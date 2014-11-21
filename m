Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id BA65C6B0071
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 04:57:29 -0500 (EST)
Received: by mail-ie0-f172.google.com with SMTP id ar1so4615750iec.3
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 01:57:29 -0800 (PST)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com. [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id sb4si5229849igb.38.2014.11.21.01.57.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Nov 2014 01:57:28 -0800 (PST)
Received: by mail-ie0-f177.google.com with SMTP id rd18so4375816iec.8
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 01:57:28 -0800 (PST)
Date: Fri, 21 Nov 2014 01:57:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] mm: sl[aou]b: introduce kmem_cache_zalloc_node()
In-Reply-To: <546EDBE0.10103@samsung.com>
Message-ID: <alpine.DEB.2.10.1411210156570.32133@chino.kir.corp.google.com>
References: <1415621218-6438-1-git-send-email-a.ryabinin@samsung.com> <alpine.DEB.2.10.1411191545210.32057@chino.kir.corp.google.com> <546DAA99.5070402@samsung.com> <alpine.DEB.2.10.1411201430220.30354@chino.kir.corp.google.com>
 <546EDBE0.10103@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>

On Fri, 21 Nov 2014, Andrey Ryabinin wrote:

> On 11/21/2014 01:31 AM, David Rientjes wrote:
> > On Thu, 20 Nov 2014, Andrey Ryabinin wrote:
> > 
> >>> Is there a reason to add this for such a specialized purpose to the slab 
> >>> allocator?  I think it can just be handled for struct irq_desc explicitly.
> >>>
> >>
> >> It could be used not only for irq_desc. Grepping sources gave me 7 possible users.
> >>
> > 
> > It would be best to follow in the example of those users and just use 
> > __GFP_ZERO.
> > 
> 
> Fair enough.
> 

Thanks, and feel free to add my

	Acked-by: David Rientjes <rientjes@google.com.

on the other two patches once they are refreshed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
