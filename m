Received: by ug-out-1314.google.com with SMTP id m2so175220uge
        for <linux-mm@kvack.org>; Tue, 26 Jun 2007 12:10:40 -0700 (PDT)
Message-ID: <29495f1d0706261204x5b49511co18546443c78033fd@mail.gmail.com>
Date: Tue, 26 Jun 2007 12:04:18 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: [PATCH] slob: poor man's NUMA support.
In-Reply-To: <Pine.LNX.4.64.0706261112380.18010@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070619090616.GA23697@linux-sh.org>
	 <20070626002131.ff3518d4.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0706261112380.18010@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Mundt <lethal@linux-sh.org>, Matt Mackall <mpm@selenic.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 6/26/07, Christoph Lameter <clameter@sgi.com> wrote:
> On Tue, 26 Jun 2007, Andrew Morton wrote:
>
> > > +#ifdef CONFIG_NUMA
> > > +   if (node != -1)
> > > +           page = alloc_pages_node(node, gfp, order);
> > > +   else
> > > +#endif
> > > +           page = alloc_pages(gfp, order);
> >
> > Isn't the above equivalent to a bare
> >
> >       page = alloc_pages_node(node, gfp, order);
> >
> > ?
>
> No. alloc_pages follows memory policy. alloc_pages_node does not. One of
> the reasons that I want a new memory policy layer are these kinds of
> strange uses.

What would break by changing, in alloc_pages_node()

        if (nid < 0)
                nid = numa_node_id();

to

        if (nid < 0)
                return alloc_pages_current(gfp_mask, order);

beyond needing to make alloc_pages_current() defined if !NUMA too.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
