Date: Mon, 19 Mar 2001 22:07:55 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 3rd version of R/W mmap_sem patch available
In-Reply-To: <Pine.LNX.4.21.0103200113550.8828-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.31.0103192206030.1025-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Rik van Riel <riel@conectiva.com.br>, Mike Galbraith <mikeg@wen-online.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Manfred Spraul <manfred@colorfullife.com>, MOLNAR Ingo <mingo@chiara.elte.hu>
List-ID: <linux-mm.kvack.org>


On Tue, 20 Mar 2001, Marcelo Tosatti wrote:
>
> Could the IDE one cause corruption ?

Only with broken disks, as far as we know right now. There's been so far
just one report of this problem, and nobody has heard back about which
disk this was.. And it should be noisy about it when it happens -
complaining about lost interrupts and resetting the IDE controller.

So unlikely.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
