Message-ID: <3B1070A3.D43B4A63@earthlink.net>
Date: Sat, 26 May 2001 21:12:35 -0600
From: "Joseph A. Knapka" <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: order of matching alloc_pages/free_pages call pairs.  Are they
 always same?
References: <OF5385EE96.412D8BDB-ON85256A58.005E44E7@pok.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bulent Abali <abali@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Bulent Abali wrote:
> 
> Is it reasonable to assume that matching
> alloc_pages/free_pages pairs will always have the same order
> as the 2nd argument?
> 
> For example
> pg = alloc_pages( , aorder);   free_pages(pg, forder);
> Is (aorder == forder) always true?
> 
> Or, are there any bizarro drivers etc which will intentionally
> free partial amounts, that is (forder < aorder)?

This would be a somewhat bizarre thing to do, but after thinking
about it a bit, I believe it would work fine - as long as you're
very careful to free blocks with appropriate order and alignment.

I'm not personally aware of any code that actually frees sub-blocks
of allocated blocks, but I expect that when I get around to looking
at the slab allocator (kmalloc(), kfree()) there will be code
in there that does so.

-- Joe


-- Joseph A. Knapka
"If I ever get reincarnated... let me make certain I don't come back
 as a paperclip." -- protagonist, H Murakami's "Hard-boiled Wonderland"
// Linux MM Documentation in progress:
// http://home.earthlink.net/~jknapka/linux-mm/vmoutline.html
* Evolution is an "unproven theory" in the same sense that gravity is. *
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
