!> \file
!> $Id: diffusion_equation_routines.f90 28 2007-07-27 08:35:14Z cpb $
!> \author Chris Bradley
!> \brief This module handles all diffusion equation routines.
!>
!> \section LICENSE
!>
!> Version: MPL 1.1/GPL 2.0/LGPL 2.1
!>
!> The contents of this file are subject to the Mozilla Public License
!> Version 1.1 (the "License"); you may not use this file except in
!> compliance with the License. You may obtain a copy of the License at
!> http://www.mozilla.org/MPL/
!>
!> Software distributed under the License is distributed on an "AS IS"
!> basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
!> License for the specific language governing rights and limitations
!> under the License.
!>
!> The Original Code is openCMISS
!>
!> The Initial Developer of the Original Code is University of Auckland,
!> Auckland, New Zealand and University of Oxford, Oxford, United
!> Kingdom. Portions created by the University of Auckland and University
!> of Oxford are Copyright (C) 2007 by the University of Auckland and
!> the University of Oxford. All Rights Reserved.
!>
!> Contributor(s):
!>
!> Alternatively, the contents of this file may be used under the terms of
!> either the GNU General Public License Version 2 or later (the "GPL"), or
!> the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
!> in which case the provisions of the GPL or the LGPL are applicable instead
!> of those above. If you wish to allow use of your version of this file only
!> under the terms of either the GPL or the LGPL, and not to allow others to
!> use your version of this file under the terms of the MPL, indicate your
!> decision by deleting the provisions above and replace them with the notice
!> and other provisions required by the GPL or the LGPL. If you do not delete
!> the provisions above, a recipient may use your version of this file under
!> the terms of any one of the MPL, the GPL or the LGPL.
!>

!>This module handles all diffusion equation routines.
MODULE DIFFUSION_EQUATION_ROUTINES

  USE BASE_ROUTINES
  USE BASIS_ROUTINES
  USE CONSTANTS
  USE CONTROL_LOOP_ROUTINES
  USE DISTRIBUTED_MATRIX_VECTOR
  USE DOMAIN_MAPPINGS
  USE EQUATIONS_MAPPING_ROUTINES
  USE EQUATIONS_MATRICES_ROUTINES
  USE EQUATIONS_SET_CONSTANTS
  USE FIELD_ROUTINES
  USE INPUT_OUTPUT
  USE ISO_VARYING_STRING
  USE KINDS
  USE MATRIX_VECTOR
  USE PROBLEM_CONSTANTS
  USE STRINGS
  USE SOLUTION_MAPPING_ROUTINES
  USE SOLUTIONS_ROUTINES
  USE SOLVER_ROUTINES
  USE TIMER
  USE TYPES

  IMPLICIT NONE

  PRIVATE

  !Module parameters

  !Module types

  !Module variables

  !Interfaces

  PUBLIC DIFFUSION_EQUATION_EQUATIONS_SET_SETUP,DIFFUSION_EQUATION_EQUATIONS_SET_SUBTYPE_SET, &
    & DIFFUSION_EQUATION_FINITE_ELEMENT_CALCULATE,DIFFUSION_EQUATION_PROBLEM_SUBTYPE_SET, &
    & DIFFUSION_EQUATION_PROBLEM_SETUP
  
CONTAINS

  !
  !================================================================================================================================
  !

  !>Sets up the diffusion equation type of a classical field equations set class.
  SUBROUTINE DIFFUSION_EQUATION_EQUATIONS_SET_SETUP(EQUATIONS_SET,SETUP_TYPE,ACTION_TYPE,ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set to setup a diffusion equation on.
    INTEGER(INTG), INTENT(IN) :: SETUP_TYPE !<The setup type
    INTEGER(INTG), INTENT(IN) :: ACTION_TYPE !<The action type
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("DIFFUSION_EQUATION_EQUATIONS_SET_SETUP",ERR,ERROR,*999)

    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      SELECT CASE(EQUATIONS_SET%SUBTYPE)
      CASE(EQUATIONS_SET_NO_SOURCE_DIFFUSION_SUBTYPE)
        CALL DIFFUSION_EQUATION_EQUATIONS_SET_LINEAR_SETUP(EQUATIONS_SET,SETUP_TYPE,ACTION_TYPE,ERR,ERROR,*999)
      CASE DEFAULT
        LOCAL_ERROR="Equations set subtype "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
          & " is not valid for a diffusion equation type of a classical field equation set class."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("DIFFUSION_EQUATION_EQUATIONS_SET_SETUP")
    RETURN
999 CALL ERRORS("DIFFUSION_EQUATION_EQUATIONS_SET_SETUP",ERR,ERROR)
    CALL EXITS("DIFFUSION_EQUATION_EQUATIONS_SET_SETUP")
    RETURN 1
  END SUBROUTINE DIFFUSION_EQUATION_EQUATIONS_SET_SETUP

  !
  !================================================================================================================================
  !

  !>Sets/changes the equation subtype for a diffusion equation type of a classical field equations set class.
  SUBROUTINE DIFFUSION_EQUATION_EQUATIONS_SET_SUBTYPE_SET(EQUATIONS_SET,EQUATIONS_SET_SUBTYPE,ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set to set the equation subtype for
    INTEGER(INTG), INTENT(IN) :: EQUATIONS_SET_SUBTYPE !<The equation subtype to set
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("DIFFUSION_EQUATION_EQUATIONS_SET_SUBTYPE_SET",ERR,ERROR,*999)
    
    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      SELECT CASE(EQUATIONS_SET_SUBTYPE)
      CASE(EQUATIONS_SET_NO_SOURCE_DIFFUSION_SUBTYPE)
        EQUATIONS_SET%CLASS=EQUATIONS_SET_CLASSICAL_FIELD_CLASS
        EQUATIONS_SET%TYPE=EQUATIONS_SET_DIFFUSION_EQUATION_TYPE
        EQUATIONS_SET%SUBTYPE=EQUATIONS_SET_NO_SOURCE_DIFFUSION_SUBTYPE
        CALL DIFFUSION_EQUATION_EQUATIONS_SET_SETUP(EQUATIONS_SET,EQUATIONS_SET_SETUP_INITIAL_TYPE, &
          & EQUATIONS_SET_SETUP_START_ACTION,ERR,ERROR,*999)
      CASE DEFAULT
        LOCAL_ERROR="Equations set subtype "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SUBTYPE,"*",ERR,ERROR))// &
          & " is not valid for a diffusion equation type of a classical field equations set class."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("DIFFUSION_EQUATION_EQUATIONS_SET_SUBTYPE_SET")
    RETURN
