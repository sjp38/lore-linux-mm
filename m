Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A75306B0003
	for <linux-mm@kvack.org>; Wed, 23 May 2018 15:51:22 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id e18-v6so7039360pgt.3
        for <linux-mm@kvack.org>; Wed, 23 May 2018 12:51:22 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z2-v6si18806915plk.184.2018.05.23.12.51.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 12:51:21 -0700 (PDT)
Date: Wed, 23 May 2018 12:51:19 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v1 10/10] mm/memory_hotplug: allow online/offline memory
 by a kernel module
Message-ID: <20180523195119.GA20852@infradead.org>
References: <20180523151151.6730-1-david@redhat.com>
 <20180523151151.6730-11-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523151151.6730-11-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Thomas Gleixner <tglx@linutronix.de>

On Wed, May 23, 2018 at 05:11:51PM +0200, David Hildenbrand wrote:
> Kernel modules that want to control how/when memory is onlined/offlined
> need a proper interface to these functions. Also, for adding memory
> properly, memory_block_size_bytes is required.

Which module?  Please send it along with the enabling code.

> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -88,6 +88,7 @@ unsigned long __weak memory_block_size_bytes(void)
>  {
>  	return MIN_MEMORY_BLOCK_SIZE;
>  }
> +EXPORT_SYMBOL(memory_block_size_bytes);

> +EXPORT_SYMBOL(mem_hotplug_begin);

> +EXPORT_SYMBOL(mem_hotplug_done);

EXPORT_SYMBOL_GPL for any deep down VM internals, please.
