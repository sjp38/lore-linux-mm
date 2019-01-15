Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id B49918E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 16:17:32 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id h11so1633015wrs.2
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 13:17:32 -0800 (PST)
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80084.outbound.protection.outlook.com. [40.107.8.84])
        by mx.google.com with ESMTPS id j6si33343738wrr.94.2019.01.15.13.17.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 15 Jan 2019 13:17:31 -0800 (PST)
From: Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH 6/6] drivers/IB,core: reduce scope of mmap_sem
Date: Tue, 15 Jan 2019 21:17:28 +0000
Message-ID: <20190115211722.GA3758@mellanox.com>
References: <20190115181300.27547-1-dave@stgolabs.net>
 <20190115181300.27547-7-dave@stgolabs.net>
 <20190115205311.GD22031@mellanox.com>
 <20190115211207.GD6310@bombadil.infradead.org>
In-Reply-To: <20190115211207.GD6310@bombadil.infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <E36B13D272CDBF4789F093A3481DFFD6@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Davidlohr Bueso <dave@stgolabs.net>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Davidlohr Bueso <dbueso@suse.de>

On Tue, Jan 15, 2019 at 01:12:07PM -0800, Matthew Wilcox wrote:
> On Tue, Jan 15, 2019 at 08:53:16PM +0000, Jason Gunthorpe wrote:
> > > -	new_pinned =3D atomic_long_read(&mm->pinned_vm) + npages;
> > > +	new_pinned =3D atomic_long_add_return(npages, &mm->pinned_vm);
> > >  	if (new_pinned > lock_limit && !capable(CAP_IPC_LOCK)) {
> >=20
> > I thought a patch had been made for this to use check_overflow...
>=20
> That got removed again by patch 1 ...

Well, that sure needs a lot more explanation. :(

Jason
