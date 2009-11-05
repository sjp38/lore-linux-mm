Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3533F6B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 18:45:19 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA5NjGh0013439
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Nov 2009 08:45:16 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0902845DE4E
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 08:45:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B217045DE62
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 08:45:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 17315E78001
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 08:45:15 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C32B1DB8046
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 08:45:14 +0900 (JST)
Date: Fri, 6 Nov 2009 08:42:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [MM] Make mm counters per cpu instead of atomic
Message-Id: <20091106084238.cbecd8ef.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.1.10.0911051008260.25718@V090114053VZO-1>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1>
	<20091105101650.45204e4e.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.1.10.0911051008260.25718@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Nov 2009 10:10:56 -0500 (EST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Thu, 5 Nov 2009, KAMEZAWA Hiroyuki wrote:
> 
> > Hmm, I don't fully understand _new_ percpu but...
> > In logical (even if not realistic), x86-32 supports up to 512 ? cpus in Kconfig.
> > BIGSMP.
> 
> x86-32 only supports 32 processors. Plus per cpu areas are only allocated
> for the possible processors.
> 
My number is just from Kconfig.

> > Then, if 65536 process runs, this consumes
> >
> > 65536(nr_proc) * 8 (size) * 512(cpus) = 256MBytes.
> 
> With 32 possible cpus this results in 16m of per cpu space use.
> 
If swap_usage is added, 24m, 25% of vmalloc area.
(But, yes, returning -ENOMEM to fork() is ok to me, 65536 proc are extreme.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
