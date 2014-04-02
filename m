Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id BFFB66B00C8
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 13:40:20 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so499242pdi.2
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 10:40:20 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id m6si1674572pbj.12.2014.04.02.10.40.17
        for <linux-mm@kvack.org>;
        Wed, 02 Apr 2014 10:40:17 -0700 (PDT)
Message-ID: <533C4B7E.6030807@sr71.net>
Date: Wed, 02 Apr 2014 10:40:14 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Volatile Ranges (v12) & LSF-MM discussion fodder
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org> <20140401212102.GM4407@cmpxchg.org> <533B8C2D.9010108@linaro.org> <20140402163013.GP14688@cmpxchg.org> <533C3BB4.8020904@zytor.com> <533C3CDD.9090400@zytor.com> <20140402171812.GR14688@cmpxchg.org>
In-Reply-To: <20140402171812.GR14688@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, "H. Peter Anvin" <hpa@zytor.com>
Cc: John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04/02/2014 10:18 AM, Johannes Weiner wrote:
> Hence my follow-up question in the other mail about how large we
> expect such code caches to become in practice in relationship to
> overall system memory.  Are code caches interesting reclaim candidates
> to begin with?  Are they big enough to make the machine thrash/swap
> otherwise?

A big chunk of the use cases here are for swapless systems anyway, so
this is the *only* way for them to reclaim anonymous memory.  Their
choices are either to be constantly throwing away and rebuilding these
objects, or to leave them in memory effectively pinned.

In practice I did see ashmem (the Android thing that we're trying to
replace) get used a lot by the Android web browser when I was playing
with it.  John said that it got used for storing decompressed copies of
images.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
