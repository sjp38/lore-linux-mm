Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 13DC6280042
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 11:58:02 -0400 (EDT)
Received: by mail-ie0-f176.google.com with SMTP id rd18so1536048iec.35
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 08:58:01 -0700 (PDT)
Received: from resqmta-po-10v.sys.comcast.net (resqmta-po-10v.sys.comcast.net. [2001:558:fe16:19:96:114:154:169])
        by mx.google.com with ESMTPS id 201si821733iof.10.2014.10.31.08.58.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 31 Oct 2014 08:58:01 -0700 (PDT)
Date: Fri, 31 Oct 2014 10:17:16 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH for v3.18] mm/slab: fix unalignment problem on Malta with
 EVA due to slab merge
In-Reply-To: <1414742912-14852-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.11.1410311015490.14859@gentwo.org>
References: <1414742912-14852-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Markos Chandras <Markos.Chandras@imgtec.com>, linux-mips@linux-mips.org

On Fri, 31 Oct 2014, Joonsoo Kim wrote:

> alloc_unbound_pwq() allocates slab object from pool_workqueue. This
> kmem_cache requires 256 bytes alignment, but, current merging code
> doesn't honor that, and merge it with kmalloc-256. kmalloc-256 requires
> only cacheline size alignment so that above failure occurs. However,
> in x86, kmalloc-256 is luckily aligned in 256 bytes, so the problem
> didn't happen on it.

That luck will run out when you enable debugging. But then that also
usually means disablign merging.

> To fix this problem, this patch introduces alignment mismatch check
> in find_mergeable(). This will fix the problem.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
