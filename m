Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A9C316B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 13:13:01 -0400 (EDT)
Date: Mon, 10 Oct 2011 12:12:57 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: RE: [PATCH] slub Discard slab page only when node partials > minimum
 setting
In-Reply-To: <1318141715.27949.144.camel@debian>
Message-ID: <alpine.DEB.2.00.1110101212010.18349@router.home>
References: <1315188460.31737.5.camel@debian>  <alpine.DEB.2.00.1109061914440.18646@router.home>  <1315357399.31737.49.camel@debian>  <alpine.DEB.2.00.1109062022100.20474@router.home>  <4E671E5C.7010405@cs.helsinki.fi>
 <6E3BC7F7C9A4BF4286DD4C043110F30B5D00DA333C@shsmsx502.ccr.corp.intel.com>  <alpine.DEB.2.00.1109071003240.9406@router.home>  <1315442639.31737.224.camel@debian>  <alpine.DEB.2.00.1109081336320.14787@router.home>  <1315557944.31737.782.camel@debian>
 <1316765880.4188.34.camel@debian>  <alpine.DEB.2.00.1109231500580.15559@router.home>  <1317290032.4188.1223.camel@debian>  <alpine.DEB.2.00.1109290927590.9848@router.home>  <6E3BC7F7C9A4BF4286DD4C043110F30B5FD97584A3@shsmsx502.ccr.corp.intel.com>
 <alpine.DEB.2.00.1110031020450.11713@router.home> <1318141715.27949.144.camel@debian>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Chen, Tim C" <tim.c.chen@intel.com>, "Huang, Ying" <ying.huang@intel.com>, Andi Kleen <ak@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, 9 Oct 2011, Alex,Shi wrote:

> I tested multi-threads loopback netperf on our machines, no clear
> regression or improvement find on our NHM-EP/NHM-EX/WSM-EP machine.

What are your criteria for a regressio?

> but on our 4 sockets tigerton machine with 2048 clients, performance
> increase 20% for TCP_RR subcase, and 10% for TCP_STREAM32 subcase;
> and on our 2 sockets harpertown machine, the TCP_RR subcase increase
> 15%.
>
> The data is quite good!

Sounds encouraging.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
