Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA11112
	for <linux-mm@kvack.org>; Fri, 4 Dec 1998 07:07:20 -0500
Date: Fri, 4 Dec 1998 12:05:07 GMT
Message-Id: <199812041205.MAA01773@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: SWAP: Linux far behind Solaris or I missed something (fwd)
In-Reply-To: <Pine.LNX.3.96.981203130156.1008D-100000@mirkwood.dummy.home>
References: <Pine.LNX.3.96.981203130156.1008D-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>, Jean-Michel.Vansteene@bull.net, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 3 Dec 1998 13:03:35 +0100 (CET), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> Hi,
> I think we really should be working on this -- anybody
> got a suggestion?

Depends on what the program is doing:

> I've made some tests to load a computer (1GB memory).
> A litle process starts eating 900 MB then slowly eats 
> the remainder of the memory 1MB by 1MB and does a
> "data shake": 200,000 times a memcpy of 4000 bytes 
> randomly choosen.

are these 4000 bytes chosen randomly from the 1MB currently being
"eaten", or from the whole block of memory currently "eaten"?  That
makes a huge difference to the problem.  What kernel is this, anyway?

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
