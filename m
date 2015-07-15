Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4FB33280267
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 08:03:26 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so38797320wic.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 05:03:25 -0700 (PDT)
Received: from mail-wg0-x235.google.com (mail-wg0-x235.google.com. [2a00:1450:400c:c00::235])
        by mx.google.com with ESMTPS id q13si25086872wik.98.2015.07.15.05.03.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 05:03:24 -0700 (PDT)
Received: by wgxm20 with SMTP id m20so31752636wgx.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 05:03:24 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 1/2] mm/cma_debug: fix debugging alloc/free interface
In-Reply-To: <1436942129-18020-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1436942129-18020-1-git-send-email-iamjoonsoo.kim@lge.com>
Date: Wed, 15 Jul 2015 14:03:20 +0200
Message-ID: <xa1t4ml5fx13.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Stefan Strogin <stefan.strogin@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, Jul 15 2015, Joonsoo Kim wrote:
> CMA has alloc/free interface for debugging. It is intended that alloc/free
> occurs in specific CMA region, but, currently, alloc/free interface is
> on root dir due to the bug so we can't select CMA region where alloc/free
> happens.
>
> This patch fixes this problem by making alloc/free interface per
> CMA region.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  mm/cma_debug.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/cma_debug.c b/mm/cma_debug.c
> index 7621ee3..22190a7 100644
> --- a/mm/cma_debug.c
> +++ b/mm/cma_debug.c
> @@ -170,10 +170,10 @@ static void cma_debugfs_add_one(struct cma *cma, in=
t idx)
>=20=20
>  	tmp =3D debugfs_create_dir(name, cma_debugfs_root);
>=20=20
> -	debugfs_create_file("alloc", S_IWUSR, cma_debugfs_root, cma,
> +	debugfs_create_file("alloc", S_IWUSR, tmp, cma,
>  				&cma_alloc_fops);
>=20=20
> -	debugfs_create_file("free", S_IWUSR, cma_debugfs_root, cma,
> +	debugfs_create_file("free", S_IWUSR, tmp, cma,
>  				&cma_free_fops);
>=20=20
>  	debugfs_create_file("base_pfn", S_IRUGO, tmp,
> --=20
> 1.9.1
>

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
