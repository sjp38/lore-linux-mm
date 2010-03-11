Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C9ECE6B008C
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 20:21:10 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2B1L8LC013319
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 11 Mar 2010 10:21:08 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E599D45DE51
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 10:21:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C522545DE4E
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 10:21:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A79B31DB8047
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 10:21:07 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 500161DB804A
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 10:21:07 +0900 (JST)
Date: Thu, 11 Mar 2010 10:17:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v6)
Message-Id: <20100311101726.f58d24e9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100311093913.07c9ca8a.kamezawa.hiroyu@jp.fujitsu.com>
References: <1268175636-4673-1-git-send-email-arighi@develer.com>
	<20100311093913.07c9ca8a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Mar 2010 09:39:13 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > The performance overhead is not so huge in both solutions, but the impact on
> > performance is even more reduced using a complicated solution...
> > 
> > Maybe we can go ahead with the simplest implementation for now and start to
> > think to an alternative implementation of the page_cgroup locking and
> > charge/uncharge of pages.
> > 
> 
> maybe. But in this 2 years, one of our biggest concerns was the performance.
> So, we do something complex in memcg. But complex-locking is , yes, complex.
> Hmm..I don't want to bet we can fix locking scheme without something complex.
> 
But overall patch set seems good (to me.) And dirty_ratio and dirty_background_ratio
will give us much benefit (of performance) than we lose by small overheads.

IIUC, this series affects trgger for background-write-out.

Could you show some score which dirty_ratio give us benefit in the cases of

	- copying a file in a memcg which hits limit
	  ex) copying a 100M file in 120MB limit.  etc..

	- kernel make performance in limited memcg.
	  ex) making a kernel in 100MB limit (too large ?)
    etc....(when an application does many write and hits memcg's limit.)

But, please get enough ack for changes in generic codes of dirty_ratio.

Thank you for your work.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
