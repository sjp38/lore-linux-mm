Subject: Re: [PATCH] [438/2many] MAINTAINERS - SLAB ALLOCATOR
From: Joe Perches <joe@perches.com>
In-Reply-To: <Pine.LNX.4.64.0708131345130.27728@schroedinger.engr.sgi.com>
References: <46bffbc9.9Jtz7kOTKn1mqlkq%joe@perches.com>
	 <Pine.LNX.4.64.0708131345130.27728@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 13 Aug 2007 14:12:37 -0700
Message-Id: <1187039557.10249.312.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: torvalds@linux-foundation.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-08-13 at 13:46 -0700, Christoph Lameter wrote:
> On Sun, 12 Aug 2007, joe@perches.com wrote:
> 
> > Add file pattern to MAINTAINER entry
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> > 
> > diff --git a/MAINTAINERS b/MAINTAINERS
> > index b2dd6f5..a3c6123 100644
> > --- a/MAINTAINERS
> > +++ b/MAINTAINERS
> > @@ -4168,6 +4168,8 @@ P:	Pekka Enberg
> >  M:	penberg@cs.helsinki.fi
> >  L:	linux-mm@kvack.org
> >  S:	Maintained
> > +F:	include/linux/slab*
> 
> Use include/linux/sl?b*.h 
> 
> > +F:	mm/slab.c
> 
> Use mm/sl?b.c ?
> 
> Otherwise this does not include slub f.e.

Do you want slob too?

SLAB/SLUB ALLOCATOR
P:	Christoph Lameter
M:	clameter@sgi.com
P:	Pekka Enberg
M:	penberg@cs.helsinki.fi
L:	linux-mm@kvack.org
S:	Maintained
F:	include/linux/slab*.h
F:	include/linux/slub*.h
F:	mm/slab.c
F:	mm/slub.c

otherwise:

SLAB/SLUB ALLOCATOR
P:	Christoph Lameter
M:	clameter@sgi.com
P:	Pekka Enberg
M:	penberg@cs.helsinki.fi
L:	linux-mm@kvack.org
S:	Maintained
F:	include/linux/sl?b*.h
F:	mm/sl?b.c


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
