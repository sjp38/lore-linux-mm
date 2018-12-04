Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id DAEA36B7080
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 15:18:08 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id s14so14848582pfk.16
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 12:18:08 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c81si17626186pfc.196.2018.12.04.12.18.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 12:18:07 -0800 (PST)
Date: Tue, 4 Dec 2018 12:18:01 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 9/9] dmapool: debug: prevent endless loop in case of
 corruption
Message-ID: <20181204201801.GS10377@bombadil.infradead.org>
References: <9e65ec2e-5e22-4f65-7b92-ca2af0c555f3@cybernetics.com>
 <20181113063601.GT21824@bombadil.infradead.org>
 <4dcb22b0-a348-841d-8175-e368f67f33c3@cybernetics.com>
 <20181204121443.1430883634a6ecf5f4a6a4a2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181204121443.1430883634a6ecf5f4a6a4a2@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Battersby <tonyb@cybernetics.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, Andy Shevchenko <andy.shevchenko@gmail.com>

On Tue, Dec 04, 2018 at 12:14:43PM -0800, Andrew Morton wrote:
> On Tue, 4 Dec 2018 11:22:34 -0500 Tony Battersby <tonyb@cybernetics.com> wrote:
> 
> > On 11/13/18 1:36 AM, Matthew Wilcox wrote:
> > > On Mon, Nov 12, 2018 at 10:46:35AM -0500, Tony Battersby wrote:
> > >> Prevent a possible endless loop with DMAPOOL_DEBUG enabled if a buggy
> > >> driver corrupts DMA pool memory.
> > >>
> > >> Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
> > > I like it!  Also, here you're using blks_per_alloc in a way which isn't
> > > normally in the performance path, but might be with the right config
> > > options.  With that, I withdraw my objection to the previous patch and
> > >
> > > Acked-by: Matthew Wilcox <willy@infradead.org>
> > >
> > > Andrew, can you funnel these in through your tree?  If you'd rather not,
> > > I don't mind stuffing them into a git tree and asking Linus to pull
> > > for 4.21.
> > >
> > No reply for 3 weeks, so adding Andrew Morton to recipient list.
> > 
> > Andrew, I have 9 dmapool patches ready for merging in 4.21.� See Matthew
> > Wilcox's request above.
> > 
> 
> I'll take a look, but I see that this v4 series has several review
> comments from Matthew which remain unresponded to.  Please attend to
> that.

I only had a review comment on 8/9, which I then withdrew during my review
of patch 9/9.  Unless I missed something during my re-review of my responses?

> Also, Andy had issues with the v2 series so it would be good to hear an
> update from him?

Certainly.
