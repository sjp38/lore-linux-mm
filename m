Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA18272
	for <linux-mm@kvack.org>; Wed, 13 Jan 1999 12:48:41 -0500
Date: Wed, 13 Jan 1999 17:48:13 GMT
Message-Id: <199901131748.RAA06406@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.96.990112200143.1382B-100000@laser.bogus>
References: <87d84kl49u.fsf@atlas.CARNet.hr>
	<Pine.LNX.3.96.990112200143.1382B-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 12 Jan 1999 20:05:21 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> On 12 Jan 1999, Zlatko Calusic wrote:
>> Could somebody spare a minute to explain why is that so, and what
>> needs to be done to make SHM swapping asynchronous?

> Maybe because nobody care about shm? I think shm can wait for 2.3 to be
> improved.

"Nobody"?  Oracle uses large shared memory regions for starters.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
