Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4CD496B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 16:22:35 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id h18so5801288igc.10
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 13:22:35 -0700 (PDT)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id x5si400339igl.25.2014.06.18.13.22.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Jun 2014 13:22:34 -0700 (PDT)
Received: by mail-ig0-f176.google.com with SMTP id c1so100677igq.3
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 13:22:34 -0700 (PDT)
Date: Wed, 18 Jun 2014 13:22:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: slab.h: wrap the whole file with guarding macro
In-Reply-To: <1403100695-1350-1-git-send-email-a.ryabinin@samsung.com>
Message-ID: <alpine.DEB.2.02.1406181321010.10339@chino.kir.corp.google.com>
References: <1403100695-1350-1-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 18 Jun 2014, Andrey Ryabinin wrote:

> Guarding section:
> 	#ifndef MM_SLAB_H
> 	#define MM_SLAB_H
> 	...
> 	#endif
> currently doesn't cover the whole mm/slab.h. It seems like it was
> done unintentionally.
> 
> Wrap the whole file by moving closing #endif to the end of it.
> 
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>

Acked-by: David Rientjes <rientjes@google.com>

Looks like

ca34956b804b ("slab: Common definition for kmem_cache_node")
e25839f67948 ("mm/slab: Sharing s_next and s_stop between slab and slub
276a2439ce79 ("mm/slab: Give s_next and s_stop slab-specific names")

added onto the header without the guard and it has been this way since 
Jan 10 2013.  Andrey, how did you notice that this was an issue?  Simply 
by visual inspection?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
