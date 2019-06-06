Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E7CEC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:45:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E11CC20868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:45:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="WgY47IGZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E11CC20868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F1796B0285; Thu,  6 Jun 2019 14:44:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 929666B0286; Thu,  6 Jun 2019 14:44:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81A8D6B0287; Thu,  6 Jun 2019 14:44:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 62F586B0285
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 14:44:52 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id n126so2748409qkc.18
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 11:44:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nVAUpO+Ga9NYec9bVUlta7oVxGoK2kbyT+1hUTcsX2M=;
        b=Ph8hbVx7rUc3HCIZtyYa+YSbb5/H56M+kPe900gY+wjXs00seXefzbOlMFQF85jYPU
         9C4MZPeOG3JG6oRQqG3ZEgoojaw0ve3EXIRIGd6BJdO7FAi2Uss8tQFPJPvcuH1//ViR
         zmuuS3jhHOhzatFXfVvWRQpvlqXHbx+3CLe9lUHQRNgLyiWscJLA9SAg0mEcLsWZJGg/
         j4B1wrxGLkjHxCi+Ve0smzIjWiSFbisQ1mGjqWltiMqE/83s78a9HGTsQEzjdrJ1M3Od
         kw/VChtBva77I9mNNCm8WGl0A2kW+cw2MhaSRj5Isuucwge1e1ycwd8/aXFLEwt6QTEH
         tOsQ==
X-Gm-Message-State: APjAAAWNglYJjg0a+6JIho3rNg57BYcK+0JlT3qZurAwMU9kffFbLjKI
	oWjXys3zDqIj4JYn8xBVqtT83+mCKeFN7gM3s7gZ4sGMGv9Xfu1wBLkQoTxsAAvq1zsu3/BfoGI
	f2+nAzyyO7B47FgX1G1wzz6LoBJVttrdKTd9xyhTXbnyfqpha9MKlMaKv80x76xw+/Q==
X-Received: by 2002:ac8:2d69:: with SMTP id o38mr28339674qta.169.1559846692179;
        Thu, 06 Jun 2019 11:44:52 -0700 (PDT)
X-Received: by 2002:ac8:2d69:: with SMTP id o38mr28339618qta.169.1559846691179;
        Thu, 06 Jun 2019 11:44:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559846691; cv=none;
        d=google.com; s=arc-20160816;
        b=TV1S35aakmMFMVAk9ETx9EJ6+zLA+HOz6+17O9reb/xCh1hSrxypl9Q/8760XZbDZL
         DN6WNW5oJCvZfCRJTl1nlVzCfcMmr0GeHI/bjDPu09DUiccMG3jCcoKelW9xl7NHS2HV
         N737VNFW/BgUqu77YARQSJf2a64HwHH0cR7iQB232xWbrPJ4mk59O+IU1qXOLeJhS0Qe
         TxDQjWAD15dZib36TYYWkLsjsyV7Mu60kOb4xKtYCdlFnSBPYiRiUOsGa412UU9o/Ofp
         AOVLEYSdQDHmAIEAsPNiMsW8eis/VU46ZiOM7FyGp6TzxeaRw70iituTOMfCOo//Mt9m
         Illw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=nVAUpO+Ga9NYec9bVUlta7oVxGoK2kbyT+1hUTcsX2M=;
        b=KT1Nj6NShsr7O8RUldkkexCpEqQzhpp6rD0i5LegdQLenqv28d3P+XRwxgR/Q0Da0B
         hf+uFHx+GvFZ1grptTQ1w3qSV3rD5YNKAR6I/hDoj4yY4P03xEGXbDemPEzKZg965xXI
         Y2qBaUHH9kqpjDg9Ip0wWWS8ddbyRAyouqDviSCjzyc5SaGiZESJGNZmyNN4bkCMuQEv
         mnKNdQgieQ2068QK2KvIUjaDr5AeWziUd/y+hPyf3Azrn1b/vl+FpHQyQcJgQXX/BXbX
         qQZhpQo3+oRNd3XTAh8yR4bCh0G9wi2sSBF8A2/NBoKO9MPm906vmSKHOPVDyazA3JEc
         cEfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=WgY47IGZ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o18sor1430337qke.38.2019.06.06.11.44.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 11:44:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=WgY47IGZ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=nVAUpO+Ga9NYec9bVUlta7oVxGoK2kbyT+1hUTcsX2M=;
        b=WgY47IGZKwCscEhmp/e1SH9Qdm9WcIPMWuHYPXHgf1Mke+ckY9UbBST6Yg3085YiGZ
         dcNR69Qrxwy8qK6hBe1Ue5L8mtizg8fgMYwpWlMDyzW4sJZM/YSdC7J0JCTA28fxl76n
         +LUXoIcNaktF9sMJ+8Tn9DSETKfpEaKYxfe0XcgkeYX9s25CuXN7zKQgSo93XiKMF8Ia
         uyDd1lBZZfguzvqyPsXI94pwdw1QaF2JfejyOIr3xXYPHSXV060VLQByKbXFlIqKGo61
         qP5nXZ0Y1Bzv69Slh4GEkWmlgkAOHNc2qWHPy706QC/VjevthD4d+IaR7G2877aUIVh2
         s12Q==
X-Google-Smtp-Source: APXvYqy0lCJbH1BvPYOo0rOmLYXG/g+I9HtsZNodsB/KhCTBbD6BMVIIs/zFfGrbgs1cd5AeX+0slQ==
X-Received: by 2002:a05:620a:16cc:: with SMTP id a12mr32024122qkn.256.1559846690927;
        Thu, 06 Jun 2019 11:44:50 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id q36sm1951613qtc.12.2019.06.06.11.44.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 11:44:46 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYxNV-0008J3-Ud; Thu, 06 Jun 2019 15:44:45 -0300
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
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v2 hmm 11/11] mm/hmm: Remove confusing comment and logic from hmm_release
Date: Thu,  6 Jun 2019 15:44:38 -0300
Message-Id: <20190606184438.31646-12-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190606184438.31646-1-jgg@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
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
---
 mm/hmm.c | 28 +++++++++-------------------
 1 file changed, 9 insertions(+), 19 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 709d138dd49027..3a45dd3d778248 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -136,26 +136,16 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 	WARN_ON(!list_empty(&hmm->ranges));
 	mutex_unlock(&hmm->lock);
 
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
@@ -287,7 +277,7 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror)
 	struct hmm *hmm = mirror->hmm;
 
 	down_write(&hmm->mirrors_sem);
-	list_del_init(&mirror->list);
+	list_del(&mirror->list);
 	up_write(&hmm->mirrors_sem);
 	hmm_put(hmm);
 	memset(&mirror->hmm, POISON_INUSE, sizeof(mirror->hmm));
-- 
2.21.0

