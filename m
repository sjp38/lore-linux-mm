Date: Wed, 27 Sep 2000 10:28:19 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
In-Reply-To: <qwwn1gu6yps.fsf@sap.com>
Message-ID: <Pine.LNX.4.21.0009271025260.2237-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: Andrea Arcangeli <andrea@suse.de>, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 27 Sep 2000, Christoph Rohland wrote:

> Nobody should rely on shm swapping for productive use. But you have
> changing/increasing loads on application servers and out of a sudden
> you run oom. In this case the system should behave and it is _very_
> good to have a smooth behaviour.

it might make sense even in production use. If there is some calculation
that has to be done only once per month, then sure the customer can decide
to wait for it a few hours until it swaps itself ready, instead of buying
gigs of RAM just to execute this single operation faster. Uncooperative
OOM in such cases is a show-stopper. Or are you saying the same thing? :-)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
