Date: Sun, 29 Jul 2001 11:48:16 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
In-Reply-To: <01072916102900.00341@starship>
Message-ID: <Pine.LNX.4.33L.0107291147500.11893-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, Andrew Morton <akpm@zip.com.au>, Mike Galbraith <mikeg@wen-online.de>, Steven Cole <elenstev@mesatop.com>, Roger Larsson <roger.larsson@skelleftea.mail.telia.com>
List-ID: <linux-mm.kvack.org>

On Sun, 29 Jul 2001, Daniel Phillips wrote:
> On Saturday 28 July 2001 22:26, Linus Torvalds wrote:

> > We only mark the page referenced when we read it, we don't actually
> > increment the age.
>
> For already-cached pages we have:
>
>    do_generic_file_read->__find_page_nolock->age_page_up

s/have/had/

This was changed quite a while ago.

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
