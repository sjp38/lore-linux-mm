Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0B0816B008C
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 22:38:46 -0500 (EST)
Message-ID: <4B21BEAF.8090402@cn.fujitsu.com>
Date: Fri, 11 Dec 2009 11:38:23 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] tracing: Define kmem_trace_alloc_notrace unconditionally
References: <4B21BA6F.2080508@cn.fujitsu.com>
In-Reply-To: <4B21BA6F.2080508@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

Li Zefan wrote:
> Always define kmem_trace_alloc_{,node}_notrace(), otherwise
> perf-kmem will show wrong stats ifndef CONFIG_KMEMTRACE,
> because a kmalloc() memory allocation may be traced by
> both trace_kmalloc and trace_kmem_cache_alloc.
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> ---
>  include/linux/slab_def.h |   24 ++----------------------
>  include/linux/slub_def.h |   27 +++------------------------
>  mm/slab.c                |    4 ----
>  mm/slub.c                |    4 ----
>  4 files changed, 5 insertions(+), 54 deletions(-)
> 

Sorry, please ignore this patch. I'll send a v2 soon..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
