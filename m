Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA25118
	for <linux-mm@kvack.org>; Thu, 19 Nov 1998 17:34:31 -0500
Date: Thu, 19 Nov 1998 14:33:59 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Linux-2.1.129..
In-Reply-To: <19981119223434.00625@boole.suse.de>
Message-ID: <Pine.LNX.3.95.981119143242.13021A-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Thu, 19 Nov 1998, Dr. Werner Fink wrote:
> 
> Yes on a 512MB system it's a great win ... on a 64 system I see
> something like a ``swapping weasel'' under high load.

The reason the page aging was removed was that I had people who did
studies and told me that the page aging hurts on low-memory machines.

On something like the machine I have, page aging makes absolutely
no difference whatsoever, either positive or negative.

Stephen, you're the one who did the studies. Comments?

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
