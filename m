Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA23888
	for <linux-mm@kvack.org>; Mon, 21 Dec 1998 11:39:12 -0500
Date: Mon, 21 Dec 1998 16:37:47 GMT
Message-Id: <199812211637.QAA02759@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <Pine.LNX.3.96.981221104034.591A-100000@laser.bogus>
References: <199812191709.RAA01245@dax.scot.redhat.com>
	<Pine.LNX.3.96.981221104034.591A-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 21 Dec 1998 10:53:35 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> The good point of 132-pre2 is that you' ll never see a thread on linux
> kernel that will say "132-pre2 VM performance jerky". 

I haven't seen that for the current ac patches, either.

> It could be not the best but sure will work well for everybody out
> there on every hardware. 

Of course, you've tested this, haven't you?

pre2 works OK on low memory for me but its performance on 64MB sucks
here.  pre3 works fine on 64MB but its performance on 8MB sucks even
more.  You simply CANNOT tell from looking at the code that it "will
work well for everybody out there on every hardware".  

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
