Received: from teeny.molehill.org (qmailr@molehill.involved.com [207.17.169.8])
	by kvack.org (8.8.7/8.8.7) with SMTP id NAA27272
	for <linux-mm@kvack.org>; Thu, 25 Jun 1998 13:15:01 -0400
Message-ID: <19980625101448.25859@molehill.org>
Date: Thu, 25 Jun 1998 10:14:48 -0700
From: Todd Larason <jtl@molehill.org>
Subject: Re: Thread implementations...
References: <199806240915.TAA09504@vindaloo.atnf.CSIRO.AU> <Pine.LNX.3.96dg4.980624025515.26983E-100000@twinlark.arctic.org> <199806241213.WAA10661@vindaloo.atnf.CSIRO.AU> <m1u35a4fz8.fsf@flinx.npwt.net> <199806242341.JAA15101@vindaloo.atnf.CSIRO.AU> <m1pvfy3x8f.fsf@flinx.npwt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m1pvfy3x8f.fsf@flinx.npwt.net>; from Eric W. Biederman on Wed, Jun 24, 1998 at 11:45:52PM -0500
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 24, 1998 at 11:45:52PM -0500, Eric W. Biederman wrote:
> >>>>> "RG" == Richard Gooch <Richard.Gooch@atnf.CSIRO.AU> writes:
> 
> RG> Eric W. Biederman writes:
> >> >>>>> "RG" == Richard Gooch <Richard.Gooch@atnf.CSIRO.AU> writes:
> 
> Does someone have the Sun/sparc man page?




C Library Functions                                    madvise(3)



NAME
     madvise - provide advice to VM system

SYNOPSIS
     #include <sys/types.h>
     #include <sys/mman.h>

     int madvise(caddr_t _a_d_d_r, size_t _l_e_n, int _a_d_v_i_c_e);

DESCRIPTION
     madvise() advises the kernel that a region  of  user  mapped
     memory in the range [_a_d_d_r, _a_d_d_r + _l_e_n) will be accessed fol-
     lowing a type of pattern.  The kernel uses this  information
     to  optimize  the procedure for manipulating and maintaining
     the resources associated with the specified mapping range.

     Values for _a_d_v_i_c_e are defined in <sys/mman.h> as:

     #define MADV_NORMAL        0x0     /* No further special treatment */
     #define MADV_RANDOM        0x1     /* Expect random page references */
     #define MADV_SEQUENTIAL    0x2     /* Expect sequential page references */
     #define MADV_WILLNEED      0x3     /* Will need these pages */
     #define MADV_DONTNEED      0x4     /* Don't need these pages */

     MADV_NORMAL
          The  default  system  characteristic  where   accessing
          memory  within  the  address range causes the system to
          read data from the mapped file.  The kernel  reads  all
          data  from  files  into  pages which are retained for a
          period of time as a "cache."  System  pages  can  be  a
          scarce  resource, so the kernel steals pages from other
          mappings when needed.  This is a likely occurrence, but
          adversely  affects  system  performance only if a large
          amount of memory is accessed.

     MADV_RANDOM
          Tells the kernel to read in a minimum  amount  of  data
          from a mapped file on any single particular access.  If
          MADV_NORMAL is in effect when an address  of  a  mapped
          file  is  accessed, the system tries to read in as much
          data from the file as reasonable,  in  anticipation  of
          other accesses within a certain locality.

     MADV_SEQUENTIAL
          Tells the system  that  addresses  in  this  range  are
          likely  to  be  accessed  only once, so the system will
          free the resources mapping the address range as quickly
          as  possible.   This  is  used  in the cat(1) and cp(1)
          utilities.

     MADV_WILLNEED
          Tells the  system  that  a  certain  address  range  is



SunOS 5.6           Last change: 29 Dec 1996                    1






C Library Functions                                    madvise(3)



          definitely  needed so the kernel will start reading the
          specified range into memory.  This can benefit programs
          wanting  to  minimize  the time needed to access memory
          the first time, as the kernel would  need  to  read  in
          from the file.

     MADV_DONTNEED
          Tells the kernel that the specified address range is no
          longer  needed,  so  the  system  starts  to  free  the
          resources associated with the address range.

     madvise() should be used by programs with specific knowledge
     of  their  access  patterns  over a memory object, such as a
     mapped file, to increase system performance.

RETURN VALUES
     madvise() returns:

     0    on success.

     -1   on failure and sets errno to indicate the error.

ERRORS
     EINVAL         _a_d_d_r is not a multiple of the  page  size  as
                    returned by sysconf(3C).

                    The length of the specified address range  is
                    less  than  or  equal to 0, or the advice was
                    invalid.

     EIO            An I/O error occurred while reading  from  or
                    writing to the file system.

     ENOMEM         Addresses in the range [_a_d_d_r, _a_d_d_r + _l_e_n) are
                    outside the valid range for the address space
                    of a process, or specify one  or  more  pages
                    that are not mapped.

     ESTALE         Stale nfs file handle.

ATTRIBUTES
     See attributes(5) for descriptions of the  following  attri-
     butes:

     __________________________________
    | ATTRIBUTE TYPE|  ATTRIBUTE VALUE|
    |_______________________________|____________________________________|_
    | MT-Level      |  MT-Safe        |
    |________________|__________________|

SEE ALSO
     cat(1), cp(1), mmap(2), sysconf(3C), attributes(5)



SunOS 5.6           Last change: 29 Dec 1996                    2


No mention of conforming to any standard her.  HP-UX 10.20's manpage
claims conformance with AES and SVID3.  It defines a MADV_SPACEAVAIL
behavior too, but notes that it isn't implemented.
