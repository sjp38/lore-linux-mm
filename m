From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH mmotm 1/2] cgroup: fix to stop adding a new task while
 rmdir going on
Date: Thu, 11 Dec 2008 09:26:47 +0900
Message-ID: <20081211092647.bb5ea05a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081210133508.3ee454ae.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830812101448h46e1ea1cs80635611f9205962@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBB0RirH004068
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 11 Dec 2008 09:27:44 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1579A45DE54
	for <linux-mm@kvack.org>; Thu, 11 Dec 2008 09:27:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E8BC745DE4F
	for <linux-mm@kvack.org>; Thu, 11 Dec 2008 09:27:43 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CF9251DB803E
	for <linux-mm@kvack.org>; Thu, 11 Dec 2008 09:27:43 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 69C871DB803B
	for <linux-mm@kvack.org>; Thu, 11 Dec 2008 09:27:40 +0900 (JST)
In-Reply-To: <6599ad830812101448h46e1ea1cs80635611f9205962@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-Id: linux-mm.kvack.org

On Wed, 10 Dec 2008 14:48:37 -0800
Paul Menage <menage@google.com> wrote:

> On Tue, Dec 9, 2008 at 8:35 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > still need reviews.
> > ==
> > Recently, pre_destroy() was moved to out of cgroup_lock() for avoiding
> > dead lock. But, by this, serialization between task attach and rmdir()
> > is lost.
> >
> > This adds CGRP_TRY_REMOVE flag to cgroup and check it at attaching.
> > If attach_pid founds CGRP_TRY_REMOVE, it returns -EBUSY.
> 
> As I've mentioned in other threads, I think the fix is to restore the
> locking for pre_destroy(), and solve the other potential deadlocks in
> better ways.
> 
Sure.

> This patch can result in an attach falsely getting an EBUSY when it
> shouldn't really do so (since the cgroup wasn't really going away).
> 
yes, it's also my concern. I'll think again.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
