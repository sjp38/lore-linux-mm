Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id EF4F06B0168
	for <linux-mm@kvack.org>; Fri, 18 Oct 2013 11:19:54 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so3940285pbb.20
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 08:19:54 -0700 (PDT)
Received: from psmtp.com ([74.125.245.194])
        by mx.google.com with SMTP id u9si1133345pbf.233.2013.10.18.08.13.36
        for <linux-mm@kvack.org>;
        Fri, 18 Oct 2013 08:13:37 -0700 (PDT)
Received: by mail-wg0-f44.google.com with SMTP id n12so3902697wgh.35
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 08:13:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <00000141c7d1fae0-ff132cb2-5485-4b8f-9b22-d4da27068681-000000@email.amazonses.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1381913052-23875-9-git-send-email-iamjoonsoo.kim@lge.com>
	<00000141c7d1fae0-ff132cb2-5485-4b8f-9b22-d4da27068681-000000@email.amazonses.com>
Date: Sat, 19 Oct 2013 00:13:34 +0900
Message-ID: <CAAmzW4PXifdn9YKG0YNmbS_Zn6-DsTqAiT5=_up2+jzTpz=8bw@mail.gmail.com>
Subject: Re: [PATCH v2 08/15] slab: use __GFP_COMP flag for allocating slab pages
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

2013/10/18 Christoph Lameter <cl@linux.com>:
> On Wed, 16 Oct 2013, Joonsoo Kim wrote:
>
>> If we use 'struct page' of first page as 'struct slab', there is no
>> advantage not to use __GFP_COMP. So use __GFP_COMP flag for all the cases.
>
> Yes this is going to make the allocators behave in the same way. We could
> actually put some of the page allocator related functionality in
> slab_common.c

Okay. After merging this, I will try to clean-up that.

> Acked-by: Christoph Lameter <cl@linux.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
