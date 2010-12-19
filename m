Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 774F46B0095
	for <linux-mm@kvack.org>; Sun, 19 Dec 2010 19:00:09 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBK002Ma019608
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 20 Dec 2010 09:00:03 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C235A45DE5C
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 09:00:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A8DB645DE5A
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 09:00:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BBDFE38002
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 09:00:02 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 57674E08005
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 09:00:02 +0900 (JST)
Date: Mon, 20 Dec 2010 08:54:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: add replace_page_cache_page() function
Message-Id: <20101220085413.b83d1093.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <E1PTcau-0001aw-60@pomaz-ex.szeredi.hu>
References: <E1PStc6-0006Cd-0Z@pomaz-ex.szeredi.hu>
	<20101216100744.e3a417cf.kamezawa.hiroyu@jp.fujitsu.com>
	<E1PTCae-0007tw-Un@pomaz-ex.szeredi.hu>
	<20101217090103.2a9ca19a.kamezawa.hiroyu@jp.fujitsu.com>
	<E1PTcau-0001aw-60@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Dec 2010 16:51:44 +0100
Miklos Szeredi <miklos@szeredi.hu> wrote:

> On Fri, 17 Dec 2010, KAMEZAWA Hiroyuki wrote:
> > No. memory cgroup expects all pages should be found on LRU. But, IIUC,
> > pages on this radix-tree will not be on LRU. So, memory cgroup can't find
> > it at destroying cgroup and can't reduce "usage" of resource to be 0.
> > This makes rmdir() returns -EBUSY.
> 
> Oh, right.  Yes, the page will be on the LRU (it needs to be,
> otherwise the VM coulnd't reclaim it).  After the
> add_to_page_cache_locked is this:
> 
> 	if (!(buf->flags & PIPE_BUF_FLAG_LRU))
> 		lru_cache_add_file(newpage);
> 
> It will add the page to the LRU, unless it's already on it.
> 

Thank you for clarification. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
