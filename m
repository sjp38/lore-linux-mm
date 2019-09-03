Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF866C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 18:25:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74EFC20828
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 18:25:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="p2mOQcWn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74EFC20828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 108AE6B0007; Tue,  3 Sep 2019 14:25:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BA806B0008; Tue,  3 Sep 2019 14:25:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC25C6B000A; Tue,  3 Sep 2019 14:25:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0169.hostedemail.com [216.40.44.169])
	by kanga.kvack.org (Postfix) with ESMTP id C8E026B0007
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 14:25:40 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 532D9824CA20
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 18:25:40 +0000 (UTC)
X-FDA: 75894437640.27.self67_14504f9c8161c
X-HE-Tag: self67_14504f9c8161c
X-Filterd-Recvd-Size: 12272
Received: from mail-lf1-f66.google.com (mail-lf1-f66.google.com [209.85.167.66])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 18:25:39 +0000 (UTC)
Received: by mail-lf1-f66.google.com with SMTP id x80so2581179lff.3
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 11:25:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=ClTJR97e6Znw+CmDzmYc0XWPIsyXNFxeCVoA2nAhqIw=;
        b=p2mOQcWnzc0NxC0h888ap5o8d7Li8NUJXHjkBbAQLiR0XZjsvXy1FHlHkC/0+/CAsF
         smekvRCmaeLbHHnFDt6l2XxM2HKvYzLPNiLTwvAWWj0JAJLpvvuElec22QUcFyhKR7eJ
         aC2WhcOxg4PkNbSveusUsRE/hPbbj2GLkGWqrrijKK8m4ORAZcR0nim547/5AEWTYM78
         xtu4w0Qq99sUnyvBPA6qzAcxgoF7NUCtSe7DpkDikgnSuz9UqcmEnB69H41WKBe/FvPq
         Cn628xcf4MqUnJI/xgYkvylCyDwPhAN4qVF5TNg3K2N/zT6iHhShMuNnO2XDbNB5wkNS
         +53Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=ClTJR97e6Znw+CmDzmYc0XWPIsyXNFxeCVoA2nAhqIw=;
        b=MDRWNHY+Z4eEddHcOtrr7ZFrSZtDcr4hOjrIcZYrpociogMrZ8m2ZDUCz4oZsE+IiO
         uov9RYuCXxm7A1hiKz9ImeGrXi86IuTR+Pln6R31ccS8LbKPSGmkAA0JCg6ZBxUlmkCX
         NcbjS2sBHWhjGzloXl4WzmtTpFwHD8H+PUbZsVR0I3vpF+qOIi5aGEwdNZnUP3U5sfkk
         Yktx7xwDgWuHmfh+YIcwIKRUWiYjdQpPfS73zqq4QHeSdg1QmWud02ME3Md8X35v64nC
         3f4hf+IDpuALZOkHW6h7oJEK7IwlimvVy/WZ6pWyVHz8dYno2cHmRhaaPm8RZJZND9r/
         p0xA==
X-Gm-Message-State: APjAAAWEPiWtcL5gXgYvx6CLD77IfKK5A//64cP+jENxflcUOLcvJn7f
	xYEBatpxqw7kiW39pHhnIE9NzOOBTd0=
X-Google-Smtp-Source: APXvYqy9rWreUxFSBhiOi4c+Q/tMhwXLNPL5JCTfmcHAmc7BF9d9rM6iCDM/1SY/IP706OR49d0j1A==
X-Received: by 2002:ac2:4835:: with SMTP id 21mr20790550lft.121.1567535137669;
        Tue, 03 Sep 2019 11:25:37 -0700 (PDT)
Received: from [84.217.173.115] (c-8caed954.51034-0-757473696b74.bbcust.telenor.se. [84.217.173.115])
        by smtp.gmail.com with ESMTPSA id p10sm2499176lji.71.2019.09.03.11.25.37
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 03 Sep 2019 11:25:37 -0700 (PDT)
Subject: Re: [BUG] Early OOM and kernel NULL pointer dereference in 4.19.69
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org
References: <31131c2d-a936-8bbf-e58d-a3baaa457340@gmail.com>
 <666dbcde-1b8a-9e2d-7d1f-48a117c78ae1@I-love.SAKURA.ne.jp>
