Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA6BAC282C2
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:00:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3FA220818
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:00:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3FA220818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 333478E00E5; Wed,  6 Feb 2019 13:00:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BDB88E00D1; Wed,  6 Feb 2019 13:00:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1369E8E00E5; Wed,  6 Feb 2019 13:00:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B7DF88E00D1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 13:00:32 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id t26so5106908pgu.18
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 10:00:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=waI1WmmPLoTveHPlnnfdMx1fmeBn1F1egAaxgnJemTY=;
        b=FwMZeAFPYKA/s37JGGLln0UFq/W0z0MfStDaOnSbTqzJJ+BnOES1F7QXNs8fSZXX/o
         /2cUx+kZ3y7qQtrvIWC5KQRup8lFXmDUgN+wRwiY5YKrvbAtbQvBh0fDnw/+jZaAHPxQ
         6i0l+D0wGuS8U0rj+UUcocftkjpWOlR7SJaVWM10FUxP/PsEQ9HMw5tkF1keqyahY+Y7
         2iTYQZM/hAL4GybQmpwMGbtDEoeFOhovzHKe70g6HZtBpf66aZi8T7ppy7i49kKm+/Hx
         hjRu5G/ET9hFoTO/+Am6+g69XVCE8XcF4mtG8LvBdRy/fMeqqidVJHlObrfMxHEfzg/U
         R2vA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: AHQUAuYflbHIgOuaS1GIk7C23P9HB3hmCkzKTC8Rq/fjpTCa9CTmsykC
	WHrxtsLpso7mvEYUpMc78ojfggL3NANBGsiL7hZM4rI+sQosSmUdiVksaryij8EnTnwzkWFsg81
	6o2KwH9JHM+lgNRk7wD1pZNH11w3KWkWr9i422J88tDq5FBXlfT5AUmZsadAIIgI=
X-Received: by 2002:a17:902:6a4:: with SMTP id 33mr11734311plh.99.1549476032379;
        Wed, 06 Feb 2019 10:00:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYpRnvBuCS84Rlk7UkAOi5ApctAgfUdMGC0/olJKLH577QUt2oeLH3fjRxWdSU0o+hIFuCk
X-Received: by 2002:a17:902:6a4:: with SMTP id 33mr11734226plh.99.1549476031438;
        Wed, 06 Feb 2019 10:00:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549476031; cv=none;
        d=google.com; s=arc-20160816;
        b=S0C8pKsl3dHsHcqciHD8gH97vjyaBCxboZH0K0hgjwKzwmx8PcLl3f5pBWaf9+IBw7
         HuMDsXuU1SdWTOsflueKeSeumoB08prehnilVvSc9388UMkxdS11F5vb0F6nFhMLgPgR
         iZKzEkokgqs/3YZT4yD8e5UCNXzOWCxOTAt5BzXUItbKqL5svY6xOWgS5HrWbEhKHZvV
         Ax/yYYIu9c5fiwrL3q2NciKxQKwDvuxkbYEsarutmlIewX5B+yjkD9BSOmtznJFXMxzk
         z7KaNIn+UC0JEDGV9NiL6vc+ssYv8wl/o2+1QFiS/P2/e1NqFD0cgVRYGcCcOjPQVN9Z
         21dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=waI1WmmPLoTveHPlnnfdMx1fmeBn1F1egAaxgnJemTY=;
        b=kpYLe6OhjrHINv1BdjHh18hKbsjrvULtsjaNDp/bs88hXuIGgc45txdTqB/3t0E9e9
         rKwZ0Vd1yL4PtJ5ER54M30WjFfatkSnjQXTpMHLJrfTbzjekFEQ+f77DVFQJDaHHv9jI
         VKtuCoq2K5zj2R+f9fZiGvBZin5fq6BnN9NIfEtUJD5TM8KYEFDq/T3wZNLbGcRWtClC
         0FVtp+UENde1JfPPC+gwCl9cy9aa87pzfRqiMsToSdfGfjgY/6vymGU5vcwha6SIWTF+
         IVL+7f4DWhNEweAS6cpojjTEhyfj6HqJnhS/ZmJ6AkXw60CUFABgnP7ai8CtDmQWdZ8y
         zd+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id d189si6909175pfa.70.2019.02.06.10.00.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 10:00:31 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Wed, 06 Feb 2019 19:00:29 +0100
