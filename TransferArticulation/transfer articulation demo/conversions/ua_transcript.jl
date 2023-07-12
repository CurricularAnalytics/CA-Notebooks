function pull_course_from_catalog(course_catalog, prefix, num)
    catalog = course_catalog.catalog
    course = filter(course -> course.second.prefix == prefix && course.second.num == num, catalog)
    try
        course = collect(values(course))[1]
        #@warn "Course IS found in catalog $(prefix) $(num)"
        return course
    catch
        @warn "Course IS NOT found in catalog $(prefix) $(num)"
        return nothing
    end
end

function get_courses_not_in_catalog(course_catalog)
    
    courses_not_in_catalog = Array{String,1}();

    for course_code in course_code_list

        prefix, num = get_course_prefix_num(course_code)

        catalog = course_catalog.catalog
        course = filter(course -> course.second.prefix == prefix && course.second.num == num, catalog)
        try
            course = collect(values(course))[1]
        catch
            #@info "Course not found in catalog $(prefix) $(num)"
            push!(courses_not_in_catalog,String(prefix*num))
        end

    end

    return courses_not_in_catalog

end


#this function to convert UA transcript from dataframe (i.e CSV) format to CA transcript format
function convert_transcript(studentid, student_transcript_dataframe, course_catalog)
    #@info "CONVERT WAS CALLED"
    transcript = Array{CourseRecord,1}()
    student_transcript = filter(
        #Courses with below grades are not required for analysis 
        #Refere to UA website for more details: https://catalog.arizona.edu/policy/grades-and-grading-system 
        row -> row.STUDENTID == studentid && row.GRADE ∉ ["O","CR","XO","WO","K"], 
        student_transcript_dataframe
    )

    for course in eachrow(student_transcript)
        prefix, num = get_course_prefix_num(course.COURSE_CODE)
        this_course = pull_course_from_catalog(course_catalog, prefix, num)
        if isnothing(this_course)
            #@info "$(prefix)$(num) is not in course catalog"
            continue
        end
        this_course_record = CourseRecord(this_course, grade(course.GRADE),course.TERM_DESC)
        push!(transcript, this_course_record)
    end

    return transcript
end

#To convert BB degree-requirements from json to CA format
function get_deg_req(course_catalog,college,department,program_name,program_code,json_folder)

    req_file_location = json_folder*program_code*".json"
    credit_file_location = json_folder*program_code*"_credit.json"

    #read programs degree requirements and total credit 
    prog_reqs = JSON.parsefile("$req_file_location");
    prog_reqs_total_credit = JSON.parsefile("$credit_file_location");
    prog_total_credit = Int(prog_reqs_total_credit["total_credit_hours"])

    # deg_req = parse_requirement_set(prog_reqs, course_catalog; total_credit = prog_total_credit);
    deg_req = parse_requirement_set(prog_reqs, course_catalog);

    return deg_req , prog_total_credit
end


function get_num_terms(current_term,first_enrolled_term)

    if iszero((current_term-first_enrolled_term)%5)
        num_terms = ((current_term-first_enrolled_term)/5)      

    else
        num_terms = (((current_term-first_enrolled_term)-((current_term-first_enrolled_term)%5))/5)+1

    end

    return num_terms

end



function student_progress_analysis(studentid, counted_credit, milestone, tolerance, system_type,deg_req_total_credit,current_term,first_enrolled_term)

    #global expected_progress_per_term 
    if system_type == "semester"
        expected_progress_per_term = deg_req_total_credit/(milestone * 2)
    elseif system_type == "quarter"
        expected_progress_per_term = deg_req_total_credit/(milestone * 3)
    end

    number_of_terms = get_num_terms(current_term,first_enrolled_term)

    expected_progress = expected_progress_per_term * number_of_terms/deg_req_total_credit

    progress = counted_credit/deg_req_total_credit

    if progress+tolerance < expected_progress
        progress_status = "Behind"

    elseif progress-tolerance > expected_progress
        progress_status = "Ahead"

    else
        progress_status = "On Track"

    end

    return round(progress,digits=3)*100, progress_status

end
