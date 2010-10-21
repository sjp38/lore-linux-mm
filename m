Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 56FB05F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 16:54:16 -0400 (EDT)
Date: Thu, 21 Oct 2010 15:54:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
In-Reply-To: <alpine.DEB.2.00.1010211348090.17944@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1010211553280.32674@router.home>
References: <alpine.DEB.2.00.1010211255570.24115@router.home> <20101021181347.GB32737@basil.fritz.box> <alpine.DEB.2.00.1010211326310.24115@router.home> <alpine.DEB.2.00.1010211348090.17944@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Oct 2010, David Rientjes wrote:

> I think these changes are deserving of comments in the code, though, that
> say we don't allocate slab from highmem.

I am not that satisfied yet. I think we should only have one call per
pgdat. Not one per zone in pgdat all operating on the same data again and
again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
