From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14541.4418.281304.671792@dukat.scot.redhat.com>
Date: Mon, 13 Mar 2000 16:03:14 +0000 (GMT)
Subject: Re: a plea for mincore()/madvise()
In-Reply-To: <Pine.BSO.4.10.10003101932390.16717-100000@funky.monkey.org>
References: <Pine.LNX.4.10.10003101612470.906-100000@penguin.transmeta.com>
	<Pine.BSO.4.10.10003101932390.16717-100000@funky.monkey.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: Linus Torvalds <torvalds@transmeta.com>, James Manning <jmm@computer.org>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 10 Mar 2000 19:39:03 -0500 (EST), Chuck Lever <cel@monkey.org>
said:

> i'll create a patch against 2.3.51-pre3 for madvise() and post it on the
> mm list before sunday.  then we can argue about something we've both seen
> :)

> let me think some more about DONTNEED.  at the face of it, i agree with
> your suggestion, but i may just exclude it from the patch until there is
> more discussion here.

For what it's worth, Linus's request --- that DONTNEED throws stuff
away without propagating dirty data --- is something that I've had big
database folk asking us for more than once.

--Stephen


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
