Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5C75260080F
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 21:18:15 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o7O0vEA4023065
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 17:57:14 -0700
Received: from pxi6 (pxi6.prod.google.com [10.243.27.6])
	by wpaz37.hot.corp.google.com with ESMTP id o7O0vCoB030104
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 17:57:13 -0700
Received: by pxi6 with SMTP id 6so3060277pxi.17
        for <linux-mm@kvack.org>; Mon, 23 Aug 2010 17:57:11 -0700 (PDT)
Date: Mon, 23 Aug 2010 17:57:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 3/3 v3] oom: kill all threads sharing oom killed task's
 mm
In-Reply-To: <20100823161620.7a46f2e1.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1008231756590.25841@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008201539310.9201@chino.kir.corp.google.com> <alpine.DEB.2.00.1008201541210.9201@chino.kir.corp.google.com> <alpine.DEB.2.00.1008201651400.16947@chino.kir.corp.google.com> <20100823161620.7a46f2e1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 23 Aug 2010, Andrew Morton wrote:

> > +			pr_err("Kill process %d (%s) sharing same memory\n",
> > +				task_pid_nr(q), q->comm);
> 
> We're really supposed to use get_task_comm() when accessing another
> tasks's comm[] to avoid races with that task altering its comm[] in
> prctl().
> 

Ok!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
