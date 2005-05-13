Date: Fri, 13 May 2005 13:24:46 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFC] consistency of zone->zone_start_pfn, spanned_pages
Message-ID: <20050513182446.GA23416@lnx-holt.americas.sgi.com>
References: <1116000019.32433.10.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1116000019.32433.10.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, May 13, 2005 at 09:00:19AM -0700, Dave Hansen wrote:
> Any other ideas?

Not necessarily a good idea but how about...

static int bad_range(struct zone *zone, struct page *page)
{
	unsigned long start_pfn;
	unsigned long spanned_pages;

	do {
		start_pfn = zone->zone_start_pfn;
		spanned_pages = zone->spanned_pages;
	while (unlikely(start_pfn != zone->zone_start_pfn));

	if (page_to_pfn(page) >= start_pfn + spanned_pages;
		return 1;
}
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
