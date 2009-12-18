Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F3A116B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 13:41:46 -0500 (EST)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nBIIaAto009802
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 13:36:10 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBIIfMxi1802338
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 13:41:22 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBIIfLFW022105
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 16:41:22 -0200
Subject: Re: [PATCH 00 of 28] Transparent Hugepage support #2
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.0912181227290.26947@router.home>
References: <patchbomb.1261076403@v2.random>
	 <alpine.DEB.2.00.0912171352330.4640@router.home>
	 <4B2A8D83.30305@redhat.com>
	 <alpine.DEB.2.00.0912171402550.4640@router.home>
	 <20091218051210.GA417@elte.hu>
	 <alpine.DEB.2.00.0912181227290.26947@router.home>
Content-Type: text/plain
Date: Fri, 18 Dec 2009 10:41:17 -0800
Message-Id: <1261161677.27372.1629.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-12-18 at 12:28 -0600, Christoph Lameter wrote:
> On Fri, 18 Dec 2009, Ingo Molnar wrote:
> > Note that it became more relevant in the past few years due to the arrival of
> > low-latency, lots-of-iops and cheap SSDs. Even on a low end server you can buy
> > a good 160 GB SSD for emergency swap with fantastic latency and for a lot less
> > money than 160 GB of real RAM. (which RAM wont even fit physically on typical
> > mainboards, is much more expensive and uses up more power and is less
> > servicable)
> 
> Swap occurs in page size chunks. SSDs may help but its still a desaster
> area. You can only realistically use swap in a batch environment. It kills
> desktop performance etc etc.

True...  Let's say it takes you down to 20% of native performance.
There are plenty of cases where people are selling Xen or KVM slices
where 20% of native performance is more than *fine*.  It may also let
you have VMs that are 3x more dense than they would be able to be
otherwise.  Yes, it kills performance, but performance isn't everything.

For many people price/performance is much more important, and swapping
really helps the price side of that equation.

We *do* need to work on making swap more useful in a wide range of
workloads, especially since SSDs have changed some of our assumptions
about swap.  I just got a laptop SSD this week, and tuned swappiness so
that I'd get some more swap activity.  Things really bogged down, so I
*know* there's work to do there.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
