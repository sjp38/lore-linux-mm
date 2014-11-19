Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 187986B0088
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 18:46:07 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id hl2so3813579igb.17
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 15:46:06 -0800 (PST)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id qo8si2209101igb.51.2014.11.19.15.46.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Nov 2014 15:46:06 -0800 (PST)
Received: by mail-ig0-f174.google.com with SMTP id hn15so3864809igb.1
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 15:46:05 -0800 (PST)
Date: Wed, 19 Nov 2014 15:46:03 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] mm: sl[aou]b: introduce kmem_cache_zalloc_node()
In-Reply-To: <1415621218-6438-1-git-send-email-a.ryabinin@samsung.com>
Message-ID: <alpine.DEB.2.10.1411191545210.32057@chino.kir.corp.google.com>
References: <1415621218-6438-1-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>

On Mon, 10 Nov 2014, Andrey Ryabinin wrote:

> kmem_cache_zalloc_node() allocates zeroed memory for a particular
> cache from a specified memory node. To be used for struct irq_desc.
> 

Is there a reason to add this for such a specialized purpose to the slab 
allocator?  I think it can just be handled for struct irq_desc explicitly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
