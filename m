Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 51AAB6B0047
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 04:42:36 -0500 (EST)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o1J9gXUO001540
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 01:42:33 -0800
Received: from pzk41 (pzk41.prod.google.com [10.243.19.169])
	by kpbe18.cbf.corp.google.com with ESMTP id o1J9gVUM013472
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 01:42:32 -0800
Received: by pzk41 with SMTP id 41so1740681pzk.0
        for <linux-mm@kvack.org>; Fri, 19 Feb 2010 01:42:31 -0800 (PST)
Date: Fri, 19 Feb 2010 01:42:27 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [regression] cpuset,mm: update tasks' mems_allowed in time
 (58568d2)
In-Reply-To: <20100219164754.A1C3.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002190137530.6293@chino.kir.corp.google.com>
References: <20100218134921.GF9738@laptop> <20100219164754.A1C3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Miao Xie <miaox@cn.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 19 Feb 2010, KOSAKI Motohiro wrote:

> Personally, I like just revert at once than bandaid. 58568d2 didn't
> introduce any new feature, then we can revet it without abi breakage.
> 

Revert a commit from more than six months ago when the fix is probably a 
small patch in cpuset_attach()?  I think we can do better than that.

This may not have introduced a new feature, but it was a worthwhile change 
to avoid the old cpuset_update_task_memory_state() hooks in mempolicy, 
page allocator, etc. code that could block on callback_mutex for iterating 
the hierarchy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
