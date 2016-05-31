Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D0236B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 07:52:09 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id h5so33216722ioh.1
        for <linux-mm@kvack.org>; Tue, 31 May 2016 04:52:09 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0108.outbound.protection.outlook.com. [157.56.112.108])
        by mx.google.com with ESMTPS id n3si2210603oia.131.2016.05.31.04.52.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 31 May 2016 04:52:07 -0700 (PDT)
Subject: Re: [PATCH] mm, kasan: introduce a special shadow value for allocator
 metadata
References: <1464691466-59010-1-git-send-email-glider@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <574D7B11.8090709@virtuozzo.com>
Date: Tue, 31 May 2016 14:52:49 +0300
MIME-Version: 1.0
In-Reply-To: <1464691466-59010-1-git-send-email-glider@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 05/31/2016 01:44 PM, Alexander Potapenko wrote:
> Add a special shadow value to distinguish accesses to KASAN-specific
> allocator metadata.
> 
> Unlike AddressSanitizer in the userspace, KASAN lets the kernel proceed
> after a memory error. However a write to the kmalloc metadata may cause
> memory corruptions that will make the tool itself unreliable and induce
> crashes later on. Warning about such corruptions will ease the
> debugging.

It will not. Whether out-of-bounds hits metadata or not is absolutely irrelevant
to the bug itself. This information doesn't help to understand, analyze or fix the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
