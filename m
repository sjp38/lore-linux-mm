Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 668546B0035
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 19:10:03 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so23507655pdj.28
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 16:10:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cp3si6031288pdb.255.2014.08.26.16.10.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Aug 2014 16:10:02 -0700 (PDT)
Date: Tue, 26 Aug 2014 16:10:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] ARM: Remove lowmem limit for default CMA region
Message-Id: <20140826161000.c760fadf0d7223372524d2ce@linux-foundation.org>
In-Reply-To: <1408610714-16204-1-git-send-email-m.szyprowski@samsung.com>
References: <1408610714-16204-1-git-send-email-m.szyprowski@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, 21 Aug 2014 10:45:12 +0200 Marek Szyprowski <m.szyprowski@samsung.com> wrote:

> Russell King recently noticed that limiting default CMA region only to
> low memory on ARM architecture causes serious memory management issues
> with machines having a lot of memory (which is mainly available as high
> memory). More information can be found the following thread:
> http://thread.gmane.org/gmane.linux.ports.arm.kernel/348441/
> 
> Those two patches removes this limit letting kernel to put default CMA
> region into high memory when this is possible (there is enough high
> memory available and architecture specific DMA limit fits).
> 
> This should solve strange OOM issues on systems with lots of RAM
> (i.e. >1GiB) and large (>256M) CMA area.

What do we think is the priority on these fixes?  3.17 or 3.18?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
