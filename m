Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 134EB6B007B
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 02:15:12 -0500 (EST)
Received: by fxm9 with SMTP id 9so6687865fxm.10
        for <linux-mm@kvack.org>; Mon, 23 Nov 2009 23:15:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B0B6E44.6090106@cn.fujitsu.com>
References: <4B0B6E44.6090106@cn.fujitsu.com>
Date: Tue, 24 Nov 2009 09:15:10 +0200
Message-ID: <84144f020911232315h7c8b7348u9ad97f585f54a014@mail.gmail.com>
Subject: Re: [PATCH 0/5] perf kmem: Add more functions and show more
	statistics
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Li,

On Tue, Nov 24, 2009 at 7:25 AM, Li Zefan <lizf@cn.fujitsu.com> wrote:
> Pekka, do you think we can remove kmemtrace now?

One more use case I forgot to mention: boot time tracing. Much of the
persistent kernel memory footprint comes from the boot process which
is why it's important to be able to trace memory allocations
immediately after kmem_cache_init() has run. Can we make "perf kmem"
do that? Eduard put most of his efforts into making that work for
kmemtrace.

On Tue, Nov 24, 2009 at 7:25 AM, Li Zefan <lizf@cn.fujitsu.com> wrote:
> With kmem trace events, low-level analyzing can be done using
> ftrace, and high-level analyzing can be done using perf-kmem.
>
> And chance is, more people may use and improve perf-kmem, and it
> will be well-maintained within the perf infrastructure. On the
> other hand, I guess few people use and contribute to kmemtrace-user.

Sure, I think "perf kmem" is the way forward. I'd love to hear
Eduard's comments on this before we remove the code from kernel. Do we
need to do that for 2.6.33 or can we postpone that for 2.6.34?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
