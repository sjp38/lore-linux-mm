Date: Wed, 30 May 2001 17:35:20 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Plain 2.4.5 VM
In-Reply-To: <Pine.LNX.4.10.10105301539030.31487-100000@coffee.psychology.mcmaster.ca>
Message-ID: <Pine.LNX.4.21.0105301734030.13062-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 30 May 2001, Mark Hahn wrote:

> 	if (ptep_test_and_clear_young(pte))
> 		age up;
> 	else		
> 		get rid of it;
> 
> shouldn't we try to gain more information by scanning page tables
> at a good rate?  we don't have to blindly get rid of every page
> that isn't young (referenced since last scan) - we could base that
> on age.  admittedly, more scanning would eat some additional CPU,
> but then again, we currently shuffle pages among lists based on relatively
> sparse PAGE_ACCESSED info.
> 
> or am I missing something?  

The "getting rid of it" above consists of 2 parts:

1) moving the page to the active list, where
   refill_inactive_scan will age it
2) the page->age will be higher if the page
   has been accessed more often

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
