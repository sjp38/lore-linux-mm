Date: Mon, 3 Mar 2008 14:21:50 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 4/6] xip: support non-struct page backed memory
In-Reply-To: <20080303203202.GI8974@wotan.suse.de>
Message-ID: <alpine.LFD.1.00.0803031420430.2979@woody.linux-foundation.org>
References: <20080118045649.334391000@suse.de> <20080118045755.735923000@suse.de> <6934efce0803010014p2cc9a5edu5fee2029c0104a07@mail.gmail.com> <47CBB44D.7040203@de.ibm.com> <alpine.LFD.1.00.0803031037560.17889@woody.linux-foundation.org>
 <6934efce0803031138g725f0ec4ra683d56615b7dbe0@mail.gmail.com> <alpine.LFD.1.00.0803031152240.17889@woody.linux-foundation.org> <20080303203202.GI8974@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Jared Hulbert <jaredeh@gmail.com>, carsteno@de.ibm.com, Andrew Morton <akpm@linux-foundation.org>, mschwid2@linux.vnet.ibm.com, heicars2@linux.vnet.ibm.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 3 Mar 2008, Nick Piggin wrote:
> 
> Although they were already using kernel-virtual addresses before I got
> there, we want to remove the requirement to have a struct page, and
> there are no good accessors to kmap a pfn (AFAIK) otherwise we could
> indeed just use a pfn.

Implementing a kmap_pfn() sounds like a perfectly sane idea. But why does 
it need to even be mapped into kernel space? Is it for the ELF header 
reading or something (not having looked at the patch, just reacting to the 
wrongness of using virt_to_phys())?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
