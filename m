Received: from crux.tip.CSIRO.AU (crux.tip.CSIRO.AU [130.155.194.32])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA17115
	for <linux-mm@kvack.org>; Wed, 24 Jun 1998 19:41:36 -0400
Date: Thu, 25 Jun 1998 09:41:18 +1000
Message-Id: <199806242341.JAA15101@vindaloo.atnf.CSIRO.AU>
From: Richard Gooch <Richard.Gooch@atnf.CSIRO.AU>
Subject: Re: Thread implementations...
In-Reply-To: <m1u35a4fz8.fsf@flinx.npwt.net>
References: <199806240915.TAA09504@vindaloo.atnf.CSIRO.AU>
	<Pine.LNX.3.96dg4.980624025515.26983E-100000@twinlark.arctic.org>
	<199806241213.WAA10661@vindaloo.atnf.CSIRO.AU>
	<m1u35a4fz8.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Eric W. Biederman writes:
> >>>>> "RG" == Richard Gooch <Richard.Gooch@atnf.CSIRO.AU> writes:
> 
> RG> If we get madvise(2) right, we don't need sendfile(2), correct?
> 
> It looks like it from here.  As far as madvise goes, I think we need
> to implement madvise(2) as:
> 
> enum madvise_strategy {
>         MADV_NORMAL,
>         MADV_RANDOM,
>         MADV_SEQUENTIAL,
>         MADV_WILLNEED,
>         MADV_DONTNEED,
> }
> struct madvise_struct {
> 	caddr_t addr;
> 	size_t size;
> 	size_t strategy;
> };
> int sys_madvise(struct madvise_struct *, int count);
> 
> With madvise(3) following the traditional format with only one
               ^
Don't you mean 2?

> advisement can be done easily.  The reason I suggest multiple
> arguments is that for apps that have random but predictable access
> patterns will want to use MADV_WILLNEED & MADV_DONTNEED to an optimum
> swapping algorigthm.

I'm not aware of madvise() being a POSIX standard. I've appended the
man page from alpha_OSF1, which looks reasonable. It would be nice to
be compatible with something.

				Regards,

					Richard....
===============================================================================
madvise(2)							   madvise(2)



NAME

  mmaaddvviissee - Advise the system of the expected paging behavior of a process

SYNOPSIS

  ##iinncclluuddee <<ssyyss//ttyyppeess..hh>>
  ##iinncclluuddee <<ssyyss//mmmmaann..hh>>
  iinntt mmaaddvviissee ((
	  ccaaddddrr__tt _a_d_d_r,,
	  ssiizzee__tt _l_e_n,,
	  iinntt _b_e_h_a_v ));;

PARAMETERS

  _a_d_d_r	    Specifies the address of the region	to which the advice refers.

  _l_e_n	    Specifies the length in bytes of the region	specified by the _a_d_d_r
	    parameter.

  _b_e_h_a_v	    Specifies the behavior of the region.  The following values	for
	    the	_b_e_h_a_v parameter	are defined in the ssyyss//mmmmaann..hh header file:

	    MMAADDVV__NNOORRMMAALL
		      No further special treatment

	    MMAADDVV__RRAANNDDOOMM
		      Expect random page references

	    MMAADDVV__SSEEQQUUEENNTTIIAALL
		      Expect sequential	references

	    MMAADDVV__WWIILLLLNNEEEEDD
		      Will need	these pages

	    MMAADDVV__DDOONNTTNNEEEEDD
		      Do not need these	pages

		      The system will free any resident	pages that are allo-
		      cated to the region.  All	modifications will be lost
		      and any swapped out pages	will be	discarded.  Subse-
		      quent access to the region will result in	a zero-fill-
		      on-demand	fault as though	it is being accessed for the
		      first time.  Reserved swap space is not affected by
		      this call.

	    MMAADDVV__SSPPAACCEEAAVVAAIILL
		      Ensure that resources are	reserved

DESCRIPTION

  The mmaaddvviissee(())	function permits a process to advise the system	about its
  expected future behavior in referencing a mapped file	or shared memory
  region.

NOTES

  Only a few values of the bbeehhaavv parameter values are operational on Digital
  UNIX systems.	 Non-operational values	cause the system to always return
  success (zero).

RETURN VALUES

  Upon successful completion, the mmaaddvviissee(()) function returns zero.  Other-
  wise,	-1 is returned and eerrrrnnoo is set	to indicate the	error.

ERRORS

  If the mmaaddvviissee(()) function fails, eerrrrnnoo may be	set to one of the following
  values:

  [[EEIINNVVAALL]]  The	_b_e_h_a_v parameter	is invalid.

  [[EENNOOSSPPCC]]  The	_b_e_h_a_v parameter	specifies MADV_SPACEAVAIL and resources	can
	    not	be reserved.

RELATED	INFORMATION

  Functions: mmmmaapp(2)
