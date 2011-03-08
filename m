Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5B68D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 22:56:35 -0500 (EST)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p283uVSb003018
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 19:56:31 -0800
Received: from pvh11 (pvh11.prod.google.com [10.241.210.203])
	by wpaz21.hot.corp.google.com with ESMTP id p283uTUb007975
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 19:56:30 -0800
Received: by pvh11 with SMTP id 11so1424572pvh.22
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 19:56:29 -0800 (PST)
Date: Mon, 7 Mar 2011 19:56:23 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: add oom killer delay
In-Reply-To: <20110308121332.de003f81.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1103071954550.2883@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com> <alpine.DEB.2.00.1102091417410.5697@chino.kir.corp.google.com> <20110223150850.8b52f244.akpm@linux-foundation.org> <alpine.DEB.2.00.1102231636260.21906@chino.kir.corp.google.com>
 <20110303135223.0a415e69.akpm@linux-foundation.org> <alpine.DEB.2.00.1103071602080.23035@chino.kir.corp.google.com> <20110307162912.2d8c70c1.akpm@linux-foundation.org> <alpine.DEB.2.00.1103071631080.23844@chino.kir.corp.google.com>
 <20110307165119.436f5d21.akpm@linux-foundation.org> <alpine.DEB.2.00.1103071657090.24549@chino.kir.corp.google.com> <20110307171853.c31ec416.akpm@linux-foundation.org> <alpine.DEB.2.00.1103071721330.25197@chino.kir.corp.google.com>
 <20110308115108.36b184c5.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103071905400.1640@chino.kir.corp.google.com> <20110308121332.de003f81.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Tue, 8 Mar 2011, KAMEZAWA Hiroyuki wrote:

> > I was referring specifically to the memcg which a job scheduler or 
> > userspace daemon responsible for doing so is attached.  If the thread 
> > responsible for managing memcgs and increasing limits or killing off lower 
> > priority jobs is in a memcg that is oom, there is a chance it will never 
> > be able to respond to the condition.
> > 
> 
> I just think memcg for such daemons shouldn't have any limit or must not
> set oom_disable. I think you know that. So, the question is why you can't
> do it ?  Is there special reason which comes from cgroup's characteristics ?
> 

Being in the root memcg doesn't mean the aggregate of your memcg's hard 
limits can't exceed the system's memory capacity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
