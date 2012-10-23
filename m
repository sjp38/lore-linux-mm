Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 6BCCE6B0044
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 22:29:45 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so3761281obc.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 19:29:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013a88e2e9dc-9f72abd3-9a31-454c-b70b-9937ba54c0ee-000000@email.amazonses.com>
References: <1350748093-7868-1-git-send-email-js1304@gmail.com>
	<1350748093-7868-2-git-send-email-js1304@gmail.com>
	<0000013a88e2e9dc-9f72abd3-9a31-454c-b70b-9937ba54c0ee-000000@email.amazonses.com>
Date: Tue, 23 Oct 2012 11:29:44 +0900
Message-ID: <CAAmzW4Nz_=_Tj-D=DXaO-SR5pRZ_n7-gfVbKHa+=DP0NQioAaQ@mail.gmail.com>
Subject: Re: [PATCH for-v3.7 2/2] slub: optimize kmalloc* inlining for GFP_DMA
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

2012/10/22 Christoph Lameter <cl@linux.com>:
> On Sun, 21 Oct 2012, Joonsoo Kim wrote:
>
>> kmalloc() and kmalloc_node() of the SLUB isn't inlined when @flags = __GFP_DMA.
>> This patch optimize this case,
>> so when @flags = __GFP_DMA, it will be inlined into generic code.
>
> __GFP_DMA is a rarely used flag for kmalloc allocators and so far it was
> not considered that it is worth to directly support it in the inlining
> code.
>
>

Hmm... but, the SLAB already did that optimization for __GFP_DMA.
Almost every kmalloc() is invoked with constant flags value,
so I think that overhead from this patch may be negligible.
With this patch, code size of vmlinux is reduced slightly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
