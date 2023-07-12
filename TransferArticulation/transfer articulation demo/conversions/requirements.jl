function import_blackbriar_courses(r, university_courses, university_catalogs)
    all_courses = r["courses"]
    university_name = r["university_name"]
    university_courses["$(university_name)_courses"] = Array{Course, 1}()
    
    university_catalogs["$(university_name)_catalog"] = CourseCatalog("$(university_name) Catalog", "$(university_name)")

    for course in all_courses
        if course["num"] === nothing
            continue
        end
        cid = mod(hash(course["name"] * course["prefix"] * course["num"] * course["institution"]), UInt32)
        cid = convert(Int, cid)
        push!(university_courses[course["collection_name"]], Course(course["name"], course["max_creds"], 
                prefix=course["prefix"], num=course["num"], institution=course["institution"], id=cid))
    end

    add_course!(university_catalogs["$(university_name)_catalog"], university_courses["$(university_name)_courses"])
end

function parse_requirement_set(r, catalog)
    individual_courses = Array{Pair{Course, Grade},1}()
    individual_credit_hours = 0
    minors_and_electives = Array{AbstractRequirement, 1}()
    minors_and_electives_hours = 0
    gen_ed = Dict{String, AbstractRequirement}()
    degree_reqs = Array{AbstractRequirement, 1}()
    degree_reqs_hours = 0

    for item in r
        if item["type"] == "CourseRequirement"
            prefix, num = split(item["course"]["code"], " ")
            push!(individual_courses, course(catalog, prefix, num, item["course"]["name"]) => grade(item["minimum_grade"]))
            individual_credit_hours += item["credits"]
            # item["credits"] < 0.1 ? individual_credit_hours += 100.0 : individual_credit_hours += item["credits"]
        # grab degree requirements
        elseif item["type"] == "DegreeRequirement"
            req = process_degree_req(item, catalog, gen_ed)
            push!(degree_reqs, req)
            degree_reqs_hours += req.credit_hours

        # grabbing gen_eds (cores)
        # TODO: account for cores that are not actually gen_ed
        elseif item["type"] == "CoreRequirement"
            process_core_req(item, gen_ed, catalog)
        
        # handle all wildcard courses (courses that are electives, minor courses, upper level department, etc)
        elseif item["type"] == "WildCardRequirement"
            # TODO: the below assumes there is only one rule, but it should iterate over the rules
            
            #=
                NOTE: the below will match all subject codes if the provided subject code is blank (code_string == "")
                This might make sense if subject_code is not provided but the min and max course numbers are (match all courses between nums)
            =#
            set = process_wildcard_req(item, catalog)
            push!(minors_and_electives, set)
            minors_and_electives_hours += item["minimum_credits"]

        end
    end

    # put gen_ed sets into an array of requirements
    gen_ed_arr = Array{AbstractRequirement, 1}()
    gen_ed_hours = 0
    for (k, v) in gen_ed
        push!(gen_ed_arr, v)
        gen_ed_hours += v.credit_hours
    end
    # create gen_ed requirements set
    gen_ed = RequirementSet("General Education Core", gen_ed_hours, gen_ed_arr)

    # build major requisite set from courses and minors & electives
    major_reqs = Array{AbstractRequirement, 1}()
    push!(major_reqs, CourseSet("Individual Courses", individual_credit_hours, individual_courses))
    push!(major_reqs, RequirementSet("Minors & Electives", minors_and_electives_hours, minors_and_electives))
    append!(major_reqs, degree_reqs)
    major_reqs = RequirementSet("Major Requirements", individual_credit_hours + minors_and_electives_hours + degree_reqs_hours, major_reqs)

    credit_hours = gen_ed.credit_hours + major_reqs.credit_hours
    # create degree requirements
    # TODO: description should be determined dynamically not manually
    req_desc = "Requirements file has no description"
    dr = RequirementSet("Degree Requirements", credit_hours, convert(Array{AbstractRequirement, 1}, [gen_ed, major_reqs]), description=req_desc)

    return dr
end

