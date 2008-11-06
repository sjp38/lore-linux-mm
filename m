Date: Thu, 6 Nov 2008 09:05:46 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 4/7] cpu ops: Core piece for generic atomic per cpu
 operations
In-Reply-To: <20081106035821.GA2373@disturbed>
Message-ID: <Pine.LNX.4.64.0811060905280.3595@quilx.com>
References: <20081105231634.133252042@quilx.com> <20081105231648.462808759@quilx.com>
 <20081106035821.GA2373@disturbed>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, travis@sgi.com, Stephen Rothwell <sfr@canb.auug.org.au>, Vegard Nossum <vegard.nossum@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 6 Nov 2008, Dave Chinner wrote:

> On Wed, Nov 05, 2008 at 05:16:38PM -0600, Christoph Lameter wrote:
> > +
> > +#define __CPU_CMPXCHG(var, old, new)		\
> > +({						\
> > +	typeof(obj) x;				\
> > +	typeof(obj) *p = THIS_CPU(&(obj));	\
> > +	x = *p;					\
> > +	if (x == (old))				\
> > +		*p = (new);			\
> > +	(x);					\
> > +})
>
> I don't think that will compile - s/obj/var/ perhaps?

Correct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
