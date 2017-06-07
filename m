Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7362C6B0279
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 10:06:34 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id r62so2361586qkf.6
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 07:06:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h4si1647032qtc.335.2017.06.07.07.06.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jun 2017 07:06:33 -0700 (PDT)
Date: Wed, 7 Jun 2017 10:06:30 -0400 (EDT)
From: Jerome Glisse <jglisse@redhat.com>
Message-ID: <1800115030.31087797.1496844390023.JavaMail.zimbra@redhat.com>
In-Reply-To: <CAKTCnz=dHsiHVPmAro1=9PoFiUQt8hzxVenpTwSzOM9aSjsXOQ@mail.gmail.com>
References: <20170524172024.30810-1-jglisse@redhat.com> <20170524172024.30810-13-jglisse@redhat.com> <20170531135954.1d67ca31@firefly.ozlabs.ibm.com> <20170601223518.GA2780@redhat.com> <CAKTCnz=dHsiHVPmAro1=9PoFiUQt8hzxVenpTwSzOM9aSjsXOQ@mail.gmail.com>
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use
 with device memory v4
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

> On Fri, Jun 2, 2017 at 8:35 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> > On Wed, May 31, 2017 at 01:59:54PM +1000, Balbir Singh wrote:
> >> On Wed, 24 May 2017 13:20:21 -0400
> >> J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com> wrote:
> >>
> >> > This patch add a new memory migration helpers, which migrate memory
> >> > backing a range of virtual address of a process to different memory
> >> > (which can be allocated through special allocator). It differs from
> >> > numa migration by working on a range of virtual address and thus by
> >> > doing migration in chunk that can be large enough to use DMA engine
> >> > or special copy offloading engine.
> >> >
> >> > Expected users are any one with heterogeneous memory where different
> >> > memory have different characteristics (latency, bandwidth, ...). As
> >> > an example IBM platform with CAPI bus can make use of this feature
> >> > to migrate between regular memory and CAPI device memory. New CPU
> >> > architecture with a pool of high performance memory not manage as
> >> > cache but presented as regular memory (while being faster and with
> >> > lower latency than DDR) will also be prime user of this patch.
> >> >
> >> > Migration to private device memory will be useful for device that
> >> > have large pool of such like GPU, NVidia plans to use HMM for that.
> >> >
> >>
> >> It is helpful, for HMM-CDM however we would like to avoid the downside=
s
> >> of MIGRATE_SYNC_NOCOPY
> >
> > What are the downside you are referring too ?
>=20
> IIUC, MIGRATE_SYNC_NO_COPY is for anonymous memory only.

It can migrate anything, file back page too. It just forbid that latter
case if it is ZONE_DEVICE HMM. I should have time now to finish the CDM
patchset and i will post, previous patches already enabled file back
page migration for HMM-CDM.

The NOCOPY is for no CPUCOPY, i couldn't think of a better name.

Cheers,
J=C3=A9r=C3=B4me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
