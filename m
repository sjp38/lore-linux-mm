Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA31312
	for <linux-mm@kvack.org>; Mon, 27 Jul 1998 15:48:47 -0400
Date: Mon, 27 Jul 1998 11:54:14 +0100
Message-Id: <199807271054.LAA00705@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <Pine.LNX.3.96.980724234821.31219A-100000@mirkwood.dummy.home>
References: <87ww93dvyt.fsf@atlas.CARNet.hr>
	<Pine.LNX.3.96.980724234821.31219A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@npwt.net>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 24 Jul 1998 23:55:10 +0200 (CEST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> I admit your patch (multiple aging) should work even better,
> but in order to do that, we probably want to make it auto-tuning
> on the borrow percentage:

> - if page_cache_size > borrow + 5%     --> add aging loop
<Bzzt> wrong answer...

> - if loads_of_disk_io and almost thrashing [*] --> remove aging loop
Yep, much better.

> [*] this thrashing can be measured by testing the cache hit/mis
> rate; if it falls below (say) 50% we could consider thrashing.

Doing even more rules based on the actual cache size is a bad thing
since it is enforcing an arbitrary limit which does not depend on what
the system load is right now.  Making it adapt to the current load is
ALWAYS going to be a better way of doing things.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
