Date: Mon, 29 Jan 2007 16:09:21 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 0/8] Create ZONE_MOVABLE to partition memory between
 movable and non-movable pages
Message-Id: <20070129160921.7b362c8d.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0701291533500.1169@schroedinger.engr.sgi.com>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
	<20070126030753.03529e7a.akpm@osdl.org>
	<Pine.LNX.4.64.0701260751230.6141@schroedinger.engr.sgi.com>
	<20070126114615.5aa9e213.akpm@osdl.org>
	<Pine.LNX.4.64.0701261147300.15394@schroedinger.engr.sgi.com>
	<20070126122747.dde74c97.akpm@osdl.org>
	<Pine.LNX.4.64.0701291349450.548@schroedinger.engr.sgi.com>
	<20070129143654.27fcd4a4.akpm@osdl.org>
	<Pine.LNX.4.64.0701291441260.1102@schroedinger.engr.sgi.com>
	<20070129225000.GG6602@flint.arm.linux.org.uk>
	<Pine.LNX.4.64.0701291533500.1169@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Russell King <rmk+lkml@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2007 15:37:29 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> With a alloc_pages_range() one would be able to specify upper and lower 
> boundaries.

Is there a proposal anywhere regarding how this would be implemented?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
