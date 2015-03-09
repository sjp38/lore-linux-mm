Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id DCB346B0032
	for <linux-mm@kvack.org>; Sun,  8 Mar 2015 20:05:17 -0400 (EDT)
Received: by padbj1 with SMTP id bj1so34530442pad.12
        for <linux-mm@kvack.org>; Sun, 08 Mar 2015 17:05:17 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id y5si26477669pdn.35.2015.03.08.17.05.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Mar 2015 17:05:16 -0700 (PDT)
Received: by paceu11 with SMTP id eu11so54145261pac.1
        for <linux-mm@kvack.org>; Sun, 08 Mar 2015 17:05:16 -0700 (PDT)
Date: Mon, 9 Mar 2015 09:05:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 3/7] zsmalloc: support compaction
Message-ID: <20150309000506.GA15184@blaptop>
References: <1425445292-29061-1-git-send-email-minchan@kernel.org>
 <1425445292-29061-4-git-send-email-minchan@kernel.org>
 <54F7E719.6070505@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F7E719.6070505@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heesub Shin <heesub.shin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Juneho Choi <juno.choi@lge.com>, Gunho Lee <gunho.lee@lge.com>, Luigi Semenzato <semenzato@google.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, opensource.ganesh@gmail.com

Hello Heesub,

On Thu, Mar 05, 2015 at 02:18:17PM +0900, Heesub Shin wrote:
> Hello Minchan,
> 
> Nice work!

Thanks. :)

> 
> On 03/04/2015 02:01 PM, Minchan Kim wrote:
> > +static void putback_zspage(struct zs_pool *pool, struct size_class *class,
> > +				struct page *first_page)
> > +{
> > +	int class_idx;
> > +	enum fullness_group fullness;
> > +
> > +	BUG_ON(!is_first_page(first_page));
> > +
> > +	get_zspage_mapping(first_page, &class_idx, &fullness);
> > +	insert_zspage(first_page, class, fullness);
> > +	fullness = fix_fullness_group(class, first_page);
> 
> Removal and re-insertion of zspage above can be eliminated, like this:
> 
> 	fullness = get_fullness_group(first_page);
> 	insert_zspage(first_page, class, fullness);
> 	set_zspage_mapping(first_page, class->index, fullness);

True.

Thanks for the review!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
