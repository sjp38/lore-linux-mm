Date: Thu, 26 Aug 1999 18:27:51 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <E11Ghah-0004RI-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.10.9908261811200.317-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linus Torvalds <torvalds@transmeta.com>, kanoj@google.engr.sgi.com, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, linux-usb@suse.com
List-ID: <linux-mm.kvack.org>

On Tue, 17 Aug 1999, Alan Cox wrote:

>of bus addressses of vmalloc pages. I don't think the 4Gig patch breaks it
>at all. In the ideal world virt_to_bus() would work on vmalloc pages. It

Yes, the bigmem patch doesn't break bttv.

bttv alloc the DMA-pool via vmalloc and with the bigmem patch applyed
vmalloc prefere the bigmem pages so the DMA-pool will be always alloced
in bigmem memory.

But using vmalloc all bigmem pages will have a valid virt-to-phys
translation. (Only GFP may return a pointer without a valid virt-to-phys
translation if __GFP_BIGMEM is been specifyed in the gfp_mask.)

So the kernel can also copy-from/to-user the DMA pool using the vmalloc
addresses since it's a _valid_ address.

Via mmap the vmalloced pages will be remapped to userspace memory and
that's fine as well.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
