Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6C69B6B0038
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 21:13:10 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so73867062pdb.3
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 18:13:10 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id h7si25823410pdf.62.2015.03.16.18.13.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 18:13:09 -0700 (PDT)
Received: by pabyw6 with SMTP id yw6so81087365pab.2
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 18:13:09 -0700 (PDT)
Date: Tue, 17 Mar 2015 10:12:58 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] zsmalloc: zsmalloc documentation
Message-ID: <20150317011258.GA11994@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Juneho Choi <juno.choi@lge.com>, Gunho Lee <gunho.lee@lge.com>, Luigi Semenzato <semenzato@google.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, opensource.ganesh@gmail.com

On Wed, Mar 04, 2015 at 04:56:10PM -0800, Andrew Morton wrote:
> On Thu, 5 Mar 2015 09:43:31 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > Hello Andrew,
> > 
> > On Wed, Mar 04, 2015 at 02:02:02PM -0800, Andrew Morton wrote:
> > > On Wed,  4 Mar 2015 14:01:32 +0900 Minchan Kim <minchan@kernel.org> wrote:
> > > 
> > > > +static int zs_stats_size_show(struct seq_file *s, void *v)
> > > > +{
> > > > +	int i;
> > > > +	struct zs_pool *pool = s->private;
> > > > +	struct size_class *class;
> > > > +	int objs_per_zspage;
> > > > +	unsigned long class_almost_full, class_almost_empty;
> > > > +	unsigned long obj_allocated, obj_used, pages_used;
> > > > +	unsigned long total_class_almost_full = 0, total_class_almost_empty = 0;
> > > > +	unsigned long total_objs = 0, total_used_objs = 0, total_pages = 0;
> > > > +
> > > > +	seq_printf(s, " %5s %5s %11s %12s %13s %10s %10s %16s\n",
> > > > +			"class", "size", "almost_full", "almost_empty",
> > > > +			"obj_allocated", "obj_used", "pages_used",
> > > > +			"pages_per_zspage");
> > > 
> > > Documentation?
> > 
> > It should been since [0f050d9, mm/zsmalloc: add statistics support].
> > Anyway, I will try it.
> > Where is right place to put only this statistics in Documentation?
> > 
> > Documentation/zsmalloc.txt?
> > Documentation/vm/zsmalloc.txt?
> > Documentation/blockdev/zram.txt?
> > Documentation/ABI/testing/sysfs-block-zram?
> 
> hm, this is debugfs so Documentation/ABI/testing/sysfs-block-zram isn't
> the right place.
> 
> akpm3:/usr/src/25> grep -rli zsmalloc Documentation 
> akpm3:/usr/src/25> 
> 
> lol.
> 
> Documentation/vm/zsmalloc.txt looks good.

Here it goes.
