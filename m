Received: (from john@localhost)
	by boreas.southchinaseas (8.9.3/8.9.3) id SAA00941
	for <linux-mm@kvack.org>; Wed, 28 Jun 2000 18:45:47 +0100
From: vii@penguinpowered.com
Subject: Re: 2.4 / 2.5 VM plans
References: <Pine.LNX.4.21.0006242357020.15823-100000@duckman.distro.conectiva>
Date: 28 Jun 2000 18:45:46 +0100
In-Reply-To: Rik van Riel's message of "Sun, 25 Jun 2000 00:51:42 -0300 (BRST)"
Message-ID: <m2bt0l4s39.fsf@boreas.southchinaseas>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

[...]

> To start the discussion, here's my flameba^Wlist of ideas:

Seeing as not much discussion has resulted (if so it missed my
mailbox), I'll stick my neck out to agree.

[...]

> 3) separate page replacement (page aging) and page flushing,

Definitely!

>    currently we'll happily free a referenced clean page just
>    because the unreferenced pages haven't been flushed to disk
>    yet ...   this is very bad since the unreferenced pages often
>    turn out to be things like executable code
> 
>    we could achieve this by augmenting the current MM subsystem
>    with an inactive and scavenge list, in the process splitting

Yes! Please!

IMHO another really cool side-effect will be getting rid of the
vmscan.c:swap_out algorithm (at least as far as I understand).

>    shrink_mmap() into three better readable functions ... I have
>    this mostly done

[...]

BTW, Is there any timescale for integrating page coloring? Someone
produced a patch somewhere (IIRC specifically for the alpha, sorry to
be so vague).

-- 

	http://altern.org/vii
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
