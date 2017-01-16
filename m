From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] mm/slub: Add a dump_stack() to the unexpected GFP check
Date: Mon, 16 Jan 2017 10:37:02 +0100
Message-ID: <20170116093702.tp7sbbosh23cxzng@pd.tnic>
References: <20170116091643.15260-1-bp@alien8.de>
 <20170116092840.GC32481@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170116092840.GC32481@mtr-leonro.local>
Sender: linux-kernel-owner@vger.kernel.org
To: Leon Romanovsky <leon@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Mon, Jan 16, 2017 at 11:28:40AM +0200, Leon Romanovsky wrote:
> On Mon, Jan 16, 2017 at 10:16:43AM +0100, Borislav Petkov wrote:
> > From: Borislav Petkov <bp@suse.de>
> >
> > We wanna know who's doing such a thing. Like slab.c does that.
> >
> > Signed-off-by: Borislav Petkov <bp@suse.de>
> > ---
> >  mm/slub.c | 1 +
> >  1 file changed, 1 insertion(+)
> >
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 067598a00849..1b0fa7625d6d 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -1623,6 +1623,7 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
> >  		flags &= ~GFP_SLAB_BUG_MASK;
> >  		pr_warn("Unexpected gfp: %#x (%pGg). Fixing up to gfp: %#x (%pGg). Fix your code!\n",
> >  				invalid_mask, &invalid_mask, flags, &flags);
> > +		dump_stack();
> 
> Will it make sense to change these two lines above to WARN(true, .....)?

Should be equivalent.

I'd even go a step further and make this a small inline function,
something like warn_unexpected_gfp(flags) or so and call it from both
from slab.c and slub.c.

Depending on what mm folks prefer, that is.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