999 CALL ERRORS("DIFFUSION_EQUATION_EQUATIONS_SET_SUBTYPE_SET",ERR,ERROR)
    CALL EXITS("DIFFUSION_EQUATION_EQUATIONS_SET_SUBTYPE_SET")
    RETURN 1
  END SUBROUTINE DIFFUSION_EQUATION_EQUATIONS_SET_SUBTYPE_SET

  !
  !================================================================================================================================
  !

  !>Sets up the linear diffusion equation.
  SUBROUTINE DIFFUSION_EQUATION_EQUATIONS_SET_LINEAR_SETUP(EQUATIONS_SET,SETUP_TYPE,ACTION_TYPE,ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set to setup
    INTEGER(INTG), INTENT(IN) :: SETUP_TYPE !<The setup type to perform
    INTEGER(INTG), INTENT(IN) :: ACTION_TYPE !<The action type to perform
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: component_idx,NEXT_NUMBER,NUMBER_OF_DIMENSIONS,NUMBER_OF_MATERIALS_COMPONENTS
    TYPE(FIELD_TYPE), POINTER :: DEPENDENT_FIELD
    TYPE(EQUATIONS_TYPE), POINTER :: EQUATIONS
    TYPE(EQUATIONS_MAPPING_TYPE), POINTER :: EQUATIONS_MAPPING
    TYPE(EQUATIONS_SET_MATERIALS_TYPE), POINTER :: EQUATIONS_MATERIALS
    TYPE(EQUATIONS_MATRICES_TYPE), POINTER :: EQUATIONS_MATRICES
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("DIFFUSION_EQUATION_EQUATION_SET_LINEAR_SETUP",ERR,ERROR,*999)

    NULLIFY(EQUATIONS_MAPPING)
    NULLIFY(EQUATIONS_MATRICES)
    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_NO_SOURCE_DIFFUSION_SUBTYPE) THEN
        SELECT CASE(SETUP_TYPE)
        CASE(EQUATIONS_SET_SETUP_INITIAL_TYPE)
          SELECT CASE(ACTION_TYPE)
          CASE(EQUATIONS_SET_SETUP_START_ACTION)
            EQUATIONS_SET%LINEARITY=EQUATIONS_SET_LINEAR
            EQUATIONS_SET%TIME_DEPENDENCE=EQUATIONS_SET_DYNAMIC
            EQUATIONS_SET%SOLUTION_METHOD=EQUATIONS_SET_FEM_SOLUTION_METHOD
          CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
!!TODO: Check valid setup
          CASE DEFAULT
            LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(ACTION_TYPE,"*",ERR,ERROR))// &
              & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(SETUP_TYPE,"*",ERR,ERROR))// &
              & " is invalid for a linear diffusion equation."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        CASE(EQUATIONS_SET_SETUP_GEOMETRY_TYPE)
          !Do nothing???
        CASE(EQUATIONS_SET_SETUP_DEPENDENT_TYPE)
          SELECT CASE(ACTION_TYPE)
          CASE(EQUATIONS_SET_SETUP_START_ACTION)
