Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id BF7106B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 15:25:31 -0400 (EDT)
Received: by mail-pf0-f174.google.com with SMTP id x3so276059267pfb.1
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 12:25:31 -0700 (PDT)
Received: from bby1mta03.pmc-sierra.bc.ca (bby1mta03.pmc-sierra.com. [216.241.235.118])
        by mx.google.com with ESMTPS id w1si3064365par.40.2016.03.21.12.25.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 Mar 2016 12:25:30 -0700 (PDT)
From: Stephen Bates <Stephen.Bates@pmcs.com>
Subject: RE: [PATCH RFC 1/1] Add support for ZONE_DEVICE IO memory with
 struct pages.
Date: Mon, 21 Mar 2016 19:25:29 +0000
Message-ID: <36F6EBABA23FEF4391AF72944D228901EB72CA35@BBYEXM01.pmc-sierra.internal>
References: <1457979277-26791-1-git-send-email-stephen.bates@pmcs.com>
 <20160314212344.GC23727@linux.intel.com>
 <20160314215708.GA7282@obsidianresearch.com> <56EACAB3.5070301@mellanox.com>
 <20160317161121.GA19501@obsidianresearch.com>
In-Reply-To: <20160317161121.GA19501@obsidianresearch.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Haggai Eran <haggaie@mellanox.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "javier@cnexlabs.com" <javier@cnexlabs.com>, "sagig@mellanox.com" <sagig@mellanox.com>, "leonro@mellanox.com" <leonro@mellanox.com>, "artemyko@mellanox.com" <artemyko@mellanox.com>, "hch@infradead.org" <hch@infradead.org>

>=20
> There are fringe cases that are more complex, and maybe the correct readi=
ng
> of the spec is to setup routing to avoid optimal paths, but it certainly =
is
> possible to configure switches in a way that could not guarentee global
> ordering.
>=20
> Jason

If someone configures a multipath PCIe topology I think they will have pote=
ntial for out of order RDMA reads/writes regardless of whether the target M=
R is in system memory of PCIe memory. So I don't think these crazy topologi=
es are uniquely problematic for IOPMEM.

Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
