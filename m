Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
References: <Pine.LNX.4.21.0009271025260.2237-100000@elte.hu>
From: Christoph Rohland <cr@sap.com>
Date: 27 Sep 2000 11:24:46 +0200
In-Reply-To: Ingo Molnar's message of "Wed, 27 Sep 2000 10:28:19 +0200 (CEST)"
Message-ID: <qwwem266vc1.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: Andrea Arcangeli <andrea@suse.de>, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar <mingo@elte.hu> writes:

> On 27 Sep 2000, Christoph Rohland wrote:
> 
> > Nobody should rely on shm swapping for productive use. But you have
> > changing/increasing loads on application servers and out of a sudden
> > you run oom. In this case the system should behave and it is _very_
> > good to have a smooth behaviour.
> 
> it might make sense even in production use. If there is some calculation
> that has to be done only once per month, then sure the customer can decide
> to wait for it a few hours until it swaps itself ready, instead of buying
> gigs of RAM just to execute this single operation faster. Uncooperative
> OOM in such cases is a show-stopper. Or are you saying the same thing? :-)

That's what I meant with the coffee break. In a big installation
somebody is always drinking coffee :-)
 
You also have often different loads during daytime and
nighttime. Swapping buffers out to swap disk instead of rereading from
the database makes a lot of sense for this. But a single job should
never swap. (It works for two month and then next month you get the
big escalation and you would love to have hotplug memory)

So swapping happens in productive use. But nobody should rely on
that too much. 

And I completely agree that uncooperative OOM is not acceptable.

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
