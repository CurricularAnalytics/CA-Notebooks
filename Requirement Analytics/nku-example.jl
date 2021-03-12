using JuMP

college = "KCTCS"
univ = "Northern Keuncky University"
KCTCS_catalog = CourseCatalog("2019-20 Academic Year", college)
NKU_catalog = CourseCatalog("2019-20 Academic Year", univ)

KCTCS_courses = Array{Course,1}()
NKU_courses = Array{Course,1}()

# Create the KCTCS Courses 
push!(KCTCS_courses, Course("Writing I", 3, prefix="ENG", num="101", institution=college))
push!(KCTCS_courses, Course("Writing II", 3, prefix="ENG", num="102", institution=college))

push!(KCTCS_courses, Course("Precalculus", 5, prefix="MAT", num="171", institution=college))
push!(KCTCS_courses, Course("Calculus I", 5, prefix="MAT", num="175", institution=college))
push!(KCTCS_courses, Course("Calculus II", 5, prefix="MAT", num="185", institution=college))

push!(KCTCS_courses, Course("Introduction to Computing", 3, prefix="CIT", num="105", institution=college))
push!(KCTCS_courses, Course("Computational Thinking", 3, prefix="CIT", num="120", institution=college))
push!(KCTCS_courses, Course("Java I", 3, prefix="CIT", num="149", institution=college))
push!(KCTCS_courses, Course("Web Page Development", 3, prefix="CIT", num="155", institution=college))
push!(KCTCS_courses, Course("Android Porogramming I", 3, prefix="CIT", num="238", institution=college))
push!(KCTCS_courses, Course("Java II", 3, prefix="CIT", num="249", institution=college))

# Add KCTCS courses to catalog
add_course!(KCTCS_catalog, KCTCS_courses)

push!(NKU_courses, Course("Great Archaeological Sites", 3, prefix="ANT", num="114", institution=univ))
push!(NKU_courses, Course("World Cultures", 3, prefix="ANT", num="201", institution=univ)) 
push!(NKU_courses, Course("North American Indians", 3, prefix="ANT", num="230", institution=univ)) 
push!(NKU_courses, Course("Modern American Indians", 3, prefix="ANT", num="231", institution=univ)) 
push!(NKU_courses, Course("Introduction to Cultural Anthropology", 3, prefix="ANT", num="100", institution=univ)) 
push!(NKU_courses, Course("Unearthing the Past: World Archaeology", 3, prefix="ANT", num="110", institution=univ)) 
push!(NKU_courses, Course("Principles of Macroeconomics", 3, prefix="ECO", num="200", institution=univ)) 
                                                                                
push!(NKU_courses, Course("Elementary Arabic I", 3, prefix="ARI", num="101", institution=univ))

push!(NKU_courses, Course("Art Appreciation", 3, prefix="ART", num="100", institution=univ))

push!(NKU_courses, Course("Solar System Astronomy with Laboratory", 4, prefix="AST", num="110", institution=univ))

push!(NKU_courses, Course("Costa Rican Natural History", 3, prefix="BIO", num="235", institution=univ))

push!(NKU_courses, Course("Computer Literacy and Informatics", 3, prefix="BIS", num="101", institution=univ))

push!(NKU_courses, Course("Networking Fundamentals", 3, prefix="CIT", num="247", institution=univ))

push!(NKU_courses, Course("Public Speaking", 3, prefix="CMST", num="101", institution=univ))
push!(NKU_courses, Course("Introduction to Communication Studies", 3, prefix="CMST", num="110", institution=univ))

push!(NKU_courses, Course("Object-Oriented Programming I", 3, prefix="CSC", num="260", institution=univ))
push!(NKU_courses, Course("Database Programming", 3, prefix="CSC", num="350", institution=univ))
push!(NKU_courses, Course("Object-Oriented Programming II", 3, prefix="CSC", num="360", institution=univ))
push!(NKU_courses, Course("Computer Systems", 3, prefix="CSC", num="362", institution=univ))
push!(NKU_courses, Course("Data Structures and Algorithms", 3, prefix="CSC", num="364", institution=univ))
push!(NKU_courses, Course("Advanced Programming Methods", 3, prefix="CSC", num="402", institution=univ))
push!(NKU_courses, Course("Software Testing and Maintenance", 3, prefix="CSC", num="439", institution=univ))
push!(NKU_courses, Course("Software Engineering", 3, prefix="CSC", num="440", institution=univ))
push!(NKU_courses, Course("Operating Systems", 3, prefix="CSC", num="460", institution=univ))
push!(NKU_courses, Course("Theory of Computation", 3, prefix="CSC", num="485", institution=univ))
push!(NKU_courses, Course("Comprehensive Examination", 0, prefix="CSC", num="491", institution=univ))

