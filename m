Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA21234
	for <linux-mm@kvack.org>; Tue, 24 Mar 1998 02:34:38 -0500
Date: Mon, 23 Mar 1998 23:34:16 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] kswapd fix
In-Reply-To: <Pine.LNX.3.91.980323222552.570B-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.980323233320.3117A-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Mon, 23 Mar 1998, Rik van Riel wrote:
> 
> It patches cleanly against 2.1.90.
> (my university's internet dialup line is _very_ flaky right
> now, so I can't ftp a pre-91 if it exists :-( ).

It certainly won't patch cleanly against pre-91 (yes, it's out there), and
anyway I'd like people to test the pre-91 first before judging whether
(and what type) patches are necessary. 

		Linus
