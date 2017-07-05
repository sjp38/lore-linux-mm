Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id E17896B037E
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 10:08:05 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id v193so145168661itc.10
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 07:08:05 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id 194si24117327itz.9.2017.07.05.07.08.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 07:08:04 -0700 (PDT)
Date: Wed, 5 Jul 2017 09:08:01 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm/slab: What is cache_reap work for?
In-Reply-To: <201707042215.ICG90672.FStFMFQOHLOOJV@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.20.1707050906290.448@east.gentwo.org>
References: <201706271935.DJJ18719.OMFLFFHJSOVtQO@I-love.SAKURA.ne.jp> <alpine.DEB.2.20.1706300856530.3291@east.gentwo.org> <201707042215.ICG90672.FStFMFQOHLOOJV@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Tue, 4 Jul 2017, Tetsuo Handa wrote:

> Thank you for explanation. What I observed is that it seems that
> cache_reap work was not able to run because it used system_wq when
> the system was unable to allocate memory for new worker thread due to
> infinite too_many_isolated() loop in shrink_inactive_list().

Its ok for it not to run for awhile but that potentially traps memory. And
you want more memory to be freed.

> I wondered whether cache_reap work qualifies as an mm_percpu_wq user
> if cache_reap work does something like what vmstat_work work does (e.g.
> update statistic counters which affect progress of memory allocation).
> But "calls other functions that are used during regular slab allocation"
> means cache_reap work cannot qualify as an mm_percpu_wq user...

Well if you audit the functions called then you may be able to get there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
