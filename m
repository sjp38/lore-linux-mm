Date: Sat, 13 May 2000 14:14:47 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <Pine.LNX.4.21.0005130901070.7316-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10005131414020.2103-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

i've also seen a bit more frequent allocation failures on pre8, during
high (but non-trashing) VM load. Will try your patch now.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
