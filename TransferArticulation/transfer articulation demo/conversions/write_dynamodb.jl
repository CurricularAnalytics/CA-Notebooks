function write_to_dynamodb(transcript, student_demographic,
                            degreq_total_credits, tablename, fully_satisfied,
                            partially_satisfied, not_satisfied,audit,current_term)
                

  #insert students record assiociated with First Year of enrollment
  id = student_demographic["STUDENTID"][1]
  #TODO:  check the names if include apostrophe/comma then needs to be reformated because 
  #       it breaks the query, for example ('LastName' : 'O'Reilly') 
  firstname = student_demographic["FIRSTNAME"][1]
  lastname = student_demographic["LASTNAME"][1]
  firstyear = student_demographic["FIRST_YEAR"][1]
  firstterm = student_demographic["FIRST_TERM_CODE"][1]
  gender = student_demographic["GENDER"][1]
  student_demographic["PELL"][1] == "Y" ? pell = true : pell = false 
  residency = student_demographic["RESIDENCY"][1]
  student_demographic["FULL_PART_TIME"][1] == "F" ? fulltime = true : fulltime=false 
  college = student_demographic["COLLEGE_NAME"][1]
  department = student_demographic["DEPARTMENT_NAME"][1]
  program = student_demographic["PRIMARY_ACAD_PLAN_DESC"][1]
  student_demographic["DOUBLE_MAJOR"][1] == "Y" ? doublemajor = true : doublemajor = false 
  creditcounted = 0 # credits are counted towards the degree requirement
  creditnotcounted = 0 # credits that are not counted towards the degree requirement
  coursescounted = 0 # number of courses counted towards the degree requirements
  total_number_of_courses = 40 # total number of courses required to fulfill the degree requirements
  totalcredithours = student_demographic["TOTAL_UNITS"][1]
  #TODO: handle students with missing GPA!
  gpa = student_demographic["GPA"][1]
  zip_code = student_demographic["ZIP_CODE"][1]
  degreqtotalcredits = degreq_total_credits
  #TODO: add institute to the input of the function
  institute = "University of Arizona"

  tolerance = 0.10 # tolerance for progress analysis i.e. is student ahead/behind/or on track?
  system_type = "semester"

  #add this student's first year to DB. Uses firstyear as Sort Key (SK)
  statement = """
    INSERT INTO "$tablename"
    value 
    {
        'PK':'ID#$id',
        'SK':'YEAR#$firstyear',
        'StudentId' : $id,
        'FirstName' : '$firstname',
        'LastName' : '$lastname',
        'FirstYear': $firstyear,
        'Gender' : '$gender',
        'PELL' : $pell,
        'Residency' : '$residency',
        'Fulltime' : $fulltime ,
        'AcademicProgram' : 'COLLEGE#$college#DEPARTMENT#$department#PROGRAM#$program',
        'DoubleMajor' : $doublemajor,
        'TotalCreditHours' : $totalcredithours,
        'TotalNumCourses' : $total_number_of_courses,
        'GPA' : $gpa,
        'ZipCode' : '$zip_code',
        'DegReqTotalCredits' : $degreqtotalcredits,
        'Institute' : 'UNIVERSITY#$institute'
    }
    """
  #@info statement
  Dynamodb.execute_statement(statement)

  statement = """
    INSERT INTO "$tablename"
    value 
    {
        'PK':'ID#$id',
        'SK':'COLLEGE#$college',
        'StudentId' : $id,
        'FirstName' : '$firstname',
        'LastName' : '$lastname',
        'FirstYear': $firstyear,
        'Gender' : '$gender',
        'PELL' : $pell,
        'Residency' : '$residency',
        'Fulltime' : $fulltime ,
        'AcademicProgram' : 'COLLEGE#$college#DEPARTMENT#$department#PROGRAM#$program',
        'DoubleMajor' : $doublemajor,
        'TotalCreditHours' : $totalcredithours,
        'TotalNumCourses' : $total_number_of_courses,
        'GPA' : $gpa,
        'ZipCode' : '$zip_code',
        'DegReqTotalCredits' : $degreqtotalcredits,
        'Institute' : 'UNIVERSITY#$institute'
    }
    """
  #@info statement
  Dynamodb.execute_statement(statement)


  statement = """
  INSERT INTO "$tablename"
  value 
  {
      'PK':'ID#$id',
      'SK':'UNIVERSITY#$institute',
      'StudentId' : $id,
      'FirstName' : '$firstname',
      'LastName' : '$lastname',
      'FirstYear': $firstyear,
      'Gender' : '$gender',
      'PELL' : $pell,
      'Residency' : '$residency',
      'Fulltime' : $fulltime ,
      'AcademicProgram' : 'COLLEGE#$college#DEPARTMENT#$department#PROGRAM#$program',
      'DoubleMajor' : $doublemajor,
      'TotalCreditHours' : $totalcredithours,
      'TotalNumCourses' : $total_number_of_courses,
      'GPA' : $gpa,
      'ZipCode' : '$zip_code',
      'DegReqTotalCredits' : $degreqtotalcredits,
      'Institute' : 'UNIVERSITY#$institute'
  }
  """
  #@info statement
  Dynamodb.execute_statement(statement)


  # add each course record for this student


  for course_record in transcript
    course = course_record.course.prefix*course_record.course.num
    grade = CurricularAnalytics.grade(course_record.grade)
    # TODO status and reason are hard coded below as defaults. Need to reason it from student_transcript
    reason = audit[course_record]
    if reason ∈ ["Not applicable (redundant course)", "Grade not sufficient", "Withdrew","Not applicable towards degree"]
      status = "NotCounted"
      creditnotcounted+=course_record.course.credit_hours
    else
      status = "Counted"
      creditcounted+=course_record.course.credit_hours
      coursescounted+=1
    end

    statement = """
      INSERT INTO "$tablename"
      value 
      {
          'PK':'ID#$id',
          'SK':'COURSE#$course',
          'StudentId' : $id,
          'Gender' : '$gender',
          'PELL' : $pell,
          'Residency' : '$residency',
          'Fulltime' : $fulltime ,
          'AcademicProgram' : 'COLLEGE#$college#DEPARTMENT#$department#PROGRAM#$program',
          'Grade' : 'GRADE#$grade',
          'CourseCountedReason' : 'COURSEIS#$status#REASON#$reason',
          'CourseStatusIndex' : 'CourseIs$status',
          'Institute' : 'UNIVERSITY#$institute'
      }
      """
    #@info statement
    Dynamodb.execute_statement(statement)
  end

  #req_progress = round(coursescounted/total_number_of_courses,digits=4)*100
  #progress_status = get_student_progress_status(firstyear,currentyear,req_progress)

  milestone = 4
  progress_4years, progress_status_4years = student_progress_analysis(id, creditcounted, milestone, tolerance, system_type,degreqtotalcredits,current_term,firstterm)
  #@info "progress for program $program with total required credis $degreq_total_credits is $progress_4years %"
  #@info "this student first term is $firstterm, total credits counted towards the deg is $creditcounted then he/she is $progress_status_4years"

  milestone = 5
  progress_5years, progress_status_5years = student_progress_analysis(id, creditcounted, milestone, tolerance, system_type,degreqtotalcredits,current_term,firstterm)

  milestone = 6
  progress_6years, progress_status_6years = student_progress_analysis(id, creditcounted, milestone, tolerance, system_type,degreqtotalcredits,current_term,firstterm)

  updatestatement = """
  UPDATE "$tablename" 
  SET CreditCounted= $creditcounted 
  SET CreditNotCounted= $creditnotcounted
  SET Progress4Years = $progress_4years
  SET ProgressStatus4Years = '$progress_status_4years'
  SET Progress5Years = $progress_5years
  SET ProgressStatus5Years = '$progress_status_5years'
  SET Progress6Years = $progress_6years
  SET ProgressStatus6Years = '$progress_status_6years'
  WHERE PK='ID#$id' AND SK='YEAR#$firstyear'
  """
  #@info updatestatement
  Dynamodb.execute_statement(updatestatement)

  updatestatement = """
  UPDATE "$tablename" 
  SET CreditCounted= $creditcounted 
  SET CreditNotCounted= $creditnotcounted
  SET Progress4Years = $progress_4years
  SET ProgressStatus4Years = '$progress_status_4years'
  SET Progress5Years = $progress_5years
  SET ProgressStatus5Years = '$progress_status_5years'
  SET Progress6Years = $progress_6years
  SET ProgressStatus6Years = '$progress_status_6years'
  WHERE PK='ID#$id' AND SK='COLLEGE#$college'
  """
  #@info updatestatement
  Dynamodb.execute_statement(updatestatement)

  updatestatement = """
  UPDATE "$tablename" 
  SET CreditCounted= $creditcounted 
  SET CreditNotCounted= $creditnotcounted
  SET Progress4Years = $progress_4years
  SET ProgressStatus4Years = '$progress_status_4years'
  SET Progress5Years = $progress_5years
  SET ProgressStatus5Years = '$progress_status_5years'
  SET Progress6Years = $progress_6years
  SET ProgressStatus6Years = '$progress_status_6years'
  WHERE PK='ID#$id' AND SK='UNIVERSITY#$institute'
  """
  #@info updatestatement
  Dynamodb.execute_statement(updatestatement)


  #update student progress for the histogram 





  # for each degree requirement that is fully satisfied, add a record to DB
  for req in fully_satisfied
      status = "Completed"

      statement = """
        INSERT INTO "$tablename"
        value 
        {
            'PK':'ID#$id',
            'SK':'REQ#$req',
            'StudentId' : $id,
            'Gender' : '$gender',
            'PELL' : $pell,
            'Residency' : '$residency',
            'Fulltime' : $fulltime ,
            'AcademicProgram' : 'COLLEGE#$college#DEPARTMENT#$department#PROGRAM#$program',
            'Grade' : 'GRADE#$grade',
            'ReqStatusIndex' : 'ReqIs$status',
            'Institute' : 'UNIVERSITY#$institute'
        }
        """

      #@info statement
      Dynamodb.execute_statement(statement)
  end

  # for each degree requirement that is partially satisfied, add a record to DB
  for req in partially_satisfied
      status = "PartiallyCompleted"

      statement = """
        INSERT INTO "$tablename"
        value 
        {
            'PK':'ID#$id',
            'SK':'REQ#$req',
            'StudentId' : $id,
            'Gender' : '$gender',
            'PELL' : $pell,
            'Residency' : '$residency',
            'Fulltime' : $fulltime ,
            'AcademicProgram' : 'COLLEGE#$college#DEPARTMENT#$department#PROGRAM#$program',
            'Grade' : 'GRADE#$grade',
            'ReqStatusIndex' : 'ReqIs$status',
            'Institute' : 'UNIVERSITY#$institute'
        }
        """

      #@info statement
      Dynamodb.execute_statement(statement)
  end

  # for each degree requirement that is not satisfied, add a record to DB
  for req in not_satisfied
      status = "NotCompleted"

      statement = """
        INSERT INTO "$tablename"
        value 
        {
            'PK':'ID#$id',
            'SK':'REQ#$req',
            'StudentId' : $id,
            'Gender' : '$gender',
            'PELL' : $pell,
            'Residency' : '$residency',
            'Fulltime' : $fulltime ,
            'AcademicProgram' : 'COLLEGE#$college#DEPARTMENT#$department#PROGRAM#$program',
            'Grade' : 'GRADE#$grade',
            'ReqStatusIndex' : 'ReqIs$status',
            'Institute' : 'UNIVERSITY#$institute'
        }
        """
      #@info statement
      Dynamodb.execute_statement(statement)
  end
