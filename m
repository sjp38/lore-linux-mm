Subject: Re: git-slab plus git-tip breaks i386 allnoconfig
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20081009170349.35e0df12.akpm@linux-foundation.org>
References: <20081009164700.c9042902.akpm@linux-foundation.org>
	 <20081009170349.35e0df12.akpm@linux-foundation.org>
Date: Fri, 10 Oct 2008 09:45:25 +0300
Message-Id: <1223621125.8959.9.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@elte.hu, linux-mm@kvack.org, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 2008-10-09 at 17:03 -0700, Andrew Morton wrote:
> OK, i386 allmodconfig is suffering something similar.
> 
> In file included from include/linux/slub_def.h:13,
>                  from include/linux/slab.h:184,
>                  from include/linux/percpu.h:5,
>                  from include/linux/rcupdate.h:39,
>                  from include/linux/marker.h:16,
>                  from include/linux/module.h:18,
>                  from include/linux/crypto.h:21,
>                  from arch/x86/kernel/asm-offsets_32.c:7,
>                  from arch/x86/kernel/asm-offsets.c:2:
> include/linux/kmemtrace.h: In function 'kmemtrace_mark_alloc_node':
> include/linux/kmemtrace.h:33: error: implicit declaration of function 'trace_mark'
> include/linux/kmemtrace.h:33: error: 'kmemtrace_alloc' undeclared (first use in this function)
> include/linux/kmemtrace.h:33: error: (Each undeclared identifier is reported only once
> include/linux/kmemtrace.h:33: error: for each function it appears in.)
> include/linux/kmemtrace.h: In function 'kmemtrace_mark_free':
> include/linux/kmemtrace.h:44: error: 'kmemtrace_free' undeclared (first use in this function)
> 
> I'll drop the slab tree.

Oh, marker.h includes kmemtrace.h through dependencies... I'd argue
that's a marker.h bug; otherwise I don't see how we can use it in slab.
Mathieu?

		Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
