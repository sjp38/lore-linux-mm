Date: Mon, 8 May 2000 11:20:58 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Recent VM fiasco - fixed
In-Reply-To: <dnln1kykkb.fsf@magla.iskon.hr>
Message-ID: <Pine.LNX.4.10.10005081118200.811-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko@iskon.hr>
Cc: riel@nl.linux.org, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On 8 May 2000, Zlatko Calusic wrote:
> 
> But still, optimizing for 1GB, while at the same time completely
> killing performances even *usability* for the 99% of users doesn't
> look like a good solution, does it?

Oh, definitely. I'll make a new pre7 that has a lot of the simplifications
discussed here over the weekend, and seems to work for me (tested both on
a 512MB setup and a 64MB setup for some sanity).

This pre7 almost certainly won't be all that perfect either, but gives a
better starting point.

> But after few hours spent dealing with the horrible VM that is in the
> pre6, I'm not scared anymore.

Good. This is really not scary stuff. Much of it is quite straightforward,
and is mainly just getting the right "feel". It's really easy to make
mistakes here, but they tend to be mistakes that just makes the system act
badly, not the kind of _really_ scary mistakes (the ones that make it
corrupt disks randomly ;)

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
