Date: Sun, 14 Jan 2001 10:57:30 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [patch] mm-deactivate-fix-1
In-Reply-To: <87ofxaz1y0.fsf@atlas.iskon.hr>
Message-ID: <Pine.LNX.4.21.0101141055160.12274-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko@iskon.hr>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 14 Jan 2001, Zlatko Calusic wrote:

> I have noticed that in deactivate_page_nolock() function pages get
> unconditionally moved from the active to the inact_dirty list. Even if
> it is really easy with additional check to put them straight to the
> inact_clean list if they're freeable. That keeps the list statistics
> more accurate and in the end should result in a little bit less CPU
> cycles burned (only one list transition, less locking). As a bonus,
> the comment above the function is now correct. :)
> 
> I have tested the patch thoroughly and couldn't find any problems with
> it. It should be really safe as reclaim_page() already carefully
> checks pages before freeing.
> 
> Comments?

We want to move all deactivated pages to the inactive dirty list to get
FIFO behaviour while reclaiming them.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
