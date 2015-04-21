Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id B491D900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 19:36:05 -0400 (EDT)
Received: by igbyr2 with SMTP id yr2so100528761igb.0
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 16:36:05 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id hb16si3098558icb.80.2015.04.21.16.36.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 16:36:05 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm, hwpoison: Add comment describing when to add new
 cases
Date: Tue, 21 Apr 2015 23:29:54 +0000
Message-ID: <20150421232954.GA2914@hori1.linux.bs1.fc.nec.co.jp>
References: <1429639890-14116-1-git-send-email-andi@firstfloor.org>
In-Reply-To: <1429639890-14116-1-git-send-email-andi@firstfloor.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <CB56391C2B8A4248AF629218BBAC58E8@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <ak@linux.intel.com>

On Tue, Apr 21, 2015 at 11:11:30AM -0700, Andi Kleen wrote:
> From: Andi Kleen <ak@linux.intel.com>
>=20
> Here's another comment fix for hwpoison.
>=20
> It describes the "guiding principle" on when to add new
> memory error recovery code.
>=20
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/memory-failure.c | 7 +++++++
>  1 file changed, 7 insertions(+)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 25c2054..d553993 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -20,6 +20,13 @@
>   * this code has to be extremely careful. Generally it tries to use=20
>   * normal locking rules, as in get the standard locks, even if that mean=
s=20
>   * the error handling takes potentially a long time.
> + *
> + * It can be very tempting to add handling for obscure cases here.
> + * In general any code for handling new cases should only be added if:
> + * - You know how to test it.
> + * - You have a test that can be added to mce-test
> + * - The case actually shows up as a frequent (top 10) page state in
> + *   tools/vm/page-types when running a real workload.
>   *=20
>   * There are several operations here with exponential complexity because
>   * of unsuitable VM data structures. For example the operation to map ba=
ck=20
> --=20
> 1.9.3
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
