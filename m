Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
References: <20000925213242.A30832@athlon.random>
	<Pine.LNX.4.21.0009251622500.4997-100000@duckman.distro.conectiva>
	<20000926002812.C5010@athlon.random>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Andrea Arcangeli's message of "Tue, 26 Sep 2000 00:28:12 +0200"
Date: 26 Sep 2000 00:30:28 +0200
Message-ID: <yttaecwksu3.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>>>>> "andrea" == Andrea Arcangeli <andrea@suse.de> writes:

Hi

andrea> I'm talking about the fact that if you have a file mmapped in 1.5G of RAM
andrea> test9 will waste time rolling between LRUs 384000 pages, while classzone
andrea> won't ever see 1 of those pages until you run low on fs cache.

Which is completely wrong if the program uses _any not completely_
unusual locality of reference.  Think twice about that, it is more
probable that you need more that 300MB of filesystem cache that you
have an aplication that references _randomly_ 1.5GB of data.  You need
to balance that _always_ :((((((

I think that there is no silver bullet here :(

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
