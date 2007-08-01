Date: Wed, 1 Aug 2007 08:19:01 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [rfc] balance-on-fork NUMA placement
Message-ID: <20070801061901.GA10134@elte.hu>
References: <20070731054142.GB11306@wotan.suse.de> <20070731080114.GA12367@elte.hu> <20070801002114.GB31006@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070801002114.GB31006@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <ak@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* Nick Piggin <npiggin@suse.de> wrote:

> > _after_ the dup_task_struct(). Then change sched_fork() to return a 
> > CPU number - hence we dont have a separate sched_fork_suggest_cpu() 
> > initialization function, only one, obvious sched_fork() function. 
> > Agreed?
> 
> That puts task struct, kernel stack, thread info on the wrong node.

ok, i missed that - your patch looks then fine to me.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
