Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id B8DDB8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 13:32:30 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id x13so11353399wro.9
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 10:32:30 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50067.outbound.protection.outlook.com. [40.107.5.67])
        by mx.google.com with ESMTPS id 68si31139244wra.172.2019.01.21.10.32.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 10:32:29 -0800 (PST)
From: Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH 6/6] drivers/IB,core: reduce scope of mmap_sem
Date: Mon, 21 Jan 2019 18:32:26 +0000
Message-ID: <20190121183218.GK25149@mellanox.com>
References: <20190121174220.10583-1-dave@stgolabs.net>
 <20190121174220.10583-7-dave@stgolabs.net>
In-Reply-To: <20190121174220.10583-7-dave@stgolabs.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <AF6C19A4E2A59848B1BBD303F838CD25@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dledford@redhat.com" <dledford@redhat.com>, "jack@suse.de" <jack@suse.de>, "ira.weiny@intel.com" <ira.weiny@intel.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Davidlohr Bueso <dbueso@suse.de>

On Mon, Jan 21, 2019 at 09:42:20AM -0800, Davidlohr Bueso wrote:
> ib_umem_get() uses gup_longterm() and relies on the lock to
> stabilze the vma_list, so we cannot really get rid of mmap_sem
> altogether, but now that the counter is atomic, we can get of
> some complexity that mmap_sem brings with only pinned_vm.
>=20
> Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
> ---
>  drivers/infiniband/core/umem.c | 41 ++----------------------------------=
-----
>  1 file changed, 2 insertions(+), 39 deletions(-)

I think this addresses my comment..

Considering that it is almost all infiniband, I'd rather it go it go
through the RDMA tree with an ack from mm people? Please advise..

Thanks,
Jason
