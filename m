Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA28533
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 02:31:53 -0500
Date: Sun, 10 Jan 1999 23:31:34 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: vfork & co bugfix
In-Reply-To: <m13e5i47n4.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.95.990110232846.1997K-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On 11 Jan 1999, Eric W. Biederman wrote:
> 
> >> Question.  Why don't we let CLONE_VFORK be a standard clone flag?
> 
> LT> Because then we're back to the old problem: before doing a vfork(),
> LT> somebody could do a "clone(CLONE_VFORK)" (which would _not_ wait on the
> LT> semaphore like a real vfork() would), and now the wrong child can wake up
> LT> the parent and mess up the real vfork(). 
> 
> Sorry.  I had the implicit assumption that if CLONE_VFORK was a
> standard clone flag, do_fork would include the five lines of semaphore
> code.

Oh, ok.

Sure, makes sense, and is probably the right thing to do - that way you
can (if you really want to) do some strange half-way vfork(), half-way
clone() thing where you share your file descriptors in a vfork(). 

I don't know how useful it would be, but it would be no uglier than doing
it any other way, and I see some advantages (no need for a separate
vfork()  system call - clone() can do it directly). 

I thus remove all my objections,

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
