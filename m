Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id EE29B6B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 18:30:00 -0400 (EDT)
Received: by oigv203 with SMTP id v203so6625519oig.3
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 15:30:00 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id sa5si363034oeb.7.2015.03.24.15.29.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 15:30:00 -0700 (PDT)
From: Jason Low <jason.low2@hp.com>
Subject: [PATCH v2 0/2] mm: Remove usages of ACCESS_ONCE()
Date: Tue, 24 Mar 2015 15:29:52 -0700
Message-Id: <1427236194-14582-1-git-send-email-jason.low2@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Jason Low <jason.low2@hp.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Aswin Chandramouleeswaran <aswin@hp.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Davidlohr Bueso <dave@stgolabs.net>, Rik van Riel <riel@redhat.com>

v1->v2:
As suggested by Michal, we can split up the v1 patch into 2 patches.
 
The first patch addresses potentially incorrect usages of ACCESS_ONCE().
 
The second patch is more of a "cleanup" patch to convert the rest of
the ACCESS_ONCE() reads in mm/ to use the new READ_ONCE() API.
 
This makes it a bit easier to backport the fixes to older kernels.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
