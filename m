Subject: Re: [RFC 6/8] x86_64: Define the macros and tables for the basic UV infrastructure.
References: <20080324182118.GA21758@sgi.com>
From: Andi Kleen <andi@firstfloor.org>
Date: 25 Mar 2008 11:11:11 +0100
In-Reply-To: <20080324182118.GA21758@sgi.com>
Message-ID: <87ej9zi05c.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jack Steiner <steiner@sgi.com> writes:

> Define the macros and tables for the basic UV infrastructure.
> 
> 
> (NOTE: a work-in-progress. Pieces missing....)

Does the kernel really need all this information? You just want
to address the UV-APIC right? I suspect you could use a much stripped
down file.

> +DECLARE_PER_CPU(struct uv_hub_info_s, __uv_hub_info);
> +#define uv_hub_info 		(&__get_cpu_var(__uv_hub_info))
> +#define uv_cpu_hub_info(cpu)	(&per_cpu(__uv_hub_info, cpu))
> +
> +/* This header file is used in BIOS code that runs in physical mode */

Not sure what physical mode is.

> +#ifdef __BIOS__
> +#define UV_ADDR(x)		((unsigned long *)(x))
> +#else
> +#define UV_ADDR(x)		((unsigned long *)__va(x))
> +#endif

But it it would be cleaner if your BIOS just supplied a suitable __va()
and then you remove these macros.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
