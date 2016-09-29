Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 031C3280256
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 04:44:21 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b4so6645205wmb.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 01:44:20 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id c81si12368385wmh.35.2016.09.29.01.44.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 01:44:20 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id b184so9581191wma.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 01:44:19 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] warn about allocations which stall for too long
Date: Thu, 29 Sep 2016 10:44:05 +0200
Message-Id: <20160929084407.7004-1-mhocko@kernel.org>
In-Reply-To: <20160923081555.14645-1-mhocko@kernel.org>
References: <20160923081555.14645-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
it seems there was no fundamental opposition to my previous RFC [1]
so I am sending this again now to be considered for inclusion. I have
reworked the patch slightly and made it use the already existing
warn_alloc_failed which was updated and renamed to be more generic. This
is the patch 1. The patch 2 then simply uses it to warn about long
stall. Comparing to the previous patch it also does show_mem() which
might be really helpful to see why the allocation cannot make any
progress.

[1] http://lkml.kernel.org/r/20160923081555.14645-1-mhocko@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
