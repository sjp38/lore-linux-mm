Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id D7E948E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 12:03:05 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id h10so4164075plk.12
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:03:05 -0800 (PST)
Received: from EUR04-DB3-obe.outbound.protection.outlook.com (mail-eopbgr60047.outbound.protection.outlook.com. [40.107.6.47])
        by mx.google.com with ESMTPS id go3si6360605plb.97.2019.01.16.09.03.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 16 Jan 2019 09:03:04 -0800 (PST)
From: Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH 6/6] drivers/IB,core: reduce scope of mmap_sem
Date: Wed, 16 Jan 2019 17:02:59 +0000
Message-ID: <20190116170252.GG3758@mellanox.com>
References: <20190115181300.27547-1-dave@stgolabs.net>
 <20190115181300.27547-7-dave@stgolabs.net>
 <20190115205311.GD22031@mellanox.com>
 <20190115211207.GD6310@bombadil.infradead.org>
 <20190115211722.GA3758@mellanox.com>
 <20190116160026.iyg7pwmzy5o35h5l@linux-r8p5>
In-Reply-To: <20190116160026.iyg7pwmzy5o35h5l@linux-r8p5>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <2CA5B3539AE26941950FE2013C532279@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Davidlohr Bueso <dbueso@suse.de>

On Wed, Jan 16, 2019 at 08:00:26AM -0800, Davidlohr Bueso wrote:
> On Tue, 15 Jan 2019, Jason Gunthorpe wrote:
>=20
> > On Tue, Jan 15, 2019 at 01:12:07PM -0800, Matthew Wilcox wrote:
> > > On Tue, Jan 15, 2019 at 08:53:16PM +0000, Jason Gunthorpe wrote:
> > > > > -	new_pinned =3D atomic_long_read(&mm->pinned_vm) + npages;
> > > > > +	new_pinned =3D atomic_long_add_return(npages, &mm->pinned_vm);
> > > > >  	if (new_pinned > lock_limit && !capable(CAP_IPC_LOCK)) {
> > > >
> > > > I thought a patch had been made for this to use check_overflow...
> > >=20
> > > That got removed again by patch 1 ...
> >=20
> > Well, that sure needs a lot more explanation. :(
>=20
> What if we just make the counter atomic64?

That could work.

Jason
