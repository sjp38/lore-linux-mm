Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BD9FA6B01B6
	for <linux-mm@kvack.org>; Mon, 31 May 2010 19:54:31 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4VNsRcb002854
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 1 Jun 2010 08:54:28 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A69AB45DE4D
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 08:54:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 876F945DE6F
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 08:54:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CFF7E38003
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 08:54:27 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 164061DB803B
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 08:54:27 +0900 (JST)
Date: Tue, 1 Jun 2010 08:50:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
Message-Id: <20100601085006.f732c049.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100531135227.GC19784@uudg.org>
References: <20100528152842.GH11364@uudg.org>
	<20100528154549.GC12035@barrios-desktop>
	<20100528164826.GJ11364@uudg.org>
	<20100531092133.73705339.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikFk_HnZWPG0s_VrRkro2rruEc8OBX5KfKp_QdX@mail.gmail.com>
	<20100531140443.b36a4f02.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTil75ziCd6bivhpmwojvhaJ2LVxwEaEaBEmZf2yN@mail.gmail.com>
	<20100531145415.5e53f837.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTilcuY5e1DNmLhUWfXtiQgPUafz2zRTUuTVl-88l@mail.gmail.com>
	<20100531155102.9a122772.kamezawa.hiroyu@jp.fujitsu.com>
	<20100531135227.GC19784@uudg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Mon, 31 May 2010 10:52:27 -0300
"Luis Claudio R. Goncalves" <lclaudio@uudg.org> wrote:

> | If an explanation as "acceralating all thread's priority in a process seems overkill"
> | is given in changelog or comment, it's ok to me.
> 
> If my understanding of badness() is right, I wouldn't be ashamed of saying
> that it seems to be _a bit_ overkill. But I may be wrong in my
> interpretation.
> 
> While re-reading the code I noticed that in select_bad_process() we can
> eventually bump on an already dying task, case in which we just wait for
> the task to die and avoid killing other tasks. Maybe we could boost the
> priority of the dying task here too.
> 
yes, nice catch.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
