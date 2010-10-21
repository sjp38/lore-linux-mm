Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 682F55F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 16:36:56 -0400 (EDT)
Date: Thu, 21 Oct 2010 13:36:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
Message-Id: <20101021133636.68979e37.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1010211527050.32674@router.home>
References: <alpine.DEB.2.00.1010211255570.24115@router.home>
	<20101021124054.14b85e50.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1010211455100.30295@router.home>
	<20101021131428.f2f7214a.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1010211527050.32674@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Oct 2010 15:28:35 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Thu, 21 Oct 2010, Andrew Morton wrote:
> 
> > The patch changes balance_pgdat() to not shrink slab when inspecting
> > the highmem zone.  It will therefore change zone balancing behaviour on
> > a humble 1G laptop, will it not?
> 
> It will avoid a slab shrink call on the HIGHMEM zone that will put useless
> pressure on the cache objects in ZONE_NORMAL and ZONE_DMA. There will have
> been already shrinker calls for ZONE_DMA and ZONE_NORMAL before. This is
> going to be the third round....
> 

Right, it changes behaviour for modest machines.  Apparently accidentally.

Is the new behaviour better, or worse?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
