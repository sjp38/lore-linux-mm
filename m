Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA10195
	for <linux-mm@kvack.org>; Mon, 4 Jan 1999 19:55:24 -0500
Subject: Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm improvement , [Re: 2.2.0 Bug summary]]
References: <Pine.LNX.3.96.990105012320.1107A-100000@laser.bogus>
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 05 Jan 1999 01:52:03 +0100
In-Reply-To: Andrea Arcangeli's message of "Tue, 5 Jan 1999 01:32:17 +0100 (CET)"
Message-ID: <873e5qbky4.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, steve@netplus.net, bredelin@ucsd.edu, sct@redhat.com, linux-kernel@vger.rutgers.edu, H.H.vanRiel@phys.uu.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@e-mind.com> writes:

> -		if (!try_to_free_pages(gfp_mask, SWAP_CLUSTER_MAX) && !(gfp_mask & (__GFP_MED | __GFP_HIGH)))
> +		if (!try_to_free_pages(gfp_mask, freepages.high - nr_free_pages + 1<<order) && !(gfp_mask & (__GFP_MED | __GFP_HIGH)))              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

How about a pair of parentheses at a strategic place? :)

Other than that, your previous (-6?) patch really works good here.

It was once that I wanted to get rid of kswapd, too, but I thought it would
surely harm performance, so I dumped the idea. Now, I'm not at all sure. :)

Keep trying!
-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
