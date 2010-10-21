Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 278B75F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 16:49:14 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o9LKn9ct015320
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 13:49:10 -0700
Received: from pva18 (pva18.prod.google.com [10.241.209.18])
	by kpbe11.cbf.corp.google.com with ESMTP id o9LKlq7q020714
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 13:48:36 -0700
Received: by pva18 with SMTP id 18so23424pva.9
        for <linux-mm@kvack.org>; Thu, 21 Oct 2010 13:48:24 -0700 (PDT)
Date: Thu, 21 Oct 2010 13:48:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
In-Reply-To: <alpine.DEB.2.00.1010211326310.24115@router.home>
Message-ID: <alpine.DEB.2.00.1010211348090.17944@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1010211255570.24115@router.home> <20101021181347.GB32737@basil.fritz.box> <alpine.DEB.2.00.1010211326310.24115@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Oct 2010, Christoph Lameter wrote:

> Potential fixup....
> 
> 
> 
> Allocations to ZONE_NORMAL may fall back to ZONE_DMA and ZONE_DMA32
> so we must allow calling shrinkers for these zones as well.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

When this is folded into the parent patch:

Acked-by: David Rientjes <rientjes@google.com>

I think these changes are deserving of comments in the code, though, that 
say we don't allocate slab from highmem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
