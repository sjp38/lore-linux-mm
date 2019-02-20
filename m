Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B2BDC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 12:45:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBC1C2183F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 12:45:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="suBfKTep"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBC1C2183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26DB48E0011; Wed, 20 Feb 2019 07:45:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F2DA8E0002; Wed, 20 Feb 2019 07:45:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09DBA8E0011; Wed, 20 Feb 2019 07:45:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 95BBA8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 07:45:40 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id m7so10564027wrn.15
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 04:45:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5gXqyUm+MzCzLQAxtw4op9wk2PcKOTUHWZhWJctI3Io=;
        b=Sa6dccvlkcrbQSYUFlLHTRU7bWWNLMV2CyWM4qWQNKQZth7+r/yVr9DOo3q5SfXpVN
         IDltiW9uKv5Ka3JGO9aLbvTT6YSdrSC/iyLQbaRFFYE+U+RVcnQ3A5WX/2JCR8LB667G
         TBkUVwP1h4Dk+UFk9vIU6keMvl87/r3/IdwOwR+6Z8XC/Nc7FucYj+//uzmMiX/8GNdb
         zsASCQCYA6O7RToc80qZOd/ufnEYPIu0EyP2WqYMlVv0bxtnXS8t7sG4nCTWswiH9ogW
         17W6nzR6HJQjg8LqUKdVByDPeyHBipdMUMTd80w4sGMlze72F4eE6goNdmFdj20AEafL
         iJVQ==
X-Gm-Message-State: AHQUAua+hmNVpkLKCiNyz10a4Pad0Kx0hjOwRkPdcmEdSdl/f2j4zcO3
	swQU3ltzJ49HqcZsbd6kkDTBNo+1QnSahvvuehQ3o3uQ78iun9RPS6OC0oRg2EQKw9HY8HD2p6r
	bZEXnqOicKolj54UwXHih9bZTxTyGeCzbn8ws0hnDQP0mW10licgpWHfte0mUeTJQsuh83nDr/V
	wkSVQKcG0v6hm6MoRlOdhN+M2tdpPXXP8kLpuvXXG1JytSptLCYDF6aAjkvE7q60YM/qeCo8StI
	R83eCXR5s6dAOV14RzLHKqFRxfUWdPNG3SI+u8+bXxxCi1gYfjeW491czLJbGp2NXsXbcLk2xNl
	saoFJjVuq5+gN+Bhxi+UkkQb7Yuf8Tzoz2aTKJh/oXmIKhzhVWEKG2+nxPnSlrcTWgU7dZa+6h3
	J
X-Received: by 2002:adf:f5d0:: with SMTP id k16mr9177725wrp.325.1550666740115;
        Wed, 20 Feb 2019 04:45:40 -0800 (PST)
