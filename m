Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 090A76B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 20:01:23 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so6663790pbc.27
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 17:01:23 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id g5si13243342pav.288.2014.01.27.17.01.20
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 17:01:22 -0800 (PST)
Date: Tue, 28 Jan 2014 10:02:53 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v10 00/16] Volatile Ranges v10
Message-ID: <20140128010253.GD25066@bbox>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
 <CAHGf_=qiQtG_7W=SfKfGHgV6p6aT3==Wnj65UAegejeoS6fLBA@mail.gmail.com>
 <20140128001244.GB25066@bbox>
 <52E6FCF3.6010009@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52E6FCF3.6010009@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, pliard@google.com

On Mon, Jan 27, 2014 at 04:42:27PM -0800, John Stultz wrote:
> On 01/27/2014 04:12 PM, Minchan Kim wrote:
> > On Mon, Jan 27, 2014 at 05:23:17PM -0500, KOSAKI Motohiro wrote:
> >> - Your number only claimed the effectiveness anon vrange, but not file vrange.
> > Yes. It's really problem as I said.
> > From the beginning, John Stultz wanted to promote vrange-file to replace
> > android's ashmem and when I heard usecase of vrange-file, it does make sense
> > to me so that's why I'd like to unify them in a same interface.
> >
> > But the problem is lack of interesting from others and lack of time to
> > test/evaluate it. I'm not an expert of userspace so actually I need a bit
> > help from them who require the feature but at a moment,
> > but I don't know who really want or/and help it.
> >
> > Even, Android folks didn't have any interest on vrange-file.
> 
> Just as a correction here. I really don't think this is the case, as
> Android's use definitely relies on file based volatility. It might be
> more fair to say there hasn't been very much discussion from Android
> developers on the particulars of the file volatility semantics (out
> possibly not having any particular objections, or more-likely, being a
> bit too busy to follow the all various theoretical tangents we've
> discussed).
> 
> But I'd not want anyone to get the impression that anonymous-only
> volatility would be sufficient for Android's needs.

Right. Thanks for the correction.

> 
> 
> (And to further clarify here, since this can be confusing... 
> shmem/tmpfs-only file volatility *would* be sufficient, despite that
> technically being anonymous backed memory. The key issue is we need to
> be able to share the volatility between processes.)
> 
> 
> > So, we might drop vrange-file part in this patchset if it's really headache.
> > But let's discuss further because still I believe it's valuable feature to
> > keep instead of dropping.
> 
> If it helps gets interest in reviewing this, I'm ok with deferring
> (tmpfs) file volatility, so folks can get comfortable with anonymous
> volatility. But I worry its too critical a feature to ignore.

Yes. I don't want to drop it without more discussion with real user
of it but the problem is it's very hard to find one to have extra time
to discuss it.


> 
> thanks
> -john
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
