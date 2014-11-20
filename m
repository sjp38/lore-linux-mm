Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id B628E6B0069
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 15:03:21 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id hn15so5409993igb.7
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 12:03:21 -0800 (PST)
Received: from resqmta-po-01v.sys.comcast.net (resqmta-po-01v.sys.comcast.net. [2001:558:fe16:19:96:114:154:160])
        by mx.google.com with ESMTPS id h10si2703738igt.36.2014.11.20.12.03.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 12:03:20 -0800 (PST)
Date: Thu, 20 Nov 2014 14:03:16 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm: sl[aou]b: introduce kmem_cache_zalloc_node()
In-Reply-To: <546DAA99.5070402@samsung.com>
Message-ID: <alpine.DEB.2.11.1411201402050.14867@gentwo.org>
References: <1415621218-6438-1-git-send-email-a.ryabinin@samsung.com> <alpine.DEB.2.10.1411191545210.32057@chino.kir.corp.google.com> <546DAA99.5070402@samsung.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>

On Thu, 20 Nov 2014, Andrey Ryabinin wrote:

> It could be used not only for irq_desc. Grepping sources gave me 7 possible users.
>
> We already have zeroing variants of kmalloc/kmalloc_node/kmem_cache_alloc,
> so why kmem_cache_alloc_node is special?

Why do we need this at all? You can always add the __GFP_ZERO flag and any
alloc function will then zero the memory for you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