X-Received: by 2002:adf:f5d0:: with SMTP id k16mr9177680wrp.325.1550666739187;
        Wed, 20 Feb 2019 04:45:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550666739; cv=none;
        d=google.com; s=arc-20160816;
        b=y9kcCsIVGKvNxql41tcI0nsITAM6Blr/QguDjp2fbIP6eNpI9euwaw8neITFQ0Oe97
         mdcj2kIRqcvVykg0nX0P6DEgq8cN6Tmn0Gma59i3LNhx1iCxcptk7Qg3322Rm6ZMfpET
         CFCyaLXkXPV9N0t8tOEBQr412K0b2oQJULU0TISNoDPgdVEHmsUE/Z/A79Pwe3Mv6rKT
         TZa7qIqroQaU3FiRLU1lPKtrEInL62o7TzHH9ISMHZzBnANXnRyic0tizFuckbJMeOyG
         r1VBlrRCm3F7g4ef66A+6cRrNGDch48NF7L3ROOoUyFCb4nMi7MieKY0gubysUy7AhTl
         9UAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=5gXqyUm+MzCzLQAxtw4op9wk2PcKOTUHWZhWJctI3Io=;
        b=BfSecqYgXSh1+DO4A//29rN8zvz8qVSkYZPvLOQTWAo+wI/XZ1NIrlQNDSJm+7Tff9
         7CtrkcVWuhOpSCqin4f2il/M/PxOYxeOe8eukVHZr9kfmPn2dCbKVKEENEEoQdZiNQUq
         rRv9YZCm6Ev8lWXnJTvZ0kjdL6xfHH0gxsEV4Fc6iAyYD2BqfCLa5stemonNwFzxlwdo
         HLpCfoA/z96BkU0MIbEXOYI1RUgGn+E5SOAxPRq9VmqWCD2B5LFH4DQ/iEmZHatUVaN+
         HEEhF0seX4rzz8YT0B/CeZLDYSOfpA9V0hKztk0A0h+SghouqgBBybktOayNy0+aYm1r
         /PUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=suBfKTep;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o13sor13122034wru.8.2019.02.20.04.45.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 04:45:39 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=suBfKTep;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=5gXqyUm+MzCzLQAxtw4op9wk2PcKOTUHWZhWJctI3Io=;
        b=suBfKTephxFP+rdqh9QzczLioDwgZsNZldG4s1nh7aGfk3wEFGpQ9PdSDS4yHWIosW
         CMz20JglknTgOIjfFaO6roeZJLwS6nLkve4A+CU0cKn5/n6inOXbO8dUd/xaDNCAek4F
         tDeqCMVMbJKNwhs6EecZjBmaYm/Yp05RlUwygtOpM1f2LSgsjrBjZZoGHSB1LSNAGCK2
         4uf9Fz5a1JhRTnz3HG1hCsgB9zV/ddcZyEYrtEcLI9hJKqzm/UlPsvhTyJm26nhpFmp8
         TqGNgiwm6KIeqMLVLNEIJW0jx+xZ8bnGjcVsAnKBF2yR5LJTxVtp1R2NZmooih+lSqjF
         OXKw==
X-Google-Smtp-Source: AHgI3IaJRu9aCw0ZFP+B3NmgwPZu8apybwshVX27xoQP+MZRDazR203qivIq48ZC/KUV1m1/OgKHcg==
X-Received: by 2002:adf:de83:: with SMTP id w3mr23532379wrl.56.1550666738752;
        Wed, 20 Feb 2019 04:45:38 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id f196sm6378889wme.36.2019.02.20.04.45.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 04:45:37 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 4/4] kasan, slab: remove redundant kasan_slab_alloc hooks
Date: Wed, 20 Feb 2019 13:45:29 +0100
Message-Id: <4ca1655cdcfc4379c49c50f7bf80f81c4ad01485.1550602886.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.rc0.258.g878e2cd30e-goog
In-Reply-To: <9c4c3ce5ccfb894c7fe66d91de7c1da2787b4da4.1550602886.git.andreyknvl@google.com>
References: <9c4c3ce5ccfb894c7fe66d91de7c1da2787b4da4.1550602886.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

kasan_slab_alloc() calls in kmem_cache_alloc() and kmem_cache_alloc_node()
are redundant as they are already called via slab_alloc/slab_alloc_node()->
slab_post_alloc_hook()->kasan_slab_alloc(). Remove them.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/slab.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 4ad95fcb1686..91c1863df93d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3547,7 +3547,6 @@ void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 {
 	void *ret = slab_alloc(cachep, flags, _RET_IP_);
 
-	ret = kasan_slab_alloc(cachep, ret, flags);
 	trace_kmem_cache_alloc(_RET_IP_, ret,
 			       cachep->object_size, cachep->size, flags);
 
@@ -3637,7 +3636,6 @@ void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 {
 	void *ret = slab_alloc_node(cachep, flags, nodeid, _RET_IP_);
 
-	ret = kasan_slab_alloc(cachep, ret, flags);
 	trace_kmem_cache_alloc_node(_RET_IP_, ret,
 				    cachep->object_size, cachep->size,
 				    flags, nodeid);
-- 
2.21.0.rc0.258.g878e2cd30e-goog

