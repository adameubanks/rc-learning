!*******************************************************************************
! Program to compute pi using a Monte-Carlo integration
!
! Author:  K. Holcomb
! Date  :  20180424
!
!*******************************************************************************

module random
  implicit none

  ! Author:  Katherine Holcomb
  ! Shortened version of a longer module
  ! Module incorporated into this file for convenience; typically it would be in its
  ! own file.
  ! Comment out one or the other when the module is incorporated into a code.

  ! Single precision
  !integer, parameter   :: rk = kind(1.0)
  ! Double precision
  integer, parameter   :: rk = kind(1.0d0)

  contains
     subroutine set_random_seed(seed)
       ! Sets all elements of the seed array
       integer, optional, intent(in)       :: seed

       integer                             :: isize
       integer, dimension(:), allocatable  :: iseed
       integer, dimension(8)               :: idate
       integer                             :: icount, i

       call random_seed(size=isize)

       if ( .not. present(seed) ) then
          call system_clock(icount)
          allocate(iseed(isize),source=icount+370*[(i,i=0,isize-1)])
       else
          allocate(iseed(isize))
          iseed=seed
       endif

       call random_seed(put=iseed)

     end subroutine set_random_seed

     function urand(lb,ub,seed)
       ! Returns a uniformly-distributed random number in the range lb to ub.
       real(rk)                        :: urand
       real(rk), optional, intent(in)  :: lb,ub
       real(rk), optional, intent(in)  :: seed

       integer                         :: iseed
       real(rk)                        :: rnd
       real(rk)                        :: lower,upper

       if ( present(seed) ) then
          iseed=int(seed)
          call set_random_seed(iseed)
       endif

       if ( present(lb) ) then
          lower=lb
       else
          lower=0.0_rk
       endif

       if ( present(ub) ) then
          upper = ub
       else
          upper = 1.0_rk
       endif

       call random_number(rnd)
       urand = lower+(upper-lower)*rnd

       return
     end function urand
end module

program piMC
   use mpi
   use random
   implicit none

   integer, parameter :: ik = selected_int_kind(15)
   character(len=12)  :: throws
   integer            :: nargs
   integer(ik)        :: my_nthrows, my_hits, n_extra, n_throws, n_hits
   double precision   :: pi

   integer            :: rank, nprocs, ierr
   integer(ik)        :: n

   interface 
      function throw_darts(n_throws)
         integer, parameter :: ik = selected_int_kind(15)
         integer(ik)             :: throw_darts
         integer(ik), intent(in) :: n_throws
      end function throw_darts
   end interface

   nargs=command_argument_count()
   if (nargs .lt. 1) then
       n_throws=1000000000   ! default, if not wanted then stop
   else
      call get_command_argument(1,throws)
      read(throws,'(i12)') n_throws
   endif

   call MPI_Init(ierr)
   call MPI_Comm_size(MPI_COMM_WORLD,nprocs,ierr)
   call MPI_Comm_rank(MPI_COMM_WORLD,rank,ierr)

   call set_random_seed()

! For strong scaling
   my_nthrows=n_throws/nprocs
   n_extra=mod(n_throws,nprocs) ! dopey load balancing
   if ( n_extra /=0 ) then
      do n=1,n_extra
         if (n-1==rank) my_nthrows=my_nthrows+1
      enddo
   endif
! For weak scaling
!  my_nthrows=n_throws
! change final denominator to npes*n_throws

   my_hits=throw_darts(my_nthrows)

   call MPI_Reduce(my_hits,n_hits,1,MPI_INTEGER8,MPI_SUM,0,MPI_COMM_WORLD,ierr)
   
   pi=4.0d0*dble(n_hits)/dble(n_throws)

   if ( rank==0 ) then
      write(*,'(f12.8)') pi
   endif

!weak scaling
!   pi=4.0d0*dble(n_hits)/dble(nprocs*n_throws)

   call MPI_Finalize(ierr)

end program piMC

function throw_darts(n_throws)
   use random
   integer, parameter      :: ik = selected_int_kind(15)
   integer(ik)             :: throw_darts
   integer(ik), intent(in) :: n_throws
   integer(ik)             :: i,hits
   double precision        :: x, y

   hits=0
   do i=1,n_throws
      x=urand(0.d0,1.d0)
      y=urand(0.d0,1.d0)
      if (sqrt(x**2+y**2)<1.0) then
         hits=hits+1
      endif
   enddo

   throw_darts=hits
end function throw_darts
