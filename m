Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67F9CC3A5A4
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 20:14:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EED32186A
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 20:14:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="He9JFSR4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EED32186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DCCC6B0275; Mon, 26 Aug 2019 16:14:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48D9C6B0277; Mon, 26 Aug 2019 16:14:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 357C36B0278; Mon, 26 Aug 2019 16:14:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0049.hostedemail.com [216.40.44.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0D91A6B0275
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 16:14:35 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id A1F50824CA3B
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 20:14:34 +0000 (UTC)
X-FDA: 75865681668.26.bears74_44fa9fbceae25
X-HE-Tag: bears74_44fa9fbceae25
X-Filterd-Recvd-Size: 8267
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 20:14:33 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id f22so28143552edt.4
        for <linux-mm@kvack.org>; Mon, 26 Aug 2019 13:14:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=o7ZUgQ2t4EFE1mwtpJ1URNzAUsS76Vtu8jaG9dFn1TA=;
        b=He9JFSR4idYfY3cTrY5TrEj3IMz4MATcFkTbswKaFuTjJVLXrG8g5PlXrG5qVP0BAC
         vftisf9Y9ImOBlYxAlQuHQAvI72a+KbZ0fnsIWd3BIIgIdpM2sGiWSs2EGrPZfBpVrw1
         hbx/vccXAWEoMwnC29A6T7olib4cw3Y+5UUpc=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=o7ZUgQ2t4EFE1mwtpJ1URNzAUsS76Vtu8jaG9dFn1TA=;
        b=ZWxIAg5eg4f7t6kS3/PczdEoS1s4TbGOuSHaZXGY6AodJ1WehEchJjA5N1B8XjYjmq
         5k5M/DwfeloDY8d7ZYF1/eW7vcc9LUuQ+kAfd8p7wXeYCV6lcv66VpN5DKaAQa6YXouY
         ek5k+T9axQ4+Pbdqo/CIKDHxrWCvqdRQcPvl4E3iHnNxwl5/ynj+Z2b5hItSUin3dHA7
         Ga36ZqDt6+grpf/dVvujLFPONvDjpQEgRPzd+KOssRUtrAjZLvCaSqr9qD8b8qwiNk1O
         70k6B9MXKGeuLJyn9IhfzrIpTDI08bhdDtwEnUE71/4qaoZZNM8x14yYz8AvHr86EjPd
         tDnA==
X-Gm-Message-State: APjAAAWW/1wWz2YOsPAyKBkEUt1bSJPt9qHV04yUcFYldM1TWX9xRL8N
	zH9f2qhUrl+cxaSJ3vOf3VBQCQ==
X-Google-Smtp-Source: APXvYqwI2mGanGH2sozUgL+eYbKM81N0+mUwsmoxd/Kj0A+ZkgeS/zd44/6ltxt/cAqXnGD7EXIVMA==
X-Received: by 2002:a50:ab5d:: with SMTP id t29mr20833370edc.32.1566850472927;
        Mon, 26 Aug 2019 13:14:32 -0700 (PDT)
Received: from phenom.ffwll.local (212-51-149-96.fiber7.init7.net. [212.51.149.96])
        by smtp.gmail.com with ESMTPSA id j25sm3000780ejb.49.2019.08.26.13.14.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 26 Aug 2019 13:14:32 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
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
	Jason Gunthorpe <jgg@mellanox.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: [PATCH 1/5] mm, notifier: Add a lockdep map for invalidate_range_start/end
Date: Mon, 26 Aug 2019 22:14:21 +0200
Message-Id: <20190826201425.17547-2-daniel.vetter@ffwll.ch>
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
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 include/linux/mmu_notifier.h | 8 ++++++++
 mm/mmu_notifier.c            | 9 +++++++++
 2 files changed, 17 insertions(+)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 31aa971315a1..3f9829a1f32e 100644
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
@@ -341,19 +345,23 @@ static inline void mmu_notifier_change_pte(struct m=
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
index d76ea27e2bbb..d48d3b2abd68 100644
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
2.23.0


