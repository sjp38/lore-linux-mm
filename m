Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFB07C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 20:43:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6219721874
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 20:43:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="lcrHgEg4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6219721874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB98F6B0003; Wed, 20 Mar 2019 16:43:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E68FF6B0006; Wed, 20 Mar 2019 16:43:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D57F66B0007; Wed, 20 Mar 2019 16:43:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA7886B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 16:43:11 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id c25so3819558qtj.13
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 13:43:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=2RLae5TxRnlaqkXd+oED+3b1Dwsri72MEioaQj3Oulg=;
        b=NNpwoFWT/cJGkWaA45bFNxa90JUNZ3Josx/7IKCMwPDEdSwGxAeJ08+e1Lo9ISJaGD
         Vxt42MNMUYJ9w1Ht3DT+brSElNXjffAZMnB4JNgbOslf/Y6Zcn/x9i33eXEpffufB2rf
         v86QQkXcYUmGrSk6qAwGmgoQuYARgu8ano4glCTO1/bBHH0WCGcVAgBAhTmUJ+G9HICv
         QmaxWEiuuc4hT4neIAtKXmYNUkQbibxn2IiyPT9pogI9U57i2ZPhHQMhLA20o63ttrlK
         el9GHcnD6vTY5W2x/R3FiVpOpJdkHgZf2Fstm4a9h+Hl+GeZE6f9+SrePjNeNCLt6s+7
         cZ6w==
X-Gm-Message-State: APjAAAWWXHy5DOlaic9qbkGImTLhD085Glejy/1tMKhsYkCQFrUyzysR
	qTiVhYym3Y2c/4mZQaW8vGBsmsQeYhp/9wRudQE8Q7BeostRkX0ySlSTchHqXd5AGSDSt+RbfzL
	4ybKddvZF+lXVTtAh9yMShToeLAk1nkm+F2KpLo+KSQiOQrtPxDlvd6ivVTshWb6GJA==
X-Received: by 2002:ac8:25b5:: with SMTP id e50mr9241172qte.186.1553114591361;
        Wed, 20 Mar 2019 13:43:11 -0700 (PDT)
X-Received: by 2002:ac8:25b5:: with SMTP id e50mr9241112qte.186.1553114590116;
        Wed, 20 Mar 2019 13:43:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553114590; cv=none;
        d=google.com; s=arc-20160816;
        b=Iv2/5ajndZHbuDrV0JtK0zcOKOlx1I1RTK3NxDTt2WEqy/obA3pKVu+OJRiO1DIlAD
         fefezmFdYtRcVbpe28sIMXWuBqpsPT9vPD+mdS9mzdcmmAnk6NJok9y4qzdNb5AMq72T
         3T+EZVPWE7tv9uDYrCXGkn9luPWUzj8qIPfq4hk4rdeXCNGKjDwUarlg922g1oNcwr/o
         vpLVIRQdI9XkW7dYkizhyTMQyQCuhIEq5BBIp3ZAdPyO9NCr33mo59ffBo+TKQ3/UqH+
         OzNkVR652d1MHaxLAtT3zrKvtPZOqsF7Ax2MIIBhw7EPbAmbgNks7vSo6ffcKx6Y/lmT
         T26g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=2RLae5TxRnlaqkXd+oED+3b1Dwsri72MEioaQj3Oulg=;
        b=JKcaV5VV86STLqW/Fw0DUJqt/rIPQcIblLjqtrebqDG0BcGgHo6ylC+WqK9WTyFFv0
         7wZhdqS5CKoDFZqG1fIM0blDQZ6/3/iwuJZF+TDIMp3SomuzPpqNwb3bSsgf/vnyn3AZ
         1p/AGsY7dD8yKK15mEPtVJFZV2b7iVaMYBLjeZDBOR8IpvwKL6xnfkk+CE9Hz6X5Kzwx
         ddC5rA26gNGBbJVJkbMS8ou/upJ2DWe+hA+IL2z6kQr7P6Uh45EXNN81kCmlI5tAFgAs
         RPSWZjxWy8jnLzaOoF1YfKos5hSqhIaf3qqera1I8k34OMGBTCM+Xct98o1clAa+T/WU
         guUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=lcrHgEg4;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j11sor5544114qti.57.2019.03.20.13.43.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 13:43:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=lcrHgEg4;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=2RLae5TxRnlaqkXd+oED+3b1Dwsri72MEioaQj3Oulg=;
        b=lcrHgEg4Qfep15DQxX+bHhuyKyVVdmSuCCHmm0pqnrjeZt12Hp1KKQToATIau34B5P
         bCdAVNkHxXCnmo0CWbW+LVRsojBOGZIT4RwH9eskGG1dYel05xR5BJ7TDMb6bKLFqUzB
         RmeoH7wS9bXaw9c4sZ9wYOxqa4biXgAujOMa5Yjgn+N0yDF9jz20u3VvLtkJDR0d2wqx
         dlA5kBBZvUlqXW+HHowZEB1sg0ufmIClYpAhfxQh7XUrBW7mNVJpwGWNXs1KpJI49GF0
         nzB+9ejLNQ5tuYK4SG3l7IZigpQenAh0iHQBZQcqxHSrjlDsigdBdC5Net74aLFHoA1a
         sixw==
