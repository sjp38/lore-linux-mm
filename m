Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EB7ED6B01EA
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 03:20:55 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o517KruN007255
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 1 Jun 2010 16:20:53 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D461145DE58
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:20:51 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 65B5945DE52
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:20:51 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 41CCFE08006
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:20:51 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C7B0FE08008
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:20:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 01/18] oom: filter tasks not sharing the same cpuset
In-Reply-To: <alpine.DEB.2.00.1006010013080.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010013080.29202@chino.kir.corp.google.com>
Message-Id: <20100601162030.244B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  1 Jun 2010 16:20:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Tasks that do not share the same set of allowed nodes with the task that
> triggered the oom should not be considered as candidates for oom kill.
> 
> Tasks in other cpusets with a disjoint set of mems would be unfairly
> penalized otherwise because of oom conditions elsewhere; an extreme
> example could unfairly kill all other applications on the system if a
> single task in a user's cpuset sets itself to OOM_DISABLE and then uses
> more memory than allowed.
> 
> Killing tasks outside of current's cpuset rarely would free memory for
> current anyway.  To use a sane heuristic, we must ensure that killing a
> task would likely free memory for current and avoid needlessly killing
> others at all costs just because their potential memory freeing is
> unknown.  It is better to kill current than another task needlessly.
> 
> Acked-by: Rik van Riel <riel@redhat.com>
> Acked-by: Nick Piggin <npiggin@suse.de>
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

ack


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
