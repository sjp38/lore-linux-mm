Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE7EDC49ED7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 16:28:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83C492084F
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 16:28:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="jhroHVwh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83C492084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1EA9E6B0007; Fri, 13 Sep 2019 12:28:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19A806B0008; Fri, 13 Sep 2019 12:28:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B0D96B000A; Fri, 13 Sep 2019 12:28:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0040.hostedemail.com [216.40.44.40])
	by kanga.kvack.org (Postfix) with ESMTP id D89F36B0007
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 12:28:13 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 6417F82437CF
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 16:28:13 +0000 (UTC)
X-FDA: 75930429666.16.pet09_d827811d800e
X-HE-Tag: pet09_d827811d800e
X-Filterd-Recvd-Size: 8473
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com [209.85.160.196])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 16:28:12 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id u9so8622231qtq.2
        for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:28:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=FzLVd4YDDf6CZHY+6NYMzJKE4UH1hHVZOJxIC0ZTZKs=;
        b=jhroHVwhxY0ImX8RYoKgbgXiFb41c1FPA0YOv565qjgzVCGyKRAw4BllIcUKTj2rgk
         +tFNixuHa1jZJT/LTE8nghJLU3TRsvKY/8gIJw0ISG2PgHYld3aaqa0uGVZ+VelOJpAe
         oe3RKf4RCdL05Tay8dzvIEgpGda+oVGzRw+HWJW2fxzAJQ2mFdmKiJRTmLxDhClf7ymF
         YU6RmzfwbcEVZgd5jnkYD9hBC+ZmK5cFBZgvW3Bdwy6KXtphGjrouUreqe6lokn5qo0v
         HcfflPLex25ZFKPwL9zMVjk3fblqxF6hu+25fvfHgIr3uaCXTpnwslkW65cVaYPUJer3
         TO3A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=FzLVd4YDDf6CZHY+6NYMzJKE4UH1hHVZOJxIC0ZTZKs=;
        b=QFe1PhSRtXe5CJP+3VzqyCYwPKUlQbIpdt+zzZB+LLGUdbE1TmLvJS0mpCvMeQgqlN
         4pwZtebNS5Arysxq9CK8/uU3Kd889o2H8RFDmzBVwKAtPwhH1eFjkZL0oJl+OA4QnGKk
         OMdSaHxCDT/Rzcvim28eBg+g6AtfJHK3e+mSIyKb+Mq6CPnnDtu/D6vXR5fjgMXxhix/
         YvBFX2fHbw6qs5XODZwGXXxlVwf1p+n5wd3UIUbXqdD2NVx3+x97nnx3+9eGwW42cN2B
         855xn7BZwFn4r2sb4RCxDxgF0j7io2j0nQ006SOGzcLEHhGvRBQPIHb8q3voK1ZIsqxq
         mY8A==
X-Gm-Message-State: APjAAAXkNvgmGpdHG+QXZ5f/S3gS7II2L9Ul8PpOHrKTqe7Iecs9bMwC
	iK0wMWLqKF4QmcTKvjCyNs+5zA==
X-Google-Smtp-Source: APXvYqzYPGdr90xcWpNbrBsq3Fr5/fv1rtRpTvfoiFz3PN7JiLtha4N9VGncD/OzPu1BcxjjbnlkDQ==
X-Received: by 2002:ac8:1307:: with SMTP id e7mr3959203qtj.183.1568392092139;
        Fri, 13 Sep 2019 09:28:12 -0700 (PDT)
Received: from qcai.nay.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id v81sm13216533qka.88.2019.09.13.09.28.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Sep 2019 09:28:11 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: bigeasy@linutronix.de,
	tglx@linutronix.de,
	thgarnie@google.com,
	peterz@infradead.org,
	tytso@mit.edu,
	cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	mingo@redhat.com,
	will@kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	keescook@chromium.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] mm/slub: fix a deadlock in shuffle_freelist()
