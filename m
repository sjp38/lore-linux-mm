Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 097596B0047
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 14:17:55 -0500 (EST)
Message-ID: <4B2BD55A.10404@sgi.com>
Date: Fri, 18 Dec 2009 11:17:46 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 28] Transparent Hugepage support #2
References: <patchbomb.1261076403@v2.random>	 <alpine.DEB.2.00.0912171352330.4640@router.home>	 <4B2A8D83.30305@redhat.com>	 <alpine.DEB.2.00.0912171402550.4640@router.home>	 <20091218051210.GA417@elte.hu>	 <alpine.DEB.2.00.0912181227290.26947@router.home> <1261161677.27372.1629.camel@nimitz>
In-Reply-To: <1261161677.27372.1629.camel@nimitz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>



Dave Hansen wrote:
> On Fri, 2009-12-18 at 12:28 -0600, Christoph Lameter wrote:
>> On Fri, 18 Dec 2009, Ingo Molnar wrote:
>>> Note that it became more relevant in the past few years due to the arrival of
>>> low-latency, lots-of-iops and cheap SSDs. Even on a low end server you can buy
>>> a good 160 GB SSD for emergency swap with fantastic latency and for a lot less
>>> money than 160 GB of real RAM. (which RAM wont even fit physically on typical
>>> mainboards, is much more expensive and uses up more power and is less
>>> servicable)
>> Swap occurs in page size chunks. SSDs may help but its still a desaster
>> area. You can only realistically use swap in a batch environment. It kills
>> desktop performance etc etc.
> 
> True...  Let's say it takes you down to 20% of native performance.
> There are plenty of cases where people are selling Xen or KVM slices
> where 20% of native performance is more than *fine*.  It may also let
> you have VMs that are 3x more dense than they would be able to be
> otherwise.  Yes, it kills performance, but performance isn't everything.
> 
> For many people price/performance is much more important, and swapping
> really helps the price side of that equation.
> 
> We *do* need to work on making swap more useful in a wide range of
> workloads, especially since SSDs have changed some of our assumptions
> about swap.  I just got a laptop SSD this week, and tuned swappiness so
> that I'd get some more swap activity.  Things really bogged down, so I
> *know* there's work to do there.
> 
> -- Dave

Interesting discussion about SSD's.  I was under the impression that with
the finite number of write cycles to an SSD, that unnecessary writes were
to be avoided?

	Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
