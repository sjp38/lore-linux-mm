Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id F18E96B0033
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 07:54:08 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y44so1045249wry.3
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 04:54:08 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x135sor4275053wmf.0.2017.10.04.04.54.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Oct 2017 04:54:07 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC] mmap(MAP_CONTIG)
In-Reply-To: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>
Date: Wed, 04 Oct 2017 13:54:05 +0200
Message-ID: <xa1tk20bxh5u.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Christoph Lameter <cl@linux.com>

On Tue, Oct 03 2017, Mike Kravetz wrote:
> At Plumbers this year, Guy Shattah and Christoph Lameter gave a presentat=
ion
> titled 'User space contiguous memory allocation for DMA' [1].  The slides
> point out the performance benefits of devices that can take advantage of
> larger physically contiguous areas.

Issue I have is that kind of memory needed may depend on a device.  Some
may require contiguous blocks.  Some may support scatter-gather.  Some
may be behind IO-MMU and not care either way.

Furthermore, I feel d=C3=A9j=C3=A0 vu.  Wasn=E2=80=99t dmabuf supposed to a=
ddress this
issue?

--=20
Best regards
=E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9C=F0=9D=93=B6=F0=9D=93=B2=F0=9D=93=B7=
=F0=9D=93=AA86=E2=80=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=83=
=84
=C2=ABIf at first you don=E2=80=99t succeed, give up skydiving=C2=BB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
