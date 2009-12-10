Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 217C76B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 18:46:19 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBANkFGg031754
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 11 Dec 2009 08:46:15 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B26C45DE54
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 08:46:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 48A1845DE4D
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 08:46:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 15E391DB803B
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 08:46:15 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CD3FC1DB8040
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 08:46:12 +0900 (JST)
Date: Fri, 11 Dec 2009 08:42:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC mm][PATCH 1/5] mm counter cleanup
Message-Id: <20091211084255.ec7d3f49.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0912101126480.5481@router.home>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
	<20091210163326.28bb7eb8.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0912101126480.5481@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Thu, 10 Dec 2009 11:30:46 -0600 (CST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Thu, 10 Dec 2009, KAMEZAWA Hiroyuki wrote:
> 
> > This patch modifies it to
> >   - Define them in mm.h as inline functions
> >   - Use array instead of macro's name creation. For making easier to add
> >     new coutners.
> 
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> 
> > @@ -454,8 +456,8 @@ static struct mm_struct * mm_init(struct
> >  		(current->mm->flags & MMF_INIT_MASK) : default_dump_filter;
> >  	mm->core_state = NULL;
> >  	mm->nr_ptes = 0;
> > -	set_mm_counter(mm, file_rss, 0);
> > -	set_mm_counter(mm, anon_rss, 0);
> > +	for (i = 0; i < NR_MM_COUNTERS; i++)
> > +		set_mm_counter(mm, i, 0);
> 
> 
> memset? Or add a clear_mm_counter function? This also occurred earlier in
> init_rss_vec().
> 
Ok, I'll try some cleaner codes.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
