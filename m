Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA19867
	for <linux-mm@kvack.org>; Tue, 2 Jun 1998 18:21:42 -0400
Date: Tue, 2 Jun 1998 23:21:03 +0100
Message-Id: <199806022221.XAA11217@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: patch for 2.1.102 swap code
In-Reply-To: <Pine.LNX.3.91.980526234356.11319A-100000@mirkwood.dummy.home>
References: <199805262138.WAA02811@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.91.980526234356.11319A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, Bill Hawes <whawes@star.net>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Rik,

On Tue, 26 May 1998 23:46:35 +0200 (MET DST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> Hmm, could read_swap_cache_async() be used to implement swap
> readahead?

Absolutely, it was designed with that in mind.  It's a bit close to
2.1 to actually use it, but I'll be doing a lot of work to tighten
things up in 2.3 around the swap code, and readahead will be one
component of that.

--Stephen
