Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA27980
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 01:46:38 -0500
Date: Sun, 10 Jan 1999 22:46:01 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: testing/pre-7 and do_poll()
In-Reply-To: <19990111012620.B3767@perlsupport.com>
Message-ID: <Pine.LNX.3.95.990110223802.1997F-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chip Salzenberg <chip@perlsupport.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Mon, 11 Jan 1999, Chip Salzenberg wrote:
> 
> Well, I forgot the (unsigned long) cast, as someone else noted:
> 
> 	timeout = ROUND_UP((unsigned long) timeout, 1000/HZ);
> 
> Otherwise, the code is Just Right.

Duh?

The above code is basically just completely wrong.

Hint: HZ is a define - not 100.

You just ended up dividing by zero on certain architectures.

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
