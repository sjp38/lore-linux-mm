Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 43E626B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 00:54:40 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 37BD93EE0CD
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:54:33 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1729145DED7
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:54:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F314145DED5
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:54:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E65511DB803F
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:54:32 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AF1EC1DB8037
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:54:32 +0900 (JST)
Message-ID: <4DE4747D.7040902@jp.fujitsu.com>
Date: Tue, 31 May 2011 13:54:21 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] oom: don't kill random process
References: <4DD61F80.1020505@jp.fujitsu.com> <4DD6207E.1070300@jp.fujitsu.com> <alpine.DEB.2.00.1105231529340.17840@chino.kir.corp.google.com> <4DDB0B45.2080507@jp.fujitsu.com> <alpine.DEB.2.00.1105231838420.17729@chino.kir.corp.google.com> <4DDB1028.7000600@jp.fujitsu.com> <alpine.DEB.2.00.1105231856210.18353@chino.kir.corp.google.com> <4DDB11F4.2070903@jp.fujitsu.com> <alpine.DEB.2.00.1105251645270.29729@chino.kir.corp.google.com> <4DE2F028.6020608@jp.fujitsu.com> <alpine.DEB.2.00.1105302147250.18793@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1105302147250.18793@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

(2011/05/31 13:48), David Rientjes wrote:
> On Mon, 30 May 2011, KOSAKI Motohiro wrote:
> 
>> Never mind.
>>
>> You never see to increase tasklist_lock. You never seen all processes
>> have root privilege case.
> 
> I don't really understand what you're trying to say, sorry.

It's no for job server workload. I mean.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
