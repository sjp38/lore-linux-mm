Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CA06160079C
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 18:59:42 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB9NxdUI027649
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 10 Dec 2009 08:59:40 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AF12F45DE61
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 08:59:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F6A445DE4F
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 08:59:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EDD31DB8042
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 08:59:39 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 139341DB803B
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 08:59:39 +0900 (JST)
Date: Thu, 10 Dec 2009 08:56:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] [23/31] HWPOISON: add memory cgroup filter
Message-Id: <20091210085634.255b244c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830912091247v1270a86er45ea8ceeff28e727@mail.gmail.com>
References: <200912081016.198135742@firstfloor.org>
	<20091208211639.8499FB151F@basil.firstfloor.org>
	<6599ad830912091247v1270a86er45ea8ceeff28e727@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, kosaki.motohiro@jp.fujitsu.com, hugh.dickins@tiscali.co.uk, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, lizf@cn.fujitsu.com, npiggin@suse.de, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 9 Dec 2009 12:47:27 -0800
Paul Menage <menage@google.com> wrote:

> On Tue, Dec 8, 2009 at 1:16 PM, Andi Kleen <andi@firstfloor.org> wrote:
> >
> > The hwpoison test suite need to inject hwpoison to a collection of
> > selected task pages, and must not touch pages not owned by them and
> > thus kill important system processes such as init. (But it's OK to
> > mis-hwpoison free/unowned pages as well as shared clean pages.
> > Mis-hwpoison of shared dirty pages will kill all tasks, so the test
> > suite will target all or non of such tasks in the first place.)
> 
> While the functionality sounds useful, the interface (passing an inode
> number) feels a bit ugly to me. Also, if that group is deleted and a
> new cgroup created, you could end up reusing the inode number.
> 
I agree.

> How about an approach where you write either the cgroup path (relative
> to the memcg mount) or an fd open on the desired cgroup? Then you
> could store a (counted) css reference rather than an inode number,
> which would make the filter function cleaner too, since it would just
> need to compare css objects.
> 
Sounds reasonable.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
