#include "cppdefs.h"
      MODULE mod_iounits
!
!svn $Id$
!================================================== Hernan G. Arango ===
!  Copyright (c) 2002-2019 The ROMS/TOMS Group                         !
!    Licensed under a MIT/X style license                              !
!    See License_ROMS.txt                                              !
!=======================================================================
!                                                                      !
!  The input and output files information is stored in compact derived !
!  type structure, TYPE(T_IO):                                         !
!                                                                      !
!    ADM       Output adjoint model history data                       !
!    ADS       Input adjoint sensitivity functional                    !
!    AVG       Output time-averaged data                               !
!    AVG2      Secondary time-averaged data                            !
!    BLK       Input bulk fluxes data in adjoint-based applications    !
!    BRY       Input open boundary conditions data                     !
!    CLM       Input climatology data                                  !
!    DAI       Output data assimilation next cycle initial conditions  !
!                (4D-Var analysis) or restart (Ensemble Kalman Filter) !
!    DAV       Output 4D-Var data assimilation variables               !
!    DIA       Output diagnostics fields                               !
!    ERR       Output 4DVar posterior error estimate                   !
#ifdef W4DPSAS_FCT_SENSITIVITY
!    FCTA      Input basic state forecast solution                     !
!    FCTB      Input basic state forecast solution                     !
#endif
!    FLT       Output Lagrangian trajectories data                     !
#if defined W4DPSAS_FCT_SENSITIVITY && !defined OBS_SPACE
!    FOIA      Input Forecast Observation Impacts forcing data when    !
!                initialized from the 4D-Var Analysis (red curve)      !
!    FOIB      Input Forecast Observation Impacts forcing data when    !
!                initialized from the 4D-Var Background (blue curve)   !
#endif
!    FRC       Input forcing data                                      !
!    FWD       Input basic state forward solution                      !
!    GRD       Input grid data                                         !
!    GST       Input/output GST analysis check pointing data           !
!    HAR       Output detiding least-squares harmonics coefficients    !
!    HIS       Output nonlinear model history data                     !
!    HSS       Input/output Hessian eigenvectors                       !
!    IAD       Input adjoint model initial conditions                  !
!    INI       Input nonlinear model initial conditions                !
!    IPR       Input representer model initial conditions              !
!    ITL       Input tangent linear model initial conditions           !
!    LCZ       Input/output Lanczos vectors                            !
!    LZE       Input/output time-evolved Lanczos vectors               !
!    NRM       Input/output error covariance normalization data        !
!                NRM(1,ng)  initial conditions                         !
!                NRM(2,ng)  model error                                !
!                NRM(3,ng)  lateral open boundary conditions           !
!                NRM(4,ng)  surface forcing                            !
!    NUD       Input climatology nudging coefficients                  !
!    OBS       Input/output 4D-Var observations                        !
#if defined W4DPSAS_FCT_SENSITIVITY && defined OBS_SPACE
!    OIFA      Input Observations Impact Forcing at datum locations if !
!                initialized from the 4D-Var Analysis (red curve)      !
!    OIFB      Input Observations Impact Forcing at datum locations if !
!                initialized from the 4D-Var Background (blue curve)   !
#endif
!    QCK       Output nonlinear model brief snpashots data             !
!    RST       Output restart data                                     !
!    TIDE      Input tide forcing                                      !
!    TLF       Input/output tangent linear model impulse forcing       !
!    TLM       Output tangent linear model history                     !
!    SSF       Input Sources/Sinks forcing (river runoff)              !
!    STA       Output station data                                     !
!    STD       Input error covariance standard deviations              !
!                STD(1,ng)  initial conditions                         !
!                STD(2,ng)  model error                                !
!                STD(3,ng)  lateral open boundary conditions           !
!                STD(4,ng)  surface forcing                            !
!                                                                      !
!  Input/output information files:                                     !
!                                                                      !
!  Iname       Physical parameters standard input script filename.     !
!  NGCname     Nested grids contact point information filename.        !
!  USRname     USER input/output generic filename.                     !
!  Wname       Wave model stadard input filename.                      !
!  aparnam     Input assimilation parameters filename.                 !
!  bparnam     Input biology parameters filename.                      !
!  fbionam     Input floats biological behavior parameters filename.   !
!  fposnam     Input initial floats positions filename.                !
!  iparnam     Input ice parameters filename.                          !
!  sparnam     Input sediment transport parameters filename.           !
!  sposnam     Input station positions filename.                       !
!  varname     Input IO variables information filename.                !
!                                                                      !
!  stdinp      Unit number for standard input (often 5).               !
!  stdout      Unit number for standard output (often 6).              !
!  usrout      Unit number for generic USER output.                    !
!                                                                      !
!  Miscellaneous variables:                                            !
!                                                                      !
!  BRYids      NetCDF file ID associated with each boundary field.     !
!  CLMids      NetCDF file ID associated with each climatology field.  !
!  FRCids      NetCDF file ID associated with each forcing field.      !
!  SSFids      NetCDF file ID associated with each river source field. !
!  Rerror      Running error messages.                                 !
!  SourceFile  Current executed filename. It is used for IO error      !
!                purposes.                                             !
!  ioerror     IO error flag.                                          !
!  ncfile      Current NetCDF filename being processed.                !
!  nFfiles     Number of forcing files.                                !
!                                                                      !
!=======================================================================
!
      USE mod_param
