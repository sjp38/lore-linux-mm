Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id E10A56B0092
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 03:01:36 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id p5so1267791lag.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 00:01:35 -0800 (PST)
Date: Thu, 15 Nov 2012 10:01:33 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH] mm: fix slab.c kernel-doc warnings
In-Reply-To: <5099B4F2.2090602@infradead.org>
Message-ID: <alpine.LFD.2.02.1211151001230.2386@tux.localdomain>
References: <5099B4F2.2090602@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>

On Tue, 6 Nov 2012, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix new kernel-doc warnings in mm/slab.c:
> 
> Warning(mm/slab.c:2358): No description found for parameter 'cachep'
> Warning(mm/slab.c:2358): Excess function parameter 'name' description in '__kmem_cache_create'
> Warning(mm/slab.c:2358): Excess function parameter 'size' description in '__kmem_cache_create'
> Warning(mm/slab.c:2358): Excess function parameter 'align' description in '__kmem_cache_create'
> Warning(mm/slab.c:2358): Excess function parameter 'ctor' description in '__kmem_cache_create'
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> Cc:	Christoph Lameter <cl@linux-foundation.org>
> Cc:	Pekka Enberg <penberg@kernel.org>
> Cc:	Matt Mackall <mpm@selenic.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
