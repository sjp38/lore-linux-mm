Date: Fri, 11 Jul 2008 17:52:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][RFC] dirty balancing for cgroups
Message-Id: <20080711175213.dc69f068.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080711083446.AC5425A22@siro.lan>
References: <20080711161349.c5831081.kamezawa.hiroyu@jp.fujitsu.com>
	<20080711083446.AC5425A22@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: linux-mm@kvack.org, menage@google.com, containers@lists.linux-foundation.org, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jul 2008 17:34:46 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:

> hi,
> 
> > > my patch penalizes heavy-writer cgroups as task_dirty_limit does
> > > for heavy-writer tasks.  i don't think that it's necessary to be
> > > tied to the memory subsystem because i merely want to group writers.
> > > 
> > Hmm, maybe what I need is different from this ;)
> > Does not seem to be a help for memory reclaim under memcg.
> 
> to implement what you need, i think that we need to keep track of
> the numbers of dirty-pages in each memory cgroups as a first step.
> do you agree?
> 
yes, I think so, now.

may be not difficult but will add extra overhead ;( Sigh..



Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
