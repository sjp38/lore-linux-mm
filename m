From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/2] powerpc: add hugepagesz boot-time parameter
Date: Wed, 28 Nov 2007 17:30:40 +0100
References: <474CF68E.1040709@us.ibm.com> <200711280826.46820.arnd@arndb.de> <20071128161201.GA10916@csn.ul.ie>
In-Reply-To: <20071128161201.GA10916@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200711281730.40907.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linuxppc-dev@ozlabs.org, kniht@linux.vnet.ibm.com, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 28 November 2007, Mel Gorman wrote:
> On (28/11/07 08:26), Arnd Bergmann didst pronounce:
> > On Wednesday 28 November 2007, Jon Tollefson wrote:
> > > This patch adds the hugepagesz boot-time parameter for ppc64 that lets 
> > > you pick the size for your huge pages.  The choices available are 64K 
> > > and 16M.  It defaults to 16M (previously the only choice) if nothing or 
> > > an invalid choice is specified.  Tested 64K huge pages with the 
> > > libhugetlbfs 1.2 release with its 'make func' and 'make stress' test 
> > > invocations.
> > 
> > How hard would it be to add the 1MB page size that some CPUs support
> > as well? On systems with small physical memory like the PS3, that
> > sounds very useful to me.
> > 
> 
> Does the PS3 support 1M pages in hardware? When I last looked, the magic
> ibm,segment-page-sizes file that described the supported pagesizes was
> missing from the device tree. In this situation, the default sizes
> become 4K and 16M because no other ones are advertised.

I think you can select the page size using a hypercall on the PS3.
The CPU supports any two of (64k, 1M, 16M) simultaneously.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
