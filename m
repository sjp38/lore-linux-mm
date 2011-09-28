Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1565F9000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 05:20:26 -0400 (EDT)
Message-ID: <4E82E6D0.4000508@hitachi.com>
Date: Wed, 28 Sep 2011 18:20:16 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 3.1.0-rc4-tip 25/26]   perf: Documentation for perf
 uprobes
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20110920120507.25326.68120.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20110920120507.25326.68120.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

(2011/09/20 21:05), Srikar Dronamraju wrote:
> Modify perf-probe.txt to include uprobe documentation

This change should be included in 23rd and 24th patches,
because the documentation should be updated with the tool
enhancement.

Thank you,

> 
> Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> ---
>  tools/perf/Documentation/perf-probe.txt |   14 ++++++++++++++
>  1 files changed, 14 insertions(+), 0 deletions(-)
> 
> diff --git a/tools/perf/Documentation/perf-probe.txt b/tools/perf/Documentation/perf-probe.txt
> index 800775e..3c98a54 100644
> --- a/tools/perf/Documentation/perf-probe.txt
> +++ b/tools/perf/Documentation/perf-probe.txt
> @@ -78,6 +78,8 @@ OPTIONS
>  -F::
>  --funcs::
>  	Show available functions in given module or kernel.
> +	With -x/--exec, can also list functions in a user space executable
> +	/ shared library.
>  
>  --filter=FILTER::
>  	(Only for --vars and --funcs) Set filter. FILTER is a combination of glob
> @@ -98,6 +100,11 @@ OPTIONS
>  --max-probes::
>  	Set the maximum number of probe points for an event. Default is 128.
>  
> +-x::
> +--exec=PATH::
> +	Specify path to the executable or shared library file for user
> +	space tracing. Can also be used with --funcs option.
> +
>  PROBE SYNTAX
>  ------------
>  Probe points are defined by following syntax.
> @@ -182,6 +189,13 @@ Delete all probes on schedule().
>  
>   ./perf probe --del='schedule*'
>  
> +Add probes at zfree() function on /bin/zsh
> +
> + ./perf probe -x /bin/zsh zfree
> +
> +Add probes at malloc() function on libc
> +
> + ./perf probe -x /lib/libc.so.6 malloc
>  
>  SEE ALSO
>  --------
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
