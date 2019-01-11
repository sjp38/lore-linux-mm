Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA01DC43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 00:26:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E2F3206B7
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 00:26:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=synopsys.com header.i=@synopsys.com header.b="arThAiTa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E2F3206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=synopsys.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21EAD8E0006; Thu, 10 Jan 2019 19:26:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CC6B8E0001; Thu, 10 Jan 2019 19:26:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E5878E0006; Thu, 10 Jan 2019 19:26:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C3F628E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 19:26:52 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id t26so7341521pgu.18
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:26:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=tONnOyuB2lpOpSvJpJpHHz+Hr9EbTu2vK/iB0IQUkdQ=;
        b=W4NabjbInN9KshHpk+nap8RYIi4ooMSzvbx2SKlx93HXrvGw5ZCqHQZa09LmQuuz34
         7QV7QTNk8yy3KyVLF8KkjKZ47B7mPQvHmJ+dGbScZU3bjyIU4qHnReCGzMCIijhdcXJs
         FwLj+xuA2qVjLXZkUgblEp0wPwXsTtSWfl2MRi1P19iuYX2YoO40An+hdC0+dIVmn5FP
         SPKoSs+FjAkYJRq+9OzQJGte3SKrYQ7PlEGsuuytVtryxBViXy7qTacjX6Ws5gaON62b
         XMaQAgbUQ0vDw8X4wLWGN6Mc/aJecdCmBJnFQ+aHnQ/TQcSduyV5PdVgIhGD6Rj0jbJv
         I8XA==
X-Gm-Message-State: AJcUukdC8AjuRL+13GPh7/Mx4Y7e3ip9TihET97YTUMpzAZt0qlItrDM
	PUE27CfmBsIpgea/pTFyeIp/saNpgqU+RE1zokoSwNnZpUFF14dKWtaclOrzHy1UaPNPk1IPwIn
	efWLDqSqSmCxF3lOZpxd89Ne+BVL722ZP1sUvOCWM+xrIZU7GpWooW11zjL3eGo8uHA==
X-Received: by 2002:a62:399b:: with SMTP id u27mr12781368pfj.181.1547166412458;
        Thu, 10 Jan 2019 16:26:52 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4C+Y4CSE9ZT1qaANaxzh8RCnDltFE5I9VwzCsdKs31J+BasHDsAr825S4PzL3dhJ7iRMds
X-Received: by 2002:a62:399b:: with SMTP id u27mr12781339pfj.181.1547166411811;
        Thu, 10 Jan 2019 16:26:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547166411; cv=none;
        d=google.com; s=arc-20160816;
        b=fFOlfx05TziAVfsXBjvX7ZOzUDx3rSRc7coECcogWEQEg0ow8offhBPndyWpOOnKBL
         G2wqokqlKXg0xKEiytu/uz137lmYD7LcleUu9K50jpO79WRoz7J6yjPCylOmTLQVIpkx
         vZfmk0f+j20fJzYiIYzVxxaWgUYP/6PYbZppEn9YuIt+wmpq5Z6mBshVRNGUa5O5lr+/
         Atpek8BkxCC/RsOhgu0EpPjGZwvF3xY1vROtgLKTDjtOStoHH3Zr444ie233peYoMTph
         QknfHwIkFQ7cvUQ7GOUVifzsa8T49yV7xNAvocXc6cnBsO5CCihiNGvigiss8fo3y7qK
         yoyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:dkim-signature;
        bh=tONnOyuB2lpOpSvJpJpHHz+Hr9EbTu2vK/iB0IQUkdQ=;
        b=pBD1MD6t2xTI1FHlalnieJqY4WSWZ8wid9WjUubrl7L+VMhyI3yWMvI3xSd3mFUT7T
         nMle0JK6Ur8eG7u9EgPf4zFnEsVR5r2tLvQ8iEa9jeqTFprK6thQV4V8nUhzA2IwL0Le
         dVJ1UsrffjqBEYA4YVvWtnImHDocJoGyG9e3KFZr5ehJWk4f10qNbgTqTHYu56iD11TM
         bK8rybWaOjIsRVoUbpbSWaIOrrvY2St1QmfZ5uxl/F5IqgIUCZe72F6nTkQh1ZR+F8bv
         bJ+XAexJ3aaab9ZldvYf8ReXcdEBh4hB/sT2tfetgXEUd08e0xcA08Bzxv6wBJY3cFgT
         xPUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=arThAiTa;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.60.111 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id y6si51191750pll.384.2019.01.10.16.26.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 16:26:51 -0800 (PST)
