Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3D6496B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 07:49:56 -0400 (EDT)
Received: by mail-qg0-f53.google.com with SMTP id q107so3616514qgd.12
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 04:49:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x1si9216200qad.103.2014.07.31.04.49.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jul 2014 04:49:55 -0700 (PDT)
From: "Jerome Marchand" <jmarchan@redhat.com>
Subject: [PATCH 0/2] Fix excessive swapping when memcg are enabled
Date: Thu, 31 Jul 2014 13:49:43 +0200
Message-Id: <1406807385-5168-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>

When memory cgroups are enabled, reclaim code may force scan of
anonymous page in one memcg even when there are plenty of file pages
in other memcg. It has lead to excessive swapping in a real life
example: a virtual machine running in a memcg while there is
background I/O.

The first patch just updates an outdated comment that has bugged me
for a while but that I never bothered to update. The second patch
actually fixes the issue.

Jerome Marchand (2):
  mm, vmscan: fix an outdated comment still mentioning get_scan_ratio
  memcg, vmscan: Fix forced anon scan

 mm/vmscan.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
