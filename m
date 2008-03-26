Date: Wed, 26 Mar 2008 07:40:45 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 01/10] x86_64: Cleanup non-smp usage of cpu maps v2
Message-ID: <20080326064045.GF18301@elte.hu>
References: <20080325220650.835342000@polaris-admin.engr.sgi.com> <20080325220651.011213000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080325220651.011213000@polaris-admin.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

* Mike Travis <travis@sgi.com> wrote:

> Cleanup references to the early cpu maps for the non-SMP configuration 
> and remove some functions called for SMP configurations only.

thanks, applied.

one observation:

> +#ifdef CONFIG_SMP
>  extern int x86_cpu_to_node_map_init[];
>  extern void *x86_cpu_to_node_map_early_ptr;
> +#else
> +#define x86_cpu_to_node_map_early_ptr NULL
> +#endif

Right now all these early_ptrs are in essence open-coded "early 
per-cpu", right? But shouldnt we solve that in a much cleaner way: by 
explicitly adding an early-per-cpu types and accessors, and avoid all 
that #ifdeffery?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
