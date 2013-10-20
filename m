Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8BB756B02BC
	for <linux-mm@kvack.org>; Sun, 20 Oct 2013 14:05:24 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ld10so3824106pab.10
        for <linux-mm@kvack.org>; Sun, 20 Oct 2013 11:05:24 -0700 (PDT)
Received: from psmtp.com ([74.125.245.126])
        by mx.google.com with SMTP id if1si7110698pad.291.2013.10.20.11.05.22
        for <linux-mm@kvack.org>;
        Sun, 20 Oct 2013 11:05:23 -0700 (PDT)
Date: Sun, 20 Oct 2013 18:05:21 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 13/15] slab: use struct page for slab management
In-Reply-To: <CAAmzW4PsEfGR8TMDiP4LTX7Oj3nr+F4Pxo2DyOEV4ab1pPmwkw@mail.gmail.com>
Message-ID: <00000141d70af320-21d92853-2cfb-4292-af09-dd57d406ab8b-000000@email.amazonses.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com> <1381913052-23875-14-git-send-email-iamjoonsoo.kim@lge.com> <00000141c7d66282-aa92b1f2-2a69-424b-9498-8e5367304d32-000000@email.amazonses.com>
 <CAAmzW4PsEfGR8TMDiP4LTX7Oj3nr+F4Pxo2DyOEV4ab1pPmwkw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Sat, 19 Oct 2013, JoonSoo Kim wrote:

> I search the history of struct page and find that the SLUB use mapping field
> in past (2007 year). At that time, you inserted VM_BUG_ON(PageSlab(page))
> ('b5fab14') into page_mapping() function to find remaining use. Recently,
> I never hear that this is triggered and 6 years have passed since inserting
> VM_BUG_ON(), so I guess there is no problem to use it.
> If this argument is reasonable, please give me an ACK :)
>
> Thanks.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
