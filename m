Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id ECEB86B0292
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 06:46:16 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v31so4497496wrc.7
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 03:46:16 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id k134si558857wmg.256.2017.08.11.03.46.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 03:46:15 -0700 (PDT)
Date: Fri, 11 Aug 2017 12:46:15 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v1 2/6] fs: use on-stack-bio if backing device has
	BDI_CAP_SYNC capability
Message-ID: <20170811104615.GA14397@lst.de>
References: <1502175024-28338-1-git-send-email-minchan@kernel.org> <1502175024-28338-3-git-send-email-minchan@kernel.org> <20170808124959.GB31390@bombadil.infradead.org> <20170808132904.GC31390@bombadil.infradead.org> <20170809015113.GB32338@bbox> <20170809023122.GF31390@bombadil.infradead.org> <20170809024150.GA32471@bbox> <20170810030433.GG31390@bombadil.infradead.org> <CAA9_cmekE9_PYmNnVmiOkyH2gq5o8=uvEKnAbMWw5nBX-zE69g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA9_cmekE9_PYmNnVmiOkyH2gq5o8=uvEKnAbMWw5nBX-zE69g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, kernel-team <kernel-team@lge.com>

On Wed, Aug 09, 2017 at 08:06:24PM -0700, Dan Williams wrote:
> I like it, but do you think we should switch to sbvec[<constant>] to
> preclude pathological cases where nr_pages is large?

Yes, please.

Then I'd like to see that the on-stack bio even matters for
mpage_readpage / mpage_writepage.  Compared to all the buffer head
overhead the bio allocation should not actually matter in practice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
