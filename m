Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1724E6B004A
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 16:28:40 -0400 (EDT)
Date: Thu, 21 Oct 2010 15:28:35 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
In-Reply-To: <20101021131428.f2f7214a.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1010211527050.32674@router.home>
References: <alpine.DEB.2.00.1010211255570.24115@router.home> <20101021124054.14b85e50.akpm@linux-foundation.org> <alpine.DEB.2.00.1010211455100.30295@router.home> <20101021131428.f2f7214a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Oct 2010, Andrew Morton wrote:

> The patch changes balance_pgdat() to not shrink slab when inspecting
> the highmem zone.  It will therefore change zone balancing behaviour on
> a humble 1G laptop, will it not?

It will avoid a slab shrink call on the HIGHMEM zone that will put useless
pressure on the cache objects in ZONE_NORMAL and ZONE_DMA. There will have
been already shrinker calls for ZONE_DMA and ZONE_NORMAL before. This is
going to be the third round....


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
