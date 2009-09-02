Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7B3516B005A
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 09:12:54 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n82DCuYp002596
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 2 Sep 2009 22:12:56 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 25CD645DE4E
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 22:12:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 05AD845DE4C
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 22:12:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DE9B4E08001
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 22:12:55 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F6051DB8038
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 22:12:52 +0900 (JST)
Message-ID: <ff13736137802f78cf492d13c43c1af1.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090902.205137.71100180.ryov@valinux.co.jp>
References: <20090902.205137.71100180.ryov@valinux.co.jp>
Date: Wed, 2 Sep 2009 22:12:51 +0900 (JST)
Subject: Re: a room for blkio-cgroup in struct page_cgroup
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Ryo Tsuruta <ryov@valinux.co.jp>
Cc: kamezawa.hiroyu@jp.fujitsu.com, balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, dm-devel@redhat.com, containers@lists.linux-foundation.org, virtualization@lists.linux-foundation.org, xen-devel@lists.xensource.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ryo Tsuruta wrote:
> Hi Kamezawa-san,
>
> As you wrote before (http://lkml.org/lkml/2009/7/22/65)
>> To be honest, what I expected in these days for people of blockio
>> cgroup is like following for getting room for themselves.
> <<snip>>
>> --- mmotm-2.6.31-Jul16.orig/include/linux/page_cgroup.h
>> +++ mmotm-2.6.31-Jul16/include/linux/page_cgroup.h
>> @@ -13,7 +13,7 @@
>>  struct page_cgroup {
>>       unsigned long flags;
>>       struct mem_cgroup *mem_cgroup;
>> -     struct page *page;
>> +     /* block io tracking will use extra unsigned long bytes */
>>       struct list_head lru;       /* per cgroup LRU list */
>> };
>
> Have you already added a room for blkio_cgroup in struct page_cgroup?
No.

> If not, I would like you to apply the above change to mmotm.
>
Plz wait until October. We're deadly busy and some amount of more important
patches are piled up in front of us. I have no objections if you add
a pointer or id  because I know I can reduce 8(4)bytes later.
Just add (a small) member for a while and ignore page_cgroup's size.
I'll fix later.

> The latest blkio-cgroup has reflected the comments you pointed out.
> I would also like you to give me any comments on it and consider
> merging blkio-cgroup to mmotm.
>
BTW, do you all have cosensus about implementation ?

Bye,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
