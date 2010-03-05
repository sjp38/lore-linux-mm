Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8FBAF6B009D
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 20:02:30 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2512S4e006159
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 5 Mar 2010 10:02:28 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DC6C545DE51
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 10:02:27 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BD26245DE4F
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 10:02:27 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A56891DB8043
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 10:02:27 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E0021DB8038
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 10:02:27 +0900 (JST)
Date: Fri, 5 Mar 2010 09:58:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm v2 04/10] oom: remove special handling for pagefault
 ooms
Message-Id: <20100305095853.d71dcad5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1003040149110.30214@chino.kir.corp.google.com>
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
	<20100304160016.dda8101a.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1003040149110.30214@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Mar 2010 01:50:04 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 4 Mar 2010, KAMEZAWA Hiroyuki wrote:
> 
> > About the _changes_ for generic part itself, I have no concerns.
> > 
> 
> Is that your acked-by?
> 
Anyway, I think you'll repost. I'll see again. feel free to CC me.


> > But I'm not sure whether TIF_MEMDIE task has been already killed (quit tasklist)
> > before VM_FAULT_OOM task comes here.
> > 
> 
> If it's no longer a member of the tasklist then it has freed its memory 
> and thus returning VM_FAULT_OOM again would mean that we are still oom.
> 
My concern was multi-threaded task with ignoring SIGCHLD..but after looking into
page allocatoer again, I think you're right. Thanks.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
