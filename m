Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C335C9000DF
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 11:21:22 -0400 (EDT)
Date: Mon, 3 Oct 2011 10:21:18 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: RE: [PATCH] slub Discard slab page only when node partials > minimum
 setting
In-Reply-To: <6E3BC7F7C9A4BF4286DD4C043110F30B5FD97584A3@shsmsx502.ccr.corp.intel.com>
Message-ID: <alpine.DEB.2.00.1110031020450.11713@router.home>
References: <1315188460.31737.5.camel@debian>  <alpine.DEB.2.00.1109061914440.18646@router.home>  <1315357399.31737.49.camel@debian>  <alpine.DEB.2.00.1109062022100.20474@router.home>  <4E671E5C.7010405@cs.helsinki.fi>
 <6E3BC7F7C9A4BF4286DD4C043110F30B5D00DA333C@shsmsx502.ccr.corp.intel.com>  <alpine.DEB.2.00.1109071003240.9406@router.home>  <1315442639.31737.224.camel@debian>  <alpine.DEB.2.00.1109081336320.14787@router.home>  <1315557944.31737.782.camel@debian>
 <1315902583.31737.848.camel@debian>  <CALmdxiMuF6Q0W4ZdvhK5c4fQs8wUjcVGWYGWBjJi7WOfLYX=Gw@mail.gmail.com>  <1316050363.8425.483.camel@debian>  <CALmdxiMrDNDvhAmi88-0-1KBdyTwExZPy3Fh9_5TxB+XhK7vjw@mail.gmail.com>  <1316052031.8425.491.camel@debian>
 <1316765880.4188.34.camel@debian>  <alpine.DEB.2.00.1109231500580.15559@router.home> <1317290032.4188.1223.camel@debian> <alpine.DEB.2.00.1109290927590.9848@router.home> <6E3BC7F7C9A4BF4286DD4C043110F30B5FD97584A3@shsmsx502.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Alex" <alex.shi@intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Chen, Tim C" <tim.c.chen@intel.com>, "Huang, Ying" <ying.huang@intel.com>, Andi Kleen <ak@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, 2 Oct 2011, Shi, Alex wrote:

> >From my viewpoint, the patch is still helpful on server machines, while no clear
> regression finding on desktop machine. So it useful.

Ok. We still have a few weeks it seems before the next merge phase.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
