Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 368D16B0070
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 19:42:51 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id k14so18556710wgh.9
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 16:42:50 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hs6si20008410wjb.68.2014.12.02.16.42.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 16:42:50 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/2] posix_fadvise.2: Document the behaviour of partial page discard requests
Date: Wed,  3 Dec 2014 00:42:47 +0000
Message-Id: <1417567367-9298-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1417567367-9298-1-git-send-email-mgorman@suse.de>
References: <1417567367-9298-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

It is not obvious from the interface that partial page discard requests
are ignored. It should be spelled out.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 man2/posix_fadvise.2 | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/man2/posix_fadvise.2 b/man2/posix_fadvise.2
index 25d0c50..07313a9 100644
--- a/man2/posix_fadvise.2
+++ b/man2/posix_fadvise.2
@@ -144,6 +144,11 @@ A program may periodically request the kernel to free cached data
 that has already been used, so that more useful cached pages are not
 discarded instead.
 
+Requests to discard partial pages are ignored. It is preferable to preserve
+needed data than discard unneeded data. If the application requires that
+data be considered for discarding then \fIoffset\fP and \fIlen\fP must be
+page-aligned.
+
 Pages that have not yet been written out will be unaffected, so if the
 application wishes to guarantee that pages will be released, it should
 call

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
