Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96561C10F13
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 01:56:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4592B20880
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 01:56:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4592B20880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D47FC6B0006; Mon,  8 Apr 2019 21:56:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD10C6B0007; Mon,  8 Apr 2019 21:56:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B98FC6B0010; Mon,  8 Apr 2019 21:56:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B3486B0006
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 21:56:25 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id l85so7780641vke.15
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 18:56:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=Rk7EBGKHYxPZokmPrqnUYQttfXrxyEBg2xHpg6SKjiM=;
        b=mjRBWiNq77QY0dMGIUbYyFkcpVMnTT0b5otBvHR169JI7WZbeuKfHB5Nn58F3Wi3Ld
         qUNyKS+sS1/H7s94ZO933WYqY58WTi7YurHE2SHoBqTCJWtv7jhO1L8bx8WOrXs0DNWl
         7A+7ZuO8FEfFY/rJOkavv8lwIU5Pks3i83tj0al42CfQOxFCDkyQGwE4iMTPl5QH9Lm0
         pKS7Tg4IbnG0UMqu3y7gMvcTmyxQobZnYh3mo0HhOGA+jXwGwCobR+LKZ6JZMtz+snDZ
         ju+LhPq2zon3SMUfw/i0yTpupY2kXzAh6eJB6eQEHbFrCTA4WdTiNMyH6bnMNwAlwcCn
         2Zjg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of luojiajun3@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=luojiajun3@huawei.com
X-Gm-Message-State: APjAAAVZJNSSJMhY/gD99wOHOs9NPe8LkduUAQukYlSrhld6ZpMl8Jxa
	d6rQm+KvI+jGA7oz5a2sR8IrmBtWES3QAENmY9WehK+p+SFJv0fLlako4hh0tpVzhPXqOQjK0AK
	tSeRSBOcKjiyNVlJN/YYXLPGvnwBVIJ5vDdESQFZNfJIotsRUlaTBj927TZRjQuzNJA==
X-Received: by 2002:a1f:bcf:: with SMTP id 198mr7967611vkl.35.1554774985163;
        Mon, 08 Apr 2019 18:56:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8PBo7EIX8QCmxJHKVyv7XzyOvycL3agSD2HWBEK9DTDDjvwPBPj7cr9m763YGgU+EQw7y
X-Received: by 2002:a1f:bcf:: with SMTP id 198mr7967578vkl.35.1554774984055;
        Mon, 08 Apr 2019 18:56:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554774984; cv=none;
        d=google.com; s=arc-20160816;
        b=KHchU4Devm2TbajXaM/aMlN9sfl8wNxCSg0KguSSVrCUaVwEx8VAwvhLtRTcD98wER
         Mli9nM1SftcFoYoPLy8dekdRLn2F+H1fDM6hSOaBlXvMGWUvz2ZIF57r9MlNHjEQFBRL
         P9YY4AZb+9tED3b+5GI4y3ZsGZF4MLJd9NTMWJ1Ky1hci0BEa1eLRGUGMQnbMGP7SN3L
         Y9FJsSIDXvmXksp0Bger4Zw2JUfMmopc4JZw+LZkqXMuB2TJhYRU4gZ1MxUMdvdzS6kB
         /0RQ4KgGpBJyR94PDi9b6niXYUHleZ3SBvLSKgnpqlv8RmvAwSRfwUkadHB4lEKgH1Vl
         6thg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=Rk7EBGKHYxPZokmPrqnUYQttfXrxyEBg2xHpg6SKjiM=;
        b=wzyIirTs/t56gQNWK4tZxcwnvkRU/DPCvjqk9nytZTGRMYWjO2BU1iKCJHyDVO7F2c
         U5zjd+dyXnOn2CmMEgfu2Uz4t5mWiCs3GZJ+XDln0hInek2df+svU+sxhcSt2p8ANsdm
         +MWIBCTZG3cKaoVCpZAr5ZJwBFTKGjrUE3CuLt8/p+sTr0s3mphlAPnTtdnxXdbfGvk3
         RNp5H5YEmrQFhgg7KZlFMFOS59JodXOOC2R6153AFVbXg1pP0uLj5bf8RnWGJK1aaHaG
         ECiBoDOwVW6nPj6rPyWK9BN8sPsYHdvU3D7RnTWcPpsLjKSIfbC+kCC9j7YV4WG/XCyM
         WeOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of luojiajun3@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=luojiajun3@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id b70si11395358vsd.270.2019.04.08.18.56.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 18:56:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of luojiajun3@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of luojiajun3@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=luojiajun3@huawei.com
Received: from DGGEMS407-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 663C3C52863B6876C231;
	Tue,  9 Apr 2019 09:56:10 +0800 (CST)
Received: from huawei.com (10.90.53.225) by DGGEMS407-HUB.china.huawei.com
 (10.3.19.207) with Microsoft SMTP Server id 14.3.408.0; Tue, 9 Apr 2019
 09:56:00 +0800
From: luojiajun <luojiajun3@huawei.com>
To: <linux-mm@kvack.org>
CC: <mike.kravetz@oracle.com>, <yi.zhang@huawei.com>, <miaoxie@huawei.com>
Subject: [PATCH] hugetlbfs: end hpage in hugetlbfs_fallocate overflow
Date: Tue, 9 Apr 2019 10:00:26 +0800
Message-ID: <1554775226-67213-1-git-send-email-luojiajun3@huawei.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.90.53.225]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In hugetlbfs_fallocate, start is rounded down and end is rounded up.
But it is inappropriate to use loff_t rounding up end, it may cause
overflow.

UBSAN: Undefined behaviour in fs/hugetlbfs/inode.c:582:22
signed integer overflow:
2097152 + 9223372036854775805 cannot be represented in type 'long long int'
CPU: 0 PID: 2669 Comm: syz-executor662 Not tainted 4.19.30 #5
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.10.2-1ubuntu1 04/01/2014
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0xca/0x13e lib/dump_stack.c:113
 ubsan_epilogue+0xe/0x81 lib/ubsan.c:159
 handle_overflow+0x193/0x1e2 lib/ubsan.c:190
 hugetlbfs_fallocate+0xe72/0x1140 fs/hugetlbfs/inode.c:582
 vfs_fallocate+0x346/0x7a0 fs/open.c:308
 ioctl_preallocate+0x15d/0x200 fs/ioctl.c:482
 file_ioctl fs/ioctl.c:498 [inline]
 do_vfs_ioctl+0xde3/0x10a0 fs/ioctl.c:688
 ksys_ioctl+0x89/0xa0 fs/ioctl.c:705
 __do_sys_ioctl fs/ioctl.c:712 [inline]
 __se_sys_ioctl fs/ioctl.c:710 [inline]
 __x64_sys_ioctl+0x74/0xb0 fs/ioctl.c:710
 do_syscall_64+0xc8/0x580 arch/x86/entry/common.c:290
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x44a3e9

Fix this problem by casting loff_t to unsigned long long when end
is rounded up.

This problem can be reproduced by syzkaller

Signed-off-by: luojiajun <luojiajun3@huawei.com>
---
 fs/hugetlbfs/inode.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 7f33244..0fe07f2 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -578,8 +578,9 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 	 * For this range, start is rounded down and end is rounded up
 	 * as well as being converted to page offsets.
 	 */
-	start = offset >> hpage_shift;
-	end = (offset + len + hpage_size - 1) >> hpage_shift;
+	start = (unsigned long long)offset >> hpage_shift;
+	end = ((unsigned long long)(offset + len + hpage_size) - 1)
+			>> hpage_shift;
 
 	inode_lock(inode);
 
-- 
2.7.4

