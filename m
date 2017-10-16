Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 39F606B0253
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 18:39:34 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id j17so129462iod.18
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 15:39:34 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id i187si6223290ioa.67.2017.10.16.15.39.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 15:39:33 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm, soft_offline: improve hugepage soft offlining error
 log
Date: Mon, 16 Oct 2017 22:35:22 +0000
Message-ID: <3046fe8d-cdeb-6609-416e-8b016d162ea2@ah.jp.nec.com>
References: <20171016171757.GA3018@ubuntu-desk-vm>
In-Reply-To: <20171016171757.GA3018@ubuntu-desk-vm>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <9442E6E1FA4C37489F5CB5058145FF40@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laszlo Toth <laszlth@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On 10/17/2017 02:17 AM, Laszlo Toth wrote:
> On a failed attempt, we get the following entry:
> soft offline: 0x3c0000: migration failed 1, type 17ffffc0008008
> (uptodate|head)
>=20
> Make this more specific to be straightforward and to follow
> other error log formats in soft_offline_huge_page().
>=20
> Signed-off-by: Laszlo Toth <laszlth@gmail.com>

Looks good to me.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/memory-failure.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 8836662..4acdf39 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1587,7 +1587,7 @@ static int soft_offline_huge_page(struct page *page=
, int flags)
>  	ret =3D migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
>  				MIGRATE_SYNC, MR_MEMORY_FAILURE);
>  	if (ret) {
> -		pr_info("soft offline: %#lx: migration failed %d, type %lx (%pGp)\n",
> +		pr_info("soft offline: %#lx: hugepage migration failed %d, type %lx (%=
pGp)\n",
>  			pfn, ret, page->flags, &page->flags);
>  		if (!list_empty(&pagelist))
>  			putback_movable_pages(&pagelist);
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
