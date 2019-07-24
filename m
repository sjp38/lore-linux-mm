Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16B8AC76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 21:13:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9868021911
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 21:13:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="i8FwvWV+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9868021911
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EA656B0269; Wed, 24 Jul 2019 17:13:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A2E18E000C; Wed, 24 Jul 2019 17:13:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 165888E0002; Wed, 24 Jul 2019 17:13:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id E2FED6B0269
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 17:13:53 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id k13so40528867qkj.4
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 14:13:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=0odYr1Idz1wemeV6CIDLYXFc4XyGKEqby2L9Fcn9Vgc=;
        b=Vgn32XIi0myr4KEaRxdhYW45tzVex1jE8UpEXI48azjZwl+/FzqiDzVGZ0z/UXnkGZ
         hmfDovHzMD9tw0ucgy0wcL/d2nTnx1Yl34E/pbKWPNshgWpTDrBguHaX/CFyz0Q/CcWL
         m7zd9wTKfTiqOZ+icv7Dtmb0uZQ6Z/F2nBxzaUBQQeHfuaayEm7jmjK5Mu8Z8D+LNnmX
         EKOs3w/5dDXUUWwoNCrxURqVnM4JfjDTomQ7eCtA9N8+9c1lOF1oenWqzaBR0XXFuzkC
         Scd/pwTvY/9cU6BfGGp3AGXG+5rukcMm9exb1PVwy45BOn1m+ii5dfxtN1J4hgkA4VGq
         2NPA==
X-Gm-Message-State: APjAAAU7tUgGQBacJGHccvuFkKU8oow2eqtxZn1jRDfXNFwMafvn3sYl
	6A6sYPe96J7jresRJtZb8jSC+9UY9p7KoBeUufpn1OgWCU1hJFLtLKdbPsJK9ia9iYJQSOZxSXC
	AlzZLz/RO3+QkdYEUlYcB2C5yVt15XAbVNU9uPIKBsisVG9K5kkYxQs9Smelkt4cJCg==
X-Received: by 2002:ae9:f209:: with SMTP id m9mr54320233qkg.251.1564002833469;
        Wed, 24 Jul 2019 14:13:53 -0700 (PDT)
X-Received: by 2002:ae9:f209:: with SMTP id m9mr54320076qkg.251.1564002830769;
        Wed, 24 Jul 2019 14:13:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564002830; cv=none;
        d=google.com; s=arc-20160816;
        b=rRuIGXpAkRZ78aUY4KGdHXj1EIA5n8DX4hogUEmGwoRSS6xbLuDOJn1YKAUL0ubVQT
         XDijYZrO22ugynseuoTOLhFn20HNIpo+RrgqI4+LMsK7XtSkSbvryj0N6c/W3+vL+req
         eU5uJGiSPqYNK0XGp7M9+MXwrnNgC983G/yvsTWCHImBaD4UtQbKy3pwGDD+6jdhWRtY
         iUAnPdbPBCxojcsfuNnfDXj41Qe5Df6sqbps1+QcmqZoMIRIyNPYYgn7poXDR/J4sVc3
         og6IF1btYv88jYI2QIRegU6NPDTVCCpSB+gl5pHcRfCQphsIpoUbyRGhqK3Bg99o5I0i
         ZMbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=0odYr1Idz1wemeV6CIDLYXFc4XyGKEqby2L9Fcn9Vgc=;
        b=PP41UWJ2JDjPal9yi3+dmIvIAHcdwKqkTWzdTAZ9goXznN3YnsBtd/Ed0fwaY9zzm+
         UwukaqQ7sLpNeGkwn2opFxeYzov2KJIcK1hOiwEL0sBTL6Qlw6NYRlSXPVOI99AgoOxr
         a/1iLKPo41PDso/wJDzw4UayGK2ze+mPlCF/LfYHlA5swRzK/F3s1Auo9050azyBUxvA
         I+ycMk5AEGxgURGml+ZzK7+GqDUeo6hnIGFXAP45DL0GaO7SBEOiZ6N4Zh75tCUoUeOM
         0Om/nD10zrL/qWKTX7ZahbCgZgq+/kz+zH+qoBOnYf5L+JvjPa2uA91BMeuyRLRZT/4E
         FvpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=i8FwvWV+;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 56sor40958310qvt.0.2019.07.24.14.13.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 14:13:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=i8FwvWV+;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=0odYr1Idz1wemeV6CIDLYXFc4XyGKEqby2L9Fcn9Vgc=;
        b=i8FwvWV+Y2sBrN5q8SJTMRqyxKGOu5dMEgl4RX9UG4F+azuAb/jBKNtaboV8pKOkyA
         PRPwjHyqGWgkIV9NN8Gkkx0INWiFYBY0it5qBFr7Jzu5tS3S1cHqQBvJPg0rQz/Hxw5W
         lUtyuoN/JWKxuLURGDcN9RXiFxHLS+zTXAu/54r7lPzhCoXhFMDjsNZXUwCHzRYDckDy
         yEiIS2J5TmIPYn9U2U96u9W+ikown/c/7oG4pmJjhXeuWF/QaVVDay4W7FEzXcpxUpxZ
         WjIpUv4yI4JwLmhtjjGL2RXmr10st574VAbVK6+pGxx027aLQ5GZn59VOUtl/0WtJuHk
         rNsQ==
X-Google-Smtp-Source: APXvYqwYgNLkDETm3nsLYWB1aGD6HwFd5BZqCFnEycSIZMYSk7VrUh+O2EBOguneFIH5hTZyGtVMfQ==
X-Received: by 2002:a0c:acea:: with SMTP id n39mr57294913qvc.99.1564002829251;
        Wed, 24 Jul 2019 14:13:49 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id f26sm27115699qtf.44.2019.07.24.14.13.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 14:13:48 -0700 (PDT)
Message-ID: <1564002826.11067.17.camel@lca.pw>
Subject: Re: list corruption in deferred_split_scan()
From: Qian Cai <cai@lca.pw>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Wed, 24 Jul 2019 17:13:46 -0400
In-Reply-To: <1562795006.8510.19.camel@lca.pw>
References: <1562795006.8510.19.camel@lca.pw>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-07-10 at 17:43 -0400, Qian Cai wrote:
> Running LTP oom01 test case with swap triggers a crash below. Revert the
> series
> "Make deferred split shrinker memcg aware" [1] seems fix the issue.

You might want to look harder on this commit, as reverted it alone on the top of
 5.2.0-next-20190711 fixed the issue.

aefde94195ca mm: thp: make deferred split shrinker memcg aware [1]

[1] https://lore.kernel.org/linux-mm/1561507361-59349-5-git-send-email-yang.shi@
linux.alibaba.com/

There are all console output while running LTP oom01 before the crash that might
be useful.

