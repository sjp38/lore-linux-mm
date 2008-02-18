From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 2/8] mm: introduce VM_MIXEDMAP
Date: Mon, 18 Feb 2008 13:59:04 +1100
References: <20080214061657.700804000@suse.de> <20080214062531.335727000@suse.de>
In-Reply-To: <20080214062531.335727000@suse.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200802181359.05429.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: Badari Pulavarty <pbadari@gmail.com>, Dave Kleikamp <shaggy@linux.vnet.ibm.com>, anton@au1.ibm.com, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Carsten Otte <cotte@de.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Jared Hulbert <jaredeh@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 14 February 2008 17:16, npiggin@suse.de wrote:
> Introduce a new type of mapping, VM_MIXEDMAP. This is unlike VM_PFNMAP in
> that it can support COW mappings of arbitrary ranges including ranges
> without struct page (PFNMAP can only support COW in those cases where the
> un-COW-ed translations are mapped linearly in the virtual address).
>
> VM_MIXEDMAP achieves this by refcounting all pfn_valid pages, and not
> refcounting !pfn_valid pages (which is not an option for VM_PFNMAP, because
> it needs to avoid refcounting pfn_valid pages eg. for /dev/mem mappings).

BTW. sorry quilt mail outsmarted me here... I had just intended to send
these privately to Badari, Dave, and the other powerpc guys. I wasn't
intending this for you Linus, or linux-mm etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
