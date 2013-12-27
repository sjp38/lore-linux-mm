Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 331B96B0031
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 13:48:18 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id w7so8994367qcr.11
        for <linux-mm@kvack.org>; Fri, 27 Dec 2013 10:48:17 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id j7si29345124qab.151.2013.12.27.10.48.16
        for <linux-mm@kvack.org>;
        Fri, 27 Dec 2013 10:48:17 -0800 (PST)
Date: Fri, 27 Dec 2013 13:48:14 -0500 (EST)
Message-Id: <20131227.134814.345379118522548543.davem@davemloft.net>
Subject: Re: [PATCH] remap_file_pages needs to check for cache coherency
From: David Miller <davem@davemloft.net>
In-Reply-To: <20131227180018.GC4945@linux.intel.com>
References: <20131227180018.GC4945@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@linux.intel.com
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-parisc@vger.kernel.org, linux-mips@linux-mips.org

From: Matthew Wilcox <willy@linux.intel.com>
Date: Fri, 27 Dec 2013 13:00:18 -0500

> It seems to me that while (for example) on SPARC, it's not possible to
> create a non-coherent mapping with mmap(), after we've done an mmap,
> we can then use remap_file_pages() to create a mapping that no longer
> aliases in the D-cache.
> 
> I have only compile-tested this patch.  I don't have any SPARC hardware,
> and my PA-RISC hardware hasn't been turned on in six years ... I noticed
> this while wandering around looking at some other stuff.

I suppose this is needed, but only in the case where the mapping is
shared and writable, right?  I don't see you testing those conditions,
but with them I'd be OK with this change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
