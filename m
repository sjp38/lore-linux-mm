Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 4E00C6B0008
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 07:55:14 -0500 (EST)
Received: by mail-ia0-f172.google.com with SMTP id u8so8124702iag.31
        for <linux-mm@kvack.org>; Mon, 04 Feb 2013 04:55:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1359973626-3900-1-git-send-email-m.szyprowski@samsung.com>
References: <1359973626-3900-1-git-send-email-m.szyprowski@samsung.com>
Date: Mon, 4 Feb 2013 21:55:13 +0900
Message-ID: <CAH9JG2XKry8fXueqM7qxbbkBXvuQrpodPxD-G8w8dpaLdLw9+g@mail.gmail.com>
Subject: Re: [PATCH] mm: cma: fix accounting of CMA pages placed in high memory
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: multipart/alternative; boundary=20cf30334ac39f659804d4e59a5a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "mgorman@suse.de" <mgorman@suse.de>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>

--20cf30334ac39f659804d4e59a5a
Content-Type: text/plain; charset=ISO-8859-1

On Monday, February 4, 2013, Marek Szyprowski wrote:

> The total number of low memory pages is determined as
> totalram_pages - totalhigh_pages, so without this patch all CMA
> pageblocks placed in highmem were accounted to low memory.
>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com <javascript:;>>

Acked-by: Kyungmin Park <kyungmin.park@samsung.com>

> ---
>  mm/page_alloc.c |    4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f5bab0a..6415d93 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -773,6 +773,10 @@ void __init init_cma_reserved_pageblock(struct page
> *page)
>         set_pageblock_migratetype(page, MIGRATE_CMA);
>         __free_pages(page, pageblock_order);
>         totalram_pages += pageblock_nr_pages;
> +#ifdef CONFIG_HIGHMEM
> +       if (PageHighMem(page))
> +               totalhigh_pages += pageblock_nr_pages;
> +#endif
>  }
>  #endif
>
> --
> 1.7.9.5
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org <javascript:;>.  For more info on Linux
> MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org <javascript:;>">
> email@kvack.org <javascript:;> </a>
>

--20cf30334ac39f659804d4e59a5a
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br>On Monday, February 4, 2013, Marek Szyprowski  wrote:<br><blockquot=
e class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc sol=
id;padding-left:1ex">The total number of low memory pages is determined as<=
br>

totalram_pages - totalhigh_pages, so without this patch all CMA<br>
pageblocks placed in highmem were accounted to low memory.<br>
<br>
Signed-off-by: Marek Szyprowski &lt;<a href=3D"javascript:;" onclick=3D"_e(=
event, &#39;cvml&#39;, &#39;m.szyprowski@samsung.com&#39;)">m.szyprowski@sa=
msung.com</a>&gt;</blockquote><div>Acked-by: Kyungmin Park &lt;<a href=3D"m=
ailto:kyungmin.park@samsung.com">kyungmin.park@samsung.com</a>&gt;<span></s=
pan>=A0</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
---<br>
=A0mm/page_alloc.c | =A0 =A04 ++++<br>
=A01 file changed, 4 insertions(+)<br>
<br>
diff --git a/mm/page_alloc.c b/mm/page_alloc.c<br>
index f5bab0a..6415d93 100644<br>
--- a/mm/page_alloc.c<br>
+++ b/mm/page_alloc.c<br>
@@ -773,6 +773,10 @@ void __init init_cma_reserved_pageblock(struct page *p=
age)<br>
=A0 =A0 =A0 =A0 set_pageblock_migratetype(page, MIGRATE_CMA);<br>
=A0 =A0 =A0 =A0 __free_pages(page, pageblock_order);<br>
=A0 =A0 =A0 =A0 totalram_pages +=3D pageblock_nr_pages;<br>
+#ifdef CONFIG_HIGHMEM<br>
+ =A0 =A0 =A0 if (PageHighMem(page))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 totalhigh_pages +=3D pageblock_nr_pages;<br>
+#endif<br>
=A0}<br>
=A0#endif<br>
<br>
--<br>
1.7.9.5<br>
<br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"javascript:;" onclick=3D"_e(event, &#39;cvml&#39;, &=
#39;majordomo@kvack.org&#39;)">majordomo@kvack.org</a>. =A0For more info on=
 Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www.linu=
x-mm.org/</a> .<br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"javascript:;" onclick=
=3D"_e(event, &#39;cvml&#39;, &#39;dont@kvack.org&#39;)">dont@kvack.org</a>=
&quot;&gt; <a href=3D"javascript:;" onclick=3D"_e(event, &#39;cvml&#39;, &#=
39;email@kvack.org&#39;)">email@kvack.org</a> &lt;/a&gt;<br>

</blockquote>

--20cf30334ac39f659804d4e59a5a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
