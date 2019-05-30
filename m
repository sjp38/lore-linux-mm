Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B112AC28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 19:01:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 454BF2605D
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 19:01:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="ES8gEkF8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 454BF2605D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D28CB6B026B; Thu, 30 May 2019 15:01:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD9116B026D; Thu, 30 May 2019 15:01:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEF256B026E; Thu, 30 May 2019 15:01:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7256B026B
	for <linux-mm@kvack.org>; Thu, 30 May 2019 15:01:12 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id c4so5683364qkd.16
        for <linux-mm@kvack.org>; Thu, 30 May 2019 12:01:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:mime-version:content-transfer-encoding;
        bh=BCNbRN90Mxr3bOeb4va7biKBtd8uIGRNJ3ziuKc2OeI=;
        b=eq8qQFrftq5QOG4K1gfXDrnLp1XrSgIspFvSFSEPVJeNqvgQo6o6x9KfwlU7qUAXBH
         qH43hNXQ7D95rL1H5xQdOKKK9drwjAO60Cu17st9F9NZ12qeO98TXGTvy0f771oRRK8E
         v2HfqnSOVfJAsh0EKwy3LoBqQbbymV0kV2Nibab5rm9jjQ39qZX9ngWCVctS2+rYUK7o
         tB1vwhATHf1z7UZLYvXRrYc8lZ4sgWjHd9NAyLR5dzUlUosLP/YWxWiwj6lTPypLsMtK
         paqoeDShfGf6rEJLGM5iAlJK0tV/GhUwOs2zd76rt2u0t3jrCSuPFHyb2B1imVY1WqBy
         FYQg==
X-Gm-Message-State: APjAAAUxiQ9/LXMlSPjr9i58nA04fAVij55Ec3gB+Na5p03A/s1QItQZ
	cbjHLn/F1q1dm4gDf6EFlHc3zfY5HeHtR8VqFcJY4eIVcwkY27FAWrV5qmGR0rQAaCjfnrJr1j0
	DxR+ErSWbb8pjhyKU34Ckknggp6dlv6mu3/dgPwdVKtnxZBRQYQ87b45xtoAKeImWNg==
X-Received: by 2002:a0c:872c:: with SMTP id 41mr4868640qvh.213.1559242872372;
        Thu, 30 May 2019 12:01:12 -0700 (PDT)
X-Received: by 2002:a0c:872c:: with SMTP id 41mr4868529qvh.213.1559242871194;
        Thu, 30 May 2019 12:01:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559242871; cv=none;
        d=google.com; s=arc-20160816;
        b=DBEhrxM2N5W7xXu1GJd/PNSE0KMe71yPjSZFGVWFmpHmIXhLdZoFLwIZQm+A8Vgm+u
         TRJJdZfiNcJdkdQbqdkAD4wyB6QyvfVN76qSC8Ba740mVk05w4BoJDopb2dClgIuyfu2
         M49EvnruJSj14zeJCIFWL24QXOVDtQIxGtZ5CPDB83E/lCwNs/ymmNrlhOKS2GzMh9Bv
         Hf2BQIpN5sICqp6NgaZZdDOoh0tnZ2rOCXRObqwe4/740X7/IplneKcaglUeIUng6HUb
         M6cFabTWdno5BI5ZfvKKR9jPTLNeupUL6x+yO3PSsFs+EgUG4XBXdS3CbkqYWVuYh3k1
         KTGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:date:cc:to:from:subject
         :message-id:dkim-signature;
        bh=BCNbRN90Mxr3bOeb4va7biKBtd8uIGRNJ3ziuKc2OeI=;
        b=ysd/V1emRzv1G9+/FasP6y5eHgVJtzy3zEyePYl0YMFXGJW9E7U4YzKrLlmXFiNVqB
         s4zHmSlXpGyyIGrCvzLOn6DehWDz5QzOYy4Z9Tfb1Zc3faP5kemToB8gnsQUMCgoCbaA
         YhJcFY8BseOKg55c02k1HMUnWAr3PtjBF0bhG6L1qh90k+V+s+ueSzWr4PgQGSwIHrvs
         LfX89HY4AdXmeM6ldSW3cs4GyKkyvWkWBR2CgioEULaxc8FBjMQ8BkgPC/HKZb6KxVJX
         gPbwJ8PejVm0rDGPEd0DsdMz9U7d4DYfFvHRHFAyO5+N5/vgAM0qldGGy34d9y6xQu4x
         YRCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ES8gEkF8;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d16sor2889315qve.67.2019.05.30.12.01.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 12:01:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ES8gEkF8;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:mime-version
         :content-transfer-encoding;
        bh=BCNbRN90Mxr3bOeb4va7biKBtd8uIGRNJ3ziuKc2OeI=;
        b=ES8gEkF8u9bGqs6mlP+MUez9i3gjkXfyo8Ha6GImpg7cvCx60tqrgiNr4yy+dpy2tO
         A3eRG7lIYyxHhQPhMldkmzDR+6TvJUQ+y2EqMEFyu4xZCa9iFdfzOHf+epbeDlKdPfyG
         isyOlWCnP5Z5G3ydoQgNZbwu/CxM89HYQ2HmGrywZrHHWOv1bmi3wnqA+PGICymePu2a
         Hvrjs61gF/J+uNNKLfUQBQNeu+E8ACckvxLsUENTk1eN5PcLE530UZiQ57nBTWyrtsg/
         uyebW6aAWWAB8JXojCTgV+AWwn9w/Tvki4JF43r2x7v0ak7irH68z+IbirrE3Az7fJ12
         R1aA==