push!(NKU_courses, Course("College Writing", 3, prefix="ENG", num="101", institution=univ))
push!(NKU_courses, Course("Advanced College Writing", 3, prefix="ENG", num="102", institution=univ))
push!(NKU_courses, Course("Honors College Writing", 3, prefix="ENG", num="104", institution=univ))

push!(NKU_courses, Course("Orientation to College of Informatics", 1, prefix="INF", num="100", institution=univ))
push!(NKU_courses, Course("Elementary Programming", 3, prefix="INF", num="120", institution=univ))
push!(NKU_courses, Course("Introduction to Computer Networks", 3, prefix="INF", num="284", institution=univ))
push!(NKU_courses, Course("Introduction to Web Development", 3, prefix="INF", num="286", institution=univ))

push!(NKU_courses, Course("Finite Mathematics", 3, prefix="MAT", num="114", institution=univ))
push!(NKU_courses, Course("Mathematics for Liberal Arts", 3, prefix="MAT", num="115", institution=univ))
push!(NKU_courses, Course("Mathematics for Liberal Arts w/ Recitation", 3, prefix="MAT", num="115R", institution=univ)) 
push!(NKU_courses, Course("Precalculus", 3, prefix="MAT", num="119", institution=univ)) 
push!(NKU_courses, Course("Calculus A", 3, prefix="MAT", num="128", institution=univ)) 
push!(NKU_courses, Course("Calculus B", 3, prefix="MAT", num="227", institution=univ))
push!(NKU_courses, Course("Calculus C", 3, prefix="MAT", num="228", institution=univ))
push!(NKU_courses, Course("Probability and Statistics I", 3, prefix="STA", num="250", institution=univ))
push!(NKU_courses, Course("Discrete mathematics", 3, prefix="MAT", num="385", institution=univ))

push!(NKU_courses, Course("Einstein 101", 3, prefix="PHY", num="101", institution=univ)) 
push!(NKU_courses, Course("Introduction to Physics with Laboratory", 4, prefix="PHY", num="110", institution=univ)) 

push!(NKU_courses, Course("Probability and Statistics with Elementary Education Applications", 3, prefix="STA", num="113", institution=univ))

# Add NKU courses to catalog
add_course!(NKU_catalog, NKU_courses)

# NKU General Education Requirement
# Communication Requirement
opt1 = CourseSet("Written Option 1", 3, [course(NKU_catalog, "ENG", "104", "Honors College Writing") => grade("D")])
writtenI = CourseSet("Written I", 3, [course(NKU_catalog, "ENG", "101", "College Writing") => grade("D")])
writtenII = CourseSet("Written II", 3, [course(NKU_catalog, "ENG", "102", "Advanced College Writing") => grade("D")])
opt2 = RequirementSet("Written Option 2", 6, convert(Array{AbstractRequirement, 1}, [writtenI, writtenII]))
written = RequirementSet("Written", 6, [opt1, opt2])
oral = CourseSet("Oral", 3, [course(NKU_catalog, "CMST", "101", "Public Speaking") => grade("D"),
                            course(NKU_catalog, "CMST", "110", "Introduction to Communication Studies") => grade("D")])
comm = RequirementSet("Communication", 9, [written, oral], description="Gen. Ed. sub-requirement")

# Scientific & Quantitative Inquiry Requirement
math_stats = CourseSet("Mathematics & Statistics", 3, [course(NKU_catalog, "MAT", "114", "Finite Mathematics") => grade("D"),
                                            course(NKU_catalog, "MAT", "115", "Mathematics for Liberal Arts") => grade("D"),
                                            course(NKU_catalog, "MAT", "115R", "Mathematics for Liberal Arts w/ Recitation") => grade("D"),
                                            course(NKU_catalog, "MAT", "128", "Calculus A") => grade("D"),
                                            course(NKU_catalog, "STA", "113", "Probability and Statistics with Elementary Education Applications") => grade("D")])
                                            
nat_sci = CourseSet("Natural Science", 7,  [course(NKU_catalog, "AST", "110", "Solar System Astronomy with Laboratory") => grade("D"),
                                        course(NKU_catalog, "PHY", "101", "Einstein 101") => grade("D"),
                                        course(NKU_catalog, "PHY", "110", "Introduction to Physics with Laboratory") => grade("D"),])
