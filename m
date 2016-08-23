Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B45166B0069
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 04:04:07 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 63so244265508pfx.0
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 01:04:07 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 19si2744649pft.165.2016.08.23.01.04.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 01:04:06 -0700 (PDT)
Message-ID: <1471939443.3696.2.camel@linux.intel.com>
Subject: Re: [PATCH] io-mapping.h: s/PAGE_KERNEL_IO/PAGE_KERNEL/
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Date: Tue, 23 Aug 2016 11:04:03 +0300
In-Reply-To: <20160823072253.26977-1-chris@chris-wilson.co.uk>
References: <20160823072253.26977-1-chris@chris-wilson.co.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, linux-mm@kvack.org

On ti, 2016-08-23 at 08:22 +0100, Chris Wilson wrote:
> PAGE_KERNEL_IO is an x86-ism. Though it is used to define the pgprot_t
> used for the iomapped region, it itself is just PAGE_KERNEL. On all
> other arches, PAGE_KERNEL_IO is undefined so in a general header we must
> refrain from using it.
> 

There is;

#define __PAGE_KERNEL_IOA A A A A A A A A A A (__PAGE_KERNEL)

So no functional change, but will compile on all archs.

Reviewed-by: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>

Regards, Joonas
-- 
Joonas Lahtinen
Open Source Technology Center
Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
