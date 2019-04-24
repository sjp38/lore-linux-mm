Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68A83C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:48:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 119C021904
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:48:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="z2J2zQm1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 119C021904
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B62E86B026F; Wed, 24 Apr 2019 10:48:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE8A76B0270; Wed, 24 Apr 2019 10:48:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AEDC6B0271; Wed, 24 Apr 2019 10:48:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 651AF6B026F
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:48:31 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j1so12004051pff.1
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:48:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hxAEAJpQEiJRKF6DZAKqIRywthdJujtzFgkkdE6iJSQ=;
        b=aj77WB8PeUHtwNsNsQe9q05rrbjYAkVTkAsTK7QcPB1SkqgSGszoMmTzKrYhsEfpwC
         NYnrQ3y4zpK0YZP4FtMQJVHXBHbSuaJZNH8yJmlZ8tabweCRNLl4XANY+TAjgmr7AEE0
         F72Y/EtQJSdXBQSvD/pD0EVDENJuiKqzH9u8eKAfMdVfjwpAODlmEpdqHOwZBjJnGRMn
         T4sMGH6MsE0pmRFPjIQqxZ9dzCIk0YxU827am5Dn9a21AInKoDf6EXruPpNFIz2s60ai
         DI2QVA1AGWOpOBWMPdWOCOKtg9X9kq3Ux9+QG+I5ixc8PZA+A47ltiEDR8qEiYPtKUgu
         I/zg==
X-Gm-Message-State: APjAAAUnLTm5is6DuyYsZZL7OxUG0iJYioo1sCRv3OuVGzke1IdzhTkw
	LZv4yTAlgf0v9FpGZ0Hv9BMBq7TjdfbbcdKJlUaahjAzwMZ+HxuPiAmoCIyiyfjvsAJLs+6zHrO
	ISY0Bbi4JGJvthX6Vw8KGEWCPL5aiFoU/d701qUQnBiVoN9K9BTVI22nJ1013Q8ijog==
X-Received: by 2002:aa7:8092:: with SMTP id v18mr33344214pff.35.1556117311031;
        Wed, 24 Apr 2019 07:48:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAWmgrT+qwd3f8av2ym6KgohNhtsOU+tHbkdeaPTZMdHFdhOut5/3X7n3pDM3o6KZGi/Pt
X-Received: by 2002:aa7:8092:: with SMTP id v18mr33344155pff.35.1556117310253;
        Wed, 24 Apr 2019 07:48:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556117310; cv=none;
        d=google.com; s=arc-20160816;
        b=Q7Nu+wSFXQ3z6XO8DZvPMmmfD6r3k2cuwBf0Ejv0WTEibk43etUDIFbv1dzF8DovKC
         G6VY0vUbHYiGQ34eAVWQzFiK7KTFiGeI+UoIY7BIWsANpbTQjyg7fpOXzIPlVi1hrOKc
         ag9GW+xlTSb94iyUrE8hX0WFu7T+eHsEvfFByVnXu+159WkT8b57eqZ8DAGRQor5osVT
         RWnOP4KugYBy7HyX2jjxOVIWhYgdqhD29Nd+pmtRFCJYKAWfhcAw2rL0NAbbe43fpuFw
         UlQk5iJ011mETiw8azZZ9Jt7yCmhPkAj0BjeqXdMLqC0Gj1T2a6jxzDcI/HHw1sTU++t
         q12A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=hxAEAJpQEiJRKF6DZAKqIRywthdJujtzFgkkdE6iJSQ=;
        b=tvHETl7V0zodPWjvZD9b6ylvpEf7seuBhN7GYAvYyQzNkk0jxQB1ivtVXs+38/tsxg
         5hVkxZWYclvVojFWwwRCzBPkjz2KlttWtJvMq1u+xuxhdH+u6yw7QvUJhgyiVLHQDgCv
         UwVP7sInLxU84YPXkBl+9TFi4RABvrEkaRGyd7aHrLpEDph6wGADeu/Y5PH+lXUdT6/i
         69FWxJsiHSht85gSQnRqMacw/WY//Hf9qSAB+ZPa6fx7+UapM0lovnl7rGTNyCSbIDAX
         6IDQLRfSlrRaJAjc5H1kfqEma6JIGTzyfn6EJh1pgOjzKySIxketm8Xh6f6PBeXEAlKs
         obmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=z2J2zQm1;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 68si4071726pla.86.2019.04.24.07.48.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 07:48:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=z2J2zQm1;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 488EF218FC;
	Wed, 24 Apr 2019 14:48:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556117309;
	bh=yaC4z6pPuPrGkaEqOFCoGfUgwHmBA84JrwfYkpdA/dk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=z2J2zQm1F65Q1FeZ6lfbOK2X/vhYFMW6l+vWWPP4EztRb2+2bpJHP5eiftIMzg3D/
	 KVWXRmZHQckD39rlCWAWgUcbHvUfx5wvEcQsZZRi2pHb84bhhazdEwj7q26tBRobrD
	 8hFnJLemq37AQEB/MqHBxF0nMTa6cbpXiQ+c5Qko=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 30/35] hugetlbfs: fix memory leak for resv_map
Date: Wed, 24 Apr 2019 10:47:04 -0400
Message-Id: <20190424144709.30215-30-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190424144709.30215-1-sashal@kernel.org>
References: <20190424144709.30215-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Mike Kravetz <mike.kravetz@oracle.com>

[ Upstream commit 58b6e5e8f1addd44583d61b0a03c0f5519527e35 ]

When mknod is used to create a block special file in hugetlbfs, it will
allocate an inode and kmalloc a 'struct resv_map' via resv_map_alloc().
inode->i_mapping->private_data will point the newly allocated resv_map.
However, when the device special file is opened bd_acquire() will set
inode->i_mapping to bd_inode->i_mapping.  Thus the pointer to the
allocated resv_map is lost and the structure is leaked.

Programs to reproduce:
        mount -t hugetlbfs nodev hugetlbfs
        mknod hugetlbfs/dev b 0 0
        exec 30<> hugetlbfs/dev
        umount hugetlbfs/

resv_map structures are only needed for inodes which can have associated
page allocations.  To fix the leak, only allocate resv_map for those
inodes which could possibly be associated with page allocations.

Link: http://lkml.kernel.org/r/20190401213101.16476-1-mike.kravetz@oracle.com
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Reported-by: Yufen Yu <yuyufen@huawei.com>
Suggested-by: Yufen Yu <yuyufen@huawei.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/hugetlbfs/inode.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index eb6f3de29f69..dd28a9b287da 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -730,11 +730,17 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 					umode_t mode, dev_t dev)
 {
 	struct inode *inode;
-	struct resv_map *resv_map;
+	struct resv_map *resv_map = NULL;
 
-	resv_map = resv_map_alloc();
-	if (!resv_map)
-		return NULL;
+	/*
+	 * Reserve maps are only needed for inodes that can have associated
+	 * page allocations.
+	 */
+	if (S_ISREG(mode) || S_ISLNK(mode)) {
+		resv_map = resv_map_alloc();
+		if (!resv_map)
+			return NULL;
+	}
 
 	inode = new_inode(sb);
 	if (inode) {
@@ -766,8 +772,10 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 			break;
 		}
 		lockdep_annotate_inode_mutex_key(inode);
-	} else
-		kref_put(&resv_map->refs, resv_map_release);
+	} else {
+		if (resv_map)
+			kref_put(&resv_map->refs, resv_map_release);
+	}
 
 	return inode;
 }
-- 
2.19.1

