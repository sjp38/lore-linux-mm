Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5F8EE6B048D
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 18:38:35 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id y71so277240977pgd.0
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 15:38:35 -0800 (PST)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id 7si10364251pgt.1.2016.11.18.15.38.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 15:38:34 -0800 (PST)
Received: by mail-pf0-x229.google.com with SMTP id 189so56629898pfz.3
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 15:38:34 -0800 (PST)
Date: Fri, 18 Nov 2016 15:38:25 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] shmem: fix compilation warnings on unused functions
In-Reply-To: <20161118055749.11313-1-jeremy.lefaure@lse.epita.fr>
Message-ID: <alpine.LSU.2.11.1611181536170.11302@eggly.anvils>
References: <20161118055749.11313-1-jeremy.lefaure@lse.epita.fr>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="0-1786005043-1479512311=:11302"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeremy Lefaure <jeremy.lefaure@lse.epita.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-1786005043-1479512311=:11302
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 18 Nov 2016, Jeremy Lefaure wrote:

> Compiling shmem.c with CONFIG_SHMEM and
> CONFIG_TRANSAPRENT_HUGE_PAGECACHE enabled raises warnings on two unused
> functions when CONFIG_TMPFS and CONFIG_SYSFS are both disabled:
>=20
> mm/shmem.c:390:20: warning: =E2=80=98shmem_format_huge=E2=80=99 defined b=
ut not used
> [-Wunused-function]
>  static const char *shmem_format_huge(int huge)
>                     ^~~~~~~~~~~~~~~~~
> mm/shmem.c:373:12: warning: =E2=80=98shmem_parse_huge=E2=80=99 defined bu=
t not used
> [-Wunused-function]
>  static int shmem_parse_huge(const char *str)
>              ^~~~~~~~~~~~~~~~
>=20
> A conditional compilation on tmpfs or sysfs removes the warnings.
>=20
> Signed-off-by: Jeremy Lefaure <jeremy.lefaure@lse.epita.fr>

Acked-by: Hugh Dickins <hughd@google.com>

Thank you!

> ---
>  mm/shmem.c | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 2c74186..99595d8 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -370,6 +370,7 @@ static bool shmem_confirm_swap(struct address_space *=
mapping,
> =20
>  int shmem_huge __read_mostly;
> =20
> +#if defined(CONFIG_SYSFS) || defined(CONFIG_TMPFS)
>  static int shmem_parse_huge(const char *str)
>  {
>  =09if (!strcmp(str, "never"))
> @@ -407,6 +408,7 @@ static const char *shmem_format_huge(int huge)
>  =09=09return "bad_val";
>  =09}
>  }
> +#endif
> =20
>  static unsigned long shmem_unused_huge_shrink(struct shmem_sb_info *sbin=
fo,
>  =09=09struct shrink_control *sc, unsigned long nr_to_split)
> --=20
> 2.10.2
--0-1786005043-1479512311=:11302--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
