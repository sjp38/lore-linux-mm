Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 869468296B
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 16:55:14 -0400 (EDT)
Received: by wghl2 with SMTP id l2so12011867wgh.8
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 13:55:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dm7si22158904wid.26.2015.03.11.13.55.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Mar 2015 13:55:12 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 0/2] Move away from non-failing small allocations
Date: Wed, 11 Mar 2015 16:54:52 -0400
Message-Id: <1426107294-21551-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

Hi,
as per discussion at LSF/MM summit few days back it seems there is a
general agreement on moving away from "small allocations do not fail"
concept.

There are two patches in this series. The first one exports a sysctl
knob which controls how hard small allocation (!__GFP_NOFAIL ones of
course) retry when we get completely out of memory before the allocation
fails. The default is still retry infinitely because we cannot simply
change the 14+ years behavior right away. It will take years before all
the potential fallouts are discovered and fixed and we can change the
default value.

The second patch is the first step in the transition plan. It changes
the default but it is NOT an upstream material. It is aimed for brave
testers who can cope with failures. I have talked to Andrew and he
was willing to keep that patch in mmotm tree. It would be even better
to have this in linux-next because the testing coverage would be even
bigger. Dave Chinner has also shown an interest to integrate this into
his xfstest farm. It would be great if Fenguang could add it into the
zero testing project too (if the pushing the patch into linux-next
would be too controversial).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
