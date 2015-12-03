Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 934366B0253
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 16:02:27 -0500 (EST)
Received: by padhx2 with SMTP id hx2so74965925pad.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 13:02:27 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id ry10si14149164pac.49.2015.12.03.13.02.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 13:02:26 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so74761096pac.3
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 13:02:26 -0800 (PST)
Date: Thu, 3 Dec 2015 13:02:24 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/slab.c: add a helper function get_first_slab
In-Reply-To: <ca810706dcf5cb70ecd3602faa022fc0c9de2487.1449151885.git.geliangtang@163.com>
Message-ID: <alpine.DEB.2.10.1512031301590.10229@chino.kir.corp.google.com>
References: <ca810706dcf5cb70ecd3602faa022fc0c9de2487.1449151885.git.geliangtang@163.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 3 Dec 2015, Geliang Tang wrote:

> Add a new helper function get_first_slab() that get the first slab
> from a kmem_cache_node.
> 
> Signed-off-by: Geliang Tang <geliangtang@163.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
