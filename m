Date: Mon, 18 Jun 2007 14:55:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 05/26] Slab allocators: Cleanup zeroing allocations
In-Reply-To: <84144f020706181316u70145db2i786641d265e5bc42@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0706181454370.14261@schroedinger.engr.sgi.com>
References: <20070618095838.238615343@sgi.com>  <20070618095914.622685354@sgi.com>
 <84144f020706181316u70145db2i786641d265e5bc42@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, 18 Jun 2007, Pekka Enberg wrote:

> On 6/18/07, clameter@sgi.com <clameter@sgi.com> wrote:
> > +static inline void *kmem_cache_zalloc(struct kmem_cache *k, gfp_t flags)
> > +{
> > +       return kmem_cache_alloc(k, flags | __GFP_ZERO);
> > +}
> > +
> > +static inline void *__kzalloc(int size, gfp_t flags)
> > +{
> > +       return kmalloc(size, flags | __GFP_ZERO);
> > +}
> 
> Hmm, did you check kernel text size before and after this change?
> Setting the __GFP_ZERO flag at every kzalloc call-site seems like a
> bad idea.

I did not check but the flags are usually constant. Compiler does the |.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
