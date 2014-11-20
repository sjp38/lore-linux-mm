Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id EDA2A6B0069
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 17:31:08 -0500 (EST)
Received: by mail-ie0-f175.google.com with SMTP id at20so3682051iec.6
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 14:31:08 -0800 (PST)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id c3si4285475igg.9.2014.11.20.14.31.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 14:31:07 -0800 (PST)
Received: by mail-ig0-f170.google.com with SMTP id r2so618125igi.3
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 14:31:07 -0800 (PST)
Date: Thu, 20 Nov 2014 14:31:05 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] mm: sl[aou]b: introduce kmem_cache_zalloc_node()
In-Reply-To: <546DAA99.5070402@samsung.com>
Message-ID: <alpine.DEB.2.10.1411201430220.30354@chino.kir.corp.google.com>
References: <1415621218-6438-1-git-send-email-a.ryabinin@samsung.com> <alpine.DEB.2.10.1411191545210.32057@chino.kir.corp.google.com> <546DAA99.5070402@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>

On Thu, 20 Nov 2014, Andrey Ryabinin wrote:

> > Is there a reason to add this for such a specialized purpose to the slab 
> > allocator?  I think it can just be handled for struct irq_desc explicitly.
> > 
> 
> It could be used not only for irq_desc. Grepping sources gave me 7 possible users.
> 

It would be best to follow in the example of those users and just use 
__GFP_ZERO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
