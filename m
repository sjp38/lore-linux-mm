Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2B4B66B006A
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 20:30:14 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n830UBk7017487
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 3 Sep 2009 09:30:12 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 86F8C45DE62
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 09:30:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3EEBE45DE64
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 09:30:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A33F11DB8053
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 09:30:06 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E7EC61DB803F
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 09:30:05 +0900 (JST)
Message-ID: <fa721014d75b6e193623349bfde28124.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <661de9470909021302ge86d01s5d107dc2b5cffbc5@mail.gmail.com>
References: <20090902.205137.71100180.ryov@valinux.co.jp>
    <ff13736137802f78cf492d13c43c1af1.squirrel@webmail-b.css.fujitsu.com>
    <661de9470909021302ge86d01s5d107dc2b5cffbc5@mail.gmail.com>
Date: Thu, 3 Sep 2009 09:30:05 +0900 (JST)
Subject: Re: a room for blkio-cgroup in struct page_cgroup
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ryo Tsuruta <ryov@valinux.co.jp>, linux-kernel@vger.kernel.org, dm-devel@redhat.com, containers@lists.linux-foundation.org, virtualization@lists.linux-foundation.org, xen-devel@lists.xensource.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> 2009/9/2 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
>> Ryo Tsuruta wrote:
>>> Hi Kamezawa-san,
>>>
>>> As you wrote before (http://lkml.org/lkml/2009/7/22/65)
>>>> To be honest, what I expected in these days for people of blockio
>>>> cgroup is like following for getting room for themselves.
>>> <<snip>>
>>>> --- mmotm-2.6.31-Jul16.orig/include/linux/page_cgroup.h
>>>> +++ mmotm-2.6.31-Jul16/include/linux/page_cgroup.h
>>>> @@ -13,7 +13,7 @@
>>>> &#160;struct page_cgroup {
>>>> &#160; &#160; &#160; unsigned long flags;
>>>> &#160; &#160; &#160; struct mem_cgroup *mem_cgroup;
>>>> - &#160; &#160; struct page *page;
>>>> + &#160; &#160; /* block io tracking will use extra unsigned long
bytes */
>>>> &#160; &#160; &#160; struct list_head lru; &#160; &#160; &#160; /*
per cgroup LRU list */
>>>> };
>>>
>>> Have you already added a room for blkio_cgroup in struct page_cgroup?
>> No.
>>
>
> The diff above is unclear, are you removing struct page from page_cgroup?
>
I said him "if you want a room, plz get by youself, consider more"
And offered this change.
 http://lkml.org/lkml/2009/7/22/65
you were CC'd.
Because page_cgroup's layout is same to memmap, we can use similar function
as
  page_cgroup_to_pfn(), pfn_to_page_cgroup().
And, we don't access page_cgroup->page in fast path. (maybe)
But as I wrote, we're busy. I'll not do this until all performance fixes
go ahead.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
