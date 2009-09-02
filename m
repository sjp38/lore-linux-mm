Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5971E6B004F
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 16:02:25 -0400 (EDT)
Received: by pzk16 with SMTP id 16so829144pzk.18
        for <linux-mm@kvack.org>; Wed, 02 Sep 2009 13:02:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <ff13736137802f78cf492d13c43c1af1.squirrel@webmail-b.css.fujitsu.com>
References: <20090902.205137.71100180.ryov@valinux.co.jp>
	 <ff13736137802f78cf492d13c43c1af1.squirrel@webmail-b.css.fujitsu.com>
Date: Thu, 3 Sep 2009 01:32:24 +0530
Message-ID: <661de9470909021302ge86d01s5d107dc2b5cffbc5@mail.gmail.com>
Subject: Re: a room for blkio-cgroup in struct page_cgroup
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ryo Tsuruta <ryov@valinux.co.jp>, linux-kernel@vger.kernel.org, dm-devel@redhat.com, containers@lists.linux-foundation.org, virtualization@lists.linux-foundation.org, xen-devel@lists.xensource.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2009/9/2 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
> Ryo Tsuruta wrote:
>> Hi Kamezawa-san,
>>
>> As you wrote before (http://lkml.org/lkml/2009/7/22/65)
>>> To be honest, what I expected in these days for people of blockio
>>> cgroup is like following for getting room for themselves.
>> <<snip>>
>>> --- mmotm-2.6.31-Jul16.orig/include/linux/page_cgroup.h
>>> +++ mmotm-2.6.31-Jul16/include/linux/page_cgroup.h
>>> @@ -13,7 +13,7 @@
>>> =A0struct page_cgroup {
>>> =A0 =A0 =A0 unsigned long flags;
>>> =A0 =A0 =A0 struct mem_cgroup *mem_cgroup;
>>> - =A0 =A0 struct page *page;
>>> + =A0 =A0 /* block io tracking will use extra unsigned long bytes */
>>> =A0 =A0 =A0 struct list_head lru; =A0 =A0 =A0 /* per cgroup LRU list */
>>> };
>>
>> Have you already added a room for blkio_cgroup in struct page_cgroup?
> No.
>

The diff above is unclear, are you removing struct page from page_cgroup?

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
