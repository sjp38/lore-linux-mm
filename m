Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4FE4B620002
	for <linux-mm@kvack.org>; Fri, 25 Dec 2009 00:14:39 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBP5Ea7S004506
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 25 Dec 2009 14:14:36 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6154445DE4E
	for <linux-mm@kvack.org>; Fri, 25 Dec 2009 14:14:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B30C45DE4F
	for <linux-mm@kvack.org>; Fri, 25 Dec 2009 14:14:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 19B98E38001
	for <linux-mm@kvack.org>; Fri, 25 Dec 2009 14:14:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BBABD1DB803A
	for <linux-mm@kvack.org>; Fri, 25 Dec 2009 14:14:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: 2.6.28.10 - kernel BUG at mm/rmap.c:725
In-Reply-To: <2375c9f90912242056h29f20dc5rb3f891c732e0d362@mail.gmail.com>
References: <f19d625d0912240309g5c066de7pc4dc9d95c084d4df@mail.gmail.com> <2375c9f90912242056h29f20dc5rb3f891c732e0d362@mail.gmail.com>
Message-Id: <20091225135840.AA81.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Fri, 25 Dec 2009 14:14:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Americo Wang <xiyou.wangcong@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, CoolCold <coolthecold@gmail.com>, Linux kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk
List-ID: <linux-mm.kvack.org>

> On Thu, Dec 24, 2009 at 7:09 PM, CoolCold <coolthecold@gmail.com> wrote:
> > 3 days ago LA on server become very high and it was working very
> > strange, so was rebooted. There are such entryies in log about kernel
> > bug - kernel BUG at mm/rmap.c:725! . Googling didn't provide me with
> > exact answer is it bug or hardware problems, something similar was
> > here https://bugs.launchpad.net/ubuntu/+source/linux/+bug/252977/comments/56
> > In general this server had number of unexpected stalls during several
> > months, but there is no ipkvm, so i can't say where something on
> > console or not. Hope you will help.
> >
> > Kernel version is 2.6.28.10 , self-builded. System - Debian stable/testing.
> >
> > Please reply to me directly, cuz i'm not subsribed to list.
> >
> > Dec 21 22:05:01 gamma kernel: Eeek! page_mapcount(page) went negative! (-1)
> > Dec 21 22:05:01 gamma kernel: A  page pfn = 1f2c81
> > Dec 21 22:05:01 gamma kernel: A  page->flags = 20000000008007c

PG_referenced | PG_uptodate | PG_dirty | PG_lru | PG_active | PG_swapbacked

> > Dec 21 22:05:01 gamma kernel: A  page->count = 2
> > Dec 21 22:05:01 gamma kernel: A  page->mapping = ffff8801fd870b58
> > Dec 21 22:05:01 gamma kernel: A  vma->vm_ops = 0xffffffff80535020
> > Dec 21 22:05:01 gamma kernel: A  vma->vm_ops->fault = shmem_fault+0x0/0x69
> > Dec 21 22:05:01 gamma kernel: A  vma->vm_file->f_op->mmap = shmem_mmap+0x0/0x2e
> > Dec 21 22:05:01 gamma kernel: ------------[ cut here ]------------
> > Dec 21 22:05:01 gamma kernel: kernel BUG at mm/rmap.c:725!
> 
> Hey,
> 
> commit 3dc147414cc already removed this BUG(), not sure
> how serious this is...

Very serious. but We don't seen this bug for very long time. thus I bet
it's hardware corruption.

> 
> Adding mm people into Cc.
> 
> Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
