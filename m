Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A0A9A6008F0
	for <linux-mm@kvack.org>; Wed, 19 May 2010 20:31:41 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4K0VP9O010234
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 20 May 2010 09:31:25 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 612D145DE4E
	for <linux-mm@kvack.org>; Thu, 20 May 2010 09:31:25 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3639045DE52
	for <linux-mm@kvack.org>; Thu, 20 May 2010 09:31:25 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E8D9E08003
	for <linux-mm@kvack.org>; Thu, 20 May 2010 09:31:25 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D2316E08009
	for <linux-mm@kvack.org>; Thu, 20 May 2010 09:31:24 +0900 (JST)
Date: Thu, 20 May 2010 09:27:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: oom killer rewrite
Message-Id: <20100520092717.0c3d8f3f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1005191511140.27294@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1005191511140.27294@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 May 2010 15:14:42 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> KOSAKI,
> 
> I've been notified that my entire oom killer rewrite has been dropped from 
> -mm based solely on your feedback.  The problem is that I have absolutely 
> no idea what issues you have with the changes that haven't already been 
> addressed (nobody else does, either, it seems).
> 

I've pointed out that "normalized" parameter doesn't seem to work well in some
situaion (in cluster). I hope you'll have an extra interface as

	echo 3G > /proc/<pid>/oom_indemification

to allow users have "absolute value" setting.
(If the admin know usual memory usage of an application, we can only
 add badness to extra memory usage.)

To be honest, I can't fully understand why we need _normalized_ parameter. Why
oom_adj _which is now used_ is not enough for setting "relative importance" ?

Does google guys controls importance of processes in very small step ?

And, IIRC, Nick pointed out that "don't remove _used_ interfaces just because
you hate it or it seems not clean". So, I recommend you to drop sysctl changes.

I think the whole concept of your patch series is good and I like it.
But changes in interfaces seem not very sensible. 

Don't take my word very serious but I don't like changes in interface.

Cheers,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
