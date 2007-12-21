Message-ID: <476B95EE.2010802@de.ibm.com>
Date: Fri, 21 Dec 2007 11:31:10 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [rfc][patch 2/2] xip: support non-struct page memory
References: <20071214133817.GB28555@wotan.suse.de> <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com> <476A7D21.7070607@de.ibm.com> <476A8133.5050809@de.ibm.com> <20071221005049.GC31040@wotan.suse.de> <476B8F2B.7010409@de.ibm.com> <20071221101419.GA28484@wotan.suse.de> <476B92AA.4020805@de.ibm.com> <20071221102329.GC28484@wotan.suse.de>
In-Reply-To: <20071221102329.GC28484@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: carsteno@de.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> OK, that's good news for my lockless get_user_pages ;)
> 
> And also potentially good news for the whole vm_normal_page scheme...
> though I'd prefer to start simple (ie. don't use the pte bit, rather
> walk the list), and see if it works first.
> 
> But whatever you think I guess, either way it would go in arch specific
> code where your opinion outweighs mine ;)

You clearly overestimate my influence on Martin. I rather keep my 
fingers off the memory management backend there.
But either way, what we'd need is an arch callback that can map to 
pfn_valid() for ARM and maybe others, and that we could map different. 
I'll try to come up with a patch that implements such callback using 
list-walk for s390. Hopefully we can safely grab the list lock 
everywhere we need to check.
Btw: I will also continue to work on this next year, and take two 
weeks christmas vacation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
