Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C25A5C282C2
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:00:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A49D20818
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:00:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A49D20818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57FFB8E00DF; Wed,  6 Feb 2019 13:00:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 504BD8E00D1; Wed,  6 Feb 2019 13:00:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 385928E00DF; Wed,  6 Feb 2019 13:00:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id DB7588E00D1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 13:00:05 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id f3so5123731pgq.13
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 10:00:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=S/67tRKTlxOYP+sBkMKRSV2F+ob/jIFmPIustnrAhjE=;
        b=AX3ur8O1POIg9m4Q1CjXvfUz09VemIgsr3QzKY2xs0B5h4VrC5Z7uWqdPCua9ggofw
         9vDKgVtu+k7b+cY0z6lr7H/aO2WCIUb4q7qiVrrbd4j3r4QTlpUikdUJUWDXkqe0Hpri
         NIFeZ4AqTHDVw3ANTbHeongTevOci8k08koq/JnalMnFuJ67Rz8QUPHHI2Wp2w8OQ6E1
         tzXac8wXrgdrPMan9X3l85KjXhvdoTytuxLcORy9+obW4SOoMJptr8EbFg2sM+E7TcCa
         RM9a+qJLKdVaogvIPnhTQi/73qC0JmepKPGvOUKnYC8DbJc292FDXri3g6piNTL77Qw1
         RfDQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: AHQUAuZM1OKFXqgSrtk0qPabXLy/dbSLdZ5K+YLzMNSavsmXo4oHsMJR
	rYgc/IryEnz443JEl0Lv+4apvleht4NTsKF/8rt2yOtQL2tnBg+NP3awyKekhe9pyokDfdq3f4g
	nhRy3VpHWDsn/oXbNN2oIvrSO+FW0n9at6Qex2HoX7dP1wVdR0aDEnNb3qtZCY3Y=
X-Received: by 2002:aa7:8245:: with SMTP id e5mr2838401pfn.172.1549476005526;
        Wed, 06 Feb 2019 10:00:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZQ5VeiRRV4mB20kYFBTxkeRII4c9gv2PsW5igEV69LTci9Z4hDhz7G0ODD5hl/PBTwvo3g
X-Received: by 2002:aa7:8245:: with SMTP id e5mr2838319pfn.172.1549476004412;
        Wed, 06 Feb 2019 10:00:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549476004; cv=none;
        d=google.com; s=arc-20160816;
        b=ThTTjwXawhtg05YqseiAeoeZIPoxStmR/vIwlfn8Xma6DiApwoxVXLa4r4J8CMXUPB
         jWVsQz+yaAhgMwhnukcNRc5TuP0TijcG8C2zOTDS8wGasiPRarf0nBHajJysgtyafLqq
         2GITyVlNHVNo5NeALEXIb8Mv+xBTNYqWtXrEEhnMTAkmM4DJfsnhlrpYmlkD0Io7Mwu8
         vtjeGfU8FuLllAZ1k0WV3kVnxYFXqH2a6aAhDxk1hEYZBGx/52Qdtjh0aPWyBUp6kos+
         BjLTZzKD2GhWXS2XMjjwKLAVvj+2sbcLlV7FBZ4MdfL+J/2GTz9c/lJNoUgCIlHqwIyY
         d31g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=S/67tRKTlxOYP+sBkMKRSV2F+ob/jIFmPIustnrAhjE=;
        b=h92dAcDcomElDHK4k2Ab/17Czn5ZvEr7XSd5AZI/MHv+bpQ2n4UL9rSelTQCLr5B+S
         qmbKI0OLWuIOtOCZZKOLC94mSCo8qblsXiAVCAuD6Y/e0+viR7e8758sSf5b19M083/U
         vkHwYWJDXT+CDBu6iSoxJE6I3VJ5nheMAQVAhj+Y3Oh2kdZklOw1vnxkG9PSMmhMb6VB
         +bhPMGrsQWENOGWEHRE7VJlTBHcuukU7DJZanlbCJfXgFfxYMh4g+mzZoH2oPAVABiil
         f9OlpMMU5Dku5bczSp7jKrC7PQiPjjVbJLWplbUvm6lsVb/UUmvQj3exvP9twnlHrYqr
         dNBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id j20si5479577pgb.520.2019.02.06.10.00.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 10:00:04 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Wed, 06 Feb 2019 19:00:02 +0100
Received: from linux-r8p5.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Wed, 06 Feb 2019 17:59:46 +0000
From: Davidlohr Bueso <dave@stgolabs.net>
To: jgg@ziepe.ca,
	akpm@linux-foundation.org
