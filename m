Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B91666B004A
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 20:05:30 -0500 (EST)
Message-ID: <4CEDB53E.5000203@cn.fujitsu.com>
Date: Thu, 25 Nov 2010 09:00:46 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/2] [PATCH 2/2] tracing/slub: Move kmalloc tracepoint
 out of inline code
References: <20101124212333.808256210@goodmis.org> <20101124212717.468748477@goodmis.org>
In-Reply-To: <20101124212717.468748477@goodmis.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Richard Kennedy <richard@rsk.demon.co.uk>
List-ID: <linux-mm.kvack.org>

Cc: Richard Kennedy <richard@rsk.demon.co.uk>

Steven Rostedt wrote:
> From: Steven Rostedt <srostedt@redhat.com>
> 
> The tracepoint for kmalloc is in the slub inlined code which causes
> every instance of kmalloc to have the tracepoint.
> 
> This patch moves the tracepoint out of the inline code to the
> slub C file (and to page_alloc), which removes a large number of
> inlined trace points.
> 
>   objdump -dr vmlinux.slub| grep 'jmpq.*<trace_kmalloc' |wc -l
> 375
>   objdump -dr vmlinux.slub.patched| grep 'jmpq.*<trace_kmalloc' |wc -l
> 2
> 
> This also has a nice impact on size.
>    text	   data	    bss	    dec	    hex	filename
> 7050424	1961068	2482688	11494180	 af6324	vmlinux.slub
> 6979599	1944620	2482688	11406907	 ae0e3b	vmlinux.slub.patched
> 
> Siged-off-by: Steven Rostedt <rostedt@goodmis.org>

See this patch from Richard: :)

http://marc.info/?l=linux-kernel&m=128765337729262&w=2

But he only touched slub.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
