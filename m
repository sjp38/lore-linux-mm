Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA16024
	for <linux-mm@kvack.org>; Sun, 29 Nov 1998 11:07:28 -0500
Date: Mon, 30 Nov 1998 11:15:46 GMT
Message-Id: <199811301115.LAA02884@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [2.1.130-3] Page cache DEFINATELY too persistant... feature?
In-Reply-To: <8767c0q55d.fsf@atlas.CARNet.hr>
References: <199811261236.MAA14785@dax.scot.redhat.com>
	<Pine.LNX.3.95.981126094159.5186D-100000@penguin.transmeta.com>
	<199811271602.QAA00642@dax.scot.redhat.com>
	<8767c0q55d.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Benjamin Redelings I <bredelin@ucsd.edu>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 27 Nov 1998 20:58:38 +0100, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
said:

> Yesterday, I was trying to understand the very same problem you're
> speaking of. Sometimes kswapd decides to swapout lots of things,
> sometimes not.

> I applied your patch, but it didn't solve the problem.
> To be honest, things are now even slightly worse. :(

Well, after a few days of running with the patched 2.1.130, I have never
seen evil cache growth and the performance has been great throughout.
If you can give me a reproducible way of observing bad worst-case
behaviour, I'd love to see it, but right now, things like

	wc /usr/bin/*

run just fine with no swapping of any running apps.

--Stephen

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
