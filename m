Received: from mail.ccr.net (ccr@alogconduit1at.ccr.net [208.130.159.20])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA03532
	for <linux-mm@kvack.org>; Mon, 1 Feb 1999 16:42:05 -0500
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
References: <Pine.LNX.3.96.990131015437.303F-100000@laser.bogus>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 31 Jan 1999 02:36:41 -0600
In-Reply-To: Andrea Arcangeli's message of "Sun, 31 Jan 1999 02:00:55 +0100 (CET)"
Message-ID: <m1r9sbvnxi.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "AA" == Andrea Arcangeli <andrea@e-mind.com> writes:

AA> On 30 Jan 1999, Eric W. Biederman wrote:

AA> The point is that you can't increment and test a mm->count if you are not
AA> sure that the mm exists on such piece of memory. And if you are sure that
AA> such piece of memory exists you don't need to check it and you can only
AA> increment it ;). Do you see my point now?

The check may be needed if someone is decrementing the count while you are
incrementing.   To remove the need for the check would require a lock
on the task struct.  (So a new pointer isn't written, and subsequently
the old data freed before you increment your count).

Furthermore I am perfectly aware, the race existed in my code, and that
it relied on fast code paths (not the best).  But since it cleared
the interrupts I could if need be garantee on a given machine the code would
always work.

However that is not a very portable way to code and I wouldn't recommend it.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
