Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2A06B7080
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 15:14:48 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id k125so9684645pga.5
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 12:14:48 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z4si15488863pgl.16.2018.12.04.12.14.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 12:14:47 -0800 (PST)
Date: Tue, 4 Dec 2018 12:14:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 9/9] dmapool: debug: prevent endless loop in case of
 corruption
Message-Id: <20181204121443.1430883634a6ecf5f4a6a4a2@linux-foundation.org>
In-Reply-To: <4dcb22b0-a348-841d-8175-e368f67f33c3@cybernetics.com>
References: <9e65ec2e-5e22-4f65-7b92-ca2af0c555f3@cybernetics.com>
	<20181113063601.GT21824@bombadil.infradead.org>
	<4dcb22b0-a348-841d-8175-e368f67f33c3@cybernetics.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, Andy Shevchenko <andy.shevchenko@gmail.com>

On Tue, 4 Dec 2018 11:22:34 -0500 Tony Battersby <tonyb@cybernetics.com> wr=
ote:

> On 11/13/18 1:36 AM, Matthew Wilcox wrote:
> > On Mon, Nov 12, 2018 at 10:46:35AM -0500, Tony Battersby wrote:
> >> Prevent a possible endless loop with DMAPOOL_DEBUG enabled if a buggy
> >> driver corrupts DMA pool memory.
> >>
> >> Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
> > I like it!  Also, here you're using blks_per_alloc in a way which isn't
> > normally in the performance path, but might be with the right config
> > options.  With that, I withdraw my objection to the previous patch and
> >
> > Acked-by: Matthew Wilcox <willy@infradead.org>
> >
> > Andrew, can you funnel these in through your tree?  If you'd rather not,
> > I don't mind stuffing them into a git tree and asking Linus to pull
> > for 4.21.
> >
> No reply for 3 weeks, so adding Andrew Morton to recipient list.
>=20
> Andrew, I have 9 dmapool patches ready for merging in 4.21.=A0 See Matthew
> Wilcox's request above.
>=20

I'll take a look, but I see that this v4 series has several review
comments from Matthew which remain unresponded to.  Please attend to
that.

Also, Andy had issues with the v2 series so it would be good to hear an
update from him?
