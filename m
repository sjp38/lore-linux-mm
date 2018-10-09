Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 60EEA6B0010
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 02:57:58 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id r20-v6so212488ljj.1
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 23:57:58 -0700 (PDT)
Received: from forwardcorp1g.cmail.yandex.net (forwardcorp1g.cmail.yandex.net. [87.250.241.190])
        by mx.google.com with ESMTPS id x9-v6si22320785ljh.189.2018.10.08.23.57.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Oct 2018 23:57:56 -0700 (PDT)
Subject: [PATCH manpages] madvise.2: MADV_FREE conflicts with mlock,
 MADV_WIPEONFORK works with anon HugeTLB
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 09 Oct 2018 09:57:52 +0300
Message-ID: <153906827290.150228.5223641064732995626.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: linux-man@vger.kernel.org, linux-mm@kvack.org

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 man2/madvise.2 |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/man2/madvise.2 b/man2/madvise.2
index c3b894d8a6f7..f0b0a43609da 100644
--- a/man2/madvise.2
+++ b/man2/madvise.2
@@ -468,6 +468,7 @@ is not a valid.
 .B EINVAL
 .I advice
 is
+.BR MADV_FREE ,
 .B MADV_DONTNEED
 or
 .BR MADV_REMOVE
@@ -490,7 +491,7 @@ is
 .BR MADV_FREE
 or
 .BR MADV_WIPEONFORK
-but the specified address range includes file, Huge TLB,
+but the specified address range includes file,
 .BR MAP_SHARED ,
 or
 .BR VM_PFNMAP
