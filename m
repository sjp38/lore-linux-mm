Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id CCA816B004D
	for <linux-mm@kvack.org>; Thu, 10 May 2012 22:19:30 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3638180pbb.14
        for <linux-mm@kvack.org>; Thu, 10 May 2012 19:19:30 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH] cma: fix migration mode
References: <1336664003-5031-1-git-send-email-minchan@kernel.org>
Date: Thu, 10 May 2012 19:19:19 -0700
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.wd4gqhfm3l0zgt@mpn-glaptop>
In-Reply-To: <1336664003-5031-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>

On Thu, 10 May 2012 08:33:23 -0700, Minchan Kim <minchan@kernel.org> wro=
te:
> __alloc_contig_migrate_range calls migrate_pages with wrong argument
> for migrate_mode. Fix it.
>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  mm/page_alloc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4d926f1..9febc62 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5689,7 +5689,7 @@ static int __alloc_contig_migrate_range(unsigned=
 long start, unsigned long end)
> 		ret =3D migrate_pages(&cc.migratepages,
>  				    __alloc_contig_migrate_alloc,
> -				    0, false, true);
> +				    0, false, MIGRATE_SYNC);
>  	}
> 	putback_lru_pages(&cc.migratepages);


-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
