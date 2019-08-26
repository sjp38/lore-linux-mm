Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D7E4C3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 20:14:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6140217F5
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 20:14:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="jWs+/c0l"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6140217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A39BC6B0277; Mon, 26 Aug 2019 16:14:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94A086B0279; Mon, 26 Aug 2019 16:14:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 813176B027A; Mon, 26 Aug 2019 16:14:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0079.hostedemail.com [216.40.44.79])
	by kanga.kvack.org (Postfix) with ESMTP id 52B036B0277
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 16:14:36 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id EEFCB824CA3B
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 20:14:35 +0000 (UTC)
X-FDA: 75865681710.20.smoke09_45357b3d29514
X-HE-Tag: smoke09_45357b3d29514
X-Filterd-Recvd-Size: 5043
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 20:14:35 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id s15so28186504edx.0
        for <linux-mm@kvack.org>; Mon, 26 Aug 2019 13:14:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=43MMkU2nAs7jtnMnw+TAIk5AMkJWGIqIB3w6SHg2dOA=;
        b=jWs+/c0l0gQqLqnonUguMXmcEgRnSUc9uFPRnBjVNs1Nfg/BKnOJH3T6iKhSC9eb6q
         dpAfCEkDXZ40OJ02lIV0O9i7OYhqlEmJrKDApByW1yfFG3TBOGtD29nnDadAmOX0w/3a
         ohtG4NM02aYnLMkZ4fScN1kWA5UKzPn2mVZA0=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=43MMkU2nAs7jtnMnw+TAIk5AMkJWGIqIB3w6SHg2dOA=;
        b=i04T0ht5jY2Cj8+T3cYIt+pteC6ldAG8MyvXKR0pZtjDQ80MR3xvPLHM2kTrzxoekK
         +KHAlbg0h0iKExDU7sfGb/gPwfME/wl1q3GvTY1Q/OECYjIDQ2om/Bp4Bvy6Z4A7/TWM
         6uNrplEltBuZ39W7pFte23VjZh/hlxxNMXjZqXI6BdgZkjMFtQMyuBhYpwUDQxUBQWym
         YivvCNnU8EiVvxfvov1HspCzSHMWClf3wCQmfwWBwGib9/VYbGm+/ch4KBT0KpLqp5ZI
         i29cz0mQdxfS5rRAtu8wwGKsT4ZHdjrtMZwKfbnNKDTl4Qc9exLKExHX7vjm6oElckpV
         dOLg==
X-Gm-Message-State: APjAAAXTYidP/GBQvX6mcYdVap82JjJgYYRGgw4MwBg7Abw1XboHSRXG
	JWssDXmaolq675MEe2BekWzfpw==
X-Google-Smtp-Source: APXvYqz1alL5dlGwBBuOouoL2tngfggzrmMx20gafiZ6V+aQeNinylzwLOpzJO1HhOF4TDXl6u3nsA==
X-Received: by 2002:a50:d0cc:: with SMTP id g12mr19859322edf.201.1566850474445;
        Mon, 26 Aug 2019 13:14:34 -0700 (PDT)
Received: from phenom.ffwll.local (212-51-149-96.fiber7.init7.net. [212.51.149.96])
        by smtp.gmail.com with ESMTPSA id j25sm3000780ejb.49.2019.08.26.13.14.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 26 Aug 2019 13:14:33 -0700 (PDT)
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
Subject: [PATCH 2/5] mm, notifier: Prime lockdep
Date: Mon, 26 Aug 2019 22:14:22 +0200
Message-Id: <20190826201425.17547-3-daniel.vetter@ffwll.ch>
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
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 mm/mmu_notifier.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index d48d3b2abd68..0523555933c9 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -259,6 +259,13 @@ int __mmu_notifier_register(struct mmu_notifier *mn,=
 struct mm_struct *mm)
 	lockdep_assert_held_write(&mm->mmap_sem);
 	BUG_ON(atomic_read(&mm->mm_users) <=3D 0);
=20
+	if (IS_ENABLED(CONFIG_LOCKDEP)) {
+		fs_reclaim_acquire(GFP_KERNEL);
+		lock_map_acquire(&__mmu_notifier_invalidate_range_start_map);
+		lock_map_release(&__mmu_notifier_invalidate_range_start_map);
+		fs_reclaim_release(GFP_KERNEL);
+	}
+
 	mn->mm =3D mm;
 	mn->users =3D 1;
=20
--=20
2.23.0


