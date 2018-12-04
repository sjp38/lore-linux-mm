Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 567746B708C
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 15:28:58 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id l131so9717237pga.2
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 12:28:58 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r11si18732297pli.175.2018.12.04.12.28.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 12:28:57 -0800 (PST)
Date: Tue, 4 Dec 2018 12:28:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 9/9] dmapool: debug: prevent endless loop in case of
 corruption
Message-Id: <20181204122854.339503ccbbdc638940c9e1d0@linux-foundation.org>
In-Reply-To: <20181204201801.GS10377@bombadil.infradead.org>
References: <9e65ec2e-5e22-4f65-7b92-ca2af0c555f3@cybernetics.com>
	<20181113063601.GT21824@bombadil.infradead.org>
	<4dcb22b0-a348-841d-8175-e368f67f33c3@cybernetics.com>
	<20181204121443.1430883634a6ecf5f4a6a4a2@linux-foundation.org>
	<20181204201801.GS10377@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Tony Battersby <tonyb@cybernetics.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, Andy Shevchenko <andy.shevchenko@gmail.com>

On Tue, 4 Dec 2018 12:18:01 -0800 Matthew Wilcox <willy@infradead.org> wrot=
e:

> On Tue, Dec 04, 2018 at 12:14:43PM -0800, Andrew Morton wrote:
> > On Tue, 4 Dec 2018 11:22:34 -0500 Tony Battersby <tonyb@cybernetics.com=
> wrote:
> >=20
> > > On 11/13/18 1:36 AM, Matthew Wilcox wrote:
> > > > On Mon, Nov 12, 2018 at 10:46:35AM -0500, Tony Battersby wrote:
> > > >> Prevent a possible endless loop with DMAPOOL_DEBUG enabled if a bu=
ggy
> > > >> driver corrupts DMA pool memory.
> > > >>
> > > >> Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
> > > > I like it!  Also, here you're using blks_per_alloc in a way which i=
sn't
> > > > normally in the performance path, but might be with the right config
> > > > options.  With that, I withdraw my objection to the previous patch =
and
> > > >
> > > > Acked-by: Matthew Wilcox <willy@infradead.org>
> > > >
> > > > Andrew, can you funnel these in through your tree?  If you'd rather=
 not,
> > > > I don't mind stuffing them into a git tree and asking Linus to pull
> > > > for 4.21.
> > > >
> > > No reply for 3 weeks, so adding Andrew Morton to recipient list.
> > >=20
> > > Andrew, I have 9 dmapool patches ready for merging in 4.21.=A0 See Ma=
tthew
> > > Wilcox's request above.
> > >=20
> >=20
> > I'll take a look, but I see that this v4 series has several review
> > comments from Matthew which remain unresponded to.  Please attend to
> > that.
>=20
> I only had a review comment on 8/9, which I then withdrew during my review
> of patch 9/9.  Unless I missed something during my re-review of my respon=
ses?

And in 0/9, that 1.3MB allocation.

Maybe it's using kvmalloc, I didn't look.
