Date: Mon, 19 Mar 2001 14:46:48 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 3rd version of R/W mmap_sem patch available
In-Reply-To: <Pine.LNX.4.33.0103192254130.1320-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.31.0103191444420.1188-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Mike Galbraith <mikeg@wen-online.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


> Now the code is beautiful and it might even be bugfree ;)

I'm applying this to my tree - I'm not exactly comfortable with this
during the 2.4.x timeframe, but at the same time I'm even less comfortable
with the current alternative, which is to make the regular semaphores
fairer (we tried it once, and the implementation had problems, I'm not
going to try that again during 2.4.x).

Besides, the fair semaphores would potentially slow things down, while
this potentially speeds things up. So.. It looks obvious enough.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
