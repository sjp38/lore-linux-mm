Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 80BAF6B007E
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 04:03:53 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id 191so10869210wmq.0
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 01:03:53 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id q7si33709466wmd.38.2016.04.01.01.03.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Apr 2016 01:03:52 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id 20so2583897wmh.3
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 01:03:52 -0700 (PDT)
Date: Fri, 1 Apr 2016 10:03:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: vmscan: reclaim highmem zone if buffer_heads is over
 limit
Message-ID: <20160401080350.GB8916@dhcp22.suse.cz>
References: <1459497658-22203-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459497658-22203-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>

On Fri 01-04-16 17:00:58, Minchan Kim wrote:
[...]
> [2] commit 5acbd3bfc93b ("mm, oom: rework oom detection")

I didn't look a tht patch yet but wanted to note that this sha is most
probably from linux-next and won't be stable. Also this patch will most
likely see some changes in future so making changes on top which should
go in independetly will likely just complicate things.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
