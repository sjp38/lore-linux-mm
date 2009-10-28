Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 024B46B0073
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 02:22:47 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9S6MjNP018440
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Oct 2009 15:22:46 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8006445DE52
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 15:22:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 451B445DE4F
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 15:22:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AF9C1DB803E
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 15:22:45 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BE75AE08004
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 15:22:44 +0900 (JST)
Date: Wed, 28 Oct 2009 15:20:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Memory overcommit
Message-Id: <20091028152015.3d383cd6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0910272311001.15462@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org>
	<20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com>
	<hb2cfu$r08$2@ger.gmane.org>
	<20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com>
	<4ADE3121.6090407@gmail.com>
	<20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
	<4AE5CB4E.4090504@gmail.com>
	<20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0910271843510.11372@sister.anvils>
	<alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com>
	<4AE78B8F.9050201@gmail.com>
	<alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com>
	<4AE792B8.5020806@gmail.com>
	<alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com>
	<20091028135519.805c4789.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910272205200.7507@chino.kir.corp.google.com>
	<20091028150536.674abe68.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910272311001.15462@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Oct 2009 23:17:41 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 28 Oct 2009, KAMEZAWA Hiroyuki wrote:
> 
> > All kernel engineers know "than expected or not" can be never known to the kernel.
> > So, oom_adj workaround is used now. (by some special users.)
> > OOM Killer itself is also a workaround, too.
> > "No kill" is the best thing but we know there are tend to be memory-leaker on bad
> > systems and all systems in this world are not perfect.
> > 
> 
> Right, and historically that has been addressed by considering total_vm 
> and adjusting it with oom_adj so that we can identify memory leaking tasks 
> through user-defined criteria.
> 
> > Yes, some more trustable values other than vmsize/rss/time are appriciated.
> > I wonder recent memory consumption speed can be an another key value.
> > 
> 
> Sounds very logical.
> 
> > Anyway, current bahavior of "killing X" is a bad thing.
> > We need some fixes.
> > 
> 
> You can easily protect X with OOM_DISABLE, as you know.  I don't think we 
> need any X-specific heuristics added to the kernel, it looks like the 
> special cases have already polluted badness() enough.
> 
It's _not_ special to X.

Almost all applications which uses many dynamica libraries can be affected by this,
total_vm. And, as I explained to Vedran, multi-threaded program like Java can easily
increase total_vm without using many anon_rss.
And it's the reason I hate overcommit_memory. size of VM doesn't tell anything.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
