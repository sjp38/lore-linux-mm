Subject: Re: [patch] mm-deactivate-fix-1
References: <Pine.LNX.4.21.0101141055160.12274-100000@freak.distro.conectiva>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 14 Jan 2001 16:48:55 +0100
In-Reply-To: Marcelo Tosatti's message of "Sun, 14 Jan 2001 10:57:30 -0200 (BRST)"
Message-ID: <87ae8uw2vs.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo@conectiva.com.br> writes:

> On 14 Jan 2001, Zlatko Calusic wrote:
> 
> > I have noticed that in deactivate_page_nolock() function pages get
> > unconditionally moved from the active to the inact_dirty list. Even if
> > it is really easy with additional check to put them straight to the
> > inact_clean list if they're freeable. That keeps the list statistics
> > more accurate and in the end should result in a little bit less CPU
> > cycles burned (only one list transition, less locking). As a bonus,
> > the comment above the function is now correct. :)
> > 
> > I have tested the patch thoroughly and couldn't find any problems with
> > it. It should be really safe as reclaim_page() already carefully
> > checks pages before freeing.
> > 
> > Comments?
> 
> We want to move all deactivated pages to the inactive dirty list to get
> FIFO behaviour while reclaiming them.
> 

Ah, I see. Then your answer should be put above the function as a
comment. To help other souls digging around that code (like I'm
doing). :)
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
