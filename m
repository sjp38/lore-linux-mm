Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8F7466B0254
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 03:06:39 -0500 (EST)
Received: by wmvv187 with SMTP id v187so19920722wmv.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 00:06:39 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id i26si6184600wmc.111.2015.11.12.00.06.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 00:06:38 -0800 (PST)
Received: by wmdw130 with SMTP id w130so143024497wmd.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 00:06:38 -0800 (PST)
Date: Thu, 12 Nov 2015 09:06:35 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 4/5] x86: dumpstack - implement show_stack_lvl()
Message-ID: <20151112080635.GA7545@gmail.com>
References: <20151105223014.701269769@redhat.com>
 <20151105223014.909080166@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151105223014.909080166@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aris@redhat.com
Cc: linux-kerne@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>


* aris@redhat.com <aris@redhat.com> wrote:

> show_stack_lvl() allows passing the log level and is used by dump_stack_lvl().
> 
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Greg Thelen <gthelen@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: David Rientjes <rientjes@google.com>
> Signed-off-by: Aristeu Rozanski <aris@redhat.com>
> 
> ---
>  arch/x86/kernel/dumpstack.c |    9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> --- linux-2.6.orig/arch/x86/kernel/dumpstack.c	2015-11-05 13:33:30.994378877 -0500
> +++ linux-2.6/arch/x86/kernel/dumpstack.c	2015-11-05 13:44:37.014856773 -0500
> @@ -180,7 +180,7 @@ void show_trace(struct task_struct *task
>  	show_trace_log_lvl(task, regs, stack, bp, "");
>  }
>  
> -void show_stack(struct task_struct *task, unsigned long *sp)
> +void show_stack_lvl(struct task_struct *task, unsigned long *sp, char *log_lvl)
>  {
>  	unsigned long bp = 0;
>  	unsigned long stack;
> @@ -194,7 +194,12 @@ unsigned long bp = 0;
>  		bp = stack_frame(current, NULL);
>  	}
>  
> -	show_stack_log_lvl(task, NULL, sp, bp, "");
> +	show_stack_log_lvl(task, NULL, sp, bp, log_lvl);
> +}
> +
> +void show_stack(struct task_struct *task, unsigned long *sp)
> +{
> +	show_stack_lvl(task, sp, KERN_DEFAULT);
>  }
>  
>  static arch_spinlock_t die_lock = __ARCH_SPIN_LOCK_UNLOCKED;

Acked-by: Ingo Molnar <mingo@kernel.org>

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
