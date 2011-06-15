Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E1B856B0082
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 20:48:18 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A03933EE0C0
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 09:48:08 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 829D645DE6B
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 09:48:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 678F445DE4D
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 09:48:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 583161DB803A
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 09:48:08 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B74E1DB803C
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 09:48:08 +0900 (JST)
Date: Wed, 15 Jun 2011 09:41:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Panic on OOM
Message-Id: <20110615094113.fa89be99.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1308058276.2074.295.camel@compaq-desktop>
References: <1308058276.2074.295.camel@compaq-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cfowler@opsdc.com
Cc: Chris Fowler <cfowler@outpostsentinel.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 14 Jun 2011 09:31:16 -0400
Chris Fowler <cfowler@outpostsentinel.com> wrote:

> I'm running into a problem in 2.6.38 where the kernel is not doing what
> I'm expecting it to do.  I'm guessing that some things have changed and
> that is what it going on.
> 
> First,  The tune at boot:
> 
>         f.open("/proc/sys/vm/panic_on_oom", std::ios::out);
>         f << "1";
>         f.close();
> 
>         f.open("/proc/sys/kernel/panic", std::ios::out);
>         f << "10";
>         f.close();
> 
> I want the kernel to panic on out of memory.  I then want it to wait 10s
> before doing a reboot.
> 
> This program will consume all memory and make the box unresponsive
> 
> #!/usr/bin/perl
> 
> my @mem = ()
> while(1) {
>   push @mem, "########################";
> }
> 

Hmm, then, OOM-Killer wasn't invoked ?

> It does not take long to fill up 1G of space.  There is NO swap on this
> device and never will be.  I did notice that after a long period of time
> (I've not timed it) I finally do see a panic and I do see "rebooting in
> 10 seconds..." .  It does not reboot.
> 

In these month(after 2.6.38), there has been some discussion
that "oom-killer doesn't work enough or lru scan very slow" problem
in linux-mm list. (and some improvemetns have been done.)

Then, if you can post your 'test case' with precise description of
machine set up, we're glad.

> 
> I'm guessing that there are some tweaks or new behavior I just need to
> be aware of.
> 

What version of kernel did you used in previous setup ?

Thanks,
-Kame



   




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
