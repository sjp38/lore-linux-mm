Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 94F6B6B010B
	for <linux-mm@kvack.org>; Thu,  8 May 2014 13:12:44 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id wo20so3403041obc.6
        for <linux-mm@kvack.org>; Thu, 08 May 2014 10:12:44 -0700 (PDT)
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
        by mx.google.com with ESMTPS id db3si814654pbc.273.2014.05.08.10.12.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 May 2014 10:12:44 -0700 (PDT)
Received: by mail-pd0-f175.google.com with SMTP id x10so2545448pdj.20
        for <linux-mm@kvack.org>; Thu, 08 May 2014 10:12:43 -0700 (PDT)
Message-ID: <536BBB08.3000503@linaro.org>
Date: Thu, 08 May 2014 10:12:40 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] Volatile Ranges (v14 - madvise reborn edition!)
References: <1398806483-19122-1-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1398806483-19122-1-git-send-email-john.stultz@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04/29/2014 02:21 PM, John Stultz wrote:
> Another few weeks and another volatile ranges patchset...
>
> After getting the sense that the a major objection to the earlier
> patches was the introduction of a new syscall (and its somewhat
> strange dual length/purged-bit return values), I spent some time
> trying to rework the vma manipulations so we can be we won't fail
> mid-way through changing volatility (basically making it atomic).
> I think I have it working, and thus, there is no longer the
> need for a new syscall, and we can go back to using madvise()
> to set and unset pages as volatile.

Johannes: To get some feedback, maybe I'll needle you directly here a
bit. :)

Does moving this interface to madvise help reduce your objections?  I
feel like your cleaning-the-dirty-bit idea didn't work out, but I was
hoping that by reworking the vma manipulations to be atomic, we could
move to madvise and still avoid the new syscall that you seemed bothered
by. But I've not really heard much from you recently so I worry your
concerns on this were actually elsewhere, and I'm just churning the
patch needlessly.

thanks
-john



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
