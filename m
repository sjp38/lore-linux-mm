Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 649988D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 21:37:50 -0500 (EST)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p182bjLx023255
	for <linux-mm@kvack.org>; Mon, 7 Feb 2011 18:37:46 -0800
Received: from pwi10 (pwi10.prod.google.com [10.241.219.10])
	by kpbe16.cbf.corp.google.com with ESMTP id p182bOaZ028896
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 7 Feb 2011 18:37:44 -0800
Received: by pwi10 with SMTP id 10so1219276pwi.27
        for <linux-mm@kvack.org>; Mon, 07 Feb 2011 18:37:44 -0800 (PST)
Date: Mon, 7 Feb 2011 18:37:30 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: add oom killer delay
In-Reply-To: <20110208112041.a9986f09.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1102071836030.17774@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com> <20110208105553.76cfe424.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1102071808280.16931@chino.kir.corp.google.com> <20110208111351.93c6d048.kamezawa.hiroyu@jp.fujitsu.com>
 <20110208112041.a9986f09.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Tue, 8 Feb 2011, KAMEZAWA Hiroyuki wrote:

> And write this fact:
> 
>      A
>     /
>    B
>   /
>  C
> 
> When 
>   A.memory_oom_delay=1sec. 
>   B.memory_oom_delay=500msec
>   C.memory_oom_delay=200msec
> 
> If there are OOM in group C, C's oom_kill will be delayed for 200msec and
> a task in group C will be killed. 
> 
> If there are OOM in group B, B's oom_kill will be delayed for 200msec and
> a task in group B or C will be killed.
> 
> If there are OOM in group A, A's oom_kill will be delayed for 1sec and
> a task in group A,B or C will be killed.
> 
> oom_killer in the hierarchy is serialized by lock and happens one-by-one
> for avoiding a serial kill. So, above delay can be stacked. 
> 

Ok, I'll add this to the comment that says changing 
memory.oom_delay_millisecs does so for all children as well that was 
already added in this version of the patch.

I'll wait a couple days to see if Balbir or Daisuke have any additional 
comments.

Thanks for the review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
