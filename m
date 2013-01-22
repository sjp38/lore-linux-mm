Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 240676B0004
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 08:41:22 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id hq4so5914140wib.2
        for <linux-mm@kvack.org>; Tue, 22 Jan 2013 05:41:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1358848018-3679-1-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1358848018-3679-1-git-send-email-ezequiel.garcia@free-electrons.com>
Date: Tue, 22 Jan 2013 15:41:19 +0200
Message-ID: <CAOJsxLFFWPChApkuec17Z09Z11OS5Q+XSHo4U4mSc754dC1-ww@mail.gmail.com>
Subject: Re: [RFC/PATCH] scripts/tracing: Add trace_analyze.py tool
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tim Bird <tim.bird@am.sony.com>, Ezequiel Garcia <elezegarcia@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@redhat.com>

(Adding acme to CC.)

On Tue, Jan 22, 2013 at 11:46 AM, Ezequiel Garcia
<ezequiel.garcia@free-electrons.com> wrote:
> From: Ezequiel Garcia <elezegarcia@gmail.com>
>
> The purpose of trace_analyze.py tool is to perform static
> and dynamic memory analysis using a kmem ftrace
> log file and a built kernel tree.
>
> This script and related work has been done on the CEWG/2012 project:
> "Kernel dynamic memory allocation tracking and reduction"
> (More info here [1])
>
> It produces mainly two kinds of outputs:
>  * an account-like output, similar to the one given by Perf, example below.
>  * a ring-char output, examples here [2].
>
> $ ./scripts/tracing/trace_analyze.py -k linux -f kmem.log --account-file account.txt
> $ ./scripts/tracing/trace_analyze.py -k linux -f kmem.log -c account.txt
>
> This will produce an account file like this:
>
>     current bytes allocated:     669696
>     current bytes requested:     618823
>     current wasted bytes:         50873
>     number of allocs:              7649
>     number of frees:               2563
>     number of callers:              115
>
>      total    waste      net alloc/free  caller
>     ---------------------------------------------
>     299200        0   298928  1100/1     alloc_inode+0x4fL
>     189824        0   140544  1483/385   __d_alloc+0x22L
>      51904        0    47552   811/68    sysfs_new_dirent+0x4eL
>     [...]
>
> [1] http://elinux.org/Kernel_dynamic_memory_analysis
> [2] http://elinux.org/Kernel_dynamic_memory_analysis#Current_dynamic_footprint
>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: Frederic Weisbecker <fweisbec@gmail.com>
> Cc: Ingo Molnar <mingo@redhat.com>
> Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>

Looks really useful! Dunno if this makes most sense as a separate
script or as an extension perf.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
