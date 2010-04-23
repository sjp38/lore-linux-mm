Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 325456B01EE
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 23:54:51 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3N3slCi016718
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 23 Apr 2010 12:54:47 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E37F645DE65
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 12:54:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EEB9245DE57
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 12:54:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D215F1DB8040
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 12:54:39 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1202F1DB8038
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 12:54:39 +0900 (JST)
Date: Fri, 23 Apr 2010 12:50:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg rcu lock fix in swap code (Was Re: [BUG]
 an RCU warning in memcg
Message-Id: <20100423125043.b3b964cd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4BD11A24.2070500@cn.fujitsu.com>
References: <4BD10D59.9090504@cn.fujitsu.com>
	<20100423121424.ae47efcb.kamezawa.hiroyu@jp.fujitsu.com>
	<4BD118E2.7080307@cn.fujitsu.com>
	<4BD11A24.2070500@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Apr 2010 11:55:16 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> Li Zefan wrote:
> > KAMEZAWA Hiroyuki wrote:
> >> On Fri, 23 Apr 2010 11:00:41 +0800
> >> Li Zefan <lizf@cn.fujitsu.com> wrote:
> >>
> >>> with CONFIG_PROVE_RCU=y, I saw this warning, it's because
> >>> css_id() is not under rcu_read_lock().
> >>>
> >> Ok. Thank you for reporting.
> >> This is ok ? 
> > 
> > Yes, and I did some more simple tests on memcg, no more warning
> > showed up.
> > 
> 
> oops, after trigging oom, I saw 2 more warnings:
> 

ok, I will update.  thank you.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
