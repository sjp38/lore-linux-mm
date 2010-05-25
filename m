Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 992B16008F9
	for <linux-mm@kvack.org>; Tue, 25 May 2010 06:06:18 -0400 (EDT)
Date: Tue, 25 May 2010 20:05:59 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: oom killer rewrite
Message-ID: <20100525100559.GI5087@laptop>
References: <alpine.DEB.2.00.1005191511140.27294@chino.kir.corp.google.com>
 <20100524100840.1E95.A69D9226@jp.fujitsu.com>
 <20100524070714.GV2516@laptop>
 <alpine.DEB.2.00.1005250242260.8045@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1005250242260.8045@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 25, 2010 at 02:46:06AM -0700, David Rientjes wrote:
> On Mon, 24 May 2010, Nick Piggin wrote:
> 
> > > > I've been notified that my entire oom killer rewrite has been dropped from 
> > > > -mm based solely on your feedback.  The problem is that I have absolutely 
> > > > no idea what issues you have with the changes that haven't already been 
> > > > addressed (nobody else does, either, it seems).
> > 
> > I had exactly the same issues with the userland kernel API changes and
> > the pagefault OOM regression it introduced, which I told you months ago.
> > You ignored me, it seems.
> > 
> 
> No, I didn't ignore you, your comments were specifically addressed with 
> oom-reintroduce-and-deprecate-oom_kill_allocating_task.patch which only 
> deprecated the API change and wasn't even scheduled for removal until of 
> the end of 2011.  So there were no kernel API changes that went 

OK, you still never justified why that change is needed, or why it
is even a cleanup at all. You need actually a *good* reason to change
the user kernel API. A slight difference in opinion of what the sysctls
should be, or a slight change in implementation in the kernel, is not
a good reason in the slightest.

Look at something like /proc/sys/fs/inode-state and dentry-state or
the old syscalls we accumulate.

The point about not many people using the parameters I don't think is
a good one. 2.6.32 is being used in the next enterprise kernels so they
are going to be in production for 5 or more years. How many people will
have written scripts by the time they upgrade?


> unaddressed, perhaps you just didn't see that patch (I cc'd it to you on 
> April 27, though).
> 
> The pagefault oom behavior can now be changed back since you've converted 
> all existing architectures to call into the oom killer and not simply kill 
> current (thanks for that work!).  Previously, there was an inconsistency 
> amongst architectures in panic_on_oom behavior that we can now unify into 
> semantics that work across the board.

Thanks that would be good. I'll do another pass shortly to make sure
all archs are converted in this window if possible.


> I've made that change in my latest patch series which I'll be posting 
> shortly.

The other thing is that it makes perfect sense to put controversial
changes on hold even if you still think you can make a case for them.
We could have already gotten *most* (and the most useful to you) of
it merged by now. Then if there is a single controversial patch rather
than a big series, Andrew or Linus say is much more likely to take a
look and weigh in.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
