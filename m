Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 800A08E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 14:54:34 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a23-v6so5136108pfo.23
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 11:54:34 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x13-v6si22682867pgr.153.2018.09.20.11.54.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Sep 2018 11:54:33 -0700 (PDT)
Date: Thu, 20 Sep 2018 21:54:28 +0300
From: Leon Romanovsky <leon@kernel.org>
Subject: Re: Linux RDMA mini-conf at Plumbers 2018
Message-ID: <20180920185428.GT3519@mtr-leonro.mtl.com>
References: <20180920181923.GA6542@mellanox.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="M0YLxmUXciMpOLPE"
Content-Disposition: inline
In-Reply-To: <20180920181923.GA6542@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: linux-rdma@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alex Rosenbaum <alexr@mellanox.com>, Alex Williamson <alex.williamson@redhat.com>, Bjorn Helgaas <bhelgaas@google.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Christoph Hellwig <hch@lst.de>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Don Dutile <ddutile@redhat.com>, Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Matthew Wilcox <willy@infradead.org>, Nicholas Piggin <npiggin@gmail.com>, Noa Osherovich <noaos@mellanox.com>, Parav Pandit <parav@mellanox.com>, Stephen Bates <sbates@raithlin.com>


--M0YLxmUXciMpOLPE
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 20, 2018 at 12:19:23PM -0600, Jason Gunthorpe wrote:
> This is just a friendly reminder that registration deadlines are
> approaching for this conference. Please see
>
> https://www.linuxplumbersconf.org/event/2/page/7-attend
>
> For details.
>
> This year we expect to have close to a day set aside for RDMA related
> topics. Including up to half a day for the thorny general kernel issues
> related to get_user_pages(), particularly as exasperated by RDMA.
>
> We have been working on the following concepts for sessions, I've
> roughly marked names based on past participation in related email
> threads. As we get closer to the conference date we will be organizing
> leaders for each section based on these lists, please let us know of
> any changes, or desire to be a leader!
>
> RDMA and get_user_pages
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>   Dan Williams <dan.j.williams@intel.com>
>   Matthew Wilcox <willy@infradead.org>
>   John Hubbard <jhubbard@nvidia.com>
>   Nicholas Piggin <npiggin@gmail.com>
>   Jan Kara <jack@suse.cz>
>
>  RDMA, DAX and persistant memory co-existence.
>
>  Explore the limits of what is possible without using On
>  Demand Paging Memory Registration. Discuss 'shootdown'
>  of userspace MRs
>
>  Dirtying pages obtained with get_user_pages() can oops ext4
>  discuss open solutions.
>
> RDMA and PCI peer to peer
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
>   Don Dutile <ddutile@redhat.com>
>   Alex Williamson <alex.williamson@redhat.com>
>   Christoph Hellwig <hch@lst.de>
>   Stephen Bates <sbates@raithlin.com>
>   Logan Gunthorpe <logang@deltatee.com>
>   J=E9r=F4me Glisse <jglisse@redhat.com>
>   Christian K=F6nig <christian.koenig@amd.com>
>   Bjorn Helgaas <bhelgaas@google.com>
>
>  RDMA and PCI peer to peer transactions. IOMMU issues. Integration
>  with HMM. How to expose PCI BAR memory to userspace and other
>  drivers as a DMA target.
>
> Improving testing of RDMA with syzkaller, RXE and Python
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
>  Noa Osherovich <noaos@mellanox.com>
>  Don Dutile <ddutile@redhat.com>
>  Jason Gunthorpe <jgg@mellanox.com>
>
>  Problem solve RDMA's distinct lack of public tests.
>  Provide a better framework for all drivers to test with,
>  and a framework for basic testing in userspace.
>
>  Worst remaining unfixed syzkaller bugs and how to try to fix them
>
>  How to hook syzkaller more deeply into RDMA.
>
> IOCTL conversion and new kABI topics
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>  Jason Gunthorpe <jgg@mellanox.com>
>  Alex Rosenbaum <alexr@mellanox.com>
>
>  Attempt to close on the remaining tasks to complete the project
>
>  Restore fork() support to userspace
>
> Container and namespaces for RDMA topics
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>  Parav Pandit <parav@mellanox.com>
>  Doug Ledford <dledford@redhat.com>
>
>  Remaining sticky situations with containers
>
>  namespaces in sysfs and legacy all-namespace operation
>
>  Remaining CM issues
>
>  Security isolation problems
>
> Very large Contiguous regions in userspace
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>  Christopher Lameter <cl@linux.com>
>  Parav Pandit <parav@mellanox.com>
>
>  Poor performance of get_user_pages on very large virtual ranges
>
>  No standardized API to allocate regions to user space
>
>  Carry over from last year
>
> As we get closer to the conference date the exact schedule will be
> published on the conference web site. I belive we have the Thursday
> set aside right now.
>
> If there are any last minute topics people would like to see please
> let us know.

I want to remind you that Mike wanted to bring the topic of enhancing
remote page faults during post-copy container migration in CRIU over
RDMA.

Thanks

>
> See you all in Vancouver!
>
> Thanks,
> Jason & Leon
>

--M0YLxmUXciMpOLPE
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJbo+zkAAoJEORje4g2clinH6IP+wfLFZ7fzsARxS15q/RbnRf1
fwsHV80uj2xr5fRwGyIvA+zkhOQyzdEyF2Pfo6fK9jtR5lIJDMHv0KLkfkgYhQrB
YMTkWW9KcczlA2d/d1iOMaK7Xg/o/rids7KgTVTPGY8unyfWxUpYNd+R2kSnmmc0
7VkS/uciKu4tacsunPxSHdOjOmU4a3FWZk4U2HpQkRaYfsJIDjcUmdZcN5QOZJcr
4lv3n8xV+u2Hn6O/A0tagh7WWbQay99xQQX6ZEay8Y7Rb+N6sxnsapZf0K3EKK+d
GFWV9lG1+IisMhAvV58zy7nAdWUHGgudqs9eKxcksMWMG1gd6Kf+lnQxqbaixeiE
v15SZNF/zGTmbxzgHbpf9XEznSRIUW9WQmmQU1ncZ4mG7GAJK9aErzpj7nJS3/fi
kk/eRyPeV5mFDZ1uTYV+ppy7azRCmRhVJWhgbHnx6XCBJl3aSXg7RNA7YmzfU3DW
nneLe7HlEENgN/FQjAI540wFnzey1vS384Y0PgcA2h6RaSUzAMlfJxkkauWmECB7
90d6S+Fo/wxPe46Tm4Wz/LFwyQ/LTS+RrobRJn7qJNRZZDLP1YOPSsf2rWRfDCP3
2c7V9p9AVZe7LumdmgO9Te0P6bOZFF8G0/MRSiGL6zxAqqiB6abzFH1DKwI9fRam
W/AMQ5XL93NxGwA/c9G9
=LW6p
-----END PGP SIGNATURE-----

--M0YLxmUXciMpOLPE--