sqi = RequirementSet("Scientific & Quantitative Inquiry", 10, convert(Array{AbstractRequirement, 1}, [math_stats, nat_sci]), description="Gen. Ed. sub-requirement")

# Self & Society Requirement
cult_plural = CourseSet("Cultural Pluralism", 3,  [course(NKU_catalog, "ANT", "201", "World Cultures") => grade("D"),
                                        course(NKU_catalog, "ANT", "230", "North American Indians") => grade("D"),
                                        course(NKU_catalog, "ANT", "231", "Modern American Indians") => grade("D"),])
indiv_soc = CourseSet("Individual & Society", 6,  [course(NKU_catalog, "ANT", "100", "Introduction to Cultural Anthropology") => grade("D"),
                                        course(NKU_catalog, "ANT", "110", "Unearthing the Past: World Archaeology") => grade("D"),
                                        course(NKU_catalog, "ECO", "200", "Principles of Macroeconomics") => grade("D"),])
ss = RequirementSet("Self & Society", 9, convert(Array{AbstractRequirement, 1}, [cult_plural, indiv_soc]), description="Gen. Ed. sub-requirement")

# Culture & Creativity Requirement
cc = CourseSet("Culture & Creativity", 6, [course(NKU_catalog, "ART", "100", "Art Appreciation") => grade("D"),
                                        course(NKU_catalog, "ARI", "101", "Elementary Arabic I") => grade("D")], description="Gen. Ed. sub-requirement")

# Global Viewpoints Requirement
gv = CourseSet("Global Viewpoints", 3, [course(NKU_catalog, "ANT", "100", "Introduction to Cultural Anthropology") => grade("D"),
                                        course(NKU_catalog, "ANT", "114", "Great Archaeological Sites") => grade("D"),
                                        course(NKU_catalog, "BIO", "235", "Costa Rican Natural History") => grade("D")], description="Gen. Ed. sub-requirement")
                                        
gen_ed = RequirementSet("Foundation of Knowledge", 37, [comm, sqi, ss, cc, gv], description="General Education Requirements")


# NKU CS Degree Requirements
major_reqs = Array{AbstractRequirement,1}()
push!(major_reqs, CourseSet("Individual Courses", 64, [course(NKU_catalog, "INF", "100", "Orientation to College of Informatics") => grade("D"),
                                                    course(NKU_catalog, "INF", "120", "Elementary Programming") => grade("D"),
                                                    course(NKU_catalog, "INF", "286", "Introduction to Web Development") => grade("D"),
                                                    course(NKU_catalog, "CSC", "260", "Object-Oriented Programming I") => grade("D"),
                                                    course(NKU_catalog, "CSC", "350", "Database Programming") => grade("D"),
                                                    course(NKU_catalog, "CSC", "360", "Object-Oriented Programming II") => grade("D"),
                                                    course(NKU_catalog, "CSC", "362", "Computer Systems") => grade("D"),
                                                    course(NKU_catalog, "CSC", "364", "Data Structures and Algorithms") => grade("D"),
                                                    course(NKU_catalog, "CSC", "402", "Advanced Programming Methods") => grade("D"),
                                                    course(NKU_catalog, "CSC", "439", "Software Testing and Maintenance") => grade("D"),
                                                    course(NKU_catalog, "CSC", "440", "Software Engineering") => grade("D"),
                                                    course(NKU_catalog, "CSC", "460", "Operating Systems") => grade("D"),
                                                    course(NKU_catalog, "CSC", "485", "Theory of Computation") => grade("D"),
                                                    course(NKU_catalog, "CSC", "491", "Comprehensive Examination") => grade("D"),
                                                    course(NKU_catalog, "MAT", "128", "Calculus A") => grade("D"),
                                                    course(NKU_catalog, "MAT", "227", "Calculus B") => grade("D"),
                                                    course(NKU_catalog, "MAT", "228", "Calculus C") => grade("D"),
                                                    course(NKU_catalog, "STA", "250", "Probability and Statistics I") => grade("D"),
                                                    course(NKU_catalog, "MAT", "385", "Discrete mathematics") => grade("D") ] ))

networking_req = CourseSet("Networking Major Requirement", 3, [course(NKU_catalog, "INF", "284", "Introduction to Computer Networks") => grade("D"),
                                                         course(NKU_catalog, "CIT", "247", "Networking Fundamentals") => grade("D") ])
