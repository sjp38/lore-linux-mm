Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E364D6B0012
	for <linux-mm@kvack.org>; Sun, 29 May 2011 21:21:03 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 615DD3EE0C1
	for <linux-mm@kvack.org>; Mon, 30 May 2011 10:17:36 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AAAC45DE55
	for <linux-mm@kvack.org>; Mon, 30 May 2011 10:17:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 33A8E45DD74
	for <linux-mm@kvack.org>; Mon, 30 May 2011 10:17:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 28619E08001
	for <linux-mm@kvack.org>; Mon, 30 May 2011 10:17:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EAD8D1DB8038
	for <linux-mm@kvack.org>; Mon, 30 May 2011 10:17:35 +0900 (JST)
Message-ID: <4DE2F028.6020608@jp.fujitsu.com>
Date: Mon, 30 May 2011 10:17:28 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] oom: don't kill random process
References: <4DD61F80.1020505@jp.fujitsu.com> <4DD6207E.1070300@jp.fujitsu.com> <alpine.DEB.2.00.1105231529340.17840@chino.kir.corp.google.com> <4DDB0B45.2080507@jp.fujitsu.com> <alpine.DEB.2.00.1105231838420.17729@chino.kir.corp.google.com> <4DDB1028.7000600@jp.fujitsu.com> <alpine.DEB.2.00.1105231856210.18353@chino.kir.corp.google.com> <4DDB11F4.2070903@jp.fujitsu.com> <alpine.DEB.2.00.1105251645270.29729@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1105251645270.29729@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

> I'm afraid that a second time through the tasklist in select_bad_process() 
> is simply a non-starter for _any_ case; it significantly increases the 
> amount of time that tasklist_lock is held and causes problems elsewhere on 
> large systems -- such as some of ours -- since irqs are disabled while 
> waiting for the writeside of the lock.  I think it would be better to use 
> a proportional privilege for root processes based on the amount of memory 
> they are using (discounting 1% of memory per 10% of memory used, as 
> proposed earlier, seems sane) so we can always protect root when necessary 
> and never iterate through the list again.
> 
> Please look into the earlier review comments on the other patches, refresh 
> the series, and post it again.  Thanks!

Never mind.

You never see to increase tasklist_lock. You never seen all processes
have root privilege case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
