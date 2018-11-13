Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F1E96B0005
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 01:44:49 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 68so3762315pfr.6
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 22:44:49 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 1-v6si20837407plv.205.2018.11.12.22.44.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Nov 2018 22:44:48 -0800 (PST)
Date: Mon, 12 Nov 2018 22:44:44 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 0/9] mpt3sas and dmapool scalability
Message-ID: <20181113064444.GU21824@bombadil.infradead.org>
References: <88395080-efc1-4e7b-f813-bb90c86d0745@cybernetics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <88395080-efc1-4e7b-f813-bb90c86d0745@cybernetics.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, linux-mm@kvack.org, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>

On Mon, Nov 12, 2018 at 10:40:57AM -0500, Tony Battersby wrote:
> I posted v3 on August 7.  Nobody acked or merged the patches, and then
> I got too busy with other stuff to repost until now.

Thanks for resending.  They were in my pile of things to look at, but
that's an ever-growing pile.

> I believe these patches are ready for merging.

I agree.

> cat /sys/devices/pci0000:80/0000:80:07.0/0000:85:00.0/pools
> (manually cleaned up column alignment)
> poolinfo - 0.1
> reply_post_free_array pool  1      21     192     1
> reply_free pool             1      1      41728   1
> reply pool                  1      1      1335296 1
> sense pool                  1      1      970272  1
> chain pool                  373959 386048 128     12064
> reply_post_free pool        12     12     166528  12

That reply pool ... 1 object of 1.3MB?  That's a lot of strain to put
on the page allocator.  I wonder if anything can be done about that.

(I'm equally non-thrilled about the sense pool, the reply_post_free pool
and the reply_free pool, but they seem a little less stressful than the
reply pool)
