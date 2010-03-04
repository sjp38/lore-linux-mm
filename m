Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 509F76B007B
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 23:03:09 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o24437hH015333
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 4 Mar 2010 13:03:07 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 05E8945DE70
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 13:03:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C10945DE6F
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 13:03:06 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FD171DB803E
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 13:03:06 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D55AE18006
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 13:03:05 +0900 (JST)
Date: Thu, 4 Mar 2010 12:59:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm v2 04/10] oom: remove special handling for pagefault
 ooms
Message-Id: <20100304125934.1d8118b0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1003031527230.32530@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002261551030.30830@chino.kir.corp.google.com>
	<20100301052306.GG19665@balbir.in.ibm.com>
	<alpine.DEB.2.00.1003010159420.26824@chino.kir.corp.google.com>
	<20100302085532.ff9d3cf4.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1003021600020.11946@chino.kir.corp.google.com>
	<20100303092210.a730a903.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1003021634030.18535@chino.kir.corp.google.com>
	<20100303094438.1e9b09fb.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1003021651170.20958@chino.kir.corp.google.com>
	<20100303095812.c3d47ee1.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1003031527230.32530@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Mar 2010 15:27:53 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 3 Mar 2010, KAMEZAWA Hiroyuki wrote:
> 
> > In patch 01-03, you don't modified panic_on_oom implementation.
> > And this patch, you don't modified the return code of memcg's charge code.
> > It still returns -ENOMEM.
> > 
> > Then, VM_FAULT_OOM is returned and page_fault_out_of_memory() calles this
> > and hit this.
> > 
> >        case CONSTRAINT_NONE:
> >                 if (sysctl_panic_on_oom) {
> >                         dump_header(NULL, gfp_mask, order, NULL);
> >                         panic("out of memory. panic_on_oom is selected\n");
> >                 }
> > 
> > The system will panic. A hook, mem_cgroup_oom_called() is for avoiding this.
> > memcg's oom doesn't mean memory shortage, just means it his limit.
> > 
> 
> And this is fixed by memcg-fix-oom-kill-behavior-v3.patch in -mm, right?
> 
yes.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
