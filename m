Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8FD65600803
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 19:16:27 -0400 (EDT)
Date: Mon, 23 Aug 2010 16:16:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 3/3 v3] oom: kill all threads sharing oom killed task's
 mm
Message-Id: <20100823161620.7a46f2e1.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1008201651400.16947@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008201539310.9201@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1008201541210.9201@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1008201651400.16947@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Aug 2010 16:52:38 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> +			pr_err("Kill process %d (%s) sharing same memory\n",
> +				task_pid_nr(q), q->comm);

We're really supposed to use get_task_comm() when accessing another
tasks's comm[] to avoid races with that task altering its comm[] in
prctl().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
