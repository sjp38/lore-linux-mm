Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 23E346B0210
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 03:34:46 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o517YhOn012660
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 1 Jun 2010 16:34:43 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 58E0A45DE59
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:34:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 14E1245DE51
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:34:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A9183E08004
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:34:42 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 43C0C1DB8038
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:34:42 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 05/18] oom: remove special handling for pagefault ooms
In-Reply-To: <alpine.DEB.2.00.1006010014080.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010014080.29202@chino.kir.corp.google.com>
Message-Id: <20100601163420.2451.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  1 Jun 2010 16:34:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> It is possible to remove the special pagefault oom handler by simply oom
> locking all system zones and then calling directly into out_of_memory().
> 
> All populated zones must have ZONE_OOM_LOCKED set, otherwise there is a
> parallel oom killing in progress that will lead to eventual memory freeing
> so it's not necessary to needlessly kill another task.  The context in
> which the pagefault is allocating memory is unknown to the oom killer, so
> this is done on a system-wide level.
> 
> If a task has already been oom killed and hasn't fully exited yet, this
> will be a no-op since select_bad_process() recognizes tasks across the
> system with TIF_MEMDIE set.
> 
> Acked-by: Nick Piggin <npiggin@suse.de>
> Signed-off-by: David Rientjes <rientjes@google.com>

ack


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
