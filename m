Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA21092
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 13:06:27 -0500
Date: Sun, 10 Jan 1999 10:04:25 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: vfork & co bugfix
In-Reply-To: <m14spz8vyx.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.95.990110100157.7668A-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On 10 Jan 1999, Eric W. Biederman wrote:
> 
> Looking at vfork in 2.2.0-pre6 I was struck by how badly 
> looking at current, (to release a process) hacks up mmput.
> 
> It took a little while but eventually a case where
> this really goes wrong.

Note that the pre6 version has a number of cases where it can really screw
up, don't even look at them too closely. I think I've fixed them all - it
was really simple, but there was a few things I hadn't originally thought
of. 

I'll make a pre7 once I've verified that the recursive semaphores work at
least to some degree, could you please take a look at that one?

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
