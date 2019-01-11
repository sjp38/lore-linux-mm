Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id AD3F38E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 11:14:25 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id 2-v6so3868923ljs.15
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 08:14:25 -0800 (PST)
Received: from bastet.se.axis.com (bastet.se.axis.com. [195.60.68.11])
        by mx.google.com with ESMTPS id k20-v6si73878512ljj.32.2019.01.11.08.14.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 08:14:23 -0800 (PST)
From: Vincent Whitchurch <vincent.whitchurch@axis.com>
Subject: [PATCH] Documentation/sysctl/vm.txt: Fix drop_caches bit number
Date: Fri, 11 Jan 2019 17:14:10 +0100
Message-Id: <20190111161410.11831-1-vincent.whitchurch@axis.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: corbet@lwn.net
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com, Vincent Whitchurch <rabinv@axis.com>, Matthew Wilcox <willy@infradead.org>

Bits are usually numbered starting from zero, so 4 should be bit 2, not
bit 3.

Suggested-by: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Vincent Whitchurch <vincent.whitchurch@axis.com>
---
 Documentation/sysctl/vm.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 187ce4f599a2..6af24cdb25cc 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -237,7 +237,7 @@ used:
 	cat (1234): drop_caches: 3
 
 These are informational only.  They do not mean that anything is wrong
-with your system.  To disable them, echo 4 (bit 3) into drop_caches.
+with your system.  To disable them, echo 4 (bit 2) into drop_caches.
 
 ==============================================================
 
-- 
2.20.0
