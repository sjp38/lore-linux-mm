Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6632C6B027F
	for <linux-mm@kvack.org>; Sun, 11 Sep 2011 07:41:33 -0400 (EDT)
Date: Sun, 11 Sep 2011 06:41:28 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: RE: [PATCH] slub Discard slab page only when node partials > minimum
 setting
In-Reply-To: <1315557944.31737.782.camel@debian>
Message-ID: <alpine.DEB.2.00.1109110640240.5059@router.home>
References: <1315188460.31737.5.camel@debian>  <alpine.DEB.2.00.1109061914440.18646@router.home>  <1315357399.31737.49.camel@debian>  <alpine.DEB.2.00.1109062022100.20474@router.home>  <4E671E5C.7010405@cs.helsinki.fi>
 <6E3BC7F7C9A4BF4286DD4C043110F30B5D00DA333C@shsmsx502.ccr.corp.intel.com>  <alpine.DEB.2.00.1109071003240.9406@router.home>  <1315442639.31737.224.camel@debian>  <alpine.DEB.2.00.1109081336320.14787@router.home> <1315557944.31737.782.camel@debian>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Huang, Ying" <ying.huang@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 9 Sep 2011, Alex,Shi wrote:

> On Fri, 2011-09-09 at 02:37 +0800, Christoph Lameter wrote:
> > On Thu, 8 Sep 2011, Alex,Shi wrote:
> >
> > > BTW, some testing results for your PCP SLUB:
> > >
> > > for hackbench process testing:
> > > on WSM-EP, inc ~60%, NHM-EP inc ~25%
> > > on NHM-EX, inc ~200%, core2-EP, inc ~250%.
> > > on Tigerton-EX, inc 1900%, :)
> >
> > There is no minus on tigerton. I hope that is not a regression?
>
> Sorry for incorrect usage of '~'. I want use the '~60%' to express
> performance increased 'about' 60%, not '-60%'. This usage is unusual in
> English.

Oh its ~ not -. Did not see that on my small devices that I used at the
conference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