end



function get_sortkeys_for_studentid(studentid,tablename)
  statement = """SELECT SK FROM "$tablename" WHERE PK = 'ID#$studentid' """
  output = pop!(Dynamodb.execute_statement(statement))

  student_data = Dict{Any,Any}()

  for i in keys(output)
      column_name = i
      data_record =  pop!(get(output,i,0))

      if !haskey(student_data,column_name)
          student_data[column_name] = [data_record]
      else 
          push!(student_data[column_name],data_record)
      end

      student_data[i] = data_record
  end

  sortkeys = Array{Any,1}()

  for i in values(student_data)
    push!(sortkeys,pop!(i))
  end
  
  return sortkeys

end



function get_student_info(studentid,tablename)

  statement = """SELECT * FROM "$tablename" WHERE PK = 'ID#$studentid'"""
  output = pop!(pop!(Dynamodb.execute_statement(statement)))

  student_data = Dict{Any,Any}()

  for i in keys(output)
      column_name = i
      data_record =  pop!(get(output,i,0))
      if !haskey(student_data,column_name)
          student_data[column_name] = [data_record]
      else
          push!(student_data[column_name],data_record)
      end

      student_data[i] = data_record
  end

  return student_data
end

function is_student_in_db(studentid,tablename)

  statement = """SELECT * FROM "$tablename" WHERE PK = 'ID#$studentid'"""
  try
    Dynamodb.execute_statement(statement)
    return true
  catch
    return false
  end
