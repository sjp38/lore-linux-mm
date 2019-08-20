Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC017C3A59D
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 08:19:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 911BB23A85
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 08:19:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="YWxeLKHf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 911BB23A85
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FCB86B000D; Tue, 20 Aug 2019 04:19:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 281ED6B000E; Tue, 20 Aug 2019 04:19:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1749A6B0010; Tue, 20 Aug 2019 04:19:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0234.hostedemail.com [216.40.44.234])
	by kanga.kvack.org (Postfix) with ESMTP id E5D3C6B000D
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 04:19:11 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 94C308248AC0
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 08:19:11 +0000 (UTC)
X-FDA: 75842106102.14.verse71_15f7320553661
X-HE-Tag: verse71_15f7320553661
X-Filterd-Recvd-Size: 8242
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com [209.85.208.67])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 08:19:10 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id p28so5331807edi.3
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 01:19:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=wgia7qPSXicnYInuL6+gfr2cdFlvKPNwuVbgz5GenZE=;
        b=YWxeLKHfVQ6n9wGxXuRJAn+g9qtmHMwaPzmYfWe8BYeYvBhhpUOFVNbgUl+9qLpP7T
         PHmTFDTMVPwsO/1+PqoKETqfMC0QoEs4IGQgsATXmRfGgRNSHR4/V73LAd/yZFEVWK1y
         s1kPTUoWam517FLtcOhvQSucIJxk+akolMA3M=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=wgia7qPSXicnYInuL6+gfr2cdFlvKPNwuVbgz5GenZE=;
        b=QtSX/ZnsEelvMVNw+0DZw6nVFjPerPujdjPZovOne6belRB270V3v5uT0jFS6p6uLk
         uG1dS1aAbyYzXBCc8mPcj+xhEMkKa1B5ztAkB5sKGFBlxM/IkZJ2qUOLgb/bsl6DIRex
         PsNS9sBXyB9IW0pBOMtmcf/Iyr9uKBRyq3kCJMDFp9vNdDpTfujfvacyBRXykxwEqqEe
         lGPiYL9cI6OggcHfCwypDIZNSCy8OEd1yWYW072PlA/wvpNf0extmLe854jP/WHU129S
         5nvHIVfWvEYPcoZBCsXGzuDZQRZ0EaLfC9hVVQNUnyVEqb0utV2mSDlwEut3XjRPNvY4
         EYVQ==
X-Gm-Message-State: APjAAAXBS42NNWCOSXL0qVRYitLHhAuS52nWUwBGwqCfVfRQjb57qDZ5
	rc3s3MGFTbbFJ5Qf4gXpmNmlYA==
X-Google-Smtp-Source: APXvYqyu/f8bVTg3bBh5ZePWB9S7yhhKk9kHLLvI/rN0zBooM1KCXKcqbAcEp76HXAnJ5MeGWWnWww==
X-Received: by 2002:aa7:d813:: with SMTP id v19mr29744820edq.45.1566289149643;
        Tue, 20 Aug 2019 01:19:09 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id fj15sm2469623ejb.78.2019.08.20.01.19.08
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Aug 2019 01:19:08 -0700 (PDT)
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
Subject: [PATCH 1/4] mm, notifier: Add a lockdep map for invalidate_range_start/end
Date: Tue, 20 Aug 2019 10:18:59 +0200
Message-Id: <20190820081902.24815-2-daniel.vetter@ffwll.ch>
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

On Jason's suggestion this is is rolled out for both
invalidate_range_start and invalidate_range_end. They both have the
same calling context, hence we can share the same lockdep map. Note
that the annotation for invalidate_ranage_start is outside of the
mm_has_notifiers(), to make sure lockdep is informed about all paths
leading to this context irrespective of whether mmu notifiers are
present for a given context. We don't do that on the
invalidate_range_end side to avoid paying the overhead twice, there
the lockdep annotation is pushed down behind the mm_has_notifiers()
check.

v2: Use lock_map_acquire/release() like fs_reclaim, to avoid confusion
with this being a real mutex (Chris Wilson).

v3: Rebase on top of Glisse's arg rework.

v4: Also annotate invalidate_range_end (Jason Gunthorpe)
Also annotate invalidate_range_start_nonblock, I somehow missed that
one in the first version.

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
 include/linux/mmu_notifier.h | 8 ++++++++
 mm/mmu_notifier.c            | 9 +++++++++
 2 files changed, 17 insertions(+)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index b6c004bd9f6a..39a86b77a939 100644
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
@@ -310,19 +314,23 @@ static inline void mmu_notifier_change_pte(struct m=
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
 mmu_notifier_invalidate_range_start_nonblock(struct mmu_notifier_range *=
range)
 {
+	lock_map_acquire(&__mmu_notifier_invalidate_range_start_map);
 	if (mm_has_notifiers(range->mm)) {
 		range->flags &=3D ~MMU_NOTIFIER_RANGE_BLOCKABLE;
 		return __mmu_notifier_invalidate_range_start(range);
 	}
+	lock_map_release(&__mmu_notifier_invalidate_range_start_map);
 	return 0;
 }
=20
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 16f1cbc775d0..d12e3079e7a4 100644
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
@@ -197,6 +204,7 @@ void __mmu_notifier_invalidate_range_end(struct mmu_n=
otifier_range *range,
 	struct mmu_notifier *mn;
 	int id;
=20
+	lock_map_acquire(&__mmu_notifier_invalidate_range_start_map);
 	id =3D srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &range->mm->mmu_notifier_mm->list, hlist) =
{
 		/*
@@ -220,6 +228,7 @@ void __mmu_notifier_invalidate_range_end(struct mmu_n=
otifier_range *range,
 			mn->ops->invalidate_range_end(mn, range);
 	}
 	srcu_read_unlock(&srcu, id);
+	lock_map_release(&__mmu_notifier_invalidate_range_start_map);
 }
 EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_end);
=20
--=20
2.23.0.rc1


