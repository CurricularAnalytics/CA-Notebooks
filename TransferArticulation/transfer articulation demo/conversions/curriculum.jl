# extract curriculum / degree plan from blackbriar in CurricularAnalytics.jl format
# function blackbriar_to_ca()
#     r = jsonpayload()
#     store_metadata = haskey(@params, :meta) ? cmp(@params(:meta), "true") == 0 : false
#     dp = blackbriar_to_ca_convert(r, store_metadata=store_metadata)
#     json_dp = julia_to_json(dp)
#     return JSON.json(json_dp["curriculum"])
# end

# extract curriculum / degree plan from blackbriar in CurricularAnalytics.jl format
# processes as get request where URL to file is passed query param
# GET /degree_plan?url=bb-arizona-assets.s3-us-west-2.amazonaws.com&university=university-of-arizona&period=108&id=7404
# function blackbriar_to_ca_get()
#     if haskey(@params, :period) && haskey(@params, :id) && haskey(@params, :url)
#         period = @params(:period)
#         id = @params(:id)
#         url = @params(:url)
#         university = @params(:university)
#         store_metadata = haskey(@params, :meta) ? cmp(@params(:meta), "true") == 0 : false
#         url = "https://$(url)/json/universities/$(university)/academic_periods/$(period)/university_layouts/$(id).json"
#         r = HTTP.request("GET", url)
#         r = JSON.Parser.parse(String(r.body))
#         dp = blackbriar_to_ca_convert(r, store_metadata=store_metadata)
#         json_dp = julia_to_json(dp)
#         return JSON.json(json_dp["curriculum"])
#     end
#     return "bad!"
# end

# given CurricularAnalytics.jl format convert to JSON for blackbriar use
function ca_to_blackbriar()
    r = jsonpayload()
    dp = json_to_julia(r)
    bb_terms = ca_to_blackbriar_convert(dp)
    return JSON.json(bb_terms)
end

function ca_to_blackbriar_convert(dp::DegreePlan)
    terms = dp.terms
    bb_terms = Dict{String, Any}[]
    for (position, term) in enumerate(terms)
        bb_term = Dict{String, Any}()
        bb_term["name"] = "Term $(position)"
        bb_term["plan_items"] = Dict{String, Any}[]
        bb_term["credits"] = 0.0
        bb_term["position"] = position
        for course in term.courses
            bb_term["credits"] += course.credit_hours
            push!(bb_term["plan_items"], course.metadata)
        end
        push!(bb_terms, bb_term)
    end
    return bb_terms
end

function blackbriar_to_ca_convert(r; institution="", store_metadata=true)
    dp_name = ""
    terms = Array{Term, 1}()
    all_courses = Array{AbstractCourse, 1}()
    course_id_set = Set{Integer}()
    eng_comp_occured = false

    plan_terms = r

    # convert the degree plan term by term
    for term in plan_terms
        plan_items = term["plan_items"]
        courses = Array{AbstractCourse, 1}()

        # add all course ids from this term into the course set
        for (i, item) in enumerate(plan_items)
            if is_course(item)
                push!(course_id_set, item["requirement"]["course"]["id"])
            end
        end

        # create courses from this term
        # if it's course, create a course with requisites, if it's a set of courses, pretend it's a course without requisites (temporary solution)            
        for item in plan_items
            # println(item)
            if is_course(item)
                credit_hours = item["credits"]
                name = item["requirement"]["course"]["name"]
                code = split(item["requirement"]["course"]["code"], " ")
                cid = Int(mod(hash(code[1] * code[2] * institution), UInt32))
                course = Course(name, credit_hours, prefix=code[1], num=code[2], id=cid, institution=institution)
                build_requisites!(course, course_id_set, item["requirement"], all_courses, institution)
            else
                credit_hours = item["credits"]
                name = item["name"]
                # if haskey(item, "requirement") && item["requirement"]["type"] == "WildCardRequirement"
                #     println(item["requirement"]["type"])
                #     # id = Int(mod(hash(name * string(credit_hours)), UInt32))
                #     id = Int(mod(hash("$(name) CourseSet" * string(credit_hours)), UInt32))
                #     course = Course(name, credit_hours, id=id, institution=institution)
                # else
                #     # id = Int(mod(hash("$(name) CourseSet" * string(credit_hours)), UInt32))
                #     id = Int(mod(hash("$(name)" * string(credit_hours)), UInt32))
                #     course = Course(name, credit_hours, id=id, institution=institution)
                # end
                id = Int(mod(hash("$(name)" * string(credit_hours)), UInt32))
                course = Course(name, credit_hours, id=id, institution=institution)
                
            end
            if store_metadata
                course.metadata = item
            end
            push!(courses, course)
        end
        push!(terms, Term(courses))
        all_courses = cat(all_courses, courses, dims=1)
    end
    # build curriculum
    curric = Curriculum(dp_name, all_courses)
    # errors = IOBuffer()
    # if isvalid_curriculum(curric, errors)
    #     basic_metrics(curric)
    # else
    #     println("Curriculum $(curric.name) is not valid:")
    #     print(String(take!(errors)))
    # end
    dp = DegreePlan(dp_name, curric, terms)
    if store_metadata
        dp_metadata = Dict{String, Any}()
        dp_metadata["id"] = plan_period_join["id"]
        dp_metadata["credits_valid"] = plan_period_join["credits_valid"]
        dp_metadata["published"] = plan_period_join["published"]
        dp_metadata["completed"] = plan_period_join["completed"]
        dp_metadata["plan"] = plan_period_join["plan"]
        dp.metadata = dp_metadata
    end
    return dp