[  656.302886][ T3384] WARNING: CPU: 79 PID: 3384 at mm/page_alloc.c:4608
__alloc_pages_nodemask+0x1a8a/0x1bc0
[  656.304395][ T3409] kmemleak: Cannot allocate a kmemleak_object structure
[  656.312714][ T3384] Modules linked in: nls_iso8859_1 nls_cp437 vfat fat
kvm_amd kvm ses enclosure dax_pmem irqbypass dax_pmem_core efivars ip_tables
x_tables xfs sd_mod smartpqi scsi_transport_sas mlx5_core tg3 libphy
firmware_class dm_mirror dm_region_hash dm_log dm_mod efivarfs
[  656.320916][ T3409] kmemleak: Kernel memory leak detector disabled
[  656.344509][ T3384] CPU: 79 PID: 3384 Comm: oom01 Not tainted 5.2.0-next-
20190711+ #3
[  656.344523][ T3384] Hardware name: HPE ProLiant DL385 Gen10/ProLiant DL385
Gen10, BIOS A40 06/24/2019
[  656.352100][  T829] kmemleak: Automatic memory scanning thread ended
[  656.358648][ T3384] RIP: 0010:__alloc_pages_nodemask+0x1a8a/0x1bc0
[  656.358658][ T3384] Code: 00 85 d2 0f 85 a1 00 00 00 48 c7 c7 e0 29 c3 a3 e8
3b 98 62 00 65 48 8b 1c 25 80 ee 01 00 e9 85 fa ff ff 0f 0b e9 3e fb ff ff <0f>
0b 48 8b b5 00 ff ff ff 8b 8d 84 fe ff ff 48 c7 c2 00 1d 6c a3
[  656.358675][ T3384] RSP: 0000:ffff888efa4a6210 EFLAGS: 00010046
[  656.406140][ T3384] RAX: 0000000000000000 RBX: 0000000000000000 RCX:
ffffffffa2b28be2
[  656.414033][ T3384] RDX: 0000000000000000 RSI: dffffc0000000000 RDI:
ffffffffa4d15d60
[  656.421926][ T3384] RBP: ffff888efa4a6420 R08: fffffbfff49a2bad R09:
fffffbfff49a2bac
[  656.429818][ T3384] R10: fffffbfff49a2bac R11: 0000000000000003 R12:
ffffffffa4d15d60
[  656.437711][ T3384] R13: 0000000000000000 R14: 0000000000000800 R15:
0000000000000000
[  656.445605][ T3384] FS:  00007ff44adfc700(0000) GS:ffff889032f80000(0000)
knlGS:0000000000000000
[  656.454459][ T3384] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  656.460952][ T3384] CR2: 00007ff2f05e1000 CR3: 0000001012e44000 CR4:
00000000001406a0
[  656.468843][ T3384] Call Trace:
[  656.472026][ T3384]  ? gfp_pfmemalloc_allowed+0xc0/0xc0
[  656.477303][ T3384]  ? stack_depot_save+0x215/0x58b
[  656.482228][ T3384]  ? lock_downgrade+0x390/0x390
[  656.486976][ T3384]  ? stack_depot_save+0x183/0x58b
[  656.491900][ T3384]  ? kasan_check_read+0x11/0x20
[  656.496647][ T3384]  ? do_raw_spin_unlock+0xa8/0x140
[  656.501658][ T3384]  ? stack_depot_save+0x215/0x58b
[  656.506582][ T3384]  alloc_pages_current+0x9c/0x110
[  656.511505][ T3384]  allocate_slab+0x351/0x11f0
[  656.516077][ T3384]  ? kasan_slab_alloc+0x11/0x20
[  656.520824][ T3384]  new_slab+0x46/0x70
[  656.524702][ T3384]  ? pageout.isra.4+0x3e5/0xa00
[  656.529449][ T3384]  ___slab_alloc+0x5d4/0x9c0
[  656.533933][ T3384]  ? try_to_free_pages+0x242/0x4d0
[  656.538941][ T3384]  ? __alloc_pages_nodemask+0x9ce/0x1bc0
[  656.544476][ T3384]  ? alloc_pages_vma+0x89/0x2c0
[  656.549226][ T3384]  ? __do_page_fault+0x25b/0x5d0
[  656.554064][ T3384]  ? create_object+0x3a/0x3e0
[  656.558637][ T3384]  ? init_object+0x7e/0x90
[  656.562947][ T3384]  ? create_object+0x3a/0x3e0
[  656.567520][ T3384]  __slab_alloc+0x12/0x20
[  656.571742][ T3384]  ? __slab_alloc+0x12/0x20
[  656.576142][ T3384]  kmem_cache_alloc+0x32a/0x400
[  656.580890][ T3384]  create_object+0x3a/0x3e0
[  656.585291][ T3384]  ? stack_depot_save+0x183/0x58b
[  656.590215][ T3384]  kmemleak_alloc+0x71/0xa0
[  656.594611][ T3384]  kmem_cache_alloc+0x272/0x400
[  656.599361][ T3384]  ? ___might_sleep+0xab/0xc0
[  656.603934][ T3384]  ? mempool_free+0x170/0x170
[  656.608507][ T3384]  mempool_alloc_slab+0x2d/0x40
[  656.613254][ T3384]  mempool_alloc+0x10a/0x29e
[  656.617739][ T3384]  ? alloc_pages_vma+0x89/0x2c0
[  656.622485][ T3384]  ? mempool_resize+0x390/0x390
[  656.627233][ T3384]  ? __read_once_size_nocheck.constprop.2+0x10/0x10
[  656.633730][ T3384]  bio_alloc_bioset+0x150/0x330
[  656.638477][ T3384]  ? bvec_alloc+0x1b0/0x1b0
[  656.642892][ T3384]  alloc_io+0x2f/0x230 [dm_mod]
[  656.647654][ T3384]  __split_and_process_bio+0x99/0x630 [dm_mod]
[  656.653714][ T3384]  ? blk_rq_map_sg+0x9f0/0x9f0
[  656.658388][ T3384]  ? __send_empty_flush.constprop.11+0x1f0/0x1f0 [dm_mod]
[  656.665407][ T3384]  ? check_chain_key+0x1df/0x2e0
[  656.670244][ T3384]  ? kasan_check_read+0x11/0x20
[  656.674992][ T3384]  ? blk_queue_split+0x60/0x90
[  656.679654][ T3384]  ? __blk_queue_split+0x970/0x970
[  656.684679][ T3384]  dm_process_bio+0x33f/0x520 [dm_mod]
[  656.690054][ T3384]  ? __process_bio+0x230/0x230 [dm_mod]
[  656.695515][ T3384]  dm_make_request+0xbd/0x150 [dm_mod]
[  656.700888][ T3384]  ? dm_wq_work+0x1b0/0x1b0 [dm_mod]
[  656.706073][ T3384]  ? lock_downgrade+0x390/0x390
[  656.710821][ T3384]  generic_make_request+0x179/0x4a0
[  656.715917][ T3384]  ? blk_queue_exit+0xc0/0xc0
[  656.720489][ T3384]  ? __unlock_page_memcg+0x4f/0x90
[  656.725495][ T3384]  ? unlock_page_memcg+0x1f/0x30
[  656.730329][ T3384]  submit_bio+0xaa/0x270
[  656.734466][ T3384]  ? generic_make_request+0x4a0/0x4a0
[  656.739739][ T3384]  __swap_writepage+0x8f5/0xba0
[  656.744484][ T3384]  ? __x64_sys_madvise.cold.0+0x22/0x22
[  656.749931][ T3384]  ? generic_swapfile_activate+0x2a0/0x2a0
[  656.755638][ T3384]  ? do_raw_spin_lock+0x118/0x1d0
[  656.760559][ T3384]  ? rwlock_bug.part.0+0x60/0x60
[  656.765393][ T3384]  ? page_swapcount+0x68/0xc0
[  656.769967][ T3384]  ? kasan_check_read+0x11/0x20
[  656.774713][ T3384]  ? do_raw_spin_unlock+0xa8/0x140
[  656.779724][ T3384]  ? __frontswap_store+0x103/0x2b0
[  656.784735][ T3384]  swap_writepage+0x65/0xb0
[  656.789134][ T3384]  pageout.isra.4+0x3e5/0xa00
[  656.793707][ T3384]  ? shrink_slab+0x440/0x440
[  656.798192][ T3384]  ? kasan_check_read+0x11/0x20
[  656.802939][ T3384]  shrink_page_list+0x159f/0x2650
[  656.807860][ T3384]  ? page_evictable+0x150/0x150
[  656.812606][ T3384]  ? kasan_check_read+0x11/0x20
[  656.817352][ T3384]  ? check_chain_key+0x1df/0x2e0
[  656.822185][ T3384]  ? shrink_inactive_list+0x2ea/0x770
[  656.827456][ T3384]  ? lock_downgrade+0x390/0x390
[  656.832202][ T3384]  ? do_raw_spin_lock+0x118/0x1d0
[  656.837126][ T3384]  ? rwlock_bug.part.0+0x60/0x60
[  656.841959][ T3384]  ? kasan_check_read+0x11/0x20
[  656.846706][ T3384]  ? do_raw_spin_unlock+0xa8/0x140
[  656.851715][ T3384]  shrink_inactive_list+0x373/0x770
[  656.856812][ T3384]  ? move_pages_to_lru+0xb60/0xb60
[  656.861820][ T3384]  ? shrink_node_memcg+0xcfa/0x1560
[  656.866917][ T3384]  ? lock_downgrade+0x390/0x390
[  656.871665][ T3384]  ? find_next_bit+0x2c/0xa0
[  656.876151][ T3384]  shrink_node_memcg+0x4ff/0x1560
[  656.881075][ T3384]  ? shrink_active_list+0xa10/0xa10
[  656.886173][ T3384]  ? dev_ifsioc+0xb0/0x4d0
[  656.890485][ T3384]  ? mem_cgroup_iter+0x18e/0x840
[  656.895319][ T3384]  ? kasan_check_read+0x11/0x20
[  656.900066][ T3384]  ? mem_cgroup_protected+0x20f/0x260
[  656.905334][ T3384]  shrink_node+0x1d3/0xa30
[  656.909644][ T3384]  ? shrink_node_memcg+0x1560/0x1560
[  656.914828][ T3384]  ? ktime_get+0x93/0x110
[  656.919050][ T3384]  do_try_to_free_pages+0x22f/0x820
[  656.924146][ T3384]  ? shrink_node+0xa30/0xa30
[  656.928632][ T3384]  ? kasan_check_read+0x11/0x20
[  656.933379][ T3384]  ? check_chain_key+0x1df/0x2e0
[  656.938212][ T3384]  try_to_free_pages+0x242/0x4d0
[  656.943046][ T3384]  ? do_try_to_free_pages+0x820/0x820
[  656.948318][ T3384]  __alloc_pages_nodemask+0x9ce/0x1bc0
[  656.953677][ T3384]  ? kasan_check_read+0x11/0x20
[  656.958424][ T3384]  ? gfp_pfmemalloc_allowed+0xc0/0xc0
[  656.963697][ T3384]  ? kasan_check_read+0x11/0x20
[  656.968443][ T3384]  ? check_chain_key+0x1df/0x2e0
[  656.973277][ T3384]  ? do_anonymous_page+0x343/0xe30
[  656.978288][ T3384]  ? lock_downgrade+0x390/0x390
[  656.983035][ T3384]  ? __count_memcg_events+0x8b/0x1c0
[  656.988218][ T3384]  ? kasan_check_read+0x11/0x20
[  656.992966][ T3384]  ? __lru_cache_add+0x122/0x160
[  656.997802][ T3384]  alloc_pages_vma+0x89/0x2c0
[  657.002375][ T3384]  do_anonymous_page+0x3e1/0xe30
[  657.007211][ T3384]  ? __update_load_avg_cfs_rq+0x2c/0x490
[  657.012743][ T3384]  ? finish_fault+0x120/0x120
[  657.017314][ T3384]  ? alloc_pages_vma+0x21e/0x2c0
[  657.022148][ T3384]  handle_pte_fault+0x457/0x12c0
[  657.026984][ T3384]  __handle_mm_fault+0x79a/0xa50
[  657.031819][ T3384]  ? vmf_insert_mixed_mkwrite+0x20/0x20
[  657.037267][ T3384]  ? kasan_check_read+0x11/0x20
[  657.042013][ T3384]  ? __count_memcg_events+0x8b/0x1c0
[  657.047199][ T3384]  handle_mm_fault+0x17f/0x370
[  657.051863][ T3384]  __do_page_fault+0x25b/0x5d0
[  657.056521][ T3384]  do_page_fault+0x4c/0x2cf
[  657.060922][ T3384]  ? page_[  659.105948][ T3124] kworker/2:1H: page
allocation failure: order:0, mode:0xa20(GFP_ATOMIC),
nodemask=(null),cpuset=/,mems_allowed=0,4
[  659.106045][ T1598] kworker/10:1H: page allocation failure: order:0,
mode:0xa20(GFP_ATOMIC), nodemask=(null),cpuset=/,mems_allowed=0,4
[  659.118049][ T3124] CPU: 2 PID: 3124 Comm: kworker/2:1H Tainted:
G        W         5.2.0-next-20190711+ #3
[  659.137325][  T762] ODEBUG: Out of memory. ODEBUG disabled
[  659.140015][ T3124] Hardware name: HPE ProLiant DL385 Gen10/ProLiant DL385
Gen10, BIOS A40 06/24/2019
[  659.140032][ T3124] Workqueue: kblockd blk_mq_run_work_fn
[  659.160266][ T3124] Call Trace:
[  659.163442][ T3124]  dump_stack+0x62/0x9a
[  659.167487][ T3124]  warn_alloc.cold.45+0x8a/0x12a
[  659.172315][ T3124]  ? zone_watermark_ok_safe+0x1a0/0x1a0
[  659.177756][ T3124]  ? __read_once_size_nocheck.constprop.2+0x10/0x10
[  659.184252][ T3124]  ? pqi_scsi_queue_command+0x791/0xdd0 [smartpqi]
[  659.190658][ T3124]  ? pqi_scsi_queue_command+0x791/0xdd0 [smartpqi]
[  659.197060][ T3124]  ? __isolate_free_page+0x390/0x390
[  659.202239][ T3124]  __alloc_pages_nodemask+0x1aab/0x1bc0
[  659.207680][ T3124]  ? gfp_pfmemalloc_allowed+0xc0/0xc0
[  659.212949][ T3124]  ? stack_trace_save+0x87/0xb0
[  659.217689][ T3124]  ? freezing_slow_path.cold.1+0x35/0x35
[  659.223219][ T3124]  ? __kasan_kmalloc.part.0+0x81/0xc0
[  659.228485][ T3124]  ? __kasan_kmalloc.part.0+0x44/0xc0
[  659.233750][ T3124]  ? __kasan_kmalloc.constprop.1+0xac/0xc0
[  659.239451][ T3124]  ? kasan_slab_alloc+0x11/0x20
[  659.244196][ T3124]  ? kmem_cache_alloc+0x17a/0x400
[  659.249113][ T3124]  ? alloc_iova+0x33/0x210
[  659.253418][ T3124]  ? alloc_iova_fast+0x47/0xba
[  659.258073][ T3124]  ? dma_ops_alloc_iova.isra.5+0x86/0xa0
[  659.263603][ T3124]  ? map_sg+0x99/0x2f0
[  659.267558][ T3124]  ? scsi_dma_map+0xc6/0x160
[  659.272042][ T3124]  ? pqi_raid_submit_scsi_cmd_with_io_request+0x1c3/0x470
[smartpqi]
[  659.280020][ T3124]  ? pqi_scsi_queue_command+0x791/0xdd0 [smartpqi]
[  659.286421][ T3124]  ? scsi_queue_rq+0x7c6/0x1280
[  659.291163][ T3124]  ? ftrace_graph_ret_addr+0x2a/0xb0
[  659.296340][ T3124]  ? stack_trace_save+0x87/0xb0
[  659.301081][ T3124]  alloc_pages_current+0x9c/0x110
[  659.305998][ T3124]  allocate_slab+0x351/0x11f0
[  659.310564][ T3124]  new_slab+0x46/0x70
[  659.314433][ T3124]  ___slab_alloc+0x5d4/0x9c0
[  659.318913][ T3124]  ? should_fail+0x107/0x3bc
[  659.323393][ T3124]  ? alloc_iova+0x33/0x210
[  659.327700][ T3124]  ? lock_downgrade+0x390/0x390
[  659.332441][ T3124]  ? lock_downgrade+0x390/0x390
[  659.337183][ T3124]  ? alloc_iova+0x33/0x210
[  659.341487][ T3124]  __slab_alloc+0x12/0x20
[  659.345704][ T3124]  ? __slab_alloc+0x12/0x20
[  659.350096][ T3124]  kmem_cache_alloc+0x32a/0x400
[  659.354838][ T3124]  ? kasan_check_read+0x11/0x20
[  659.359580][ T3124]  ? do_raw_spin_unlock+0xa8/0x140
[  659.364585][ T3124]  alloc_iova+0x33/0x210
[  659.368714][ T3124]  ? iova_rcache_get+0x1a1/0x300
[  659.373545][ T3124]  alloc_iova_fast+0x47/0xba
[  659.378026][ T3124]  dma_ops_alloc_iova.isra.5+0x86/0xa0
[  659.383381][ T3124]  map_sg+0x99/0x2f0
[  659.387161][ T3124]  scsi_dma_map+0xc6/0x160
[  659.391470][ T3124]  pqi_raid_submit_scsi_cmd_with_io_request+0x1c3/0x470
[smartpqi]
[  659.399274][ T3124]  ? pqi_alloc_io_request+0x11e/0x140 [smartpqi]
[  659.405507][ T3124]  pqi_scsi_queue_command+0x791/0xdd0 [smartpqi]
[  659.411733][ T3124]  ? scsi_init_io+0x102/0x150
[  659.416306][ T3124]  ? sd_setup_read_write_cmnd+0x6e9/0xa90 [sd_mod]
[  659.422713][ T3124]  ? pqi_event_worker+0xdf0/0xdf0 [smartpqi]
[  659.428593][ T3124]  ? sd_init_command+0x88b/0x930 [sd_mod]
[  659.434211][ T3124]  ? blk_add_timer+0xd7/0x110
[  659.438780][ T3124]  scsi_queue_rq+0x7c6/0x1280
[  659.443350][ T3124]  blk_mq_dispatch_rq_list+0x9d3/0xba0
[  659.448702][ T3124]  ? blk_mq_flush_busy_ctxs+0x1c5/0x450
[  659.454145][ T3124]  ? blk_mq_get_driver_tag+0x290/0x290
[  659.459498][ T3124]  ? __lock_acquire.isra.13+0x430/0x830
[  659.464938][ T3124]  blk_mq_sched_dispatch_requests+0x2f4/0x300
[  659.470903][ T3124]  ? blk_mq_sched_restart+0x60/0x60
[  659.475993][ T3124]  __blk_mq_run_hw_queue+0x156/0x230
[  659.481172][ T3124]  ? hctx_lock+0xc0/0xc0
[  659.485301][ T3124]  ? process_one_work+0x426/0xa70
[  659.490217][ T3124]  blk_mq_run_work_fn+0x3b/0x40
[  659.494959][ T3124]  process_one_work+0x53b/0xa70
[  659.499703][ T3124]  ? pwq_dec_nr_in_flight+0x170/0x170
[  659.504967][ T3124]  worker_thread+0x63/0x5b0
[  659.509361][ T3124]  kthread+0x1df/0x200
[  659.513316][ T3124]  ? process_one_work+0xa70/0xa70
[  659.518231][ T3124]  ? kthread_park+0xc0/0xc0
[  659.522625][ T3124]  ret_from_fork+0x22/0x40
[  659.526937][ T1598] CPU: 10 PID: 1598 Comm: kworker/10:1H Tainted:
G        W         5.2.0-next-20190711+ #3
[  659.526991][ T3124] Mem-Info:
[  659.536921][ T1598] Hardware name: HPE ProLiant DL385 Gen10/ProLiant DL385
Gen10, BIOS A40 06/24/2019
[  659.536934][ T1598] Workqueue: kblockd blk_mq_run_work_fn
[  659.540067][ T3124] active_anon:4662210 inactive_anon:359358
isolated_anon:2005
[  659.540067][ T3124]  active_file:10032 inactive_file:12947 isolated_file:0
[  659.540067][ T3124]  unevictable:0 dirty:12 writeback:0 unstable:0
[  659.540067][ T3124]  slab_reclaimable:71207 slab_unreclaimable:1252996
[  659.540067][ T3124]  mapped:17530 shmem:1850 pagetables:11491 bounce:0
[  659.540067][ T3124]  free:54096 free_pcp:5994 free_cma:84
[  659.549192][ T1598] Call Trace:
[  659.549203][ T1598]  dump_stack+0x62/0x9a
[  659.554639][ T3124] Node 0 active_anon:2246440kB inactive_anon:572540kB
active_file:19500kB inactive_file:19016kB unevictable:0kB isolated(anon):7708kB
isolated(file):0kB mapped:24840kB dirty:8kB writeback:0kB shmem:1372kB
shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 1689600kB writeback_tmp:0kB
unstable:0kB all_unreclaimable? no
[  659.593619][ T1598]  warn_alloc.cold.45+0x8a/0x12a
[  659.596785][ T3124] Node 1 active_anon:0kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB
mapped:0kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  659.600821][ T1598]  ? zone_watermark_ok_safe+0x1a0/0x1a0
[  659.630195][ T3124] Node 2 active_anon:0kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB
mapped:0kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  659.635021][ T1598]  ? __read_once_size_nocheck.constprop.2+0x10/0x10
[  659.661328][ T3124] Node 3 active_anon:0kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB
mapped:0kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  659.661337][ T3124] Node 4 active_anon:16402112kB inactive_anon:865180kB
active_file:20600kB inactive_file:32712kB unevictable:0kB isolated(anon):304kB
isolated(file):0kB mapped:45216kB dirty:40kB writeback:12kB shmem:6028kB
shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 15167488kB writeback_tmp:0kB
unstable:0kB all_unreclaimable? no
[  659.666778][ T1598]  ? pqi_scsi_queue_command+0x791/0xdd0 [smartpqi]
[  659.693086][ T3124] Node 5 active_anon:0kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB
mapped:0kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  659.693096][ T3124] Node 6 active_anon:0kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB
mapped:0kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  659.699583][ T1598]  ? pqi_scsi_queue_command+0x791/0xdd0 [smartpqi]
[  659.725894][ T3124] Node 7 active_anon:0kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB
mapped:0kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  659.755524][ T1598]  ? __isolate_free_page+0x390/0x390
[  659.761953][ T3124] Node 0 DMA free:15908kB min:24kB low:36kB high:48kB
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB
unevictable:0kB writepending:0kB present:15996kB managed:15908kB mlocked:0kB
kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB
free_cma:0kB
[  659.788234][ T1598]  __alloc_pages_nodemask+0x1aab/0x1bc0
[  659.814544][ T3124] lowmem_reserve[]: 0 1532 19982 19982 19982
[  659.820945][ T1598]  ? gfp_pfmemalloc_allowed+0xc0/0xc0
[  659.847287][ T3124] Node 0 DMA32 free:73504kB min:2676kB low:4244kB
high:5812kB active_anon:1190128kB inactive_anon:362496kB active_file:0kB
inactive_file:0kB unevictable:0kB writepending:0kB present:1923080kB
managed:1634348kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB
free_pcp:1432kB local_pcp:0kB free_cma:0kB
[  659.852428][ T1598]  ? stack_trace_save+0x87/0xb0
[  659.852435][ T1598]  ? freezing_slow_path.cold.1+0x35/0x35
[  659.879003][ T3124] lowmem_reserve[]: 0 0 18450 18450 18450
[  659.884446][ T1598]  ? __kasan_kmalloc.part.0+0x81/0xc0
[  659.890346][ T3124] Node 0 Normal free:47760kB min:137264kB low:156156kB
high:175048kB active_anon:1056208kB inactive_anon:209672kB active_file:19456kB
inactive_file:18996kB unevictable:0kB writepending:0kB present:27262976kB
managed:18893712kB mlocked:0kB kernel_stack:22240kB pagetables:10064kB
bounce:0kB free_pcp:9340kB local_pcp:164kB free_cma:0kB
[  659.895574][ T1598]  ? __kasan_kmalloc.part.0+0x44/0xc0
[  659.895581][ T1598]  ? __kasan_kmalloc.constprop.1+0xac/0xc0
[  659.924420][ T3124] lowmem_reserve[]: 0 0 0 0 0
[  659.929163][ T1598]  ? kasan_slab_alloc+0x11/0x20
[  659.929170][ T1598]  ? kmem_cache_alloc+0x17a/0x400
[  659.934724][ T3124] Node 4 Normal free:72728kB min:234904kB low:267232kB
high:299560kB active_anon:16401776kB inactive_anon:865580kB active_file:20596kB
inactive_file:32692kB unevictable:0kB writepending:40kB present:33538048kB
managed:32332156kB mlocked:0kB kernel_stack:23040kB pagetables:35900kB
bounce:0kB free_pcp:12956kB local_pcp:24kB free_cma:336kB
[  659.940301][ T1598]  ? alloc_iova+0x33/0x210
[  659.940307][ T1598]  ? alloc_iova_fast+0x47/0xba
[  659.945563][ T3124] lowmem_reserve[]: 0 0 0 0 0
[  659.976773][ T1598]  ? dma_ops_alloc_iova.isra.5+0x86/0xa0
[  659.976780][ T1598]  ? map_sg+0x99/0x2f0
[  659.982039][ T3124] Node 0 DMA: 1*4kB (U) 0*8kB 0*16kB 1*32kB (U) 2*64kB (U)
1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15908kB
[  659.987736][ T1598]  ? scsi_dma_map+0xc6/0x160
[  659.987747][ T1598]  ? pqi_raid_submit_scsi_cmd_with_io_request+0x1c3/0x470
[smartpqi]
[  659.992300][ T3124] Node 0 DMA32: 0*4kB 0*8kB 2*16kB (M) 5*32kB (UM) 17*64kB
(UM) 8*128kB (UM) 12*256kB (UM) 11*512kB (UM) 10*1024kB (UM) 2*2048kB (UM)
12*4096kB (M) = 74496kB
[  659.997045][ T1598]  ? pqi_scsi_queue_command+0x791/0xdd0 [smartpqi]
[  659.997051][ T1598]  ? scsi_queue_rq+0x7c6/0x1280
[  660.001958][ T3124] Node 0 Normal: 0*4kB 0*8kB 198*16kB (MEH) 356*32kB (ME)
83*64kB (UME) 15*128kB (UME) 101*256kB (U) 0*512kB 0*1024kB 0*2048kB 0*4096kB =
47648kB
[  660.033521][ T1598]  ? ftrace_graph_ret_addr+0x2a/0xb0
[  660.033528][ T1598]  ? stack_trace_save+0x87/0xb0
[  660.037828][ T3124] Node 4 Normal: 0*4kB 0*8kB 211*16kB (UME) 441*32kB (UME)
449*64kB (UME) 71*128kB (ME) 62*256kB (M) 0*512kB 0*1024kB 0*2048kB 0*4096kB =
71184kB
[  660.042481][ T1598]  alloc_pages_current+0x9c/0x110
[  660.047042][ T3124] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=1048576kB
[  660.052569][ T1598]  allocate_slab+0x351/0x11f0
[  660.056516][ T3124] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=2048kB
[  660.056521][ T3124] Node 4 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=1048576kB
[  660.070694][ T1598]  new_slab+0x46/0x70
[  660.075169][ T3124] Node 4 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=2048kB
[  660.083141][ T1598]  ___slab_alloc+0x5d4/0x9c0
[  660.098879][ T3124] 26058 total pagecache pages
[  660.098894][ T3124] 1298 pages in swap cache
[  660.105279][ T1598]  ? should_fail+0x107/0x3bc
[  660.105285][ T1598]  ? alloc_iova+0x33/0x210
[  660.110020][ T3124] Swap cache stats: add 2607, delete 1311, find 0/1
[  660.110024][ T3124] Free swap  = 32919548kB
[  660.124719][ T1598]  ? lock_downgrade+0x390/0x390
[  660.124725][ T1598]  ? lock_downgrade+0x390/0x390
[  660.129894][ T3124] Total swap = 32952316kB
[  660.129899][ T3124] 15685025 pages RAM
[  660.134637][ T1598]  ? alloc_iova+0x33/0x210
[  660.149328][ T3124] 0 pages HighMem/MovableOnly
[  660.149332][ T3124] 2465994 pages reserved
[  660.154245][ T1598]  __slab_alloc+0x12/0x20
[  660.154252][ T1598]  ? __slab_alloc+0x12/0x20
[  660.163701][ T3124] 16384 pages cma reserved
[  660.163763][ T3124] SLUB: Unable to allocate memory on node -1,
gfp=0xa20(GFP_ATOMIC)
[  660.168269][ T1598]  kmem_cache_alloc+0x32a/0x400
[  660.168276][ T1598]  ? kasan_check_read+0x11/0x20
[  660.177465][ T3124]   cache: iommu_iova, object size: 40, buffer size: 448,
default order: 0, min order: 0
[  660.177470][ T3124]   node 0: slabs: 10580, objs: 95220, free: 0
[  660.186924][ T1598]  ? do_raw_spin_unlock+0xa8/0x140
[  660.186930][ T1598]  alloc_iova+0x33/0x210
[  660.190792][ T3124]   node 4: slabs: 2292, objs: 20628, free: 25
[  660.199982][ T1598]  ? iova_rcache_get+0x1a1/0x300
[  660.199989][ T1598]  alloc_iova_fast+0x47/0xba
[  660.204513][ T3124] kworker/2:1H: page allocation failure: order:0,
mode:0xa20(GFP_ATOMIC), nodemask=(null),cpuset=/,mems_allowed=0,4
[  660.209026][ T1598]  dma_ops_alloc_iova.isra.5+0x86/0xa0
[  660.351109][ T1598]  map_sg+0x99/0x2f0
[  660.354891][ T1598]  ? __debug_object_init+0x412/0x7a0
[  660.360070][ T1598]  scsi_dma_map+0xc6/0x160
[  660.364381][ T1598]  pqi_raid_submit_scsi_cmd_with_io_request+0x1c3/0x470
[smartpqi]
[  660.372184][ T1598]  ? pqi_alloc_io_request+0x11e/0x140 [smartpqi]
[  660.378415][ T1598]  pqi_scsi_queue_command+0x791/0xdd0 [smartpqi]
[  660.384644][ T1598]  ? scsi_init_io+0x102/0x150
[  660.389217][ T1598]  ? sd_setup_read_write_cmnd+0x6e9/0xa90 [sd_mod]
[  660.395622][ T1598]  ? pqi_event_worker+0xdf0/0xdf0 [smartpqi]
[  660.401503][ T1598]  ? sd_init_command+0x88b/0x930 [sd_mod]
[  660.407119][ T1598]  ? blk_add_timer+0xd7/0x110
[  660.411686][ T1598]  scsi_queue_rq+0x7c6/0x1280
[  660.416252][ T1598]  blk_mq_dispatch_rq_list+0x9d3/0xba0
[  660.421604][ T1598]  ? blk_mq_flush_busy_ctxs+0x1c5/0x450
[  660.427045][ T1598]  ? blk_mq_get_driver_tag+0x290/0x290
[  660.432396][ T1598]  ?
__lock_acquire.isra.13+0xT3124]  __blk_mq_run_hw_queue+0x156/0x230
[  660.822569][ T3124]  ? hctx_lock+0xc0/0xc0
[  660.826700][ T3124]  ? process_one_work+0x426/0xa70
[  660.831617][ T3124]  blk_mq_run_work_fn+0x3b/0x40
[  660.836358][ T3124]  process_one_work+0x53b/0xa70
[  660.841100][ T3124]  ? pwq_dec_nr_in_flight+0x170/0x170
[  660.846365][ T3124]  worker_thread+0x63/0x5b0
[  660.850756][ T3124]  kthread+0x1df/0x200
[  660.854712][ T3124]  ? process_one_work+0xa70/0xa70
[  660.859626][ T3124]  ? kthread_park+0xc0/0xc0
[  660.864021][ T3124]  ret_from_fork+0x22/0x40
[  660.868328][ T3124] warn_alloc_show_mem: 1 callbacks suppressed
[  660.868332][ T1598] CPU: 10 PID: 1598 Comm: kworker/10:1H Tainted:
G        W         5.2.0-next-20190711+ #3
[  660.868335][ T3124] Mem-Info:
[  660.868485][ T3124] active_anon:4662011 inactive_anon:359383
isolated_anon:2155
[  660.868485][ T3124]  active_file:10012 inactive_file:12922 isolated_file:0
[  660.868485][ T3124]  unevictable:0 dirty:12 writeback:0 unstable:0
[  660.868485][ T3h:175048kB active_anon:1056208kB inactive_anon:209448kB
active_file:19452kB inactive_file:18996kB unevictable:0kB writepending:0kB
present:27262976kB managed:18893712kB mlocked:0kB kernel_stack:22240kB
pagetables:10064kB bounce:0kB free_pcp:8784kB local_pcp:164kB free_cma:0kB
[  661.222532][ T1598]  ? kernel_poison_pages.cold.2+0x8c/0x8c
[  661.228397][ T3124] lowmem_reserve[]: 0 0 0 0 0
[  661.233138][ T1598]  ? vprintk_default+0x1f/0x30
[  661.233146][ T1598]  alloc_pages_current+0x9c/0x110
[  661.238174][ T3124] Node 4 Normal free:71384kB min:234904kB low:267232kB
high:299560kB active_anon:16401776kB inactive_anon:865588kB active_file:20596kB
inactive_file:32692kB unevictable:0kB writepending:40kB present:33538048kB
managed:32332156kB mlocked:0kB kernel_stack:23040kB pagetables:35900kB
bounce:0kB free_pcp:12872kB local_pcp:24kB free_cma:336kB
[  661.266900][ T1598]  allocate_slab+0x351/0x11f0
[  661.266905][ T1598]  new_slab+0x46/0x70
[  661.271461][ T3124] lowmem_reserve[]: 0 0 0 0 0
[  661.275941][ T1598]  ___slab_alloc+0x5d4/0x9c0
[  661.275948][ T1598]  ? should0
[  661.543007][ T3132]   cache: iommu_iova, object size: 40, buffer size: 448,
default order: 0, min order: 0
[  661.543011][ T3203]   node 0: slabs: 10582, objs: 95238, free: 7
[  661.543016][ T3132]   node 0: slabs: 10582, objs: 95238, free: 7
[  661.543020][ T3203]   node 4: slabs: 2293, objs: 20637, free: 30
[  661.543026][ T3132]   node 4: slabs: 2293, objs: 20637, free: 30
[  661.543040][ T3203] SLUB: Unable to allocate memory on node -1,
gfp=0xa20(GFP_ATOMIC)
[  661.543046][ T3203]   cache: iommu_iova, object size: 40, buffer size: 448,
default order: 0, min order: 0
[  661.543052][ T3203]   node 0: slabs: 10582, objs: 95238, free: 7
[  661.543057][ T3132] SLUB: Unable to allocate memory on node -1,
gfp=0xa20(GFP_ATOMIC)
[  661.543061][ T3203]   node 4: slabs: 2293, objs: 20637, free: 30
[  661.543066][ T3132]   cache: iommu_iova, object size: 40, buffer size: 448,
default order: 0, min order: 0
[  661.543072][ T3132]   node 0: slabs: 10582, objs: 95238, free: 7
[  661.543078][ T3132]   node 4: slabs: 2293, objs: 20637, free: 30
[  661.543544][ T3205] SLUB: Unable to allocnevictable:0kB isolated(anon):352kB
isolated(file):0kB mapped:45056kB dirty:40kB writeback:52kB shmem:6028kB
shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 15167488kB writeback_tmp:0kB
unstable:0kB all_unreclaimable? no
[  662.181289][ T1598] Node 5 active_anon:0kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB
mapped:0kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  662.207607][ T3209]  ? __read_once_size_nocheck.constprop.2+0x10/0x10
[  662.212434][ T1598] Node 6 active_anon:0kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB
mapped:0kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  662.238751][ T3209]  ? pqi_scsi_queue_command+0x791/0xdd0 [smartpqi]
[  662.244187][ T1598] Node 7 active_anon:0kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB isolated(ano  alloc_iova_fast+0x47/0xba
[  662.835750][ T3209]  dma_ops_alloc_iova.isra.5+0x86/0xa0
[  662.841103][ T3209]  map_sg+0x99/0x2f0
[  662.844886][ T3209]  ? kasan_check_read+0x11/0x20
[  662.849627][ T3209]  scsi_dma_map+0xc6/0x160
[  662.853938][ T3209]  pqi_raid_submit_scsi_cmd_with_io_request+0x1c3/0x470
[smartpqi]
[  662.861740][ T3209]  ? pqi_alloc_io_request+0x11e/0x140 [smartpqi]
[  662.867971][ T3209]  pqi_scsi_queue_command+0x791/0xdd0 [smartpqi]
[  662.874198][ T3209]  ? scsi_init_io+0x102/0x150
[  662.878768][ T3209]  ? sd_setup_read_write_cmnd+0x6e9/0xa90 [sd_mod]
[  662.885176][ T3209]  ? pqi_event_worker+0xdf0/0xdf0 [smartpqi]
[  662.891055][ T3209]  ? sd_init_command+0x88b/0x930 [sd_mod]
[  662.896672][ T3209]  ? blk_add_timer+0xd7/0x110
[  662.901240][ T3209]  scsi_queue_rq+0x7c6/0x1280
[  662.905807][ T3209]  blk_mq_dispatch_rq_list+0x9d3/0xba0
[  662.911159][ T3209]  ? blk_mq_flush_busy_ctxs+0x1c5/0x450
[  662.916601][ T3209]  ? blk_mq_get_driver_tag+0x290/0x290
[  662.921953][ T3209]  ? __lock_acquire.isra.13+0x430/0x830
[  662.927394][ T3209]  blk_mq_sched_diag+0x290/0x290
[  663.313403][ T3146]  ? __lock_acquire.isra.13+0x430/0x830
[  663.318844][ T3146]  blk_mq_sched_dispatch_requests+0x2f4/0x300
[  663.324807][ T3146]  ? blk_mq_sched_restart+0x60/0x60
[  663.329898][ T3146]  __blk_mq_run_hw_queue+0x156/0x230
[  663.335076][ T3146]  ? hctx_lock+0xc0/0xc0
[  663.339211][ T3146]  ? process_one_work+0x426/0xa70
[  663.344128][ T3146]  blk_mq_run_work_fn+0x3b/0x40
[  663.348870][ T3146]  process_one_work+0x53b/0xa70
[  663.353613][ T3146]  ? pwq_dec_nr_in_flight+0x170/0x170
[  663.358880][ T3146]  worker_thread+0x63/0x5b0
[  663.363277][ T3146]  kthread+0x1df/0x200
[  663.367233][ T3146]  ? process_one_work+0xa70/0xa70
[  663.372148][ T3146]  ? kthread_park+0xc0/0xc0
[  663.376543][ T3146]  ret_from_fork+0x22/0x40
[  663.380848][ T3146] warn_alloc_show_mem: 1 callbacks suppressed
[  663.380855][ T3123] CPU: 1 PID: 3123 Comm: kworker/1:1H Tainted:
G        W         5.2.0-next-20190711+ #3
[  663.380857][ T3146] Mem-Info:
[  663.381000][ T3146] active_anon:4654271 inactive_anon:367023
isolated_anon:2263
[  663.381000T3123]  ? gfp_pfmemalloc_allowed+0xc0/0xc0
[  663.744691][ T3146] Node 0 Normal free:74264kB min:137264kB low:156156kB
high:175048kB active_anon:1055816kB inactive_anon:209292kB active_file:19416kB
inactive_file:18964kB unevictable:0kB writepending:248kB present:27262976kB
managed:18893712kB mlocked:0kB kernel_stack:22240kB pagetables:10064kB
bounce:0kB free_pcp:9356kB local_pcp:124kB free_cma:0kB
[  663.750101][ T3123]  ? lock_downgrade+0x390/0x390
[  663.778942][ T3146] lowmem_reserve[]: 0 0 0 0 0
[  663.783688][ T3123]  ? do_raw_spin_lock+0x118/0x1d0
[  663.789326][ T3146] Node 4 Normal free:81632kB min:234904kB low:267232kB
high:299560kB active_anon:16368972kB inactive_anon:898504kB active_file:20548kB
inactive_file:32468kB unevictable:0kB writepending:104kB present:33538048kB
managed:32332156kB mlocked:0kB kernel_stack:23040kB pagetables:35900kB
bounce:0kB free_pcp:11372kB local_pcp:160kB free_cma:0kB
[  663.794556][ T3123]  ? rwlock_bug.part.0+0x60/0x60
[  663.794563][ T3123]  ? get_partial_node+0x48/0x540
[  663.825936][ T3146] lowmem_reserve[]: 0 0 0 0 0
[  663.830678][ T3123]   #3
[  664.269661][ T3202] Hardware name: HPE ProLiant DL385 Gen10/ProLiant DL385
Gen10, BIOS A40 06/24/2019
[  664.278993][ T3202] Workqueue: kblockd blk_mq_run_work_fn
[  664.284453][ T3202] Call Trace:
[  664.287655][ T3202]  dump_stack+0x62/0x9a
[  664.291721][ T3202]  warn_alloc.cold.45+0x8a/0x12a
[  664.296577][ T3202]  ? zone_watermark_ok_safe+0x1a0/0x1a0
[  664.302044][ T3202]  ? __read_once_size_nocheck.constprop.2+0x10/0x10
[  664.308564][ T3202]  ? pqi_scsi_queue_command+0x791/0xdd0 [smartpqi]
[  664.314996][ T3202]  ? pqi_scsi_queue_command+0x791/0xdd0 [smartpqi]
[  664.321420][ T3202]  ? __isolate_free_page+0x390/0x390
[  664.326613][ T3202]  __alloc_pages_nodemask+0x1aab/0x1bc0
[  664.332062][ T3202]  ? gfp_pfmemalloc_allowed+0xc0/0xc0
[  664.337345][ T3202]  ? stack_trace_save+0x87/0xb0
[  664.342103][ T3202]  ? freezing_slow_path.cold.1+0x35/0x35
[  664.347647][ T3202]  ? __kasan_kmalloc.part.0+0x81/0xc0
[  664.352925][ T3202]  ? __kasan_kmalloc.part.0+0x44/0xc0
[  664.358204][ T3202]  ? __kasan_kmalloc.constprop.1+0xac/0xc0
[  664.363922][ hmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB
all_unreclaimable? no
[  664.759472][ T3127]  ? __read_once_size_nocheck.constprop.2+0x10/0x10
[  664.759508][ T3127]  ? pqi_scsi_queue_command+0x791/0xdd0 [smartpqi]
[  664.785836][ T3202] Node 4 active_anon:15362196kB inactive_anon:1296156kB
active_file:15052kB inactive_file:17752kB unevictable:0kB isolated(anon):66644kB
isolated(file):112kB mapped:30596kB dirty:0kB writeback:3968kB shmem:1080kB
shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 14735360kB writeback_tmp:0kB
unstable:0kB all_unreclaimable? no
[  664.789031][ T3127]  ? pqi_scsi_queue_command+0x791/0xdd0 [smartpqi]
[  664.793056][ T3202] Node 5 active_anon:0kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB
mapped:0kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 0kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  664.819386][ T3127]  ? __isolate_free_page+0x390/0x390
[  664.819401][ T3127]  __alloc_pages_nodemask+0x1aab/0x1bc0
[  664.824245][ T3202] Node 6 active_anon7]  map_sg+0x99/0x2f0
[  665.159320][ T3202] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=2048kB
[  665.191157][ T3127]  ? kasan_check_read+0x11/0x20
[  665.191176][ T3127]  scsi_dma_map+0xc6/0x160
[  665.195480][ T3202] Node 4 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=1048576kB
[  665.195490][ T3202] Node 4 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=2048kB
[  665.200248][ T3127]  pqi_raid_submit_scsi_cmd_with_io_request+0x1c3/0x470
[smartpqi]
[  665.204805][ T3202] 69668 total pagecache pages
[  665.209566][ T3127]  ? pqi_alloc_io_request+0x11e/0x140 [smartpqi]
[  665.213886][ T3202] 65404 pages in swap cache
[  665.228054][ T3127]  pqi_scsi_queue_command+0x791/0xdd0 [smartpqi]
[  665.228074][ T3127]  ? scsi_init_io+0x102/0x150
[  665.232285][ T3202] Swap cache stats: add 486050, delete 428240, find 59/149
[  665.232294][ T3202] Free swap  = 30975484kB
[  665.236832][ T3127]  ? sd_setup_read_write_cmnd+0x6e9/0xa90 [sd_mod]
[  665.236858][ T3127]  ? pqi_event_worker+0xdf0/0xdf0 [smar390
[  665.806891][ T3141]  ? lock_downgrade+0x390/0x390
[  665.811664][ T3141]  ? alloc_iova+0x33/0x210
[  665.815987][ T3141]  __slab_alloc+0x12/0x20
[  665.820232][ T3141]  ? __slab_alloc+0x12/0x20
[  665.824654][ T3141]  kmem_cache_alloc+0x32a/0x400
[  665.829413][ T3141]  ? kasan_check_read+0x11/0x20
[  665.834179][ T3141]  ? do_raw_spin_unlock+0xa8/0x140
[  665.839221][ T3141]  alloc_iova+0x33/0x210
[  665.843369][ T3141]  ? iova_rcache_get+0x1a1/0x300
[  665.848225][ T3141]  alloc_iova_fast+0x47/0xba
[  665.852736][ T3141]  dma_ops_alloc_iova.isra.5+0x86/0xa0
[  665.858122][ T3141]  map_sg+0x99/0x2f0
[  665.861957][ T3141]  ? kasan_check_read+0x11/0x20
[  665.866759][ T3141]  scsi_dma_map+0xc6/0x160
[  665.871098][ T3141]  pqi_raid_submit_scsi_cmd_with_io_request+0x1c3/0x470
[smartpqi]
[  665.878918][ T3141]  ? pqi_alloc_io_request+0x11e/0x140 [smartpqi]
[  665.885172][ T3141]  pqi_scsi_queue_command+0x791/0xdd0 [smartpqi]
[  665.891435][ T3141]  ? scsi_init_io+0x102/0x150
[  665.896103][ T3141]  ? sd_setup_read_write_cmnd+0x6e9/0xa90 [sd_mod]
[  665.902619][ T3141]  ? pqie:0kB unevictable:0kB writepending:0kB
present:15996kB managed:15908kB mlocked:0kB kernel_stack:0kB pagetables:0kB
bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  666.300385][ T3141] lowmem_reserve[]: 0 1532 19982 19982 19982
[  666.306395][ T3141] Node 0 DMA32 free:75568kB min:2676kB low:4244kB
high:5812kB active_anon:749752kB inactive_anon:395332kB active_file:128kB
inactive_file:168kB unevictable:0kB writepending:0kB present:1923080kB
managed:1634348kB mlocked:0kB kernel_stack:0kB pagetables:28kB bounce:0kB
free_pcp:55484kB local_pcp:248kB free_cma:0kB
[  666.335894][ T3141] lowmem_reserve[]: 0 0 18450 18450 18450
[  666.341762][ T3141] Node 0 Normal free:52856kB min:52716kB low:71608kB
high:90500kB active_anon:1127696kB inactive_anon:80184kB active_file:492kB
inactive_file:656kB unevictable:0kB writepending:2208kB present:27262976kB
managed:18893712kB mlocked:0kB kernel_stack:22240kB pagetables:10372kB
bounce:0kB free_pcp:12848kB local_pcp:36kB free_cma:0kB
[  666.372602][ T3141] lowmem_reserve[]: 0 0 0 0 0
[  666.377419][ T3141] Node 4 Normal free:234488kB m[  685.274656][ T3456]
list_del corruption. prev->next should be ffffea0022b10098, but was
0000000000000000
[  685.284254][ T3456] ------------[ cut here ]------------
[  685.289616][ T3456] kernel BUG at lib/list_debug.c:53!
[  685.294808][ T3456] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN NOPTI
[  685.301998][ T3456] CPU: 5 PID: 3456 Comm: oom01 Tainted:
G        W         5.2.0-next-20190711+ #3
[  685.311193][ T3456] Hardware name: HPE ProLiant DL385 Gen10/ProLiant DL385
Gen10, BIOS A40 06/24/2019
[  685.320485][ T3456] RIP: 0010:__list_del_entry_valid+0x8b/0xb6
[  685.326364][ T3456] Code: f1 e0 ff 49 8b 55 08 4c 39 e2 75 2c 5b b8 01 00 00
00 41 5c 41 5d 5d c3 4c 89 e2 48 89 de 48 c7 c7 c0 5a 73 a3 e8 d9 fa bc ff <0f>
0b 48 c7 c7 60 a0 e1 a3 e8 13 52 01 00 4c 89 e6 48 c7 c7 20 5b
[  685.345956][ T3456] RSP: 0018:ffff888e0c8a73c0 EFLAGS: 00010082
[  685.351920][ T3456] RAX: 0000000000000054 RBX: ffffea0022b10098 RCX:
ffffffffa2d5d708
[  685.359807][ T3456] RDX: 0000000000000000 RSI: 0000000000000008 RDI:
ffff8888442bd380
[  685.367693][ T3456] RBP: ffff888e0c8a73d8 R08: ffffed1108857a71 R09:
ffffed1108857a70
[  685.375577][ T3456] R10: ffffed1108857a70 R11: ffff8888442bd387 R12:
0000000000000000
[  685.383462][ T3456] R13: 0000000000000000 R14: ffffea0022b10034 R15:
ffffea0022b10098
[  685.391348][ T3456] FS:  00007fbe26db4700(0000) GS:ffff888844280000(0000)
knlGS:0000000000000000
[  685.400194][ T3456] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  685.406681][ T3456] CR2: 00007fbcabb3f000 CR3: 0000001012e44000 CR4:
00000000001406a0
[  685.414563][ T3456] Call Trace:
[  685.417736][ T3456]  deferred_split_scan+0x337/0x740
[  685.422741][ T3456]  ? split_huge_page_to_list+0xe10/0xe10
[  685.428272][ T3456]  ? __radix_tree_lookup+0x12d/0x1e0
[  685.433453][ T3456]  ? node_tag_get.part.0.constprop.6+0x40/0x40
[  685.439505][ T3456]  do_shrink_slab+0x244/0x5a0
[  685.444071][ T3456]  shrink_slab+0x253/0x440
[  685.448375][ T3456]  ? unregister_shrinker+0x110/0x110
[  685.453551][ T3456]  ? kasan_check_read+0x11/0x20
[  685.458291][ T3456]  ? mem_cgroup_protected+0x20f/0x260
[  685.463555][ T3456]  shrink_node+0x31e/0xa30
[  685.467858][ T3456]  ? shrink_node_memcg+0x1560/0x1560
[  685.473036][ T3456]  ? ktime_get+0x93/0x110
[  685.477250][ T3456]  do_try_to_free_pages+0x22f/0x820
[  685.482338][ T3456]  ? shrink_node+0xa30/0xa30
[  685.486815][ T3456]  ? kasan_check_read+0x11/0x20
[  685.491556][ T3456]  ? check_chain_key+0x1df/0x2e0
[  685.496383][ T3456]  try_to_free_pages+0x242/0x4d0
[  685.501209][ T3456]  ? do_try_to_free_pages+0x820/0x820
[  685.506476][ T3456]  __alloc_pages_nodemask+0x9ce/0x1bc0
[  685.511826][ T3456]  ? gfp_pfmemalloc_allowed+0xc0/0xc0
[  685.517089][ T3456]  ? kasan_check_read+0x11/0x20
[  685.521826][ T3456]  ? check_chain_key+0x1df/0x2e0
[  685.526657][ T3456]  ? do_anonymous_page+0x343/0xe30
[  685.531658][ T3456]  ? lock_downgrade+0x390/0x390
[  685.536399][ T3456]  ? get_kernel_page+0xa0/0xa0
[  685.541050][ T3456]  ? __lru_cache_add+0x108/0x160
[  685.545879][ T3456]  alloc_pages_vma+0x89/0x2c0
[  685.550444][ T3456]  do_anonymous_page+0x3e1/0xe30
[  685.555271][ T3456]  ? __update_load_avg_cfs_rq+0x2c/0x490
[  685.560796][ T3456]  ? finish_fault+0x120/0x120
[  685.565361][ T3456]  ? alloc_pages_vma+0x21e/0x2c0
[  685.570187][ T3456]  handle_pte_fault+0x457/0x12c0
[  685.575014][ T3456]  __handle_mm_fault+0x79a/0xa50
[  685.579841][ T3456]  ? vmf_insert_mixed_mkwrite+0x20/0x20
[  685.585280][ T3456]  ? kasan_check_read+0x11/0x20
[  685.590021][ T3456]  ? __count_memcg_events+0x8b/0x1c0
[  685.595196][ T3456]  handle_mm_fault+0x17f/0x370
[  685.599850][ T3456]  __do_page_fault+0x25b/0x5d0
[  685.604501][ T3456]  do_page_fault+0x4c/0x2cf
[  685.608892][ T3456]  ? page_fault+0x5/0x20
[  685.613019][ T3456]  page_fault+0x1b/0x20
[  685.617058][ T3456] RIP: 0033:0x410be0
[  685.620840][ T3456] Code: 89 de e8 e3 23 ff ff 48 83 f8 ff 0f 84 86 00 00 00
48 89 c5 41 83 fc 02 74 28 41 83 fc 03 74 62 e8 95 29 ff ff 31 d2 48 98 90 <c6>
44 15 00 07 48 01 c2 48 39 d3 7f f3 31 c0 5b 5d 41 5c c3 0f 1f
[  68[  687.120156][ T3456] Shutting down cpus with NMI
[  687.124731][ T3456] Kernel Offset: 0x21800000 from 0xffffffff81000000
(relocation range: 0xffffffff80000000-0xffffffffbfffffff)
[  687.136389][ T3456] ---[ end Kernel panic - not syncing: Fatal exception ]---