end




function delete_student_record(studentid,tablename)
  sortkeys = get_sortkeys_for_studentid(studentid,tablename)
  for sk in sortkeys
    statement = """
                DELETE FROM "$tablename" 
                WHERE "PK" = 'ID#$studentid' AND "SK" = '$sk'
                """ 
    #@info statement
    Dynamodb.execute_statement(statement)
    #sleep(1)
  end
end



function delete_batch_of_students(studentid_list,tablename)

  counter = 0;

  for id in studentid_list
    delete_student_record(id,tablename)
    #sleep(1)
    counter+=1;
    if(counter%10 == 0)
      @info "$counter students have been deleted"
    end
  end

end


function write_cohort_to_dynamodb(students_transcript_dataframe,students_demographic_dataframe,program_name,program_degree_requirements,total_credit,course_catalog,current_term,tablename)

  processed_students_list=Array{Int64,1}();
  unprocessed_students_list=Array{Int64,1}();
  unprocessed_program_list=Array{String,1}();
  students_demo_for_this_program=filter(row -> row.PRIMARY_ACAD_PLAN_DESC == program_name, students_demographic_dataframe)
  studentid_list=unique(students_demo_for_this_program["STUDENTID"]);

  for studentid in studentid_list
    
    student_demographic = filter(row -> row.STUDENTID == studentid, students_demo_for_this_program)
    student_transcript = filter(row -> row.STUDENTID == studentid, students_transcript_dataframe)
    #isempty(student_transcript) ? has_transcript = false : has_transcript = true # validate transcript data


    if isempty(student_transcript)

      @info "database does not include transcript data for the student id: "*studentid
      issubset(studentid,unprocessed_students_list) ? nothing : push!(unprocessed_students_list,studentid)

    else


      try

        transcript = convert_transcript(studentid, student_transcript, course_catalog);

        try
          model = CurricularOptimization.assign_courses(transcript, program_degree_requirements, applied_credits);
          x = model.obj_dict[:x];
          
          is_satisfied = Dict{Int,Bool}();
          is_satisfied = satisfied(transcript, program_degree_requirements, JuMP.value.(x));
          
          audit = audit_transcript(transcript, program_degree_requirements, JuMP.value.(x));
          
          fully_satisfied, partially_satisfied, not_satisfied = get_satisfied_requirements(
              program_degree_requirements, is_satisfied
          );
      
          try
            write_to_dynamodb(
              coalesce_transcript(transcript),
              student_demographic,
              total_credit,
              tablename,
              unique(fully_satisfied),
              unique(partially_satisfied),
              unique(not_satisfied),
              audit,
              current_term
            )
            issubset(studentid,processed_students_list) ? nothing : push!(processed_students_list,studentid)
            @info "Student#"*string(studentid)*" has been succussfully added to the Cohort Analytics DynamoDB database"
  
          catch
            @info "Failed to write student#"*string(studentid)*" record into Cohort Analytics DynamoDB database"
            issubset(studentid,unprocessed_students_list) ? nothing : push!(unprocessed_students_list,studentid)
  
          end
                    
        catch
          @info "Model Failed: Could not assign courses to the "*program_name*" program (i.e. assign_courses function failed)"
          issubset(studentid,unprocessed_students_list) ? nothing : push!(unprocessed_students_list,studentid)
          issubset(program_name,unprocessed_program_list) ? nothing : push!(unprocessed_program_list,program_name)
        end
        
      catch
        @info "faild to create a transcript for this student Student#"*string(studentid)
        issubset(studentid,unprocessed_students_list) ? nothing : push!(unprocessed_students_list,studentid)


      end





    end



  end

  return processed_students_list, unprocessed_students_list, unprocessed_program_list

