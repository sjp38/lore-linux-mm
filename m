Date: Wed, 18 Jul 2001 14:16:29 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Basic MM question
In-Reply-To: <17230000.995473146@baldur>
Message-ID: <Pine.LNX.4.33L.0107181415230.9022-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmc@austin.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Jul 2001, Dave McCracken wrote:

> My apologies if this is a newbie question.  I'm still trying to figure out
> the fine points of how MM works.
>
> Why does read_swap_cache_async use GFP_USER as opposed to GFP_HIGHUSER for
> swapped in pages?

You may not have figured out how the VM works, but you
sure figured out why it isn't currently working as
expected ;)

This is a bug, thanks for tracking it down.

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
