Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BE4296B004F
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 19:08:05 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0M082FW017823
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 22 Jan 2009 09:08:03 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CB40445DE55
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 09:08:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A024145DE51
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 09:08:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E99E1DB8040
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 09:08:02 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FF5C1DB8038
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 09:08:02 +0900 (JST)
Date: Thu, 22 Jan 2009 09:06:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Question: Is  zone->prev_prirotiy  used ?
Message-Id: <20090122090657.7c1d7b56.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090123084500.421C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20090121155219.8b870167.kamezawa.hiroyu@jp.fujitsu.com>
	<20090121071718.GA17969@barrios-desktop>
	<20090123084500.421C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: MinChan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jan 2009 08:54:07 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > On Wed, Jan 21, 2009 at 03:52:19PM +0900, KAMEZAWA Hiroyuki wrote:
> > > Just a question.
> > > 
> > > In vmscan.c,  zone->prev_priority doesn't seem to be used.
> > > 
> > > Is it for what, now ?
> > 
> > It's the purpose of reclaiming mapped pages before split-lru.
> > Now, get_scan_ratio can do it. 
> > I think it is a meaningless variable.
> > How about Kosaki and Rik ?
> 
> Right.
> I thought this variable can use for future enhancement. 
> then I didn't removed.
> 
example ?

> Kamezawa-san, does its variable prevent your development?
> if so, I don't oppose removing.
> 

Hmm, I tried to fix/clean up hierarchical-memory-reclaim + split-LRU and
wondered where prev_priority should be recorded (hierarchy root or local or..)
and found prev_priority is not used.

IMHO, LRU management is too complex to keep unnecessary code maintained just
because it may be used in future. I personally like to rewrite better new code
rather than reuse old ruins.

But I'm not in hurry. I just wanted to confirm.

BTW, I noticed mem_cgroup_calc_mapped_ratio() is not used, either ;)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
