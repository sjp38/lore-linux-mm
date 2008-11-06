Date: Thu, 6 Nov 2008 08:12:06 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 5/7] x86_64: Support for cpu ops
Message-ID: <20081106071206.GH15731@elte.hu>
References: <20081105231634.133252042@quilx.com> <20081105231649.108433550@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081105231649.108433550@quilx.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, travis@sgi.com, Stephen Rothwell <sfr@canb.auug.org.au>, Vegard Nossum <vegard.nossum@gmail.com>
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <cl@linux-foundation.org> wrote:

> +#
> +# X86_64's spare segment register points to the PDA instead of the per
> +# cpu area. Therefore x86_64 is not able to generate atomic vs. interrupt
> +# per cpu instructions.
> +#
> +config HAVE_CPU_OPS
> +	def_bool y
> +	depends on X86_32
> +

hm, what happened to the rebase-PDA-to-percpu-area optimization 
patches you guys were working on? I remember there was some binutils 
flakiness - weird crashes and things like that. Did you ever manage to 
stabilize it? It would be sad if only 32-bit could take advantage of 
the optimized ops.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