X-Google-Smtp-Source: APXvYqwJb4+Rk2tNcEuO5fo8neeRj1Ac71N+BoHNK6wzhea0OU1kmbdaS/gwMmucUeE++zcz0on/aA==
X-Received: by 2002:a0c:9e02:: with SMTP id p2mr4817117qve.150.1559242870338;
        Thu, 30 May 2019 12:01:10 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id l3sm1827188qkd.49.2019.05.30.12.01.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 12:01:09 -0700 (PDT)
Message-ID: <1559242868.6132.35.camel@lca.pw>
Subject: "lib: rework bitmap_parse()" triggers invalid access errors
From: Qian Cai <cai@lca.pw>
To: Yury Norov <ynorov@marvell.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, linux-kernel@vger.kernel.org, 
 Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Andrew Morton
 <akpm@linux-foundation.org>,  "linux-mm@kvack.org" <linux-mm@kvack.org>
Date: Thu, 30 May 2019 15:01:08 -0400
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The linux-next commit "lib: rework bitmap_parse" triggers errors below during
boot on both arm64 and powerpc with KASAN_SW_TAGS or SLUB_DEBUG enabled.

Reverted the commit and its dependency (lib: opencode in_str()) fixed the issue.

[   67.056867][ T3737] BUG kmalloc-16 (Tainted: G    B            ): Redzone
overwritten
[   67.056905][ T3737] -------------------------------------------------------
----------------------
[   67.056905][ T3737] 
[   67.056946][ T3737] INFO: 0x00000000bd269811-0x0000000039a2fb86. First byte
0x0 instead of 0xcc
[   67.056989][ T3737] INFO: Allocated in alloc_cpumask_var_node+0x38/0x80 age=0
cpu=62 pid=3737
[   67.057029][ T3737] 	__slab_alloc+0x34/0x60
[   67.057052][ T3737] 	__kmalloc_node+0x1a8/0x860
[   67.057086][ T3737] 	alloc_cpumask_var_node+0x38/0x80
[   67.057133][ T3737] 	write_irq_affinity.isra.0+0x84/0x1e0
[   67.057178][ T3737] 	proc_reg_write+0x90/0x130
[   67.057224][ T3737] 	__vfs_write+0x3c/0x70
[   67.057261][ T3737] 	vfs_write+0xd8/0x210
[   67.057292][ T3737] 	ksys_write+0x7c/0x140
[   67.057325][ T3737] 	system_call+0x5c/0x70
[   67.057355][ T3737] INFO: Freed in free_cpumask_var+0x18/0x30 age=0 cpu=62
pid=3737
[   67.057392][ T3737] 	free_cpumask_var+0x18/0x30
[   67.057427][ T3737] 	write_irq_affinity.isra.0+0x130/0x1e0
[   67.057464][ T3737] 	proc_reg_write+0x90/0x130
[   67.057525][ T3737] 	__vfs_write+0x3c/0x70
[   67.057558][ T3737] 	vfs_write+0xd8/0x210
[   67.057607][ T3737] 	ksys_write+0x7c/0x140
[   67.057643][ T3737] 	system_call+0x5c/0x70
[   67.057692][ T3737] INFO: Slab 0x00000000786814bb objects=186 used=49
fp=0x0000000019431596 flags=0x3fffc000000201
[   67.057810][ T3737] INFO: Object 0x000000005c0b6a3a @offset=25352
fp=0x00000000a42ffc35
[   67.057810][ T3737] 
[   67.057922][ T3737] Redzone 00000000d929958b: cc cc cc cc cc cc cc
cc                          ........
[   67.058024][ T3737] Object 000000005c0b6a3a: 00 00 00 00 00 00 00 04 00 00 00
00 00 00 00 00  ................
[   67.058171][ T3737] Redzone 00000000bd269811: 00 00 00 00 00 00 00
00                          ........
[   67.058283][ T3737] Padding 00000000b327be67: 5a 5a 5a 5a 5a 5a 5a
5a                          ZZZZZZZZ
[   67.058383][ T3737] CPU: 62 PID: 3737 Comm: irqbalance Tainted:
G    B             5.2.0-rc2-next-20190530 #13
[   67.058508][ T3737] Call Trace:
[   67.058531][ T3737] [c000001c4738f930] [c00000000089045c]
dump_stack+0xb0/0xf4 (unreliable)
[   67.058653][ T3737] [c000001c4738f970] [c0000000003dd368]
print_trailer+0x23c/0x264
[   67.058751][ T3737] [c000001c4738fa00] [c0000000003cd7d8]
check_bytes_and_report+0x138/0x160
[   67.058846][ T3737] [c000001c4738faa0] [c0000000003cfb9c]
check_object+0x2ac/0x3e0
[   67.058914][ T3737] [c000001c4738fb10] [c0000000003d646c]
free_debug_processing+0x1ec/0x680
[   67.059009][ T3737] [c000001c4738fc00] [c0000000003d6c54]
__slab_free+0x354/0x6d0
[   67.059113][ T3737] [c000001c4738fcc0] [c00000000088fda8]
free_cpumask_var+0x18/0x30
[   67.059205][ T3737] [c000001c4738fce0] [c0000000001c3fc0]
write_irq_affinity.isra.0+0x130/0x1e0
[   67.059324][ T3737] [c000001c4738fd30] [c00000000050c6b0]
proc_reg_write+0x90/0x130
[   67.059415][ T3737] [c000001c4738fd60] [c0000000004475ac]
__vfs_write+0x3c/0x70
[   67.059498][ T3737] [c000001c4738fd80] [c00000000044b0a8]
vfs_write+0xd8/0x210
[   67.059581][ T3737] [c000001c4738fdd0] [c00000000044b44c]
ksys_write+0x7c/0x140
[   67.059692][ T3737] [c000001c4738fe20] [c00000000000b108]
system_call+0x5c/0x70
[   67.059781][ T3737] FIX kmalloc-16: Restoring 0x00000000bd269811-
0x0000000039a2fb86=0xcc
[   67.059781][ T3737] 
[   67.059922][ T3737] FIX kmalloc-16: Object at 0x000000005c0b6a3a not freed


  185.039693][ T3647] BUG: KASAN: invalid-access in bitmap_parse+0x20c/0x2d8
