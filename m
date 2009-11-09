Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0AAE56B004D
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 03:38:49 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA98clkB003872
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 9 Nov 2009 17:38:47 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3672245DE53
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 17:38:47 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DC31A45DE52
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 17:38:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id AD85EE1800C
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 17:38:46 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 64EA81DB803C
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 17:38:46 +0900 (JST)
Date: Mon, 9 Nov 2009 17:36:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] memcg : rewrite percpu countings with new
 interfaces
Message-Id: <20091109173610.3d23daf2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091109070737.GE3042@balbir.in.ibm.com>
References: <20091106175242.6e13ee29.kamezawa.hiroyu@jp.fujitsu.com>
	<20091106175545.b97ee867.kamezawa.hiroyu@jp.fujitsu.com>
	<20091109070737.GE3042@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 9 Nov 2009 12:37:37 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
 
> > after==
> >  Performance counter stats for './runpause.sh' (5 runs):
> > 
> >   474919.429670  task-clock-msecs         #      7.896 CPUs    ( +-   0.013% )
> >        36520440  page-faults              #      0.077 M/sec   ( +-   1.854% )
> >      3109834751  cache-references         #      6.548 M/sec   ( +-   0.276% )
> >      1053275160  cache-misses             #      2.218 M/sec   ( +-   0.036% )
> > 
> >    60.146585280  seconds time elapsed   ( +-   0.019% )
> > 
> > This test is affected by cpu-utilization but I think more improvements
> > will be found in bigger system.
> >
> 
> Hi, Kamezawa-San,
> 
> Could you please post the IPC results as well? 
> 
Because PREEMPT=n, no differnce between v1/v2, basically.

Here.
==
 Performance counter stats for './runpause.sh' (5 runs):

  475884.969949  task-clock-msecs         #      7.913 CPUs    ( +-   0.005% )
       36592060  page-faults              #      0.077 M/sec   ( +-   0.301% )
     3037784893  cache-references         #      6.383 M/sec   ( +-   0.361% )  (scaled from 99.71%)
     1130761297  cache-misses             #      2.376 M/sec   ( +-   0.244% )  (scaled from 98.24%)

   60.136803969  seconds time elapsed   ( +-   0.006% )
==

But this program is highly affected by cpu utilization etc...

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
