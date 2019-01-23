Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 17EEE8E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 15:33:31 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id ay11so2282154plb.20
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 12:33:31 -0800 (PST)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id t184si19573706pfb.22.2019.01.23.12.33.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 12:33:29 -0800 (PST)
From: Vineet Gupta <vineet.gupta1@synopsys.com>
Subject: [PATCH v2 3/3] bitops.h: set_mask_bits() to return old value
Date: Wed, 23 Jan 2019 12:33:04 -0800
Message-ID: <1548275584-18096-4-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1548275584-18096-1-git-send-email-vgupta@synopsys.com>
References: <1548275584-18096-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-snps-arc@lists.infradead.org, linux-mm@kvack.org, peterz@infradead.org, mark.rutland@arm.com, Vineet Gupta <vineet.gupta1@synopsys.com>, Miklos Szeredi <mszeredi@redhat.com>, Ingo Molnar <mingo@kernel.org>, Jani Nikula <jani.nikula@intel.com>, Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>

| > Also, set_mask_bits is used in fs quite a bit and we can possibly come up
| > with a generic llsc based implementation (w/o the cmpxchg loop)
|
| May I also suggest changing the return value of set_mask_bits() to old.
|
| You can compute the new value given old, but you cannot compute the old
| value given new, therefore old is the better return value. Also, no
| current user seems to use the return value, so changing it is without
| risk.

Link: http://lkml.kernel.org/g/20150807110955.GH16853@twins.programming.kicks-ass.net
Suggested-by: Peter Zijlstra <peterz@infradead.org>
Cc: Miklos Szeredi <mszeredi@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Jani Nikula <jani.nikula@intel.com>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Reviewed-by: Anthony Yznaga <anthony.yznaga@oracle.com>
Acked-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 include/linux/bitops.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/bitops.h b/include/linux/bitops.h
index 705f7c442691..602af23b98c7 100644
--- a/include/linux/bitops.h
+++ b/include/linux/bitops.h
@@ -246,7 +246,7 @@ static __always_inline void __assign_bit(long nr, volatile unsigned long *addr,
 		new__ = (old__ & ~mask__) | bits__;		\
 	} while (cmpxchg(ptr, old__, new__) != old__);		\
 								\
-	new__;							\
+	old__;							\
 })
 #endif
 
-- 
2.7.4
