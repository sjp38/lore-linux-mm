Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9A28D6B004D
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 02:23:53 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7A6Nv45029834
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 10 Aug 2009 15:23:58 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 00F8945DE54
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 15:23:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AC2EE45DE4F
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 15:23:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 838751DB803B
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 15:23:56 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 39CAD1DB8041
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 15:23:56 +0900 (JST)
Date: Mon, 10 Aug 2009 15:22:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Help Resource Counters Scale Better (v3)
Message-Id: <20090810152205.d37d8e2f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090810144559.ac5a3499.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090807221238.GJ9686@balbir.in.ibm.com>
	<39eafe409b85053081e9c6826005bb06.squirrel@webmail-b.css.fujitsu.com>
	<20090808060531.GL9686@balbir.in.ibm.com>
	<99f2a13990d68c34c76c33581949aefd.squirrel@webmail-b.css.fujitsu.com>
	<20090809121530.GA5833@balbir.in.ibm.com>
	<20090810093229.10db7185.kamezawa.hiroyu@jp.fujitsu.com>
	<20090810053025.GC5257@balbir.in.ibm.com>
	<20090810144559.ac5a3499.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, andi.kleen@intel.com, Prarit Bhargava <prarit@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 10 Aug 2009 14:45:59 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > Do you agree?
> 
> Ok. Config is enough at this stage.
> 
> The last advice for merge is, it's better to show the numbers or
> ask someone who have many cpus to measure benefits. Then, Andrew can
> know how this is benefical.
> (My box has 8 cpus. But maybe your IBM collaegue has some bigger one)
> 
> In my experience (in my own old trial),
>  - lock contention itself is low. not high.
>  - but cacheline-miss, pingpong is very very frequent.
> 
> Then, this patch has some benefit logically but, in general,
> File-I/O, swapin-swapout, page-allocation/initalize etc..dominates
> the performance of usual apps. You'll have to be careful to select apps
> to measure the benfits of this patch by application performance.
> (And this is why I don't feel so much emergency as you do)
> 

Why I say "I want to see the numbers" again and again is that
this is performance improvement with _bad side effect_.
If this is an emergent trouble, and need fast-track, which requires us
"fix small problems later", plz say so. 

I have no objection to this approach itself because I can't think of
something better, now. percpu-counter's error tolerance is a generic
problem and we'll have to visit this anyway.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
