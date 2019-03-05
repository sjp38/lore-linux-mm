Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14578C43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 03:55:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F4FB20663
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 03:55:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="NII5eSaO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F4FB20663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25E9F8E0003; Mon,  4 Mar 2019 22:55:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20DE68E0001; Mon,  4 Mar 2019 22:55:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1251E8E0003; Mon,  4 Mar 2019 22:55:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id DEFD28E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 22:55:08 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id d134so6060254qkc.17
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 19:55:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:to:cc:from:subject:message-id
         :date:user-agent:mime-version:content-language
         :content-transfer-encoding;
        bh=gtchVtkhpbUw5x5BeXcSl+kTTS2T1jNmi26iky3V8CI=;
        b=QbclPKMSB7UXH/KYtv4PDtHuwaUtperibXVqgTgZ5OvBfgX8ZPkLmaSJ7X0tq8vly8
         0Spg8W4qgFHcediRWYQj2arOv9f+UPRRwuMiGM4eBVr9TmPsihnqjsvt7LuNnyph0Mr+
         vr5KwHlmVYBtfUUBwB8c6iY3DPj4qIGvfQJole7vp26HJj4EVu1sLFyPXemT6dyIrXrH
         qSkpydNOl6xUywsOrjfG5iMO1OYWpSnmqWIOwOIK3c9/zbjP2wqXdoFQdqdrybw0P5CT
         QP9Kn2xepxTacieq4tM0dkOcjYnh0fYUDKYv/EGf5DqcOPixLOLIW3izggiY33HrUEpJ
         U2Wg==
X-Gm-Message-State: APjAAAXKtm7SAwv6wtQxUwVIqgiuy6R0c53JXOIgO8OTvNrQgIwW9dp2
	kW06Sx5XciKX53uHfixNg+RdYZ2vi+LodxO0WQy+XYPOLf6pqkUdo+IIf3Ql6jScP5wLJCMOShc
	3ko4TuJNjZ6PeQhATsi0mj10rshZLtvxWGzW2ybDNwt0hTiRyrcZq2YNSsXRmGuTq28pcTMVz3C
	iZGJyutG36LFkKPmzsZvOtHLBs3HnOemprHT6MjMUQz67ZlqSQ3ggSUnPxUPGSnXpBP4KR1ywt+
	EvXBVtxrX3SvUbhHYT6EvkkWrBsCoPzvl+60lSgrsEe0CdU4DmscAuC10GO7bFXHVSHHQQfopUC
	ee3qeQSRVWUu3yvd2LwUdyoR6fsOnOr7eInWPPhWv5OQplZmZcNYxYJpqmweQ6Z59jWaHv4qYz8
	d
X-Received: by 2002:a0c:87d0:: with SMTP id 16mr565881qvk.166.1551758108541;
        Mon, 04 Mar 2019 19:55:08 -0800 (PST)
X-Received: by 2002:a0c:87d0:: with SMTP id 16mr565847qvk.166.1551758107634;
        Mon, 04 Mar 2019 19:55:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551758107; cv=none;
        d=google.com; s=arc-20160816;
        b=d03sarnH4UWhJFE9Mar0dJRV8e+MaslrfNiOibQ1hpmWhPfAHcDm7ZQ/U6ffwdg0s5
         aZBGvhI1wFdXcdhmCSpEYz9pHFyIP/Iqkrmh1vehasarsmJiuMPEVsUhhYyYDn0ILQzg
         0lakAfb6LcfoZjwazULey18MWIauqQ30eS10pJBHwsMrX7guI+017NZcWcKbNqqSK8u+
         3r6f2MmyzGMFOy0uDeV+eTEitn8X4NUa9KvFS3THgpDYRgz4iD0F4b4D/8EGDDXebMAe
         VLZCyq43UgKPJQv834xFw+myd6bLLXL/9gq5cjMntlcdSJo5Tizsp54bB3tfPOgT5w/Z
         +pKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:subject:from:cc:to:dkim-signature;
        bh=gtchVtkhpbUw5x5BeXcSl+kTTS2T1jNmi26iky3V8CI=;
        b=uMPZBvNFCGjgPNaS82cNZ3koTJmsuwRXFIQKYrJV/zlxr5gBPKRO1tIsm+caei0xWZ
         0Pe20QqLpoPr959MNnl+SI+TjGFr44/rxpuO+V2BR7ptgsYvVrzQmfq9MfODxdIudPcj
         7WfGejznHD9WrQZ0mruMnZWGGphASebRHj9+F482Pet1WgIWxfFMlT1q7GmO5LXRJTe2
         c6UIQnwWIofH1RNZ6u3Rli2KbMiJMzXHdcw+PPAlqVNSDXgBKkwfXjiGtQzxl11Z9k5X
         l6VstRhpyIhqYLpx1srPAquVnpqhSruW71BZMQMM73wdim4Cjq2AJoY2WGbz+SKKrB4Z
         Ve8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=NII5eSaO;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w7sor4215229qkw.115.2019.03.04.19.55.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Mar 2019 19:55:07 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=NII5eSaO;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=to:cc:from:subject:message-id:date:user-agent:mime-version
         :content-language:content-transfer-encoding;
        bh=gtchVtkhpbUw5x5BeXcSl+kTTS2T1jNmi26iky3V8CI=;
        b=NII5eSaOsdpnewFsPr+VdPwatnoeLULRPQ3vgYQgI6j8bD7BeGsNeEMCp+0tN6VHMS
         9kdCv3faRd9lim3e37+YStxslPvaZUiZthsp0LUwV70U9DJXxpMTekjm1PgRgTnV3PHj
         jJbiwIa30Crqp0D3OtPXPFSDC0f8Y9aWe1NTn9fFbRXDZVJlkUHXJZax5h+qjW/SLJaQ
         AAwcL8is1/KOwU+awyI8nNlWHeBINP22QpT9dEnBdwkCvdoTWLB9BKVGtVVLGSMfHdi+
         ti6NHKi78IRI7gKRTNu/Dho5mSW8G05QMre5Ac2oIi1KsBliWWAKU9ItNE6DEV11T7Up
         gfbg==