X-Google-Smtp-Source: APXvYqwzCP9jQqLKW0C4jmyp3fUsgGIIOy4gfG1whZqkYd5q01aerQ0qLQhXJnxRnA2EQyz0NZU8DQ==
X-Received: by 2002:aed:302f:: with SMTP id 44mr8986876qte.178.1553114589845;
        Wed, 20 Mar 2019 13:43:09 -0700 (PDT)
Received: from ovpn-120-94.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id o19sm1971787qkl.65.2019.03.20.13.43.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 13:43:09 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mhocko@kernel.org,
	osalvador@suse.de,
	anshuman.khandual@arm.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>,
	stable@vger.kernel.org
Subject: [RESEND PATCH] mm/hotplug: fix notification in offline error path
Date: Wed, 20 Mar 2019 16:42:55 -0400
Message-Id: <20190320204255.53571-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When start_isolate_page_range() returned -EBUSY in __offline_pages(), it
calls memory_notify(MEM_CANCEL_OFFLINE, &arg) with an uninitialized
"arg". As the result, it triggers warnings below. Also, it is only
necessary to notify MEM_CANCEL_OFFLINE after MEM_GOING_OFFLINE.

page:ffffea0001200000 count:1 mapcount:0 mapping:0000000000000000
index:0x0
flags: 0x3fffe000001000(reserved)
raw: 003fffe000001000 ffffea0001200008 ffffea0001200008 0000000000000000
raw: 0000000000000000 0000000000000000 00000001ffffffff 0000000000000000
page dumped because: unmovable page
WARNING: CPU: 25 PID: 1665 at mm/kasan/common.c:665
kasan_mem_notifier+0x34/0x23b
CPU: 25 PID: 1665 Comm: bash Tainted: G        W         5.0.0+ #94
Hardware name: HP ProLiant DL180 Gen9/ProLiant DL180 Gen9, BIOS U20
10/25/2017
RIP: 0010:kasan_mem_notifier+0x34/0x23b
RSP: 0018:ffff8883ec737890 EFLAGS: 00010206
RAX: 0000000000000246 RBX: ff10f0f4435f1000 RCX: f887a7a21af88000
RDX: dffffc0000000000 RSI: 0000000000000020 RDI: ffff8881f221af88
RBP: ffff8883ec737898 R08: ffff888000000000 R09: ffffffffb0bddcd0
R10: ffffed103e857088 R11: ffff8881f42b8443 R12: dffffc0000000000
R13: 00000000fffffff9 R14: dffffc0000000000 R15: 0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000560fbd31d730 CR3: 00000004049c6003 CR4: 00000000001606a0
Call Trace:
 notifier_call_chain+0xbf/0x130
 __blocking_notifier_call_chain+0x76/0xc0
 blocking_notifier_call_chain+0x16/0x20
 memory_notify+0x1b/0x20
 __offline_pages+0x3e2/0x1210
 offline_pages+0x11/0x20
 memory_block_action+0x144/0x300
 memory_subsys_offline+0xe5/0x170
 device_offline+0x13f/0x1e0
 state_store+0xeb/0x110
 dev_attr_store+0x3f/0x70
 sysfs_kf_write+0x104/0x150
 kernfs_fop_write+0x25c/0x410
 __vfs_write+0x66/0x120
 vfs_write+0x15a/0x4f0
 ksys_write+0xd2/0x1b0
 __x64_sys_write+0x73/0xb0
 do_syscall_64+0xeb/0xb78
 entry_SYSCALL_64_after_hwframe+0x44/0xa9
RIP: 0033:0x7f14f75cc3b8
RSP: 002b:00007ffe84d01d68 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 0000000000000008 RCX: 00007f14f75cc3b8
RDX: 0000000000000008 RSI: 0000563f8e433d70 RDI: 0000000000000001
RBP: 0000563f8e433d70 R08: 000000000000000a R09: 00007ffe84d018f0
R10: 000000000000000a R11: 0000000000000246 R12: 00007f14f789e780
R13: 0000000000000008 R14: 00007f14f7899740 R15: 0000000000000008

Fixes: 7960509329c2 ("mm, memory_hotplug: print reason for the offlining failure")
CC: stable@vger.kernel.org # 5.0.x
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/memory_hotplug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 0e0a16021fd5..0082d699be94 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1699,12 +1699,12 @@ static int __ref __offline_pages(unsigned long start_pfn,
 
 failed_removal_isolated:
 	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
+	memory_notify(MEM_CANCEL_OFFLINE, &arg);
 failed_removal:
 	pr_debug("memory offlining [mem %#010llx-%#010llx] failed due to %s\n",
 		 (unsigned long long) start_pfn << PAGE_SHIFT,
 		 ((unsigned long long) end_pfn << PAGE_SHIFT) - 1,
 		 reason);
-	memory_notify(MEM_CANCEL_OFFLINE, &arg);
 	/* pushback to free area */
 	mem_hotplug_done();
 	return ret;
-- 
2.17.2 (Apple Git-113)

