Date: Mon, 29 Jul 2002 11:22:59 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Regarding Page Cache ,Buffer Cachein  disabling in Linux Kernel.
In-Reply-To: <Pine.OSF.4.10.10207291827040.26879-100000@moon.cdotd.ernet.in>
Message-ID: <Pine.LNX.4.44L.0207291122310.3086-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anil Kumar <anilk@cdotd.ernet.in>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jul 2002, Anil Kumar wrote:

>   I am new to this mailing list.I am going through the linux kernel
>  source code. I want to disable the Page Caching,Buffer Caching  in
>  the Kernel.How can i do it  ?

You cannot disable it, without the page cache read(2) and write(2)
don't have a target to read or write data to/from...

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