!!TODO: maybe given negative user numbers to openCMISS generated fields???
            CALL FIELD_NEXT_NUMBER_FIND(EQUATIONS_SET%REGION,NEXT_NUMBER,ERR,ERROR,*999)
            CALL FIELD_CREATE_START(NEXT_NUMBER,EQUATIONS_SET%REGION,EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,ERR,ERROR,*999)
            CALL FIELD_TYPE_SET(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_GENERAL_TYPE,ERR,ERROR,*999)
            CALL FIELD_DEPENDENT_TYPE_SET(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_DEPENDENT_TYPE,ERR,ERROR,*999)
            CALL FIELD_MESH_DECOMPOSITION_SET(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD% &
              & DECOMPOSITION,ERR,ERROR,*999)
            CALL FIELD_GEOMETRIC_FIELD_SET(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD, &
              & ERR,ERROR,*999)
            CALL FIELD_NUMBER_OF_VARIABLES_SET(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,2,ERR,ERROR,*999)
            CALL FIELD_NUMBER_OF_COMPONENTS_SET(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,1,ERR,ERROR,*999)
            !Default to the geometric interpolation setup
            CALL FIELD_COMPONENT_MESH_COMPONENT_SET(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_STANDARD_VARIABLE_TYPE,1, &
              & EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD%VARIABLES(FIELD_STANDARD_VARIABLE_TYPE)%COMPONENTS(1)% &
              & MESH_COMPONENT_NUMBER,ERR,ERROR,*999)
            CALL FIELD_COMPONENT_MESH_COMPONENT_SET(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_NORMAL_VARIABLE_TYPE,1, &
              & EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD%VARIABLES(FIELD_STANDARD_VARIABLE_TYPE)%COMPONENTS(1)% &
              & MESH_COMPONENT_NUMBER,ERR,ERROR,*999)
            SELECT CASE(EQUATIONS_SET%SOLUTION_METHOD)
            CASE(EQUATIONS_SET_FEM_SOLUTION_METHOD)
              CALL FIELD_COMPONENT_INTERPOLATION_SET(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_STANDARD_VARIABLE_TYPE,1, &
                & FIELD_NODE_BASED_INTERPOLATION,ERR,ERROR,*999)
              CALL FIELD_COMPONENT_INTERPOLATION_SET(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_NORMAL_VARIABLE_TYPE,1, &
                & FIELD_NODE_BASED_INTERPOLATION,ERR,ERROR,*999)
              CALL FIELD_SCALING_TYPE_SET(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD% &
                & SCALINGS%SCALING_TYPE,ERR,ERROR,*999)
            CASE(EQUATIONS_SET_BEM_SOLUTION_METHOD)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE(EQUATIONS_SET_FD_SOLUTION_METHOD)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE(EQUATIONS_SET_FV_SOLUTION_METHOD)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE(EQUATIONS_SET_GFEM_SOLUTION_METHOD)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE(EQUATIONS_SET_GFV_SOLUTION_METHOD)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE DEFAULT
              LOCAL_ERROR="The solution method of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SOLUTION_METHOD,"*",ERR,ERROR))// &
                & " is invalid."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            END SELECT
          CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
            CALL FIELD_CREATE_FINISH(EQUATIONS_SET%REGION,EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,ERR,ERROR,*999)
          CASE DEFAULT
            LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(ACTION_TYPE,"*",ERR,ERROR))// &
              & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(SETUP_TYPE,"*",ERR,ERROR))// &
              & " is invalid for a linear diffusion equation"
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        CASE(EQUATIONS_SET_SETUP_MATERIALS_TYPE)
          SELECT CASE(ACTION_TYPE)
          CASE(EQUATIONS_SET_SETUP_START_ACTION)
            EQUATIONS_MATERIALS=>EQUATIONS_SET%MATERIALS
            IF(ASSOCIATED(EQUATIONS_MATERIALS)) THEN
              CALL FIELD_NEXT_NUMBER_FIND(EQUATIONS_SET%REGION,NEXT_NUMBER,ERR,ERROR,*999)
              CALL FIELD_CREATE_START(NEXT_NUMBER,EQUATIONS_SET%REGION,EQUATIONS_MATERIALS%MATERIALS_FIELD,ERR,ERROR,*999)
              CALL FIELD_TYPE_SET(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_MATERIAL_TYPE,ERR,ERROR,*999)
              CALL FIELD_DEPENDENT_TYPE_SET(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_INDEPENDENT_TYPE,ERR,ERROR,*999)
              CALL FIELD_MESH_DECOMPOSITION_SET(EQUATIONS_MATERIALS%MATERIALS_FIELD,EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD% &
                & DECOMPOSITION,ERR,ERROR,*999)
              CALL FIELD_GEOMETRIC_FIELD_SET(EQUATIONS_MATERIALS%MATERIALS_FIELD,EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD, &
                & ERR,ERROR,*999)
              CALL FIELD_NUMBER_OF_VARIABLES_SET(EQUATIONS_MATERIALS%MATERIALS_FIELD,1,ERR,ERROR,*999)
              NUMBER_OF_DIMENSIONS=EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD%DIMENSION
              NUMBER_OF_MATERIALS_COMPONENTS=NUMBER_OF_DIMENSIONS              
              !Set the number of materials components
              CALL FIELD_NUMBER_OF_COMPONENTS_SET(EQUATIONS_MATERIALS%MATERIALS_FIELD,NUMBER_OF_MATERIALS_COMPONENTS,ERR,ERROR,*999)
              !Default the k materials components to the geometric interpolation setup with constant interpolation
              DO component_idx=1,NUMBER_OF_DIMENSIONS
                CALL FIELD_COMPONENT_MESH_COMPONENT_SET(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_STANDARD_VARIABLE_TYPE, &
                  & component_idx,EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD%VARIABLES(FIELD_STANDARD_VARIABLE_TYPE)% &
                  & COMPONENTS(component_idx)%MESH_COMPONENT_NUMBER,ERR,ERROR,*999)
                CALL FIELD_COMPONENT_INTERPOLATION_SET(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_STANDARD_VARIABLE_TYPE, &
                  & component_idx,FIELD_CONSTANT_INTERPOLATION,ERR,ERROR,*999)
              ENDDO !component_idx             
              !Default the field scaling to that of the geometric field
              CALL FIELD_SCALING_TYPE_SET(EQUATIONS_MATERIALS%MATERIALS_FIELD,EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD% &
                & SCALINGS%SCALING_TYPE,ERR,ERROR,*999)
            ELSE
              CALL FLAG_ERROR("Equations set materials is not associated.",ERR,ERROR,*999)
            ENDIF
          CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
            EQUATIONS_MATERIALS=>EQUATIONS_SET%MATERIALS
            IF(ASSOCIATED(EQUATIONS_MATERIALS)) THEN
              !Finish creating the materials field
              CALL FIELD_CREATE_FINISH(EQUATIONS_SET%REGION,EQUATIONS_MATERIALS%MATERIALS_FIELD,ERR,ERROR,*999)
              !Set the default values for the materials field
              NUMBER_OF_DIMENSIONS=EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD%DIMENSION             
              NUMBER_OF_MATERIALS_COMPONENTS=NUMBER_OF_DIMENSIONS             
              !First set the k values to 1.0
              DO component_idx=1,NUMBER_OF_DIMENSIONS
                CALL FIELD_COMPONENT_VALUES_INITIALISE(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_STANDARD_VARIABLE_TYPE, &
                  & component_idx,FIELD_VALUES_SET_TYPE,1.0_DP,ERR,ERROR,*999)
              ENDDO !component_idx
            ELSE
              CALL FLAG_ERROR("Equations set materials is not associated.",ERR,ERROR,*999)
            ENDIF
          CASE DEFAULT
            LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(ACTION_TYPE,"*",ERR,ERROR))// &
              & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(SETUP_TYPE,"*",ERR,ERROR))// &
              & " is invalid for a linear diffusion equation."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        CASE(EQUATIONS_SET_SETUP_SOURCE_TYPE)
          SELECT CASE(ACTION_TYPE)
          CASE(EQUATIONS_SET_SETUP_START_ACTION)
            !Do nothing???
          CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
            !Do nothing
            !? Maybe set finished flag????
          CASE DEFAULT
            LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(ACTION_TYPE,"*",ERR,ERROR))// &
              & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(SETUP_TYPE,"*",ERR,ERROR))// &
              & " is invalid for a linear diffusion equation."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        CASE(EQUATIONS_SET_SETUP_ANALYTIC_TYPE)
          SELECT CASE(ACTION_TYPE)
          CASE(EQUATIONS_SET_SETUP_START_ACTION)
            IF(EQUATIONS_SET%DEPENDENT%DEPENDENT_FINISHED) THEN
              !Do nothing
            ELSE
              CALL FLAG_ERROR("Equations set dependent field has not been finished.",ERR,ERROR,*999)
            ENDIF
          CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
            !Do nothing
            !? Maybe set finished flag????
          CASE DEFAULT
            LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(ACTION_TYPE,"*",ERR,ERROR))// &
              & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(SETUP_TYPE,"*",ERR,ERROR))// &
              & " is invalid for a linear diffusion equation."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        CASE(EQUATIONS_SET_SETUP_FIXED_CONDITIONS_TYPE)
          SELECT CASE(ACTION_TYPE)
          CASE(EQUATIONS_SET_SETUP_START_ACTION)
            IF(EQUATIONS_SET%DEPENDENT%DEPENDENT_FINISHED) THEN
              DEPENDENT_FIELD=>EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD
              IF(ASSOCIATED(DEPENDENT_FIELD)) THEN
                EQUATIONS_MATERIALS=>EQUATIONS_SET%MATERIALS
                IF(ASSOCIATED(EQUATIONS_MATERIALS)) THEN
                  IF(EQUATIONS_MATERIALS%MATERIALS_FINISHED) THEN
                    CALL FIELD_PARAMETER_SET_CREATE(DEPENDENT_FIELD,FIELD_BOUNDARY_CONDITIONS_SET_TYPE,ERR,ERROR,*999)
                  ELSE
                    CALL FLAG_ERROR("Equations set dependent field is not associated.",ERR,ERROR,*999)
                  ENDIF
                ELSE
                  CALL FLAG_ERROR("Equations materials has not been finished.",ERR,ERROR,*999)
                ENDIF
              ELSE
                CALL FLAG_ERROR("Equations set materials is not associated.",ERR,ERROR,*999)
              ENDIF
            ELSE
              CALL FLAG_ERROR("Equations set dependent field has not been finished.",ERR,ERROR,*999)
            ENDIF
          CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
            DEPENDENT_FIELD=>EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD
            IF(ASSOCIATED(DEPENDENT_FIELD)) THEN
              CALL FIELD_PARAMETER_SET_UPDATE_START(DEPENDENT_FIELD,FIELD_BOUNDARY_CONDITIONS_SET_TYPE,ERR,ERROR,*999)
              CALL FIELD_PARAMETER_SET_UPDATE_FINISH(DEPENDENT_FIELD,FIELD_BOUNDARY_CONDITIONS_SET_TYPE,ERR,ERROR,*999)
            ELSE
              CALL FLAG_ERROR("Equations set dependent field is not associated.",ERR,ERROR,*999)
            ENDIF
          CASE DEFAULT
            LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(ACTION_TYPE,"*",ERR,ERROR))// &
              & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(SETUP_TYPE,"*",ERR,ERROR))// &
              & " is invalid for a linear diffusion equation."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        CASE(EQUATIONS_SET_SETUP_EQUATIONS_TYPE)
          SELECT CASE(ACTION_TYPE)
          CASE(EQUATIONS_SET_SETUP_START_ACTION)
            IF(ASSOCIATED(EQUATIONS_SET%FIXED_CONDITIONS)) THEN
              IF(EQUATIONS_SET%FIXED_CONDITIONS%FIXED_CONDITIONS_FINISHED) THEN
                !Do nothing
                !?Initialise problem solution???
              ELSE
                CALL FLAG_ERROR("Equations set fixed conditions has not been finished.",ERR,ERROR,*999)
              ENDIF
            ELSE
              CALL FLAG_ERROR("Equations set fixed conditions is not associated.",ERR,ERROR,*999)
            ENDIF
          CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
            SELECT CASE(EQUATIONS_SET%SOLUTION_METHOD)
            CASE(EQUATIONS_SET_FEM_SOLUTION_METHOD)
              EQUATIONS=>EQUATIONS_SET%EQUATIONS
              IF(ASSOCIATED(EQUATIONS)) THEN
                !Create the equations mapping.
                CALL EQUATIONS_MAPPING_CREATE_START(EQUATIONS,EQUATIONS_MAPPING,ERR,ERROR,*999)
                CALL EQUATIONS_MAPPING_LINEAR_MATRICES_NUMBER_SET(EQUATIONS_MAPPING,2,ERR,ERROR,*999)
                CALL EQUATIONS_MAPPING_LINEAR_MATRICES_VARIABLE_TYPES_SET(EQUATIONS_MAPPING, &
                  & (/FIELD_STANDARD_VARIABLE_TYPE,FIELD_STANDARD_VARIABLE_TYPE/),ERR,ERROR,*999)
                CALL EQUATIONS_MAPPING_RHS_VARIABLE_TYPE_SET(EQUATIONS_MAPPING,FIELD_NORMAL_VARIABLE_TYPE,ERR,ERROR,*999)
                CALL EQUATIONS_MAPPING_CREATE_FINISH(EQUATIONS_MAPPING,ERR,ERROR,*999)
                !Create the equations matrices
                CALL EQUATIONS_MATRICES_CREATE_START(EQUATIONS,EQUATIONS_MATRICES,ERR,ERROR,*999)
                IF(EQUATIONS%SPARSITY_TYPE==EQUATIONS_MATRICES_FULL_MATRICES) THEN
                  CALL EQUATIONS_MATRICES_LINEAR_STORAGE_TYPE_SET(EQUATIONS_MATRICES, &
                    & (/MATRIX_BLOCK_STORAGE_TYPE,MATRIX_BLOCK_STORAGE_TYPE/),ERR,ERROR,*999)
                ELSE IF(EQUATIONS%SPARSITY_TYPE==EQUATIONS_MATRICES_SPARSE_MATRICES) THEN
                  CALL EQUATIONS_MATRICES_LINEAR_STORAGE_TYPE_SET(EQUATIONS_MATRICES, &
                    & (/MATRIX_COMPRESSED_ROW_STORAGE_TYPE,MATRIX_COMPRESSED_ROW_STORAGE_TYPE/),ERR,ERROR,*999)
                  CALL EQUATIONS_MATRICES_LINEAR_STRUCTURE_TYPE_SET(EQUATIONS_MATRICES, &
                    & (/EQUATIONS_MATRIX_FEM_STRUCTURE,EQUATIONS_MATRIX_FEM_STRUCTURE/),ERR,ERROR,*999)
                ELSE
                  LOCAL_ERROR="The equations matrices sparsity type of "// &
                    & TRIM(NUMBER_TO_VSTRING(EQUATIONS%SPARSITY_TYPE,"*",ERR,ERROR))//" is invalid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                ENDIF
                CALL EQUATIONS_MATRICES_CREATE_FINISH(EQUATIONS_MATRICES,ERR,ERROR,*999)
              ELSE
                CALL FLAG_ERROR("Equations is not associated.",ERR,ERROR,*999)
              ENDIF
            CASE(EQUATIONS_SET_BEM_SOLUTION_METHOD)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE(EQUATIONS_SET_FD_SOLUTION_METHOD)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE(EQUATIONS_SET_FV_SOLUTION_METHOD)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE(EQUATIONS_SET_GFEM_SOLUTION_METHOD)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE(EQUATIONS_SET_GFV_SOLUTION_METHOD)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE DEFAULT
                LOCAL_ERROR="The solution method of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SOLUTION_METHOD,"*",ERR,ERROR))// &
                & " is invalid."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            END SELECT
          CASE DEFAULT
            LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(ACTION_TYPE,"*",ERR,ERROR))// &
              & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(SETUP_TYPE,"*",ERR,ERROR))// &
              & " is invalid for a linear diffusion equation."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        CASE DEFAULT
          LOCAL_ERROR="The setup type of "//TRIM(NUMBER_TO_VSTRING(SETUP_TYPE,"*",ERR,ERROR))// &
            & " is invalid for a linear diffusion equation."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        END SELECT
      ELSE
        LOCAL_ERROR="The equations set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
          & " is not a linear diffusion equation subtype."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("DIFFUSION_EQUATION_EQUATIONS_SET_LINEAR_SETUP")
    RETURN
