Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DBAFC43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 18:19:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54B4F20838
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 18:19:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54B4F20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E52D78E0004; Sat,  2 Mar 2019 13:19:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E02938E0001; Sat,  2 Mar 2019 13:19:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF1258E0004; Sat,  2 Mar 2019 13:19:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id A85108E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 13:19:58 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id n197so1119181qke.0
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 10:19:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=ViznYoTxRWLy/JPq/xFr+4uRX6PWtqibQBxeBIYuo1Y=;
        b=a0Yyul3WOocKoe/4On0RSaHsG6qrH4WS/bu4YYxRZ6N5mipH2R1KW5P2xH92MOB6RM
         x8b1VoTUSEnbljohRfrAcRY6SdPIhXpAS+UbQA83GfFeTPhxiU/2b7j5M1nkQu9LljUU
         OyvhL2x6MENbOBnXmpPov9OPMsnmVoW8Aa084lKjnkZ4xPHlPB3GVPEjqIlTY2P3XSoB
         nuVlbht8hwbNdOwy1Di/7ezSMt25wTSr9NpChO81g3Z+/ouVGZAQap7Y924AE958/UP8
         he1qVEvOvaMNqr4Zwt2otas4qphk5Q8j4Pcw4kPYexwElyQfgsGC4vmAiqSg84kAUvxM
         zPXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVj0X3fVQUtlQJje7FgoRaJ8R+cWQhGA2oMdQtl3W8cSLxjcKzr
	tMDV6467bbli6haksOUXdaCb8n6WAlhK6SmO/qyD9jenOHzWub1SMh7PA7lLqyE9oJKKAx3BELJ
	V59zoipS1WbKhQ0YkFEvFDE1lvVqUIiUeXorHFQ2IwU9p1uWY2uBE8anrEc6im1YYhw==
X-Received: by 2002:ad4:5141:: with SMTP id g1mr8546215qvq.236.1551550798441;
        Sat, 02 Mar 2019 10:19:58 -0800 (PST)
X-Google-Smtp-Source: APXvYqw3ZoKZZEvRzfNg7f3U8/H6BHqMUbDptw8fo7sJDZTiq9FhlbN+iKV8qB00qeuppYHNp3H2
X-Received: by 2002:ad4:5141:: with SMTP id g1mr8546170qvq.236.1551550797374;
        Sat, 02 Mar 2019 10:19:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551550797; cv=none;
        d=google.com; s=arc-20160816;
        b=A+lxsXzCmVhQ58UYep1tcqztZ+MghWTOGjlqYozWREmbo90XFF3xL+OMRzuq22uvuK
         SzD+VP/jSwPsxui5z3SrkNt7yf18TeoKtj/I1FUydtwN6yuDu6R+3LArm3Ece61Wd6If
         +owukpNKjJa72CQV5DyAP5moYzi/icoQjKyod7uKCPwurp/TOPNMbYN8RQXWKcSHt4Et
         KY7shto94m1Arvb8h06EJvismZ0TtzErhxGvfNVq2FU0HdS6xeqkElu6VzoB6LE6HKh/
         Zf4T1ePgTdXIv7Q0g1vuGttSloca7D5oEiBVUPE3z9kUGArPtrVy7d/ggd+81vEIEr6G
         cTHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=ViznYoTxRWLy/JPq/xFr+4uRX6PWtqibQBxeBIYuo1Y=;
        b=0TafmDps3qYfuCQPSVkuDgmpU0ImhO1LJY5ggLbT97kVM4aJ2zjBs9PBMC6aZ7BKF9
         +Grn6r+o+hhK24qraJ+mYVfPTM1nWI+e8fdVpFuHxTO5xVvivwrWT/4lOXJeQNIyrJ5D
         QCkiGXHGq1wWbOeeiJNdUsv8MaXwspzDoSeVH29K5qAH3KR4iqK66DkT7KwkOtDtT4h5
         c8vUfPOLXTP9s8uzr8nv9SFmX91e1WckMRQBpbU3wZ4J6uhhFU63vTIHx2f+0ndWNKp/
         QDzM8ifrx6FoSBhlA1Mc4yrfUSP8mEPE5C4v7sq3E1yHZYu4Pag+rBRrpifcWtrl/o/4
         Nidw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t61si779949qtd.142.2019.03.02.10.19.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 10:19:57 -0800 (PST)
Received-SPF: pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 65E373092665;
	Sat,  2 Mar 2019 18:19:56 +0000 (UTC)
