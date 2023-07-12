function store_metadata(course)
    metadata = Dict{String, Any}()
    if haskey(course, "nameSub")
        typeof(course["nameSub"]) == String ? metadata["nameSub"] = course["nameSub"] : nothing # set nameSub if it is provided
    end
    if haskey(course, "nameCanonical")
        typeof(course["nameCanonical"]) == String ? metadata["nameCanonical"] = course["nameCanonical"] : nothing # set nameCanonical if it is provided
    end
    if haskey(course, "annotation")
        typeof(course["annotation"]) == String ? metadata["annotation"] = course["annotation"] : nothing # set annotation if it is provided
    end
    if haskey(course, "metadata")
        merge!(metadata, course["metadata"]) # add any metadata in the json to the julia course
    end
    return metadata
end

function json_to_julia(json_tuple)
    all_course_objects = Array{Course}(undef, 0)
    courses_dict = Dict{Int, Course}()

    if ("courses" in keys(json_tuple)) # If the received data is a curriculum (and not a degree plan)
        num_courses = length(json_tuple["courses"])
        
        for i = 1:num_courses # For each of the courses in the received tuple, create a Julia Course object
            current_course = json_tuple["courses"][i]
            if current_course["credits"] == nothing 
                current_course["credits"] = 0
            end
            metadata = store_metadata(current_course)
            course_object = Course(current_course["name"], current_course["credits"], id=current_course["id"])
            course_object.metadata = metadata
            push!(all_course_objects, course_object)
            courses_dict[current_course["id"]] = course_object  # Add the course_object using the current_course id as the index
        end

        for i = 1:num_courses # For each course in the received tuple, create its requisites
            current_course = json_tuple["courses"][i]
            for req in current_course["requisites"] # For each requisite that the current_course has...
                source = courses_dict[req["source_id"]]
                target = courses_dict[req["target_id"]]
                add_requisite!(source, target, string_to_requisite(req["type"]))
            end
        end

        curriculum_name = haskey(json_tuple, "name") ? json_tuple["name"] : ""

        system_type = CurricularAnalytics.semester
        if ("system_type" in keys(json_tuple))
            system_type = json_tuple["system_type"] == "quarter" ? CurricularAnalytics.quarter : CurricularAnalytics.semester
        end
        
        curric = Curriculum(curriculum_name, all_course_objects, system_type = system_type)
        return curric

    elseif ("curriculum_terms" in keys(json_tuple)) # Received data must be a degree plan. Visualization API Data is this format.
        num_terms = length(json_tuple["curriculum_terms"])
        terms = Array{Term}(undef, num_terms)
        
        for i = 1:num_terms # For every term
            current_term = json_tuple["curriculum_terms"][i]
            term_courses = Array{Course}(undef, 0)
            
            for course in current_term["curriculum_items"] # For each course in the current term
                metadata = store_metadata(course)
                current_course = Course(course["name"], course["credits"], id=course["id"])
                current_course.metadata = metadata
                push!(term_courses, current_course)
                push!(all_course_objects, current_course)
                courses_dict[course["id"]] = current_course
            end

            for course in current_term["curriculum_items"] # For each course object create its requisites
                if !isempty(course["curriculum_requisites"]) # if the course has requisites
                    for req in course["curriculum_requisites"] # loop through each of them
                        source = courses_dict[req["source_id"]]
                        target = courses_dict[req["target_id"]]
                        add_requisite!(source, target, string_to_requisite(req["type"])) # create the requisite relationship
                    end
                end
            end

            # Set the current term to be a Term object
            terms[i] = Term(term_courses)
        end

        curriculum_name = haskey(json_tuple, "name") ? json_tuple["name"] : ""

        system_type = CurricularAnalytics.semester
        if ("system_type" in keys(json_tuple))
            system_type = json_tuple["system_type"] == "quarter" ? CurricularAnalytics.quarter : CurricularAnalytics.semester
        end

        curric = Curriculum(curriculum_name, all_course_objects, system_type = system_type)
        degreeplan = DegreePlan((haskey(json_tuple, "name") ? json_tuple["name"] : ""), curric, terms)
        return degreeplan
    else
        @error "Unable to convert JSON to Julia - unknown JSON data type"
    end
end

function julia_to_json(julia_object)
    if (typeof(julia_object) == DegreePlan)
        json_dp = Dict{String, Any}()
        json_dp["curriculum"] = Dict{String, Any}()
        json_dp["curriculum"]["name"] = julia_object.name
        json_dp["curriculum"]["curriculum_terms"] = Dict{String, Any}[]
        json_dp["curriculum"]["metadata"] = julia_object.metadata
        for i = 1:julia_object.num_terms
            current_term = Dict{String, Any}()
            current_term["id"] = i
            current_term["name"] = "Term $i"
            current_term["curriculum_items"] = Dict{String, Any}[]
            for course in julia_object.terms[i].courses
                current_course = Dict{String, Any}()
                current_course["id"] = course.id
                current_course["name"] = course.name
                current_course["credits"] = course.credit_hours
                current_course["curriculum_requisites"] = Dict{String, Any}[]
                if !isempty(course.metadata)
                    current_course["metadata"] = course.metadata
                end
                if !isempty(course.metrics)
                    current_course["metrics"] = course.metrics
                end
                haskey(course.metadata, "nameSub") ? current_course["nameSub"] = course.metadata["nameSub"] : nothing
                haskey(course.metadata, "nameCanonical") ? current_course["nameCanonical"] = course.metadata["nameCanonical"] : nothing
                haskey(course.metadata, "annotation") ? current_course["annotation"] = course.metadata["annotation"] : nothing
                for req in collect(keys(course.requisites))
                    current_req = Dict{String, Any}()
                    current_req["source_id"] = req
                    current_req["target_id"] = course.id
                    current_req["type"] = requisite_to_string(course.requisites[req])
                    push!(current_course["curriculum_requisites"], current_req)
                end
                push!(current_term["curriculum_items"], current_course)
            end
            push!(json_dp["curriculum"]["curriculum_terms"], current_term)
        end
        if !isempty(julia_object.curriculum.metrics)
            json_dp["curriculum"]["metrics"] = Dict{String, Any}()
            json_dp["curriculum"]["metrics"]["complexity"] = julia_object.curriculum.metrics["complexity"][1]
            if ( haskey(julia_object.curriculum.metrics, "centrality") )
                (isdefined(julia_object.curriculum.metrics["centrality"], 1)) ? json_dp["curriculum"]["metrics"]["centrality"] = julia_object.curriculum.metrics["centrality"][1] : Nothing
            end
        end
        return json_dp
    elseif (typeof(julia_object) == Curriculum)
        # TODO Implement conversion from Curriculum object to JSON
        return julia_object
    end
end