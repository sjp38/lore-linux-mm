Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B5D736B007E
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 19:03:34 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1G03Wov001499
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Feb 2010 09:03:32 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BEA645DE7A
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 09:03:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D113445DE6E
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 09:03:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C9591DB8048
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 09:03:31 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A59D1DB803B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 09:03:31 +0900 (JST)
Date: Tue, 16 Feb 2010 09:00:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
Message-Id: <20100216090005.f362f869.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Feb 2010 14:20:09 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> If /proc/sys/vm/panic_on_oom is set to 2, the kernel will panic
> regardless of whether the memory allocation is constrained by either a
> mempolicy or cpuset.
> 
> Since mempolicy-constrained out of memory conditions now iterate through
> the tasklist and select a task to kill, it is possible to panic the
> machine if all tasks sharing the same mempolicy nodes (including those
> with default policy, they may allocate anywhere) or cpuset mems have
> /proc/pid/oom_adj values of OOM_DISABLE.  This is functionally equivalent
> to the compulsory panic_on_oom setting of 2, so the mode is removed.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

NACK. In an enviroment which depends on cluster-fail-over, this is useful
even if in such situation.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
