Received: from thermo.lanl.gov (thermo.lanl.gov [128.165.59.202])
	by mailwasher-b.lanl.gov (8.12.11/8.12.11/(ccn-5)) with SMTP id jA4Lp78Z016735
	for <linux-mm@kvack.org>; Fri, 4 Nov 2005 14:51:07 -0700
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-Id: <20051104215103.E5C6C18476F@thermo.lanl.gov>
Date: Fri,  4 Nov 2005 14:51:03 -0700 (MST)
From: andy@thermo.lanl.gov (Andy Nelson)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: gmaxwell@gmail.com
Cc: akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@mbligh.org, mel@csn.ul.ie, mingo@elte.hu, nickpiggin@yahoo.com.au, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

Hi folks,

It sound like in principle I (`I'=generic HPC person) could be
happy with this sort of solution. The proof of the pudding is
in the eating however, and various perversions and misunderstanding
can still always crop up. Hopefully they can be solved or avoided
if the do show up though. Also, other folk might not be so satisfied.
I'll let them speak for themselves though.

One issue remaining is that I don't know how this hugetlbfs stuff 
that was discussed actually works or should work, in terms of 
the interface to my code. What would work for me is something to 
the effect of

f90 -flag_that_turns_access_to_big_pages_on code.f

That then substitutes in allocation calls to this hugetlbfs zone
instead of `normal' allocation calls to generic memory, and perhaps
lets me fall back to normal memory up to whatever system limits may
exist if no big pages are available.

Or even something more simple like 

setenv HEY_OS_I_WANT_BIG_PAGES_FOR_MY_JOB  

or alternatively, a similar request in a batch script.
I don't know that any of these things really have much to do
with the OS directly however.


Thanks all, and have a good weekend.

Andy




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
