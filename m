Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7146B0038
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 02:38:51 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id w21so229003lfi.1
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 23:38:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j74sor1077512lfg.56.2017.12.14.23.38.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Dec 2017 23:38:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171215062428.5dyv7wjbzn2ggxvz@thunk.org>
References: <CANrsvRPQcWz-p_3TYfNf+Waek3bcNNPniXhFzyyS=7qbCqzGyg@mail.gmail.com>
 <20171213104617.7lffucjhaa6xb7lp@gmail.com> <CANrsvRPuhPyh1nFnzdYj8ph7e1FQRw_W_WN2a1tm9fzpAYks4g@mail.gmail.com>
 <CANrsvRP3-bWatoaq1teNFG1RXRbazqnHvOKXe458eAxSdAnsfg@mail.gmail.com> <20171215062428.5dyv7wjbzn2ggxvz@thunk.org>
From: Byungchul Park <max.byungchul.park@gmail.com>
Date: Fri, 15 Dec 2017 16:38:47 +0900
Message-ID: <CANrsvROu_Y6nOwnTGxyL8UbMcFpYdhZrQpa=ECNUsVxNftC=zQ@mail.gmail.com>
Subject: Re: [PATCH] locking/lockdep: Remove the cross-release locking checks
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Byungchul Park <max.byungchul.park@gmail.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, david@fromorbit.com, willy@infradead.org, Linus Torvalds <torvalds@linux-foundation.org>, Amir Goldstein <amir73il@gmail.com>, byungchul.park@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, oleg@redhat.com

On Fri, Dec 15, 2017 at 3:24 PM, Theodore Ts'o <tytso@mit.edu> wrote:
> On Fri, Dec 15, 2017 at 01:05:43PM +0900, Byungchul Park wrote:
>> For example, in the case of fs issues, for now we can
>> invalidate wait_for_completion() in submit_bio_wait()....
>
> And this will spawn a checkpatch.pl ERROR:
>
>                     ERROR("LOCKDEP",
>                     "lockdep_no_validate class is reserved for device->mutex.\n" . $herecurr);
>
> This mention in checkpatch.pl is the only documentation I've been able
> to find about lockdep_set_novalidate_class(), by the way.
>
>> ... and re-validate it later, of course, I really want to find more
>> fundamental solution though.
>
> Oh, and I was finally able to find the quote that the *only* people
> who are likely to be able to deal with lock annotations are the

Right. Using the word, "only", is one that I should not have done
and I apologize for.

They are just "only" people who solve and classify locks quickly,
assuming all of kernel guys are familiar with lockdep annotations.
Thus, even this statement is bad as well, since no good
document for that exists, as you pointed out. I agree.

> subsystem maintainers.  But if the ways of dealing with lock
> annotations are not documented, such that subsystem maintainers are
> going to have a very hard time figuring out *how* to deal with it, it

Right. I've agreed with this, since you pointed out it's problem not
to be documented well.

> seems that lock classification as a solution to cross-release false
> positives seems.... unlikely:
>
>    From: Byungchul Park <byungchul.park@lge.com>
>    Date: Fri, 8 Dec 2017 18:27:45 +0900
>    Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
>
>    1) Firstly, it's hard to assign lock classes *properly*. By
>    default, it relies on the caller site of lockdep_init_map(),
>    but we need to assign another class manually, where ordering
>    rules are complicated so cannot rely on the caller site. That
>    *only* can be done by experts of the subsystem.
>
>                                         - Ted



-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
