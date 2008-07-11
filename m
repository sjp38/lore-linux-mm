Subject: Re: [PATCH][RFC] dirty balancing for cgroups
In-Reply-To: Your message of "Fri, 11 Jul 2008 16:13:49 +0900"
	<20080711161349.c5831081.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080711161349.c5831081.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080711083446.AC5425A22@siro.lan>
Date: Fri, 11 Jul 2008 17:34:46 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, menage@google.com, containers@lists.linux-foundation.org, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

hi,

> > my patch penalizes heavy-writer cgroups as task_dirty_limit does
> > for heavy-writer tasks.  i don't think that it's necessary to be
> > tied to the memory subsystem because i merely want to group writers.
> > 
> Hmm, maybe what I need is different from this ;)
> Does not seem to be a help for memory reclaim under memcg.

to implement what you need, i think that we need to keep track of
the numbers of dirty-pages in each memory cgroups as a first step.
do you agree?

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
