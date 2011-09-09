Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 020936B018E
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 04:39:57 -0400 (EDT)
Subject: RE: [PATCH] slub Discard slab page only when node partials >
 minimum setting
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <alpine.DEB.2.00.1109081336320.14787@router.home>
References: <1315188460.31737.5.camel@debian>
	 <alpine.DEB.2.00.1109061914440.18646@router.home>
	 <1315357399.31737.49.camel@debian>
	 <alpine.DEB.2.00.1109062022100.20474@router.home>
	 <4E671E5C.7010405@cs.helsinki.fi>
	 <6E3BC7F7C9A4BF4286DD4C043110F30B5D00DA333C@shsmsx502.ccr.corp.intel.com>
	 <alpine.DEB.2.00.1109071003240.9406@router.home>
	 <1315442639.31737.224.camel@debian>
	 <alpine.DEB.2.00.1109081336320.14787@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 09 Sep 2011 16:45:44 +0800
Message-ID: <1315557944.31737.782.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Huang, Ying" <ying.huang@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 2011-09-09 at 02:37 +0800, Christoph Lameter wrote:
> On Thu, 8 Sep 2011, Alex,Shi wrote:
> 
> > BTW, some testing results for your PCP SLUB:
> >
> > for hackbench process testing:
> > on WSM-EP, inc ~60%, NHM-EP inc ~25%
> > on NHM-EX, inc ~200%, core2-EP, inc ~250%.
> > on Tigerton-EX, inc 1900%, :)
> 
> There is no minus on tigerton. I hope that is not a regression?

Sorry for incorrect usage of '~'. I want use the '~60%' to express
performance increased 'about' 60%, not '-60%'. This usage is unusual in
English.

> >
> > for hackbench thread testing:
> > on WSM-EP, no clear inc, NHM-EP no clear inc
> > on NHM-EX, inc 10%, core2-EP, inc ~20%.
> > on Tigertion-EX, inc 100%,
> 
> > for  netperf loopback testing, no clear performance change.
> 
> Hmmm... The sizes of the per cpu partial objects could be varied a bit to
> see if more would make an impact.


I find almost in one time my kbuilding. 
size 384, was alloced in fastpath about 2900k times
size 176, was alloced in fastpath about 1900k times
size 192, was alloced in fastpath about 500k times
anon_vma, was alloced in fastpath about 560k times 
size 72, was alloced in fastpath about 600k times 
size 512, 256, 128, was alloced in fastpath about more than 100k for
each of them.

I may give you objects size involved in my netperf testing later. 
and which test case do you prefer to? If I have, I may collection data
on them. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
