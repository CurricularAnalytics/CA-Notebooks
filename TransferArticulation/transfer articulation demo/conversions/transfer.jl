# function transfer_mapper(transf_map_db,send_institute_catalog::CourseCatalog,receive_institute_catalog::CourseCatalog)
    
#     transf_map = Dict{Vector{Int64}, Vector{Vector{Int64}}}()
#     reverse_transf_map = Dict{Vector{Vector{Int64}}, Vector{Int64}}()

#     for course in eachrow(transf_map_db)
#         send_courses = Array{Int64,1}()
#         receive_courses = Array{Int64,1}()
        
#         prefix=split(course.SendCourse1CourseCode)[1]
#         num=split(course.SendCourse1CourseCode)[2]
#         send_cr = pull_course_from_catalog(send_institute_catalog, prefix, num)
#         push!(send_courses,send_cr.id)

#         prefix=split(course.ReceiveCourse1CourseCode)[1]
#         num=split(course.ReceiveCourse1CourseCode)[2]
#         receive_cr = pull_course_from_catalog(receive_institute_catalog, prefix, num)
#         push!(receive_courses,receive_cr.id)

#         if !haskey(transf_map,send_courses)
#             #@info "1) $(send_cr.prefix)$(send_cr.num) ==> $(receive_cr.prefix)$(receive_cr.num)"
#             transf_map[send_courses] = [receive_courses]
#         else
#             #@info "2) $(send_cr.prefix)$(send_cr.num) ==> $(receive_cr.prefix)$(receive_cr.num)"
#             push!(transf_map[send_courses],receive_courses)
#         end
        

#     end

#     reverse_transf_map = Dict(value => key for (key, value) in transf_map)

#     return transf_map, reverse_transf_map
    
# end

# function clean_transfer_file(transf_map_db,send_institute_catalog::CourseCatalog,receive_institute_catalog::CourseCatalog)

#     dropmissing!(transf_map_db, :SendCourse1Units)
#     dropmissing!(transf_map_db, :ReceiveCourse1Units)

#     course_code_list = transf_map_db["SendCourse1CourseCode"]
#     courses_not_in_send_institute_catalog = Array{String,1}();
#     for course_code in course_code_list
#         prefix = split(course_code)[1]
#         num = split(course_code)[2]
#         catalog = send_institute_catalog.catalog
#         course = filter(course -> course.second.prefix == prefix && course.second.num == num, catalog)
#         try
#             course = collect(values(course))[1]
#         catch
#             #@info "Course not found in catalog $(prefix) $(num)"
#             push!(courses_not_in_send_institute_catalog,String(prefix*" "*num))
#         end

#     end

#     course_code_list = transf_map_db["ReceiveCourse1CourseCode"]
#     courses_not_in_receive_institute_catalog = Array{String,1}();
#     for course_code in course_code_list
#         prefix = split(course_code)[1]
#         num = split(course_code)[2]
#         catalog = receive_institute_catalog.catalog
#         course = filter(course -> course.second.prefix == prefix && course.second.num == num, catalog)
#         try
#             course = collect(values(course))[1]
#         catch
#             #@info "Course not found in catalog $(prefix) $(num)"
#             push!(courses_not_in_receive_institute_catalog,String(prefix*" "*num))
#         end

#     end

#     filter!(row -> row.SendCourse1CourseCode ∉ courses_not_in_send_institute_catalog, transf_map_db)
#     filter!(row -> row.ReceiveCourse1CourseCode ∉ courses_not_in_receive_institute_catalog, transf_map_db)

#     return transf_map_db

# end
