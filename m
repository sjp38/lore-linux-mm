Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 069806B01AD
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 19:58:12 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o53Nw9hK008290
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 4 Jun 2010 08:58:09 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 621B845DE4E
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 08:58:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 41E6F45DE53
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 08:58:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 27AAD1DB8048
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 08:58:09 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D14031DB804F
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 08:58:05 +0900 (JST)
Date: Fri, 4 Jun 2010 08:53:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
Message-Id: <20100604085347.80c7b43f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100603161030.074d9b98.akpm@linux-foundation.org>
References: <20100601163627.245D.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1006011140110.32024@chino.kir.corp.google.com>
	<20100602225252.F536.A69D9226@jp.fujitsu.com>
	<20100603161030.074d9b98.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jun 2010 16:10:30 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed,  2 Jun 2010 22:54:03 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > Why?
> > > 
> > > If it's because the patch is too big, I've explained a few times that 
> > > functionally you can't break it apart into anything meaningful.  I do not 
> > > believe it is better to break functional changes into smaller patches that 
> > > simply change function signatures to pass additional arguments that are 
> > > unused in the first patch, for example.
> > > 
> > > If it's because it adds /proc/pid/oom_score_adj in the same patch, that's 
> > > allowed since otherwise it would be useless with the old heuristic.  In 
> > > other words, you cannot apply oom_score_adj's meaning to the bitshift in 
> > > any sane way.
> > > 
> > > I'll suggest what I have multiple times: the easiest way to review the 
> > > functional change here is to merge the patch into your own tree and then 
> > > review oom_badness().  I agree that the way the diff comes out it is a 
> > > little difficult to read just from the patch form, so merging it and 
> > > reviewing the actual heuristic function is the easiest way.
> > 
> > I've already explained the reason. 1) all-of-rewrite patches are 
> > always unacceptable. that's prevent our code maintainance.
> 
> No, we'll sometime completely replace implementations.  There's no hard
> rule apart from "whatever makes sense".  If wholesale replacement makes
> sense as a patch-presentation method then we'll do that.
> 
I agree. 

IMHO.

But this series includes both of bug fixes and new features at random.
Then, a small bugfixes, which doens't require refactoring, seems to do that.
That's irritating guys (at least me) because it seems that he tries to sneak
his own new logic into bugfix and moreover, it makes backport to distro difficult.
I'd like to beg him separate them into 2 series as bugfix and something new.


Thanks,
-Kame

 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
