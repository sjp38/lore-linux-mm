Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id B5E686B004A
	for <linux-mm@kvack.org>; Sat, 14 Apr 2012 00:53:21 -0400 (EDT)
Message-ID: <4F8902BF.6070801@codeaurora.org>
Date: Fri, 13 Apr 2012 21:53:19 -0700
From: Stephen Boyd <sboyd@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [Updated PATCH 3/3] tracing: Provide trace events interface for
 uprobes
References: <20120413112941.16602.69097.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20120413112941.16602.69097.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On 4/13/2012 4:29 AM, Srikar Dronamraju wrote:
> diff --git a/arch/Kconfig b/arch/Kconfig
> index e5d3778..0f8f968 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -78,7 +78,7 @@ config OPTPROBES
>  
>  config UPROBES
>  	bool "Transparent user-space probes (EXPERIMENTAL)"
> -	depends on ARCH_SUPPORTS_UPROBES && PERF_EVENTS
> +	depends on UPROBE_EVENTS && PERF_EVENTS

Is it UPROBE_EVENTS or UPROBE_EVENT?

>  	default n
>  	help
>  	  Uprobes is the user-space counterpart to kprobes: they
> diff --git a/kernel/trace/Kconfig b/kernel/trace/Kconfig
> index ce5a5c5..ea4bff6 100644
> --- a/kernel/trace/Kconfig
> +++ b/kernel/trace/Kconfig
> @@ -386,6 +386,22 @@ config KPROBE_EVENT
>  	  This option is also required by perf-probe subcommand of perf tools.
>  	  If you want to use perf tools, this option is strongly recommended.
>  
> +config UPROBE_EVENT

Looks like UPROBE_EVENT.

> +	bool "Enable uprobes-based dynamic events"
> +	depends on ARCH_SUPPORTS_UPROBES
> +	depends on MMU
> +	select UPROBES
> +	select PROBE_EVENTS
>

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
