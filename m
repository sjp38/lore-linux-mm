Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 47CCD6B004A
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 20:19:46 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o820JhkD031913
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 2 Sep 2010 09:19:43 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 56A0445DE5A
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:19:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 226CF45DE4F
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:19:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 01A8D1DB8043
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:19:43 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A99BD1DB8044
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:19:42 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] oom: filter unkillable tasks from tasklist dump
In-Reply-To: <alpine.DEB.2.00.1009011426260.28408@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1009011426260.28408@chino.kir.corp.google.com>
Message-Id: <20100902091916.D056.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  2 Sep 2010 09:19:41 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> /proc/sys/vm/oom_dump_tasks is enabled by default, so it's necessary to
> limit as much information as possible that it should emit.
> 
> The tasklist dump should be filtered to only those tasks that are
> eligible for oom kill.  This is already done for memcg ooms, but this
> patch extends it to both cpuset and mempolicy ooms as well as init.
> 
> In addition to suppressing irrelevant information, this also reduces
> confusion since users currently don't know which tasks in the tasklist
> aren't eligible for kill (such as those attached to cpusets or bound to
> mempolicies with a disjoint set of mems or nodes, respectively) since
> that information is not shown.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Looks good.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
