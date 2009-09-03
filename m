Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 843066B0088
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 01:09:32 -0400 (EDT)
Date: Thu, 03 Sep 2009 14:09:32 +0900 (JST)
Message-Id: <20090903.140932.189713001.ryov@valinux.co.jp>
Subject: Re: a room for blkio-cgroup in struct page_cgroup
From: Ryo Tsuruta <ryov@valinux.co.jp>
In-Reply-To: <ff13736137802f78cf492d13c43c1af1.squirrel@webmail-b.css.fujitsu.com>
References: <20090902.205137.71100180.ryov@valinux.co.jp>
	<ff13736137802f78cf492d13c43c1af1.squirrel@webmail-b.css.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, dm-devel@redhat.com, containers@lists.linux-foundation.org, virtualization@lists.linux-foundation.org, xen-devel@lists.xensource.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Kamezawa-san,

"KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Ryo Tsuruta wrote:
> > Hi Kamezawa-san,
> >
> > As you wrote before (http://lkml.org/lkml/2009/7/22/65)
> >> To be honest, what I expected in these days for people of blockio
> >> cgroup is like following for getting room for themselves.
> > <<snip>>
> >> --- mmotm-2.6.31-Jul16.orig/include/linux/page_cgroup.h
> >> +++ mmotm-2.6.31-Jul16/include/linux/page_cgroup.h
> >> @@ -13,7 +13,7 @@
> >>  struct page_cgroup {
> >>       unsigned long flags;
> >>       struct mem_cgroup *mem_cgroup;
> >> -     struct page *page;
> >> +     /* block io tracking will use extra unsigned long bytes */
> >>       struct list_head lru;       /* per cgroup LRU list */
> >> };
> >
> > Have you already added a room for blkio_cgroup in struct page_cgroup?
> No.
> 
> > If not, I would like you to apply the above change to mmotm.
> >
> Plz wait until October. We're deadly busy and some amount of more important
> patches are piled up in front of us. I have no objections if you add
> a pointer or id  because I know I can reduce 8(4)bytes later.
> Just add (a small) member for a while and ignore page_cgroup's size.
> I'll fix later.

Thank you very much, but I've already added unsigned long member in the
last posted patch...

> > The latest blkio-cgroup has reflected the comments you pointed out.
> > I would also like you to give me any comments on it and consider
> > merging blkio-cgroup to mmotm.
> >
> BTW, do you all have cosensus about implementation ?

Not yet, it is under discussion now.

Thanks,
Ryo Tsuruta

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
