Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 216206B021A
	for <linux-mm@kvack.org>; Wed, 26 May 2010 12:07:06 -0400 (EDT)
Received: from f199130.upc-f.chello.nl ([80.56.199.130] helo=dyad.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1OHJ8K-0002ci-1M
	for linux-mm@kvack.org; Wed, 26 May 2010 16:07:04 +0000
Subject: Re: [PATCH] tracing: Remove kmemtrace ftrace plugin
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100526160028.GC5299@nowhere>
References: <4BFCE849.7090804@cn.fujitsu.com>
	 <20100526095934.GA5311@nowhere> <1274880514.27810.454.camel@twins>
	 <20100526160028.GC5299@nowhere>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 26 May 2010 18:06:59 +0200
Message-ID: <1274890019.1674.1761.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2010-05-26 at 18:00 +0200, Frederic Weisbecker wrote:

> > You can also axe kernel/tracing/trace_sysprof.c and related bits.

> I'll do that too, but I 'll need Soeren's opinion before actually pushing it.

ISTR that the latest sysprof code uses the perf syscall.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