!
      implicit none
!
!  I/O units.
!
      integer :: stdinp = 5                 ! standard input
      integer :: stdout = 6                 ! standard output
      integer :: usrout = 10                ! generic user unit
!
!  I/O files management, derived type structures.
!
      TYPE(T_IO), allocatable :: ADM(:)     ! ADM history fields
      TYPE(T_IO), allocatable :: ADS(:)     ! sensitivity functional
      TYPE(T_IO), allocatable :: AVG(:)     ! time-averaged fields
      TYPE(T_IO), allocatable :: AVG2(:)    ! secondary averaged fields
      TYPE(T_IO), allocatable :: BLK(:)     ! bulk fluxes fields
      TYPE(T_IO), allocatable :: DAI(:)     ! Data assilation IC/restart
      TYPE(T_IO), allocatable :: DAV(:)     ! 4D-Var variables
      TYPE(T_IO), allocatable :: DIA(:)     ! diagnostics fields
      TYPE(T_IO), allocatable :: ERR(:)     ! 4D-Var posterior error
      TYPE(T_IO), allocatable :: FIL(:,:)   ! Filter restart
      TYPE(T_IO), allocatable :: FLT(:)     ! Lagrangian trajectories
#ifdef W4DPSAS_FCT_SENSITIVITY
      TYPE(T_IO), allocatable :: FCTA(:)    ! forecast for impacts, A
      TYPE(T_IO), allocatable :: FCTB(:)    ! forecast for impacts, B
#endif
#if defined W4DPSAS_FCT_SENSITIVITY && !defined OBS_SPACE
      TYPE(T_IO), allocatable :: FOIA(:)    ! observation impacts, A
      TYPE(T_IO), allocatable :: FOIB(:)    ! observation impacts, B
#endif
      TYPE(T_IO), allocatable :: FWD(:)     ! forward solution
      TYPE(T_IO), allocatable :: GRD(:)     ! grid data
      TYPE(T_IO), allocatable :: GST(:)     ! generalized stability
      TYPE(T_IO), allocatable :: HAR(:)     ! detiding harmonics
      TYPE(T_IO), allocatable :: HIS(:)     ! NLM history fields
      TYPE(T_IO), allocatable :: HSS(:)     ! Hessian eigenvectors
      TYPE(T_IO), allocatable :: IAD(:)     ! ADM initial conditions
      TYPE(T_IO), allocatable :: INI(:)     ! NLM initial conditions
      TYPE(T_IO), allocatable :: IRP(:)     ! RPM initial conditions
      TYPE(T_IO), allocatable :: ITL(:)     ! TLM initial conditions
      TYPE(T_IO), allocatable :: LCZ(:)     ! Lanczos vectors
      TYPE(T_IO), allocatable :: LZE(:)     ! evolved Lanczos vectors
      TYPE(T_IO), allocatable :: NRM(:,:)   ! normalization
      TYPE(T_IO), allocatable :: NUD(:)     ! nudging coefficients
      TYPE(T_IO), allocatable :: OBS(:)     ! observations
