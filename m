Date: Fri, 21 Dec 2007 11:14:19 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 2/2] xip: support non-struct page memory
Message-ID: <20071221101419.GA28484@wotan.suse.de>
References: <20071214133817.GB28555@wotan.suse.de> <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com> <476A7D21.7070607@de.ibm.com> <476A8133.5050809@de.ibm.com> <20071221005049.GC31040@wotan.suse.de> <476B8F2B.7010409@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <476B8F2B.7010409@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 21, 2007 at 11:02:19AM +0100, Carsten Otte wrote:
> Nick Piggin wrote:
> >You wouldn't even need to store it in the vm_area_struct -- you could just
> >set up eg. an rb tree of flash extents, and have a function that looks up
> >that tree for you.
> We have a list aready, and I don't see the number of plugged extents 
> get so large that rb tree saves us CPU cycles over a list implementation.
> Martin Schwidefsky suggested to use a bit in the page table entry to 
> prevent refcounting. fault() could set it up proper for xip pages. 
> That would be way faster then walking a list. Would that be an option?

I thought s390 was short on OS-available pte bits. There are a couple of other
nice things to use them for, so I'd rather not for this if possible (it is
not so critical if you can use a list, I would have thought)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