function parse_degree_plan_requirements(r, catalog)
    # total credit hours for requirements
    total_credits = r["period_degree_joins"][1]["total_credit_hours"]
    plan_terms = r["period_degree_joins"][1]["plan_period_joins"][1]["plan_terms"]

    individual_courses = Array{Pair{Course, Grade}, 1}()
    individual_credit_hours = 0
    minors_and_electives = Array{AbstractRequirement, 1}()
    minors_and_electives_hours = 0
    gen_ed = Dict{String, AbstractRequirement}()
    
    degree_reqs = Array{AbstractRequirement, 1}()
    degree_reqs_hours = 0

    for term in plan_terms
        plan_items = term["plan_items"]
        for item in plan_items
            if item["custom"] == true || item["requirement"] == "null"
                println("\"$(item["name"])\" is a custom plan item. This should be corrected in blackbriar!")
                continue
            end
            credit_units=item["credits"]
            println("main requirement name: \"$(item["name"])\" with credits: \"$(item["credits"])\" ")
            item = item["requirement"]
            # if the req in blackbriar is a CourseRequirement that is a CourseSet with a single Course
            # these are pushed to the collection of individual_courses (major courses)
            if item["type"] == "CourseRequirement"
                prefix, num = split(item["course"]["code"], " ")
                push!(individual_courses, course(catalog, prefix, num, item["course"]["name"]) => grade(item["minimum_grade"]))
                individual_credit_hours += item["credits"]
                
            # grab degree requirements
            elseif item["type"] == "DegreeRequirement"
                req = process_degree_req(item, catalog, gen_ed)
                push!(degree_reqs, req)
                degree_reqs_hours += req.credit_hours

            # grabbing gen_eds (cores)
            # TODO: account for cores that are not actually gen_ed
            elseif item["type"] == "CoreRequirement"
                process_core_req(item, gen_ed, catalog)
            
            # handle all wildcard courses (courses that are electives, minor courses, upper level department, etc)
            elseif item["type"] == "WildCardRequirement"
                # TODO: the below assumes there is only one rule, but it should iterate over the rules
                
                #=
                 NOTE: the below will match all subject codes if the provided subject code is blank (code_string == "")
                 This might make sense if subject_code is not provided but the min and max course numbers are (match all courses between nums)
                =#
                set = process_wildcard_req(item, catalog)
                push!(minors_and_electives, set)
                minors_and_electives_hours += item["minimum_credits"]

            end
        end
    end

    # put gen_ed sets into an array of requirements
    gen_ed_arr = Array{AbstractRequirement, 1}()
    gen_ed_hours = 0
    for (k, v) in gen_ed
        push!(gen_ed_arr, v)
        gen_ed_hours += v.credit_hours
    end
    # create gen_ed requirements set
    gen_ed = RequirementSet("General Education Core", gen_ed_hours, gen_ed_arr)

    # build major requisite set from courses and minors & electives
    major_reqs = Array{AbstractRequirement, 1}()
    push!(major_reqs, CourseSet("Individual Courses", individual_credit_hours, individual_courses))
    push!(major_reqs, RequirementSet("Minors & Electives", minors_and_electives_hours, minors_and_electives))
    append!(major_reqs, degree_reqs)
    major_reqs = RequirementSet("Major Requirements", individual_credit_hours + minors_and_electives_hours + degree_reqs_hours, major_reqs)

    credit_hours = gen_ed.credit_hours + major_reqs.credit_hours

    # create degree requirements
    # TODO: description should be determined dynamically not manually
    req_desc = "Degree Requirements of $(r["program"]["name"])"
    dr = RequirementSet("Degree Requirements", credit_hours, convert(Array{AbstractRequirement, 1}, [gen_ed, major_reqs]), description= req_desc)

    return dr
end

