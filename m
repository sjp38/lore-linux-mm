Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CE17F6B008C
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 07:58:18 -0500 (EST)
Date: Sat, 30 Jan 2010 12:59:17 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
Message-ID: <20100130125917.600beb51@lxorguk.ukuu.org.uk>
In-Reply-To: <4B64272D.8020509@gmail.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	<20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126151202.75bd9347.akpm@linux-foundation.org>
	<20100127085355.f5306e78.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126161952.ee267d1c.akpm@linux-foundation.org>
	<20100127095812.d7493a8f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100128001636.2026a6bc@lxorguk.ukuu.org.uk>
	<4B622AEE.3080906@gmail.com>
	<20100129003547.521a1da9@lxorguk.ukuu.org.uk>
	<4B62327F.3010208@gmail.com>
	<20100129110321.564cb866@lxorguk.ukuu.org.uk>
	<4B64272D.8020509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: vedran.furac@gmail.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> > So how about you go and have a complain at the people who are causing
> > your problem, rather than the kernel.
> 
> That would pass completely unnoticed and ignored as long as overcommit
> is enabled by default.

Defaults are set by the distributions. So you are still complaining to
the wrong people.

> So, if you don't want to change the OOM algorithm why not fixing this
> bug then? And after that change the proc(5) manpage entry for
> /proc/sys/vm/overcommit_memory into something like:
> 
> 0: heuristic overcommit (enable this if you have memory problems with
>                           some buggy software)
> 1: always overcommit, never check
> 2: always check, never overcommit (this is the default)

Because there are a lot of systems where heuristic overcommit makes
sense ?

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
