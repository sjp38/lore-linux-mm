Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id BAFFB6B0005
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 05:51:45 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id jf8so40725752lbc.3
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 02:51:45 -0700 (PDT)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id yt4si9553552wjb.200.2016.06.07.02.51.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 02:51:44 -0700 (PDT)
Received: by mail-wm0-f54.google.com with SMTP id n184so128767377wmn.1
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 02:51:44 -0700 (PDT)
Date: Tue, 7 Jun 2016 11:51:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 00/10] mm: balance LRU lists based on relative thrashing
Message-ID: <20160607095143.GI12305@dhcp22.suse.cz>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160606194836.3624-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Mon 06-06-16 15:48:26, Johannes Weiner wrote:
> Hi everybody,
> 
> this series re-implements the LRU balancing between page cache and
> anonymous pages to work better with fast random IO swap devices.

I didn't get to review the full series properly but initial patches
(2-5) seem good to go even without the rest. I will try to get to the
rest ASAP.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
