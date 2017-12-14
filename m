Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 979746B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 00:58:44 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id e21so1111885lfb.23
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 21:58:44 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 11sor625223lje.110.2017.12.13.21.58.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 21:58:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171214030711.gtxzm57h7h4hwbfe@thunk.org>
References: <CANrsvRPQcWz-p_3TYfNf+Waek3bcNNPniXhFzyyS=7qbCqzGyg@mail.gmail.com>
 <CANrsvRMAci5Vxj0kKsgW4-cgK4X4BAvq9jOwkAx0TWHqBjogVw@mail.gmail.com> <20171214030711.gtxzm57h7h4hwbfe@thunk.org>
From: Byungchul Park <max.byungchul.park@gmail.com>
Date: Thu, 14 Dec 2017 14:58:41 +0900
Message-ID: <CANrsvRMnRF06NLcHkEChLDCTpTemvKCunk+nJ13Kj+avT0vf4Q@mail.gmail.com>
Subject: Re: About the try to remove cross-release feature entirely by Ingo
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Byungchul Park <max.byungchul.park@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, david@fromorbit.com, willy@infradead.org, Linus Torvalds <torvalds@linux-foundation.org>, Amir Goldstein <amir73il@gmail.com>, byungchul.park@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, oleg@redhat.com

On Thu, Dec 14, 2017 at 12:07 PM, Theodore Ts'o <tytso@mit.edu> wrote:
> On Wed, Dec 13, 2017 at 04:13:07PM +0900, Byungchul Park wrote:
>>
>> Therefore, I want to say the fundamental problem
>> comes from classification, not cross-release
>> specific.
>
> You keep saying that it is "just" a matter of classificaion.

But, it's a fact.

> However, it is not obvious how to do the classification in a sane
> manner.  And this is why I keep pointing out that there is no
> documentation on how to do this, and somehow you never respond to this
> point....

I can write a document explaining what lock class is but.. I
cannot explain how to assign it perfectly since there's no right
answer. It's something we need to improve more and more.

> In the case where you have multiple unrelated subsystems that can be
> stacked in different ways, with potentially multiple instances stacked
> on top of each other, it is not at all clear to me how this problem
> should be solved.

I cannot give you a perfect solution immediately. I know, and
as you know, it's a very difficult problem to solve.

> It was said on one of these threads (perhaps by you, perhaps by
> someone else), that we can't expect the lockdep maintainers to
> understand all of the subsystems in the kernels, and so therefore it
> must be up to the subsystem maintainers to classify the locks.  I
> interpreted this as the lockdep maintainers saying, "hey, not my
> fault, it's the subsystem maintainer's fault for not properly
> classifying the locks" --- and thus dumping the responsibility in the
> subsystem maintainers' laps.

Sorry to say, making you feel like that.

Precisely speaking, the responsibility for something caused by
cross-release is on me, and the responsibility for something caused
by lockdep itselt is on lockdep.

I meant, in the current way to assign lock class automatically, it's
inevitable for someone to annotate places manually, and it can be
done best by each expert. But, anyway fundamentally I think the
responsibility is on lockdep.

> I don't know if the situation is just that lockdep is insufficiently
> documented, and with the proper tutorial, it would be obvious how to
> solve the classification problem.
>
> Or, if perhaps, there *is* no way to solve the classification problem,
> at least not in a general form.

Agree. It's a very difficult one to solve.

> For example --- suppose we have a network block device on which there
> is an btrfs file system, which is then exported via NFS.  Now all of
> the TCP locks will be used twice for two different instances, once for
> the TCP connection for the network block device, and then for the NFS
> export.
>
> How exactly are we supposed to classify the locks to make it all work?
>
> Or the loop device built on top of an ext4 file system which on a
> LVM/device mapper device.  And suppose the loop device is then layered
> with a dm-error device for regression testing, and with another ext4
> file system on top of that?

Ditto.

> How exactly are we supposed to classify the locks in that situation?
> Where's the documentation and tutorials which explain how to make this
> work, if the responsibility is going to be dumped on the subsystem
> maintainers' laps?  Or if the lockdep maintainers are expected to fix
> and classify all of these locks, are you volunteering to do this?

I have the will. I will.

> How hard is it exactly to do all of this classification work, no
> matter whose responsibility it will ultimately be?
>
> And if the answer is that it is too hard, then let me gently suggest
> to you that perhaps, if this is a case, that maybe this is a
> fundamental and fatal flaw with the cross-release and completion
> lockdep feature?

I don't understand this.

> Best regards,
>
>                                                 - Ted



-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
