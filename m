Date: Tue, 17 May 2005 05:46:14 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFC] consistency of zone->zone_start_pfn, spanned_pages
Message-ID: <20050517104614.GB12790@lnx-holt.americas.sgi.com>
References: <1116000019.32433.10.camel@localhost> <20050513182446.GA23416@lnx-holt.americas.sgi.com> <4289BE64.8070605@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4289BE64.8070605@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Robin Holt <holt@sgi.com>, Dave Hansen <haveblue@us.ibm.com>, lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 17, 2005 at 10:50:28AM +0100, Andy Whitcroft wrote:
> Robin Holt wrote:
> 
> > 	do {
> > 		start_pfn = zone->zone_start_pfn;
> > 		spanned_pages = zone->spanned_pages;
> > 	while (unlikely(start_pfn != zone->zone_start_pfn));
> 
> Whilst like a seq_lock, without the memory barriers this isn't safe right?

Definitely.  You would need barriers.

Robin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
