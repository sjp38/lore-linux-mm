Message-ID: <4289BE64.8070605@shadowen.org>
Date: Tue, 17 May 2005 10:50:28 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [RFC] consistency of zone->zone_start_pfn, spanned_pages
References: <1116000019.32433.10.camel@localhost> <20050513182446.GA23416@lnx-holt.americas.sgi.com>
In-Reply-To: <20050513182446.GA23416@lnx-holt.americas.sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Robin Holt wrote:

> 	do {
> 		start_pfn = zone->zone_start_pfn;
> 		spanned_pages = zone->spanned_pages;
> 	while (unlikely(start_pfn != zone->zone_start_pfn));

Whilst like a seq_lock, without the memory barriers this isn't safe right?

-apw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