[  185.039701][ T3647] Write of size 8 at addr 33ff809501263f20 by task
irqbalance/3647
[  185.039710][ T3647] Pointer tag: [33], memory tag: [fe]
[  185.056475][ T3647] 
[  185.056486][ T3647] CPU: 218 PID: 3647 Comm: irqbalance Tainted:
G        W         5.2.0-rc2-next-20190530+ #5
[  185.056491][ T3647] Hardware name: HPE Apollo
70             /C01_APACHE_MB         , BIOS L50_5.13_1.0.9 03/01/2019
[  185.056498][ T3647] Call trace:
[  185.079885][ T3647]  dump_backtrace+0x0/0x268
[  185.079896][ T3647]  show_stack+0x20/0x2c
[  185.092149][ T3647]  dump_stack+0xb4/0x108
[  185.092162][ T3647]  print_address_description+0x7c/0x330
[  185.092172][ T3647]  __kasan_report+0x194/0x1dc
[  185.116236][ T3647]  kasan_report+0x10/0x18
[  185.116243][ T3647]  __hwasan_store8_noabort+0x74/0x7c
[  185.116248][ T3647]  bitmap_parse+0x20c/0x2d8
[  185.116254][ T3647]  bitmap_parse_user+0x40/0x64
[  185.116268][ T3647]  write_irq_affinity+0x118/0x1a8
[  185.135032][ T3647]  irq_affinity_proc_write+0x34/0x44
[  185.135040][ T3647]  proc_reg_write+0xf4/0x130
[  185.135057][ T3647]  __vfs_write+0x88/0x33c
[  185.135067][ T3647]  vfs_write+0x118/0x208
[  185.144546][ T3647]  ksys_write+0xa0/0x110
[  185.158794][ T3647]  __arm64_sys_write+0x54/0x88
[  185.158811][ T3647]  el0_svc_handler+0x198/0x260
[  185.158820][ T3647]  el0_svc+0x8/0xc
[  185.172464][ T3647] 
[  185.172469][ T3647] Allocated by task 3647:
[  185.172476][ T3647]  __kasan_kmalloc+0x114/0x1d0
[  185.172481][ T3647]  kasan_kmalloc+0x10/0x18
[  185.172499][ T3647]  __kmalloc_node+0x1e0/0x7cc
[  185.192389][ T3647]  alloc_cpumask_var_node+0x48/0x94
[  185.192395][ T3647]  alloc_cpumask_var+0x10/0x1c
[  185.192400][ T3647]  write_irq_affinity+0xa8/0x1a8
[  185.192406][ T3647]  irq_affinity_proc_write+0x34/0x44
[  185.192415][ T3647]  proc_reg_write+0xf4/0x130
[  185.224744][ T3647]  __vfs_write+0x88/0x33c
[  185.224750][ T3647]  vfs_write+0x118/0x208
[  185.224756][ T3647]  ksys_write+0xa0/0x110
[  185.224766][ T3647]  __arm64_sys_write+0x54/0x88
[  185.258392][ T3647]  el0_svc_handler+0x198/0x260
[  185.258398][ T3647]  el0_svc+0x8/0xc
[  185.258401][ T3647] 
[  185.258405][ T3647] Freed by task 3647:
[  185.258411][ T3647]  __kasan_slab_free+0x154/0x228
[  185.258417][ T3647]  kasan_slab_free+0xc/0x18
[  185.258422][ T3647]  kfree+0x268/0xb70
[  185.258428][ T3647]  free_cpumask_var+0xc/0x14
[  185.258446][ T3647]  write_irq_affinity+0x19c/0x1a8
[  185.273666][ T3647]  irq_affinity_proc_write+0x34/0x44
[  185.273675][ T3647]  proc_reg_write+0xf4/0x130
[  185.288620][ T3647]  __vfs_write+0x88/0x33c
[  185.288626][ T3647]  vfs_write+0x118/0x208
[  185.288632][ T3647]  ksys_write+0xa0/0x110
[  185.288645][ T3647]  __arm64_sys_write+0x54/0x88
[  185.303075][ T3647]  el0_svc_handler+0x198/0x260
[  185.303081][ T3647]  el0_svc+0x8/0xc
[  185.303084][ T3647] 
[  185.303091][ T3647] The buggy address belongs to the object at
ffff809501263f00
[  185.303091][ T3647]  which belongs to the cache kmalloc-128 of size 128
[  185.303103][ T3647] The buggy address is located 32 bytes inside of
[  185.303103][ T3647]  128-byte region [ffff809501263f00, ffff809501263f80)
[  185.331347][ T3647] The buggy address belongs to the page:
[  185.331356][ T3647] page:ffff7fe025404980 refcount:1 mapcount:0
mapping:7fff800800010480 index:0xaff809501267d80
[  185.331365][ T3647] flags: 0x17ffffffc000200(slab)
[  185.331377][ T3647] raw: 017ffffffc000200 ffff7fe025997308 e5ff808b7d00fd40
7fff800800010480
[  185.350500][ T3647] raw: 19ff80950126aa80 0000000000660059 00000001ffffffff
0000000000000000
[  185.350505][ T3647] page dumped because: kasan: bad access detected
[  185.350514][ T3647] page allocated via order 0, migratetype Unmovable,
gfp_mask 0x12cc0(GFP_KERNEL|__GFP_NOWARN|__GFP_NORETRY)
[  185.350535][ T3647]  prep_new_page+0x2ec/0x388
[  185.364704][ T3647]  get_page_from_freelist+0x2530/0x27fc
[  185.364711][ T3647]  __alloc_pages_nodemask+0x360/0x1c60
[  185.364719][ T3647]  new_slab+0x108/0x9d4
[  185.364725][ T3647]  ___slab_alloc+0x57c/0x9e4
[  185.364735][ T3647]  __kmalloc_node+0x734/0x7cc
[  185.382050][ T3647]  alloc_rt_sched_group+0x17c/0x258
[  185.382070][ T3647]  sched_create_group+0x54/0x9c
[  185.382090][ T3647]  sched_autogroup_create_attach+0x40/0x1f0
[  185.494511][ T3647]  ksys_setsid+0x158/0x15c
[  185.494517][ T3647]  __arm64_sys_setsid+0x10/0x1c
[  185.494524][ T3647]  el0_svc_handler+0x198/0x260
[  185.494529][ T3647]  el0_svc+0x8/0xc
[  185.494532][ T3647] 
[  185.494536][ T3647] Memory state around the buggy address:
[  185.494549][ T3647]  ffff809501263d00: fe fe fe fe fe fe fe fe fe fe fe fe fe
fe fe fe
[  185.514973][ T3647]  ffff809501263e00: fe fe fe fe fe fe fe fe fe fe fe fe fe
fe fe fe
[  185.514979][ T3647] >ffff809501263f00: 33 33 fe fe fe fe fe fe fe fe fe fe fe
fe fe fe
[  185.514982][ T3647]                          ^
[  185.514988][ T3647]  ffff809501264000: fe fe fe fe fe fe fe fe fe fe fe fe fe
fe fe fe
[  185.514997][ T3647]  ffff809501264100: fe fe fe fe fe fe fe fe 36 36 36 36 36
36 36 36

