Received: from mail.ccr.net (ccr@alogconduit1ar.ccr.net [208.130.159.18])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA19662
	for <linux-mm@kvack.org>; Sun, 24 Jan 1999 13:44:18 -0500
Subject: Re: 2.2.0-final
References: <Pine.LNX.3.96.990124141300.222A-100000@laser.bogus>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 24 Jan 1999 12:41:25 -0600
In-Reply-To: Andrea Arcangeli's message of "Sun, 24 Jan 1999 14:16:35 +0100 (CET)"
Message-ID: <m1iudwo6nd.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "AA" == Andrea Arcangeli <andrea@e-mind.com> writes:

AA> On Sat, 23 Jan 1999, Andrea Arcangeli wrote:
>> On Wed, 20 Jan 1999, Linus Torvalds wrote:
>> 
>> > In short, before you post a bug-report about 2.2.0-final, I'd like you to
>> 
>> There are three things from me I think should go in before 2.2.0 real

AA> There's a fourth thing I forget to tell yesterday. If all pte are young we
AA> could not be able to swapout while with priority == 0 we must not care
AA> about CPU aging. I hope to have pointed out right and needed things, I
AA> don't want to spam you while you are busy... 

I don't think this is an issue.  Before we get to calling
swap_out with priority == 0 we have called it with priorities.
6,5,4,3,2,1  Which will have travelled a little over 1.5 times over
the page tables (assuming they can't find anything either).

So it looks doubtful to me that all pte's could be young.

Eric


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
