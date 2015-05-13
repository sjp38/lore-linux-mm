Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id A68026B006C
	for <linux-mm@kvack.org>; Wed, 13 May 2015 10:38:26 -0400 (EDT)
Received: by wicnf17 with SMTP id nf17so58694301wic.1
        for <linux-mm@kvack.org>; Wed, 13 May 2015 07:38:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ym6si33148004wjc.130.2015.05.13.07.38.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 May 2015 07:38:23 -0700 (PDT)
From: Michal Hocko <miso@dhcp22.suse.cz>
Subject: [PATCH 2/2] mmap2: clarify MAP_POPULATE
Date: Wed, 13 May 2015 16:38:12 +0200
Message-Id: <1431527892-2996-3-git-send-email-miso@dhcp22.suse.cz>
In-Reply-To: <1431527892-2996-1-git-send-email-miso@dhcp22.suse.cz>
References: <1431527892-2996-1-git-send-email-miso@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

From: Michal Hocko <mhocko@suse.cz>

David Rientjes has noticed that MAP_POPULATE wording might promise much
more than the kernel actually provides and intend to provide. The
primary usage of the flag is to pre-fault the range. There is no
guarantee that no major faults will happen later on. The pages might
have been reclaimed by the time the process tries to access them.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 man2/mmap.2 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man2/mmap.2 b/man2/mmap.2
index 1486be2e96b3..dcf306f2f730 100644
--- a/man2/mmap.2
+++ b/man2/mmap.2
@@ -284,7 +284,7 @@ private writable mappings.
 .BR MAP_POPULATE " (since Linux 2.5.46)"
 Populate (prefault) page tables for a mapping.
 For a file mapping, this causes read-ahead on the file.
-Later accesses to the mapping will not be blocked by page faults.
+This will help to reduce blocking on page faults later.
 .BR MAP_POPULATE
 is supported for private mappings only since Linux 2.6.23.
 .TP
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
