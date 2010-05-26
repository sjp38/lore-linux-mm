Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D19936B01BC
	for <linux-mm@kvack.org>; Wed, 26 May 2010 05:59:43 -0400 (EDT)
Received: by fxm11 with SMTP id 11so3804684fxm.14
        for <linux-mm@kvack.org>; Wed, 26 May 2010 02:59:41 -0700 (PDT)
Date: Wed, 26 May 2010 11:59:40 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH] tracing: Remove kmemtrace ftrace plugin
Message-ID: <20100526095934.GA5311@nowhere>
References: <4BFCE849.7090804@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BFCE849.7090804@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 05:22:17PM +0800, Li Zefan wrote:
> We have been resisting new ftrace plugins and removing existing
> ones, and kmemtrace has been superseded by kmem trace events
> and perf-kmem, so we remove it.
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
> ---
>  Documentation/ABI/testing/debugfs-kmemtrace |   71 ----
>  Documentation/trace/kmemtrace.txt           |  126 -------
>  MAINTAINERS                                 |    7 -
>  include/linux/kmemtrace.h                   |   25 --
>  include/linux/slab_def.h                    |    3 +-
>  include/linux/slub_def.h                    |    3 +-
>  init/main.c                                 |    2 -
>  kernel/trace/Kconfig                        |   20 -
>  kernel/trace/kmemtrace.c                    |  529 ---------------------------
>  kernel/trace/trace.h                        |   13 -
>  kernel/trace/trace_entries.h                |   35 --
>  mm/slab.c                                   |    1 -
>  mm/slub.c                                   |    1 -
>  13 files changed, 4 insertions(+), 832 deletions(-)
>  delete mode 100644 Documentation/ABI/testing/debugfs-kmemtrace
>  delete mode 100644 Documentation/trace/kmemtrace.txt
>  delete mode 100644 include/linux/kmemtrace.h
>  delete mode 100644 kernel/trace/kmemtrace.c



Thanks!

Just one thing: you forgot to update the kernel/trace/Makefile

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
