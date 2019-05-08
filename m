Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00424C004C9
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 00:39:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4EF620C01
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 00:39:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="P9wByt6X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4EF620C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FD526B0003; Tue,  7 May 2019 20:39:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4AE126B0005; Tue,  7 May 2019 20:39:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39BFC6B0006; Tue,  7 May 2019 20:39:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6696B0003
	for <linux-mm@kvack.org>; Tue,  7 May 2019 20:39:06 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id n39so21393418qtn.0
        for <linux-mm@kvack.org>; Tue, 07 May 2019 17:39:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=v9eQGAXN/pUrwyhsEw4eGQ0SnWi81FsI3CN7zGHdMUY=;
        b=BDW7wnRPURWyTV7HoSoRLTU63dIhtau9WyDpzXUdj13s83/JLNo0AGXfL1EFTOL2Sv
         brKhRrlnpfctiAlYv2nh2/CcKjnR1ptR/lrZkXkT4pwzKQQA+TC6dgdDjXNgUcbqsayp
         W0a1EB6iP9nkFVJCaCzyM5Bc5wtWgPWG6ZvrTRJf37/wozAh+bbZxdD91f1BCmk5HMgV
         XOJRStJt3yN1gE4u/UPDG0doT3FR09XR/TL9rjeW9wwltA0f4u1aZSoZzGVcElwHAHeW
         B7JZcTKtr0iseMdxXEUjp0o0sJFSbRTmk8+LWf4fanGBI+2ekBnG5KoqeDRhVn959tOZ
         uTsQ==
X-Gm-Message-State: APjAAAUc3b/+NfxkLsIydi6ujb7fBhwneMWpC2Q+9mwqb97jCQX+9kFs
	nOPSwwUIudhP5NSXCz86flIMzOM5u2Cts49xdDZM9f5hsR21jBV/fyl5CVr5wPC7LHUGZO4d+RC
	8OfKstMKR7Hyz75jmgX30+815PCoDu3wAQll2boJSScfqnblEo0O57YizgIFNV/xFwg==
X-Received: by 2002:a37:49ce:: with SMTP id w197mr26064382qka.330.1557275945795;
        Tue, 07 May 2019 17:39:05 -0700 (PDT)
X-Received: by 2002:a37:49ce:: with SMTP id w197mr26064356qka.330.1557275945154;
        Tue, 07 May 2019 17:39:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557275945; cv=none;
        d=google.com; s=arc-20160816;
        b=rGKWkzYsLC35uN5XHQlpt1EpkfEKd+zreiJEnmuWp3+pxx8JrbzN3LA+oBA0/NQK/Q
         awWfAebloKhags7///OqcjRoGgnHcdgRiWCl0cpaYowF2nvi40UjPkNDnoQuU2TkMp2U
         VoztzlBilGdOOXrN/+KnJkwoXGo+78pxLngyB4zg64N5YHBoPwsKp5RoQYuoRQs26pJ8
         IS0clDEFZK2MxG/lPPxZ1t5GxZpJKhH84hm7zoLmgObbxVVCe6MET2GxJWWkj45GYcmF
         4q1fHZ33qBRP19q92Jxc2FByVr3gPSKapaOi+gaH7dkWd15mEvwblTKEsZyXo6CNdrns
         0Qag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=v9eQGAXN/pUrwyhsEw4eGQ0SnWi81FsI3CN7zGHdMUY=;
        b=L6KOd6j5qF2EhvJWWuNnp4TkeYTzPq+S8A73x3DgbOoj+P+BcGwAFwnjYztSxEbPVT
         n8+8uecGjAhh0fH8TrjFUB7FCFAZJrRzkhEe9/FbpeI77eK/KVKTDzduGrf+vAaHLY2Z
         nwlS/A476EVLCqg/UaY068KBk7lL3J/oYqKcZkp2j5xX97BzFc1Q0dOXzf7hzyG34CUO
         a6YIdmaHRMlfGE4iv6FDUxfU11EF1Z3726AJiY1gAQfNSLYU16Q/fukSMutwPfL5VI9N
         NT4S4Cw5SHtTxbRKM7tB6CjfohFstuo1AymkEfEyS1pScV+PeTW7kPFSM97wzmitG8+p
         c41Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=P9wByt6X;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n185sor8619898qkc.21.2019.05.07.17.39.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 17:39:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=P9wByt6X;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=v9eQGAXN/pUrwyhsEw4eGQ0SnWi81FsI3CN7zGHdMUY=;
        b=P9wByt6X7/7EYnOVIL+L4niq5xhOsA7fNdy5JhqzkC2EDOnh6kD8+oRsJPsdP6yTAn
         hLOOu+3ZGncE0jEbvAgByRNnn70mDcYt296iT4kYbIIRgE08hQwnom7YGmfQFAlW7PuJ
         AVzyFOjo2yMMctzMlPy4UQ2Fmb9VpcnsvuYK+LZq8s+L4PYPPbPbnkUHyECTP0kIK0dp
         QEKXyP6+DptIl+Lf3PfBMTTdDKxsia6+spQ8TnQAz+BbJ3V3To/mQEbKLRPX/n61dog3
         aLGMxm+ZD71/nRb/gNTB/S1yrclRU6Q4FfuaDiG8F82F17ceo/iPfDSsqiOwQ5uC/C6P
         iKNA==
X-Google-Smtp-Source: APXvYqx3wh7S/VSM6RE3kBIPQ5Eso3w/I/f0YhknfHS271wzjV4Ff5Ktu4I1WFAP3qSFDXkbyyk1vw==
X-Received: by 2002:ae9:d844:: with SMTP id u65mr25749828qkf.310.1557275944782;
        Tue, 07 May 2019 17:39:04 -0700 (PDT)
Received: from ovpn-121-162.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id o37sm8153984qte.55.2019.05.07.17.39.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 17:39:03 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	catalin.marinas@arm.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] slab: skip kmemleak_object in leaks_show()
Date: Tue,  7 May 2019 20:38:38 -0400
Message-Id: <20190508003838.62264-1-cai@lca.pw>
X-Mailer: git-send-email 2.20.1 (Apple Git-117)
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Running tests on a debug kernel will usually generate a large number of
kmemleak objects.

  # grep kmemleak /proc/slabinfo
  kmemleak_object   2243606 3436210 ...

As the result, reading /proc/slab_allocators could easily loop forever
while processing the kmemleak_object cache and any additional freeing or
allocating objects will trigger a reprocessing. To make a situation
worse, soft-lockups could easily happen in this sitatuion which will
call printk() to allocate more kmemleak objects to guarantee a livelock.

Since kmemleak_object has a single call site (create_object()), there
isn't much new information compared with slabinfo. Just skip it.

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/slab.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/slab.c b/mm/slab.c
index 20f318f4f56e..85d1d223f879 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4285,6 +4285,15 @@ static int leaks_show(struct seq_file *m, void *p)
 	if (!(cachep->flags & SLAB_RED_ZONE))
 		return 0;
 
+	/*
+	 * /proc/slabinfo has the same information, so skip kmemleak here due to
+	 * a high volume and its RCU free could make cachep->store_user_clean
+	 * dirty all the time.
+	 */
+	if (IS_ENABLED(CONFIG_DEBUG_KMEMLEAK) &&
+	    !strcmp("kmemleak_object", cachep->name))
+		return 0;
+
 	/*
 	 * Set store_user_clean and start to grab stored user information
 	 * for all objects on this cache. If some alloc/free requests comes
-- 
2.20.1 (Apple Git-117)

