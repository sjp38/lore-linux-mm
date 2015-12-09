Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7021C6B0258
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 05:00:17 -0500 (EST)
Received: by ioir85 with SMTP id r85so53669607ioi.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 02:00:17 -0800 (PST)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0083.outbound.protection.outlook.com. [157.55.234.83])
        by mx.google.com with ESMTPS id w4si23723471igl.28.2015.12.09.02.00.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Dec 2015 02:00:16 -0800 (PST)
From: Shachar Raindel <raindel@mellanox.com>
Subject: RE: [RFC contig pages support 1/2] IB: Supports contiguous memory
 operations
Date: Wed, 9 Dec 2015 10:00:02 +0000
Message-ID: <AM4PR05MB146005B448BEA876519335CDDCE80@AM4PR05MB1460.eurprd05.prod.outlook.com>
References: <1449587707-24214-1-git-send-email-yishaih@mellanox.com>
 <1449587707-24214-2-git-send-email-yishaih@mellanox.com>
 <20151208151852.GA6688@infradead.org>
 <20151208171542.GB13549@obsidianresearch.com>
In-Reply-To: <20151208171542.GB13549@obsidianresearch.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Christoph Hellwig <hch@infradead.org>
Cc: Yishai Hadas <yishaih@mellanox.com>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>, Tal Alon <talal@mellanox.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>



> -----Original Message-----
> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> Behalf Of Jason Gunthorpe
> Sent: Tuesday, December 08, 2015 7:16 PM
> To: Christoph Hellwig <hch@infradead.org>
> Cc: Yishai Hadas <yishaih@mellanox.com>; dledford@redhat.com; linux-
> rdma@vger.kernel.org; Or Gerlitz <ogerlitz@mellanox.com>; Tal Alon
> <talal@mellanox.com>; linux-mm@kvack.org
> Subject: Re: [RFC contig pages support 1/2] IB: Supports contiguous
> memory operations
>=20
> On Tue, Dec 08, 2015 at 07:18:52AM -0800, Christoph Hellwig wrote:
> > There is absolutely nothing IB specific here.  If you want to support
> > anonymous mmaps to allocate large contiguous pages work with the MM
> > folks on providing that in a generic fashion.
>=20
> Yes please.
>=20

Note that other HW vendors are developing similar solutions, see for exampl=
e: http://www.slideshare.net/linaroorg/hkg15106-replacing-cmem-meeting-tis-=
soc-shared-buffer-allocation-management-and-address-translation-requirement=
s

> We already have huge page mmaps, how much win is had by going from
> huge page maps to this contiguous map?
>=20

As far as gain is concerned, we are seeing gains in two cases here:
1. If the system has lots of non-fragmented, free memory, you can create la=
rge contig blocks that are above the CPU huge page size.
2. If the system memory is very fragmented, you cannot allocate huge pages.=
 However, an API that allows you to create small (i.e. 64KB, 128KB, etc.) c=
ontig blocks reduces the load on the HW page tables and caches.

Thanks,
--Shachar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
