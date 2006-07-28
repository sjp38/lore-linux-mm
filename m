Date: Fri, 28 Jul 2006 11:28:36 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 0/9] oom: various fixes and improvements for 2.6.18-rc2
Message-ID: <20060728092836.GB4161@wotan.suse.de>
References: <20060515210529.30275.74992.sendpatchset@linux.site> <20060728004410.63bba676.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060728004410.63bba676.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 28, 2006 at 12:44:10AM -0700, Andrew Morton wrote:
> On Fri, 28 Jul 2006 09:20:44 +0200 (CEST)
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > These are some various OOM killer fixes that I have accumulated. Some of
> > the more important ones are in SLES10, and were developed in response to
> > issues coming up in stress testing.
> > 
> > The other small fixes haven't been widely tested, but they're issues I
> > spotted when working in this area.
> > 
> > Comments?
> 
> They all look good to me (although I haven't grappled with the cpuset ones
> yet).

OK.

> 
> The "oom: reclaim_mapped on oom" one is kinda funny.  Back in 2.5.early I
> decided that we were probably donig too much scanning before declaring oom
> so I randomly reduced it by a factor of, iirc, four.  Under the assumption
> that someone would start hitting early ooms and would get in there and tune
> it for real.  It took five years ;)

Well, I guess it *can* make the machine less responsive during OOM, but
I guess it is probably reasonable to trade "OOM throughput" for a system
that is more conservative about killing tasks.

The workload involved was semi-realistic I guess, involving apache/mysql
servers in a hypervisor guest. The after patch 1, it was still killing
early, and with patch 2 it seemed to be the minimum required to get it to
use up all swap first.

> 
> Which of these patches have been well-tested and which are the more
> speculative ones?

1,2,3 are in SLES10, and tested/confirmed to fix things. The others I
guess are more edge cases, but I hope that together they can make things
a little more robust.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
