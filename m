Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C00456B00A1
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 03:55:52 -0500 (EST)
Date: Fri, 20 Nov 2009 09:55:36 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC][PATCH 1/2] perf: Add 'perf kmem' tool
Message-ID: <20091120085536.GC19778@elte.hu>
References: <4B064AF5.9060208@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B064AF5.9060208@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Li Zefan <lizf@cn.fujitsu.com> wrote:

> ---
>  tools/perf/Makefile       |    1 +
>  tools/perf/builtin-kmem.c |  578 +++++++++++++++++++++++++++++++++++++++++++++
>  tools/perf/builtin.h      |    1 +
>  tools/perf/perf.c         |   27 +-
>  4 files changed, 594 insertions(+), 13 deletions(-)
>  create mode 100644 tools/perf/builtin-kmem.c

btw., you might want to add it to command-list.txt as well (in a future 
patch), so that 'kmem' shows up in the default 'perf' output.

Plus a Documentation/perf-kmem.txt file will make sure that 'perf help 
kmem' and 'perf kmem --help' displays a help page, etc.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
