Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8EDFF9003C7
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 04:59:30 -0400 (EDT)
Received: by qkcs67 with SMTP id s67so3100343qkc.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 01:59:30 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id 5si8805647qkq.77.2015.08.12.01.59.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Aug 2015 01:59:30 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 4/5] mm/hwpoison: fix refcount of THP head page in
 no-injection case
Date: Wed, 12 Aug 2015 08:58:59 +0000
Message-ID: <20150812085859.GF32192@hori1.linux.bs1.fc.nec.co.jp>
References: <1439206103-86829-1-git-send-email-wanpeng.li@hotmail.com>
 <BLU436-SMTP127FE35D7513403A2EF15BC80700@phx.gbl>
In-Reply-To: <BLU436-SMTP127FE35D7513403A2EF15BC80700@phx.gbl>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <912AC763C40DC04886D7A14108761F88@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Aug 10, 2015 at 07:28:22PM +0800, Wanpeng Li wrote:
> Hwpoison injection takes a refcount of target page and another refcount
> of head page of THP if the target page is the tail page of a THP. However=
,
> current code doesn't release the refcount of head page if the THP is not=
=20
> supported to be injected wrt hwpoison filter.=20
>=20
> Fix it by reducing the refcount of head page if the target page is the ta=
il=20
> page of a THP and it is not supported to be injected.
>=20
> Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/hwpoison-inject.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
> index 5015679..9d26fd9 100644
> --- a/mm/hwpoison-inject.c
> +++ b/mm/hwpoison-inject.c
> @@ -55,7 +55,7 @@ inject:
>  	pr_info("Injecting memory failure at pfn %#lx\n", pfn);
>  	return memory_failure(pfn, 18, MF_COUNT_INCREASED);
>  put_out:
> -	put_page(p);
> +	put_hwpoison_page(p);
>  	return 0;
>  }
> =20
> --=20
> 1.7.1
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
