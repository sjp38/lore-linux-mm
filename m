Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D641E5F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 05:24:11 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3K9OWKn030035
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 20 Apr 2009 18:24:33 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C0ADB45DD7F
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 18:24:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B4D745DD75
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 18:24:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4719B1DB803C
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 18:24:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D70D2E08005
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 18:24:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Does get_user_pages_fast lock the user pages in memory in my case?
In-Reply-To: <49EC311D.4090605@gmail.com>
References: <20090420165529.61AB.A69D9226@jp.fujitsu.com> <49EC311D.4090605@gmail.com>
Message-Id: <20090420181436.61AE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 20 Apr 2009 18:24:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> In the V4L2_MEMORY_USERPTR method, what I want to do is pin the 
> anonymous pages in memory.
> 
> I used to add the VM_LOCKED to vma associated with the pages.In my 
> opinion, the pages will:
> LRU_ACTIVE_ANON ---> LRU_INACTIVE_ANON---> LRU_UNEVICTABLE
> 
> so the pages are pinned in memory.It was ugly, but it works I think.
> Do you have any suggestions about this method?

page migration (e.g. move_pages) ignore MLOCK.
maybe, VM_LOCKED + gut()ed solved it partially :)

but, user process still can call munlock. it cause disaster.
I still think -EINVAL is better.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
