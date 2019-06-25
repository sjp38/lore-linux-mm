Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65AECC48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 23:53:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AD9920869
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 23:53:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="VkTn5AAk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AD9920869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF9028E0007; Tue, 25 Jun 2019 19:53:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA8718E0003; Tue, 25 Jun 2019 19:53:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9494A8E0007; Tue, 25 Jun 2019 19:53:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 729C78E0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 19:53:42 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id k10so1033021ywb.18
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:53:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=yjZXcMnfv52cV3iKAqHjSpI81GHA3MMnQyOdI5uEAgE=;
        b=DvJiSokM9IXl2IqgFtxXy7O+EUQgcD4y5mgxyQzb8cCdtlmtsLTZj2Vnm87qkQpV8S
         qIOibwuv4PqUNHDu29jnP3q0amzr+mKx/QIxHvIyzDpX5nij0oWwky20ZaWrwoAhLRem
         Fo8pBrDQAGwAfd4NzV/nhICcvaikmrMnq75fbZyGkSdYZzoy3GycyHAkNI5OKyYGTEtQ
         aO+HHk9KXJjfbwrrkIqADQyiUqprP7b8smc6xxdkvUprwuGNHfnNI87Er3/XcesAFuhU
         IcJjyaVpnUGFH2tbnQ/Y3P0fgpAayBsOouXQrVEh7Q6epLsYWtxWHR3Mjd51ud+zHoPj
         JpUQ==
X-Gm-Message-State: APjAAAWbebMYRcoFl7CqDyteI3dlZZ8HlZA66WCUiPZowlaieaiC0dUE
	XN2HIB764Fe0HRCnD1x7kQaRUs71ytc8bQMR2xJael1Iwqxl5VoQLoJZ1p9Pj1yQj3eMovTyIsf
	E1mSlmF3SMoSxuA+DYZG/vmorP1dMeLOHSHBTM+4N1YufC3YSgmxFoWrlKAEqcQ0ocA==
X-Received: by 2002:a81:23ca:: with SMTP id j193mr928347ywj.332.1561506822184;
        Tue, 25 Jun 2019 16:53:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydwtqjeI66/K9JNQwFWE98bfCPnt8xGURaejJfO4pVIsvKR4KWbn4u2WhJLMxIHop51GHV
X-Received: by 2002:a81:23ca:: with SMTP id j193mr928327ywj.332.1561506821560;
        Tue, 25 Jun 2019 16:53:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561506821; cv=none;
        d=google.com; s=arc-20160816;
        b=BTxzs1rBUJmu0bhDd8jRz/PMgiBlZUWCyPRLP9pcsAh/CS8Na4aMrQLVEb7Nr+oy2j
         kjPAUtRxTdZIRkv6d0V43p0xcLS7JY3XGptOpH4Q7RND4AqPWklvQ0gTqiGUgh44z0NS
         Syp/+sFmEIGzpU3FIiofx3S66m6nFKn0TeUSS0LPFQg8CM+vesDumdn0ySjGYNPo+8RW
         UGzuYWCPqH0pGa+H2+/RHYbCsrAodaHI5oQ8oRaJJRoYxmWVie4ofxjUH2NpvuHBMW/0
         vKiIJuXa/Tdny5EkxAfybr6NZLxusv0yv92KSkusUIEGHWp62nSlAFRzB97Wo6wQeZWe
         9Q4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=yjZXcMnfv52cV3iKAqHjSpI81GHA3MMnQyOdI5uEAgE=;
        b=ZRYO/zcDPtGNzLeXlU+MvkDPZCGLtMAlZUrWpXdmh5ik81xZtO9KKBU4yag7TEzWKP
         esbpBamUj7TDNPYGmSnsNoSpRNP1OGyPSjPMZSct8OhVd1m0PbgebAb2eaLpLI4Lg4Ty
         CfS7jW/hKg47sLzim1zWBYXPSnW7DUKIPJ0VzmlAzf1HYBvzP1Ic5V0/7DUWsojo8sdW
         j/J+HSD54LRueXgf117mvYdV0csMY3CQv0GUQGGHJrHwdcl4DKaokAeG9AboYeNlnq3r
         GCLvkIJ2GPlvCapwQ5efm6v1k+DfWMZv0P1VDXA+WMMBPU9F7rrFgQnVDsyGkTVAX7Jk
         XCkg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=VkTn5AAk;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id h3si2417349ybo.307.2019.06.25.16.53.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 16:53:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=VkTn5AAk;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5PNm1ef020477
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:53:41 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=yjZXcMnfv52cV3iKAqHjSpI81GHA3MMnQyOdI5uEAgE=;
 b=VkTn5AAkF2g/g6aMB4uoEcacFi6ioIEc0jHI+HVDO8/jXANbk9TQoPd/wTj8QI8dmV1v
 8oyl60BTncgPcmOw6/culgQ4kWqb1/6sgqTOldJJH4RSV4AT1ZFXmqoz2L0eExf8jbZ+
 Nw3kRVNGo3y5+heuWvOFhqIgFAE4Q3jtu7A= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2tbrn7958t-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:53:41 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 25 Jun 2019 16:53:40 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id D10D962E1F8B; Tue, 25 Jun 2019 16:53:38 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v7 4/4] uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT
Date: Tue, 25 Jun 2019 16:53:25 -0700
Message-ID: <20190625235325.2096441-5-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190625235325.2096441-1-songliubraving@fb.com>
References: <20190625235325.2096441-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-25_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=729 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906250195
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patches uses newly added FOLL_SPLIT_PMD in uprobe. This enables easy
regroup of huge pmd after the uprobe is disabled (in next patch).

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 kernel/events/uprobes.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index f7c61a1ef720..a20d7b43a056 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -153,7 +153,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct page_vma_mapped_walk pvmw = {
-		.page = old_page,
+		.page = compound_head(old_page),
 		.vma = vma,
 		.address = addr,
 	};
@@ -165,8 +165,6 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, mm, addr,
 				addr + PAGE_SIZE);
 
-	VM_BUG_ON_PAGE(PageTransHuge(old_page), old_page);
-
 	if (!orig) {
 		err = mem_cgroup_try_charge(new_page, vma->vm_mm, GFP_KERNEL,
 					    &memcg, false);
@@ -483,7 +481,7 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 retry:
 	/* Read the page with vaddr into memory */
 	ret = get_user_pages_remote(NULL, mm, vaddr, 1,
-			FOLL_FORCE | FOLL_SPLIT, &old_page, &vma, NULL);
+			FOLL_FORCE | FOLL_SPLIT_PMD, &old_page, &vma, NULL);
 	if (ret <= 0)
 		return ret;
 
-- 
2.17.1