Received: from linux-r8p5.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Wed, 06 Feb 2019 17:59:58 +0000
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
	Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 6/6] drivers/IB,core: reduce scope of mmap_sem
Date: Wed,  6 Feb 2019 09:59:20 -0800
Message-Id: <20190206175920.31082-7-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190206175920.31082-1-dave@stgolabs.net>
References: <20190206175920.31082-1-dave@stgolabs.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

ib_umem_get() uses gup_longterm() and relies on the lock to
stabilze the vma_list, so we cannot really get rid of mmap_sem
altogether, but now that the counter is atomic, we can get of
some complexity that mmap_sem brings with only pinned_vm.

Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 drivers/infiniband/core/umem.c | 41 ++---------------------------------------
 1 file changed, 2 insertions(+), 39 deletions(-)

diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index 678abe1afcba..b69d3efa8712 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -165,15 +165,12 @@ struct ib_umem *ib_umem_get(struct ib_udata *udata, unsigned long addr,
 
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 
-	down_write(&mm->mmap_sem);
-	new_pinned = atomic64_read(&mm->pinned_vm) + npages;
+	new_pinned = atomic64_add_return(npages, &mm->pinned_vm);
 	if (new_pinned > lock_limit && !capable(CAP_IPC_LOCK)) {
-		up_write(&mm->mmap_sem);
+		atomic64_sub(npages, &mm->pinned_vm);
 		ret = -ENOMEM;
 		goto out;
 	}
-	atomic64_set(&mm->pinned_vm, new_pinned);
-	up_write(&mm->mmap_sem);
 
 	cur_base = addr & PAGE_MASK;
 
@@ -233,9 +230,7 @@ struct ib_umem *ib_umem_get(struct ib_udata *udata, unsigned long addr,
 umem_release:
 	__ib_umem_release(context->device, umem, 0);
 vma:
-	down_write(&mm->mmap_sem);
 	atomic64_sub(ib_umem_num_pages(umem), &mm->pinned_vm);
-	up_write(&mm->mmap_sem);
 out:
 	if (vma_list)
 		free_page((unsigned long) vma_list);
@@ -258,25 +253,12 @@ static void __ib_umem_release_tail(struct ib_umem *umem)
 		kfree(umem);
 }
 
-static void ib_umem_release_defer(struct work_struct *work)
-{
-	struct ib_umem *umem = container_of(work, struct ib_umem, work);
-
-	down_write(&umem->owning_mm->mmap_sem);
-	atomic64_sub(ib_umem_num_pages(umem), &umem->owning_mm->pinned_vm);
-	up_write(&umem->owning_mm->mmap_sem);
-
-	__ib_umem_release_tail(umem);
-}
-
 /**
  * ib_umem_release - release memory pinned with ib_umem_get
  * @umem: umem struct to release
  */
 void ib_umem_release(struct ib_umem *umem)
 {
-	struct ib_ucontext *context = umem->context;
-
 	if (umem->is_odp) {
 		ib_umem_odp_release(to_ib_umem_odp(umem));
 		__ib_umem_release_tail(umem);
@@ -285,26 +267,7 @@ void ib_umem_release(struct ib_umem *umem)
 
 	__ib_umem_release(umem->context->device, umem, 1);
 
-	/*
-	 * We may be called with the mm's mmap_sem already held.  This
-	 * can happen when a userspace munmap() is the call that drops
-	 * the last reference to our file and calls our release
-	 * method.  If there are memory regions to destroy, we'll end
-	 * up here and not be able to take the mmap_sem.  In that case
-	 * we defer the vm_locked accounting a workqueue.
-	 */
-	if (context->closing) {
-		if (!down_write_trylock(&umem->owning_mm->mmap_sem)) {
-			INIT_WORK(&umem->work, ib_umem_release_defer);
-			queue_work(ib_wq, &umem->work);
-			return;
-		}
-	} else {
-		down_write(&umem->owning_mm->mmap_sem);
-	}
 	atomic64_sub(ib_umem_num_pages(umem), &umem->owning_mm->pinned_vm);
-	up_write(&umem->owning_mm->mmap_sem);
-
 	__ib_umem_release_tail(umem);
 }
 EXPORT_SYMBOL(ib_umem_release);
-- 
2.16.4

