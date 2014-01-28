Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC476B0037
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 20:21:44 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id rd3so6647808pab.16
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 17:21:43 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id va10si13327636pbc.188.2014.01.27.17.21.41
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 17:21:42 -0800 (PST)
Date: Tue, 28 Jan 2014 10:23:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v10 00/16] Volatile Ranges v10
Message-ID: <20140128012315.GE25066@bbox>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
 <CAHGf_=qiQtG_7W=SfKfGHgV6p6aT3==Wnj65UAegejeoS6fLBA@mail.gmail.com>
 <20140128001244.GB25066@bbox>
 <52E6FCF3.6010009@linaro.org>
 <52E70367.1080504@mozilla.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52E70367.1080504@mozilla.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Taras Glek <tglek@mozilla.com>
Cc: John Stultz <john.stultz@linaro.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Jan Kara <jack@suse.cz>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, pliard@google.com

On Mon, Jan 27, 2014 at 05:09:59PM -0800, Taras Glek wrote:
> 
> 
> John Stultz wrote:
> >On 01/27/2014 04:12 PM, Minchan Kim wrote:
> >>On Mon, Jan 27, 2014 at 05:23:17PM -0500, KOSAKI Motohiro wrote:
> >>>- Your number only claimed the effectiveness anon vrange, but not file vrange.
> >>Yes. It's really problem as I said.
> >> From the beginning, John Stultz wanted to promote vrange-file to replace
> >>android's ashmem and when I heard usecase of vrange-file, it does make sense
> >>to me so that's why I'd like to unify them in a same interface.
> >>
> >>But the problem is lack of interesting from others and lack of time to
> >>test/evaluate it. I'm not an expert of userspace so actually I need a bit
> >>help from them who require the feature but at a moment,
> >>but I don't know who really want or/and help it.
> >>
> >>Even, Android folks didn't have any interest on vrange-file.
> >
> >Just as a correction here. I really don't think this is the case, as
> >Android's use definitely relies on file based volatility. It might be
> >more fair to say there hasn't been very much discussion from Android
> >developers on the particulars of the file volatility semantics (out
> >possibly not having any particular objections, or more-likely, being a
> >bit too busy to follow the all various theoretical tangents we've
> >discussed).
> >
> >But I'd not want anyone to get the impression that anonymous-only
> >volatility would be sufficient for Android's needs.
> Mozilla is starting to use android's ashmem for discardable memory
> within a single process:
> https://bugzilla.mozilla.org/show_bug.cgi?id=748598 .
> 
> Volatile ranges do help with that specific(uncommon?) use of ashmem.

Thanks for the info.

I'd like to ask a question.
Do you prefer fvrange(fd, offset, len) or fadvise(fd, offset, len, advise)
inteface rather than current vrange syscall interface for vrange-file?

Because I think it would remove unnecessary mmap/munmap syscall for vrange
interface as well as out of address space in 32bit machine.

> 
> For Mozilla sharing memory across processes via ashmem is not a
> nearterm project. It's something that is likely to require
> significant rework. Process-local discardable memory can be
> retrofited in a more straight-forward fashion.
> 
> Taras

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
