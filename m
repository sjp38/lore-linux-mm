Date: Fri, 18 Jan 2008 21:46:05 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 4/5] x86: Add config variables for SMP_MAX
Message-ID: <20080118204605.GC3079@elte.hu>
References: <20080118183011.354965000@sgi.com> <20080118183011.917801000@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080118183011.917801000@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

* travis@sgi.com <travis@sgi.com> wrote:

> +config THREAD_ORDER
> +	int "Kernel stack size (in page order)"
> +	range 1 3
> +	depends on X86_64_SMP
> +	default "3" if X86_SMP_MAX
> +	default "1"
> +	help
> +	  Increases kernel stack size.

nack on kernel stack bloat. We worked hard to get the kernel stack 
footprint down to 4K on x86. (and it is 4K on most distros, despite 
there still being a legacy 8K stack size) No way are we going to throw 
away all that now ...

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
