Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA02274
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 18:42:20 -0500
Subject: Re: Results: pre6 vs pre6+zlatko's_patch  vs pre5 vs arcavm13
References: <Pine.LNX.3.96.990111234054.5378A-100000@laser.bogus>
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 12 Jan 1999 00:38:22 +0100
In-Reply-To: Andrea Arcangeli's message of "Tue, 12 Jan 1999 00:03:02 +0100 (CET)"
Message-ID: <87ww2tv0r5.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Steve Bergman <steve@netplus.net>, Linus Torvalds <torvalds@transmeta.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@e-mind.com> writes:

> I've seen pre7 now and I produced arca-vm-18 against it.
> 
> In arca-vm-18 I avoided the swaping readahead if we would be forced to do
> _sync_ IO in the readahead. This make tons of sense to me. 

Yes, I agree. I made a same change in my development patches, this
morning, and it works well. We can only gain with policy like that.

> Another thing that would be interesting could be to change
> SWAPFILE_CLUSTER to 256 as in clean pre7. I think it's not needed because
> I am not hearing disk seeks under heavy swapping but may I guess there is
> some reason is 256 in pre7 ;)?
> 

Better clustering of pages on the disk. That will improve swapin
readahead hit rate, and overall performance.

Regards,
-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
