Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 93FD9600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 20:02:42 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7305nH0016184
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Aug 2010 09:05:49 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D077745DE55
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 09:05:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 926C145DE51
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 09:05:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 69543E18006
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 09:05:48 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C9211DB803F
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 09:05:48 +0900 (JST)
Date: Tue, 3 Aug 2010 09:00:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
Message-Id: <20100803090058.48c0a0c9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100802134312.c0f48615.akpm@linux-foundation.org>
References: <20100730091125.4AC3.A69D9226@jp.fujitsu.com>
	<20100729183809.ca4ed8be.akpm@linux-foundation.org>
	<20100730195338.4AF6.A69D9226@jp.fujitsu.com>
	<20100802134312.c0f48615.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2 Aug 2010 13:43:12 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 30 Jul 2010 20:02:13 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > On Fri, 30 Jul 2010 09:12:26 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > > 
> > > > > On Sat, 17 Jul 2010 12:16:33 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> > > > > 
> > > > > > This a complete rewrite of the oom killer's badness() heuristic 
> > > > > 
> > > > > Any comments here, or are we ready to proceed?
> > > > > 
> > > > > Gimme those acked-bys, reviewed-bys and tested-bys, please!
> > > > 
> > > > If he continue to resend all of rewrite patch, I continue to refuse them.
> > > > I explained it multi times.
> > > 
> > > There are about 1000 emails on this topic.  Please briefly explain it again.
> > 
> > Major homework are
> > 
> > - make patch series instead unreviewable all in one patch.
> 
> Sometimes that's not very practical and the splitup isn't necessarily a
> lot easier to understand and review.
> 
> It's still possible to review the end result - just read the patched code.
> 
> > - kill oom_score_adj
> 
> Unclear why?
> 

One reason I poitned out is that this new parameter is hard to use for admins and
library writers. 
  old oom_adj was defined as an parameter works as 
		(memory usage of app)/oom_adj.
  new oom_score_adj was define as
		(memory usage of app * oom_score_adj)/ system_memory

Then, an applications' oom_score on a host is quite different from on the other
host. This operation is very new rather than a simple interface updates.
This opinion was rejected.

Anyway, I believe the value other than OOM_DISABLE is useless,
I have no concerns. I'll use memcg if I want to control this kind of things.

Because I know the new calculation logic works better at default, I welcome
this patch itself in general.

Thanks,
-Kame








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
