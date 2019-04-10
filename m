Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFA18C10F0E
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 02:46:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FBAE20857
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 02:46:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FBAE20857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AF196B0003; Tue,  9 Apr 2019 22:46:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05CEA6B0005; Tue,  9 Apr 2019 22:46:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8EBF6B0006; Tue,  9 Apr 2019 22:46:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id C77E16B0003
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 22:46:55 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id f11so307916otl.20
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 19:46:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=JvrZJYm1SW+A7krIN3Wqu100/PlRw/ToSA51zEq6mqU=;
        b=Q8aGPzMgnX97IgcrVmkZUZTSZBPY8yvdy1oCmWHqOnxfhoJ9xgb8sjeX9poxq+3QQ9
         9xIt00rYBOuutqjyaOSHe5MWNP7PbQqtOhEm9CJpM8WcXEiiMax6/7iRzuyy0jYKGTFG
         3ueTFYXirId00xGiL7qLymCED0PSpPxa1cI0NPekVi7WLg+RKF/bfv9jzlOrH1QKQz5k
         bff2hOYQGrtp21RSOFRBkb05BXhT42QvSzSnhNqlUqJP80hgta1bAeT78IhMRRAXMaOs
         stPUfrIZj8o3TPBFAsTh/uQBhrjZX66gnMgNw3UGysyQpQlVS3zXboRZEiQOduVN3tQF
         TUuw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
X-Gm-Message-State: APjAAAUoWzc+VQzar1PbZUvAxMSZ8A064fKi1Nv5K+rmEc/IwZI8miag
	LDXhQ0mxUWqWQGZXZ2DJ8j7meUJNFiMsnKdLe1W2q/QB5hIwvcQWZs1sDv6UgPqwP6oPjS/Ruw+
	wggiG4pwMzKaBFYP11tbdC1UxUY3yO5Pr9E+pbo5jb4YeB9qxD4W/Bo/t47KVyyPMOg==
X-Received: by 2002:aca:ed88:: with SMTP id l130mr1052574oih.70.1554864415476;
        Tue, 09 Apr 2019 19:46:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwq+wHbfeF9L45bMVS5hqoG/kSrGvcvucTGpN0VUiLd6SebZ7Ia8j/74ZJzyLH9gEIvz1qw
X-Received: by 2002:aca:ed88:: with SMTP id l130mr1052541oih.70.1554864414480;
        Tue, 09 Apr 2019 19:46:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554864414; cv=none;
        d=google.com; s=arc-20160816;
        b=LL+mw4iG0KvmFDDR8j1IZbs/U8Y/hZYzgCNOQjxgdv/kRP31IEfVRUGhDoR1Yr12Am
         5vI2H3CwqILgpEokQ9hYaGJV6bXIL3Ni4Onv1nXSh2xU+Bz4D/v1B5FvHgjdVxOR3mXi
         BBzrL6ypQkljGuouEGFy02r30vlafyhLAAH4wtKZdcMO0OS6jPgc3gCdboIeRINlyXTb
         DrtSNQkiPKJchgj+LtCsBBUynykurUdA2pgDYwpMIwNuFV4Xr/e2BrWPju891bH47XyU
         El1I9ULefbNbHxMn5XtKAvGSS6DKNETZj6M/dhZhSErsKwOuOrWw8K0q+028mbw1Vhhe
         3xVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=JvrZJYm1SW+A7krIN3Wqu100/PlRw/ToSA51zEq6mqU=;
        b=fukH3l1KvXsL5TVUE50SiUCz5C8cSnskqZsPPuuMStOG1sNVrxmUSKyHYuxFJ4ma9z
         fodrakViP5uYHbcP4ho20/FMDhgC7c1ClW2XQeG+jGAJPq3kOm89JydwFH0O7JK6I5ju
         KG8d/lYsCuK7clC8X2g+Zy/F+MpOTXQnaR+MYrfI/Luh2oeSh//fchLEu0zXreo5ljc/
         zuiF4BIwCVgmncQ51A3xePjeFmkUzt/6BbQdU4AEIw2gWfSOI+5hjcqSW/KcjcA+qX10
         G4DGTBUxT6WVwR613mlavQbRCHG5Dsed0VQL9O8MCUvGEIaRIulDytRX3zEbREjmIs4B
         xEKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id p10si12570869oia.172.2019.04.09.19.46.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 19:46:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from DGGEMS412-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 5031411A6EBB1533747E;
	Wed, 10 Apr 2019 10:46:49 +0800 (CST)
Received: from huawei.com (10.90.53.225) by DGGEMS412-HUB.china.huawei.com
 (10.3.19.212) with Microsoft SMTP Server id 14.3.408.0; Wed, 10 Apr 2019
 10:46:47 +0800
From: Yufen Yu <yuyufen@huawei.com>
To: <mike.kravetz@oracle.com>, <linux-mm@kvack.org>
CC: <kirill.shutemov@linux.intel.com>, <n-horiguchi@ah.jp.nec.com>,
	<mhocko@kernel.org>
Subject: [PATCH] hugetlbfs: fix protential null pointer dereference
Date: Wed, 10 Apr 2019 10:50:37 +0800
Message-ID: <20190410025037.144872-1-yuyufen@huawei.com>
X-Mailer: git-send-email 2.16.2.dirty
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.90.53.225]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

After commit 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map"),
i_mapping->private_data will be NULL for mode that is not regular and link.
Then, it might cause NULL pointer derefernce in hugetlb_reserve_pages()
when do_mmap. We can avoid protential null pointer dereference by
judging whether it have been allocated.

Fixes: 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map")
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Yufen Yu <yuyufen@huawei.com>
---
 mm/hugetlb.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 97b1e0290c66..15e4baf2aa7d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4465,6 +4465,8 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 */
 	if (!vma || vma->vm_flags & VM_MAYSHARE) {
 		resv_map = inode_resv_map(inode);
+		if (!resv_map)
+			return -EOPNOTSUPP;
 
 		chg = region_chg(resv_map, from, to);
 
-- 
2.16.2.dirty

