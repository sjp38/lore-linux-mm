Date: Thu, 28 Sep 2000 13:31:40 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
In-Reply-To: <Pine.LNX.4.21.0009280702460.1814-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0009281329270.5655-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Rohland <cr@sap.com>, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Sep 2000, Rik van Riel wrote:

> The OS has no business knowing what's inside that SHM page.

exactly.

> IF the shm contains I/O cache, maybe you're right. However,
> until you know that this is the case, optimising for that
> situation just doesn't make any sense.

if the shm contains raw I/O data, then thats flawed application design -
an mmap()-ed file should be used instead. Shm is equivalent to shared
anonymous pages.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