#if defined W4DPSAS_FCT_SENSITIVITY && defined OBS_SPACE
      TYPE(T_IO), allocatable :: OIFA(:)    ! observation impacts, A
      TYPE(T_IO), allocatable :: OIFB(:)    ! observation impacts, B
#endif
      TYPE(T_IO), allocatable :: QCK(:)     ! quicksave fields
      TYPE(T_IO), allocatable :: RST(:)     ! restart fields
      TYPE(T_IO), allocatable :: STA(:)     ! stations data
      TYPE(T_IO), allocatable :: STD(:,:)   ! standard deviation
      TYPE(T_IO), allocatable :: TIDE(:)    ! tidal forcing
      TYPE(T_IO), allocatable :: TLF(:)     ! TLM impulse fields
      TYPE(T_IO), allocatable :: TLM(:)     ! TLM history fields
!
!  Input boundary condition data.
!
      integer, allocatable :: nBCfiles(:)
      integer, allocatable :: BRYids(:,:)

      TYPE(T_IO), allocatable :: BRY(:,:)
!
!  Input climatology data.
!
      integer, allocatable :: nCLMfiles(:)
      integer, allocatable :: CLMids(:,:)

      TYPE(T_IO), allocatable :: CLM(:,:)   ! climatology fields
!
!  Input forcing data.
!
      integer, allocatable :: nFfiles(:)
      integer, allocatable :: FRCids(:,:)

      TYPE(T_IO), allocatable :: FRC(:,:)
!
!  Input river source data.
!
      integer, allocatable :: nSSFfiles(:)
      integer, allocatable :: SSFids(:,:)

      TYPE(T_IO), allocatable :: SSF(:,:)
!
!  Error messages.
!
      character (len=50), dimension(10) :: Rerror =                     &
     &       (/ ' ROMS/TOMS - Blows up ................ exit_flag: ',   &
     &          ' ROMS/TOMS - Input error ............. exit_flag: ',   &
     &          ' ROMS/TOMS - Output error ............ exit_flag: ',   &
     &          ' ROMS/TOMS - I/O error ............... exit_flag: ',   &
     &          ' ROMS/TOMS - Configuration error ..... exit_flag: ',   &
     &          ' ROMS/TOMS - Partition error ......... exit_flag: ',   &
     &          ' ROMS/TOMS - Illegal input parameter . exit_flag: ',   &
     &          ' ROMS/TOMS - Fatal algorithm result .. exit_flag: ',   &
     &          ' ROMS/TOMS - Coupling error .......... exit_flag: ',   &
     &          ' ROMS/TOMS - Frazil ice problem ...... exit_flag: ' /)
!
!  Standard input scripts filenames.
!
      character (len=256) :: Iname          ! ROMS physical parameters
      character (len=256) :: Wname          ! wave model standard input
      character (len=256) :: NGCname        ! contact points filename
      character (len=256) :: USRname        ! use generic filename
      character (len=256) :: aparnam        ! assimilation parameters
      character (len=256) :: bparnam        ! biology model parameters
      character (len=256) :: fbionam        ! floats behavior parameters
      character (len=256) :: fposnam        ! floats positions
      character (len=256) :: iparnam        ! ice model parameters
      character (len=256) :: sparnam        ! sediment model parameters
      character (len=256) :: sposnam        ! station positions
      character (len=256) :: varname        ! I/O metadata
!
!  Miscelaneous variables.
!
      integer :: ioerror = 0                ! I/O error flag

      character (len=256) :: MyAppCPP       ! application CPP flag
      character (len=256) :: SourceFile     ! current executed ROMS file
      character (len=256) :: ncfile         ! current NetCDF file
!
      CONTAINS
!
      SUBROUTINE allocate_iounits
!
!=======================================================================
!                                                                      !
!  This routine allocates several variables in the module that depend  !
!  on the number of nested grids.                                      !
!                                                                      !
!=======================================================================
!
!  Local variable declarations.
!
      integer :: i, lstr, ng

      character (len=1), parameter :: blank = ' '
