Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A5DD96B01EF
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 02:32:45 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o2V6WdPY000847
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 23:32:39 -0700
Received: from pwi1 (pwi1.prod.google.com [10.241.219.1])
	by kpbe20.cbf.corp.google.com with ESMTP id o2V6Wc1G013283
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 23:32:38 -0700
Received: by pwi1 with SMTP id 1so83735pwi.39
        for <linux-mm@kvack.org>; Tue, 30 Mar 2010 23:32:38 -0700 (PDT)
Date: Tue, 30 Mar 2010 23:32:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom killer: break from infinite loop
In-Reply-To: <20100331063007.GN3308@balbir.in.ibm.com>
Message-ID: <alpine.DEB.2.00.1003302331001.839@chino.kir.corp.google.com>
References: <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329140633.GA26464@desktop> <alpine.DEB.2.00.1003291259400.14859@chino.kir.corp.google.com>
 <20100330142923.GA10099@desktop> <alpine.DEB.2.00.1003301326490.5234@chino.kir.corp.google.com> <20100331095714.9137caab.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003302302420.22316@chino.kir.corp.google.com> <20100331151356.673c16c0.kamezawa.hiroyu@jp.fujitsu.com>
 <20100331063007.GN3308@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Mar 2010, Balbir Singh wrote:

> > To me, this patch is acceptable and seems reasnoable.
> > 
> > But I didn't joined to memcg development when this check was added
> > and don't know why kill current..
> >
> 
> The reason for adding current was that we did not want to loop
> forever, since it stops forward progress - no error/no forward
> progress. It made sense to oom kill the current process, so that the
> cgroup admin could look at what went wrong.
>  

oom_kill_process() will fail on current since it wasn't selected as an 
eligible task to kill in select_bad_process() and we know it to be a 
member of the memcg, so there's no point in trying to kill it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