function process_core_req(item, gen_ed, catalog; degree_req=false)
    # hold the courses that make up this core requirement
    courses = Array{Pair{Course, Grade}, 1}()
    course_sets = Array{AbstractRequirement, 1}()
    # for each subrequirement of the core
    for item in item["core"]["subrequirements"]
        # if the current item has subrequirements of its own (it is a separate CourseSet)
        if (item["type"] == "DegreeRequirement") 
            set = process_degree_req(item, catalog, gen_ed)
            push!(course_sets, set)
        elseif (item["type"] == "WildCardRequirement")
            set = process_wildcard_req(item, catalog)
            push!(course_sets, set)
        # otherwise it is a single course that can count towards satisfying the core requirement
        else
            prefix, num = split(item["course"]["code"], " ")
            push!(courses, course(catalog, prefix, num, item["course"]["name"]) => grade(item["minimum_grade"]))
        end
    end

    if length(course_sets) == 0
        req_set = CourseSet(item["core"]["name"], item["core"]["minimum_credits"], courses)
    else
        main_course_set = CourseSet(item["core"]["name"] * " CourseSet", item["core"]["minimum_credits"], courses)
        push!(course_sets, main_course_set)
        # CoreRequirement Name: GE General Math Strand
        # req_set name = "GE General Math Strand RequirementSet"
        req_set = RequirementSet(item["core"]["name"] * " RequirementSet", item["core"]["minimum_credits"], 
                                    convert(Array{AbstractRequirement, 1}, course_sets), satisfy = item["core"]["required"])
    end
    if (degree_req)
        return req_set
    else
        # TODO: investigate how this value changes (print it when reading in a few programs)
        key = (length(course_sets) == 0) ? item["core"]["name"] : item["core"]["name"] * " RequirementSet"
        # check for duplicate cores (if this core has been seen before)
        if haskey(gen_ed, key)
            # this core has already been defined, check if they are the same name
            # TODO: try checking with something better, like if the collection of requisites is the same
            # TODO: define the equality operator for the RequirementSet datatype
            if gen_ed[key].name == req_set.name
                #println("repeated degree")
                # they are the same value, so add in the minimum credits again (this will be done for however many times the core is duplicated)
                gen_ed[key].credit_hours += item["core"]["minimum_credits"]
                # if key ends in RequirementSet increment the number of requirements you must satisfy
                (key[end-13:end] == "RequirementSet") ? gen_ed[key].satisfy += 1 : nothing
            else
                error("Duplicate core entry that does not contain the same courses: $(gen_ed[item["core"]["name"]])")
            end
        else
            gen_ed[key] = req_set
        end
    end
end

function process_degree_req(item, catalog, gen_ed)
    # hold the courses that make up this core requirement
    courses = Array{Pair{Course, Grade}, 1}()
    requirement_sets = Array{AbstractRequirement, 1}()
    # for each course in the course requirement, push them to courses array
    for item in item["subrequirements"]
        if (item["type"] == "CoreRequirement")
            set = process_core_req(item, gen_ed, catalog, degree_req=true)
            push!(requirement_sets, set)
        elseif (item["type"] == "DegreeRequirement")
            set=process_degree_req(item, catalog, gen_ed)
            push!(requirement_sets, set)
        elseif (item["type"] == "WildCardRequirement")
            set = process_wildcard_req(item, catalog)
            push!(requirement_sets, set)
        else
            prefix, num = split(item["course"]["code"], " ")
            push!(courses, course(catalog, prefix, num, item["course"]["name"]) => grade(item["minimum_grade"]))
        end
    end
    if length(courses) != 0
        course_set = CourseSet("$(item["name"]) CourseSet", item["minimum_credits"], courses)
        push!(requirement_sets, course_set)
    end
    if length(requirement_sets) == 1 && typeof(requirement_sets[1]) == CourseSet
        return requirement_sets[1]
    end
    return RequirementSet(item["name"], item["minimum_credits"], requirement_sets, satisfy = item["required"])
end

function process_wildcard_req(item, catalog)
    if isassigned(item["rules"], 1)
        # get item prefix. if it is empty then match all prefixes
        prefix = item["rules"][1]["code_string"] != "" ? Regex("^$(item["rules"][1]["code_string"])") : r"\w+"
        # get item's min course number. if it is empty then match all numbers
        num = item["rules"][1]["minimum_match_number"] != "" ? Regex("^$(item["rules"][1]["minimum_match_number"][1])") : r"\w+"
        # create a course set that matches from prefix and min number (via regular expressions defined in CurricularAnalytics::CourseSet constructor.)
    else
        prefix = r"\w+"
        num = r"\w+"
    end
    return CourseSet(item["name"], item["minimum_credits"], course_catalog=catalog, prefix_regex=prefix, num_regex=num, min_grade=grade("D"))
end