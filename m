Date: Mon, 28 Aug 2000 14:40:43 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Question: memory management and QoS
In-Reply-To: <39AA56D1.EC5635D3@tuke.sk>
Message-ID: <Pine.LNX.4.21.0008281432010.18553-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Astalos <astalos@tuke.sk>
Cc: Andrey Savochkin <saw@saw.sw.com.sg>, Yuri Pudgorodsky <yur@asplinux.ru>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Aug 2000, Jan Astalos wrote:

> I wont repeat it again. With personal swapfiles _all_ users
> would be guarantied to get the amount of virtual memory provided
> by _themselves_.

This is STUPID.

Suppose that one user has a 10MB swapfile and a 32MB physical
memory quota (quite reasonable or even low nowadays).

Now suppose that user is away from the console (drinking coffee)
and has 20MB of IDLE processes sitting around.

In the mean time, another user is running something that could
really need a bit more physical memory, but it CANNOT get the
memory because the first (coffee drinking) user doesn't have
the swap space available...

This is a rediculously inefficient situation that should (and
can) be easily avoided by simply having per-user VM and RSS
_quotas_, but sharing one system-wide swap area.

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
