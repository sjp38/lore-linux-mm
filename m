Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 87E996B0038
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 19:06:36 -0400 (EDT)
Received: by pabxd6 with SMTP id xd6so1984159pab.2
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 16:06:36 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id pf6si1625894pbc.182.2015.08.04.16.06.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Aug 2015 16:06:30 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] memory-failure/hwpoison_user_mappings: move the comment
 about swap cache pages' check to proper location
Date: Tue, 4 Aug 2015 23:05:18 +0000
Message-ID: <20150804230517.GA13606@hori1.linux.bs1.fc.nec.co.jp>
References: <20150804202038.0ca2777e@hp>
In-Reply-To: <20150804202038.0ca2777e@hp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <FF68DA42A17DCB4AB220F912882D4018@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Xiaoqiang <wangxq10@lzu.edu.cn>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Aug 04, 2015 at 08:20:38PM +0800, Wang Xiaoqiang wrote:
> Hi Naoya,
>=20
> This patch just move the comment about swap cache pages' check to the
> proper location in 'hwpoison_user_mappings' function.
>=20
> Signed-off-by: Wang Xiaoqiang <wangxq10@lzu.edu.cn>

Thank you for finding out this.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/memory-failure.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 1cf7f29..3253abb 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -945,10 +945,6 @@ static int hwpoison_user_mappings(struct page *p, un=
signed long pfn,
>  	if (!(PageLRU(hpage) || PageHuge(p)))
>  		return SWAP_SUCCESS;
> =20
> -	/*
> -	 * This check implies we don't kill processes if their pages
> -	 * are in the swap cache early. Those are always late kills.
> -	 */
>  	if (!page_mapped(hpage))
>  		return SWAP_SUCCESS;
> =20
> @@ -957,6 +953,10 @@ static int hwpoison_user_mappings(struct page *p, un=
signed long pfn,
>  		return SWAP_FAIL;
>  	}
> =20
> +	/*
> +	 * This check implies we don't kill processes if their pages
> +	 * are in the swap cache early. Those are always late kills.
> +	 */
>  	if (PageSwapCache(p)) {
>  		printk(KERN_ERR
>  		       "MCE %#lx: keeping poisoned page in swap cache\n", pfn);
> --=20
> 1.7.10.4
>=20
>=20
>=20
> --
> thx!
> Wang Xiaoqiang
>=20
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
