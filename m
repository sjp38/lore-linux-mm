Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DA63C900137
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 04:23:47 -0400 (EDT)
Subject: RE: [PATCH] slub Discard slab page only when node partials >
 minimum setting
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <1315557944.31737.782.camel@debian>
References: <1315188460.31737.5.camel@debian>
	 <alpine.DEB.2.00.1109061914440.18646@router.home>
	 <1315357399.31737.49.camel@debian>
	 <alpine.DEB.2.00.1109062022100.20474@router.home>
	 <4E671E5C.7010405@cs.helsinki.fi>
	 <6E3BC7F7C9A4BF4286DD4C043110F30B5D00DA333C@shsmsx502.ccr.corp.intel.com>
	 <alpine.DEB.2.00.1109071003240.9406@router.home>
	 <1315442639.31737.224.camel@debian>
	 <alpine.DEB.2.00.1109081336320.14787@router.home>
	 <1315557944.31737.782.camel@debian>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 13 Sep 2011 16:29:43 +0800
Message-ID: <1315902583.31737.848.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Huang, Ying" <ying.huang@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>


> > Hmmm... The sizes of the per cpu partial objects could be varied a bit to
> > see if more would make an impact.
> 
> 
> I find almost in one time my kbuilding. 
> size 384, was alloced in fastpath about 2900k times
> size 176, was alloced in fastpath about 1900k times
> size 192, was alloced in fastpath about 500k times
> anon_vma, was alloced in fastpath about 560k times 
> size 72, was alloced in fastpath about 600k times 
> size 512, 256, 128, was alloced in fastpath about more than 100k for
> each of them.
> 
> I may give you objects size involved in my netperf testing later. 
> and which test case do you prefer to? If I have, I may collection data
> on them. 

I write a short script to collect different size object usage of
alloc_fastpath.  The output is following, first column is the object
name and second is the alloc_fastpath called times.

:t-0000448 62693419
:t-0000384 1037746
:at-0000104 191787
:t-0000176 2051053
anon_vma 953578
:t-0000048 2108191
:t-0008192 17858636
:t-0004096 2307039
:t-0002048 21601441
:t-0001024 98409238
:t-0000512 14896189
:t-0000256 96731409
:t-0000128 221045
:t-0000064 149505
:t-0000032 638431
:t-0000192 263488
-----

Above output shows size 448/8192/2048/512/256 are used much. 

So at least both kbuild(with 4 jobs) and netperf loopback (one server on
CPU socket 1, and one client on CPU socket 2) testing have no clear
performance change on our machine
NHM-EP/NHM-EX/WSM-EP/tigerton/core2-EP. 





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
