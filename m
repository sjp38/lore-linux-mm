Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id EA71A6B005A
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 05:02:11 -0400 (EDT)
Message-ID: <4A7A9C0E.6010308@cs.helsinki.fi>
Date: Thu, 06 Aug 2009 12:02:06 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] slab: remove duplicate kmem_cache_init_late() declarations
References: <20090806022704.GA17337@localhost> <20090805211727.cd4ccedd.akpm@linux-foundation.org> <20090806053153.GA13960@localhost>
In-Reply-To: <20090806053153.GA13960@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:
> Right. It seems someone recently moved the declaration from slab_def.h
> to slab.h, so the replacement patch is a bit smaller:
> 
> ---
> slab: remove duplicate kmem_cache_init_late() declarations
> 
> kmem_cache_init_late() has been declared in slab.h
> 
> CC: Nick Piggin <npiggin@suse.de>
> CC: Matt Mackall <mpm@selenic.com>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>
> CC: Christoph Lameter <cl@linux-foundation.org>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
