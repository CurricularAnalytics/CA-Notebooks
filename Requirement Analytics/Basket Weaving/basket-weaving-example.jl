using JuMP

# Basket Weaving RequirementSatisfaction Example
college = "Tri-County Community College"
univ = "Big State U"
tri_county_catalog = CourseCatalog("2019-20 Academic Year", college)
big_state_catalog = CourseCatalog("2019-20 Academic Year", univ)
tri_county_courses = Array{Course,1}()
big_state_courses = Array{Course,1}()

# Create the tri county Courses 
push!(tri_county_courses, Course("Probability & Statistics", 3, prefix="MA", num="107", institution=college))
push!(tri_county_courses, Course("Aerobics", 3, prefix="EXE", num="105", institution=college))
push!(tri_county_courses, Course("Baskets 101", 5, prefix="BW", num="101", institution=college))
push!(tri_county_courses, Course("World Literature", 5, prefix="ENG", num="110", institution=college))
push!(tri_county_courses, Course("Art History", 5, prefix="ART", num="100", institution=college))

# Add tri county courses to catalog
add_course!(tri_county_catalog, tri_county_courses)

# requisites for MATH courses
#add_requisite!(course(tri_county_catalog, "MATH", "120R", "Calculus Preparation", univ),
#               course(tri_county_catalog, "MATH", "122A", "Functions for Calculus", univ),
#               pre)

# Create the big state Courses
push!(big_state_courses, Course("College Algebra", 3, prefix="MATH", num="110", institution=univ))
push!(big_state_courses, Course("Statistics", 3, prefix="MATH", num="120", institution=univ))
push!(big_state_courses, Course("Calculus I", 3, prefix="MATH", num="180", institution=univ)) 
push!(big_state_courses, Course("College Trigonometry", 3, prefix="MATH", num="140", institution=univ)) 

push!(big_state_courses, Course("Swimming", 3, prefix="PHS", num="110", institution=univ)) 
push!(big_state_courses, Course("Weightlifting", 3, prefix="PHS", num="120", institution=univ)) 
push!(big_state_courses, Course("Aerobics", 3, prefix="PHS", num="130", institution=univ)) 
                                                                        
push!(big_state_courses, Course("History of Art", 3, prefix="ART", num="101", institution=univ))
push!(big_state_courses, Course("Intro. Philosophy", 3, prefix="PHIL", num="100", institution=univ))
push!(big_state_courses, Course("World Literature", 4, prefix="LIT", num="130", institution=univ))

push!(big_state_courses, Course("College Trigonometry", 3, prefix="MATH", num="140", institution=univ))
push!(big_state_courses, Course("Intro. Philosophy", 3, prefix="PHIL", num="100", institution=univ))
push!(big_state_courses, Course("Basic Basket Forms", 3, prefix="BW", num="101", institution=univ))
push!(big_state_courses, Course("Basket Materials", 3, prefix="BW", num="220", institution=univ))
push!(big_state_courses, Course("Philosophy of Weaving", 3, prefix="BW", num="300", institution=univ))

push!(big_state_courses, Course("Scuba Diving", 3, prefix="PHS", num="210", institution=univ))
push!(big_state_courses, Course("Waterproof Materials", 3, prefix="BW", num="330", institution=univ))

push!(big_state_courses, Course("Ancient Basket Forms", 3, prefix="BW", num="201", institution=univ))
push!(big_state_courses, Course("Functional Basketry", 3, prefix="BW", num="340", institution=univ))

# Add big state courses to catalog
add_course!(big_state_catalog, big_state_courses)

# Bit State U General Education Requirement
# Math Requirement
math = CourseSet("Math Requirement", 3, [course(big_state_catalog, "MATH", "120", "Statistics") => grade("D"),
                                        course(big_state_catalog, "MATH", "180", "Calculus I") => grade("D"),
                                        course(big_state_catalog, "MATH", "140", "College Trigonometry") => grade("D")],
                                        double_count = true)
# Physical Education Requirement
phys_ed = CourseSet("Phyiscal Ed. Requirement", 3, [course(big_state_catalog, "PHS", "110", "Swimming") => grade("D"),
                                                    course(big_state_catalog, "PHS", "120", "Weightlifting") => grade("D"),
                                                    course(big_state_catalog, "PHS", "130", "Aerobics") => grade("D")])
# Humanitites Requirement
humanities = CourseSet("Humanitites Requirement", 3, [course(big_state_catalog, "ART", "101", "History of Art") => grade("D"),
                                                    course(big_state_catalog, "PHIL", "100", "Intro. Philosophy") => grade("D"),
                                                    course(big_state_catalog, "LIT", "130", "World Literature") => grade("D")],
                                                    double_count = true)

