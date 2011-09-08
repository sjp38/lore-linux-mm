Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7B50B6B017A
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 21:31:37 -0400 (EDT)
Subject: RE: [PATCH] slub Discard slab page only when node partials >
 minimum setting
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <1315442639.31737.224.camel@debian>
References: <1315188460.31737.5.camel@debian>
	 <alpine.DEB.2.00.1109061914440.18646@router.home>
	 <1315357399.31737.49.camel@debian>
	 <alpine.DEB.2.00.1109062022100.20474@router.home>
	 <4E671E5C.7010405@cs.helsinki.fi>
	 <6E3BC7F7C9A4BF4286DD4C043110F30B5D00DA333C@shsmsx502.ccr.corp.intel.com>
	 <alpine.DEB.2.00.1109071003240.9406@router.home>
	 <1315442639.31737.224.camel@debian>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 08 Sep 2011 09:34:34 +0800
Message-ID: <1315445674.29510.74.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Alex" <alex.shi@intel.com>
Cc: Christoph Lameter <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Huang, Ying" <ying.huang@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 2011-09-08 at 08:43 +0800, Shi, Alex wrote:
> On Wed, 2011-09-07 at 23:05 +0800, Christoph Lameter wrote:
> > On Wed, 7 Sep 2011, Shi, Alex wrote:
> > 
> > > Oh, seems the deactivate_slab() corrected at linus' tree already, but
> > > the unfreeze_partials() just copied from the old version
> > > deactivate_slab().
> > 
> > Ok then the patch is ok.
> > 
> > Do you also have performance measurements? I am a bit hesitant to merge
> > the per cpu partials patchset if there are regressions in the low
> > concurrency tests as seem to be indicated by intels latest tests.
> > 
> 
> My LKP testing system most focus on server platforms. I tested your per
> cpu partial set on hackbench and netperf loopback benchmark. hackbench
> improve much.
> 
> Maybe some IO testing is low concurrency for SLUB, maybe a few jobs
> kbuild? or low swap press testing.  I may try them for your patchset in
> the near days. 
> 
> BTW, some testing results for your PCP SLUB:
> 
> for hackbench process testing: 
> on WSM-EP, inc ~60%, NHM-EP inc ~25%
> on NHM-EX, inc ~200%, core2-EP, inc ~250%. 
> on Tigerton-EX, inc 1900%, :) 
> 
> for hackbench thread testing: 
> on WSM-EP, no clear inc, NHM-EP no clear inc
> on NHM-EX, inc 10%, core2-EP, inc ~20%. 
> on Tigertion-EX, inc 100%, 
> 
> for  netperf loopback testing, no clear performance change. 
did you add my patch to add page to partial list tail in the test?
Without it the per-cpu partial list can have more significant impact to
reduce lock contention, so the result isn't precise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
