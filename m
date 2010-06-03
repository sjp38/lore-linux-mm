Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 655266B01AD
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 19:11:23 -0400 (EDT)
Date: Thu, 3 Jun 2010 16:10:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
Message-Id: <20100603161030.074d9b98.akpm@linux-foundation.org>
In-Reply-To: <20100602225252.F536.A69D9226@jp.fujitsu.com>
References: <20100601163627.245D.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1006011140110.32024@chino.kir.corp.google.com>
	<20100602225252.F536.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed,  2 Jun 2010 22:54:03 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > Why?
> > 
> > If it's because the patch is too big, I've explained a few times that 
> > functionally you can't break it apart into anything meaningful.  I do not 
> > believe it is better to break functional changes into smaller patches that 
> > simply change function signatures to pass additional arguments that are 
> > unused in the first patch, for example.
> > 
> > If it's because it adds /proc/pid/oom_score_adj in the same patch, that's 
> > allowed since otherwise it would be useless with the old heuristic.  In 
> > other words, you cannot apply oom_score_adj's meaning to the bitshift in 
> > any sane way.
> > 
> > I'll suggest what I have multiple times: the easiest way to review the 
> > functional change here is to merge the patch into your own tree and then 
> > review oom_badness().  I agree that the way the diff comes out it is a 
> > little difficult to read just from the patch form, so merging it and 
> > reviewing the actual heuristic function is the easiest way.
> 
> I've already explained the reason. 1) all-of-rewrite patches are 
> always unacceptable. that's prevent our code maintainance.

No, we'll sometime completely replace implementations.  There's no hard
rule apart from "whatever makes sense".  If wholesale replacement makes
sense as a patch-presentation method then we'll do that.

> 2) no justification
> patches are also unacceptable. you need to write more proper patch descriptaion
> at least.

The descriptions look better than usual from a quick scan.  I haven't
really got into them yet.


And I'm going to have to get into it because of you guys' seeming
inability to get your act together.

The unsubstantiated "nack"s are of no use and I shall just be ignoring
them and making my own decisions.  If you have specific objections then
let's hear them.  In detail, please - don't refer to previous
conversations because that's all too confusing - there is benefit in
starting again.

I expect I'll be looking at the oom-killer situation in depth early
next week.  It would be useful if between now and then you can send
any specific, detailed and actionable comments which you have.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
