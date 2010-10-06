Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 717A86B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 17:42:28 -0400 (EDT)
Date: Wed, 6 Oct 2010 16:42:24 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] SLAB: Add function to get slab cache for a page
In-Reply-To: <1286398930-11956-2-git-send-email-andi@firstfloor.org>
Message-ID: <alpine.DEB.2.00.1010061640240.8083@router.home>
References: <1286398930-11956-1-git-send-email-andi@firstfloor.org> <1286398930-11956-2-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, penberg@cs.helsinki.fi, mpm@selenic.com, Andi Kleen <ak@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 6 Oct 2010, Andi Kleen wrote:

> +struct kmem_cache *kmem_page_cache(struct page *p);

That sounds as if we do something with the page cache.

kmem_cache_of_slab_page(struct page *)

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