999 CALL ERRORS("DIFFUSION_EQUATION_EQUATIONS_SET_LINEAR_SETUP",ERR,ERROR)
    CALL EXITS("DIFFUSION_EQUATION_EQUATIONS_SET_LINEAR_SETUP")
    RETURN 1
  END SUBROUTINE DIFFUSION_EQUATION_EQUATIONS_SET_LINEAR_SETUP

  !
  !================================================================================================================================
  !
 
  !>Sets up the diffusion solution.
  SUBROUTINE DIFFUSION_EQUATION_PROBLEM_SETUP(PROBLEM,SETUP_TYPE,ACTION_TYPE,ERR,ERROR,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the solutions set to setup a diffusion equation on.
    INTEGER(INTG), INTENT(IN) :: SETUP_TYPE !<The setup type
    INTEGER(INTG), INTENT(IN) :: ACTION_TYPE !<The action type
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("DIFFUSION_EQUATION_PROBLEM_SETUP",ERR,ERROR,*999)

    IF(ASSOCIATED(PROBLEM)) THEN
      SELECT CASE(PROBLEM%SUBTYPE)
      CASE(PROBLEM_NO_SOURCE_DIFFUSION_SUBTYPE)
        CALL DIFFUSION_EQUATION_PROBLEM_LINEAR_SETUP(PROBLEM,SETUP_TYPE,ACTION_TYPE,ERR,ERROR,*999)
      CASE DEFAULT
        LOCAL_ERROR="Problem subtype "//TRIM(NUMBER_TO_VSTRING(PROBLEM%SUBTYPE,"*",ERR,ERROR))// &
          & " is not valid for a diffusion equation type of a classical field problem class."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("DIFFUSION_EQUATION_PROBLEM_SETUP")
    RETURN
999 CALL ERRORS("DIFFUSION_EQUATION_PROBLEM_SETUP",ERR,ERROR)
    CALL EXITS("DIFFUSION_EQUATION_PROBLEM_SETUP")
    RETURN 1
  END SUBROUTINE DIFFUSION_EQUATION_PROBLEM_SETUP
  
  !
  !================================================================================================================================
  !

  !>Calculates the element stiffness matrices and RHS for a diffusion equation finite element equations set.
  SUBROUTINE DIFFUSION_EQUATION_FINITE_ELEMENT_CALCULATE(EQUATIONS_SET,ELEMENT_NUMBER,ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set to perform the finite element calculations on
    INTEGER(INTG), INTENT(IN) :: ELEMENT_NUMBER !<The element number to calculate
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) mh,mhs,ms,ng,nh,nhs,ni,nj,ns
    REAL(DP) :: K_PARAM,RWG,SUM,PGMJ(3),PGNJ(3)
    TYPE(BASIS_TYPE), POINTER :: DEPENDENT_BASIS,GEOMETRIC_BASIS
    TYPE(EQUATIONS_TYPE), POINTER :: EQUATIONS
    TYPE(EQUATIONS_MAPPING_TYPE), POINTER :: EQUATIONS_MAPPING
    TYPE(EQUATIONS_MAPPING_LINEAR_TYPE), POINTER :: LINEAR_MAPPING
    TYPE(EQUATIONS_MATRICES_TYPE), POINTER :: EQUATIONS_MATRICES
    TYPE(EQUATIONS_MATRICES_LINEAR_TYPE), POINTER :: LINEAR_MATRICES
    TYPE(EQUATIONS_MATRICES_RHS_TYPE), POINTER :: RHS_VECTOR
    TYPE(EQUATIONS_MATRIX_TYPE), POINTER :: DAMPING_MATRIX,STIFFNESS_MATRIX
    TYPE(FIELD_TYPE), POINTER :: DEPENDENT_FIELD,GEOMETRIC_FIELD,MATERIALS_FIELD
    TYPE(FIELD_VARIABLE_TYPE), POINTER :: FIELD_VARIABLE,GEOMETRIC_VARIABLE
    TYPE(QUADRATURE_SCHEME_TYPE), POINTER :: QUADRATURE_SCHEME
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("DIFFUSION_EQUATION_FINITE_ELEMENT_CALCULATE",ERR,ERROR,*999)

    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      EQUATIONS=>EQUATIONS_SET%EQUATIONS
      IF(ASSOCIATED(EQUATIONS)) THEN
        SELECT CASE(EQUATIONS_SET%SUBTYPE)
        CASE(EQUATIONS_SET_NO_SOURCE_DIFFUSION_SUBTYPE)
          !Store all these in equations matrices/somewhere else?????
          DEPENDENT_FIELD=>EQUATIONS%INTERPOLATION%DEPENDENT_FIELD
          GEOMETRIC_FIELD=>EQUATIONS%INTERPOLATION%GEOMETRIC_FIELD
          MATERIALS_FIELD=>EQUATIONS%INTERPOLATION%MATERIALS_FIELD
          EQUATIONS_MATRICES=>EQUATIONS%EQUATIONS_MATRICES
          LINEAR_MATRICES=>EQUATIONS_MATRICES%LINEAR_MATRICES
          STIFFNESS_MATRIX=>LINEAR_MATRICES%MATRICES(1)%PTR
          DAMPING_MATRIX=>LINEAR_MATRICES%MATRICES(2)%PTR
          RHS_VECTOR=>EQUATIONS_MATRICES%RHS_VECTOR
          EQUATIONS_MAPPING=>EQUATIONS%EQUATIONS_MAPPING
          LINEAR_MAPPING=>EQUATIONS_MAPPING%LINEAR_MAPPING
          FIELD_VARIABLE=>LINEAR_MAPPING%EQUATIONS_MATRIX_TO_VAR_MAPS(1)%VARIABLE
          GEOMETRIC_VARIABLE=>GEOMETRIC_FIELD%VARIABLE_TYPE_MAP(FIELD_STANDARD_VARIABLE_TYPE)%PTR
          DEPENDENT_BASIS=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(DEPENDENT_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
            & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
          GEOMETRIC_BASIS=>GEOMETRIC_FIELD%DECOMPOSITION%DOMAIN(GEOMETRIC_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
            & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
          QUADRATURE_SCHEME=>DEPENDENT_BASIS%QUADRATURE%QUADRATURE_SCHEME_MAP(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
          CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_VALUES_SET_TYPE,ELEMENT_NUMBER,EQUATIONS%INTERPOLATION% &
            & GEOMETRIC_INTERP_PARAMETERS,ERR,ERROR,*999)
          CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_VALUES_SET_TYPE,ELEMENT_NUMBER,EQUATIONS%INTERPOLATION% &
            & MATERIALS_INTERP_PARAMETERS,ERR,ERROR,*999)
          !Loop over gauss points
          DO ng=1,QUADRATURE_SCHEME%NUMBER_OF_GAUSS
            CALL FIELD_INTERPOLATE_GAUSS(FIRST_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng,EQUATIONS%INTERPOLATION% &
              & GEOMETRIC_INTERP_POINT,ERR,ERROR,*999)
            CALL FIELD_INTERPOLATED_POINT_METRICS_CALCULATE(GEOMETRIC_BASIS%NUMBER_OF_XI,EQUATIONS%INTERPOLATION% &
              & GEOMETRIC_INTERP_POINT_METRICS,ERR,ERROR,*999)
            CALL FIELD_INTERPOLATE_GAUSS(NO_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng,EQUATIONS%INTERPOLATION% &
              & MATERIALS_INTERP_POINT,ERR,ERROR,*999)
            !Calculate RWG.
!!TODO: Think about symmetric problems. 
            RWG=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS%JACOBIAN*QUADRATURE_SCHEME%GAUSS_WEIGHTS(ng)
            !Loop over field components
            mhs=0          
            DO mh=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
              !Loop over element rows
              DO ms=1,DEPENDENT_BASIS%NUMBER_OF_ELEMENT_PARAMETERS
                mhs=mhs+1
                nhs=0
                IF(STIFFNESS_MATRIX%UPDATE_MATRIX.OR.DAMPING_MATRIX%UPDATE_MATRIX) THEN
                  !Loop over element columns
                  DO nh=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                    DO ns=1,DEPENDENT_BASIS%NUMBER_OF_ELEMENT_PARAMETERS
                      nhs=nhs+1
                      IF(STIFFNESS_MATRIX%UPDATE_MATRIX) THEN
                        SUM=0.0_DP
                        DO nj=1,GEOMETRIC_VARIABLE%NUMBER_OF_COMPONENTS
                          PGMJ(nj)=0.0_DP
                          PGNJ(nj)=0.0_DP
                          DO ni=1,DEPENDENT_BASIS%NUMBER_OF_XI                          
                            PGMJ(nj)=PGMJ(nj)+ &
                              & QUADRATURE_SCHEME%GAUSS_BASIS_FNS(ms,PARTIAL_DERIVATIVE_FIRST_DERIVATIVE_MAP(ni),ng)* &
                              & EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS%DXI_DX(ni,nj)
                            PGNJ(nj)=PGNJ(nj)+ &
                              & QUADRATURE_SCHEME%GAUSS_BASIS_FNS(ns,PARTIAL_DERIVATIVE_FIRST_DERIVATIVE_MAP(ni),ng)* &
                              & EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS%DXI_DX(ni,nj)
                          ENDDO !ni
                          K_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT%VALUES(nj,NO_PART_DERIV)
                          SUM=SUM+K_PARAM*PGMJ(nj)*PGNJ(nj)
                        ENDDO !nj
                        STIFFNESS_MATRIX%ELEMENT_MATRIX%MATRIX(mhs,nhs)=STIFFNESS_MATRIX%ELEMENT_MATRIX%MATRIX(mhs,nhs)+SUM*RWG
                      ENDIF
                      IF(DAMPING_MATRIX%UPDATE_MATRIX) THEN
                        DAMPING_MATRIX%ELEMENT_MATRIX%MATRIX(mhs,nhs)=DAMPING_MATRIX%ELEMENT_MATRIX%MATRIX(mhs,nhs)+ &
                          & QUADRATURE_SCHEME%GAUSS_BASIS_FNS(ms,NO_PART_DERIV,ng)* &
                          & QUADRATURE_SCHEME%GAUSS_BASIS_FNS(ns,NO_PART_DERIV,ng)*RWG
                      ENDIF
                    ENDDO !ns
                  ENDDO !nh
                ENDIF
                IF(RHS_VECTOR%UPDATE_VECTOR) RHS_VECTOR%ELEMENT_VECTOR%VECTOR(mhs)=0.0_DP
              ENDDO !ms
            ENDDO !mh
          ENDDO !ng
          
        CASE DEFAULT
          LOCAL_ERROR="Equations set subtype "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
            & " is not valid for a diffusion equation type of a classical field equations set class."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        END SELECT
      ELSE
        CALL FLAG_ERROR("Equations set equations is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("DIFFUSION_EQUATION_FINITE_ELEMENT_CALCULATE")
    RETURN
999 CALL ERRORS("DIFFUSION_EQUATION_FINITE_ELEMENT_CALCULATE",ERR,ERROR)
    CALL EXITS("DIFFUSION_EQUATION_FINITE_ELEMENT_CALCULATE")
    RETURN 1
  END SUBROUTINE DIFFUSION_EQUATION_FINITE_ELEMENT_CALCULATE

  !
  !================================================================================================================================
  !

  !>Sets/changes the problem subtype for a diffusion equation type.
  SUBROUTINE DIFFUSION_EQUATION_PROBLEM_SUBTYPE_SET(PROBLEM,PROBLEM_SUBTYPE,ERR,ERROR,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem to set the problem subtype for
    INTEGER(INTG), INTENT(IN) :: PROBLEM_SUBTYPE !<The problem subtype to set
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("DIFFUSION_EQUATION_PROBLEM_SUBTYPE_SET",ERR,ERROR,*999)
    
    IF(ASSOCIATED(PROBLEM)) THEN
      SELECT CASE(PROBLEM_SUBTYPE)
      CASE(PROBLEM_NO_SOURCE_DIFFUSION_SUBTYPE)        
        PROBLEM%CLASS=PROBLEM_CLASSICAL_FIELD_CLASS
        PROBLEM%TYPE=PROBLEM_DIFFUSION_EQUATION_TYPE
        PROBLEM%SUBTYPE=PROBLEM_NO_SOURCE_DIFFUSION_SUBTYPE     
        CALL DIFFUSION_EQUATION_PROBLEM_SETUP(PROBLEM,PROBLEM_SETUP_INITIAL_TYPE,PROBLEM_SETUP_START_ACTION, &
          & ERR,ERROR,*999)
      CASE DEFAULT
        LOCAL_ERROR="Problem subtype "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SUBTYPE,"*",ERR,ERROR))// &
          & " is not valid for a diffusion equation type of a classical field problem class."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("DIFFUSION_EQUATION_PROBLEM_SUBTYPE_SET")
    RETURN
999 CALL ERRORS("DIFFUSION_EQUATION_PROBLEM_SUBTYPE_SET",ERR,ERROR)
    CALL EXITS("DIFFUSION_EQUATION_PROBLEM_SUBTYPE_SET")
    RETURN 1
  END SUBROUTINE DIFFUSION_EQUATION_PROBLEM_SUBTYPE_SET

  !
  !================================================================================================================================
  !

  !>Sets up the diffusion equations solution.
  SUBROUTINE DIFFUSION_EQUATION_PROBLEM_LINEAR_SETUP(PROBLEM,SETUP_TYPE,ACTION_TYPE,ERR,ERROR,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem to setup
    INTEGER(INTG), INTENT(IN) :: SETUP_TYPE !<The setup type to perform
    INTEGER(INTG), INTENT(IN) :: ACTION_TYPE !<The action type to perform
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP,CONTROL_LOOP_ROOT
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET
    TYPE(PROBLEM_EQUATIONS_ADD_TYPE), POINTER :: EQUATIONS_TO_ADD
    TYPE(SOLUTION_TYPE), POINTER :: SOLUTION
    TYPE(SOLUTION_MAPPING_TYPE), POINTER :: SOLUTION_MAPPING
    TYPE(SOLUTIONS_TYPE), POINTER :: SOLUTIONS
    TYPE(SOLVER_TYPE), POINTER :: SOLVER
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("DIFFUSION_EQUATION_PROBLEM_LINEAR_SETUP",ERR,ERROR,*999)

    NULLIFY(CONTROL_LOOP)
    NULLIFY(SOLUTION)
    NULLIFY(SOLUTIONS)
    NULLIFY(SOLUTION_MAPPING)
    NULLIFY(SOLVER)
    IF(ASSOCIATED(PROBLEM)) THEN
      IF(PROBLEM%SUBTYPE==PROBLEM_NO_SOURCE_DIFFUSION_SUBTYPE) THEN
        SELECT CASE(SETUP_TYPE)
        CASE(PROBLEM_SETUP_INITIAL_TYPE)
          SELECT CASE(ACTION_TYPE)
          CASE(PROBLEM_SETUP_START_ACTION)
            !Do nothing????
          CASE(PROBLEM_SETUP_FINISH_ACTION)
            !Do nothing????
          CASE(PROBLEM_SETUP_DO_ACTION)
            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
          CASE DEFAULT
            LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(ACTION_TYPE,"*",ERR,ERROR))// &
              & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(SETUP_TYPE,"*",ERR,ERROR))// &
              & " is invalid for a linear diffusion equation."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        CASE(PROBLEM_SETUP_CONTROL_TYPE)
          SELECT CASE(ACTION_TYPE)
          CASE(PROBLEM_SETUP_START_ACTION)
            !Set up a time control loop
            CALL CONTROL_LOOP_CREATE_START(PROBLEM,CONTROL_LOOP,ERR,ERROR,*999)
            CALL CONTROL_LOOP_TYPE_SET(CONTROL_LOOP,PROBLEM_CONTROL_TIME_LOOP_TYPE,ERR,ERROR,*999)
          CASE(PROBLEM_SETUP_FINISH_ACTION)
            !Finish the control loops
            CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
            CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
            CALL CONTROL_LOOP_CREATE_FINISH(CONTROL_LOOP,ERR,ERROR,*999)            
          CASE(PROBLEM_SETUP_DO_ACTION)
            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
          CASE DEFAULT
            LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(ACTION_TYPE,"*",ERR,ERROR))// &
              & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(SETUP_TYPE,"*",ERR,ERROR))// &
              & " is invalid for a linear diffusion equation."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        CASE(PROBLEM_SETUP_SOLUTION_TYPE)
          SELECT CASE(ACTION_TYPE)
          CASE(PROBLEM_SETUP_START_ACTION)
            !Get the control loop
            CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
            CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
            !Create the solutions on the control loop
            CALL SOLUTIONS_CREATE_START(CONTROL_LOOP,SOLUTIONS,ERR,ERROR,*999)
            CALL SOLUTIONS_NUMBER_SET(SOLUTIONS,1,ERR,ERROR,*999)
            CALL SOLUTIONS_TIME_DEPENDENCE_SET(SOLUTIONS,1,PROBLEM_SOLUTION_FIRST_ORDER_DYNAMIC,ERR,ERROR,*999)
            CALL SOLUTIONS_CREATE_FINISH(SOLUTIONS,ERR,ERROR,*999)
            !Create the solutions mapping 
            CALL SOLUTIONS_SOLUTION_GET(SOLUTIONS,1,SOLUTION,ERR,ERROR,*999)
            CALL SOLUTION_MAPPING_CREATE_START(SOLUTION,SOLUTION_MAPPING,ERR,ERROR,*999)
            CALL SOLUTION_MAPPING_SOLVER_MATRICES_NUMBER_SET(SOLUTION_MAPPING,1,ERR,ERROR,*999)
          CASE(PROBLEM_SETUP_FINISH_ACTION)
            !Get the control loop
            CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
            CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
            !Get the solution mapping
            CALL CONTROL_LOOP_SOLUTIONS_GET(CONTROL_LOOP,SOLUTIONS,ERR,ERROR,*999)
            CALL SOLUTIONS_SOLUTION_GET(SOLUTIONS,1,SOLUTION,ERR,ERROR,*999)
            CALL SOLUTION_SOLUTION_MAPPING_GET(SOLUTION,SOLUTION_MAPPING,ERR,ERROR,*999)
            !Finish the solution mapping creation
            CALL SOLUTION_MAPPING_CREATE_FINISH(SOLUTION_MAPPING,ERR,ERROR,*999)            
          CASE(PROBLEM_SETUP_DO_ACTION)
            EQUATIONS_TO_ADD=>PROBLEM%EQUATIONS_TO_ADD
            IF(ASSOCIATED(EQUATIONS_TO_ADD)) THEN
              EQUATIONS_SET=>EQUATIONS_TO_ADD%EQUATIONS_SET_TO_ADD
              IF(ASSOCIATED(EQUATIONS_SET)) THEN
                !Check the equations set is from a no source diffusion equation
                IF(EQUATIONS_SET%CLASS==EQUATIONS_SET_CLASSICAL_FIELD_CLASS.AND. &
                  & EQUATIONS_SET%TYPE==EQUATIONS_SET_DIFFUSION_EQUATION_TYPE.AND. &
                  & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_NO_SOURCE_DIFFUSION_SUBTYPE) THEN
                  !Get the control loop
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,EQUATIONS_TO_ADD%CONTROL_LOOP_IDENTIFIER,CONTROL_LOOP,ERR,ERROR,*999)
                  !Get the solution mapping
                  CALL CONTROL_LOOP_SOLUTIONS_GET(CONTROL_LOOP,SOLUTIONS,ERR,ERROR,*999)
                  CALL SOLUTIONS_SOLUTION_GET(SOLUTIONS,EQUATIONS_TO_ADD%SOLUTION_INDEX,SOLUTION,ERR,ERROR,*999)
                  CALL SOLUTION_SOLUTION_MAPPING_GET(SOLUTION,SOLUTION_MAPPING,ERR,ERROR,*999)
                  !Add in the equations set
                  CALL SOLUTION_MAPPING_EQUATIONS_SET_ADD(SOLUTION_MAPPING,EQUATIONS_TO_ADD%EQUATIONS_SET_TO_ADD,EQUATIONS_TO_ADD% &
                    & EQUATIONS_SET_ADDED_INDEX,ERR,ERROR,*999)
                  CALL SOLUTION_MAPPING_EQUATS_VARS_TO_SOLVER_MATRIX_SET(SOLUTION_MAPPING,1,EQUATIONS_TO_ADD% &
                    & EQUATIONS_SET_ADDED_INDEX,(/FIELD_STANDARD_VARIABLE_TYPE/),ERR,ERROR,*999)                 
                ELSE
                  CALL FLAG_ERROR("The equations set to add is not a classical field linear diffusion equations set.", &
                    & ERR,ERROR,*999)
                ENDIF
              ELSE
                CALL FLAG_ERROR("Equations set to add is not associated.",ERR,ERROR,*999)
              ENDIF
            ELSE
              CALL FLAG_ERROR("Problem equations to add is not associated.",ERR,ERROR,*999)
            ENDIF
          CASE DEFAULT
            LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(ACTION_TYPE,"*",ERR,ERROR))// &
              & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(SETUP_TYPE,"*",ERR,ERROR))// &
              & " is invalid for a linear diffusion equation."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        CASE(PROBLEM_SETUP_SOLVER_TYPE)
          !Get the control loop
          CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
          CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
          !Get the solution
          CALL CONTROL_LOOP_SOLUTIONS_GET(CONTROL_LOOP,SOLUTIONS,ERR,ERROR,*999)
          CALL SOLUTIONS_SOLUTION_GET(SOLUTIONS,1,SOLUTION,ERR,ERROR,*999)
          SELECT CASE(ACTION_TYPE)
          CASE(PROBLEM_SETUP_START_ACTION)
            !Start the linear solver creation
            CALL SOLVER_CREATE_START(SOLUTION,SOLVER_DYNAMIC_TYPE,SOLVER,ERR,ERROR,*999)
            !Set solver defaults
            CALL SOLVER_LIBRARY_SET(SOLVER,SOLVER_CMISS_LIBRARY,ERR,ERROR,*999)
            CALL SOLVER_SPARSITY_TYPE_SET(SOLVER,SOLVER_SPARSE_MATRICES,ERR,ERROR,*999)
          CASE(PROBLEM_SETUP_FINISH_ACTION)
            !Get the solver
            CALL SOLUTION_SOLVER_GET(SOLUTION,SOLVER,ERR,ERROR,*999)
            !Finish the solver creation
            CALL SOLVER_CREATE_FINISH(SOLVER,ERR,ERROR,*999)
          CASE(PROBLEM_SETUP_DO_ACTION)
            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
          CASE DEFAULT
            LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(ACTION_TYPE,"*",ERR,ERROR))// &
              & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(SETUP_TYPE,"*",ERR,ERROR))// &
              & " is invalid for a linear diffusion equation."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        CASE DEFAULT
          LOCAL_ERROR="The setup type of "//TRIM(NUMBER_TO_VSTRING(SETUP_TYPE,"*",ERR,ERROR))// &
            & " is invalid for a linear diffusion equation."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        END SELECT
      ELSE
        LOCAL_ERROR="The problem subtype of "//TRIM(NUMBER_TO_VSTRING(PROBLEM%SUBTYPE,"*",ERR,ERROR))// &
          & " does not equal a linear diffusion equation subtype."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("DIFFUSION_EQUATION_PROBLEM_LINEAR_SETUP")
    RETURN
999 CALL ERRORS("DIFFUSION_EQUATION_PROBLEM_LINEAR_SETUP",ERR,ERROR)
    CALL EXITS("DIFFUSION_EQUATION_PROBLEM_LINEAR_SETUP")
    RETURN 1
  END SUBROUTINE DIFFUSION_EQUATION_PROBLEM_LINEAR_SETUP
  
  !
  !================================================================================================================================
  !
  
END MODULE DIFFUSION_EQUATION_ROUTINES
