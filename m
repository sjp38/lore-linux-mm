Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id DB7086B53E4
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 13:11:00 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id y7so1748188wrr.12
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 10:11:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t10sor2202568wmt.1.2018.11.29.10.10.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Nov 2018 10:10:59 -0800 (PST)
From: mhocko@kernel.org
Subject: [PATCH] madvise.2: MADV_FREE clarify swapless behavior
Date: Thu, 29 Nov 2018 19:10:48 +0100
Message-Id: <20181129181048.11010-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: linux-mm@kvack.org, =?UTF-8?q?Niklas=20Hamb=C3=BCchen?= <mail@nh2.me>, Shaohua Li <shli@fb.com>, linux-man@vger.kernel.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Since 93e06c7a6453 ("mm: enable MADV_FREE for swapless system") we
handle MADV_FREE on a swapless system the same way as with the swap
available. Clarify that fact in the man page.

Reported-by: Niklas Hambüchen <mail@nh2.me>
---
 man2/madvise.2 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man2/madvise.2 b/man2/madvise.2
index eb82a57a1cf5..d9135a05a1c2 100644
--- a/man2/madvise.2
+++ b/man2/madvise.2
@@ -403,7 +403,7 @@ The
 operation
 can be applied only to private anonymous pages (see
 .BR mmap (2)).
-On a swapless system, freeing pages in a given range happens instantly,
+Prior to 4.12 on a swapless system, freeing pages in a given range happens instantly,
 regardless of memory pressure.
 .TP
 .BR MADV_WIPEONFORK " (since Linux 4.14)"
-- 
2.19.1
