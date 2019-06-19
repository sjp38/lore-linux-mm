Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CB5CC43613
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 20:53:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FD222147A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 20:53:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="PBQvRmU9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FD222147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B0316B0003; Wed, 19 Jun 2019 16:53:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 360C38E0002; Wed, 19 Jun 2019 16:53:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 250188E0001; Wed, 19 Jun 2019 16:53:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 089E56B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 16:53:27 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id u129so710747qkd.12
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 13:53:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=r1JW72QZvFM97mG3byq8Xb6t+u2a6sidb0hhLRwcOmU=;
        b=lYzrYfn9GEPmZZIcVOwmTSGwaDA7PYPVcHaucoPdSPP2oplrKQH+YkL0XvM0Knituy
         p37EWqAc6DlaOH+1MtWqjzCHlmZgrIQJE/N1yWF6woe7Wy3oorCu5S71uwtqKfK6D73L
         Vz35/diFiknqDfGbri0ktRQ01MS7KObDVLtD0w4zzpayhcMr5k2Hf0abCrdu8LRE5gJM
         IPGGc26DVCf/RgFJXsPIMoqO+yUAUp23RpiLahksn0yuoVWkuCZKAGn6cyxrxmuQSAeK
         zj0uKv5LlFZFCyqr8CDqO1/1KMuUWj0KHUd7WJ79F289ZayueD7Ee/+LFYE6wcQZ7yRi
         1vfA==
X-Gm-Message-State: APjAAAX9URx39xeS7tFTNxjCffqd5244o07u35cDMiSGv/nIXCfPZg5D
	V54fT5l7FGKqyJuYQbav/ni7bG0j+apkwnaPxR2ThrqZvEGdm5IS/G5M4/fVDloiW0gtb23mA9R
	X/HAe6ac48zPlsrWMRuOrffR2SeTfyaSYpkxw+avjz5GS4uHVk9cG+6qbVRXBCfYv1Q==
X-Received: by 2002:ac8:1751:: with SMTP id u17mr96024671qtk.305.1560977606748;
        Wed, 19 Jun 2019 13:53:26 -0700 (PDT)
X-Received: by 2002:ac8:1751:: with SMTP id u17mr96024608qtk.305.1560977605779;
        Wed, 19 Jun 2019 13:53:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560977605; cv=none;
        d=google.com; s=arc-20160816;
        b=ovIBg1kdOA3MS275GTvLsynT3fLBWWMHa5kfKb9ELT98k4kdtSsmfFhB3BO5WPhGZI
         2s8rbkwR+7CRWxA/A0s4/EtVB0Cu4mV3nCXKyf26PoHMagQsI75OUG5DlLXszdR8XBVf
         GlsDZF3UvXPdksF5aSaauCDsjn6j4B+e2JqBUFidaIv1Fe28F5e/7TKZefyhUDNAlcMY
         R1k6G07bDgS4TscEAfYKJV6Lq3pilvJebkwJx6bWGIwqOVn5mqe2B6b0tDW/nXTjpQ0D
         m1RKSlaucxtkifilvddEUukPPufYOUeVDf0QPPH5e9U3qg9Cyxw3QCAD4C6bI5rf4jlm
         khnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=r1JW72QZvFM97mG3byq8Xb6t+u2a6sidb0hhLRwcOmU=;
        b=lX9xBkEYrV/o41RGlXecEyHEHMQ3sj1nR7w4p1JxcubdKzhKqOAUw3MnBCJYsex23g
         /6JDv++XPZeRAXS81f6Cjf0tIxJvE4Fp7+ZMZ1Sx8YD0yNVs0OujJDORIwqlufEvfTSU
         sehV+pKECbxP+nDkXxUa2qICx1rLfoK0Apt9ZmDCvy8/b2qK/5k7n5U5kNtvCfrBlt3n
         IruJ6rRwI3hfx04V3R75Iuk9PYqEwk5K0G1EeRCGL83oVgcdORPvZWYtHNDbHQBe7v2k
         +AherXhvAqJNCYNyYy3w3WuHpBLqwg3BzBaoUNP7lmod3uFNgNVScQoQ70XsK3kq5nXX
         M3BQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=PBQvRmU9;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d7sor16989242qvc.67.2019.06.19.13.53.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 13:53:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=PBQvRmU9;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=r1JW72QZvFM97mG3byq8Xb6t+u2a6sidb0hhLRwcOmU=;
        b=PBQvRmU97QmDiSH6VHDaVQhPepePHrPHYlwwQ/KedfmWFuxP7nUwqp4/gHO2vD8PXY
         SW9GabxMpnd0/VDvqluCZBrgba4B+TZYn77dps9SRIWk2FLlws4+lPZaBGwxR9ZgjM2C
         7xwslkwmmsnwnPue83IhaipYL5eRyUk5+oWTnWae3b1fwgku785VXUP54Ar7RnMV4R3m
         RE9tyi1FcCXdjUJTubVkJobdiO0q/NrOpxhXAtRsHS/dMms3Qj4rgqvYQf5xhyi07dpw
         TqZPdrr43X0vGiK+pke37NhAY8QZWb7anvOlUJl9WUNKa1+r9pA81Myq6CsYzOWv+tym
         apsQ==
X-Google-Smtp-Source: APXvYqzoYanqwMwE8GB/pmwJLxlLQcRHAuhdcsBEYsWD0YJ/kIjmSl19ksNIX8BZAxajAHkqRUDi9g==
X-Received: by 2002:a0c:acab:: with SMTP id m40mr19419150qvc.52.1560977605321;
        Wed, 19 Jun 2019 13:53:25 -0700 (PDT)
