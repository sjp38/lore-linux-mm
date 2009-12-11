Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B49846B00B2
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 03:06:23 -0500 (EST)
Message-ID: <4B21FD7A.9010006@cs.helsinki.fi>
Date: Fri, 11 Dec 2009 10:06:18 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] tracing: Define kmem_cache_alloc_notrace ifdef CONFIG_TRACING
References: <4B21F89A.7000801@cn.fujitsu.com>
In-Reply-To: <4B21F89A.7000801@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>, Christoph Lameter <cl@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

Li Zefan kirjoitti:
> Define kmem_trace_alloc_{,node}_notrace() if CONFIG_TRACING is
> enabled, otherwise perf-kmem will show wrong stats ifndef
> CONFIG_KMEM_TRACE, because a kmalloc() memory allocation may
> be traced by both trace_kmalloc() and trace_kmem_cache_alloc().
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
