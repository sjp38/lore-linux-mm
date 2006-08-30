Date: Wed, 30 Aug 2006 05:20:10 -0500
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [RFC][PATCH 02/10] conditionally define generic get_order() (ARCH_HAS_GET_ORDER)
Message-ID: <20060830102010.GB10629@localhost.internal.ocgnet.org>
References: <20060829201934.47E63D1F@localhost.localdomain> <20060829201935.9954D4F2@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060829201935.9954D4F2@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org, rdunlap@xenotime.net
List-ID: <linux-mm.kvack.org>

On Tue, Aug 29, 2006 at 01:19:35PM -0700, Dave Hansen wrote:
> This is very greppable.  If you grep and see foo() showing up in
> asm-generic/foo.h, it is *obvious* that it is a generic version.  If you
> see another version in asm-i386/foo.h, it is also obvious that i386 has
> (or can) override the generic one.
> 
[snip]
> So, is _this_ patch disgusting?

The only problem I see with sticking this in mm/Kconfig is that it's not
immediately apparent from poking through asm-<arch> what is specially
provided by the architecture to override the generic fallback (though
some might even consider this a benefit). One has to first find the
symbol of interest in asm-generic, figure out the config option guarding
it, and then grep the rest of the Kconfig hierarchy to figure out which
architectures actually use the thing, or stick purely with symbol
lookup.

>From a .config point of view, this is certainly far more readable
compared to asm-<arch> lookups, though I'm not entirely convinced that
this really buys us much in the greppability or reduced complexity
department.

If the new trend is to forego any future HAVE_ARCH_xxx definitions, then
I suppose this is the way to go.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
