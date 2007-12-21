Date: Fri, 21 Dec 2007 01:50:49 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 2/2] xip: support non-struct page memory
Message-ID: <20071221005049.GC31040@wotan.suse.de>
References: <20071214133817.GB28555@wotan.suse.de> <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com> <476A7D21.7070607@de.ibm.com> <476A8133.5050809@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <476A8133.5050809@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 20, 2007 at 03:50:27PM +0100, Carsten Otte wrote:
> Carsten Otte wrote:
> >So bottom line I think we do need a different trigger then pfn_valid() 
> >to select which pages within VM_MIXEDMAP get refcounted and which don't.
> A poor man's solution could be, to store a pfn range of the flash chip 
> and/or shared memory segment inside vm_area_struct, and in case of 
> VM_MIXEDMAP we check if the pfn matches that range. If so: no 
> refcounting. If not: regular refcounting. Is that an option?

Yeah, although I'd not particularly like to touch generic code for such a
thing (except of course we could add an extra test to VM_MIXEDMAP, which
would be a noop for all other architectures).

You wouldn't even need to store it in the vm_area_struct -- you could just
set up eg. an rb tree of flash extents, and have a function that looks up
that tree for you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
