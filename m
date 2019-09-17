Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B43BC4CECE
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 20:30:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4DAD2054F
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 20:30:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="b2heVtMa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4DAD2054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 736336B0005; Tue, 17 Sep 2019 16:30:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E5E66B0006; Tue, 17 Sep 2019 16:30:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D53F6B0007; Tue, 17 Sep 2019 16:30:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0051.hostedemail.com [216.40.44.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3E3D26B0005
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 16:30:45 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id A9DBD4404
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 20:30:44 +0000 (UTC)
X-FDA: 75945556008.26.sign42_2386049e9d762
X-HE-Tag: sign42_2386049e9d762
X-Filterd-Recvd-Size: 3453
Received: from mail-qk1-f194.google.com (mail-qk1-f194.google.com [209.85.222.194])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 20:30:44 +0000 (UTC)
Received: by mail-qk1-f194.google.com with SMTP id x134so5528030qkb.0
        for <linux-mm@kvack.org>; Tue, 17 Sep 2019 13:30:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=FapF/w8V6L5P4RP46nAQFrAdDN4jwAlxC54JDkAvfWE=;
        b=b2heVtMaAE//iiVUcKsZr0w7awdslPkqyQbYNyjGPHEL5W+LgsLzJdHgLusSCvcjFf
         YvSE5Y384otm0G5eZOgbTalFDAnlo01PRpnbLoB2ayOgzzTvNYCOnP4IGWEDYDbQ4qVD
         dLFolbhNPH4v6x1Pps+vdpjxTD8MKBvF9f5WuyV4U/4gF4NrkK8t59Lk1P6YK3FtQTW5
         hkfqNyCR2qrlhcy5XdsCerD3vDypFmfHqqZDSITyUW3Bpfw6Pwbmq7Wfcg/fHMOiKMxO
         PypYyKoxR5XSuCydNmltfumpdY8vQfvEYwhwI+VzGz4AnmdtC70mTm1ttcp//WcrmOwp
         Cytw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=FapF/w8V6L5P4RP46nAQFrAdDN4jwAlxC54JDkAvfWE=;
        b=TWrz2F4t/AELVZnGpWo6iA/g4cM5XoB1Km/znTLJQcjZm+J5GROFPaKeNo11hTurxa
         teAwi+CebqD13KThUp9TdXvJF+UKZnEtajcYfvTA4N/lrdw+WkCxpOy9Chb7fUlLllhs
         2/3pDyo4muYc77YICF5pLAnjQTFoeFjSCdTBtuiGMsd4+J0tglCv+hk/zcG4qaFSpEcz
         tflXzb+Y1GFidlN5hjK1qlMsq5pjpWfNS0B8/2yY52WkfCqgbbIGgDw+RcJ2jyaIKMem
         88mic5aFYp5FbQw7SyCsphMu6mQf/R8eGF6XLblAGiQfh8g5jHDqyrxkM/9gtNisgIsj
         vo7g==
X-Gm-Message-State: APjAAAVuXT8qthzCvyiqGs4qDxOt2h+5rHD++NIwgRIOfFXSDkQrFIZI
	+U797ldpfZeT0To2qCNvjb6UUg==
X-Google-Smtp-Source: APXvYqxAmisQfB6dzZqw466gLLRXufi21otNJ/5du7EZOaLPbhdALpCQOrklxXZW9Tlgu7tiOQD7Gg==
X-Received: by 2002:a37:9d93:: with SMTP id g141mr427405qke.188.1568752243366;
        Tue, 17 Sep 2019 13:30:43 -0700 (PDT)
Received: from qcai.nay.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id 139sm1822874qkf.14.2019.09.17.13.30.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Sep 2019 13:30:42 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: rientjes@google.com,
	cl@linux.com,
	penberg@kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] mm/slub: fix -Wunused-function compiler warnings
Date: Tue, 17 Sep 2019 16:30:32 -0400
Message-Id: <1568752232-5094-1-git-send-email-cai@lca.pw>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.030575, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

tid_to_cpu() and tid_to_event() are only used in note_cmpxchg_failure()
when SLUB_DEBUG_CMPXCHG=y, so when SLUB_DEBUG_CMPXCHG=n by default,
Clang will complain that those unused functions.

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/slub.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index 8834563cdb4b..49739f005b4f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2004,6 +2004,7 @@ static inline unsigned long next_tid(unsigned long tid)
 	return tid + TID_STEP;
 }
 
+#ifdef SLUB_DEBUG_CMPXCHG
 static inline unsigned int tid_to_cpu(unsigned long tid)
 {
 	return tid % TID_STEP;
@@ -2013,6 +2014,7 @@ static inline unsigned long tid_to_event(unsigned long tid)
 {
 	return tid / TID_STEP;
 }
+#endif
 
 static inline unsigned int init_tid(int cpu)
 {
-- 
1.8.3.1


