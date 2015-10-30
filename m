Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id CDF4482F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 04:23:42 -0400 (EDT)
Received: by lbbec13 with SMTP id ec13so45865764lbb.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 01:23:41 -0700 (PDT)
Received: from mail-lb0-x235.google.com (mail-lb0-x235.google.com. [2a00:1450:4010:c04::235])
        by mx.google.com with ESMTPS id l3si4034198lfb.29.2015.10.30.01.23.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 01:23:41 -0700 (PDT)
Received: by lbbec13 with SMTP id ec13so45865562lbb.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 01:23:41 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm, kasan: Added GFP flags to KASAN API
References: <1446050357-40105-1-git-send-email-glider@google.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <56332924.20107@gmail.com>
Date: Fri, 30 Oct 2015 11:24:04 +0300
MIME-Version: 1.0
In-Reply-To: <1446050357-40105-1-git-send-email-glider@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/28/2015 07:39 PM, Alexander Potapenko wrote:
> Add GFP flags to KASAN hooks for future patches to use.

Really? These flags are still not used in the next patch (unless I missed something).

> This is the first part of the "mm: kasan: unified support for SLUB and
> SLAB allocators" patch originally prepared by Dmitry Chernenkov.
> 
> Signed-off-by: Dmitry Chernenkov <dmitryc@google.com>
> Signed-off-by: Alexander Potapenko <glider@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
