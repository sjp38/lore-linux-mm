Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0A81D6B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 14:49:02 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id b1so1777657264pgc.5
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 11:49:02 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id s11si89622927pgc.259.2017.01.09.11.49.00
        for <linux-mm@kvack.org>;
        Mon, 09 Jan 2017 11:49:01 -0800 (PST)
Date: Mon, 09 Jan 2017 14:48:59 -0500 (EST)
Message-Id: <20170109.144859.1717139396935735509.davem@davemloft.net>
Subject: Re: Crash in -next due to 'mm/vmalloc: replace opencoded 4-level
 page walkers'
From: David Miller <davem@davemloft.net>
In-Reply-To: <20170109113707.GQ19067@nuc-i3427.alporthouse.com>
References: <20161028171825.GA15116@roeck-us.net>
	<20170109113707.GQ19067@nuc-i3427.alporthouse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chris@chris-wilson.co.uk
Cc: linux@roeck-us.net, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sparclinux@vger.kernel.org, linux-mm@kvack.org

From: Chris Wilson <chris@chris-wilson.co.uk>
Date: Mon, 9 Jan 2017 11:37:07 +0000

> Could some mm expert explain why it is safe for mm/vmalloc.c to ignore
> huge pud/pmd that raise BUG_ON in the same code in mm/memory.c
> (vmap_pmd_range() vs apply_to_pmd_range())?
> 
> At a guess, is sparc64 covering the init_mm with a huge zero page? How
> is it then meant to be split? Something like

We map the linear physical area (PAGE_OFFSET --> PAGE_OFFSET +
max_phys_addr) using huge pages unless DEBUG_PAGEALLOC is enabled.

It is not meant to be split, and that's why we don't use huge pages
when DEBUG_PAGEALLOC is set since that requires changes to the mapping
to be possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
