Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id E9AFD6B0255
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 12:48:44 -0500 (EST)
Received: by igcmv3 with SMTP id mv3so129196460igc.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 09:48:44 -0800 (PST)
Received: from quartz.orcorp.ca (quartz.orcorp.ca. [184.70.90.242])
        by mx.google.com with ESMTPS id 144si13978368iob.145.2015.12.09.09.48.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 09:48:43 -0800 (PST)
Date: Wed, 9 Dec 2015 10:48:31 -0700
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC contig pages support 1/2] IB: Supports contiguous memory
 operations
Message-ID: <20151209174831.GC31636@obsidianresearch.com>
References: <1449587707-24214-1-git-send-email-yishaih@mellanox.com>
 <1449587707-24214-2-git-send-email-yishaih@mellanox.com>
 <20151208151852.GA6688@infradead.org>
 <20151208171542.GB13549@obsidianresearch.com>
 <AM4PR05MB146005B448BEA876519335CDDCE80@AM4PR05MB1460.eurprd05.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AM4PR05MB146005B448BEA876519335CDDCE80@AM4PR05MB1460.eurprd05.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>
Cc: Christoph Hellwig <hch@infradead.org>, Yishai Hadas <yishaih@mellanox.com>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>, Tal Alon <talal@mellanox.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Dec 09, 2015 at 10:00:02AM +0000, Shachar Raindel wrote:
> > Yes please.

> Note that other HW vendors are developing similar solutions, see for
> example:
> http://www.slideshare.net/linaroorg/hkg15106-replacing-cmem-meeting-tis-soc-shared-buffer-allocation-management-and-address-translation-requirements

CMA and it's successors are for something totally different.

> > We already have huge page mmaps, how much win is had by going from
> > huge page maps to this contiguous map?
> 
> As far as gain is concerned, we are seeing gains in two cases here:
> 1. If the system has lots of non-fragmented, free memory, you can
> create large contig blocks that are above the CPU huge page size.
> 2. If the system memory is very fragmented, you cannot allocate huge
> pages. However, an API that allows you to create small (i.e. 64KB,
> 128KB, etc.) contig blocks reduces the load on the HW page tables
> and caches.

I understand what it does, I was looking for performance numbers. The
last time I trivially benchmarked huge pages vs not huge pages on mlx4
I wasn't able to detect a performance difference.

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
