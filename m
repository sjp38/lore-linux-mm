Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 18EB26B00B0
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 02:56:19 -0500 (EST)
Date: Fri, 11 Dec 2009 08:56:04 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/2] tracing: Define kmem_cache_alloc_notrace ifdef
 CONFIG_TRACING
Message-ID: <20091211075604.GC31149@elte.hu>
References: <4B21F89A.7000801@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B21F89A.7000801@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>


* Li Zefan <lizf@cn.fujitsu.com> wrote:

> Define kmem_trace_alloc_{,node}_notrace() if CONFIG_TRACING is
> enabled, otherwise perf-kmem will show wrong stats ifndef
> CONFIG_KMEM_TRACE, because a kmalloc() memory allocation may
> be traced by both trace_kmalloc() and trace_kmem_cache_alloc().
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> ---
>  include/linux/slab_def.h |    4 ++--
>  include/linux/slub_def.h |    4 ++--
>  mm/slab.c                |    6 +++---
>  mm/slub.c                |    4 ++--
>  4 files changed, 9 insertions(+), 9 deletions(-)

Pekka, can i add your Reviewed-by or Acked-by to this v2 version of the 
patch?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
