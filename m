Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2CFB16B01BA
	for <linux-mm@kvack.org>; Fri, 21 May 2010 20:04:35 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4M04W3i005981
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sat, 22 May 2010 09:04:32 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E38645DE50
	for <linux-mm@kvack.org>; Sat, 22 May 2010 09:04:32 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E481E45DE4F
	for <linux-mm@kvack.org>; Sat, 22 May 2010 09:04:31 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CD9511DB8014
	for <linux-mm@kvack.org>; Sat, 22 May 2010 09:04:31 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 888F71DB8013
	for <linux-mm@kvack.org>; Sat, 22 May 2010 09:04:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] tmpfs: Insert tmpfs cache pages to inactive list at first
In-Reply-To: <20100521115718.552d50dd.akpm@linux-foundation.org>
References: <20100521093629.1E44.A69D9226@jp.fujitsu.com> <20100521115718.552d50dd.akpm@linux-foundation.org>
Message-Id: <20100522085421.1E72.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sat, 22 May 2010 09:04:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > -static inline void lru_cache_add_active_anon(struct page *page)
> > -{
> > -	__lru_cache_add(page, LRU_ACTIVE_ANON);
> > -}
> > -
> >  static inline void lru_cache_add_file(struct page *page)
> >  {
> >  	__lru_cache_add(page, LRU_INACTIVE_FILE);
> >  }
> >  
> > -static inline void lru_cache_add_active_file(struct page *page)
> > -{
> > -	__lru_cache_add(page, LRU_ACTIVE_FILE);
> > -}
> 
> Did you intend to remove these two functions?

This is for applying Hannes's commnet.

> They do appear to be unused now, but they still make sense and might be
> used in the future, perhaps.  

Personally, I don't like the strategy that anyone without me might
use this function in the future. because It often never come.

> It's OK to remove them, but I'm wondering
> if it was deliberately included in this patch?

Makes sense.
OK, please drop current patch at once. I'll post V2.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
