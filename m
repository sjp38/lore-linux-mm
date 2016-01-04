Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 61BB36B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 01:53:03 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id 65so152579909pff.3
        for <linux-mm@kvack.org>; Sun, 03 Jan 2016 22:53:03 -0800 (PST)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id hl6si56970111pac.123.2016.01.03.22.53.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 03 Jan 2016 22:53:02 -0800 (PST)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id u046r02V006753
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Mon, 4 Jan 2016 15:53:00 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/page_isolation: use micro to judge the alignment
Date: Mon, 4 Jan 2016 06:51:12 +0000
Message-ID: <20160104065058.GA10434@hori1.linux.bs1.fc.nec.co.jp>
References: <20160104134154.40c28f94@debian>
In-Reply-To: <20160104134154.40c28f94@debian>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <59EEC0F1B59D4041BDB208DB80FD8E2C@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Xiaoqiang <wangxq10@lzu.edu.cn>
Cc: David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jan 04, 2016 at 01:41:54PM +0800, Wang Xiaoqiang wrote:
> Hi, Naoya,
>=20
> This patch simply use micro IS_ALIGNED() to judge the alignment,
> instead of directly judging.

Hi Xiaoqiang,

Can you apply the same cleanup to undo_isolate_page_range(), too?
But anyway, this looks a good cleanup to me.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya Horiguchi

> Signed-off-by: Wang Xiaoqiang <wangxq10@lzu.edu.cn>
> ---
>  mm/page_isolation.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 4568fd5..9248929 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -162,8 +162,8 @@ int start_isolate_page_range(unsigned long
> start_pfn, unsigned long end_pfn, unsigned long undo_pfn;
>  	struct page *page;
> =20
> -	BUG_ON((start_pfn) & (pageblock_nr_pages - 1));
> -	BUG_ON((end_pfn) & (pageblock_nr_pages - 1));
> +	BUG_ON(!IS_ALIGNED(start_pfn, pageblock_nr_pages));
> +	BUG_ON(!IS_ALIGNED(end_pfn, pageblock_nr_pages));
> =20
>  	for (pfn =3D start_pfn;
>  	     pfn < end_pfn;
> --=20
> 2.1.4
>=20
> thanks
> Wang Xiaoqiang
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