!
!-----------------------------------------------------------------------
!  Allocate I/O files management, derived type structures.
!-----------------------------------------------------------------------
!
      IF (.not.allocated(ADM)) THEN
        allocate ( ADM(Ngrids) )
      END IF
      IF (.not.allocated(ADS)) THEN
        allocate ( ADS(Ngrids) )
      END IF
      IF (.not.allocated(AVG)) THEN
        allocate ( AVG(Ngrids) )
      END IF
      IF (.not.allocated(AVG2)) THEN
        allocate ( AVG2(Ngrids) )
      END IF
      IF (.not.allocated(BLK)) THEN
        allocate ( BLK(Ngrids) )
      END IF
      IF (.not.allocated(DAI)) THEN
        allocate ( DAI(Ngrids) )
      END IF
      IF (.not.allocated(DAV)) THEN
        allocate ( DAV(Ngrids) )
      END IF
      IF (.not.allocated(DIA)) THEN
        allocate ( DIA(Ngrids) )
      END IF
      IF (.not.allocated(ERR)) THEN
        allocate ( ERR(Ngrids) )
      END IF
#ifdef FILTERED_RST
# ifdef GLACIER_BAY
! Not sure what this is all about, but was getting seg faults.
      IF (.not. allocated(FIL)) allocate ( FIL(10,Ngrids) )
# else
! Ditto
      IF (.not. allocated(FIL)) allocate ( FIL(10,Ngrids) )
# endif
#endif
      IF (.not.allocated(FLT)) THEN
        allocate ( FLT(Ngrids) )
      END IF
#ifdef W4DPSAS_FCT_SENSITIVITY
      IF (.not.allocated(FCTA)) THEN
        allocate ( FCTA(Ngrids) )
      END IF
      IF (.not.allocated(FCTB)) THEN
        allocate ( FCTB(Ngrids) )
      END IF
#endif
#if defined W4DPSAS_FCT_SENSITIVITY && !defined OBS_SPACE
      IF (.not.allocated(FOIA)) THEN
        allocate ( FOIA(Ngrids) )
      END IF
      IF (.not.allocated(FOIB)) THEN
        allocate ( FOIB(Ngrids) )
      END IF
#endif
      IF (.not.allocated(FWD)) THEN
        allocate ( FWD(Ngrids) )
      END IF
      IF (.not.allocated(GRD)) THEN
        allocate ( GRD(Ngrids) )
      END IF
      IF (.not.allocated(GST)) THEN
        allocate ( GST(Ngrids) )
      END IF
      IF (.not.allocated(HAR)) THEN
        allocate ( HAR(Ngrids) )
      END IF
      IF (.not.allocated(HIS)) THEN
        allocate ( HIS(Ngrids) )
      END IF
      IF (.not.allocated(HSS)) THEN
        allocate ( HSS(Ngrids) )
      END IF
      IF (.not.allocated(IAD)) THEN
        allocate ( IAD(Ngrids) )
      END IF
      IF (.not.allocated(INI)) THEN
        allocate ( INI(Ngrids) )
      END IF
      IF (.not.allocated(IRP)) THEN
        allocate ( IRP(Ngrids) )
      END IF
      IF (.not.allocated(ITL)) THEN
        allocate ( ITL(Ngrids) )
      END IF
      IF (.not.allocated(LCZ)) THEN
        allocate ( LCZ(Ngrids) )
      END IF
      IF (.not.allocated(LZE)) THEN
        allocate ( LZE(Ngrids) )
      END IF
      IF (.not.allocated(NUD)) THEN
        allocate ( NUD(Ngrids) )
      END IF
      IF (.not.allocated(OBS)) THEN
        allocate ( OBS(Ngrids) )
      END IF
#if defined W4DPSAS_FCT_SENSITIVITY && defined OBS_SPACE
      IF (.not.allocated(OIFA)) THEN
        allocate ( OIFA(Ngrids) )
      END IF
      IF (.not.allocated(OIFB)) THEN
        allocate ( OIFB(Ngrids) )
      END IF
