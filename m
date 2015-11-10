Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9D3116B0038
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 08:33:38 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so234996207pab.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 05:33:38 -0800 (PST)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id y1si5210251par.57.2015.11.10.05.33.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 05:33:37 -0800 (PST)
Received: by pacfl14 with SMTP id fl14so10155381pac.1
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 05:33:37 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 0/3] tools/vm: trivial fixes
Date: Tue, 10 Nov 2015 22:32:03 +0900
Message-Id: <1447162326-30626-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,
A set of simple tweaks to tools/vm: fix Makefile and make
gcc happier.

Sergey Senozhatsky (3):
  tools/vm: fix Makefile multi-targets
  tools/vm/page-types: suppress gcc warnings
  tools/vm/slabinfo: update struct slabinfo members' types

 tools/vm/Makefile     |  8 ++++----
 tools/vm/page-types.c |  5 +++--
 tools/vm/slabinfo.c   | 12 +++++++-----
 3 files changed, 14 insertions(+), 11 deletions(-)

-- 
2.6.2.280.g74301d6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
