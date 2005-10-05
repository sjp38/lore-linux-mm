Date: Wed, 5 Oct 2005 18:20:00 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/7] Fragmentation Avoidance V16: 005_fallback
In-Reply-To: <1128531235.26009.35.camel@localhost>
Message-ID: <Pine.LNX.4.58.0510051817560.16421@skynet>
References: <20051005144546.11796.1154.sendpatchset@skynet.csn.ul.ie>
 <20051005144612.11796.35309.sendpatchset@skynet.csn.ul.ie>
 <1128531235.26009.35.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, jschopp@austin.ibm.com, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Wed, 5 Oct 2005, Dave Hansen wrote:

> On Wed, 2005-10-05 at 15:46 +0100, Mel Gorman wrote:
> > +static struct page *
> > +fallback_alloc(int alloctype, struct zone *zone, unsigned int order)
> > {
> ...
> > +       /*
> > +        * Here, the alloc type lists has been depleted as well as the global
> > +        * pool, so fallback. When falling back, the largest possible block
> > +        * will be taken to keep the fallbacks clustered if possible
> > +        */
> > +       while ((alloctype = *(++fallback_list)) != -1) {
>
> That's a bit obtuse.  Is there no way to simplify it?  Just keeping an
> index instead of a fallback_list pointer should make it quite a bit
> easier to grok.
>

Changed to

for (i = 0; (alloctype = fallback_list[i]) != -1; i++) {

where i is declared a the start of the function. It's essentially the same
as how we move through the zones fallback list so should seem familiar. Is
that better?

-- 
Mel Gorman
Part-time Phd Student                          Java Applications Developer
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
