Date: Fri, 14 Jan 2000 01:28:49 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC] 2.3.39 zone balancing
In-Reply-To: <Pine.LNX.4.10.10001131428250.2250-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0001140124110.3816-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@nl.linux.org>, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jan 2000, Linus Torvalds wrote:

>to keep some memory free. Also, while we don't use high-memory pages right
>now in BH and irq contexts, I don't think that is something we need to
>codify, and it may change in the future. There's no real reason per se for

Yes, it will change on 64bit platforms.

>not using them (except for complexity), so I'd hate to have a special case
>for that case.

With the current code the special case is necessary but a rewrite should
be able to get rid of it cleanly. Anyway actually adding the number of
freeable pages to the free pages when checking the watermark is completly
buggy (this has nothing to do with the special case).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
