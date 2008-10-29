Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9T5TRc6031388
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 29 Oct 2008 14:29:29 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CBAA2AC027
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 14:29:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 33FDA12C045
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 14:29:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 10DAE1DB803B
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 14:29:27 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BE481DB8044
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 14:29:26 +0900 (JST)
Date: Wed, 29 Oct 2008 14:28:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [discuss][memcg] oom-kill extension
Message-Id: <20081029142858.2db54e92.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.1.10.0810282206260.10159@chino.kir.corp.google.com>
References: <20081029113826.cc773e21.kamezawa.hiroyu@jp.fujitsu.com>
	<4907E1B4.6000406@linux.vnet.ibm.com>
	<20081029140012.fff30bce.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.1.10.0810282206260.10159@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Oct 2008 22:13:03 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:
> 
> There was a patchset from February that added /dev/mem_notify to warn 
> userspace of low or out of memory conditions:
> 
> 	http://marc.info/?l=linux-kernel&m=120257050719077
> 	http://marc.info/?l=linux-kernel&m=120257050719087
> 	http://marc.info/?l=linux-kernel&m=120257062719234
> 	http://marc.info/?l=linux-kernel&m=120257071219327
> 	http://marc.info/?l=linux-kernel&m=120257071319334
> 	http://marc.info/?l=linux-kernel&m=120257080919488
> 	http://marc.info/?l=linux-kernel&m=120257081019497
> 	http://marc.info/?l=linux-kernel&m=120257096219705
> 	http://marc.info/?l=linux-kernel&m=120257096319717
> 
> Perhaps this idea can simply be reworked for the memory controller or 
> standalone cgroup?
> 
I know and like that. The concept of mem_notify is notifing shortage of memory
by watching page reclaimation.
But the situation/usage/purpose is a bit different from oom-killer.
(oom-kill is the final stage to recover memory...)

To implement mem_notify in memcg's context, my idea is
  - support followings.
    => account swap (now going on)
    => show usage of swap
    => "reduce memory usage" interface (to decrease noise from usage of file cache)

In usual systems, we watche"amount of swap".
In swapless systems, watches the amount of anonymous/locked memory under memcg.
Or "measure how much time we'll take to reduce memory usage to some level"

maybe it's interresting that we can add multi-purpose notifier to memcg.
for example, 
  - triggered when anonymous memory is over 95% of limits
  - triggered when swap occurs.

(But can be done by user-land daemon...Hmm?)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
