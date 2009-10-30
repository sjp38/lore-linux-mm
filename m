Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 155746B004D
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 05:39:16 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9U9dE8n024641
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 30 Oct 2009 18:39:14 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E36FD45DE4D
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 18:39:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C13AF45DD75
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 18:39:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id ABC8C1DB803B
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 18:39:13 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 55033E18006
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 18:39:10 +0900 (JST)
Date: Fri, 30 Oct 2009 18:36:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Memory overcommit
Message-Id: <20091030183638.1125c987.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0910300200170.18076@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org>
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
	<20091030084836.5428e085.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910300200170.18076@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 30 Oct 2009 02:10:37 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> >    - The kernel can't know the program is bad or not. just guess it.
> 
> Totally irrelevant, given your fourth point about /proc/pid/oom_adj.  We 
> can tell the kernel what we'd like the oom killer behavior should be if 
> the situation arises.
> 

My point is that the server cannot distinguish memory leak from intentional
memory usage. No other than that.



> >    - Then, there is no "correct" OOM-Killer other than fork-bomb killer.
> 
> Well of course there is, you're seeing this is a WAY too simplistic 
> manner.  If we are oom, we want to be able to influence how the oom killer 
> behaves and respond to that situation.  You are proposing that we change 
> the baseline for how the oom killer selects tasks which we use CONSTANTLY 
> as part of our normal production environment.  I'd appreciate it if you'd 
> take it a little more seriously.
> 
Yes, I'm serious.

In this summer, at lunch with a daily linux user, I was said
"you, enterprise guys, don't consider desktop or laptop problem at all."
yes, I use only servers. My customer uses server, too. My first priority
is always on server users.
But, for this time, I wrote reply to Vedran and try to fix desktop problem.
Even if current logic works well for servers, "KDE/GNOME is killed" problem
seems to be serious. And this may be a problem for EMBEDED people, I guess.


> >    - User has a knob as oom_adj. This is very strong.
> > 
> 
> Agreed.
> 
This and memcg are very useful. But everone says "bad workaround" ;(
Maybe only servers can use these functions.

> > Then, there is only "reasonable" or "easy-to-understand" OOM-Kill.
> > "Current biggest memory eater is killed" sounds reasonable, easy to
> > understand. And if total_vm works well, overcommit_guess should catch it.
> > Please improve overcommit_guess if you want to stay on total_vm.
> > 
> 
> I don't necessarily want to stay on total_vm, but I also don't want to 
> move to rss as a baseline, as you would probably agree.
> 
I'll rewrite all. I'll not rely only on rss. There are several situations
and we need some more information than we have know. I'll have to implement
ways to gather information before chaging badness.


> We disagree about a very fundamental principle: you are coming from a 
> perspective of always wanting to kill the biggest resident memory eater 
> even for a single order-0 allocation that fails and I'm coming from a 
> perspective of wanting to ensure that our machines know how the oom killer 
> will react when it is used. 
yes.

> Moving to rss reduces the ability of the user to specify an expected oom
> priority other than polarizing it by either 
> disabling it completely with an oom_adj value of -17 or choosing the 
> definite next victim with +15.  That's my objection to it: the user cannot 
> possibly be expected to predict what proportion of each application's 
> memory will be resident at the time of oom.
> 
I can say the same thing to total_vm size. total_vm size doesn't include any
good information for oom situation. And tweaking based on that not-useful
parameter will make things worse.

For oom_adj tweak, we may need other technique other than "shift".
If I've wrote oom_adj, I'll write it as

   /proc/<pid>/guarantee_nooom_size

  #echo 3G > /proc/<pid>/guarantee_nooom_size

  Then, 3G bytes of this process's memory usage will not be accounted to badness.

I'm not sure I can add new interface or replace oom_adj, now.
But to do this, current chilren's score problem etc...should be fixed.

> I understand you want to totally rewrite the oom killer for whatever 
> reason, but I think you need to spend a lot more time understanding the 
> needs that the Linux community has for its behavior instead of insisting 
> on your point of view.
> 
yes, use more time. I don't think all of changes can be in quick work.

To be honest, this is a part of work to implement "custom oom handler" cgroup.
Before going further, I'd like to fix current problem.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
