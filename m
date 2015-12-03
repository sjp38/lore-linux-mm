Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 065536B0255
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 09:48:03 -0500 (EST)
Received: by igcph11 with SMTP id ph11so12215005igc.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 06:48:02 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id p133si6048143iop.15.2015.12.03.06.48.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 03 Dec 2015 06:48:02 -0800 (PST)
Date: Thu, 3 Dec 2015 08:48:01 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slab.c: add a helper function get_first_slab
In-Reply-To: <ca810706dcf5cb70ecd3602faa022fc0c9de2487.1449151885.git.geliangtang@163.com>
Message-ID: <alpine.DEB.2.20.1512030847330.7483@east.gentwo.org>
References: <ca810706dcf5cb70ecd3602faa022fc0c9de2487.1449151885.git.geliangtang@163.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@163.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 3 Dec 2015, Geliang Tang wrote:

> Add a new helper function get_first_slab() that get the first slab
> from a kmem_cache_node.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
