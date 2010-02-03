Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5AF216B007E
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 03:07:05 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o13872ER009144
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 3 Feb 2010 17:07:02 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6173D45DE50
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 17:07:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 36A2645DE4D
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 17:07:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1655E1DB803E
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 17:07:02 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AE9281DB803A
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 17:07:01 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] sysctl: clean up vm related variable declarations
In-Reply-To: <alpine.DEB.2.00.1002021832160.5344@chino.kir.corp.google.com>
References: <20100203111224.8fe0e20c.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002021832160.5344@chino.kir.corp.google.com>
Message-Id: <20100203170632.D3AF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  3 Feb 2010 17:07:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, minchan.kim@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, there are many "extern" declaration in kernel/sysctl.c. "extern"
> declaration in *.c file is not appreciated in general.
> And Hmm...it seems there are a few redundant declarations.
> 
> Because most of sysctl variables are defined in its own header file,
> they should be declared in the same style, be done in its own *.h file.
> 
> This patch removes some VM(memory management) related sysctl's
> variable declaration from kernel/sysctl.c and move them to
> proper places.
> 
> [rientjes@google.com: #ifdef fixlet]
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

Looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
