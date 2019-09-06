Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6240C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 17:47:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4967D20640
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 17:47:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="FRjTuqf9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4967D20640
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F07D66B0005; Fri,  6 Sep 2019 13:47:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB9096B0006; Fri,  6 Sep 2019 13:47:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D802C6B0007; Fri,  6 Sep 2019 13:47:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0236.hostedemail.com [216.40.44.236])
	by kanga.kvack.org (Postfix) with ESMTP id B46AD6B0005
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 13:47:38 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 693D155F94
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 17:47:38 +0000 (UTC)
X-FDA: 75905228196.27.brick56_868e9f437d08
X-HE-Tag: brick56_868e9f437d08
X-Filterd-Recvd-Size: 5017
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 17:47:37 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id a23so4791254edv.5
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 10:47:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=AXnjF1eMA0qvhNi+oaAvRaU1Op/sm6+LQv/OHFTjjBs=;
        b=FRjTuqf9guqExV42vYGxD/fiJVxgZg0XxcBoMZkO3y4QM+JRyu5YDuJcT8dY4cwVtT
         6/DchteyEMWB7Egugye1ennPXOFn5/y55kWgyjVlAxTOzKoAeV3mZZ1vkODIu9aV6ZZ/
         wPg7BapUpyEmLjNdij5gnkTUktJpuxzhSOXy4=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=AXnjF1eMA0qvhNi+oaAvRaU1Op/sm6+LQv/OHFTjjBs=;
        b=sea72Qupym6w5IMCziuQ7X10OFuQ0st8NSPzIsZlnKZFQI/SAaE7EeZVIFC/noNQI2
         MF++6w9nCSPi/AkDNR5/tq77+omk1m3NpnicvFTnTeBkfuEac9crfKkKmxnQp7I2JkYh
         wBFkhBELAEoeJyAFOlYvjDHl7DZITzRpWFAUS7C/AlDp323ugzu4R74BPVwJFigXwDa1
         EdKcpRYUHjrBPwyQDBf6VwiuTHMFbEcTEAjsBAwb3XPwTh/I8JKV0cfZDNYczcloX2GP
         Qj+8zL7DDD83qpvgi8bNRWWiP3lH3GDrw2LKGCzZ+EvvQHfwRviCiNrMxeBGDPvCaI2g
         XeYA==
X-Gm-Message-State: APjAAAUG0e+u0BJCrdpLpNV29vLkrowSbCtvC9yp5Cj0MulG6FlTx0nP
	MPJBhXQTUOBViZXRKlsaIMZizA==
X-Google-Smtp-Source: APXvYqyXNSoipVDK3YxyEJ0q0hqumo6vbP/ePP5SeWNLJC+mFFPaXXQumLn2z+pO051A2VuoAWL5CA==
X-Received: by 2002:a17:906:8158:: with SMTP id z24mr8426652ejw.54.1567792056188;
        Fri, 06 Sep 2019 10:47:36 -0700 (PDT)
Received: from phenom.ffwll.local (212-51-149-96.fiber7.init7.net. [212.51.149.96])
        by smtp.gmail.com with ESMTPSA id m14sm537241edc.61.2019.09.06.10.47.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 06 Sep 2019 10:47:35 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
To: LKML <linux-kernel@vger.kernel.org>
Cc: DRI Development <dri-devel@lists.freedesktop.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	syzbot+aaedc50d99a03250fe1f@syzkaller.appspotmail.com,
	Jason Gunthorpe <jgg@mellanox.com>,
	Daniel Vetter <daniel.vetter@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Ira Weiny <ira.weiny@intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Sean Christopherson <sean.j.christopherson@intel.com>,
	Jean-Philippe Brucker <jean-philippe@linaro.org>,
	linux-mm@kvack.org
Subject: [PATCH] mm, notifier: Fix early return case for new lockdep annotations
Date: Fri,  6 Sep 2019 19:47:30 +0200
Message-Id: <20190906174730.22462-1-daniel.vetter@ffwll.ch>
X-Mailer: git-send-email 2.23.0
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I missed that when extending the lockdep annotations to the
nonblocking case.

I missed this while testing since in the i915 mmu notifiers is hitting
a nice lockdep splat already before the point of going into oom killer
mode :-/

Reported-by: syzbot+aaedc50d99a03250fe1f@syzkaller.appspotmail.com
Fixes: d2b219ed03d4 ("mm/mmu_notifiers: add a lockdep map for invalidate_=
range_start/end")
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Daniel Vetter <daniel.vetter@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Sean Christopherson <sean.j.christopherson@intel.com>
Cc: Jean-Philippe Brucker <jean-philippe@linaro.org>
Cc: linux-mm@kvack.org
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 include/linux/mmu_notifier.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 5a03417e5bf7..4edd98b06834 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -356,13 +356,14 @@ mmu_notifier_invalidate_range_start(struct mmu_noti=
fier_range *range)
 static inline int
 mmu_notifier_invalidate_range_start_nonblock(struct mmu_notifier_range *=
range)
 {
+	int ret =3D 0;
 	lock_map_acquire(&__mmu_notifier_invalidate_range_start_map);
 	if (mm_has_notifiers(range->mm)) {
 		range->flags &=3D ~MMU_NOTIFIER_RANGE_BLOCKABLE;
-		return __mmu_notifier_invalidate_range_start(range);
+		ret =3D __mmu_notifier_invalidate_range_start(range);
 	}
 	lock_map_release(&__mmu_notifier_invalidate_range_start_map);
-	return 0;
+	return ret;
 }
=20
 static inline void
--=20
2.23.0