Date: Fri, 13 Sep 2019 12:27:44 -0400
Message-Id: <1568392064-3052-1-git-send-email-cai@lca.pw>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit b7d5dc21072c ("random: add a spinlock_t to struct
batched_entropy") insists on acquiring "batched_entropy_u32.lock" in
get_random_u32() which introduced the lock chain,

"&rq->lock --> batched_entropy_u32.lock"

even after crng init. As the result, it could result in deadlock below.
Fix it by using get_random_bytes() in shuffle_freelist() which does not
need to take on the batched_entropy locks.

WARNING: possible circular locking dependency detected
5.3.0-rc7-mm1+ #3 Tainted: G             L
------------------------------------------------------
make/7937 is trying to acquire lock:
ffff900012f225f8 (random_write_wait.lock){....}, at:
__wake_up_common_lock+0xa8/0x11c

but task is already holding lock:
ffff0096b9429c00 (batched_entropy_u32.lock){-.-.}, at:
get_random_u32+0x6c/0x1dc

which lock already depends on the new lock.

the existing dependency chain (in reverse order) is:

-> #3 (batched_entropy_u32.lock){-.-.}:
       lock_acquire+0x31c/0x360
       _raw_spin_lock_irqsave+0x7c/0x9c
       get_random_u32+0x6c/0x1dc
       new_slab+0x234/0x6c0
       ___slab_alloc+0x3c8/0x650
       kmem_cache_alloc+0x4b0/0x590
       __debug_object_init+0x778/0x8b4
       debug_object_init+0x40/0x50
       debug_init+0x30/0x29c
       hrtimer_init+0x30/0x50
       init_dl_task_timer+0x24/0x44
       __sched_fork+0xc0/0x168
       init_idle+0x78/0x26c
       fork_idle+0x12c/0x178
       idle_threads_init+0x108/0x178
       smp_init+0x20/0x1bc
       kernel_init_freeable+0x198/0x26c
       kernel_init+0x18/0x334
       ret_from_fork+0x10/0x18

-> #2 (&rq->lock){-.-.}:
       lock_acquire+0x31c/0x360
       _raw_spin_lock+0x64/0x80
       task_fork_fair+0x5c/0x1b0
       sched_fork+0x15c/0x2dc
       copy_process+0x9e0/0x244c
       _do_fork+0xb8/0x644
       kernel_thread+0xc4/0xf4
       rest_init+0x30/0x238
       arch_call_rest_init+0x10/0x18
       start_kernel+0x424/0x52c

-> #1 (&p->pi_lock){-.-.}:
       lock_acquire+0x31c/0x360
       _raw_spin_lock_irqsave+0x7c/0x9c
       try_to_wake_up+0x74/0x8d0
       default_wake_function+0x38/0x48
       pollwake+0x118/0x158
       __wake_up_common+0x130/0x1c4
       __wake_up_common_lock+0xc8/0x11c
       __wake_up+0x3c/0x4c
       account+0x390/0x3e0
       extract_entropy+0x2cc/0x37c
       _xfer_secondary_pool+0x35c/0x3c4
       push_to_pool+0x54/0x308
       process_one_work+0x4f4/0x950
       worker_thread+0x390/0x4bc
       kthread+0x1cc/0x1e8
       ret_from_fork+0x10/0x18

-> #0 (random_write_wait.lock){....}:
       validate_chain+0xd10/0x2bcc
       __lock_acquire+0x7f4/0xb8c
       lock_acquire+0x31c/0x360
       _raw_spin_lock_irqsave+0x7c/0x9c
       __wake_up_common_lock+0xa8/0x11c
       __wake_up+0x3c/0x4c
       account+0x390/0x3e0
       extract_entropy+0x2cc/0x37c
       crng_reseed+0x60/0x2f8
       _extract_crng+0xd8/0x164
       crng_reseed+0x7c/0x2f8
       _extract_crng+0xd8/0x164
       get_random_u32+0xec/0x1dc
       new_slab+0x234/0x6c0
       ___slab_alloc+0x3c8/0x650
       kmem_cache_alloc+0x4b0/0x590
       getname_flags+0x44/0x1c8
       user_path_at_empty+0x3c/0x68
       vfs_statx+0xa4/0x134
       __arm64_sys_newfstatat+0x94/0x120
       el0_svc_handler+0x170/0x240
       el0_svc+0x8/0xc

other info that might help us debug this:

Chain exists of:
  random_write_wait.lock --> &rq->lock --> batched_entropy_u32.lock

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(batched_entropy_u32.lock);
                               lock(&rq->lock);
                               lock(batched_entropy_u32.lock);
  lock(random_write_wait.lock);

 *** DEADLOCK ***

1 lock held by make/7937:
 #0: ffff0096b9429c00 (batched_entropy_u32.lock){-.-.}, at:
get_random_u32+0x6c/0x1dc

stack backtrace:
CPU: 220 PID: 7937 Comm: make Tainted: G             L    5.3.0-rc7-mm1+
Hardware name: HPE Apollo 70             /C01_APACHE_MB         , BIOS
L50_5.13_1.11 06/18/2019
Call trace:
 dump_backtrace+0x0/0x248
 show_stack+0x20/0x2c
 dump_stack+0xd0/0x140
 print_circular_bug+0x368/0x380
 check_noncircular+0x248/0x250
 validate_chain+0xd10/0x2bcc
 __lock_acquire+0x7f4/0xb8c
 lock_acquire+0x31c/0x360
 _raw_spin_lock_irqsave+0x7c/0x9c
 __wake_up_common_lock+0xa8/0x11c
 __wake_up+0x3c/0x4c
 account+0x390/0x3e0
 extract_entropy+0x2cc/0x37c
 crng_reseed+0x60/0x2f8
 _extract_crng+0xd8/0x164
 crng_reseed+0x7c/0x2f8
 _extract_crng+0xd8/0x164
 get_random_u32+0xec/0x1dc
 new_slab+0x234/0x6c0
 ___slab_alloc+0x3c8/0x650
 kmem_cache_alloc+0x4b0/0x590
 getname_flags+0x44/0x1c8
 user_path_at_empty+0x3c/0x68
 vfs_statx+0xa4/0x134
 __arm64_sys_newfstatat+0x94/0x120
 el0_svc_handler+0x170/0x240
 el0_svc+0x8/0xc

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/slub.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 8834563cdb4b..96cdd36f9380 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1598,8 +1598,15 @@ static bool shuffle_freelist(struct kmem_cache *s, struct page *page)
 	if (page->objects < 2 || !s->random_seq)
 		return false;
 
+	/*
+	 * Don't use get_random_int() here as it might deadlock due to
+	 * "&rq->lock --> batched_entropy_u32.lock" chain.
+	 */
+	if (!arch_get_random_int((int *)&pos))
+		get_random_bytes(&pos, sizeof(int));
+
 	freelist_count = oo_objects(s->oo);
-	pos = get_random_int() % freelist_count;
+	pos %= freelist_count;
 
 	page_limit = page->objects * s->size;
 	start = fixup_red_left(s, page_address(page));
-- 
1.8.3.1


