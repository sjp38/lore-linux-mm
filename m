Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0EE0C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 12:45:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 535E02183F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 12:45:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="RkuGNSEi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 535E02183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A353F8E000F; Wed, 20 Feb 2019 07:45:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BB708E0002; Wed, 20 Feb 2019 07:45:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C43A8E000F; Wed, 20 Feb 2019 07:45:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1418E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 07:45:37 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id v24so10362913wrd.23
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 04:45:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+VnSgGIcvAVUjgW6Yip0Hrcu3Y+bDJDMuLdNyR0jxRw=;
        b=ekf5V/7lwJMCP0xYgEqtySoNFljRKCY+MHeZI481OuQ7V9f8lAu0x4/X3gi9X1+yDj
         3LXJcIhRmk89g1VRQGLCqDiAxSPukUhMi+N3YJEkAg7SXdJ193ETuk/jmllSL/D1bAbj
         RJUbeAiEDV2oswJBxVKhN8nNW21rB9P7+f4dapA7jUmv0J8k+saBs3u+aRbP+84O0Do9
         3sYZAZbv3Zsx9t49SUMlW8oUP7VArdkTKFM9IhAdFhACli7D3BloBsp3MXOXqfPehqhj
         DhTMyjoS7VOdW+AMFHXstAKU7Ivp2k6T/c2PogsQSJR52LkQdTJa1XCobOgX9GbWarra
         ALdQ==
X-Gm-Message-State: AHQUAuZyZEBjC4nSccf72XEWq3VSmuCXCn4FZjhm2Y4vMJnajZqeALS0
	gpvsj/3nslmWhWjbN9fde3HpRBeVlhqZKqNKTf8uaao5PGA3UYTljeocDq2t7MTfZN6+CLkr1rb
	g+mNMK1D3KX5RfX+3S8OUdIDHZNOMdlSrgraoOaT4T+IWzFcgpbALRm0zphPWaLcJ800zAj5Np9
	ymNMb6Yt/rnbmHRW2JI/0PJO4C7goCsSlLqB/q0rKJPLC3AGOJYq/nBCQkJ3ev1MftCvtwEzq/I
	ETXdgC53v/R+6HCJ3PChRYcK19zBo/m2Wb0FxMmVZJTieG1I39Jo0onblbDdvKScAhr6datFlQn
	ukOb+LLaWxeUIeVkgWasPVE1FdRupkW25S1ZYakUT9a4NIHs4Yql8UjroYyZqjWZk4zHW7hdi1I
	a
X-Received: by 2002:adf:f343:: with SMTP id e3mr22906799wrp.205.1550666736494;
        Wed, 20 Feb 2019 04:45:36 -0800 (PST)
X-Received: by 2002:adf:f343:: with SMTP id e3mr22906761wrp.205.1550666735744;
        Wed, 20 Feb 2019 04:45:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550666735; cv=none;
        d=google.com; s=arc-20160816;
        b=I5+6F77IRTiAUyTfkqHA5P6JcDP8iDv4SYtIpE2L+GvNhZwdrI8/EWINPXhU0sOMDV
         9lp7+DBy2Fl2xiDc+eVRyYuoRcAE7+C/fDYDLMS1mFL2dF1slOws88V60JI6tCqX/dEY
         PEGB8QoryYyEWxBzazrMtKOGX4ensBhqzBY+cfuKJGXyLlNH2wdj1KHxwpZSG9OlXZBL
         NHB2/4LzPt4xNRw2Zow5TE6u81otjgj+uL8e6OuMPhagTAQ6vE3muw72LNT5ViMifp3w
         a9zfN1mP/9r6k1FmL4P/mY6i1wMFbBpg+1jP9g2VfrU8QC2YAffwVqF6GerruNDrX1FG
         9N2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=+VnSgGIcvAVUjgW6Yip0Hrcu3Y+bDJDMuLdNyR0jxRw=;
        b=aSBh7CebrqmWCf3HoailUhdX9qVCwXR6S0KQVCsEsx4fljoQOXvUqSPHXrhsetZ8bm
         WuchVqp+0sMMMOd0mnpd7ctKQT28B4RMrKiNhim2K2i7FccQ7qHcUt7OaEGVhXS915FS
         3bhJvRPGyhs9Kv+F37Fo1viA+XEcysHgkKVdAaqYlvcy3kManJ18ey2CgS3itjFi4G7C
         ahER6fgr4oMdPyKmBcdIBu6DIGj78pXdBTixdT47+tvjT4z+7RCnSa6agjpzr3aRNt2Q
         glLVnKjuvHoFMPpD3KwT+bN7QTmprE6e819XP3Lt3E5s5IYzDgMXr5GQOIIM7q2wKorB
         RxBw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=RkuGNSEi;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d1sor10015706wrp.39.2019.02.20.04.45.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 04:45:35 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=RkuGNSEi;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=+VnSgGIcvAVUjgW6Yip0Hrcu3Y+bDJDMuLdNyR0jxRw=;
        b=RkuGNSEiWiBLUh5xUgWCC7aRfo5c8cmVpDx8tczf3SsCt/JNp7bl3CEPAZ6bIuphr6
         0qKGZlUEZX3FmSKQMud3QrYDhZGWbFY6JJ9gUXazEMSCQQNUiJJf32ojxJEj+xg1L+Tn
         zC9QKnEJByoPIgtwi7RtLJtG/4uVYgPOGXtZOP5AZsYJtPUVWBch17nA+JuMjTYAo0CW
         Auv5Lb9zfCy/GLO80qQIv+HIAK7/5Q1qIqeL00en4QDK0xASfoSHpM8wL4tWvvgpkb6c
         xq93SHrk6KiU4c26SCT4nfkCwzOhkzWfCNaV+nzb0aIBvJcOK6l0ln0jviTh/RXYY9AT
         C31A==
X-Google-Smtp-Source: AHgI3IZCQAIZAKtPesdCePJTdMeBXMjkB4yKP6E02FjEZNJbh7DAEvbOIwdxq/2SRWXrl5Daqdq8dA==
X-Received: by 2002:adf:9d1d:: with SMTP id k29mr23582142wre.211.1550666735197;
        Wed, 20 Feb 2019 04:45:35 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id f196sm6378889wme.36.2019.02.20.04.45.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 04:45:34 -0800 (PST)
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
Subject: [PATCH 2/4] kasan, slab: fix conflicts with CONFIG_HARDENED_USERCOPY
Date: Wed, 20 Feb 2019 13:45:27 +0100
Message-Id: <9a5c0f958db10e69df5ff9f2b997866b56b7effc.1550602886.git.andreyknvl@google.com>
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

Similarly to 96fedce2 ("kasan: make tag based mode work with
CONFIG_HARDENED_USERCOPY"), we need to reset pointer tags in
__check_heap_object() in mm/slab.c before doing any pointer math.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/slab.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/slab.c b/mm/slab.c
index 78eb8c5bf4e4..c84458281a88 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4408,6 +4408,8 @@ void __check_heap_object(const void *ptr, unsigned long n, struct page *page,
 	unsigned int objnr;
 	unsigned long offset;
 
+	ptr = kasan_reset_tag(ptr);
+
 	/* Find and validate object. */
 	cachep = page->slab_cache;
 	objnr = obj_to_index(cachep, page, (void *)ptr);
-- 
2.21.0.rc0.258.g878e2cd30e-goog

