Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD466B0038
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 00:21:28 -0400 (EDT)
Received: by igbhj9 with SMTP id hj9so6207993igb.1
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 21:21:27 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id a1si614529ioj.29.2015.04.20.21.21.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Apr 2015 21:21:25 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm, hwpoison: Remove obsolete "Notebook" todo list
Date: Tue, 21 Apr 2015 04:20:53 +0000
Message-ID: <20150421042053.GF21832@hori1.linux.bs1.fc.nec.co.jp>
References: <1429553383-11466-1-git-send-email-andi@firstfloor.org>
In-Reply-To: <1429553383-11466-1-git-send-email-andi@firstfloor.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <653DB8B181AFF340943DF418B8CDD7F2@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <ak@linux.intel.com>

On Mon, Apr 20, 2015 at 11:09:43AM -0700, Andi Kleen wrote:
> From: Andi Kleen <ak@linux.intel.com>
>=20
> All the items mentioned here have been either addressed, or were
> not really needed. So just remove the comment.
>=20
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Thanks!

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/memory-failure.c | 7 -------
>  1 file changed, 7 deletions(-)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index d487f8d..25c2054 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -28,13 +28,6 @@
>   * are rare we hope to get away with this. This avoids impacting the cor=
e=20
>   * VM.
>   */
> -
> -/*
> - * Notebook:
> - * - hugetlb needs more code
> - * - kcore/oldmem/vmcore/mem/kmem check for hwpoison pages
> - * - pass bad pages to kdump next kernel
> - */
>  #include <linux/kernel.h>
>  #include <linux/mm.h>
>  #include <linux/page-flags.h>
> --=20
> 1.9.3
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
