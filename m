Date: Mon, 18 Aug 2008 20:57:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [BUG] __GFP_THISNODE is not always honored
Message-ID: <20080818195743.GB22601@csn.ul.ie>
References: <1218837685.12953.11.camel@localhost.localdomain> <20080818105918.GD32113@csn.ul.ie> <1219083412.29323.36.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1219083412.29323.36.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, nacc <nacc@linux.vnet.ibm.com>, apw <apw@shadowen.org>, agl <agl@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On (18/08/08 13:16), Adam Litke didst pronounce:
> <MUCH SNIPPAGE>
> mminit::memmap_init Initialising map node 0 zone 0 pfns 32768 -> 278528
> mminit::memmap_init Initialising map node 1 zone 0 pfns 0 -> 524288

This might be the problem here. This machine has overlapping nodes which
is a fairly rare situation. I think it's possible the page linkages for
node 0 are getting overwritten with their node 1 equivalents. If this is
happening, it would lead to some oddness.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
