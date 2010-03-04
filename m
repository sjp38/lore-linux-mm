Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D2B356B0047
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 02:03:54 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2473of4004929
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 4 Mar 2010 16:03:50 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E8ED545DE56
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 16:03:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 829A145DE4F
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 16:03:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FC88E38006
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 16:03:49 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CB341E38002
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 16:03:48 +0900 (JST)
Date: Thu, 4 Mar 2010 16:00:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm v2 04/10] oom: remove special handling for pagefault
 ooms
Message-Id: <20100304160016.dda8101a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1003032249340.25386@chino.kir.corp.google.com>
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
	<20100304125934.1d8118b0.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1003032249340.25386@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Mar 2010 22:50:53 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 4 Mar 2010, KAMEZAWA Hiroyuki wrote:
> 
> > > And this is fixed by memcg-fix-oom-kill-behavior-v3.patch in -mm, right?
> > > 
> > yes.
> > 
> 
> Good.  This patch can easily be rebased on top of the next mmotm release, 
> then, as I mentioned before.  Do you have time to review the actual oom 
> killer part of this patch?
> 
About the _changes_ for generic part itself, I have no concerns.

But I'm not sure whether TIF_MEMDIE task has been already killed (quit tasklist)
before VM_FAULT_OOM task comes here.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
