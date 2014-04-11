Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id B97156B003D
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 15:32:31 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id x10so5617463pdj.6
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 12:32:31 -0700 (PDT)
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
        by mx.google.com with ESMTPS id iw3si4794056pac.178.2014.04.11.12.32.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Apr 2014 12:32:30 -0700 (PDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so5830213pad.3
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 12:32:30 -0700 (PDT)
Message-ID: <53484349.1000806@linaro.org>
Date: Fri, 11 Apr 2014 12:32:25 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Volatile Ranges (v12) & LSF-MM discussion fodder
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org> <20140401212102.GM4407@cmpxchg.org> <533B313E.5000403@zytor.com> <533B4555.3000608@sr71.net> <533B8E3C.3090606@linaro.org> <20140402163638.GQ14688@cmpxchg.org> <CALAqxLUNKJQs+q__fwqggaRtqLz5sJtuxKdVPja8X0htDyaT6A@mail.gmail.com> <20140402175852.GS14688@cmpxchg.org> <CALAqxLXs+tB3h6wqZ3m5qOFWfgeJcH03k-0dsj+NUoB5D5LEgQ@mail.gmail.com> <20140402194708.GV14688@cmpxchg.org> <533C6F6E.4080601@linaro.org>
In-Reply-To: <533C6F6E.4080601@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Hansen <dave@sr71.net>, "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04/02/2014 01:13 PM, John Stultz wrote:
> On 04/02/2014 12:47 PM, Johannes Weiner wrote:
>
>> It's really nothing but a use-after-free bug that has consequences for
>> no-one but the faulty application.  The thing that IS new is that even
>> a read is enough to corrupt your data in this case.
>>
>> MADV_REVIVE could return 0 if all pages in the specified range were
>> present, -Esomething if otherwise.  That would be semantically sound
>> even if userspace messes up.
> So its semantically more of just a combined mincore+dirty operation..
> and nothing more?
>
> What are other folks thinking about this? Although I don't particularly
> like it, I probably could go along with Johannes' approach, forgoing
> SIGBUS for zero-fill and adapting the semantics that are in my mind a
> bit stranger. This would allow for ashmem-like style behavior w/ the
> additional  write-clears-volatile-state and read-clears-purged-state
> constraints (which I don't think would be problematic for Android, but
> am not totally sure).
>
> But I do worry that these semantics are easier for kernel-mm-developers
> to grasp, but are much much harder for application developers to
> understand.

So I don't feel like we've gotten enough feedback for consensus here.

Thus, to at least address other issues pointed out at LSF-MM, I'm going
to shortly send out a v13 of the patchset which keeps with the previous
approach instead of adopting Johannes' suggested approach here.

If folks do prefer Johannes' approach, please speak up as I'm willing to
give it a whirl, despite my concerns about the subtle semantics.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