push!(major_reqs, networking_req)
upper_level_req = CourseSet("Upper Level Major Requirement", 6, course_catalog=NKU_catalog, prefix_regex=r"^CSC", num_regex=r"^4", course_regex=r"MAT360", 
                           min_grade=grade("D"), description="Upper level CSC courses")
push!(major_reqs, upper_level_req)

cs_mr = RequirementSet("Major Requirements", 64, major_reqs, description="CS Major Requirements")

cs_dr = RequirementSet("Degree Requirements", 120, convert(Array{AbstractRequirement,1}, [gen_ed, cs_mr]), description="Degree Requirements for the BS Computer Science Degree")

# Create the transfer articulation map between KCTCS and NKU
NKU_xfer = TransferArticulation("NKU Transfer Articulation", univ, NKU_catalog)
add_transfer_catalog(NKU_xfer, KCTCS_catalog)
add_transfer_course(NKU_xfer, [course_id("ENG", "101", "College Writing", univ)], KCTCS_catalog.id, course_id("ENG", "101", "Writing I", college))
add_transfer_course(NKU_xfer, [course_id("ENG", "102", "Advanced College Writing", univ)], KCTCS_catalog.id, course_id("ENG", "102", "Writing II", college))
add_transfer_course(NKU_xfer, [course_id("MAT", "119", "Precalculus", univ)], KCTCS_catalog.id, course_id("MAT", "171", "Precalculus", college))
add_transfer_course(NKU_xfer, [course_id("MAT", "128", "Calculus A", univ)], KCTCS_catalog.id, course_id("MAT", "175", "Calculus I", college))
add_transfer_course(NKU_xfer, [course_id("MAT", "227", "Calculus B", univ)], KCTCS_catalog.id, course_id("MAT", "185", "Calculus II", college))
add_transfer_course(NKU_xfer, [course_id("BIS", "101", "Computer Literacy and Informatics", univ)], KCTCS_catalog.id, course_id("CIT", "105", "Introduction to Computing", college))
add_transfer_course(NKU_xfer, [course_id("INF", "100", "Orientation to College of Informatics", univ)], KCTCS_catalog.id, course_id("CIT", "120", "Computational Thinking", college))
add_transfer_course(NKU_xfer, [course_id("INF", "120", "Elementary Programming", univ)], KCTCS_catalog.id, course_id("CIT", "149", "Java I", college))
add_transfer_course(NKU_xfer, [course_id("INF", "286", "Introduction to Web Development", univ)], KCTCS_catalog.id, course_id("CIT", "155", "Web Page Development", college))
add_transfer_course(NKU_xfer, [course_id("CSC", "260", "Object-Oriented Programming I", univ)], KCTCS_catalog.id, course_id("CIT", "238", "Android Programming I", college))
add_transfer_course(NKU_xfer, [course_id("CSC", "360", "Object-Oriented Programming II", univ)], KCTCS_catalog.id, course_id("CIT", "249", "Java II", college))

# Create a transcript involving KCTCS coursework
KCTCS_transcript = Array{CourseRecord,1}()
push!(KCTCS_transcript, CourseRecord(course(KCTCS_catalog, "CIT", "105", "Introduction to Computing"), grade("A")))
push!(KCTCS_transcript, CourseRecord(course(KCTCS_catalog, "ENG", "101", "Writing I"), grade("B")))
push!(KCTCS_transcript, CourseRecord(course(KCTCS_catalog, "MAT", "171", "Precalculus"), grade("A")))
push!(KCTCS_transcript, CourseRecord(course(KCTCS_catalog, "MAT", "175", "Calculus I"), grade("D")))
push!(KCTCS_transcript, CourseRecord(course(KCTCS_catalog, "CIT", "120", "Computational Thinking"), grade("B")))
push!(KCTCS_transcript, CourseRecord(course(KCTCS_catalog, "ENG", "102", "Writing II"), grade("B")))

# Map KCTCS courses and grades to NKU courses and grades through transfer equivalences
NKU_equiv_transcript = Array{CourseRecord,1}()
for cr in KCTCS_transcript
    if (equiv_courses = transfer_equiv(NKU_xfer, KCTCS_catalog.id, cr.course.id)) !== nothing
        for ec in equiv_courses 
            push!(NKU_equiv_transcript, CourseRecord(NKU_catalog.catalog[ec], cr.grade))
        end
    end
end