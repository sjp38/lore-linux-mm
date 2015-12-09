Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 62BCF6B0258
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 13:39:45 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so33587003pac.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 10:39:45 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id wy9si14248918pab.27.2015.12.09.10.39.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 10:39:44 -0800 (PST)
Date: Wed, 9 Dec 2015 10:39:40 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC contig pages support 1/2] IB: Supports contiguous memory
 operations
Message-ID: <20151209183940.GA4522@infradead.org>
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
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Yishai Hadas <yishaih@mellanox.com>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>, Tal Alon <talal@mellanox.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Dec 09, 2015 at 10:00:02AM +0000, Shachar Raindel wrote:
> As far as gain is concerned, we are seeing gains in two cases here:
> 1. If the system has lots of non-fragmented, free memory, you can create large contig blocks that are above the CPU huge page size.
> 2. If the system memory is very fragmented, you cannot allocate huge pages. However, an API that allows you to create small (i.e. 64KB, 128KB, etc.) contig blocks reduces the load on the HW page tables and caches.

None of that is a uniqueue requirement for the mlx4 devices.  Again,
please work with the memory management folks to address your
requirements in a generic way!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
