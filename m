Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F4EDC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 08:19:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E628323A85
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 08:19:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="H3IaTIIK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E628323A85
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 718F46B000E; Tue, 20 Aug 2019 04:19:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67E246B0010; Tue, 20 Aug 2019 04:19:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5719C6B0269; Tue, 20 Aug 2019 04:19:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0162.hostedemail.com [216.40.44.162])
	by kanga.kvack.org (Postfix) with ESMTP id 2EB0E6B000E
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 04:19:13 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id D91996C2D
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 08:19:12 +0000 (UTC)
X-FDA: 75842106144.18.leg41_1626500992f0d
X-HE-Tag: leg41_1626500992f0d
X-Filterd-Recvd-Size: 5053
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com [209.85.208.65])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 08:19:12 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id x19so5328226eda.12
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 01:19:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=HRs5HpBA3qSqFe5qnt1LL6h0B7I2hzSM+r7A2DpfdeU=;
        b=H3IaTIIKcnZxd8XaCn8QCH9mcrNGjOx/ak2ybd66H0ki331clYHFNQzkO0bKWcuXsr
         Mq6+jU/jrdI7HQWeHyhaTDSfFkUDTPsmPa++H2SDWnl1ZAvHNh4YpUIn825O4i0/plh8
         z09eHCYqJKERfRBDZg/Pr+cpNjod1qv2vMJ8w=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=HRs5HpBA3qSqFe5qnt1LL6h0B7I2hzSM+r7A2DpfdeU=;
        b=MOly1xQAuQ9lDXdmc9hCk6E0Z9YmQE0sxTdzCIRwcnIoBEIcyzBKRNuNRfh70TDBn7
         JukuaxudTwHoDjTBDn7C/mG2IFnmT6DtmO1teyuAK7wHLM47PyJa5TWO2O5VOSzOzkG+
         /Oxof98NBvVvjfXXLcf4e2BFtyoCIeAzEjrGa+qirMS82FDEX71csfERYpOAVR7Qc/16
         PU/uX+o9azSLHeBj2FQfTEJUtfzP91IPUZl7sbXD69h12hcFXb9d3CVWG0PfGcgc4ElK
         WwnjzOkjF1nTuRa3cvCHL9UIgqqud5Xol1202xY35H2viXxL1Ic5K906t9T7+SWy3d4N
         GnaA==
X-Gm-Message-State: APjAAAXdWYrIFa65+5DnHWWBvMDoRBlokeZ+4XC9Eb7GApIOLH9+2OCY
	c++gCkeTqRNKFBZ50FK/0skOPQ==
X-Google-Smtp-Source: APXvYqzwk/VVcEGb/uEJb+MjHFqWnLqThVvSK3PFeDiC0L0cxhC/+XJhzn783w4kD3r5dKVWby8hcQ==
X-Received: by 2002:aa7:c498:: with SMTP id m24mr12784881edq.277.1566289150887;
        Tue, 20 Aug 2019 01:19:10 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id fj15sm2469623ejb.78.2019.08.20.01.19.09
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Aug 2019 01:19:10 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: [PATCH 2/4] mm, notifier: Prime lockdep
Date: Tue, 20 Aug 2019 10:19:00 +0200
Message-Id: <20190820081902.24815-3-daniel.vetter@ffwll.ch>
X-Mailer: git-send-email 2.23.0.rc1
In-Reply-To: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
References: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We want to teach lockdep that mmu notifiers can be called from direct
reclaim paths, since on many CI systems load might never reach that
level (e.g. when just running fuzzer or small functional tests).

Motivated by a discussion with Jason.

I've put the annotation into mmu_notifier_register since only when we
have mmu notifiers registered is there any point in teaching lockdep
about them. Also, we already have a kmalloc(, GFP_KERNEL), so this is
safe.

Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Christian K=C3=B6nig" <christian.koenig@amd.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 mm/mmu_notifier.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index d12e3079e7a4..538d3bb87f9b 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -256,6 +256,13 @@ static int do_mmu_notifier_register(struct mmu_notif=
ier *mn,
=20
 	BUG_ON(atomic_read(&mm->mm_users) <=3D 0);
=20
+	if (IS_ENABLED(CONFIG_LOCKDEP)) {
+		fs_reclaim_acquire(GFP_KERNEL);
+		lock_map_acquire(&__mmu_notifier_invalidate_range_start_map);
+		lock_map_release(&__mmu_notifier_invalidate_range_start_map);
+		fs_reclaim_release(GFP_KERNEL);
+	}
+
 	ret =3D -ENOMEM;
 	mmu_notifier_mm =3D kmalloc(sizeof(struct mmu_notifier_mm), GFP_KERNEL)=
;
 	if (unlikely(!mmu_notifier_mm))
--=20
2.23.0.rc1


