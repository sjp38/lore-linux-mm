Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 653EC6B0037
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 16:54:51 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id s18so4339936lam.20
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 13:54:50 -0700 (PDT)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id kv5si13240827lbc.54.2014.07.08.13.54.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Jul 2014 13:54:50 -0700 (PDT)
Received: by mail-lb0-f176.google.com with SMTP id w7so4384592lbi.35
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 13:54:49 -0700 (PDT)
Date: Wed, 9 Jul 2014 00:54:48 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Don't forget to set softdirty on file mapped fault
Message-ID: <20140708205448.GH17860@moon.sw.swsoft.com>
References: <20140708192151.GD17860@moon.sw.swsoft.com>
 <20140708131920.2a857d573e8cc89780c9fa1c@linux-foundation.org>
 <20140708204017.GG17860@moon.sw.swsoft.com>
 <20140708134511.4a32b7400a952541a31e9078@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140708134511.4a32b7400a952541a31e9078@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Pavel Emelyanov <xemul@parallels.com>

On Tue, Jul 08, 2014 at 01:45:11PM -0700, Andrew Morton wrote:
> 
> The user doesn't know or care about pte bits.
> 
> What actually *happens*?  Does criu migration hang?  Does it lose data?
> Does it take longer?

Ah, I see. Yes, the softdirty bit might be lost that usespace program
won't see that a page was modified. So data lose is possible.

> IOW, what would an end-user's bug report look like?
> 
> It's important to think this way because a year from now some person
> we've never heard of may be looking at a user's bug report and
> wondering whether backporting this patch will fix it.  Amongst other
> reasons.

Here is updated changelog, sounds better?
---

In case if page fault happend on dirty filemapping the newly created pte
may loose softdirty bit thus if a userspace program is tracking memory
changes with help of a memory tracker (CONFIG_MEM_SOFT_DIRTY) it might
miss modification of a memory page (which in worts case may lead to
data inconsistency).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
