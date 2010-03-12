Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1BCDA6B0127
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 02:50:30 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2C7oLMd012968
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Mar 2010 16:50:21 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D96945DE53
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 16:50:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B05F745DE50
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 16:50:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 92C69EF8002
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 16:50:20 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4154AE08005
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 16:50:20 +0900 (JST)
Date: Fri, 12 Mar 2010 16:46:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 00/10 -mm v3] oom killer rewrite
Message-Id: <20100312164642.2757ec6c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1003100236510.30013@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003100236510.30013@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Mar 2010 02:41:08 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> This patchset is a rewrite of the out of memory killer to address several
> issues that have been raised recently.  The most notable change is a
> complete rewrite of the badness heuristic that determines which task is
> killed; the goal was to make it as simple and predictable as possible
> while still addressing issues that plague the VM.
> 
> Changes from version 2:
> 
>  - updated to mmotm-2010-03-09-19-15
> 
>  - schedule a timeout for current if it was not selected for oom kill
>    when it has returned VM_FAULT_OOM so memory can freed to prevent
>    needlessly recalling the oom killer and looping.
> 
> To apply, download the -mm tree from
> http://userweb.kernel.org/~akpm/mmotm/broken-out.tar.gz first.
> 
> This patchset is also available for each kernel release from:
> 
> 	http://www.kernel.org/pub/linux/kernel/people/rientjes/oom-killer-rewrite/
> 

One question. Assume a host A and B. A has 4G memory, B has 8G memory.

Here, an applicaton which consumes 2G memory.

Then, this application's oom_score will be 500 on A, 250 on B.

How admin detemine the best oom_score_adj value ? Does it depend on envrionment
even if runnning the same application ?

Is it bad to use bare value as

	echo 1G > /proc/<pid>/oom_score_adj

for getting 1G bytes of excuse to this application ?

Thanks,
-Kame














--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
