Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA00595
	for <linux-mm@kvack.org>; Thu, 26 Nov 1998 07:49:03 -0500
Date: Thu, 26 Nov 1998 12:48:37 GMT
Message-Id: <199811261248.MAA15049@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Two naive questions and a suggestion
In-Reply-To: <Pine.LNX.3.96.981126082011.24048K-100000@mirkwood.dummy.home>
References: <199811252229.WAA05737@dax.scot.redhat.com>
	<Pine.LNX.3.96.981126082011.24048K-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, jfm2@club-internet.fr, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 26 Nov 1998 08:30:20 +0100 (CET), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> We could simply increase the readahead if we were more
> than 50% succesful (ie. 80% of swap requests can be
> satisfied from the swap cache) and decrease it if we
> drop below 40% (or less than 50% of swap requests can
> be serviced from the swap cache).

Yes --- do a patch, show us some benchmarks!  We could make a big
difference with this.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