gen_ed = RequirementSet("General Education Core", 9, convert(Array{AbstractRequirement,1}, [math, phys_ed, humanities]), description="General Education Requirements")

# Big State U Degree Requirements
major_reqs = Array{AbstractRequirement,1}()
major_emphasis = Array{AbstractRequirement, 1}()
push!(major_reqs, CourseSet("Individual Courses", 15, [course(big_state_catalog, "MATH", "140", "College Trigonometry") => grade("D"),
                                                    course(big_state_catalog, "PHIL", "100", "Intro. Philosophy") => grade("D"),
                                                    course(big_state_catalog, "BW", "101", "Basic Basket Forms") => grade("D"),
                                                    course(big_state_catalog, "BW", "220", "Basket Materials") => grade("D"),
                                                    course(big_state_catalog, "BW", "300", "Philosophy of Weaving") => grade("D") ] ))

underwater_req = CourseSet("Underwater Basket Weaving", 6, [course(big_state_catalog, "PHS", "210", "Scuba Diving") => grade("D"),
                                                            course(big_state_catalog, "BW", "330", "Waterproof Materials") => grade("D") ])
push!(major_emphasis, underwater_req)

traditional_req = CourseSet("Traditional Basket Weaving", 6, [course(big_state_catalog, "BW", "201", "Ancient Basket Forms") => grade("D"),
                                                            course(big_state_catalog, "BW", "340", "Functional Basketry") => grade("D") ])
push!(major_emphasis, traditional_req)

bw_emphasis = RequirementSet("Major Emphasis", 6, major_emphasis, satisfy=1, description="Basket Weaving Major Emphasis")

push!(major_reqs, bw_emphasis)

bw_major = RequirementSet("Major Requirements", 21, major_reqs, description="Basket Weaving Major Requirements")

bw_dr = RequirementSet("Degree Requirements", 30, convert(Array{AbstractRequirement,1}, [gen_ed, bw_major]), description="Degree Requirements for the BS Computer Science Degree")

# Create the transfer articulation map between tri county and big state
BSU_xfer = TransferArticulation("Big State U Transfer Articulation", univ, big_state_catalog)
add_transfer_catalog(BSU_xfer, tri_county_catalog)
add_transfer_course(BSU_xfer, [course_id("MATH", "120", "Statistics", univ)], tri_county_catalog.id, course_id("MA", "107", "Probability & Statistics", college))
add_transfer_course(BSU_xfer, [course_id("PHS", "130", "Aerobics", univ)], tri_county_catalog.id, course_id("EXE", "105", "Aerobics", college))
add_transfer_course(BSU_xfer, [course_id("BW", "101", "Basic Basket Forms", univ)], tri_county_catalog.id, course_id("BW", "101", "Baskets 101", college))
add_transfer_course(BSU_xfer, [course_id("LIT", "130", "World Literature", univ)], tri_county_catalog.id, course_id("ENG", "110", "World Literature", college))
add_transfer_course(BSU_xfer, [course_id("ART", "101", "History of Art", univ)], tri_county_catalog.id, course_id("ART", "100", "Art History", college))

# Create a transcript involving tri county coursework
tri_county_transcript = Array{CourseRecord,1}()
push!(tri_county_transcript, CourseRecord(course(tri_county_catalog, "MA", "107", "Probability & Statistics"), grade("A")))
push!(tri_county_transcript, CourseRecord(course(tri_county_catalog, "EXE", "105", "Aerobics"), grade("B")))
push!(tri_county_transcript, CourseRecord(course(tri_county_catalog, "BW", "101", "Baskets 101"), grade("A")))
push!(tri_county_transcript, CourseRecord(course(tri_county_catalog, "ENG", "110", "World Literature"), grade("D")))
push!(tri_county_transcript, CourseRecord(course(tri_county_catalog, "ART", "100", "Art History"), grade("B")))

# Map KCTCS courses and grades to NKU courses and grades through transfer equivalences
BSU_equiv_transcript = Array{CourseRecord,1}()
for cr in tri_county_transcript
    if (equiv_courses = transfer_equiv(BSU_xfer, tri_county_catalog.id, cr.course.id)) !== nothing
        for ec in equiv_courses 
            push!(BSU_equiv_transcript, CourseRecord(big_state_catalog.catalog[ec], cr.grade))
        end
    end
end

# Determine the requirements satisfied at BSU by the articulated courses
model = assign_courses(BSU_equiv_transcript, bw_dr, [applied_credits, requirement_level]);
x = model.obj_dict[:x];
is_satisfied = satisfied(BSU_equiv_transcript, bw_dr, JuMP.value.(x));
show_requirements(bw_dr, satisfied=is_satisfied)