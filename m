Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 076216B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 03:38:17 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id n2so40783795wma.0
        for <linux-mm@kvack.org>; Thu, 26 May 2016 00:38:16 -0700 (PDT)
Received: from fnsib-smtp05.srv.cat (fnsib-smtp05.srv.cat. [46.16.61.54])
        by mx.google.com with ESMTPS id r19si7105980lfe.307.2016.05.26.00.38.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 00:38:14 -0700 (PDT)
Received: from vostok.local.mail (boro.ii.uam.es [150.244.58.71])
	by fnsib-smtp05.srv.cat (Postfix) with ESMTPA id 719431EF111
	for <linux-mm@kvack.org>; Thu, 26 May 2016 09:38:12 +0200 (CEST)
Date: Thu, 26 May 2016 09:38:04 +0200
From: =?utf-8?Q?Guillermo_Juli=C3=A1n_Moreno?=
 <guillermo.julian@naudit.es>
Message-ID: <etPan.5746a7e1.1cc53686.1602@naudit.es>
In-Reply-To: <etPan.57175fb3.7a271c6b.2bd@naudit.es>
References: <etPan.57175fb3.7a271c6b.2bd@naudit.es>
Subject: Re: [PATCH] mm: fix overflow in vm_map_ram
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


On 20 April 2016 at 12:53:41, Guillermo Juli=C3=A1n Moreno (guillermo.jul=
ian=40naudit.es(mailto:guillermo.julian=40naudit.es)) wrote:

> =20
> When remapping pages accounting for 4G or more memory space, the
> operation 'count << PAGE=5FSHI=46T' overflows as it is performed on an
> integer. Solution: cast before doing the bitshift.
> =20
> Signed-off-by: Guillermo Juli=C3=A1n =20
> ---
> mm/vmalloc.c =7C 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> =20
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index ae7d20b..97257e4 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> =40=40 -1114,7 +1114,7 =40=40 EXPORT=5FSYMBOL(vm=5Funmap=5Fram);
> */
> void *vm=5Fmap=5Fram(struct page **pages, unsigned int count, int node,=
 pgprot=5Ft prot)
> =7B
> - unsigned long size =3D count << PAGE=5FSHI=46T;
> + unsigned long size =3D ((unsigned long) count) << PAGE=5FSHI=46T;
> unsigned long addr;
> void *mem;
> =20
> =40=40 -1484,7 +1484,7 =40=40 static void =5F=5Fvunmap(const void *addr=
, int deallocate=5Fpages)
> kfree(area);
> return;
> =7D
> -
> +
> /**
> * vfree - release memory allocated by vmalloc()
> * =40addr: memory base address
> --
> 1.8.3.1

Hello, has anyone taken a look at this patch=3F

Guillermo Juli=C3=A1n



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
