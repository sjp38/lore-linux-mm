Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71E6FC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 19:27:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D7B52146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 19:27:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Ft0YhVKA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D7B52146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C36A76B0003; Wed, 20 Mar 2019 15:26:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE7256B0006; Wed, 20 Mar 2019 15:26:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD70A6B0007; Wed, 20 Mar 2019 15:26:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 865A76B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 15:26:59 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id k5so3621322qte.0
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 12:26:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=I3tdl5L6G+L4wZtfr4ffg2pY8PDniLnkmBZEEfgscCA=;
        b=eozVT/TPzvsFy+sIH4VugLGdgilJUDeBrIlyd33upzJhfWOMwjsRmynhuiOtdfv0MP
         3cX2mBmwga0N5Q0wNs7/esT7jHijY5aZP3hKeP+MRvlUYbLvl0iQC5r0IUrxsinadl9q
         8n7Sr41Uo/cBX/KKCSYH/BVmdVzjbJf42z2AK7oxnQ/PRqhaYU7dui8f29nLnbOTmwsv
         zdoZyuq74hykc5KLtK9Y9I9+rctLgCWJBWJOdPW3V7dh4bEG3ZboxHjzRLTMvcsHBtN8
         5QoUZHbjMoNUTFczkR7OblFXlcd/yq2eIp40wKaQwCO9PD/nWRq0UsH8NJJVergJrKS4
         xWEA==
X-Gm-Message-State: APjAAAXu+A8HmaV+0OMVVmbh2LXuqq9Qws5wYgrt+2Gm6Vlkfj43pQQX
	PePFTLD+e+oot3CIv7jq6rp17fUBcuxqGU2CTJbw4Vw7bOY4dU1yq9jfWwTr95VsjGumKcJZ4Mn
	o84ubdm50zMQ6czE7oM8D6eINlzaf0eunlM5k2pqyJtZ35r/g15GIlzSoyN54WQW9pQ==
X-Received: by 2002:ac8:17bd:: with SMTP id o58mr8758538qtj.245.1553110019289;
        Wed, 20 Mar 2019 12:26:59 -0700 (PDT)
X-Received: by 2002:ac8:17bd:: with SMTP id o58mr8758485qtj.245.1553110018482;
        Wed, 20 Mar 2019 12:26:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553110018; cv=none;
        d=google.com; s=arc-20160816;
        b=p2hZXgQ8PNGESU99m3vC2SSTL/Ubmqk/6MPgbPTH9dqOAPj71VP808cy3DryvVk9vk
         wWhcM4a9qKC20knHndZA6ItIRLJALXf8Q/L5iQGCgMBF/z3vqYaLZZzVcJOC3mTlB0gi
         gMa5DDjFbaQCLCJ39jV0qFbDbM+olIwEQjF20+8Jd+s8KiFyLA64hb0WV03pM3dPWiIa
         CQeorQQbT9MjFce1Pv+ACB0ysFh5sbZRCyXO4DhseEtNHV8bFqM0EEG7+BnCw9/TQrD6
         RzkfkQoyZuXDJz3kGyVbjHikrMNf60fkuZQrFzgPbcj5sSKSGiadUwMl3Sl5NlxJbP3m
         eu3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=I3tdl5L6G+L4wZtfr4ffg2pY8PDniLnkmBZEEfgscCA=;
        b=u7E0Bh31Q6er5yA/0vJY+3cBX32FMPUEyakuvS+0Su3Jl5uMyEWTyNIcHbP6/SWzTn
         aysjYM512AdZmHEsDcehc1rOPJhikN/vSlR51Dl5FVKFR4lldjltFM7wLWqpzuxsxBb/
         osh7gCe4QMS20M2Lakyk7HGrRowEPTKnxzeKLgCNebRziQCoek+Ts18wmY/HEIf624n6
         3G/NvwNzHCTmFUZvPF+et8cU1gCKFZyERhjvGdTQTgVfmuGiN9a15XBh0bJTz3Cfgj3e
         1CIXtv1lXeA6zPmNoosvgy9F3MyoHmSBojDncgiTkTQdEbqcQKsJg3vHXmaLl8rvTBNJ
         h8QQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Ft0YhVKA;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l188sor2357455qkf.0.2019.03.20.12.26.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 12:26:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Ft0YhVKA;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=I3tdl5L6G+L4wZtfr4ffg2pY8PDniLnkmBZEEfgscCA=;
        b=Ft0YhVKA30FM2Hwf8vkspCk3n5ip2zIvvmvY8RV6Ov4RmZuHWO/F8Pbxr/iUKEqVlw
         y8whAbF9u6PEGSfEICgZ6zeRjmzrrO15PILAI9Pktg3ZtlEeDZrs6ZHYM5IpK+JtSPFN
         hLBakyVyvIqg21r1zK/+wSUzwviT/36jB8HcKaXXAwc+Zfm3Ep7iY0K1d5FcVptnDog8
         mmy4LCACnW5kFoa4AHr9YBHtvqczueRLG6AOA/a6EiJa8VGWrE+AEPv84EjmHJxEf8Mt
         ByIbVHbx4HP63LY0J6SZPQ29df3o5ll/EdioGYcLtNIgmDjLhki/QMx8KQ+SA65E3DYU
         2KdA==
