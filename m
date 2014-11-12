Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 26AE36B00E3
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 11:33:49 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id y13so12501618pdi.6
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 08:33:48 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id bi2si23247802pbb.68.2014.11.12.08.33.45
        for <linux-mm@kvack.org>;
        Wed, 12 Nov 2014 08:33:45 -0800 (PST)
Message-ID: <54638BE4.3080509@sr71.net>
Date: Wed, 12 Nov 2014 08:33:40 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/5] mm/page_ext: resurrect struct page extending
 code for debugging
References: <1415780835-24642-1-git-send-email-iamjoonsoo.kim@lge.com> <1415780835-24642-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1415780835-24642-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Alexander Nyberg <alexn@dsv.su.se>, Dave Hansen <dave@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/12/2014 12:27 AM, Joonsoo Kim wrote:
> @@ -1092,6 +1096,14 @@ struct mem_section {
>  
>  	/* See declaration of similar field in struct zone */
>  	unsigned long *pageblock_flags;
> +#ifdef CONFIG_PAGE_EXTENSION
> +	/*
> +	 * If !SPARSEMEM, pgdat doesn't have page_ext pointer. We use
> +	 * section. (see page_ext.h about this.)
> +	 */
> +	struct page_ext *page_ext;
> +	unsigned long pad;
> +#endif

Will the distributions be amenable to enabling this?  If so, I'm all for
it if it gets us things like page_owner at runtime.

If not, this becomes of much more questionable utility.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
