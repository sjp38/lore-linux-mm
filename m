Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA14326
	for <linux-mm@kvack.org>; Tue, 5 Jan 1999 10:43:18 -0500
Date: Tue, 5 Jan 1999 16:42:35 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm improvement , [Re: 2.2.0 Bug summary]]
In-Reply-To: <8767alua44.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.3.96.990105164004.3611D-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 5 Jan 1999, Zlatko Calusic wrote:

> I tried few times, but to no avail. Looks like subtle race, bad news
> for you, unfortunately.

Hmm, I gues it's been due the wrong order shifiting you pointed out a bit
before...

The lockup could be due to one oom loop. Ingo pointed out at once that
raid1 (if I remeber well) has one of them. Do you use raidx?

> Sure, just be careful. :)

Don't worry ;). Could you try if you can reproduce problems with
arca-vm-8? 

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
