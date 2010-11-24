Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 386B56B0085
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 16:27:21 -0500 (EST)
Message-Id: <20101124212333.808256210@goodmis.org>
Date: Wed, 24 Nov 2010 16:23:33 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: [RFC][PATCH 0/2] Move kmalloc tracepoints out of inlined code
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

Anyone have any objections to this code?

Tracepoints do carry a bit of weight and having them in a common
inlined function such as kmalloc() adds a bit of bloat to the kernel.

This is an RFC patch (to get comments) and hopefully will be something
to pull in for 2.6.38. It should not change the functionality
of the tracepoints, that is, you should still get the same result
from them as we have before. Just they are now inside the sl*b C code
instead of being scattered about the kernel.

If you are fine with these patches, please add your Acked-by.

Thanks,

-- Steve


The following patches are in:

  git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-2.6-trace.git

    branch: rfc/trace


Steven Rostedt (2):
      tracing/slab: Move kmalloc tracepoint out of inline code
      tracing/slub: Move kmalloc tracepoint out of inline code

----
 include/linux/slab_def.h |   33 +++++++++++++--------------------
 include/linux/slub_def.h |   46 +++++++++++++++++++++-------------------------
 mm/page_alloc.c          |   14 ++++++++++++++
 mm/slab.c                |   38 +++++++++++++++++++++++---------------
 mm/slub.c                |   27 +++++++++++++++++++--------
 5 files changed, 90 insertions(+), 68 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