Cc: dledford@redhat.com,
	jgg@mellanox.com,
	jack@suse.cz,
	willy@infradead.org,
	ira.weiny@intel.com,
	linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	dave@stgolabs.net,
	dennis.dalessandro@intel.com,
	mike.marciniszyn@intel.com,
	Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 3/6] drivers/IB,qib: optimize mmap_sem usage
Date: Wed,  6 Feb 2019 09:59:17 -0800
Message-Id: <20190206175920.31082-4-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190206175920.31082-1-dave@stgolabs.net>
References: <20190206175920.31082-1-dave@stgolabs.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The driver uses mmap_sem for both pinned_vm accounting and
get_user_pages(). Because rdma drivers might want to use
gup_longterm() in the future we still need some sort of
mmap_sem serialization (as opposed to removing it entirely
by using gup_fast()). Now that pinned_vm is atomic the
writer lock can therefore be converted to reader.

This also fixes a bug that __qib_get_user_pages was not
taking into account the current value of pinned_vm.

Cc: dennis.dalessandro@intel.com
Cc: mike.marciniszyn@intel.com
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 drivers/infiniband/hw/qib/qib_user_pages.c | 73 +++++++++++-------------------
 1 file changed, 27 insertions(+), 46 deletions(-)

diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index c6c81022d313..ef8bcf366ddc 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -49,43 +49,6 @@ static void __qib_release_user_pages(struct page **p, size_t num_pages,
 	}
 }
 
-/*
- * Call with current->mm->mmap_sem held.
- */
-static int __qib_get_user_pages(unsigned long start_page, size_t num_pages,
-				struct page **p)
-{
-	unsigned long lock_limit;
-	size_t got;
-	int ret;
-
-	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
-
-	if (num_pages > lock_limit && !capable(CAP_IPC_LOCK)) {
-		ret = -ENOMEM;
-		goto bail;
-	}
-
-	for (got = 0; got < num_pages; got += ret) {
-		ret = get_user_pages_longterm(start_page + got * PAGE_SIZE,
-					      num_pages - got,
-					      FOLL_WRITE | FOLL_FORCE,
-					      p + got, NULL);
-		if (ret < 0)
-			goto bail_release;
-	}
-
-	atomic64_add(num_pages, &current->mm->pinned_vm);
-
-	ret = 0;
-	goto bail;
-
-bail_release:
-	__qib_release_user_pages(p, got, 0);
-bail:
-	return ret;
-}
-
 /**
  * qib_map_page - a safety wrapper around pci_map_page()
  *
@@ -137,26 +100,44 @@ int qib_map_page(struct pci_dev *hwdev, struct page *page, dma_addr_t *daddr)
 int qib_get_user_pages(unsigned long start_page, size_t num_pages,
 		       struct page **p)
 {
+	unsigned long locked, lock_limit;
+	size_t got;
 	int ret;
 
-	down_write(&current->mm->mmap_sem);
+	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
+	locked = atomic64_add_return(num_pages, &current->mm->pinned_vm);
 
-	ret = __qib_get_user_pages(start_page, num_pages, p);
+	if (num_pages > lock_limit && !capable(CAP_IPC_LOCK)) {
+		ret = -ENOMEM;
+		goto bail;
+	}
 
-	up_write(&current->mm->mmap_sem);
+	down_read(&current->mm->mmap_sem);
+	for (got = 0; got < num_pages; got += ret) {
+		ret = get_user_pages_longterm(start_page + got * PAGE_SIZE,
+					      num_pages - got,
+					      FOLL_WRITE | FOLL_FORCE,
+					      p + got, NULL);
+		if (ret < 0) {
+			up_read(&current->mm->mmap_sem);
+			goto bail_release;
+		}
+	}
+	up_read(&current->mm->mmap_sem);
 
+	return 0;
+bail_release:
+	__qib_release_user_pages(p, got, 0);
+bail:
+	atomic64_sub(num_pages, &current->mm->pinned_vm);
 	return ret;
 }
 
 void qib_release_user_pages(struct page **p, size_t num_pages)
 {
-	if (current->mm) /* during close after signal, mm can be NULL */
-		down_write(&current->mm->mmap_sem);
-
 	__qib_release_user_pages(p, num_pages, 1);
 
-	if (current->mm) {
+	/* during close after signal, mm can be NULL */
+	if (current->mm)
 		atomic64_sub(num_pages, &current->mm->pinned_vm);
-		up_write(&current->mm->mmap_sem);
-	}
 }
-- 
2.16.4

