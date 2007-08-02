Date: Thu, 2 Aug 2007 12:30:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 4/4] vmemmap ppc64: convert VMM_* macros to a real function
In-Reply-To: <1186072295.18414.257.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708021229230.7948@schroedinger.engr.sgi.com>
References: <exportbomb.1186045945@pinky>  <E1IGWwO-0002Yc-8h@hellhawk.shadowen.org>
 <1186072295.18414.257.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, 2 Aug 2007, Dave Hansen wrote:

> On Thu, 2007-08-02 at 10:25 +0100, Andy Whitcroft wrote:
> > 
> > +unsigned long __meminit vmemmap_section_start(struct page *page)
> > +{
> > +       unsigned long offset = ((unsigned long)page) -
> > +                                               ((unsigned long)(vmemmap)); 
> 
> Isn't this basically page_to_pfn()?  Can we use it here?

Nope. He cast page to long.

Its equivalent to 

	page_to_pfn(page) * sizeof(struct page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
