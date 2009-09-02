Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 12DA06B005A
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 07:51:32 -0400 (EDT)
Date: Wed, 02 Sep 2009 20:51:37 +0900 (JST)
Message-Id: <20090902.205137.71100180.ryov@valinux.co.jp>
Subject: a room for blkio-cgroup in struct page_cgroup
From: Ryo Tsuruta <ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, dm-devel@redhat.com, containers@lists.linux-foundation.org, virtualization@lists.linux-foundation.org, xen-devel@lists.xensource.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Kamezawa-san,

As you wrote before (http://lkml.org/lkml/2009/7/22/65)
> To be honest, what I expected in these days for people of blockio
> cgroup is like following for getting room for themselves.
<<snip>>
> --- mmotm-2.6.31-Jul16.orig/include/linux/page_cgroup.h
> +++ mmotm-2.6.31-Jul16/include/linux/page_cgroup.h
> @@ -13,7 +13,7 @@
>  struct page_cgroup {
>       unsigned long flags;
>       struct mem_cgroup *mem_cgroup;
> -     struct page *page;
> +     /* block io tracking will use extra unsigned long bytes */
>       struct list_head lru;       /* per cgroup LRU list */
> };

Have you already added a room for blkio_cgroup in struct page_cgroup?
If not, I would like you to apply the above change to mmotm.

The latest blkio-cgroup has reflected the comments you pointed out.
I would also like you to give me any comments on it and consider
merging blkio-cgroup to mmotm.

Thank you for your help in advance.
Ryo Tsuruta

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
