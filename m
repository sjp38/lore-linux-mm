Date: Thu, 4 May 2000 11:34:56 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [PATCH][RFC] Alternate shrink_mmap
In-Reply-To: <39116F1B.7882BF6A@norran.net>
Message-ID: <Pine.LNX.4.21.0005041132410.23740-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.21.0005041132412.23740@duckman.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 May 2000, Roger Larsson wrote:

> Here is an alternative shrink_mmap.
> It tries to touch the list as little as possible
> (only young pages are moved)

I will use something like this in the active/inactive queue
thing. The major differences will be that:
- we won't be reclaiming memory in the first queue
  (only from the inactive queue)
- we'll try to keep a minimum number of active and
  inactive pages in every zone
- we will probably have a (per pg_dat) self-tuning
  target for the number of inactive pages

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
