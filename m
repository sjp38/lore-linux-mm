Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D5ED16B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 06:18:35 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y142so3241894wme.12
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 03:18:35 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q7sor6740776edh.11.2017.10.19.03.18.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Oct 2017 03:18:34 -0700 (PDT)
Date: Thu, 19 Oct 2017 13:18:32 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: mlock: remove lru_add_drain_all()
Message-ID: <20171019101832.xli25kizn3y55pbq@node.shutemov.name>
References: <20171018231730.42754-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171018231730.42754-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, Ingo Molnar <mingo@kernel.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Oct 18, 2017 at 04:17:30PM -0700, Shakeel Butt wrote:
> Recently we have observed high latency in mlock() in our generic
> library and noticed that users have started using tmpfs files even
> without swap and the latency was due to expensive remote LRU cache
> draining.

Hm. Isn't the point of mlock() to pay price upfront and make execution
smoother after this?

With this you shift latency onto reclaim (and future memory allocation).

I'm not sure if it's a win.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
