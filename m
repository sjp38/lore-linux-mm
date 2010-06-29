Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 73F7F600227
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 12:23:00 -0400 (EDT)
Date: Tue, 29 Jun 2010 10:41:59 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q 08/16] slub: remove dynamic dma slab allocation
In-Reply-To: <20100628113308.a9b6e834.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006291039260.16135@router.home>
References: <20100625212026.810557229@quilx.com> <20100625212105.765531312@quilx.com> <20100628113308.a9b6e834.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jun 2010, KAMEZAWA Hiroyuki wrote:

> Uh...I think just using GFP_KERNEL drops too much
> requests-from-user-via-gfp_mask.

Sorry I do not understand what the issue is? The dma slabs are allocated
while user space is not active yet.

Please do not quote diff hunks that you do not comment on. I am on a slow
link (vacation) and its awkward to check for comments...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