X-Google-Smtp-Source: APXvYqwsl1ADw1AD26GQEgzvcfncCNyn5RjRIfFhrIEVUXPpCk59gewmYNZrSybWHLStG3L/mAnFAg==
X-Received: by 2002:ae9:f809:: with SMTP id x9mr321332qkh.84.1551758106817;
        Mon, 04 Mar 2019 19:55:06 -0800 (PST)
Received: from ovpn-120-151.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id c19sm4515050qkg.88.2019.03.04.19.55.05
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 19:55:06 -0800 (PST)
To: Mel Gorman <mgorman@techsingularity.net>
Cc: vbabka@suse.cz, Linux-MM <linux-mm@kvack.org>
From: Qian Cai <cai@lca.pw>
Subject: low-memory crash with patch "capture a page under direct compaction"
Message-ID: <604a92ae-cbbb-7c34-f9aa-f7c08925bedf@lca.pw>
Date: Mon, 4 Mar 2019 22:55:04 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Reverted the patches below from linux-next seems fixed a crash while running LTP
oom01.

915c005358c1 mm, compaction: Capture a page under direct compaction -fix
e492a5711b67 mm, compaction: capture a page under direct compaction

Especially, just removed this chunk along seems fixed the problem.

--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -2227,10 +2227,10 @@ compact_zone(struct compact_control *cc, struct
capture_control *capc)
                }

                /* Stop if a page has been captured */
-               if (capc && capc->page) {
-                       ret = COMPACT_SUCCESS;
-                       break;
-               }


BUG_ON(!PageBuddy(page)); from  __isolate_free_page
fast_isolate_freepages at mm/compaction.c:1358
(inlined by) isolate_freepages at mm/compaction.c:1431
(inlined by) compaction_alloc at mm/compaction.c:1543
unmap_and_move at mm/migrate.c:1176
migrate_pages at mm/migrate.c:1426
compact_zone at mm/compaction.c:2174
kcompactd_do_work at mm/compaction.c:2557
kcompactd at mm/compaction.c:2640

