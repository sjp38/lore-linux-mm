Message-ID: <47CBB725.7040108@de.ibm.com>
Date: Mon, 03 Mar 2008 09:30:29 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [patch 4/6] xip: support non-struct page backed memory
References: <20080118045649.334391000@suse.de> <20080118045755.735923000@suse.de> <6934efce0803010014p2cc9a5edu5fee2029c0104a07@mail.gmail.com> <20080303052959.GB32555@wotan.suse.de>
In-Reply-To: <20080303052959.GB32555@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Jared Hulbert <jaredeh@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, mschwid2@linux.vnet.ibm.com, heicars2@linux.vnet.ibm.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> What about 
> int get_xip_mem(mapping, pgoff, create, void **kaddr, unsigned long *pfn)
> 
> get_xip_mem(mapping, pgoff, create, &addr, &pfn);
> if (pagefault)
>     vm_insert_mixed(vma, vaddr, pfn);
> else if (read/write) {
>     memcpy(kaddr, blah, sizeof);
> 
> My simple brd driver can easily do
>  *kaddr = page_address(page);
>  *pfn = page_to_pfn(page);
> 
> This should work for you too?
Looks good to me. Otoh, if there is an easy way to fix virt_to_phys() 
I would like that better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
