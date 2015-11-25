Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 39EB16B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 05:41:02 -0500 (EST)
Received: by wmuu63 with SMTP id u63so132123978wmu.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 02:41:01 -0800 (PST)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id cm4si33719884wjb.78.2015.11.25.02.41.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 02:41:01 -0800 (PST)
Received: by wmww144 with SMTP id w144so63423009wmw.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 02:41:00 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] GFP_NOFAIL reserves + warning about reserves depletion
Date: Wed, 25 Nov 2015 11:40:52 +0100
Message-Id: <1448448054-804-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
The first patch has been posted [1] last time and it seems there is no
major opposition to it. The only concern was a warning which was used
to note the ALLOC_NO_WATERMARKS request for the __GFP_NOFAIL failed.

I still think that the warning is helpful so I've separated it to 
its own patch 2 and make it more generic to all ALLOC_NO_WATERMARKS
failures. The warning is on off but an update to min_free_kbytes
allows dump the warning again.

[1] http://lkml.kernel.org/r/1447249697-13380-1-git-send-email-mhocko@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
