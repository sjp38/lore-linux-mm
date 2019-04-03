Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D335FC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 02:29:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F7EF21473
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 02:29:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="OBUgMHS0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F7EF21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27DFD6B0266; Tue,  2 Apr 2019 22:29:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22B806B026B; Tue,  2 Apr 2019 22:29:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11B616B026D; Tue,  2 Apr 2019 22:29:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id E153E6B0266
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 22:29:23 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id f15so15373110qtk.16
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 19:29:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=AZgVPE4HREq+sv6cmpMtDG6gnzQkBOK43yh8D3ILToQ=;
        b=nwtPoAQ2yVAG4xccs7cg8KHQjpjgv66rNH48lZceeM7CmImQbliH3sfMhpQqepl+GP
         V1vJhZFA/xcNESARP9GTldeLq9fGwdxBXLFxiVTGmUs8LNA2rlgfONIvi7Xux1RiA+xw
         q2jouaide7NjF32taTpwfYB57qZ4QwjzH3iFyL3SMAAkE+toWX3MnFeQJLYqV4QIAcNx
         goPMx543XIRCjslbYID6kpbArM2buS4qMn0G1kHc7s/knwIeTHFOWBij0OiqY2Oydc6U
         swNGxEp8TsI1ax8k/QShIyWRWLa9ptJiB140VKMxc6Qzr1FBcwpxEs8JCUfgcE9ypfSY
         D9aQ==
X-Gm-Message-State: APjAAAXe2o1x703+VXGClhcJ1e5OQsXxGAQmXiVUHzkaKa/T278+4OU8
	L4U9c3xT6n1XiksUPVoKIz4bdIdhvbMud8BLtur3m+XSp2oQKPjiTZjYArGsIUIuTyy+S3Nppo5
	jsjYkZOraIyYRjFuwFduAU4hMn27baFntsSSfC2rZEgCk9xudqAM54wl6E4Vw5HBa9w==
X-Received: by 2002:aed:3bc3:: with SMTP id s3mr38179914qte.313.1554258563619;
        Tue, 02 Apr 2019 19:29:23 -0700 (PDT)
X-Received: by 2002:aed:3bc3:: with SMTP id s3mr38179874qte.313.1554258562666;
        Tue, 02 Apr 2019 19:29:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554258562; cv=none;
        d=google.com; s=arc-20160816;
        b=yqrBogrlwe9qmXU09liY5NwIHjVeU4KUPWVFO4NNk+zjFA9vbMWI4zVGrQLExHH2MJ
         ojSgFKTJRLEY8pEE+lUq7P/wTXgDPxSsvjUpMfqLuCwY3/PD23Mz7qMFm2bVqP1bugBy
         5XCnIqwl42K+YAqP8n5B/ZcgSq7o5VKuiBS1Rcij7bq6tdCBJonosIv5+tbbTxukR6rr
         UktTlesbNtceZkiWrAC+c+PxEwgPZe3U8GXA1hEzO56JxEqJBweDwZT1mPWpiIEr72rv
         gziWRxLaCNdfvkpLZn/EnmHC8PnygncBPlWh39dfCaepS62BNc+CLL75b/Ar9TDw5NXv
         MlaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=AZgVPE4HREq+sv6cmpMtDG6gnzQkBOK43yh8D3ILToQ=;
        b=wL68OYSPWo9GpDTo+RZgyIVtc0Jj0joCf1qPSEd4VoHtuzQTDFL2A29eYyllgwfwK+
         ZBiZhLFHCAXhuZSU9esT66PIU8edLKm2by+FEBmy3WkVwAw2Tn3Y0jjtFbTFrOoAuAWs
         xj/UZ1A2svnIfixvpGZzGLZJFC+qzUo+b+012kd94vHAPCm0V4ouVoC/afwESWfLZmtA
         E2zCsf9V8iLbsL0aEMOiVUhfZGHZqvzcjHnLUPnB+qxFZx/AjJvDR8n8quYnuphFD5gm
         AR7SSTDIFz43MEs5zsCML2EQjDBZUfRdDy6SQlQVVm8ZyR9tyOpvFku2OeOqmAmFU1Ch
         QLmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=OBUgMHS0;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j16sor20699668qtc.47.2019.04.02.19.29.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 19:29:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=OBUgMHS0;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=AZgVPE4HREq+sv6cmpMtDG6gnzQkBOK43yh8D3ILToQ=;
        b=OBUgMHS0ifgqCut+LRrVnK4OKWSIn2FHLfyQla7SPo0+MRm3yUlamfA/7jh82iGxJi
         ShhhPJZJBJQv7ByakBgw8jN7R7Gsz1vAHmRQViZRZDMemyOB4tGEBJpgtwWDpp3kR2YH
         HU1wY3KXvPpfS7KXCmzE2L3U40Bp9JdCcs9e9/ycuj8qyPCDwPtTN+Uq0A911EVHgldF
         kWNtahF5k6T5QrAR0D+4k6tul5MmuzWYFt2i97TwuWxk0EUrRJziIcC6huUeeqbUJyXi
         UuYhk2jXiaA+M1owgJ+BcxZ+tvLIFksXEpbEUTJZOtGNQISAR0g/4KtijVLR86oRChnX
         Gd8g==