#endif
      IF (.not.allocated(QCK)) THEN
        allocate ( QCK(Ngrids) )
      END IF
      IF (.not.allocated(RST)) THEN
        allocate ( RST(Ngrids) )
      END IF
      IF (.not.allocated(STA)) THEN
        allocate ( STA(Ngrids) )
      END IF
      IF (.not.allocated(TIDE)) THEN
        allocate ( TIDE(Ngrids) )
      END IF
      IF (.not.allocated(TLF)) THEN
        allocate ( TLF(Ngrids) )
      END IF
      IF (.not.allocated(TLM)) THEN
        allocate ( TLM(Ngrids) )
      END IF

      IF (.not.allocated(NRM)) THEN
        allocate ( NRM(4,Ngrids) )
      END IF
      IF (.not.allocated(STD)) THEN
        allocate ( STD(4,Ngrids) )
      END IF
!
!-----------------------------------------------------------------------
!  Allocate variables.
!-----------------------------------------------------------------------
!
      IF (.not. allocated(nBCfiles)) allocate ( nBCfiles(Ngrids) )
      IF (.not. allocated(nCLMfiles)) allocate ( nCLMfiles(Ngrids) )
      IF (.not. allocated(nFfiles)) allocate ( nFfiles(Ngrids) )
      IF (.not. allocated(nSSFfiles)) allocate ( nSSFfiles(Ngrids) )
!
!-----------------------------------------------------------------------
!  Initialize I/O NetCDF files ID to close state.
!-----------------------------------------------------------------------
!
      DO ng=1,Ngrids
        ADM(ng)%ncid=-1
        ADS(ng)%ncid=-1
        AVG(ng)%ncid=-1
        AVG2(ng)%ncid=-1
        BLK(ng)%ncid=-1
        DAI(ng)%ncid=-1
        DAV(ng)%ncid=-1
        DIA(ng)%ncid=-1
        ERR(ng)%ncid=-1
        FLT(ng)%ncid=-1
#ifdef W4DPSAS_FCT_SENSITIVITY
        FCTA(ng)%ncid=-1
        FCTB(ng)%ncid=-1
#endif
#if defined W4DPSAS_FCT_SENSITIVITY && !defined OBS_SPACE
        FOIA(ng)%ncid=-1
        FOIB(ng)%ncid=-1
#endif
        FWD(ng)%ncid=-1
        GRD(ng)%ncid=-1
        GST(ng)%ncid=-1
        HAR(ng)%ncid=-1
        HIS(ng)%ncid=-1
        HSS(ng)%ncid=-1
        IAD(ng)%ncid=-1
        INI(ng)%ncid=-1
        IRP(ng)%ncid=-1
        ITL(ng)%ncid=-1
        LCZ(ng)%ncid=-1
        LZE(ng)%ncid=-1
        NUD(ng)%ncid=-1
        OBS(ng)%ncid=-1
#if defined W4DPSAS_FCT_SENSITIVITY && defined OBS_SPACE
        OIFA(ng)%ncid=-1
        OIFB(ng)%ncid=-1
#endif
        QCK(ng)%ncid=-1
        RST(ng)%ncid=-1
        STA(ng)%ncid=-1
        TLF(ng)%ncid=-1
        TLM(ng)%ncid=-1

        TIDE(ng)%ncid=-1

        NRM(1:4,ng)%ncid=-1
        STD(1:4,ng)%ncid=-1
      END DO
!
!-----------------------------------------------------------------------
!  Initialize filenames to blanks.
!-----------------------------------------------------------------------
!
      DO ng=1,Ngrids
        lstr=LEN(HIS(ng)%name)
        DO i=1,lstr
          ADM(ng)%base(i:i)=blank
          ADM(ng)%name(i:i)=blank

          ADS(ng)%base(i:i)=blank
          ADS(ng)%name(i:i)=blank

          AVG(ng)%base(i:i)=blank
          AVG(ng)%name(i:i)=blank

          AVG2(ng)%base(i:i)=blank
          AVG2(ng)%name(i:i)=blank

          BLK(ng)%base(i:i)=blank
          BLK(ng)%name(i:i)=blank

          DAI(ng)%base(i:i)=blank
          DAI(ng)%name(i:i)=blank

          DAV(ng)%base(i:i)=blank
          DAV(ng)%name(i:i)=blank

          DIA(ng)%base(i:i)=blank
          DIA(ng)%name(i:i)=blank

          ERR(ng)%base(i:i)=blank
          ERR(ng)%name(i:i)=blank

          FLT(ng)%base(i:i)=blank
          FLT(ng)%name(i:i)=blank

