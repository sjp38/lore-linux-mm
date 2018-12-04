Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id A4E8F6B6FC9
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 12:10:22 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id d11so14017531wrw.4
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 09:10:22 -0800 (PST)
Received: from eu-smtp-delivery-151.mimecast.com (eu-smtp-delivery-151.mimecast.com. [207.82.80.151])
        by mx.google.com with ESMTPS id b12si13136145wrv.58.2018.12.04.09.10.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 09:10:21 -0800 (PST)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 0/2] put_user_page*(): start converting the call sites
Date: Tue, 4 Dec 2018 17:10:28 +0000
Message-ID: <b31c7b3359344e778fc525013eeece64@AcuMS.aculab.com>
References: <20181204001720.26138-1-jhubbard@nvidia.com>
In-Reply-To: <20181204001720.26138-1-jhubbard@nvidia.com>
Content-Language: en-US
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'john.hubbard@gmail.com'" <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Jan Kara <jack@suse.cz>, Tom Talpey <tom@talpey.com>, Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, "Christoph Hellwig  <hch@infradead.org>, Christopher Lameter <cl@linux.com>, Dan Williams" <dan.j.williams@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, "Jason Gunthorpe  <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox" <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Ralph Campbell <rcampbell@nvidia.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>

From: john.hubbard@gmail.com
> Sent: 04 December 2018 00:17
>=20
> Summary: I'd like these two patches to go into the next convenient cycle.
> I *think* that means 4.21.
>=20
> Details
>=20
> At the Linux Plumbers Conference, we talked about this approach [1], and
> the primary lingering concern was over performance. Tom Talpey helped me
> through a much more accurate run of the fio performance test, and now
> it's looking like an under 1% performance cost, to add and remove pages
> from the LRU (this is only paid when dealing with get_user_pages) [2]. So
> we should be fine to start converting call sites.
>=20
> This patchset gets the conversion started. Both patches already had a fai=
r
> amount of review.

Shouldn't the commit message contain actual details of the change?

=09David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1=
PT, UK
Registration No: 1397386 (Wales)