[  985.025371] UBSAN: Undefined behaviour in ./include/linux/mm.h:1195:50
[  985.058855] index 7 is out of range for type 'zone [5]'
[  985.082233] CPU: 13 PID: 264 Comm: kcompactd1 Tainted: G        W
5.0.0-rc8-next-20190304+ #43
[  985.124314] Hardware name: HP ProLiant DL180 Gen9/ProLiant DL180 Gen9, BIOS
U20 10/25/2017
[  985.161530] Call Trace:
[  985.172517]  dump_stack+0x62/0x9a
[  985.187332]  ubsan_epilogue+0xd/0x7f
[  985.203347]  __ubsan_handle_out_of_bounds+0x14d/0x192
[  985.331394]  __isolate_free_page+0x52c/0x600
[  985.350570]  compaction_alloc+0x886/0x25f0
[  985.412281]  unmap_and_move+0x37/0x1e70
[  985.449069]  migrate_pages+0x2ca/0xb20
[  985.508167]  compact_zone+0x19cb/0x3620
[  985.587332]  kcompactd_do_work+0x2df/0x680
[  985.658292]  kcompactd+0x1d8/0x6c0
[  985.746357]  kthread+0x32c/0x3f0
[  985.797002]  ret_from_fork+0x35/0x40
[  985.812989]
================================================================================
[  985.850800] ------------[ cut here ]------------
[  985.871466] kernel BUG at mm/page_alloc.c:3124!
[  985.891423] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
[  985.919458] CPU: 13 PID: 264 Comm: kcompactd1 Tainted: G        W
5.0.0-rc8-next-20190304+ #43
[  985.961822] Hardware name: HP ProLiant DL180 Gen9/ProLiant DL180 Gen9, BIOS
U20 10/25/2017
[  985.999012] RIP: 0010:__isolate_free_page+0x464/0x600
[  986.021780] Code: 31 c0 5b 41 5c 41 5d 41 5e 41 5f 5d c3 48 c7 c6 e0 6e 6b a8
48 89 df e8 4a 8b f8 ff 0f 0b 48 c7 c7 e0 31 c9 a8 e8 a1 3f 43 00 <0f> 0b 48 c7
c7 20 31 c9 a8 e8 93 3f 43 00 48 c7 c6 40 71 6b a8 48
[  986.111505] RSP: 0000:ffff8881f56cf848 EFLAGS: 00010883
[  986.134890] RAX: 0000000070000080 RBX: ffff88847e030160 RCX: 0000000000000000
[  986.167582] RDX: 1ffff1108fc06032 RSI: 0000000000000004 RDI: ffffed103ead9ef6
[  986.199580] RBP: ffff8881f56cf898 R08: fffffbfff51c2471 R09: fffffbfff51c2470
[  986.231619] R10: fffffbfff51c2470 R11: ffffffffa8e12383 R12: 0000000000000008
[  986.264032] R13: dffffc0000000000 R14: 0000000000000000 R15: 0000000000000007
[  986.296108] FS:  0000000000000000(0000) GS:ffff888455480000(0000)
knlGS:0000000000000000
[  986.332433] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  986.358224] CR2: 00007f9c620d0000 CR3: 000000041b416004 CR4: 00000000001606a0
[  986.390940] Call Trace:
[  986.401894]  compaction_alloc+0x886/0x25f0
[  986.462643]  unmap_and_move+0x37/0x1e70
[  986.500043]  migrate_pages+0x2ca/0xb20
[  986.560356]  compact_zone+0x19cb/0x3620
[  986.638822]  kcompactd_do_work+0x2df/0x680
[  986.710168]  kcompactd+0x1d8/0x6c0
[  986.798424]  kthread+0x32c/0x3f0
[  986.849165]  ret_from_fork+0x35/0x40
[  986.865180] Modules linked in: nls_iso8859_1 nls_cp437 vfat fat kvm_intel kvm
irqbypass efivars ip_tables x_tables xfs sd_mod ahci igb libahci i2c_algo_bit
libata i2c_core dm_mirror dm_region_hash dm_log dm_mod efivarfs
[  986.953234] ---[ end trace 9cfeadd3642eaaf8 ]---
[  986.974041] RIP: 0010:__isolate_free_page+0x464/0x600
[  986.996784] Code: 31 c0 5b 41 5c 41 5d 41 5e 41 5f 5d c3 48 c7 c6 e0 6e 6b a8
48 89 df e8 4a 8b f8 ff 0f 0b 48 c7 c7 e0 31 c9 a8 e8 a1 3f 43 00 <0f> 0b 48 c7
c7 20 31 c9 a8 e8 93 3f 43 00 48 c7 c6 40 71 6b a8 48
[  987.085030] RSP: 0000:ffff8881f56cf848 EFLAGS: 00010883
[  987.109886] RAX: 0000000070000080 RBX: ffff88847e030160 RCX: 0000000000000000
[  987.141793] RDX: 1ffff1108fc06032 RSI: 0000000000000004 RDI: ffffed103ead9ef6
[  987.173768] RBP: ffff8881f56cf898 R08: fffffbfff51c2471 R09: fffffbfff51c2470
[  987.205814] R10: fffffbfff51c2470 R11: ffffffffa8e12383 R12: 0000000000000008
[  987.237426] R13: dffffc0000000000 R14: 0000000000000000 R15: 0000000000000007
[  987.269606] FS:  0000000000000000(0000) GS:ffff888455480000(0000)
knlGS:0000000000000000
[  987.305810] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  987.332027] CR2: 00007f9c620d0000 CR3: 000000041b416004 CR4: 00000000001606a0
[  987.365458] Kernel panic - not syncing: Fatal exception
[  988.449736] Shutting down cpus with NMI
[  988.470880] Kernel Offset: 0x26200000 from 0xffffffff81000000 (relocation
range: 0xffffffff80000000-0xffffffffbfffffff)
[  988.522206] ---[ end Kernel panic - not syncing: Fatal exception ]---

