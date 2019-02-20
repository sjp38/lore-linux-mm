Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A7ACC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 20:41:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E44C320880
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 20:41:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="Qw7lFkV8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E44C320880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43A818E0030; Wed, 20 Feb 2019 15:41:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E8398E0002; Wed, 20 Feb 2019 15:41:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B0A58E0030; Wed, 20 Feb 2019 15:41:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C5EB48E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 15:41:07 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id d8so10470613edi.6
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 12:41:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=S6f5ltKfmmbc/Y9tRkkr1Gep0E2+84qSjXYQazP6FGY=;
        b=QXEZTgfxF2KbtPGg6mYWeavEqF3P6Pqz+7BzFMKuE47cMs/+E/Dv6ACimR4YEfndUB
         2N6eakgL76OPy22emp+n2oZkHYq9OtCUVwhmWxoNg8WOCOmeRBuvjMCkK/1qWRXCZ0A0
         HBiOITu7ZtE4mPCHje8uQgU8uKjLrxf5ehCf5KWrP0lXH+0ogzFGOR+4PCwzQm+eDCdg
         MkHzRgy7Exmh4v5ArjEkuldLCPQRZvtjSSeoEUm98/FNoOXkpHS/Xu71gYnPrvt/HDxo
         ZawQQm6vKTiMLD3sutc0knL7jucFPERO9AuLed8yxKlcS54hIH22Ujm7ZFlGIkcTvGZ2
         L71Q==
X-Gm-Message-State: AHQUAuYQ8rSAI37STIzDJc6/tDHeUoEX701+nj53onUTYScFYs7B7AOS
	Gd5sBUiI1xu9Kc3hvZowPBFx4thXBZtiLFJ8SbJfKjTgsFGifvq6Vw9qp/rvffUpG6DLaHggpGC
	VK4t2AROxnr/97yT4nDogxg+EbRpaPnoOQp9pl+bNBgZ5Q5FEb1UCGWzIRRkmYmPSsfF3csOx9+
	8kr3xPYU0Aw9HoHsX99ROeywiulwt+rhRzBKfZUl2UyB2ltLFYiSxGjl4tfQkb2zYT1YOQ7bjfs
	Fkh4z2f5HNOBgl+X8WgKOxknRAnkGT/WBXV9psIRSwTbH8+pc+mQW+2Loz9dr9x3VSZDXAXT4XZ
	Gj7afc6z/wwqcGcWcu+d5ML0As7EuZ/14j/UkaENTriNACpP9NkZJTP/N8hteN7RL0eCfon4kUG
	C
X-Received: by 2002:a17:906:911:: with SMTP id i17mr24678355ejd.187.1550695267064;
        Wed, 20 Feb 2019 12:41:07 -0800 (PST)
X-Received: by 2002:a17:906:911:: with SMTP id i17mr24678327ejd.187.1550695266105;
        Wed, 20 Feb 2019 12:41:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550695266; cv=none;
        d=google.com; s=arc-20160816;
        b=offXpjstheeo2j8G3DRp7YMfmbUMFTFsd7VQxKshTMPKap7rPlUDsgFhWP62QoqQPZ
         W6kk+D5HRPdwy3EUa7SKT+QUGZE71h6tdmyUGXdqWGphL8CFXXEocyx5Gg+E9iLxWQ98
         T8iUPDTxQWde/AzV/SsqZI7mZCswU4CbUqbVdQVQcihGdJlhjNh3sVf55OR5FBFKaCJ2
         ce8jToh/FMqU5A3owBUbib6gBvjxRG8TDUvuD7hWNZA8ZtX2qSXc49P6GtJgUkOPf2NH
         kimIiTmNUfwiMaTdC2do+fN0Nz/Xwlb4YC4xUzHV6GtWJzUiB9W7aSRakC6eOPsPFW8q
         2rAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=S6f5ltKfmmbc/Y9tRkkr1Gep0E2+84qSjXYQazP6FGY=;
        b=kyAVf02UxtOMS5h3CfV3n+/OqijlSAaTzSkgfRjtcfrR5JmgXZWFYY57cAMvq/tSWJ
         vkVTvy0OKZgHXSUay33T8nQNVvk778kr/ZyGDpUcQWBD4y8vwd5Pu/r9uVFEfGQ8viVw
         Ck+bXGjcHBDG1/k0O24Ap6/+qozAQykgrgkYx2G7B2+DbgvXqjQjyok1YrqmzCsDiG23
         KnqxXXhIO7MzZEYqZkZY2bCbcCTCyCUk7zXFdiv06QGMeAACGn+HWaWr1bSxB3l7ot30
         I83RHrGBUSWWymxp9l9xWFp4BjTe/E4lzngbbbUZuyCI0LyqKn2KunfTuwg6fze5Vst5
         mtFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=Qw7lFkV8;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t19sor5690019eji.14.2019.02.20.12.41.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 12:41:06 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=Qw7lFkV8;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=S6f5ltKfmmbc/Y9tRkkr1Gep0E2+84qSjXYQazP6FGY=;
        b=Qw7lFkV8yfgMQI7I1KxGwt8coeYmzppBGjv89An9g4411slsQYPWkWoHK5o6qTaZY8
         mGVh03kx1JrDV9WJ5hZVsSPFHwCrg7JtjxyRHfwFNCmGCG1aNmrR3BweASg7EduzJRcC
         ZKEsPQaejvdqcHGTjwANDEGhQqLpqZ3r+9C+k=
X-Google-Smtp-Source: AHgI3IagqA0mxBGHF+yEfWeC0mj2PH/FOucG9GisitYve7hjX3IsPJmMFQpogapUuhVj9T6XNVqoOw==
X-Received: by 2002:a17:906:1602:: with SMTP id m2mr13654457ejd.228.1550695265590;
        Wed, 20 Feb 2019 12:41:05 -0800 (PST)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id j6sm6087946edd.43.2019.02.20.12.41.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 12:41:04 -0800 (PST)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
To: DRI Development <dri-devel@lists.freedesktop.org>,
	LKML <linux-kernel@vger.kernel.org>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>,
	Daniel Vetter <daniel.vetter@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Michal Hocko <mhocko@suse.com>,
	Roman Gushchin <guro@fb.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Jan Stancek <jstancek@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Huang Ying <ying.huang@intel.com>,
	Bartosz Golaszewski <brgl@bgdev.pl>,
	linux-mm@kvack.org
Subject: [PATCH] mm: Don't let userspace spam allocations warnings
Date: Wed, 20 Feb 2019 21:40:58 +0100
Message-Id: <20190220204058.11676-1-daniel.vetter@ffwll.ch>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

memdump_user usually gets fed unchecked userspace input. Blasting a
full backtrace into dmesg every time is a bit excessive - I'm not sure
on the kernel rule in general, but at least in drm we're trying not to
let unpriviledge userspace spam the logs freely. Definitely not entire
warning backtraces.

It also means more filtering for our CI, because our testsuite
exercises these corner cases and so hits these a lot.

Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Jan Stancek <jstancek@redhat.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Bartosz Golaszewski <brgl@bgdev.pl>
Cc: linux-mm@kvack.org
---
 mm/util.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/util.c b/mm/util.c
index 1ea055138043..379319b1bcfd 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -150,7 +150,7 @@ void *memdup_user(const void __user *src, size_t len)
 {
 	void *p;
 
-	p = kmalloc_track_caller(len, GFP_USER);
+	p = kmalloc_track_caller(len, GFP_USER | __GFP_NOWARN);
 	if (!p)
 		return ERR_PTR(-ENOMEM);
 
-- 
2.20.1

