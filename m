Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id D2C31280037
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 11:15:14 -0400 (EDT)
Received: by mail-yh0-f52.google.com with SMTP id a41so2792996yho.11
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 08:15:14 -0700 (PDT)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id q6si2474513qas.32.2014.10.31.08.15.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 31 Oct 2014 08:15:13 -0700 (PDT)
Date: Fri, 31 Oct 2014 10:15:11 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slab: reverse iteration on find_mergeable()
In-Reply-To: <1414742954-14889-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.11.1410311014570.14859@gentwo.org>
References: <1414742954-14889-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Markos Chandras <Markos.Chandras@imgtec.com>

On Fri, 31 Oct 2014, Joonsoo Kim wrote:

> To prevent this situation, this patch reverses iteration order in
> find_mergeable() to find frequently used kmem_caches. This change
> helps to merge kmem_cache to frequently used kmem_caches, such as
> kmalloc kmem_caches.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