end


function write_multiple_cohort_to_dynamodb(students_transcript,students_demographic,current_term,course_catalog,json_folder,tablename)
  
  processed_students_list=Array{Int64,1}();
  unprocessed_students_list=Array{Int64,1}();
  unprocessed_program_list=Array{String,1}();
  
  process_st_lst=Array{Int64,1}();
  unprocess_st_lst=Array{Int64,1}();
  unprocess_prog_lst=Array{String,1}();
  
  
  programs_catalog = unique(DataFrame(  ["COLLEGE_NAME"=> students_demographic["COLLEGE_NAME"] , 
                                "DEPARTMENT_NAME"=> students_demographic["DEPARTMENT_NAME"],
                                "PRIMARY_ACAD_PLAN_DESC"=>students_demographic["PRIMARY_ACAD_PLAN_DESC"], 
                                "PRIMARY_ACAD_PLAN"=>students_demographic["PRIMARY_ACAD_PLAN"]]));
  
  programs_code_list = unique(programs_catalog["PRIMARY_ACAD_PLAN"])
  
  for program in programs_code_list

  
    program_info = filter(prog -> prog.PRIMARY_ACAD_PLAN == program, programs_catalog)

    if (isempty(program_info))
      @info "This program (" * program * ") has no data in the provided dataframe"
    else
      college = program_info["COLLEGE_NAME"][1];
      department = program_info["DEPARTMENT_NAME"][1];
      program_name = program_info["PRIMARY_ACAD_PLAN_DESC"][1];
      program_code = program_info["PRIMARY_ACAD_PLAN"][1];

      try
        program_degree_requirements, prog_total_credit=get_deg_req(college,department,
        program_name,program_code,
        json_folder);

        process_st_lst, unprocess_st_lst, unprocess_prog_lst = write_cohort_to_dynamodb(
        students_transcript,
        students_demographic,
        program_name,
        program_degree_requirements,
        prog_total_credit,
        course_catalog,
        current_term,
        tablename);
      catch
        @info "Could not proceess the program: "*program_name*" degree requirements json file"
      end
    end

    append!(processed_students_list,process_st_lst);
    append!(unprocessed_students_list,unprocess_st_lst);
    append!(unprocessed_program_list,unprocess_prog_lst);
  
  end

  return unique(processed_students_list), unique(unprocessed_students_list), unique(unprocessed_program_list)


end

