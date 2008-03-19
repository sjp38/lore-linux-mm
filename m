Date: Wed, 19 Mar 2008 22:42:27 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [2/2] vmallocinfo: Add caller information
Message-ID: <20080319214227.GA4454@elte.hu>
References: <20080318222701.788442216@sgi.com> <20080318222827.519656153@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080318222827.519656153@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <clameter@sgi.com> wrote:

> Add caller information so that /proc/vmallocinfo shows where the 
> allocation request for a slice of vmalloc memory originated.

please use one simple save_stack_trace() instead of polluting a dozen 
architectures with:

> -	return __ioremap(phys_addr, size, IOR_MODE_UNCACHED);
> +	return __ioremap_caller(phys_addr, size, IOR_MODE_UNCACHED,
> +						__builtin_return_address(0));

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
