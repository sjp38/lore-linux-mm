Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 923BA6B02FD
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 03:23:10 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id h10so380777pgn.19
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 00:23:10 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id l24si348682pgn.528.2018.01.03.00.23.08
        for <linux-mm@kvack.org>;
        Wed, 03 Jan 2018 00:23:09 -0800 (PST)
Subject: Re: About the try to remove cross-release feature entirely by Ingo
From: Byungchul Park <byungchul.park@lge.com>
References: <CANrsvRPQcWz-p_3TYfNf+Waek3bcNNPniXhFzyyS=7qbCqzGyg@mail.gmail.com>
 <20171229014736.GA10341@X58A-UD3R> <20171229035146.GA11757@thunk.org>
 <20171229072851.GA12235@X58A-UD3R>
 <20171230061624.GA27959@bombadil.infradead.org>
 <20171230154041.GB3366@thunk.org>
 <20171230204417.GF27959@bombadil.infradead.org>
 <20171230224028.GC3366@thunk.org>
 <f2bc220a-a363-122a-dbf9-e5416c550899@lge.com>
 <20180103070556.GA22583@thunk.org>
 <66296fcb-8df0-9697-2825-efa37c234ad9@lge.com>
Message-ID: <45973bf8-f20c-ec0c-7e82-71b4d0a64998@lge.com>
Date: Wed, 3 Jan 2018 17:23:07 +0900
MIME-Version: 1.0
In-Reply-To: <66296fcb-8df0-9697-2825-efa37c234ad9@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <willy@infradead.org>, Byungchul Park <max.byungchul.park@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, david@fromorbit.com, Linus Torvalds <torvalds@linux-foundation.org>, Amir Goldstein <amir73il@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, oleg@redhat.com, kernel-team@lge.com, daniel@ffwll.ch

On 1/3/2018 5:10 PM, Byungchul Park wrote:
> On 1/3/2018 4:05 PM, Theodore Ts'o wrote:
>> On Wed, Jan 03, 2018 at 11:10:37AM +0900, Byungchul Park wrote:
>>>> The point I was trying to drive home is that "all we have to do is
>>>> just classify everything well or just invalidate the right lock
>>>
>>> Just to be sure, we don't have to invalidate lock objects at all but
>>> a problematic waiter only.
>>
>> So essentially you are proposing that we have to play "whack-a-mole"
>> as we find false positives, and where we may have to put in ad-hoc
>> plumbing to only invalidate "a problematic waiter" when it's
>> problematic --- or to entirely suppress the problematic waiter
> 
> If we have too many problematic completions(waiters) to handle it,
> then I agree with you. But so far, only one exits and it seems able
> to be handled even in the future on my own.
> 
> Or if you believe that we have a lot of those kind of completions
> making trouble so we cannot handle it, the (4) by Amir would work,
> no? I'm asking because I'm really curious about your opinion..
> 
>> altogether.A  And in that case, a file system developer might be forced
>> to invalidate a lock/"waiter"/"completion" in another subsystem.
> 
> As I said, with regard to the invalidation, we don't have to
> consider locks at all. It's enough to invalidate the waiter only.
> 
>> I will also remind you that doing this will trigger a checkpatch.pl
>> *error*:
> 
> This is what we decided. And I think the decision is reasonable for
> original lockdep. But I wonder if we should apply the same decision
> on waiters. I don't insist but just wonder.

What if we adopt the (4) in which waiters are validated one by one
and no explicit invalidation is involved?

>> ERROR("LOCKDEP", "lockdep_no_validate class is reserved for 
>> device->mutex.\n" . $herecurr);
>>
>> A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  - Ted
>>
> 

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
