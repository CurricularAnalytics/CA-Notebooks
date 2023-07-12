include("conversions/curriculum.jl")
include("conversions/requirements.jl")
include("conversions/viz_json.jl")
include("conversions/error_codes.jl")
include("conversions/ua_transcript.jl")
include("conversions/write_dynamodb.jl")
include("conversions/transfer.jl")

# Returns a requisite as a string for visualization
function requisite_to_string(req::Requisite)
    if req == pre
        return "prereq"
    elseif req == co
        return "coreq"
    else
        return "strict-coreq"
    end
end

# Returns a requisite (enumerated type) from a string
function string_to_requisite(req::String)
    if (req == "prereq" || req == "CurriculumPrerequisite")
        return pre
    elseif (req == "coreq" || req == "CurriculumCorequisite")
        return co
    elseif (req == "strict-coreq" || req == "CurriculumStrictCorequisite")
        return strict_co
    end
end