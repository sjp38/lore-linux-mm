Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2B35D6B00A7
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 01:34:48 -0500 (EST)
Message-ID: <4B21E806.6070207@cs.helsinki.fi>
Date: Fri, 11 Dec 2009 08:34:46 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] tracing: Define kmem_trace_alloc_notrace unconditionally
References: <4B21DD88.7080806@cn.fujitsu.com> <4B21DF33.7010906@cs.helsinki.fi> <4B21E07B.9040301@cn.fujitsu.com>
In-Reply-To: <4B21E07B.9040301@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>, Christoph Lameter <cl@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

Li Zefan kirjoitti:
> Pekka Enberg wrote:
>> Li Zefan wrote:
>>> Always define kmem_trace_alloc_{,node}_notrace(), otherwise
>>> perf-kmem will show wrong stats ifndef CONFIG_KMEMTRACE,
>>> because a kmalloc() memory allocation may be traced by
>>> both trace_kmalloc() and trace_kmem_cache_alloc().
>>>
>>> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
>> Did you check how much this will make kernel text bigger because of the
>> inlining happening in kmem_cache_alloc_notrace()?
>>
> 
> I'm not sure I understood what you meant, but I'm not inlining
> kmem_cache_alloc_notrace(), and instead I'm removing the inline
> version in !CONFIG_KMEMTRACE case.

In SLUB, slab_alloc() will be inlined to kmem_cache_alloc_notrace() 
increasing mm/slub.o size so we don't want to define 
kmem_cache_alloc_notrace() unconditionally.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
