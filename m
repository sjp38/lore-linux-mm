Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D96B86B005A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 07:53:33 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n73CCtRq011450
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 3 Aug 2009 21:12:55 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 227DA45DE58
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 21:12:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D3E9645DE57
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 21:12:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A61631DB8041
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 21:12:54 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D6B21DB803A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 21:12:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
In-Reply-To: <20090803200639.CC1D.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.2.00.0907310210460.25447@chino.kir.corp.google.com> <20090803200639.CC1D.A69D9226@jp.fujitsu.com>
Message-Id: <20090803211112.CC23.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  3 Aug 2009 21:12:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


One mistake.

> > > And, May I explay why I think your oom_adj_child is wrong idea?
> > > The fact is: new feature introducing never fix regression. yes, some
> > > application use new interface and disappear the problem. but other
> > > application still hit the problem. that's not correct development style
> > > in kernel.
> > > 
> > 
> > So you're proposing that we forever allow /proc/pid/oom_score to be 
> > completely wrong for pid without any knowledge to userspace?  That we 
> > falsely advertise what it represents and allow userspace to believe that 
> > changing oom_adj for a thread sharing memory with other threads actually 
> > changes how the oom killer selects tasks?
> 
> No. perhaps no doublly.
> 
> 1) In my patch, oom_score is also per-process value. all thread have the same
>    oom_score.
>    It's clear meaning.

it's wrong explanation. oom_score is calculated from the same oom_adj.
but it have each different oom_score. sorry my confused.



> 2) In almost case, oom_score display collect value because oom_adj is per-process
>    value too. 
>    Yes, there is one exception. vfork() and change oom_adj'ed process might display 
>    wrong value. but I don't think it is serious problem because vfork() process call
>    exec() soon.
>    Administrator never recognize this difference.
> 
> > Please.
> 
> David, I hope you join to fix this regression. I can't believe we
> can't fix this issue honestly.
> 
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
