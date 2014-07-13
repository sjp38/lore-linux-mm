Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id C4E556B0035
	for <linux-mm@kvack.org>; Sun, 13 Jul 2014 18:05:44 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id uq10so1128027igb.17
        for <linux-mm@kvack.org>; Sun, 13 Jul 2014 15:05:44 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id dp4si16023653icc.59.2014.07.13.14.43.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 13 Jul 2014 14:43:58 -0700 (PDT)
Message-ID: <53C2FD71.7090102@oracle.com>
Date: Sun, 13 Jul 2014 17:43:13 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: + shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
 added to -mm tree
References: <alpine.LSU.2.11.1407092358090.18131@eggly.anvils> <53BE8B1B.3000808@oracle.com> <53BECBA4.3010508@oracle.com> <alpine.LSU.2.11.1407101033280.18934@eggly.anvils> <53BED7F6.4090502@oracle.com> <alpine.LSU.2.11.1407101131310.19154@eggly.anvils> <53BEE345.4090203@oracle.com> <20140711082500.GB20603@laptop.programming.kicks-ass.net> <53BFD708.1040305@oracle.com> <alpine.LSU.2.11.1407110745430.2054@eggly.anvils> <20140711155958.GR20603@laptop.programming.kicks-ass.net>
In-Reply-To: <20140711155958.GR20603@laptop.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, davej@redhat.com, koct9i@gmail.com, lczerner@redhat.com, stable@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 07/11/2014 11:59 AM, Peter Zijlstra wrote:
>>> I agree with you that "The call trace is very clear on it that its not", but
>>> > > when you have 500 call traces you really want something better than going
>>> > > through it one call trace at a time.
>> > 
>> > Points well made, and I strongly agree with Vlastimil and Sasha.
>> > There is a world of difference between a lock wanted and a lock held,
>> > and for the display of locks "held" to conceal that difference is unhelpful.
>> > It just needs one greppable word to distinguish the cases.
> So for the actual locking scenario it doesn't make a difference one way
> or another. These threads all can/could/will acquire the lock
> (eventually), so all their locking chains should be considered.

I think that the difference here is that we're not actually debugging a locking
issue, we're merely using lockdep to help with figuring out a non-locking
related bug and finding it difficult because lockdep's list of "held locks"
is really a lie :)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
