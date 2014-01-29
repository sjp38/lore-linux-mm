Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id B1E676B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 00:02:41 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id x10so1239958pdj.36
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 21:02:41 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id sz7si1038693pab.116.2014.01.28.21.02.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 21:02:40 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so1287882pab.5
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 21:02:40 -0800 (PST)
Date: Tue, 28 Jan 2014 21:02:36 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH] mm: sl[uo]b: fix misleading comments
In-Reply-To: <20140128222450.0B32C3FD@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.02.1401282102240.20167@chino.kir.corp.google.com>
References: <20140128222450.0B32C3FD@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, akpm@linux-foundation.org

On Tue, 28 Jan 2014, Dave Hansen wrote:

> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> On x86, SLUB creates and handles <=8192-byte allocations internally.
> It passes larger ones up to the allocator.  Saying "up to order 2" is,
> at best, ambiguous.  Is that order-1?  Or (order-2 bytes)?  Make
> it more clear.
> 
> SLOB commits a similar sin.  It *handles* page-size requests, but the
> comment says that it passes up "all page size and larger requests".
> 
> SLOB also swaps around the order of the very-similarly-named
> KMALLOC_SHIFT_HIGH and KMALLOC_SHIFT_MAX #defines.  Make it
> consistent with the order of the other two allocators.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
