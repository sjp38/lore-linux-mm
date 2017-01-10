Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C24EE6B0038
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 07:56:12 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so21064327wms.7
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 04:56:12 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id u26si1424994wrd.206.2017.01.10.04.56.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 04:56:11 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id r126so9231604wmr.3
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 04:56:11 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 0/2] follow up nodereclaim for 32b fix
Date: Tue, 10 Jan 2017 13:55:50 +0100
Message-Id: <20170110125552.4170-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Hi,
this is a follow up fix on top of [1]. I wasn't able to trigger bad
things happening without the patch but the fix should be quite obvious
and should make sense in general. I am sending this as an RFC, though,
because g_u_p is better to not touch without strong reasons because it
is just too easy to screw up.

The second patch is just a cleanup on top.

[1] http://lkml.kernel.org/r/20170104100825.3729-1-mhocko@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
