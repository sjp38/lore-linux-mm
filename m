Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89901C4646C
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F00520656
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="F8IpBc2p"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F00520656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A36D8E0006; Mon, 24 Jun 2019 17:02:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6121F8E0007; Mon, 24 Jun 2019 17:02:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22B8F8E0006; Mon, 24 Jun 2019 17:02:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id C08568E0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:02:06 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id b14so6892209wrn.8
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:02:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yY5nuWFfvtGdjXx5X0jOTLVoM6UrkzhjnRnf2/dFDmQ=;
        b=VbbJwV5In/MFRvPpTBzLGAA3T7/XV+za3y/4JQgy4Nub8TJomJq//JdJAsdQgRfRUw
         VbaopRUD2AGanmkW1VWaWucNbxmqIevJ7DosvRKxMzmniEqDVpyjZ23bbqwX82+WbWOO
         YTNdOpjG7ExUSlCy3r9JMMpVq8sWuuVxivrC9wwgXrg+FY5xPqGJ+9em7U3Uqslq9rdz
         OFUUK/scHYPN/Wu9zkYitcfvCnpsfXcaUdxW5YZwiZEpXaD6TwpsU00P60guOwSh25Q3
         vptb/QiFISV4y9ze+4+q58ZvJmuOle/Ij6pSedu0rDqxSD3U2LT16W8c1tL1EJ/AjPBT
         7aMQ==
X-Gm-Message-State: APjAAAV5kqklpxxFM1EVAPkKs2Al2WBg2Rk/i0XYBR0ulXI45I3/gaUd
	+KRSPmN7+ECTZ22u7jjeHngX0Bg9i4G20CM5cwVYF+xCRQcs6firfkBFgkL4b7612GLr+++Jy1D
	rd5XSf0oVMvVVpJn3wE2aGs8HMb2o82ANVyULAOnedwu829HThzfBeLrOsoszX4o+mw==
X-Received: by 2002:adf:ebcd:: with SMTP id v13mr36750941wrn.263.1561410126329;
        Mon, 24 Jun 2019 14:02:06 -0700 (PDT)
X-Received: by 2002:adf:ebcd:: with SMTP id v13mr36750908wrn.263.1561410125481;
        Mon, 24 Jun 2019 14:02:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561410125; cv=none;
        d=google.com; s=arc-20160816;
        b=iG2mhDdgm/0r1N1Yn43w8IO6TKYBz1CdoXgzkm9pw3448vu46VW2uP01FBnfrBSUMB
         ZuRc2G5AV9BP0VysbK9UGtVRuKQEOoLMPhuYL9XC9BD2ySUprCmCOyAl7Axp32g5SyMy
         7jRs02zUa5n1ivGgSsVeVkm9+wNwc/FznzHY/4SbD4A14hgv0Iyp4VPuf0np5nDIi/8p
         uHuP9ua7tleUi6iqkYj39ZsmABYX1gbEGO0kJpWWlMINgRjz4TWzct0V+Jz1jGQChbaV
         5t1NkDZkuCr4PauUkYL5KNLXg/4UyftICYqdE79h7Lm/hzhDdRisglY4iumoJxWJCZS9
         l86g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=yY5nuWFfvtGdjXx5X0jOTLVoM6UrkzhjnRnf2/dFDmQ=;
        b=im8wty/ZCgjPSF6GKYRpEDWw2mDdy89KPiUu2JWGGptMlLTO05tpMgaNgUUSjtIz/O
         r8pL6JlKq4kOzqwUcJNdaKgnElFonAG2MIEMBhj26QzNSswujuQvX0QFKzU94ieZH2ey
         FvUQkK1mB8GPLKJY2BzKiXhoFZBc3iRoXbuhmEx+Zvcluqarc3q5N942Wxm0hnjUwW7W
         w/mle07OOJd3C1CHukCw/auDLEz4NMe8VSiEhPlBmz32xBH3+zNCG2EgYurrcV+ENSbU
         ZpDIPLbF2EIvLaOm0BPZ0fxA8yrGc0Av+z/pJEeD6RUfxxoqGk1ChMsOSRGTt1obKLzG
         ivCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=F8IpBc2p;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y134sor368769wmc.4.2019.06.24.14.02.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 14:02:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=F8IpBc2p;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=yY5nuWFfvtGdjXx5X0jOTLVoM6UrkzhjnRnf2/dFDmQ=;
        b=F8IpBc2pCC9TRRcnAQyPopBTGejfFjN4O3manyf4o/rILQiqjMrQn93gZmQT0zfX3x
         5Z+FOf3huG56JiHRxImMjpmYUHWLJoUWRxsyiLyvuER8NJ6yXAhiFhmoMeS3xXIFDdo2
         S8cp9J0djUNYJQZ5sFZYQ/C2WzaQmeRBmrPgWsubS3c8Ie4OcoFe0BbQ1hX51zSmNWX8
         jRx4QvWLtE9d+wLs0Pn2yh3tjD1LsHbOoGDIFKF99fyOS9uFazFhPFuBYcSfa5SLimKH
         7oBiYCs7lU7Wqx9ujUyjct2anJPQXnJ7qZm2I66poFSkOkPL9DAIWEUtnwKp1WVc7xDc
         HnQg==
