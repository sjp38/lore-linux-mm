Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f49.google.com (mail-lf0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 46726828E5
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 14:52:48 -0400 (EDT)
Received: by mail-lf0-f49.google.com with SMTP id g184so110459614lfb.3
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 11:52:48 -0700 (PDT)
Received: from mail.anarazel.de (mail.anarazel.de. [217.115.131.40])
        by mx.google.com with ESMTP id 17si22377724wjx.30.2016.04.04.11.52.46
        for <linux-mm@kvack.org>;
        Mon, 04 Apr 2016 11:52:46 -0700 (PDT)
Date: Mon, 4 Apr 2016 20:52:41 +0200
From: Andres Freund <andres@anarazel.de>
Subject: Re: [PATCH 0/3] mm: support bigger cache workingsets and protect
 against writes
Message-ID: <20160404185241.GF25969@awork2.anarazel.de>
References: <1459790018-6630-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459790018-6630-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi Johannes,

On 2016-04-04 13:13:35 -0400, Johannes Weiner wrote:
> this is a follow-up to http://www.spinics.net/lists/linux-mm/msg101739.html
> where Andres reported his database workingset being pushed out by the
> minimum size enforcement of the inactive file list - currently 50% of cache
> - as well as repeatedly written file pages that are never actually read.

Thanks for following up!


> Andres, I tried reproducing your postgres scenario, but I could never get
> the WAL to interfere even with wal_log = hot_standby mode. It's a 8G
> machine, I set shared_buffers = 2GB, ran pgbench -i -s 290, and then -c 32
> -j 32 -M prepared -t 150000. Any input on how to trigger the thrashing you
> observed would be appreciated. But it would be great if you could test these
> patches on your known-problematic setup as well.

I'm unfortunately in the process of moving to the US (as in, I'm packing
boxes), so I can't get back to you just now. I'll try ASAP (early next
week).

Regards,

Andres

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
