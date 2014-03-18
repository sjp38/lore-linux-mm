Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id C2B776B00FC
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 08:24:29 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so5750645wgh.15
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 05:24:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bd3si11413208wjb.65.2014.03.18.05.24.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 05:24:28 -0700 (PDT)
Date: Tue, 18 Mar 2014 13:24:25 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/3] Volatile Ranges (v11)
Message-ID: <20140318122425.GD3191@dhcp22.suse.cz>
References: <1394822013-23804-1-git-send-email-john.stultz@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1394822013-23804-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dgiani@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri 14-03-14 11:33:30, John Stultz wrote:
[...]
> Volatile ranges provides a method for userland to inform the kernel that
> a range of memory is safe to discard (ie: can be regenerated) but
> userspace may want to try access it in the future.  It can be thought of
> as similar to MADV_DONTNEED, but that the actual freeing of the memory
> is delayed and only done under memory pressure, and the user can try to
> cancel the action and be able to quickly access any unpurged pages. The
> idea originated from Android's ashmem, but I've since learned that other
> OSes provide similar functionality.

Maybe I have missed something (I've only glanced through the patches)
but it seems that marking a range volatile doesn't alter neither
reference bits nor position in the LRU. I thought that a volatile page
would be moved to the end of inactive LRU with the reference bit
dropped. Or is this expectation wrong and volatility is not supposed to
touch page aging?

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
