Received: from mail.ccr.net (ccr@alogconduit1ag.ccr.net [208.130.159.7])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA28401
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 02:20:59 -0500
Subject: Re: vfork & co bugfix
References: <Pine.LNX.3.95.990110223325.1997E-100000@penguin.transmeta.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 11 Jan 1999 00:59:27 -0600
In-Reply-To: Linus Torvalds's message of "Sun, 10 Jan 1999 22:35:44 -0800 (PST)"
Message-ID: <m13e5i47n4.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "LT" == Linus Torvalds <torvalds@transmeta.com> writes:

LT> I missed it too, until I started thinking about all the possible
LT> combinations.

>> Question.  Why don't we let CLONE_VFORK be a standard clone flag?

LT> Because then we're back to the old problem: before doing a vfork(),
LT> somebody could do a "clone(CLONE_VFORK)" (which would _not_ wait on the
LT> semaphore like a real vfork() would), and now the wrong child can wake up
LT> the parent and mess up the real vfork(). 

Sorry.  I had the implicit assumption that if CLONE_VFORK was a
standard clone flag, do_fork would include the five lines of semaphore
code.

Eric


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
