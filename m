Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA08408
	for <linux-mm@kvack.org>; Fri, 27 Mar 1998 12:31:50 -0500
Date: Fri, 27 Mar 1998 09:30:40 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: new allocation algorithm
In-Reply-To: <Pine.LNX.3.91.980327095733.3532A-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.980327092811.6613C-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Fri, 27 Mar 1998, Rik van Riel wrote:
> 
> I just came up with the idea of using an ext2 like algorithm
> for memory allocation, in which we:
> - group memory in 128 PAGE groups
> - have one unsigned char counter per group, counting the number
>   of used pages

Let's wait with how well the current setup works. It seems to perform
reasonably well even on smaller machines (modulo your patch), and I think
we'd better more-or-less freeze it waiting for further info on what people
actually think. 

The current scheme is fairly efficient and extremely stable, and gives
good behaviour for the cases we _really_ care about (pageorders 0, 1 and
to some degree 2). It comes reasonably close to working for the higher
orders too, but they really aren't as critical..

		Linus
