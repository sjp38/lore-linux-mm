Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B59746B004D
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 19:51:13 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9TNpACW003441
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 30 Oct 2009 08:51:11 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A609845DE7B
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 08:51:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B00E45DE79
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 08:51:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 600E31DB803F
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 08:51:10 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EAE901DB8037
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 08:51:09 +0900 (JST)
Date: Fri, 30 Oct 2009 08:48:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Memory overcommit
Message-Id: <20091030084836.5428e085.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0910291248480.2276@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org>
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
	<20091028152015.3d383cd6.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910290136000.11476@chino.kir.corp.google.com>
	<4AE97861.1070902@gmail.com>
	<alpine.DEB.2.00.0910291248480.2276@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Oct 2009 12:53:42 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> > If you have OOM situation and Xorg is the first, that means it's leaking
> > memory badly and the system is probably already frozen/FUBAR. Killing
> > krunner in that situation wouldn't do any good. From a user perspective,
> > nothing changes, system is still FUBAR and (s)he would probably reboot
> > cursing linux in the process.
> > 
> 
> It depends on what you're running, we need to be able to have the option 
> of protecting very large tasks on production servers.  Imagine if "test" 
> here is actually a critical application that we need to protect, its 
> not solely mlocked anonymous memory, but still kill if it is leaking 
> memory beyond your approximate 2.5GB.  How do you do that when using rss 
> as the baseline?

As I wrote repeatedly,

   - OOM-Killer itselfs is bad thing, bad situation.
   - The kernel can't know the program is bad or not. just guess it.
   - Then, there is no "correct" OOM-Killer other than fork-bomb killer.
   - User has a knob as oom_adj. This is very strong.

Then, there is only "reasonable" or "easy-to-understand" OOM-Kill.
"Current biggest memory eater is killed" sounds reasonable, easy to
understand. And if total_vm works well, overcommit_guess should catch it.
Please improve overcommit_guess if you want to stay on total_vm.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
