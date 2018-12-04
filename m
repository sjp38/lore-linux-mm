Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 408A06B7094
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 15:36:03 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id r16so9708274pgr.15
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 12:36:03 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g8si21104353pli.50.2018.12.04.12.36.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 12:36:02 -0800 (PST)
Date: Tue, 4 Dec 2018 12:35:57 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 9/9] dmapool: debug: prevent endless loop in case of
 corruption
Message-ID: <20181204203557.GT10377@bombadil.infradead.org>
References: <9e65ec2e-5e22-4f65-7b92-ca2af0c555f3@cybernetics.com>
 <20181113063601.GT21824@bombadil.infradead.org>
 <4dcb22b0-a348-841d-8175-e368f67f33c3@cybernetics.com>
 <20181204121443.1430883634a6ecf5f4a6a4a2@linux-foundation.org>
 <20181204201801.GS10377@bombadil.infradead.org>
 <20181204122854.339503ccbbdc638940c9e1d0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204122854.339503ccbbdc638940c9e1d0@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Battersby <tonyb@cybernetics.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, Andy Shevchenko <andy.shevchenko@gmail.com>

On Tue, Dec 04, 2018 at 12:28:54PM -0800, Andrew Morton wrote:
> On Tue, 4 Dec 2018 12:18:01 -0800 Matthew Wilcox <willy@infradead.org> wrote:
> > I only had a review comment on 8/9, which I then withdrew during my review
> > of patch 9/9.  Unless I missed something during my re-review of my responses?
> 
> And in 0/9, that 1.3MB allocation.
> 
> Maybe it's using kvmalloc, I didn't look.

Oh!  That's the mptsas driver doing something utterly awful.  Not the
fault of this patchset, in any way.