#ifdef W4DPSAS_FCT_SENSITIVITY
          FCTA(ng)%base(i:i)=blank
          FCTA(ng)%name(i:i)=blank

          FCTB(ng)%base(i:i)=blank
          FCTB(ng)%name(i:i)=blank
#endif

#if defined W4DPSAS_FCT_SENSITIVITY && !defined OBS_SPACE
          FOIA(ng)%base(i:i)=blank
          FOIA(ng)%name(i:i)=blank

          FOIB(ng)%base(i:i)=blank
          FOIB(ng)%name(i:i)=blank
#endif

          FWD(ng)%base(i:i)=blank
          FWD(ng)%name(i:i)=blank

          GRD(ng)%base(i:i)=blank
          GRD(ng)%name(i:i)=blank

          GST(ng)%base(i:i)=blank
          GST(ng)%name(i:i)=blank

          HAR(ng)%base(i:i)=blank
          HAR(ng)%name(i:i)=blank

          HIS(ng)%base(i:i)=blank
          HIS(ng)%name(i:i)=blank

          HSS(ng)%base(i:i)=blank
          HSS(ng)%name(i:i)=blank

          IAD(ng)%base(i:i)=blank
          IAD(ng)%name(i:i)=blank

          INI(ng)%base(i:i)=blank
          INI(ng)%name(i:i)=blank

          IRP(ng)%base(i:i)=blank
          IRP(ng)%name(i:i)=blank

          ITL(ng)%base(i:i)=blank
          ITL(ng)%name(i:i)=blank

          LCZ(ng)%base(i:i)=blank
          LCZ(ng)%name(i:i)=blank

          LZE(ng)%base(i:i)=blank
          LZE(ng)%name(i:i)=blank

          NUD(ng)%base(i:i)=blank
          NUD(ng)%name(i:i)=blank

          OBS(ng)%base(i:i)=blank
          OBS(ng)%name(i:i)=blank

#if defined W4DPSAS_FCT_SENSITIVITY && defined OBS_SPACE
          OIFA(ng)%base(i:i)=blank
          OIFA(ng)%name(i:i)=blank

          OIFB(ng)%base(i:i)=blank
          OIFB(ng)%name(i:i)=blank
#endif

          QCK(ng)%base(i:i)=blank
          QCK(ng)%name(i:i)=blank

          RST(ng)%base(i:i)=blank
          RST(ng)%name(i:i)=blank

          STA(ng)%base(i:i)=blank
          STA(ng)%name(i:i)=blank

          TLF(ng)%base(i:i)=blank
          TLF(ng)%name(i:i)=blank

          TLM(ng)%base(i:i)=blank
          TLM(ng)%name(i:i)=blank

          TIDE(ng)%base(i:i)=blank
          TIDE(ng)%name(i:i)=blank

          NRM(1:4,ng)%base(i:i)=blank
          NRM(1:4,ng)%name(i:i)=blank

          STD(1:4,ng)%base(i:i)=blank
          STD(1:4,ng)%name(i:i)=blank
        END DO
      END DO
!
      DO i=1,LEN(Iname)
        Wname(i:i)=blank
        NGCname(i:i)=blank
        USRname(i:i)=blank
        aparnam(i:i)=blank
        bparnam(i:i)=blank
        fbionam(i:i)=blank
        fposnam(i:i)=blank
        iparnam(i:i)=blank
        sparnam(i:i)=blank
        sposnam(i:i)=blank
      END DO

      RETURN
      END SUBROUTINE allocate_iounits

      END MODULE mod_iounits
