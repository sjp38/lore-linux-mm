Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 0B4596B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 16:25:54 -0500 (EST)
Received: by bkwq16 with SMTP id q16so991717bkw.14
        for <linux-mm@kvack.org>; Thu, 08 Mar 2012 13:25:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1329929337-16648-13-git-send-email-m.szyprowski@samsung.com>
References: <1329929337-16648-1-git-send-email-m.szyprowski@samsung.com> <1329929337-16648-13-git-send-email-m.szyprowski@samsung.com>
From: Sandeep Patil <psandeep.s@gmail.com>
Date: Thu, 8 Mar 2012 13:25:13 -0800
Message-ID: <CA+K6fF5aN7Z3roKOzZe+a87ey4YcLd5Fr1U794wvb+8H3qP2+w@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCHv23 12/16] mm: trigger page reclaim in
 alloc_contig_range() to stabilise watermarks
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Ohad Ben-Cohen <ohad@wizery.com>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Rob Clark <rob.clark@linaro.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> +static int __reclaim_pages(struct zone *zone, gfp_t gfp_mask, int count)
> +{
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Increase level of watermarks to force kswapd do his jo=
b
> + =A0 =A0 =A0 =A0* to stabilise at new watermark level.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 __update_cma_watermarks(zone, count);
> +
> + =A0 =A0 =A0 /* Obey watermarks as if the page was being allocated */
> + =A0 =A0 =A0 watermark =3D low_wmark_pages(zone) + count;
> + =A0 =A0 =A0 while (!zone_watermark_ok(zone, 0, watermark, 0, 0)) {

Wouldn't this reclaim (2 * count pages) above low wmark?

You are updating the low wmark first and then adding "count"
for the zone_watermark_ok() check as well ..

Sandeep

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
