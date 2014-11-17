Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 173DD6B0082
	for <linux-mm@kvack.org>; Sun, 16 Nov 2014 19:16:11 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id q107so14549900qgd.14
        for <linux-mm@kvack.org>; Sun, 16 Nov 2014 16:16:10 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id p77si61408256qgd.26.2014.11.16.16.16.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 16 Nov 2014 16:16:10 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/3] hugetlb: alloc_bootmem_huge_page(): use IS_ALIGNED()
Date: Mon, 17 Nov 2014 00:11:51 +0000
Message-ID: <20141117001228.GB4667@hori1.linux.bs1.fc.nec.co.jp>
References: <1415831593-9020-1-git-send-email-lcapitulino@redhat.com>
 <1415831593-9020-3-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1415831593-9020-3-git-send-email-lcapitulino@redhat.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <DB9ACF5C0D0027439E0D9DB9690CD525@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "rientjes@google.com" <rientjes@google.com>, "riel@redhat.com" <riel@redhat.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "davidlohr@hp.com" <davidlohr@hp.com>

On Wed, Nov 12, 2014 at 05:33:12PM -0500, Luiz Capitulino wrote:
> No reason to duplicate the code of an existing macro.
>=20
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>

I think that we can apply the same macro for the following two lines in
__unmap_hugepage_range():

	BUG_ON(start & ~huge_page_mask(h));
	BUG_ON(end & ~huge_page_mask(h));

Anyway, this makes the code more readable.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/hugetlb.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 9fd7227..a10fd57 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1457,7 +1457,7 @@ int __weak alloc_bootmem_huge_page(struct hstate *h=
)
>  	return 0;
> =20
>  found:
> -	BUG_ON((unsigned long)virt_to_phys(m) & (huge_page_size(h) - 1));
> +	BUG_ON(!IS_ALIGNED(virt_to_phys(m), huge_page_size(h)));
>  	/* Put them into a private list first because mem_map is not up yet */
>  	list_add(&m->list, &huge_boot_pages);
>  	m->hstate =3D h;
> --=20
> 1.9.3
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