Received: from dustball.brq.redhat.com (unknown [10.43.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 23FA8600C8;
	Sat,  2 Mar 2019 18:19:49 +0000 (UTC)
From: Jan Stancek <jstancek@redhat.com>
To: linux-mm@kvack.org,
	akpm@linux-foundation.org,
	willy@infradead.org,
	peterz@infradead.org,
	riel@surriel.com,
	mhocko@suse.com,
	ying.huang@intel.com,
	jrdr.linux@gmail.com,
	jglisse@redhat.com,
	aneesh.kumar@linux.ibm.com,
	david@redhat.com,
	aarcange@redhat.com,
	raquini@redhat.com,
	rientjes@google.com,
	kirill@shutemov.name,
	mgorman@techsingularity.net,
	jstancek@redhat.com
Cc: linux-kernel@vger.kernel.org
Subject: [PATCH v2] mm/memory.c: do_fault: avoid usage of stale vm_area_struct
Date: Sat,  2 Mar 2019 19:19:39 +0100
Message-Id: <a5234d11b8cc158352a2f97fc33aa9ad90bb287b.1551550112.git.jstancek@redhat.com>
In-Reply-To: <20190302171043.GP11592@bombadil.infradead.org>
References: <20190302171043.GP11592@bombadil.infradead.org>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Sat, 02 Mar 2019 18:19:56 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

LTP testcase mtest06 [1] can trigger a crash on s390x running 5.0.0-rc8.
This is a stress test, where one thread mmaps/writes/munmaps memory area
and other thread is trying to read from it:

  CPU: 0 PID: 2611 Comm: mmap1 Not tainted 5.0.0-rc8+ #51
  Hardware name: IBM 2964 N63 400 (z/VM 6.4.0)
  Krnl PSW : 0404e00180000000 00000000001ac8d8 (__lock_acquire+0x7/0x7a8)
  Call Trace:
  ([<0000000000000000>]           (null))
   [<00000000001adae4>] lock_acquire+0xec/0x258
   [<000000000080d1ac>] _raw_spin_lock_bh+0x5c/0x98
   [<000000000012a780>] page_table_free+0x48/0x1a8
   [<00000000002f6e54>] do_fault+0xdc/0x670
   [<00000000002fadae>] __handle_mm_fault+0x416/0x5f0
   [<00000000002fb138>] handle_mm_fault+0x1b0/0x320
   [<00000000001248cc>] do_dat_exception+0x19c/0x2c8
   [<000000000080e5ee>] pgm_check_handler+0x19e/0x200

page_table_free() is called with NULL mm parameter, but because
"0" is a valid address on s390 (see S390_lowcore), it keeps
going until it eventually crashes in lockdep's lock_acquire.
This crash is reproducible at least since 4.14.

Problem is that "vmf->vma" used in do_fault() can become stale.
Because mmap_sem may be released, other threads can come in,
call munmap() and cause "vma" be returned to kmem cache, and
get zeroed/re-initialized and re-used:

handle_mm_fault                           |
  __handle_mm_fault                       |
    do_fault                              |
      vma = vmf->vma                      |
      do_read_fault                       |
        __do_fault                        |
          vma->vm_ops->fault(vmf);        |
            mmap_sem is released          |
                                          |
                                          | do_munmap()
                                          |   remove_vma_list()
                                          |     remove_vma()
                                          |       vm_area_free()
                                          |         # vma is released
                                          | ...
                                          | # same vma is allocated
                                          | # from kmem cache
                                          | do_mmap()
                                          |   vm_area_alloc()
                                          |     memset(vma, 0, ...)
                                          |
      pte_free(vma->vm_mm, ...);          |
        page_table_free                   |
          spin_lock_bh(&mm->context.lock);|
            <crash>                       |

Cache mm_struct to avoid using potentially stale "vma".

[1] https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/mem/mtest06/mmap1.c

Signed-off-by: Jan Stancek <jstancek@redhat.com>
---
 mm/memory.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index e11ca9dd823f..6c1afc1ece50 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3517,10 +3517,13 @@ static vm_fault_t do_shared_fault(struct vm_fault *vmf)
  * but allow concurrent faults).
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
+ * If mmap_sem is released, vma may become invalid (for example
+ * by other thread calling munmap()).
  */
 static vm_fault_t do_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
+	struct mm_struct *vm_mm = READ_ONCE(vma->vm_mm);
 	vm_fault_t ret;
 
 	/*
@@ -3561,7 +3564,7 @@ static vm_fault_t do_fault(struct vm_fault *vmf)
 
 	/* preallocated pagetable is unused: free it */
 	if (vmf->prealloc_pte) {
-		pte_free(vma->vm_mm, vmf->prealloc_pte);
+		pte_free(vm_mm, vmf->prealloc_pte);
 		vmf->prealloc_pte = NULL;
 	}
 	return ret;
-- 
1.8.3.1