Received: from qcai.nay.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id g2sm8477275qkm.31.2019.06.19.13.53.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 13:53:24 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: guro@fb.com,
	vdavydov.dev@gmail.com,
	hannes@cmpxchg.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH -next] mm/slab: fix an use-after-free in kmemcg_workfn()
Date: Wed, 19 Jun 2019 16:52:53 -0400
Message-Id: <1560977573-10715-1-git-send-email-cai@lca.pw>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The linux-next commit "mm: rework non-root kmem_cache lifecycle
management" [1] introduced an use-after-free below because
kmemcg_workfn() may call slab_kmem_cache_release() which has already
freed the whole kmem_cache. Fix it by removing the bogus NULL assignment
and checkings that will not work with SLUB_DEBUG poisoning anyway.

[1] https://lore.kernel.org/patchwork/patch/1087376/

BUG kmem_cache (Tainted: G    B   W        ): Poison overwritten
INFO: 0x(____ptrval____)-0x(____ptrval____). First byte 0x0 instead of
0x6b
INFO: Allocated in create_cache+0x6c/0x1bc age=2653 cpu=154 pid=1599
	kmem_cache_alloc+0x514/0x568
	create_cache+0x6c/0x1bc
	memcg_create_kmem_cache+0xfc/0x11c
	memcg_kmem_cache_create_func+0x40/0x170
	process_one_work+0x4e0/0xa54
	worker_thread+0x498/0x650
	kthread+0x1b8/0x1d4
	ret_from_fork+0x10/0x18
INFO: Freed in slab_kmem_cache_release+0x3c/0x48 age=255 cpu=7 pid=1505
	slab_kmem_cache_release+0x3c/0x48
	kmem_cache_release+0x1c/0x28
	kobject_cleanup+0x134/0x288
	kobject_put+0x5c/0x68
	sysfs_slab_release+0x2c/0x38
	shutdown_cache+0x190/0x234
	kmemcg_cache_shutdown_fn+0x1c/0x34
	kmemcg_workfn+0x44/0x68
	process_one_work+0x4e0/0xa54
	worker_thread+0x498/0x650
	kthread+0x1b8/0x1d4
	ret_from_fork+0x10/0x18
INFO: Slab 0x(____ptrval____) objects=64 used=64 fp=0x(____ptrval____)
flags=0x17ffffffc000200
INFO: Object 0x(____ptrval____) @offset=11601272640106456192
fp=0x(____ptrval____)
Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
bb  ................
Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
bb  ................
Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
bb  ................
Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
bb  ................
Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
bb  ................
Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
bb  ................
Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
bb  ................
Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
bb  ................
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 00 00 00 00 00 00 00 00
kkkkkkkk........
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
kkkkkkkkkkkkkkkk
Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b a5
kkkkkkk.
Redzone (____ptrval____): bb bb bb bb bb bb bb bb
........
Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a  ZZZZZZZZZZZZZZZZ
Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a  ZZZZZZZZZZZZZZZZ
Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a  ZZZZZZZZZZZZZZZZ
Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a  ZZZZZZZZZZZZZZZZ
Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a
ZZZZZZZZ
CPU: 193 PID: 1557 Comm: kworker/193:1 Tainted: G    B   W
5.2.0-rc5-next-20190619+ #8
Hardware name: HPE Apollo 70             /C01_APACHE_MB         , BIOS
L50_5.13_1.0.9 03/01/2019
Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
Call trace:
 dump_backtrace+0x0/0x268
 show_stack+0x20/0x2c
 dump_stack+0xb4/0x108
 print_trailer+0x274/0x298
 check_bytes_and_report+0xc4/0x118
 check_object+0x2fc/0x36c
 alloc_debug_processing+0x154/0x240
 ___slab_alloc+0x710/0xa68
 kmem_cache_alloc+0x514/0x568
 create_cache+0x6c/0x1bc
 memcg_create_kmem_cache+0xfc/0x11c
 memcg_kmem_cache_create_func+0x40/0x170
 process_one_work+0x4e0/0xa54
 worker_thread+0x498/0x650
 kthread+0x1b8/0x1d4
 ret_from_fork+0x10/0x18
FIX kmem_cache: Restoring 0x(____ptrval____)-0x(____ptrval____)=0x6b

FIX kmem_cache: Marking all objects used

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/slab_common.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 91e8c739dc97..bb8aec6d8744 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -714,10 +714,7 @@ static void kmemcg_workfn(struct work_struct *work)
 	get_online_mems();
 
 	mutex_lock(&slab_mutex);
-
 	s->memcg_params.work_fn(s);
-	s->memcg_params.work_fn = NULL;
-
 	mutex_unlock(&slab_mutex);
 
 	put_online_mems();
@@ -753,7 +750,6 @@ static void kmemcg_cache_shutdown(struct percpu_ref *percpu_ref)
 	if (s->memcg_params.root_cache->memcg_params.dying)
 		goto unlock;
 
-	WARN_ON(s->memcg_params.work_fn);
 	s->memcg_params.work_fn = kmemcg_cache_shutdown_fn;
 	INIT_WORK(&s->memcg_params.work, kmemcg_workfn);
 	queue_work(memcg_kmem_cache_wq, &s->memcg_params.work);
@@ -784,7 +780,6 @@ static void kmemcg_cache_deactivate(struct kmem_cache *s)
 	if (s->memcg_params.root_cache->memcg_params.dying)
 		goto unlock;
 
-	WARN_ON_ONCE(s->memcg_params.work_fn);
 	s->memcg_params.work_fn = kmemcg_cache_deactivate_after_rcu;
 	call_rcu(&s->memcg_params.rcu_head, kmemcg_rcufn);
 unlock:
-- 
1.8.3.1

