Date: Sat, 11 Feb 2006 16:59:55 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Skip reclaim_mapped determination if we do not swap
In-Reply-To: <20060211152905.6093258d.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0602111658370.25379@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0602111335560.24685@schroedinger.engr.sgi.com>
 <20060211135031.623fdef9.akpm@osdl.org> <Pine.LNX.4.62.0602111405340.24923@schroedinger.engr.sgi.com>
 <20060211152905.6093258d.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, nickpiggin@yahoo.com.au, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Sat, 11 Feb 2006, Andrew Morton wrote:

> Christoph Lameter <clameter@engr.sgi.com> wrote:
> >
> > But should 
> >  this piece of code really be there? Doesnt it belong ito shrink_zone() or 
> >  even in try_to_free_pages() or balance_pgdat(). Shouldn't we pass 
> >  reclaim_mapped as a parameter to refill_inactive_zone?
> 
> Well, it's only used in refill_inactive_zone().  Does it matter much where
> it is?

If it is repeatedly evaluated when reclaiming then it matters. It also 
makes refill_inactive_zone() simpler if the statistical considerations are 
in one place in shrink_zone().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