X-Google-Smtp-Source: APXvYqxwQ+rf8Hlos+xrj8IgGII+vS1qst7ATAFPtfT/DhH5vTyzU1J9HFNoCoBzBoK1fqcP7TpElQ==
X-Received: by 2002:a37:27d4:: with SMTP id n203mr8028336qkn.105.1553110017618;
        Wed, 20 Mar 2019 12:26:57 -0700 (PDT)
Received: from ovpn-120-94.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id l129sm1449292qkb.44.2019.03.20.12.26.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 12:26:56 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mgorman@techsingularity.net,
	daniel.m.jordan@oracle.com,
	mikhail.v.gavrilov@gmail.com,
	vbabka@suse.cz,
	pasha.tatashin@soleen.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH v2] mm/compaction: abort search if isolation fails
Date: Wed, 20 Mar 2019 15:26:48 -0400
Message-Id: <20190320192648.52499-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Running LTP oom01 in a tight loop or memory stress testing put the
system in a low-memory situation could triggers random memory
corruption like page flag corruption below due to in
fast_isolate_freepages(), if isolation fails, next_search_order() does
not abort the search immediately could lead to improper accesses.

UBSAN: Undefined behaviour in ./include/linux/mm.h:1195:50
index 7 is out of range for type 'zone [5]'
Call Trace:
 dump_stack+0x62/0x9a
 ubsan_epilogue+0xd/0x7f
 __ubsan_handle_out_of_bounds+0x14d/0x192
 __isolate_free_page+0x52c/0x600
 compaction_alloc+0x886/0x25f0
 unmap_and_move+0x37/0x1e70
 migrate_pages+0x2ca/0xb20
 compact_zone+0x19cb/0x3620
 kcompactd_do_work+0x2df/0x680
 kcompactd+0x1d8/0x6c0
 kthread+0x32c/0x3f0
 ret_from_fork+0x35/0x40
------------[ cut here ]------------
kernel BUG at mm/page_alloc.c:3124!
invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
RIP: 0010:__isolate_free_page+0x464/0x600
RSP: 0000:ffff888b9e1af848 EFLAGS: 00010007
RAX: 0000000030000000 RBX: ffff888c39fcf0f8 RCX: 0000000000000000
RDX: 1ffff111873f9e25 RSI: 0000000000000004 RDI: ffffed1173c35ef6
RBP: ffff888b9e1af898 R08: fffffbfff4fc2461 R09: fffffbfff4fc2460
R10: fffffbfff4fc2460 R11: ffffffffa7e12303 R12: 0000000000000008
R13: dffffc0000000000 R14: 0000000000000000 R15: 0000000000000007
FS:  0000000000000000(0000) GS:ffff888ba8e80000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fc7abc00000 CR3: 0000000752416004 CR4: 00000000001606a0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
 compaction_alloc+0x886/0x25f0
 unmap_and_move+0x37/0x1e70
 migrate_pages+0x2ca/0xb20
 compact_zone+0x19cb/0x3620
 kcompactd_do_work+0x2df/0x680
 kcompactd+0x1d8/0x6c0
 kthread+0x32c/0x3f0
 ret_from_fork+0x35/0x40

Fixes: dbe2d4e4f12e ("mm, compaction: round-robin the order while searching the free lists for a target")
Signed-off-by: Qian Cai <cai@lca.pw>
---

v2: abort the search by causing a wrap-around, so cc->search_order can be
    updated for the next search.

 mm/compaction.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 6aebf1eb8d98..0d1156578114 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1365,7 +1365,7 @@ fast_isolate_freepages(struct compact_control *cc)
 				count_compact_events(COMPACTISOLATED, nr_isolated);
 			} else {
 				/* If isolation fails, abort the search */
-				order = -1;
+				order = cc->search_order + 1;
 				page = NULL;
 			}
 		}
-- 
2.17.2 (Apple Git-113)

