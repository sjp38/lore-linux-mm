Message-ID: <3F02A171.7070200@aitel.hist.no>
Date: Wed, 02 Jul 2003 11:10:09 +0200
From: Helge Hafting <helgehaf@aitel.hist.no>
MIME-Version: 1.0
Subject: Re: 2.5.73-mm3 `highmem_start_page' undeclared  with DEBUG_PAGEALLOC
 and no highmem
References: <20030701203830.19ba9328.akpm@digeo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This didn't compile.

.
.
.
   CC      arch/i386/mm/fault.o
   CC      arch/i386/mm/ioremap.o
   CC      arch/i386/mm/extable.o
   CC      arch/i386/mm/pageattr.o
arch/i386/mm/pageattr.c: In function `kernel_map_pages':
arch/i386/mm/pageattr.c:200: `highmem_start_page' undeclared (first use 
in this function)
arch/i386/mm/pageattr.c:200: (Each undeclared identifier is reported 
only once
arch/i386/mm/pageattr.c:200: for each function it appears in.)
make[1]: *** [arch/i386/mm/pageattr.o] Error 1
make: *** [arch/i386/mm] Error 2


Configuring highmem support to 4G instead of turning
it off avoids this, but I have only 512M in
this machine.

Turning off highmem and page allocation debugging
also compiles.

Helge Hafting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
