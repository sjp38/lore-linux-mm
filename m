From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/2] powerpc: add hugepagesz boot-time parameter
Date: Wed, 28 Nov 2007 08:26:46 +0100
References: <474CF68E.1040709@us.ibm.com>
In-Reply-To: <474CF68E.1040709@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200711280826.46820.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc-dev@ozlabs.org, kniht@linux.vnet.ibm.com
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 28 November 2007, Jon Tollefson wrote:
> This patch adds the hugepagesz boot-time parameter for ppc64 that lets 
> you pick the size for your huge pages.  The choices available are 64K 
> and 16M.  It defaults to 16M (previously the only choice) if nothing or 
> an invalid choice is specified.  Tested 64K huge pages with the 
> libhugetlbfs 1.2 release with its 'make func' and 'make stress' test 
> invocations.

How hard would it be to add the 1MB page size that some CPUs support
as well? On systems with small physical memory like the PS3, that
sounds very useful to me.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
