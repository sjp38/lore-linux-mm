Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id C497D6B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 19:43:40 -0500 (EST)
Received: by pdev10 with SMTP id v10so15227723pde.0
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 16:43:40 -0800 (PST)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com. [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id w8si7157162pde.58.2015.03.04.16.43.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 16:43:40 -0800 (PST)
Received: by pdjz10 with SMTP id z10so10703839pdj.11
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 16:43:39 -0800 (PST)
Date: Thu, 5 Mar 2015 09:43:31 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 7/7] zsmalloc: add fullness into stat
Message-ID: <20150305004330.GB2592@blaptop>
References: <1425445292-29061-1-git-send-email-minchan@kernel.org>
 <1425445292-29061-8-git-send-email-minchan@kernel.org>
 <20150304140202.905f566b7107e2735d075b27@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150304140202.905f566b7107e2735d075b27@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Juneho Choi <juno.choi@lge.com>, Gunho Lee <gunho.lee@lge.com>, Luigi Semenzato <semenzato@google.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, opensource.ganesh@gmail.com

Hello Andrew,

On Wed, Mar 04, 2015 at 02:02:02PM -0800, Andrew Morton wrote:
> On Wed,  4 Mar 2015 14:01:32 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > +static int zs_stats_size_show(struct seq_file *s, void *v)
> > +{
> > +	int i;
> > +	struct zs_pool *pool = s->private;
> > +	struct size_class *class;
> > +	int objs_per_zspage;
> > +	unsigned long class_almost_full, class_almost_empty;
> > +	unsigned long obj_allocated, obj_used, pages_used;
> > +	unsigned long total_class_almost_full = 0, total_class_almost_empty = 0;
> > +	unsigned long total_objs = 0, total_used_objs = 0, total_pages = 0;
> > +
> > +	seq_printf(s, " %5s %5s %11s %12s %13s %10s %10s %16s\n",
> > +			"class", "size", "almost_full", "almost_empty",
> > +			"obj_allocated", "obj_used", "pages_used",
> > +			"pages_per_zspage");
> 
> Documentation?

It should been since [0f050d9, mm/zsmalloc: add statistics support].
Anyway, I will try it.
Where is right place to put only this statistics in Documentation?

Documentation/zsmalloc.txt?
Documentation/vm/zsmalloc.txt?
Documentation/blockdev/zram.txt?
Documentation/ABI/testing/sysfs-block-zram?

I hope you suggest.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