X-Google-Smtp-Source: APXvYqyRMuYsh8UNUKwpWttANdd8lJKeiEYwmSXHHDDyx29FbNSbr+pndqxDZmcjLhM+HZNLBH9CVQ==
X-Received: by 2002:a1c:4054:: with SMTP id n81mr17413906wma.78.1561410125081;
        Mon, 24 Jun 2019 14:02:05 -0700 (PDT)
Received: from ziepe.ca ([66.187.232.66])
        by smtp.gmail.com with ESMTPSA id f7sm6578766wrv.38.2019.06.24.14.02.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Jun 2019 14:02:02 -0700 (PDT)
Received: from jgg by jggl.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hfW6D-0001N1-4V; Mon, 24 Jun 2019 18:02:01 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Felix.Kuehling@amd.com
Cc: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>,
	Christoph Hellwig <hch@lst.de>,
	Philip Yang <Philip.Yang@amd.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v4 hmm 11/12] mm/hmm: Remove confusing comment and logic from hmm_release
Date: Mon, 24 Jun 2019 18:01:09 -0300
Message-Id: <20190624210110.5098-12-jgg@ziepe.ca>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190624210110.5098-1-jgg@ziepe.ca>
References: <20190624210110.5098-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

hmm_release() is called exactly once per hmm. ops->release() cannot
accidentally trigger any action that would recurse back onto
hmm->mirrors_sem.

This fixes a use after-free race of the form:

       CPU0                                   CPU1
                                           hmm_release()
                                             up_write(&hmm->mirrors_sem);
 hmm_mirror_unregister(mirror)
  down_write(&hmm->mirrors_sem);
  up_write(&hmm->mirrors_sem);
  kfree(mirror)
                                             mirror->ops->release(mirror)

The only user we have today for ops->release is an empty function, so this
is unambiguously safe.

As a consequence of plugging this race drivers are not allowed to
register/unregister mirrors from within a release op.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
 mm/hmm.c | 28 +++++++++-------------------
 1 file changed, 9 insertions(+), 19 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index c30aa9403dbe4d..b224ea635a7716 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -130,26 +130,16 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 	 */
 	WARN_ON(!list_empty_careful(&hmm->ranges));
 
-	down_write(&hmm->mirrors_sem);
-	mirror = list_first_entry_or_null(&hmm->mirrors, struct hmm_mirror,
-					  list);
-	while (mirror) {
-		list_del_init(&mirror->list);
-		if (mirror->ops->release) {
-			/*
-			 * Drop mirrors_sem so the release callback can wait
-			 * on any pending work that might itself trigger a
-			 * mmu_notifier callback and thus would deadlock with
-			 * us.
-			 */
-			up_write(&hmm->mirrors_sem);
+	down_read(&hmm->mirrors_sem);
+	list_for_each_entry(mirror, &hmm->mirrors, list) {
+		/*
+		 * Note: The driver is not allowed to trigger
+		 * hmm_mirror_unregister() from this thread.
+		 */
+		if (mirror->ops->release)
 			mirror->ops->release(mirror);
-			down_write(&hmm->mirrors_sem);
-		}
-		mirror = list_first_entry_or_null(&hmm->mirrors,
-						  struct hmm_mirror, list);
 	}
-	up_write(&hmm->mirrors_sem);
+	up_read(&hmm->mirrors_sem);
 
 	hmm_put(hmm);
 }
@@ -279,7 +269,7 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror)
 	struct hmm *hmm = mirror->hmm;
 
 	down_write(&hmm->mirrors_sem);
-	list_del_init(&mirror->list);
+	list_del(&mirror->list);
 	up_write(&hmm->mirrors_sem);
 	hmm_put(hmm);
 }
-- 
2.22.0

