Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA27814
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 01:35:59 -0500
Date: Sun, 10 Jan 1999 22:35:44 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: vfork & co bugfix
In-Reply-To: <m1ogo64eg5.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.95.990110223325.1997E-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On 10 Jan 1999, Eric W. Biederman wrote:
> 
> Darn it I missed the easy bug (All children waking up the parent),
> and found the hard one (waking up the parent if fork fails).

I missed it too, until I started thinking about all the possible
combinations.

> Question.  Why don't we let CLONE_VFORK be a standard clone flag?

Because then we're back to the old problem: before doing a vfork(),
somebody could do a "clone(CLONE_VFORK)" (which would _not_ wait on the
semaphore like a real vfork() would), and now the wrong child can wake up
the parent and mess up the real vfork(). 

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
