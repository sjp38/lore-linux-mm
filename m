Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6C6CD6B0088
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 02:47:17 -0500 (EST)
Date: Tue, 24 Nov 2009 08:47:03 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/5] perf kmem: Add more functions and show more
 statistics
Message-ID: <20091124074703.GB21991@elte.hu>
References: <4B0B6E44.6090106@cn.fujitsu.com>
 <84144f020911232315h7c8b7348u9ad97f585f54a014@mail.gmail.com>
 <20091124073426.GA21991@elte.hu>
 <84144f020911232345j75c93ec6mf1fc426262c14eb0@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020911232345j75c93ec6mf1fc426262c14eb0@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Arjan van de Ven <arjan@infradead.org>, Li Zefan <lizf@cn.fujitsu.com>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> Hi Ingo,
> 
> On Tue, Nov 24, 2009 at 9:34 AM, Ingo Molnar <mingo@elte.hu> wrote:
> > Certainly we can postpone it, as long as there's rough strategic
> > consensus on the way forward. I'd hate to have two overlapping core
> > kernel facilities and friction between the groups pursuing them and
> > constant distraction from having two targets.
> 
> Sure, like I said, I think "kmem perf" is the way forward. The only 
> reason we did kmemtrace userspace out-of-tree was because there was no 
> perf (or ftrace!) at the time and there wasn't much interest in 
> putting userspace tools in the tree.
> 
> I hope that counts as a "rough strategic consensus" :-)

it does :-)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