From: Thomas Lindroth <thomas.lindroth@gmail.com>
Message-ID: <ccf79dd9-b2e5-0d78-f520-164d198f9ca4@gmail.com>
Date: Tue, 3 Sep 2019 20:25:36 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <666dbcde-1b8a-9e2d-7d1f-48a117c78ae1@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/3/19 3:33 PM, Tetsuo Handa wrote:
> On 2019/09/02 5:43, Thomas Lindroth wrote:
>> Those kernel memory allocation failures can also cause kernel NULL pointer
>> dereference. Here is a dmesg captured over netconsole when that happens:
> 
> Can you establish steps to reproduce this crash?
> Since it seems that __GFP_NOFAIL allocation is failing for some reason, we should fix it.

I have no reliable way to reproduce the crash. I just setup a v1 memory cgroup
with memory.kmem.limit_in_bytes < memory.limit_in_bytes then run something that
allocates SLUB memory and deplete the kmem limit. Usually the OOM killer is
triggered when the kmem limit is hit but sometimes I get warnings like
"SLUB: Unable to allocate memory on node -1" and kernel null pointer
dereference.

Running "find / -xdev -type f -print0 | xargs -0 -n 1 -P 8 stat > /dev/null"
in the cgroup is an easy way to allocate ext4_inode_cache and deplete the kmem
limit but I never got any null pointer deref that way. Building the chromium
browser in the cgroup can also trigger the kmem limit and will sometimes cause
null pointer deref.

