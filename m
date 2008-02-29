Date: Fri, 29 Feb 2008 14:12:51 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/6] Use two zonelists per node instead of multiple zonelists v11r3
Message-ID: <20080229141250.GA6045@csn.ul.ie>
References: <20080227214708.6858.53458.sendpatchset@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080227214708.6858.53458.sendpatchset@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: akpm@linux-foundation.org, ak@suse.de, clameter@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, rientjes@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On (27/02/08 16:47), Lee Schermerhorn didst pronounce:
> From: Mel Gorman <mel@csn.ul.ie>
> [PATCH 0/6] Use two zonelists per node instead of multiple zonelists v11r3
> 
> This is a rebase of the two-zonelist patchset to 2.6.25-rc2-mm1.
> 
> Mel, still on vacation last I checked,  asked me to repost these
> as I'd already rebased them and I've been testing them continually
> on each -mm tree for months, hoping to see them in -mm for wider
> testing.
> 

Thanks a lot, Lee. I tested this patchset against a slightly patched
2.6.25-rc2-mm1 (compile-failure fix and a memoryless-related bug that is
fixed in git-x86#testing).

> These are the range of performance losses/gains when running against
> 2.6.24-rc4-mm1. The set and these machines are a mix of i386, x86_64 and
> ppc64 both NUMA and non-NUMA.
> 

Against 2.6.25-rc5-mm1, the results are
				loss	to	gain
Total CPU time on Kernbench:	-0.23%		 1.04%
Elapsed time on Kernbench:	-0.69%		 3.86%
page_test from aim9:		-3.74%		 5.72%
brk_test from aim9:		-7.37%		10.98%
fork_test from aim9:		-3.52%		 3.17%
exec_test from aim9:		-2.78%		 2.34%
TBench:				-1.93%		 2.96%

Hackbench was similarly variable but most machines showed little or no
difference. As before, whether the changes are a performance win/loss
depends on the machine but the majority of results showed little
difference.

> 			     loss   to  gain
> Total CPU time on Kernbench: -0.86% to  1.13%
> Elapsed   time on Kernbench: -0.79% to  0.76%
> page_test from aim9:         -4.37% to  0.79%
> brk_test  from aim9:         -0.71% to  4.07%
> fork_test from aim9:         -1.84% to  4.60%
> exec_test from aim9:         -0.71% to  1.08%
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
