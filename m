Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id D39186B0009
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 12:41:15 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id g6so51149503igt.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 09:41:15 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0145.hostedemail.com. [216.40.44.145])
        by mx.google.com with ESMTPS id m8si7137175igv.95.2016.03.02.09.41.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 09:41:15 -0800 (PST)
Date: Wed, 2 Mar 2016 12:41:10 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v4 4/7] arch, ftrace: For KASAN put hard/soft IRQ
 entries into separate sections
Message-ID: <20160302124110.3769070a@gandalf.local.home>
In-Reply-To: <ae0fd7e5bdabbea6ad3f164a3b21e05e6c26deea.1456504662.git.glider@google.com>
References: <cover.1456504662.git.glider@google.com>
	<ae0fd7e5bdabbea6ad3f164a3b21e05e6c26deea.1456504662.git.glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 26 Feb 2016 17:48:44 +0100
Alexander Potapenko <glider@google.com> wrote:

> KASAN needs to know whether the allocation happens in an IRQ handler.
> This lets us strip everything below the IRQ entry point to reduce the
> number of unique stack traces needed to be stored.
> 
> Move the definition of __irq_entry to <linux/interrupt.h> so that the
> users don't need to pull in <linux/ftrace.h>. Also introduce the
> __softirq_entry macro which is similar to __irq_entry, but puts the
> corresponding functions to the .softirqentry.text section.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>

Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve

> ---
> v2: - per request from Steven Rostedt, moved the declarations of __softirq_entry
> and __irq_entry to <linux/interrupt.h>
> 
> v3: - minor description changes
> ---
>  arch/arm/kernel/vmlinux.lds.S        |  1 +
>  arch/arm64/kernel/vmlinux.lds.S      |  1 +
>  arch/blackfin/kernel/vmlinux.lds.S   |  1 +
>  arch/c6x/kernel/vmlinux.lds.S        |  1 +
>  arch/metag/kernel/vmlinux.lds.S      |  1 +
>  arch/microblaze/kernel/vmlinux.lds.S |  1 +
>  arch/mips/kernel/vmlinux.lds.S       |  1 +
>  arch/nios2/kernel/vmlinux.lds.S      |  1 +
>  arch/openrisc/kernel/vmlinux.lds.S   |  1 +
>  arch/parisc/kernel/vmlinux.lds.S     |  1 +
>  arch/powerpc/kernel/vmlinux.lds.S    |  1 +
>  arch/s390/kernel/vmlinux.lds.S       |  1 +
>  arch/sh/kernel/vmlinux.lds.S         |  1 +
>  arch/sparc/kernel/vmlinux.lds.S      |  1 +
>  arch/tile/kernel/vmlinux.lds.S       |  1 +
>  arch/x86/kernel/vmlinux.lds.S        |  1 +
>  include/asm-generic/vmlinux.lds.h    | 12 +++++++++++-
>  include/linux/ftrace.h               | 11 -----------
>  include/linux/interrupt.h            | 20 ++++++++++++++++++++
>  kernel/softirq.c                     |  2 +-
>  kernel/trace/trace_functions_graph.c |  1 +
>  21 files changed, 49 insertions(+), 13 deletions(-)
> 
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
