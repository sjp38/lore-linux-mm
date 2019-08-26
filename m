Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6253C3A5A6
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 20:14:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A59D2189D
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 20:14:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="QViZPMOC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A59D2189D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAA146B027D; Mon, 26 Aug 2019 16:14:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9974B6B027F; Mon, 26 Aug 2019 16:14:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 885AC6B0280; Mon, 26 Aug 2019 16:14:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0051.hostedemail.com [216.40.44.51])
	by kanga.kvack.org (Postfix) with ESMTP id 62F4D6B027D
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 16:14:40 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 06DB9824CA3B
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 20:14:40 +0000 (UTC)
X-FDA: 75865681920.07.hen34_45c9d513cf939
X-HE-Tag: hen34_45c9d513cf939
X-Filterd-Recvd-Size: 4857
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com [209.85.208.67])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 20:14:39 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id t50so28194644edd.2
        for <linux-mm@kvack.org>; Mon, 26 Aug 2019 13:14:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=bUhdeRpbg8gRloy4w33VnXTSeooO5sqpvDT0wx5DMzY=;
        b=QViZPMOCt4TCBDSlKAVCdrC+U37mohUaGpt7t54fKUAJnII/M30PJe3HVgsMvO32I/
         JHmsQisAEo+uwv1GVmUHudMfC1x01ExLcWbO28gdRMZiZ/4jYiOIUrGZ6L9+5vRcVnku
         F9YxwgBgX7xnEA70Wp+hl/fz9/FJFtPM7Z4dQ=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=bUhdeRpbg8gRloy4w33VnXTSeooO5sqpvDT0wx5DMzY=;
        b=FNOrI5rxnmPsSQQqYg0mBdy+O3wAwYTGLsr2QjnUwCAK5ZQcZruSbWTbBuf2yQX3gh
         hXwGGEGZ8GkucKC1uyhcznp2CwWIYO+wd7FGd/QEJVJBW3poyi8SQa1hprdrMJ8qgWor
         REpr+b/p0gVMtIe69ZduDZW9tyOqHUGJPb9KoVyr4uN0O/omOL/faAVp3/E8FvXK12b0
         VuwesZvGQMRkCu+AFMZ/ouBMVZp8Sy7JFSeFIpUd+a92TITMOFN7SHK+YL3vJpbrPpZk
         5N+o1R9zuvlDoyQx7CSdou9b/vlcMtmvJ5xF4wJTCE3gBDc+iUpzhTi5snolskwUth2H
         K+TQ==
X-Gm-Message-State: APjAAAXILrIkGwGTq6n7YSIvzzUCcE1gLkSu0yZ5Ih0FJ3nt5aEizp2x
	qpY2j8Ec1+iXu+znEoY4D07EPA==
X-Google-Smtp-Source: APXvYqwQX5rJn4xiT0PzmoOjk8RceDZHB/u+ViHnJA99I4EPasO1Ql6cGV43P/XDRPUyqHKPLLvlzQ==
X-Received: by 2002:aa7:c552:: with SMTP id s18mr21104247edr.0.1566850478492;
        Mon, 26 Aug 2019 13:14:38 -0700 (PDT)
Received: from phenom.ffwll.local (212-51-149-96.fiber7.init7.net. [212.51.149.96])
        by smtp.gmail.com with ESMTPSA id j25sm3000780ejb.49.2019.08.26.13.14.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 26 Aug 2019 13:14:37 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: [PATCH 5/5] mm, notifier: annotate with might_sleep()
Date: Mon, 26 Aug 2019 22:14:25 +0200
Message-Id: <20190826201425.17547-6-daniel.vetter@ffwll.ch>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190826201425.17547-1-daniel.vetter@ffwll.ch>
References: <20190826201425.17547-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since mmu notifiers don't exist for more processes, but could block in
interesting places, add some annotations. This should help make sure
core mm keeps up its end of the mmu notifier contract.

The checks here are outside of all notifier checks because of that.
They compile away without CONFIG_DEBUG_ATOMIC_SLEEP.

Suggested by Jason.

Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
Cc: "Christian K=C3=B6nig" <christian.koenig@amd.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: linux-mm@kvack.org
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 include/linux/mmu_notifier.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 3f9829a1f32e..8b71813417e7 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -345,6 +345,8 @@ static inline void mmu_notifier_change_pte(struct mm_=
struct *mm,
 static inline void
 mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
 {
+	might_sleep();
+
 	lock_map_acquire(&__mmu_notifier_invalidate_range_start_map);
 	if (mm_has_notifiers(range->mm)) {
 		range->flags |=3D MMU_NOTIFIER_RANGE_BLOCKABLE;
@@ -368,6 +370,9 @@ mmu_notifier_invalidate_range_start_nonblock(struct m=
mu_notifier_range *range)
 static inline void
 mmu_notifier_invalidate_range_end(struct mmu_notifier_range *range)
 {
+	if (mmu_notifier_range_blockable(range))
+		might_sleep();
+
 	if (mm_has_notifiers(range->mm))
 		__mmu_notifier_invalidate_range_end(range, false);
 }
--=20
2.23.0


