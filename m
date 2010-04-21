Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 87F4A6B01F5
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 15:18:16 -0400 (EDT)
Date: Wed, 21 Apr 2010 12:17:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable
 task can be found
Message-Id: <20100421121758.af52f6e0.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1004081036520.25592@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com>
	<20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100407205418.FB90.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1004081036520.25592@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


fyi, I still consider these patches to be in the "stuck" state.  So we
need to get them unstuck.


Hiroyuki (and anyone else): could you please summarise in the briefest
way possible what your objections are to Daivd's oom-killer changes?

I'll start: we don't change the kernel ABI.  Ever.  And when we _do_
change it we don't change it without warning.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
