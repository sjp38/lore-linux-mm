Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 9A5A06B0044
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 04:38:34 -0500 (EST)
Date: Mon, 26 Nov 2012 09:38:26 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Comparison between three trees (was: Latest numa/core release,
 v17)
Message-ID: <20121126093826.GG8218@suse.de>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
 <20121123173205.GZ8218@suse.de>
 <CAJd=RBCUZn4gvzAME0Xm98TCBRnY_201R3dkKaWMySYr4hNmFA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAJd=RBCUZn4gvzAME0Xm98TCBRnY_201R3dkKaWMySYr4hNmFA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Nov 25, 2012 at 04:47:15PM +0800, Hillf Danton wrote:
> On 11/24/12, Mel Gorman <mgorman@suse.de> wrote:
> > Warning: This is an insanely long mail and there a lot of data here. Get
> > 	coffee or something.
> >
> > This is another round of comparisons between the latest released versions
> > of each of three automatic numa balancing trees that are out there.
> >
> > From the series "Automatic NUMA Balancing V5", the kernels tested were
> >
> > stats-v5r1	Patches 1-10. TLB optimisations, migration stats
> > thpmigrate-v5r1	Patches 1-37. Basic placement policy, PMD handling, THP
> > migration etc.
> > adaptscan-v5r1	Patches 1-38. Heavy handed PTE scan reduction
> > delaystart-v5r1 Patches 1-40. Delay the PTE scan until running on a new
> > node
> >
> > If I just say balancenuma, I mean the "delaystart-v5r1" kernel. The other
> > kernels are included so you can see the impact the scan rate adaption
> > patch has and what that might mean for a placement policy using a proper
> > feedback mechanism.
> >
> > The other two kernels were
> >
> > numacore-20121123 It was no longer clear what the deltas between releases
> > and
> > 	the dependencies might be so I just pulled tip/master on November
> > 	23rd, 2012. An earlier pull had serious difficulties and the patch
> > 	responsible has been dropped since. This is not a like-with-like
> > 	comparison as the tree contains numerous other patches but it's
> > 	the best available given the timeframe
> >
> > autonuma-v28fast This is a rebased version of Andrea's autonuma-v28fast
> > 	branch with Hugh's THP migration patch on top.
> 
> FYI, based on how target huge page is selected,
> 
> +
> +	new_page = alloc_pages_node(numa_node_id(),
> +		(GFP_TRANSHUGE | GFP_THISNODE) & ~__GFP_WAIT, HPAGE_PMD_ORDER);
> 
> the thp replacement policy is changed to be MORON,
> 

That is likely true. When rebasing a policy on top of balancenuma it is
important to keep an eye on what node is used for target migration and
what node is passed to task_numa_fault() and confirm this is the node
the policy expects.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
