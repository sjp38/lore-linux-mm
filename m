Date: Fri, 25 Aug 2006 17:27:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: zone_reclaim: dynamic zone based slab reclaim
In-Reply-To: <20060825164233.8276e425.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0608251727010.11715@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608251500560.11154@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0608251521190.11205@schroedinger.engr.sgi.com>
 <20060825164233.8276e425.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 25 Aug 2006, Andrew Morton wrote:

> On Fri, 25 Aug 2006 15:22:14 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> >
> > This patch implements slab reclaim during zone reclaim.
> 
> hrm, OK.  Yes, the globalness of the slab is a bit sad.
> 
> >  	unsigned long		min_unmapped_ratio;
> > +	unsigned long		min_slab_ratio;
> 
> These are not ratios.   Can we please rename them?  min_unmapped_page_count?

Yes I was wondering about that when you introduced it.

How about simply removing the _ratio at the end?

min_unmapped
min_slab

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
