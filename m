Received: from mail.ccr.net (ccr@alogconduit1am.ccr.net [208.130.159.13])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA23691
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 16:42:56 -0500
Subject: Re: vfork & co bugfix
References: <Pine.LNX.3.95.990110100157.7668A-100000@penguin.transmeta.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 10 Jan 1999 15:34:46 -0600
In-Reply-To: Linus Torvalds's message of "Sun, 10 Jan 1999 10:04:25 -0800 (PST)"
Message-ID: <m1u2xy6ccp.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "LT" == Linus Torvalds <torvalds@transmeta.com> writes:

LT> On 10 Jan 1999, Eric W. Biederman wrote:
>> 
>> Looking at vfork in 2.2.0-pre6 I was struck by how badly 
>> looking at current, (to release a process) hacks up mmput.
>> 
>> It took a little while but eventually a case where
>> this really goes wrong.

LT> Note that the pre6 version has a number of cases where it can really screw
LT> up, don't even look at them too closely. I think I've fixed them all - it
LT> was really simple, but there was a few things I hadn't originally thought
LT> of. 

LT> I'll make a pre7 once I've verified that the recursive semaphores work at
LT> least to some degree, could you please take a look at that one?

Will do.  

The messing up of segments, and the ldt is much older than pre6 though.
The vfork release semaphore code just happened to make about the same assumption,
so I fixed them both at the same time.

Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
