Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4650A6B0072
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 16:15:12 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id l15so28711385wiw.5
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:15:11 -0800 (PST)
Received: from mail-wg0-x235.google.com (mail-wg0-x235.google.com. [2a00:1450:400c:c00::235])
        by mx.google.com with ESMTPS id jv8si25571730wid.31.2015.02.24.13.15.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 13:15:11 -0800 (PST)
Received: by wghl2 with SMTP id l2so8020578wgh.9
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:15:10 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v3 2/4] mm: cma: add number of pages to debug message in cma_release()
In-Reply-To: <a0c78bd29b1aa0bccb461ebd675716c0b1a2caf3.1424802755.git.s.strogin@partner.samsung.com>
References: <cover.1424802755.git.s.strogin@partner.samsung.com> <a0c78bd29b1aa0bccb461ebd675716c0b1a2caf3.1424802755.git.s.strogin@partner.samsung.com>
Date: Tue, 24 Feb 2015 22:15:07 +0100
Message-ID: <xa1tr3tfovtw.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

On Tue, Feb 24 2015, Stefan Strogin <s.strogin@partner.samsung.com> wrote:
> It's more useful to print address and number of pages which are being rel=
eased,
> not only address.
>
> Signed-off-by: Stefan Strogin <s.strogin@partner.samsung.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  mm/cma.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/cma.c b/mm/cma.c
> index 3a63c96..111bf62 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -434,7 +434,7 @@ bool cma_release(struct cma *cma, struct page *pages,=
 int count)
>  	if (!cma || !pages)
>  		return false;
>=20=20
> -	pr_debug("%s(page %p)\n", __func__, (void *)pages);
> +	pr_debug("%s(page %p, count %d)\n", __func__, (void *)pages, count);
>=20=20
>  	pfn =3D page_to_pfn(pages);
>=20=20
> --=20
> 2.1.0
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
