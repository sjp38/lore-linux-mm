Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA00594
	for <linux-mm@kvack.org>; Mon, 25 Jan 1999 13:44:17 -0500
Date: Mon, 25 Jan 1999 18:43:58 GMT
Message-Id: <199901251843.SAA08417@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.95.990125102428.21082D-100000@penguin.transmeta.com>
References: <199901251625.QAA04452@dax.scot.redhat.com>
	<Pine.LNX.3.95.990125102428.21082D-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 25 Jan 1999 10:27:30 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

>> Regarding the former, is there any chance you'd consider adding a kswapd
>> wakeup when low_memory gets set in get_free_pages()?  Being able to
>> respond to a burst in network traffic without locking up is not exactly
>> a minor issue.

> Note that it wouldn't ever trigger for GFP_ATOMIC allocations, so I
> suspect you haven't actually _tried_ it? For a machine that gets burst of
> network traffic with nothing else going on, adding it should essentially
> amount to a no-op.

Correct: I haven't been testing any of the networking stuff myself so it
has been a non-issue for any of my workloads here.  Obviously any check
for this case would have to be outside the GFP_WAIT conditional, but it
does make sense to set low_on_memory there anyway.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
