Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 46F396B0087
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 03:49:03 -0500 (EST)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id oBM8mx5N001773
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 00:49:00 -0800
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by kpbe16.cbf.corp.google.com with ESMTP id oBM8mwxF030368
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 00:48:58 -0800
Received: by pzk37 with SMTP id 37so1447422pzk.40
        for <linux-mm@kvack.org>; Wed, 22 Dec 2010 00:48:58 -0800 (PST)
Date: Wed, 22 Dec 2010 00:48:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: add oom killer delay
In-Reply-To: <20101222171749.06ef5559.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1012220043040.24462@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1012212318140.22773@chino.kir.corp.google.com> <20101221235924.b5c1aecc.akpm@linux-foundation.org> <20101222171749.06ef5559.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Divyesh Shah <dpshah@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Dec 2010, KAMEZAWA Hiroyuki wrote:

> seems to be hard to use. No one can estimate "milisecond" for avoidling
> OOM-kill. I think this is very bad. Nack to this feature itself.
> 

There's no estimation that is really needed, we simply need to be able to 
stall long enough that we'll eventually kill "something" if userspace 
fails to act.

> If you want something smart _in kernel_, please implement followings.
> 
>  - When hit oom, enlarge limit to some extent.
>  - All processes in cgroup should be stopped.
>  - A helper application will be called by usermode_helper().
>  - When a helper application exit(), automatically release all processes
>    to run again.
> 

Hmm, that's a _lot_ of policy to be implemented in the kernel itself and 
comes at the cost of either being faulty (if the limit cannot be 
increased) or harmful (when increasing the limit is detrimental to other 
memcg).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
