Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A83626B01AF
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 23:30:31 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5M3UTqe021859
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 22 Jun 2010 12:30:29 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EE06145DE51
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 12:30:28 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C5ECF45DE4E
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 12:30:28 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A19881DB8053
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 12:30:28 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 580481DB8050
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 12:30:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [Lsf10-pc] Current MM topics for LSF10/MM Summit 8-9 August in Boston
In-Reply-To: <20100621131608.GW5787@random.random>
References: <20100621120526.GA31679@laptop> <20100621131608.GW5787@random.random>
Message-Id: <20100622122813.B566.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 22 Jun 2010 12:30:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf10-pc@lists.linuxfoundation.org, linux-scsi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Mon, Jun 21, 2010 at 10:05:26PM +1000, Nick Piggin wrote:
> > Andrea Arcangeli	Transparent hugepages
> 
> Sure fine on my side. I got a proposal accepted for presentation at
> KVM Forum 2010 about it too the days after the VM summit too.
> 
> > KOSAKI Motohiro		get_user_pages vs COW problem
> 
> Just a side note, not sure exactly what is meant to be discussed about
> this bug, considering the fact this is still unsolved isn't technical
> problem as there were plenty of fixes available, and the one that seem
> to had better chance to get included was the worst one in my view, as
> it tried to fix it in a couple of gup caller (but failed, also because
> finding all put_page pin release is kind of a pain as they're spread
> all over the place and not identified as gup_put_page, and in addition
> to the instability and lack of completeness of the fix, it was also
> the most inefficient as it added unnecessary and coarse locking) plus
> all gup callers are affected, not just a few. I normally call it gup
> vs fork race. Luckily not all threaded apps uses O_DIRECT and fork and
> pretend to do the direct-io in different sub-page chunks of the same
> page from different threads (KVM would probably be affected if it
> didn't use MADV_DONTFORK on the O_DIRECT memory, as it might run fork
> to execute some network script when adding an hotplug pci net device
> for example). But surely we can discuss the fix we prefer for this
> bug, or at least we can agree it needs fixing.

If people don't want this. I'm ok to drop this. In my personal concern
most important topics are following four topics. (again it's only _my_
concern)


Rik van Riel		Memory management under virtualization (with KVM)
Andrea Arcangeli	Transparent hugepages
- mmap_sem scalability, again
- Direct reclaim, direct writeback problems



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
