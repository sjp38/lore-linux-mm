Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 15D386B0069
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 01:28:57 -0500 (EST)
Received: by ghrr18 with SMTP id r18so1690623ghr.14
        for <linux-mm@kvack.org>; Sun, 08 Jan 2012 22:28:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1326078369-2814-1-git-send-email-shijie8@gmail.com>
References: <1326078369-2814-1-git-send-email-shijie8@gmail.com>
Date: Mon, 9 Jan 2012 14:28:56 +0800
Message-ID: <CAMiH66FobuG7OCYDDi5iVrOyijovA6Jz-5-Xo2OpHD1SYEOmpw@mail.gmail.com>
Subject: Re: [PATCH] mm/page_alloc.c : fix the typo of __zone_watermark_ok()
From: Huang Shijie <shijie8@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>

sorry for the noise.

Please ignore this patch.

On Mon, Jan 9, 2012 at 11:06 AM, Huang Shijie <shijie8@gmail.com> wrote:
> The current code does keep the same meaning as the original code.
> The patch fixes it.
>
> Signed-off-by: Huang Shijie <shijie8@gmail.com>
> ---
> =C2=A0mm/page_alloc.c | =C2=A0 =C2=A02 +-
> =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bdc804c..63f9026 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1435,7 +1435,7 @@ static bool __zone_watermark_ok(struct zone *z, int=
 order, unsigned long mark,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0long min =3D mark;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int o;
>
> - =C2=A0 =C2=A0 =C2=A0 free_pages -=3D (1 << order) + 1;
> + =C2=A0 =C2=A0 =C2=A0 free_pages -=3D (1 << order) - 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (alloc_flags & ALLOC_HIGH)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0min -=3D min / 2;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (alloc_flags & ALLOC_HARDER)
> --
> 1.7.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
