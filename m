Received: by gv-out-0910.google.com with SMTP id n8so72337gve.19
        for <linux-mm@kvack.org>; Mon, 03 Mar 2008 07:59:17 -0800 (PST)
Message-ID: <6934efce0803030759q3c9c84c5mfb45267d182c3e90@mail.gmail.com>
Date: Mon, 3 Mar 2008 07:59:15 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: [patch 4/6] xip: support non-struct page backed memory
In-Reply-To: <20080303052959.GB32555@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080118045649.334391000@suse.de>
	 <20080118045755.735923000@suse.de>
	 <6934efce0803010014p2cc9a5edu5fee2029c0104a07@mail.gmail.com>
	 <20080303052959.GB32555@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>  OK right... one problem is that we need an address for the kernel to
>  manipulate the memory with, but we also need a pfn to insert into user
>  page tables. So I like your last suggestion, but I think we always
>  need both address and pfn.

Right I forgot about the xip_file_read() path.

I like to use UML kernels with the file-to-iomem interface for
testing.  I forget how UML kernels deal with physical address like
this.  I remember there are some caveats.  I'll look into it.  But I
think I can do for UML:

*kaddr = (void *)(start_virt_addr + offset);
*pfn = virt_to_phys(*kaddr) >> PAGE_SHIFT;

And the ARM + MTD I can do:

*kaddr = (void *)(start_virt_addr + offset);
*pfn = (start_phys_addr + offset) >> PAGE_SHIFT;

>  This should work for you too?

I think so.  But like Carsten I'd prefer a virtual only solution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
