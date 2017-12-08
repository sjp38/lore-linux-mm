Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5916B0033
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 05:56:45 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id p1so8523893pfp.13
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 02:56:45 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 97si5273595plc.450.2017.12.08.02.56.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Dec 2017 02:56:44 -0800 (PST)
Date: Fri, 8 Dec 2017 11:56:40 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] sched/autogroup: move sched.h include
Message-ID: <20171208105640.2ovmvxpds6psdnnq@hirez.programming.kicks-ass.net>
References: <20171208025616.16267-2-sergey.senozhatsky@gmail.com>
 <20171208082422.5021-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208082422.5021-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Fri, Dec 08, 2017 at 05:24:22PM +0900, Sergey Senozhatsky wrote:
> Move local "sched.h" include to the bottom. sched.h defines
> several macros that are getting redefined in ARCH-specific
> code, for instance, finish_arch_post_lock_switch() and
> prepare_arch_switch(), so we need ARCH-specific definitions
> to come in first.
> 
> Suggested-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

> ---
>  kernel/sched/autogroup.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/sched/autogroup.c b/kernel/sched/autogroup.c
> index 0786227a3f48..bb4b9fe026a1 100644
> --- a/kernel/sched/autogroup.c
> +++ b/kernel/sched/autogroup.c
> @@ -1,12 +1,12 @@
>  // SPDX-License-Identifier: GPL-2.0
> -#include "sched.h"
> -
>  #include <linux/proc_fs.h>
>  #include <linux/seq_file.h>
>  #include <linux/utsname.h>
>  #include <linux/security.h>
>  #include <linux/export.h>
>  
> +#include "sched.h"
> +
>  unsigned int __read_mostly sysctl_sched_autogroup_enabled = 1;
>  static struct autogroup autogroup_default;
>  static atomic_t autogroup_seq_nr;
> -- 
> 2.15.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
