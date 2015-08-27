Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id A56A46B0254
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 11:38:17 -0400 (EDT)
Received: by wicge2 with SMTP id ge2so5862852wic.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 08:38:17 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id bc8si4751795wjc.159.2015.08.27.08.38.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 08:38:16 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so49051082wid.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 08:38:16 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm/cma_debug: Check return value of the debugfs_create_dir()
In-Reply-To: <1440489154-3470-1-git-send-email-kuleshovmail@gmail.com>
References: <1440489154-3470-1-git-send-email-kuleshovmail@gmail.com>
Date: Thu, 27 Aug 2015 17:38:13 +0200
Message-ID: <xa1tsi74oi6y.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Kuleshov <kuleshovmail@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Stefan Strogin <stefan.strogin@gmail.com>, Dmitry Safonov <d.safonov@partner.samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 25 2015, Alexander Kuleshov wrote:
> The debugfs_create_dir() function may fail and return error. If the
> root directory not created, we can't create anything inside it. This
> patch adds check for this case.
>
> Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>

I=E2=80=99d also add a pr_warn but otherwise:

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  mm/cma_debug.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/mm/cma_debug.c b/mm/cma_debug.c
> index f8e4b60..bfb46e2 100644
> --- a/mm/cma_debug.c
> +++ b/mm/cma_debug.c
> @@ -171,6 +171,9 @@ static void cma_debugfs_add_one(struct cma *cma, int =
idx)
>=20=20
>  	tmp =3D debugfs_create_dir(name, cma_debugfs_root);
>=20=20
> +	if (!tmp)
> +		return;
> +
>  	debugfs_create_file("alloc", S_IWUSR, tmp, cma,
>  				&cma_alloc_fops);
>=20=20

--=20
Best regards,                                            _     _
.o. | Liege of Serenely Enlightened Majesty of         o' \,=3D./ `o
..o | Computer Science,  =E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9Cmina86=E2=80=
=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=83=84  (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>-----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
