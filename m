Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id E85076B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 11:12:56 -0400 (EDT)
Received: by mail-io0-f174.google.com with SMTP id 2so59818528ioy.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 08:12:56 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id k8si17904063igx.61.2016.04.06.08.12.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 08:12:56 -0700 (PDT)
From: Frank Mehnert <frank.mehnert@oracle.com>
Subject: Re: Re: PG_reserved and compound pages
Date: Wed, 06 Apr 2016 17:12:43 +0200
Message-ID: <3877205.TjDYue2aah@noys2>
In-Reply-To: <20160406150206.GB24283@dhcp22.suse.cz>
References: <4482994.u2S3pScRyb@noys2> <20160406150206.GB24283@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Michal,

On Wednesday 06 April 2016 17:02:06 Michal Hocko wrote:
> [CCing linux-mm mailing list]
>=20
> On Wed 06-04-16 13:28:37, Frank Mehnert wrote:
> > Hi,
> >=20
> > Linux 4.5 introduced additional checks to ensure that compound page=
s are
> > never marked as reserved. In our code we use PG_reserved to ensure =
that
> > the kernel does never swap out such pages, e.g.
>=20
> Are you putting your pages on the LRU list? If not how they could get=

> swapped out?

No, we do nothing like that. It was my understanding that at least with=

older kernels it was possible that pages allocated with alloc_pages()
could be swapped out or otherwise manipulated, I might be wrong. For
instance, it's also necessary that the physical address of the page
is known and that it does never change. I know, there might be problems=

with automatic NUMA page migration but that's another story.

> >   int i;
> >   struct page *pages =3D alloc_pages(GFP_HIGHUSER | __GFP_COMP, 4);=

> >   for (i =3D 0; i < 16; i++)
> >  =20
> >     SetPageReserved(&pages[i]);
> >=20
> > The purpose of setting PG_reserved is to prevent the kernel from sw=
apping
> > this memory out. This worked with older kernel but not with Linux 4=
.5 as
> > setting PG_reserved to compound pages is not allowed any more.
> >=20
> > Can somebody explain how we can achieve the same result in accordan=
ce to
> > the new Linux 4.5 rules?

Frank
--=20
Dr.-Ing. Frank Mehnert | Software Development Director, VirtualBox
ORACLE Deutschland B.V. & Co. KG | Werkstr. 24 | 71384 Weinstadt, Germa=
ny

ORACLE Deutschland B.V. & Co. KG
Hauptverwaltung: Riesstra=C3=9Fe 25, D-80992 M=C3=BCnchen
Registergericht: Amtsgericht M=C3=BCnchen, HRA 95603

Komplement=C3=A4rin: ORACLE Deutschland Verwaltung B.V.
Hertogswetering 163/167, 3543 AS Utrecht, Niederlande
Handelsregister der Handelskammer Midden-Niederlande, Nr. 30143697
Gesch=C3=A4ftsf=C3=BChrer: Alexander van der Ven, Jan Schultheiss, Val =
Maher

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
