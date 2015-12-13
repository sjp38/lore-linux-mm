Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id D07656B0038
	for <linux-mm@kvack.org>; Sun, 13 Dec 2015 07:48:12 -0500 (EST)
Received: by obc18 with SMTP id 18so113279012obc.2
        for <linux-mm@kvack.org>; Sun, 13 Dec 2015 04:48:12 -0800 (PST)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0087.outbound.protection.outlook.com. [157.56.112.87])
        by mx.google.com with ESMTPS id tp10si3332422obb.49.2015.12.13.04.48.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 13 Dec 2015 04:48:10 -0800 (PST)
From: Shachar Raindel <raindel@mellanox.com>
Subject: RE: [RFC contig pages support 1/2] IB: Supports contiguous memory
 operations
Date: Sun, 13 Dec 2015 12:48:05 +0000
Message-ID: <AM4PR05MB14603FC8169D50AD2A8F5AA3DCEC0@AM4PR05MB1460.eurprd05.prod.outlook.com>
References: <1449587707-24214-1-git-send-email-yishaih@mellanox.com>
 <1449587707-24214-2-git-send-email-yishaih@mellanox.com>
 <20151208151852.GA6688@infradead.org>
 <20151208171542.GB13549@obsidianresearch.com>
 <AM4PR05MB146005B448BEA876519335CDDCE80@AM4PR05MB1460.eurprd05.prod.outlook.com>
 <20151209183940.GA4522@infradead.org>
In-Reply-To: <20151209183940.GA4522@infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Yishai Hadas <yishaih@mellanox.com>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>, Tal Alon <talal@mellanox.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>



> -----Original Message-----
> From: Christoph Hellwig [mailto:hch@infradead.org]
> Sent: Wednesday, December 09, 2015 8:40 PM
>=20
> On Wed, Dec 09, 2015 at 10:00:02AM +0000, Shachar Raindel wrote:
> > As far as gain is concerned, we are seeing gains in two cases here:
> > 1. If the system has lots of non-fragmented, free memory, you can
> create large contig blocks that are above the CPU huge page size.
> > 2. If the system memory is very fragmented, you cannot allocate huge
> pages. However, an API that allows you to create small (i.e. 64KB,
> 128KB, etc.) contig blocks reduces the load on the HW page tables and
> caches.
>=20
> None of that is a uniqueue requirement for the mlx4 devices.  Again,
> please work with the memory management folks to address your
> requirements in a generic way!

I completely agree, and this RFC was sent in order to start discussion
on this subject.

Dear MM people, can you please advise on the subject?

Multiple HW vendors, from different fields, ranging between embedded SoC
devices (TI) and HPC (Mellanox) are looking for a solution to allocate
blocks of contiguous memory to user space applications, without using huge
pages.

What should be the API to expose such feature?=20

Should we create a virtual FS that allows the user to create "files"
representing memory allocations, and define the contiguous level we
attempt to allocate using folders (similar to hugetlbfs)?

Should we patch hugetlbfs to allow allocation of contiguous memory chunks,
without creating larger memory mapping in the CPU page tables?

Should we create a special "allocator" virtual device, that will hand out
memory in contiguous chunks via a call to mmap with an FD connected to the
device?

Thanks,
--Shachar


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
