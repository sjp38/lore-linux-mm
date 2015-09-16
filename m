Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2301D6B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 22:58:05 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so194366774pad.3
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 19:58:04 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id g7si36772609pat.209.2015.09.15.19.58.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Sep 2015 19:58:04 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp ([10.7.69.202])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t8G2w0Ks017535
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 11:58:01 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1] mm: migrate: hugetlb: putback destination hugepage
 to active list
Date: Wed, 16 Sep 2015 02:53:46 +0000
Message-ID: <20150916025344.GA18550@hori1.linux.bs1.fc.nec.co.jp>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
 <1442362850-23261-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1442362850-23261-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <505BE543B0BD5E43864715FEE6EE4947@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

my bad, this patch is totally unrelated to the thread the previous email
replied to. I just mishandled my script wrapping git-send-email, sorry.

But just resending patch seems to be noisy, so I want this to be reviewed
on this email.
If it's inconvenient or uncommon way of submission, please let me know and
I'll resend in a new thread.

Thanks,
Naoya Horiguchi

On Wed, Sep 16, 2015 at 12:21:04AM +0000, Naoya Horiguchi wrote:
> Since commit bcc54222309c ("mm: hugetlb: introduce page_huge_active")
> each hugetlb page maintains its active flag to avoid a race condition bet=
ween
> multiple calls of isolate_huge_page(), but current kernel doesn't set the=
 flag
> on a hugepage allocated by migration because the proper putback routine i=
sn't
> called. This means that users could still encounter the race referred to =
by
> bcc54222309c in this special case, so this patch fixes it.
>=20
> Fixes: bcc54222309c ("mm: hugetlb: introduce page_huge_active")
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: <stable@vger.kernel.org>  #4.1
> ---
>  mm/migrate.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git v4.3-rc1/mm/migrate.c v4.3-rc1_patched/mm/migrate.c
> index c3cb566af3e2..7452a00bbb50 100644
> --- v4.3-rc1/mm/migrate.c
> +++ v4.3-rc1_patched/mm/migrate.c
> @@ -1075,7 +1075,7 @@ static int unmap_and_move_huge_page(new_page_t get_=
new_page,
>  	if (rc !=3D MIGRATEPAGE_SUCCESS && put_new_page)
>  		put_new_page(new_hpage, private);
>  	else
> -		put_page(new_hpage);
> +		putback_active_hugepage(new_hpage);
> =20
>  	if (result) {
>  		if (rc)
> --=20
> 2.4.3
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
