Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA08573
	for <linux-mm@kvack.org>; Tue, 12 Jan 1999 11:07:07 -0500
Date: Tue, 12 Jan 1999 16:06:38 GMT
Message-Id: <199901121606.QAA04800@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <m1aezq4a78.fsf@flinx.ccr.net>
References: <199901101659.QAA00922@dax.scot.redhat.com>
	<Pine.LNX.3.95.990110103201.7668D-100000@penguin.transmeta.com>
	<199901102249.WAA01684@dax.scot.redhat.com>
	<m1aezq4a78.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Savochkin Andrey Vladimirovich <saw@msu.ru>, Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 11 Jan 1999 00:04:11 -0600, ebiederm+eric@ccr.net (Eric W. Biederman)
said:

> Oh, and just as a side note we are currently unfairly penalizing
> threaded programs by doing for_each_task instead of for_each_mm in the
> swapout code...

I know, on my TODO list...

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
