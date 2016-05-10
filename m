Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 84BAD6B007E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 07:28:38 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id k129so25904173iof.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 04:28:38 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id ef8si13786451igb.61.2016.05.10.04.28.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 04:28:37 -0700 (PDT)
Subject: Re: [RFC 02/13] mm, page_alloc: set alloc_flags only once in slowpath
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
	<1462865763-22084-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1462865763-22084-3-git-send-email-vbabka@suse.cz>
Message-Id: <201605102028.AAC26596.SMHOQOtLOFFFVJ@I-love.SAKURA.ne.jp>
Date: Tue, 10 May 2016 20:28:27 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz, mhocko@kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, riel@redhat.com, rientjes@google.com, mgorman@techsingularity.net, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

Vlastimil Babka wrote:
> In __alloc_pages_slowpath(), alloc_flags doesn't change after it's initialized,
> so move the initialization above the retry: label. Also make the comment above
> the initialization more descriptive.

Not true. gfp_to_alloc_flags() will include ALLOC_NO_WATERMARKS if current
thread got TIF_MEMDIE after gfp_to_alloc_flags() was called for the first
time. Do you want to make TIF_MEMDIE threads fail their allocations without
using memory reserves?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
