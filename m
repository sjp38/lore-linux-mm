Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 31FD46B0253
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 12:15:55 -0500 (EST)
Received: by ioc74 with SMTP id 74so30964090ioc.2
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 09:15:55 -0800 (PST)
Received: from quartz.orcorp.ca (quartz.orcorp.ca. [184.70.90.242])
        by mx.google.com with ESMTPS id uh6si4250537igb.90.2015.12.08.09.15.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 09:15:54 -0800 (PST)
Date: Tue, 8 Dec 2015 10:15:42 -0700
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC contig pages support 1/2] IB: Supports contiguous memory
 operations
Message-ID: <20151208171542.GB13549@obsidianresearch.com>
References: <1449587707-24214-1-git-send-email-yishaih@mellanox.com>
 <1449587707-24214-2-git-send-email-yishaih@mellanox.com>
 <20151208151852.GA6688@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151208151852.GA6688@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Yishai Hadas <yishaih@mellanox.com>, dledford@redhat.com, linux-rdma@vger.kernel.org, ogerlitz@mellanox.com, talal@mellanox.com, linux-mm@kvack.org

On Tue, Dec 08, 2015 at 07:18:52AM -0800, Christoph Hellwig wrote:
> There is absolutely nothing IB specific here.  If you want to support
> anonymous mmaps to allocate large contiguous pages work with the MM
> folks on providing that in a generic fashion.

Yes please.

We already have huge page mmaps, how much win is had by going from
huge page maps to this contiguous map?

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