Received-SPF: pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.60.111 as permitted sender) client-ip=198.182.60.111;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=arThAiTa;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.60.111 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from mailhost.synopsys.com (mailhost2.synopsys.com [10.13.184.66])
	by smtprelay.synopsys.com (Postfix) with ESMTP id 99A9E10C06EF;
	Thu, 10 Jan 2019 16:26:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=synopsys.com; s=mail;
	t=1547166411; bh=MTd8hhL8+Yrd4J5zf9O3w4pCpQ1E6m+yK5NdRUgT2As=;
	h=From:To:CC:Subject:Date:In-Reply-To:References:From;
	b=arThAiTak6xtjdEQqT6DCcRORRxKOtPKlTZOKV/ZQLPMuplgeRxm5smd9cNlASzX6
	 WDjzrQiDGNcYPSXlgN9OrHbfPrCEr9W0qGCRLpKziLfoOP/Vd/z9oRiYFMxP2PCVRN
	 gugo+ZaJnTuhaJcpjCD9DmLCjdPzWf7/WO+qK75/V17XO5DTYREMHipU/BfRqD0UO+
	 +a140xT9WNax6dENNdLpzceFqSXE1jnIjX1c3yf3RUgFSUjgYpy2KFJazxEWclrz5e
	 EBwuQesuig/h/PxG9jewFe1dQpWDSobr/TZkQPUVlZ4G2nDUBiQQmtb5BawiqzBhFu
	 /nmVMgepWt7Hg==
Received: from US01WXQAHTC1.internal.synopsys.com (us01wxqahtc1.internal.synopsys.com [10.12.238.230])
	by mailhost.synopsys.com (Postfix) with ESMTP id 63E3B39F7;
	Thu, 10 Jan 2019 16:26:50 -0800 (PST)
Received: from IN01WEHTCA.internal.synopsys.com (10.144.199.104) by
 US01WXQAHTC1.internal.synopsys.com (10.12.238.230) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Thu, 10 Jan 2019 16:26:50 -0800
Received: from IN01WEHTCB.internal.synopsys.com (10.144.199.105) by
 IN01WEHTCA.internal.synopsys.com (10.144.199.103) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Fri, 11 Jan 2019 05:56:48 +0530
Received: from vineetg-Latitude-E7450.internal.synopsys.com (10.10.161.70) by
 IN01WEHTCB.internal.synopsys.com (10.144.199.243) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Fri, 11 Jan 2019 05:56:50 +0530
From: Vineet Gupta <vineet.gupta1@synopsys.com>
To: <linux-kernel@vger.kernel.org>
CC: <linux-snps-arc@lists.infradead.org>, <linux-mm@kvack.org>,
	<peterz@infradead.org>, Vineet Gupta <vineet.gupta1@synopsys.com>,
	Miklos Szeredi <mszeredi@redhat.com>, Ingo Molnar <mingo@kernel.org>,
	Jani Nikula <jani.nikula@intel.com>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	"Andrew  Morton" <akpm@linux-foundation.org>,
	Will Deacon <will.deacon@arm.com>
Subject: [PATCH 3/3] bitops.h: set_mask_bits() to return old value
Date: Thu, 10 Jan 2019 16:26:27 -0800
Message-ID: <1547166387-19785-4-git-send-email-vgupta@synopsys.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1547166387-19785-1-git-send-email-vgupta@synopsys.com>
References: <1547166387-19785-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Originating-IP: [10.10.161.70]
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111002627.BDn9LwjAmmp0OOUv-tVjNmcVaSZbskje7xnNiyr17Lg@z>

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
Cc: Will Deacon <will.deacon@arm.com>
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

