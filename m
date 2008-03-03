Date: Mon, 3 Mar 2008 10:40:04 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 4/6] xip: support non-struct page backed memory
In-Reply-To: <47CBB44D.7040203@de.ibm.com>
Message-ID: <alpine.LFD.1.00.0803031037560.17889@woody.linux-foundation.org>
References: <20080118045649.334391000@suse.de> <20080118045755.735923000@suse.de> <6934efce0803010014p2cc9a5edu5fee2029c0104a07@mail.gmail.com> <47CBB44D.7040203@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: Jared Hulbert <jaredeh@gmail.com>, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, mschwid2@linux.vnet.ibm.com, heicars2@linux.vnet.ibm.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 3 Mar 2008, Carsten Otte wrote:
>
> Jared Hulbert wrote:
> > The problem is that virt_to_phys() gives bogus answer for a
> > mtd->point()'ed address.  It's a ioremap()'ed address which doesn't
> > work with the ARM virt_to_phys().  I can get a physical address from
> > mtd->point() with a patch I dropped a little while back.
>
> Is there a chance virt_to_phys() can be fixed on arm?

NO!

"virt_to_phys()" is about kernel 1:1-mapped virtual addresses, and 
"fixing" it would be totally wrong. We don't do crap like following page 
tables, and we shouldn't encourage anybody to even think that we do.

If somebody needs to follow page table pointers, they had better do it 
themselves and open-code the fact that they are doing something stupid and 
expensive, not make it easy for everybody else to do that mistake without 
even realising.

A lot of the kernel architecture is all about making it really hard to do 
stupid things by mistake.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
