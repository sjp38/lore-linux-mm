Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 849586B0069
	for <linux-mm@kvack.org>; Sun, 31 Dec 2017 07:38:07 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a74so32580461pfg.20
        for <linux-mm@kvack.org>; Sun, 31 Dec 2017 04:38:07 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id h2si31731217pli.718.2017.12.31.04.38.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 31 Dec 2017 04:38:06 -0800 (PST)
Date: Sun, 31 Dec 2017 20:37:10 +0800
From: kbuild test robot <lkp@intel.com>
Subject: [RFC PATCH] ksm: fasthash() can be static
Message-ID: <20171231123710.GA117422@lkp-hsx03>
References: <20171229095241.23345-1-nefelim4ag@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171229095241.23345-1-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, leesioh <solee@os.korea.ac.kr>, Andrea Arcangeli <aarcange@redhat.com>


Fixes: 038adb295b0c ("ksm: replace jhash2 with faster hash")
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 ksm.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index ac2aa49..1c2619cbc3 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -374,7 +374,7 @@ static void __init choice_fastest_hash(void)
 	kfree(page);
 }
 
-unsigned long fasthash(const void *input, size_t length)
+static unsigned long fasthash(const void *input, size_t length)
 {
 	unsigned long checksum = 0;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
