Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id E822B82905
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 18:36:20 -0400 (EDT)
Received: by yhaf73 with SMTP id f73so6274889yha.1
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 15:36:20 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id z9si2554495yhb.95.2015.03.11.15.36.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Mar 2015 15:36:20 -0700 (PDT)
Message-ID: <5500C352.2060104@oracle.com>
Date: Wed, 11 Mar 2015 18:36:02 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] Move away from non-failing small allocations
References: <1426107294-21551-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <1426107294-21551-1-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On 03/11/2015 04:54 PM, Michal Hocko wrote:
> The second patch is the first step in the transition plan. It changes
> the default but it is NOT an upstream material. It is aimed for brave
> testers who can cope with failures. I have talked to Andrew and he
> was willing to keep that patch in mmotm tree. It would be even better
> to have this in linux-next because the testing coverage would be even
> bigger. Dave Chinner has also shown an interest to integrate this into
> his xfstest farm. It would be great if Fenguang could add it into the
> zero testing project too (if the pushing the patch into linux-next
> would be too controversial).

Stuff in mmotm automatically end up in linux-next.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
