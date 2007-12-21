Date: Fri, 21 Dec 2007 11:23:29 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 2/2] xip: support non-struct page memory
Message-ID: <20071221102329.GC28484@wotan.suse.de>
References: <20071214133817.GB28555@wotan.suse.de> <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com> <476A7D21.7070607@de.ibm.com> <476A8133.5050809@de.ibm.com> <20071221005049.GC31040@wotan.suse.de> <476B8F2B.7010409@de.ibm.com> <20071221101419.GA28484@wotan.suse.de> <476B92AA.4020805@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <476B92AA.4020805@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 21, 2007 at 11:17:14AM +0100, Carsten Otte wrote:
> Nick Piggin wrote:
> >I thought s390 was short on OS-available pte bits. There are a couple of 
> >other
> >nice things to use them for, so I'd rather not for this if possible (it is
> >not so critical if you can use a list, I would have thought)
> OS-available bits are only short for invalid ptes. For valid ptes 
> however, there are quite a few spare.

OK, that's good news for my lockless get_user_pages ;)

And also potentially good news for the whole vm_normal_page scheme...
though I'd prefer to start simple (ie. don't use the pte bit, rather
walk the list), and see if it works first.

But whatever you think I guess, either way it would go in arch specific
code where your opinion outweighs mine ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
