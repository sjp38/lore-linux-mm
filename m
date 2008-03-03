Message-ID: <47CBB44D.7040203@de.ibm.com>
Date: Mon, 03 Mar 2008 09:18:21 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [patch 4/6] xip: support non-struct page backed memory
References: <20080118045649.334391000@suse.de> <20080118045755.735923000@suse.de> <6934efce0803010014p2cc9a5edu5fee2029c0104a07@mail.gmail.com>
In-Reply-To: <6934efce0803010014p2cc9a5edu5fee2029c0104a07@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: npiggin@suse.de, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, mschwid2@linux.vnet.ibm.com, heicars2@linux.vnet.ibm.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jared Hulbert wrote:
> The problem is that virt_to_phys() gives bogus answer for a
> mtd->point()'ed address.  It's a ioremap()'ed address which doesn't
> work with the ARM virt_to_phys().  I can get a physical address from
> mtd->point() with a patch I dropped a little while back.
Is there a chance virt_to_phys() can be fixed on arm? It looks like a 
simple page table walk to me. If not, I would prefer to have 
get_xip_address return a physical address over having to split the 
code path here. S390 has a 1:1 mapping for xip mappings, thus it 
would'nt be a big change for us.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
