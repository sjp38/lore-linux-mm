Received: from Cantor.suse.de (Cantor.suse.de [194.112.123.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA24823
	for <linux-mm@kvack.org>; Thu, 19 Nov 1998 16:36:22 -0500
Message-ID: <19981119223434.00625@boole.suse.de>
Date: Thu, 19 Nov 1998 22:34:34 +0100
From: "Dr. Werner Fink" <werner@suse.de>
Subject: Re: Linux-2.1.129..
References: <Pine.LNX.3.95.981119002335.838A-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.95.981119002335.838A-100000@penguin.transmeta.com>; from Linus Torvalds on Thu, Nov 19, 1998 at 12:33:19AM -0800
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> 
> Have fun with it, and tell me if it breaks. But it won't. I'm finally
> getting the old "greased weasel" feeling back. In short, this is the much
> awaited perfect and bug-free release, and the only reason I don't call it
> 2.2 is that I'm chicken.
> 
> 	Kvaa, kvaa,
> 			Linus

Yes on a 512MB system it's a great win ... on a 64 system I see
something like a ``swapping weasel'' under high load.

It seems that page ageing or something *similar* would be nice
for a factor 512/64 >= 2  ... under high load and not enough
memory it's maybe better if we could get the processes in turn
into work instead of useless swapping (this was a side effect
of page ageing due to the implicit slow down).


          Werner

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
