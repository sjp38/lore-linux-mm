Date: Thu, 24 Jan 2008 16:59:38 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 2/3] x86: add percpu, cpu_to_node debug options
Message-ID: <20080124155938.GC4857@elte.hu>
References: <20080122230409.198261000@sgi.com> <20080122230409.514557000@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080122230409.514557000@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* travis@sgi.com <travis@sgi.com> wrote:

> +config THREAD_ORDER
> +	int "Kernel stack size (in page order)"
> +	range 1 3
> +	depends on X86_64
> +	default "3" if X86_SMP
> +	default "1"
> +	help
> +	  Increases kernel stack size.

you keep sending this broken portion, please dont ... 

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
