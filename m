Date: Tue, 20 Mar 2001 01:15:20 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: 3rd version of R/W mmap_sem patch available
In-Reply-To: <Pine.LNX.4.31.0103191839510.1003-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0103200113550.8828-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Mike Galbraith <mikeg@wen-online.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Manfred Spraul <manfred@colorfullife.com>, MOLNAR Ingo <mingo@chiara.elte.hu>
List-ID: <linux-mm.kvack.org>


On Mon, 19 Mar 2001, Linus Torvalds wrote:

> 
> There is a 2.4.3-pre5 in the test-directory on ftp.kernel.org.
> 
> The complete changelog is appended, but the biggest recent change is the
> mmap_sem change, which I updated with new locking rules for pte/pmd_alloc
> to avoid the race on the actual page table build.
> 
> This has only been tested on i386 without PAE, and is known to break other
> architectures. Ingo, mind checking what PAE needs? Generally, the changes
> are simple, and really only implies changing the pte/pmd allocation
> functions to _only_ allocate (ie removing the stuff that actually modifies
> the page tables, as that is now handled by generic code), and to make sure
> that the "pgd/pmd_populate()" functions do the right thing.
> 
> I have also removed the xxx_kernel() functions - for architectures that
> need them, I suspect that the right approach is to just make the
> "populate" funtions notice when "mm" is "init_mm", the kernel context.
> That removed a lot of duplicate code that had little good reason.
> 
> This pre-release is meant mainly as a synchronization point for mm
> developers, not for generic use.
> 
> 	Thanks,
> 
> 		Linus
> 
> 
> -----
> -pre5:
>   - Rik van Riel and others: mm rw-semaphore (ps/top ok when swapping)
>   - IDE: 256 sectors at a time is legal, but apparently confuses some
>     drives. Max out at 255 sectors instead.

Could the IDE one cause corruption ?

EXT2-fs error (device ide0(3,1)): ext2_free_blocks: bit already cleared
for block 6211

Just hitted this now with pre3. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
