Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 441EF6002CC
	for <linux-mm@kvack.org>; Fri, 21 May 2010 20:34:01 -0400 (EDT)
Date: Fri, 21 May 2010 17:32:15 -0400
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] tmpfs: Insert tmpfs cache pages to inactive list at
 first
Message-Id: <20100521173215.e2240f5b.akpm@linux-foundation.org>
In-Reply-To: <20100522085421.1E72.A69D9226@jp.fujitsu.com>
References: <20100521093629.1E44.A69D9226@jp.fujitsu.com>
	<20100521115718.552d50dd.akpm@linux-foundation.org>
	<20100522085421.1E72.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 22 May 2010 09:04:30 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > > -static inline void lru_cache_add_active_anon(struct page *page)
> > > -{
> > > -	__lru_cache_add(page, LRU_ACTIVE_ANON);
> > > -}
> > > -
> > >  static inline void lru_cache_add_file(struct page *page)
> > >  {
> > >  	__lru_cache_add(page, LRU_INACTIVE_FILE);
> > >  }
> > >  
> > > -static inline void lru_cache_add_active_file(struct page *page)
> > > -{
> > > -	__lru_cache_add(page, LRU_ACTIVE_FILE);
> > > -}
> > 
> > Did you intend to remove these two functions?
> 
> This is for applying Hannes's commnet.
> 
> > They do appear to be unused now, but they still make sense and might be
> > used in the future, perhaps.  
> 
> Personally, I don't like the strategy that anyone without me might
> use this function in the future. because It often never come.
> 
> > It's OK to remove them, but I'm wondering
> > if it was deliberately included in this patch?
> 
> Makes sense.
> OK, please drop current patch at once. I'll post V2.

Is OK, let's keep the change.  I just wanted to check that it wasn't
made accidentally.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
