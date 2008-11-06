Date: Thu, 6 Nov 2008 14:58:21 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch 4/7] cpu ops: Core piece for generic atomic per cpu
	operations
Message-ID: <20081106035821.GA2373@disturbed>
References: <20081105231634.133252042@quilx.com> <20081105231648.462808759@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081105231648.462808759@quilx.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, travis@sgi.com, Stephen Rothwell <sfr@canb.auug.org.au>, Vegard Nossum <vegard.nossum@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 05, 2008 at 05:16:38PM -0600, Christoph Lameter wrote:
> +
> +#define __CPU_CMPXCHG(var, old, new)		\
> +({						\
> +	typeof(obj) x;				\
> +	typeof(obj) *p = THIS_CPU(&(obj));	\
> +	x = *p;					\
> +	if (x == (old))				\
> +		*p = (new);			\
> +	(x);					\
> +})

I don't think that will compile - s/obj/var/ perhaps?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
