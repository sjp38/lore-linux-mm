Date: Mon, 19 Jul 2004 09:42:06 -0500
From: Dimitri Sivanich <sivanich@sgi.com>
Subject: Re: [PATCH] Move cache_reap out of timer context
Message-ID: <20040719144206.GA11585@sgi.com>
References: <20040714180942.GA18425@sgi.com> <20040717185256.GA5815@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040717185256.GA5815@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Manfred Spraul <manfred@colorfullife.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lse-tech@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Sat, Jul 17, 2004 at 08:52:56PM +0200, Ingo Molnar wrote:
> 
> * Dimitri Sivanich <sivanich@sgi.com> wrote:
> 
> > I'm submitting two patches associated with moving cache_reap
> > functionality out of timer context.  Note that these patches do not
> > make any further optimizations to cache_reap at this time.
> > 
> > The first patch adds a function similiar to schedule_delayed_work to
> > allow work to be scheduled on another cpu.
> > 
> > The second patch makes use of schedule_delayed_work_on to schedule
> > cache_reap to run from keventd.
> > 
> > These patches apply to 2.6.8-rc1.
> > 
> > Signed-off-by: Dimitri Sivanich <sivanich@sgi.com>
> 
> looks good to me and i agree with moving this unbound execution-time
> function out of irq context. I suspect this should see some -mm testing
> first/too?
> 
If others could test this patch on whatever platforms they have available, I
would very much appreciate it.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