X-Google-Smtp-Source: APXvYqwedQnZcvsPDLInLy4Y+H1ifeejd/OGRe/ypSaz2cIuGClG7ekDLMNcXTbW2p0cY//cy9bCdw==
X-Received: by 2002:ac8:3019:: with SMTP id f25mr61330389qte.204.1554258562365;
        Tue, 02 Apr 2019 19:29:22 -0700 (PDT)
Received: from ovpn-120-94.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id n41sm9520737qtf.63.2019.04.02.19.29.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 19:29:21 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: andreyknvl@google.com,
	cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	aryabinin@virtuozzo.com,
	glider@google.com,
	dvyukov@google.com,
	kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] slab: store tagged freelist for off-slab slabmgmt
Date: Tue,  2 Apr 2019 22:28:58 -0400
Message-Id: <20190403022858.97584-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit 51dedad06b5f ("kasan, slab: make freelist stored without
tags") calls kasan_reset_tag() for off-slab slab management object
leading to freelist being stored non-tagged. However, cache_grow_begin()
-> alloc_slabmgmt() -> kmem_cache_alloc_node() which assigns a tag for
the address and stores in the shadow address. As the result, it causes
endless errors below during boot due to drain_freelist() ->
slab_destroy() -> kasan_slab_free() which compares already untagged
freelist against the stored tag in the shadow address. Since off-slab
slab management object freelist is such a special case, so just store it
tagged. Non-off-slab management object freelist is still stored untagged
which has not been assigned a tag and should not cause any other
troubles with this inconsistency.

BUG: KASAN: double-free or invalid-free in slab_destroy+0x84/0x88
Pointer tag: [ff], memory tag: [99]

CPU: 0 PID: 1376 Comm: kworker/0:4 Tainted: G        W
5.1.0-rc3+ #8
Hardware name: HPE Apollo 70             /C01_APACHE_MB         , BIOS
L50_5.13_1.0.6 07/10/2018
Workqueue: cgroup_destroy css_killed_work_fn
Call trace:
 dump_backtrace+0x0/0x450
 show_stack+0x20/0x2c
 dump_stack+0xe0/0x16c
 print_address_description+0x74/0x2a4
 kasan_report_invalid_free+0x80/0xc0
 __kasan_slab_free+0x204/0x208
 kasan_slab_free+0xc/0x18
 kmem_cache_free+0xe4/0x254
 slab_destroy+0x84/0x88
 drain_freelist+0xd0/0x104
 __kmem_cache_shrink+0x1ac/0x224
 __kmemcg_cache_deactivate+0x1c/0x28
 memcg_deactivate_kmem_caches+0xa0/0xe8
 memcg_offline_kmem+0x8c/0x3d4
 mem_cgroup_css_offline+0x24c/0x290
 css_killed_work_fn+0x154/0x618
 process_one_work+0x9cc/0x183c
 worker_thread+0x9b0/0xe38
 kthread+0x374/0x390
 ret_from_fork+0x10/0x18

Allocated by task 1625:
 __kasan_kmalloc+0x168/0x240
 kasan_slab_alloc+0x18/0x20
 kmem_cache_alloc_node+0x1f8/0x3a0
 cache_grow_begin+0x4fc/0xa24
 cache_alloc_refill+0x2f8/0x3e8
 kmem_cache_alloc+0x1bc/0x3bc
 sock_alloc_inode+0x58/0x334
 alloc_inode+0xb8/0x164
 new_inode_pseudo+0x20/0xec
 sock_alloc+0x74/0x284
 __sock_create+0xb0/0x58c
 sock_create+0x98/0xb8
 __sys_socket+0x60/0x138
 __arm64_sys_socket+0xa4/0x110
 el0_svc_handler+0x2c0/0x47c
 el0_svc+0x8/0xc

Freed by task 1625:
 __kasan_slab_free+0x114/0x208
 kasan_slab_free+0xc/0x18
 kfree+0x1a8/0x1e0
 single_release+0x7c/0x9c
 close_pdeo+0x13c/0x43c
 proc_reg_release+0xec/0x108
 __fput+0x2f8/0x784
 ____fput+0x1c/0x28
 task_work_run+0xc0/0x1b0
 do_notify_resume+0xb44/0x1278
 work_pending+0x8/0x10

The buggy address belongs to the object at ffff809681b89e00
 which belongs to the cache kmalloc-128 of size 128
The buggy address is located 0 bytes inside of
 128-byte region [ffff809681b89e00, ffff809681b89e80)
The buggy address belongs to the page:
page:ffff7fe025a06e00 count:1 mapcount:0 mapping:01ff80082000fb00
index:0xffff809681b8fe04
flags: 0x17ffffffc000200(slab)
raw: 017ffffffc000200 ffff7fe025a06d08 ffff7fe022ef7b88 01ff80082000fb00
raw: ffff809681b8fe04 ffff809681b80000 00000001000000e0 0000000000000000
page dumped because: kasan: bad access detected
page allocated via order 0, migratetype Unmovable, gfp_mask
0x2420c0(__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE)
 prep_new_page+0x4e0/0x5e0
 get_page_from_freelist+0x4ce8/0x50d4
 __alloc_pages_nodemask+0x738/0x38b8
 cache_grow_begin+0xd8/0xa24
 ____cache_alloc_node+0x14c/0x268
 __kmalloc+0x1c8/0x3fc
 ftrace_free_mem+0x408/0x1284
 ftrace_free_init_mem+0x20/0x28
 kernel_init+0x24/0x548
 ret_from_fork+0x10/0x18

Memory state around the buggy address:
 ffff809681b89c00: fe fe fe fe fe fe fe fe fe fe fe fe fe fe fe fe
 ffff809681b89d00: fe fe fe fe fe fe fe fe fe fe fe fe fe fe fe fe
>ffff809681b89e00: 99 99 99 99 99 99 99 99 fe fe fe fe fe fe fe fe
                   ^
 ffff809681b89f00: 43 43 43 43 43 fe fe fe fe fe fe fe fe fe fe fe
 ffff809681b8a000: 6d fe fe fe fe fe fe fe fe fe fe fe fe fe fe fe

Fixes: 51dedad06b5f ("kasan, slab: make freelist stored without tags")
Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/slab.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 329bfe67f2ca..46a6e084222b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2374,7 +2374,6 @@ static void *alloc_slabmgmt(struct kmem_cache *cachep,
 		/* Slab management obj is off-slab. */
 		freelist = kmem_cache_alloc_node(cachep->freelist_cache,
 					      local_flags, nodeid);
-		freelist = kasan_reset_tag(freelist);
 		if (!freelist)
 			return NULL;
 	} else {
-- 
2.17.2 (Apple Git-113)

