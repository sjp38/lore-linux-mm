Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8A06B0044
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 09:56:17 -0500 (EST)
Date: Tue, 24 Nov 2009 06:57:53 -0800
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH 0/5] perf kmem: Add more functions and show more
 statistics
Message-ID: <20091124065753.6a08435b@infradead.org>
In-Reply-To: <20091124083423.GE21991@elte.hu>
References: <4B0B6E44.6090106@cn.fujitsu.com>
	<84144f020911232315h7c8b7348u9ad97f585f54a014@mail.gmail.com>
	<20091124073426.GA21991@elte.hu>
	<4B0B937F.4080906@cn.fujitsu.com>
	<20091124083423.GE21991@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Nov 2009 09:34:23 +0100
Ingo Molnar <mingo@elte.hu> wrote:
> > It would be great if perf can be used for boot time tracing. This 
> > needs pretty big work on kernel side.
> 
> What would be needed is to open per cpu events right after perf
> events initializes, and allocate memory for output buffers to them.
> 
> They would round-robin after that point, and we could use 
> perf_event_open() (with a special flag) to 'attach' to them and
> mmap() them - at which point they'd turn into regular objects with a
> lot of boot time data in them.

I'm not too worried about this btw;
we can start the userland trace early enough in the boot (the kernel is
done after 0.6 seconds after all) to capture the relevant stuff.
The actual kernel mostly gets captured with scripts/bootgraph.pl
already.

Yes it would be nice to do a timechart earlier, but if it's extremely
hard...
Also unless it starts before the drivers (eg the normal driver
initcall level), it is not useful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
