Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA09089
	for <linux-mm@kvack.org>; Fri, 3 Jul 1998 16:06:27 -0400
Date: Fri, 3 Jul 1998 21:05:27 +0100
Message-Id: <199807032005.VAA02773@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Thread implementations... 
In-Reply-To: <Pine.LNX.3.96.980703171908.20629B-100000@mirkwood.dummy.home>
References: <199807010850.JAA00764@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.96.980703171908.20629B-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 3 Jul 1998 17:21:51 +0200 (CEST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> On Wed, 1 Jul 1998, Stephen C. Tweedie wrote:
>> sequential clusters, but if we have things like Ingo's random swap
>> stats-based prediction logic, then we can use exactly the same extent
>> concept there too.

> Hmm, it appears this was the legendary swap readahead code I
> was looking for a while ago :)

> But, ehhh, just what _is_ this random swap stats-based prediction
> algorithm, 

It's a per-swap-page readahead predictor which observes the access
patterns for vmas.  

> and how far from implementation is it?

It is implemented.  It is not in the main kernels, nor does it take
advantage of the potential for swap readahead in the 2.1.86+ kernels.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