Here is another null pointer deref I got while building chromium in the cgroup.
4,1180,556857645,-;SLUB: Unable to allocate memory on node -1, gfp=0x600040(GFP_NOFS)
4,1181,556857652,-;  cache: ext4_inode_cache(100:12G), object size: 1024, buffer size: 1032, default order: 3, min order: 0
4,1182,556857654,-;  node 0: slabs: 17997, objs: 557851, free: 0
4,1183,556857675,-;SLUB: Unable to allocate memory on node -1, gfp=0x600040(GFP_NOFS)
4,1184,556857677,-;  cache: ext4_inode_cache(100:12G), object size: 1024, buffer size: 1032, default order: 3, min order: 0
4,1185,556857679,-;  node 0: slabs: 17997, objs: 557851, free: 0
4,1186,556857955,-;SLUB: Unable to allocate memory on node -1, gfp=0x600040(GFP_NOFS)
4,1187,556857957,-;  cache: ext4_inode_cache(100:12G), object size: 1024, buffer size: 1032, default order: 3, min order: 0
4,1188,556857959,-;  node 0: slabs: 18003, objs: 557869, free: 0
4,1189,556857974,-;SLUB: Unable to allocate memory on node -1, gfp=0x600040(GFP_NOFS)
4,1190,556857976,-;  cache: ext4_inode_cache(100:12G), object size: 1024, buffer size: 1032, default order: 3, min order: 0
4,1191,556857979,-;  node 0: slabs: 18003, objs: 557869, free: 0
4,1192,556857989,-;SLUB: Unable to allocate memory on node -1, gfp=0x600040(GFP_NOFS)
4,1193,556857992,-;  cache: ext4_inode_cache(100:12G), object size: 1024, buffer size: 1032, default order: 3, min order: 0
4,1194,556857994,-;  node 0: slabs: 18003, objs: 557869, free: 0
4,1195,556858518,-;SLUB: Unable to allocate memory on node -1, gfp=0x600040(GFP_NOFS)
4,1196,556858522,-;  cache: ext4_inode_cache(100:12G), object size: 1024, buffer size: 1032, default order: 3, min order: 0
4,1197,556858523,-;  node 0: slabs: 18003, objs: 557869, free: 0
4,1198,556858535,-;SLUB: Unable to allocate memory on node -1, gfp=0x600040(GFP_NOFS)
4,1199,556858537,-;  cache: ext4_inode_cache(100:12G), object size: 1024, buffer size: 1032, default order: 3, min order: 0
4,1200,556858538,-;  node 0: slabs: 18003, objs: 557869, free: 0
4,1201,556858545,-;SLUB: Unable to allocate memory on node -1, gfp=0x600040(GFP_NOFS)
4,1202,556858547,-;  cache: ext4_inode_cache(100:12G), object size: 1024, buffer size: 1032, default order: 3, min order: 0
4,1203,556858548,-;  node 0: slabs: 18003, objs: 557869, free: 0
4,1204,556858554,-;SLUB: Unable to allocate memory on node -1, gfp=0x600040(GFP_NOFS)
4,1205,556858556,-;  cache: ext4_inode_cache(100:12G), object size: 1024, buffer size: 1032, default order: 3, min order: 0
4,1206,556858558,-;  node 0: slabs: 18003, objs: 557869, free: 0
4,1207,556858748,-;SLUB: Unable to allocate memory on node -1, gfp=0x600040(GFP_NOFS)
4,1208,556858751,-;  cache: ext4_inode_cache(100:12G), object size: 1024, buffer size: 1032, default order: 3, min order: 0
4,1209,556858753,-;  node 0: slabs: 18003, objs: 557869, free: 0
1,1210,556861832,-;BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
6,1211,556861836,-;PGD 0
4,1212,556861837,c;P4D 0
4,1213,556861839,-;Oops: 0000 [#1] PREEMPT SMP PTI
4,1214,556861841,-;CPU: 7 PID: 12228 Comm: find Not tainted 4.19.69 #43
4,1215,556861842,-;Hardware name: Gigabyte Technology Co., Ltd. Z97X-Gaming G1/Z97X-Gaming G1, BIOS F9 07/31/2015
4,1216,556861846,-;RIP: 0010:__getblk_gfp+0x181/0x240
4,1217,556861848,-;Code: e8 e4 ee ff ff 48 89 04 24 49 8b 46 30 48 8d b8 80 00 00 00 e8 20 5e 67 00 48 8b 04 24 44 8b 4c 24 1c 48 89 c1 eb 03 48 89 d1 <48> 8b 51 08 48 85 d2 75 f4 48 89 41 08 49 8b 4f 08 48 8d 51 ff 83
4,1218,556861850,-;RSP: 0018:ffffaba441853be8 EFLAGS: 00010246
4,1219,556861851,-;RAX: 0000000000000000 RBX: 0000000000001000 RCX: 0000000000000000
4,1220,556861853,-;RDX: 0000000000000001 RSI: 0000000000000082 RDI: ffff9824dd8943c8
4,1221,556861854,-;RBP: 0000000000000000 R08: ffffd552cd660e48 R09: 0000000000000000
4,1222,556861855,-;R10: 0000000000000000 R11: 0000000000000036 R12: ffff9824dd894100
4,1223,556861856,-;R13: 0000000001301775 R14: ffff9824dd8941d8 R15: ffffd552c84f1380
4,1224,556861858,-;FS:  00007fdd32a0cb80(0000) GS:ffff9824df9c0000(0000) knlGS:0000000000000000
4,1225,556861859,-;CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
4,1226,556861861,-;CR2: 0000000000000008 CR3: 00000003614b6002 CR4: 00000000001606e0
4,1227,556861862,-;Call Trace:
4,1228,556861866,-; ext4_getblk+0x91/0x1a0
4,1229,556861868,-; ext4_bread+0x1e/0xa0
4,1230,556861871,-; ? tomoyo_path_perm+0xa3/0x200
4,1231,556861873,-; __ext4_read_dirblock+0x2c/0x2e0
4,1232,556861875,-; htree_dirblock_to_tree+0x6a/0x1e0
4,1233,556861877,-; ext4_htree_fill_tree+0xcd/0x2f0
4,1234,556861880,-; ? kmem_cache_alloc_trace+0x163/0x1c0
4,1235,556861882,-; ext4_readdir+0x472/0x870
4,1236,556861886,-; iterate_dir+0x138/0x180
4,1237,556861967,-; ksys_getdents64+0x9c/0x130
4,1238,556861969,-; ? iterate_dir+0x180/0x180
4,1239,556861972,-; __x64_sys_getdents64+0x16/0x20
4,1240,556861974,-; do_syscall_64+0x59/0x180
4,1241,556861977,-; entry_SYSCALL_64_after_hwframe+0x44/0xa9
4,1242,556861979,-;RIP: 0033:0x7fdd32adef3b
4,1243,556861981,-;Code: 00 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 40 00 48 83 ec 18 64 48 8b 04 25 28 00 00 00 48 89 44 24 08 31 c0 b8 d9 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 1d 48 8b 4c 24 08 64 48 33 0c 25 28 00 00 00
4,1244,556861982,-;RSP: 002b:00007ffdf210cc10 EFLAGS: 00000246
4,1245,556861984,c; ORIG_RAX: 00000000000000d9
4,1246,556861985,-;RAX: ffffffffffffffda RBX: 0000563985f7f110 RCX: 00007fdd32adef3b
4,1247,556861986,-;RDX: 0000000000008000 RSI: 0000563985f7f140 RDI: 0000000000000006
4,1248,556861987,-;RBP: 0000563985f7f140 R08: 0000563985f740a8 R09: 0000563985f768f0
4,1249,556861988,-;R10: 0000000000000100 R11: 0000000000000246 R12: ffffffffffffff80
4,1250,556861990,-;R13: 0000000000000000 R14: 0000563985f73c00 R15: 0000563985f74040
4,1251,556861991,-;Modules linked in:
4,1252,556861993,c; 8021q
4,1253,556861994,c; iptable_mangle
4,1254,556861996,c; xt_limit
4,1255,556861997,c; xt_conntrack
4,1256,556861998,c; iptable_filter
4,1257,556862000,c; iptable_nat
4,1258,556862001,c; nf_nat_ipv4
4,1259,556862002,c; nf_nat
4,1260,556862101,c; ip_tables
4,1261,556862102,c; arc4
4,1262,556862103,c; ath9k_htc
4,1263,556862104,c; ath9k_common
4,1264,556862105,c; ath9k_hw
4,1265,556862107,c; ath
4,1266,556862108,c; mac80211
4,1267,556862109,c; kvm_intel
4,1268,556862110,c; cfg80211
4,1269,556862111,c; kvm
4,1270,556862112,c; crc32_pclmul
4,1271,556862113,c; uas
4,1272,556862115,c; usb_storage
4,1273,556862116,c; cdc_acm
4,1274,556862117,c; joydev
4,1275,556862118,-;CR2: 0000000000000008
4,1276,556862120,-;---[ end trace b7a234b0d1e0ec38 ]---
4,1277,556862122,-;RIP: 0010:__getblk_gfp+0x181/0x240
4,1278,556862123,-;Code: e8 e4 ee ff ff 48 89 04 24 49 8b 46 30 48 8d b8 80 00 00 00 e8 20 5e 67 00 48 8b 04 24 44 8b 4c 24 1c 48 89 c1 eb 03 48 89 d1 <48> 8b 51 08 48 85 d2 75 f4 48 89 41 08 49 8b 4f 08 48 8d 51 ff 83
4,1279,556862125,-;RSP: 0018:ffffaba441853be8 EFLAGS: 00010246
4,1280,556862126,-;RAX: 0000000000000000 RBX: 0000000000001000 RCX: 0000000000000000
4,1281,556862127,-;RDX: 0000000000000001 RSI: 0000000000000082 RDI: ffff9824dd8943c8
4,1282,556862129,-;RBP: 0000000000000000 R08: ffffd552cd660e48 R09: 0000000000000000
4,1283,556862130,-;R10: 0000000000000000 R11: 0000000000000036 R12: ffff9824dd894100
4,1284,556862131,-;R13: 0000000001301775 R14: ffff9824dd8941d8 R15: ffffd552c84f1380
4,1285,556862132,-;FS:  00007fdd32a0cb80(0000) GS:ffff9824df9c0000(0000) knlGS:0000000000000000
4,1286,556862134,-;CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
4,1287,556862176,-;CR2: 0000000000000008 CR3: 00000003614b6002 CR4: 00000000001606e0
0,1288,556862178,-;Kernel panic - not syncing: Fatal exception
0,1289,556862184,-;Kernel Offset: 0x30000000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
0,1290,556862186,-;---[ end Kernel panic - not syncing: Fatal exception ]---

