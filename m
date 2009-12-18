Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BA3F66B0047
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 00:12:45 -0500 (EST)
Date: Fri, 18 Dec 2009 06:12:10 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00 of 28] Transparent Hugepage support #2
Message-ID: <20091218051210.GA417@elte.hu>
References: <patchbomb.1261076403@v2.random>
 <alpine.DEB.2.00.0912171352330.4640@router.home>
 <4B2A8D83.30305@redhat.com>
 <alpine.DEB.2.00.0912171402550.4640@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0912171402550.4640@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>


* Christoph Lameter <cl@linux-foundation.org> wrote:

> On Thu, 17 Dec 2009, Rik van Riel wrote:
> 
> > I believe it will be more useful if we figure out a way forward together.  
> > Do you have any ideas on how to solve the hugepage swapping problem?
> 
> Frankly I am not sure that there is a problem. The word swap is mostly 
> synonymous with "problem". Huge pages are good. I dont think one needs to 
> necessarily associate something good (huge page) with a known problem (swap) 
> otherwise the whole may not improve.

Swapping in the VM is 'reality', not some fringe feature. Almost every big 
enterprise shop cares about it.

Note that it became more relevant in the past few years due to the arrival of 
low-latency, lots-of-iops and cheap SSDs. Even on a low end server you can buy 
a good 160 GB SSD for emergency swap with fantastic latency and for a lot less 
money than 160 GB of real RAM. (which RAM wont even fit physically on typical 
mainboards, is much more expensive and uses up more power and is less 
servicable)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
