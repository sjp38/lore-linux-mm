Message-ID: <3B12A515.B8B207EA@colorfullife.com>
Date: Mon, 28 May 2001 21:20:53 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH] modified memory_pressure calculation
References: <Pine.LNX.4.21.0105281425450.1204-100000@freak.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:
> 
> I disagree with the second hunk.
> 
> memory_pressure is used to calculate the size of _both_ the inactive dirty
> and clean lists.
> 
> Since you're adding the page back to the inactive dirty list, you should
> not increase memory_pressure.
>

Correct. And page_launder should increase memory_pressure fore each page
it moves back into the active list.

But I don't like the overloading of memory_pressure. Initially I thought
that one ++ is missing.

I think an additional statistic variable would be better.
[reactivation_rate, or whatever].

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
