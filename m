Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id CBDB96B0035
	for <linux-mm@kvack.org>; Fri,  4 Jul 2014 08:52:13 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id r20so12997941wiv.2
        for <linux-mm@kvack.org>; Fri, 04 Jul 2014 05:52:13 -0700 (PDT)
Received: from mail-we0-x229.google.com (mail-we0-x229.google.com [2a00:1450:400c:c03::229])
        by mx.google.com with ESMTPS id ca17si28368652wib.45.2014.07.04.05.52.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 04 Jul 2014 05:52:10 -0700 (PDT)
Received: by mail-we0-f169.google.com with SMTP id t60so1646877wes.28
        for <linux-mm@kvack.org>; Fri, 04 Jul 2014 05:52:10 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 01/10] mm/page_alloc: remove unlikely macro on free_one_page()
In-Reply-To: <1404460675-24456-2-git-send-email-iamjoonsoo.kim@lge.com>
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com> <1404460675-24456-2-git-send-email-iamjoonsoo.kim@lge.com>
Date: Fri, 04 Jul 2014 14:52:06 +0200
Message-ID: <xa1t38ehqoax.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 04 2014, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> Isolation is really rare case so !is_migrate_isolate() is
> likely case. Remove unlikely macro.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>



> ---
>  mm/page_alloc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8dac0f0..0d4cf7a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -735,7 +735,7 @@ static void free_one_page(struct zone *zone,
>  	zone->pages_scanned =3D 0;
>=20=20
>  	__free_one_page(page, pfn, zone, order, migratetype);
> -	if (unlikely(!is_migrate_isolate(migratetype)))
> +	if (!is_migrate_isolate(migratetype))
>  		__mod_zone_freepage_state(zone, 1 << order, migratetype);
>  	spin_unlock(&zone->lock);
>  }
> --=20
> 1.7.9.5
>

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
