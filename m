Date: Mon, 9 Oct 2000 17:05:11 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <39E21CCB.61AC1EBE@kalifornia.com>
Message-ID: <Pine.LNX.4.21.0010091704040.1562-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: david+validemail@kalifornia.com
Cc: mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, David Ford wrote:

> Then spam the console loudly with printk, but don't destroy the
> whole machine. Init should only get killed if it REALLY is
> taking a lot of memory.  On a 4 or 8meg machine tho, the
> probability of init getting killed is simply too high for
> comfort.  I have never ever seen init start consuming memory
> like this so I'd rather get spammed on the console a LOT then
> have my entire machine instantly go dead.

Please TEST THIS before spreading Wild Rumours(tm)

On 2.2 a /random/ process gets killed when the system gets
tight, so you'll see init killed on (pre-kludge) 2.2 kernels,
but I don't believe you'll see this with 2.4...

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
