function handle_error(errors)
    error_string = String(take!(errors))
    if occursin("requisite cycles", error_string)
        # return error code 1 and the error string
        error_string = error_string * "\n Information on how to identify and remove requisite cycles can be found in our documentation: <a href=\"https://curricularanalytics.org/faq\">Requisite Cycles Docs</a>"
        return error_string
    else
        # return error code ??? and unknown error string
    end
end