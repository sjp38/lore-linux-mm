Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05636C32759
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 20:20:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF2A8216F4
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 20:20:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="dtTpZc1T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF2A8216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 790FC6B000D; Wed, 14 Aug 2019 16:20:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CD946B000E; Wed, 14 Aug 2019 16:20:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AAD36B0010; Wed, 14 Aug 2019 16:20:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0096.hostedemail.com [216.40.44.96])
	by kanga.kvack.org (Postfix) with ESMTP id 2346F6B000D
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:20:41 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id C527F442C
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:20:40 +0000 (UTC)
X-FDA: 75822151440.29.cord04_5d962f9c3539
X-HE-Tag: cord04_5d962f9c3539
X-Filterd-Recvd-Size: 6848
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:20:40 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id f22so369892edt.4
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 13:20:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=U5KwhaOsa05mLs5dKsxyaJ8nPNTkq9L0E7PVwxBUg2k=;
        b=dtTpZc1TP3phfJWfjZ0TTcGZDEkgZeTx7+tiSVp14czRexPyqDM1gnaVtyCL269PpM
         uyr+QykzpH67/lUTpJRJ4qgJstssFYUgdSFMP71ckMZGGA6c+b2mIUyn+RNlKV5QMWnf
         BWavURm9nkk5uzc5rKnkwSgXxYm3JJg1jMKeM=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=U5KwhaOsa05mLs5dKsxyaJ8nPNTkq9L0E7PVwxBUg2k=;
        b=Qd+C+YOLYPWF3lflw5XnKGLtyCTnObxqzKyPhYMXY6FIw0GcHMNfQNKFvGfF6wiZWH
         Kz7JO8udt4Gvpta424ps/0+W2793jsvi1Js6QGfPNPTknYXyOOzxIUK/yxT0/CBBTe5I
         S4LKfMEXydWV50orO5BYD4aluNCigr76d1qgUYrbvY+wmikAiNqQWQkTviojTGo5nD3G
         TR3iwZWnTkth/4Ycm0eDcRYSGJW4tgxImg4MYyUaLyYy0IUHeizWIr0Vft3jYDwyiKve
         wvMteLiaSGeuOpulj5HowyNz06SI/aN0qJo7ww1IHqmW2VQc58DUkWlF2dDY5/2ocd5J
         E9rw==
X-Gm-Message-State: APjAAAXTetN1G2CZRJDdHagCioiPLupREgjLPKSMYDoj+Maas4/PC/8y
	7KAt4hG1gAP3+dBqyVGm5U5d1w==
X-Google-Smtp-Source: APXvYqwr2QYX0Cwtm9mM9vEmD8lUn0css8IRklo25E0smQh544dGM+PTj5A8hH3aTQAPYL0Qh4N4uw==
X-Received: by 2002:a17:907:390:: with SMTP id ss16mr1324369ejb.46.1565814039028;
        Wed, 14 Aug 2019 13:20:39 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id ns22sm84342ejb.9.2019.08.14.13.20.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 14 Aug 2019 13:20:38 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org,
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
Subject: [PATCH 4/5] mm, notifier: Add a lockdep map for invalidate_range_start
Date: Wed, 14 Aug 2019 22:20:26 +0200
Message-Id: <20190814202027.18735-5-daniel.vetter@ffwll.ch>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a similar idea to the fs_reclaim fake lockdep lock. It's
fairly easy to provoke a specific notifier to be run on a specific
range: Just prep it, and then munmap() it.

A bit harder, but still doable, is to provoke the mmu notifiers for
all the various callchains that might lead to them. But both at the
same time is really hard to reliable hit, especially when you want to
exercise paths like direct reclaim or compaction, where it's not
easy to control what exactly will be unmapped.

By introducing a lockdep map to tie them all together we allow lockdep
to see a lot more dependencies, without having to actually hit them
in a single challchain while testing.

Aside: Since I typed this to test i915 mmu notifiers I've only rolled
this out for the invaliate_range_start callback. If there's
interest, we should probably roll this out to all of them. But my
undestanding of core mm is seriously lacking, and I'm not clear on
whether we need a lockdep map for each callback, or whether some can
be shared.

v2: Use lock_map_acquire/release() like fs_reclaim, to avoid confusion
with this being a real mutex (Chris Wilson).

v3: Rebase on top of Glisse's arg rework.

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
Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 include/linux/mmu_notifier.h | 6 ++++++
 mm/mmu_notifier.c            | 7 +++++++
 2 files changed, 13 insertions(+)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index b6c004bd9f6a..9dd38c32fc53 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -42,6 +42,10 @@ enum mmu_notifier_event {
=20
 #ifdef CONFIG_MMU_NOTIFIER
=20
+#ifdef CONFIG_LOCKDEP
+extern struct lockdep_map __mmu_notifier_invalidate_range_start_map;
+#endif
+
 /*
  * The mmu notifier_mm structure is allocated and installed in
  * mm->mmu_notifier_mm inside the mm_take_all_locks() protected
@@ -310,10 +314,12 @@ static inline void mmu_notifier_change_pte(struct m=
m_struct *mm,
 static inline void
 mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
 {
+	lock_map_acquire(&__mmu_notifier_invalidate_range_start_map);
 	if (mm_has_notifiers(range->mm)) {
 		range->flags |=3D MMU_NOTIFIER_RANGE_BLOCKABLE;
 		__mmu_notifier_invalidate_range_start(range);
 	}
+	lock_map_release(&__mmu_notifier_invalidate_range_start_map);
 }
=20
 static inline int
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 43a76d030164..331e43ce6f3c 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -21,6 +21,13 @@
 /* global SRCU for all MMs */
 DEFINE_STATIC_SRCU(srcu);
=20
+#ifdef CONFIG_LOCKDEP
+struct lockdep_map __mmu_notifier_invalidate_range_start_map =3D {
+	.name =3D "mmu_notifier_invalidate_range_start"
+};
+EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start_map);
+#endif
+
 /*
  * This function allows mmu_notifier::release callback to delay a call t=
o
  * a function that will free appropriate resources. The function must be
--=20
2.22.0


