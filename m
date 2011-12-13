Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 7708F6B0272
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 11:15:29 -0500 (EST)
Date: Tue, 13 Dec 2011 10:15:27 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slab: too much allocated in bootstrap head arrays?
In-Reply-To: <4EE67D35.5000307@gmail.com>
Message-ID: <alpine.DEB.2.00.1112131013310.23111@router.home>
References: <4EE67D35.5000307@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: roel <roel.kluin@gmail.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 12 Dec 2011, roel wrote:

> In mm/slab.c kmem_cache_init() at /* 4) Replace the bootstrap head arrays */
> it kmallocs *ptr and memcpy's with sizeof(struct arraycache_init). Is this
> correct or should it maybe be with sizeof(struct arraycache) instead?

Allocating with sizeof(struct arraycache) will only allocate the header of
the array cache and not reserve space for the pointers that are part of
it. It is always wrong.

Look at alloc_arraycache() for the proper way to use struct arraycache to
calculate the number of bytes needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
