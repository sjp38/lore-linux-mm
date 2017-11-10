Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0F3280278
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 04:08:20 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id t139so299703wmt.7
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 01:08:20 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id s77si860314wmd.222.2017.11.10.01.08.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 01:08:19 -0800 (PST)
Date: Fri, 10 Nov 2017 10:08:18 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 14/15] dax: associate mappings with inodes, and warn if
	dma collides with truncate
Message-ID: <20171110090818.GE4895@lst.de>
References: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com> <150949217152.24061.9869502311102659784.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150949217152.24061.9869502311102659784.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, hch@lst.de

> +		struct {
> +			/*
> +			 * ZONE_DEVICE pages are never on an lru or handled by
> +			 * a slab allocator, this points to the hosting device
> +			 * page map.
> +			 */
> +			struct dev_pagemap *pgmap;
> +			/*
> +			 * inode association for MEMORY_DEVICE_FS_DAX page-idle
> +			 * callbacks. Note that we don't use ->mapping since
> +			 * that has hard coded page-cache assumptions in
> +			 * several paths.
> +			 */

What assumptions?  I'd much rather fix those up than having two fields
that have the same functionality.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
