Date: Thu, 15 Jun 2000 13:12:41 -0600
From: Neil Schemenauer <nascheme@enme.ucalgary.ca>
Subject: Re: shrink_mmap bug in 2.2?
Message-ID: <20000615131241.D9717@acs.ucalgary.ca>
References: <20000614185034.A2505@acs.ucalgary.ca> <200006150116.SAA41023@google.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200006150116.SAA41023@google.engr.sgi.com>; from kanoj@google.engr.sgi.com on Wed, Jun 14, 2000 at 06:16:10PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 14, 2000 at 06:16:10PM -0700, Kanoj Sarcar wrote:
> Aren't you misreading the logic here? It is
> 
> 	referenced && swap_count(page->offset) != 1)
> 	          ^^^^
[...]
> So delete_from_swap_cache will only ever be called on a page
> with swap_count(page->offset) == 1.

If the page is not referenced it will be removed regardless of
the swap_count.  My question is "does swap_count have to equal
one before calling delete_from_swap_cache"?  If it does then I
think the code is wrong.

I wouldn't consider this code old as it is in the current stable
kernel (2.2.16).  

  Neil

-- 
145 = 1! + 4! + 5!
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