end

function build_requisites!(target_course, course_id_set, requirement, all_courses, institution)
    if requirement["type"] != "CourseRequirement"
        return reqs
    end
    # add course requisites
    if haskey(requirement["course"], "prereq")
        add_requisites!(target_course, requirement["course"]["prereq"], course_id_set, all_courses, requirement["name"], false, institution)
    end
    if haskey(requirement["course"], "coreq")
        add_requisites!(target_course, requirement["course"]["coreq"], course_id_set, all_courses, requirement["name"], true, institution)
    end
end

function add_requisites!(target_course, reqs, course_id_set, all_courses, name, is_strict, institution)
    for p in validate_req(build_requisites_helper(course_id_set, reqs, is_strict, institution, target_course_name=target_course.name), name, is_strict)
        rc = p[1]
        add_requisite!(rc, target_course, p[2])
        push!(all_courses, rc)
    end
end

function build_requisites_helper(course_id_set, req, is_strict, institution; target_course_name="", root=true)
    if req === nothing
        return []
    end

    type = req["type"]

    # base case
    if type != "or" && type != "and"
        if type == "course"
            course = req["course"]
            # the course is requisite but not taken
            if course["id"] in course_id_set
                code = split(course["code"], " ")
                cid = Int(mod(hash(code[1] * code[2] * institution), UInt32))
                course = Course(course["name"], course["minimum_credits"], prefix=code[1], num=code[2], institution=institution, id=cid)
                pair = Pair{AbstractCourse, Requisite}(course, is_strict ? strict_co : req["concurrency_ind"] ? co : pre)
                return [pair]
                
            end
            if root
                println("$(course["full_name"]) is a requisite of $(target_course_name), but it's not occured.")
            end
            return [nothing]
        end
        return []
    end

    # if the operand is "and" relation, add all to the requisites list
    # if the operand is "or" relation, add all as a course list to the requisites list (only one of them will picked later)
    requisites = []
    for operand in req["operands"]
        if type == "and"
            requisites = cat(requisites, build_requisites_helper(course_id_set, operand, is_strict, institution, target_course_name=target_course_name, root=false), dims=1)
        else
            push!(requisites, build_requisites_helper(course_id_set, operand, is_strict, institution, target_course_name=target_course_name, root=false))
        end
    end
    # eliminate course list (courses with "or" relation) based on other courses in the plan
    # e.g. if there are A, B, C, D in the plan and C has prereq of (or [A, E]), A is picked as the prereq for C
    if type == "or"
        for requisite in requisites
            if length(requisite) > 0 && requisite[1] !== nothing && all(pair -> pair[1].id in course_id_set, requisite)
                return requisite
            end
        end
        return [nothing]
    end
    return requisites
end

function validate_req(reqs, full_name, is_strict)
    type = is_strict ? "strict co-requisites" : "pre-requisites";
    if nothing in reqs
        println("Some $(type) are missing for course $(full_name)")
    end
    return filter(e -> e !== nothing, reqs)
end

function is_course(item)
    return !item["custom"] && haskey(item, "requirement") && item["requirement"]["type"] == "CourseRequirement"
end



# this function return the prefix and number for a given course-code
function get_course_prefix_num(course_code::AbstractString)

    length = sizeof(str);
    #This is the case when only letters and course Number exists e.g MIS112
    if length <= 6
        if !contains(str,"-")
        matchC = match(r"([A-Z]+)(\d+)",str)
        else
             #case : "SA-1SA"
            matchC = match(r"([A-Z]+)-((\d+)+[A-Z]+)", str)
        end
    else
        matchC = match(r"([A-Z]+)([0-9]+[A-Z]+[0-9]*)", str)
    end
    prefix = matchC.captures[1]
    num = matchC.captures[2]

    return prefix, num    
end