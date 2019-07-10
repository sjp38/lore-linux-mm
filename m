Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8F75C74A36
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 21:43:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 836E320838
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 21:43:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="RTtmexYz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 836E320838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23B0B8E0099; Wed, 10 Jul 2019 17:43:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C4BD8E0032; Wed, 10 Jul 2019 17:43:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08D018E0099; Wed, 10 Jul 2019 17:43:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id C0BAD8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 17:43:30 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id b139so3240623qkc.21
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 14:43:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:mime-version:content-transfer-encoding;
        bh=2tzgi4Zac0ZxLi4fn6SADohqb+2iB/sBi5WTb+EDY1c=;
        b=AXiZnlonqqm9hYUf4AhEoQdrDVj1LuM7PHYCaksKygdhsLduk/FGD1XF3svpS9xZPl
         SOW05YU/gCnLmxySruam0gzYcsAZS/mJtIT1/H4fj0+LKZsAZhEiJXwW/3xb8CZf1DMK
         3seRTor1az1keo36mZJgJH8i4C+BirV6H7CKo3cv9Dl7dEWhMb7RrOqBxHx9zlW2ONbw
         +8DGGwcvh5YDsk//PR5yxrDswcK4vp7Op3ruwVitPbfa+orMEHU+DoO1oXzCfYHQbEiI
         TERF9oagXa1fooucwxpfggzm+lVRVE/ic4iU8GLEpYYQXjKqnTSN9gPOKGf4aU8eML1I
         +uIg==
X-Gm-Message-State: APjAAAXT4uUodyIODPk28ldEy9BYBrlSSTPYSboI+YfV+L803j5XmB9i
	SWZ61AGV3oueggVEg7jbMWZfu6kYzlIVVWqWlLTzrm6xeE+t5ixa+bHVlbtUWiHLxbM/456YrC2
	czUb3oQm/pMcFvcjCiO6+uD0qb7Hn1AuibRUaRNn3ldTktUDApiSVPk83iO7j9jW8wg==
X-Received: by 2002:ac8:768f:: with SMTP id g15mr120587qtr.23.1562795010358;
        Wed, 10 Jul 2019 14:43:30 -0700 (PDT)
X-Received: by 2002:ac8:768f:: with SMTP id g15mr120535qtr.23.1562795009468;
        Wed, 10 Jul 2019 14:43:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562795009; cv=none;
        d=google.com; s=arc-20160816;
        b=PP7i7xWn3YVOcIC/0LrytJBW79W/AtCnt6xFo5YW5vPZN1ilgCey2ST9X4x146KX61
         FYdFiYI+gPxqtRZHBHaqnqOHBGjVIJmlgZ/D5oPD1Iqram7IKO1PXehruoonkt3cSzk/
         bYVEr+ojxj0m+m58Gb0vx25LS81wVTWYoe9UPMVuif46bgXT31NnXt+uBhMZDif8feA7
         JIKhyvAat/bxDxvRsCjBwc0WhnIBpoJU07B2qlXk28oAgCMq0OdkesLf+MuaL84Wh931
         JrWmbH3C6s3ol6jsdiPpmKSwVjxiGPeRKpbu4HINDwSCrUL5voVLjZuCdE5/l1A4W+u3
         CJXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:date:cc:to:from:subject
         :message-id:dkim-signature;
        bh=2tzgi4Zac0ZxLi4fn6SADohqb+2iB/sBi5WTb+EDY1c=;
        b=fNITv+1nX5C4ZQUREvZMqkKFMoo5HSPUGxUG/R3v/wAZT/vDuO2XAr6RTzWPYs2+Rf
         ttUpS64KaS9XIhIEwsELHvYVIV25bvYShOtmQCx3RAP7w/jaaH/V+ATzO7zsj3M6VYG7
         GYzExJG2Ie0nvNWAzNQM4f6fbSt0yFTKK2ii5R0wZYX15JBRzewF/nEUX4Trdxm9XkHH
         ojfb2PlszpCki4Za12JI/Dv2DVbEdlZVFrOEWgeXkmGQ7sLDR3pZM//1A7Z9jCGUCcFP
         lnay5iARZMGtzpgb30aTGnPHpNy2cjausa4Hmck9PPOBHpKqCeaTht80sEtDyjQP3dCC
         fXNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=RTtmexYz;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t28sor5165425qtj.18.2019.07.10.14.43.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 14:43:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=RTtmexYz;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:mime-version
         :content-transfer-encoding;
        bh=2tzgi4Zac0ZxLi4fn6SADohqb+2iB/sBi5WTb+EDY1c=;
        b=RTtmexYzjFGoJNmCNQ+kGg6eiE3WpGN0tLMskcLxxMLXwbgWWV22p0bY3n5+G7V5MG
         ch4U6R3QEqFDRQpW8xli4FEue0UXhpR5D2ngEYFawyLCjEC2BCynACgaB7ewK5107887
         1XpThMjllNPzJaO3CV9kAoxVZOA6F8zgKeNbxFIbX9IRliKWl/FCUMO7sxhxk/1mcVJ/
         efa6l8qNn/93CPUVUbU7e9fMyV7QDdv7h6UH3KUeEnAyOcD2ANIvtWp4hhbt5PlpEgEm
         9aO8RwVSPi/miJ5jXIHLbx9KewwuQtUNOjzvKIIbR9SQiqXFaj2Cxo2KlgatChzGFPk7
         00mQ==
X-Google-Smtp-Source: APXvYqzYZYzY8fBomc8nJoZ4iEwjzHsi/gvyHTfpNqwqEvGYAuecSeFtOzR19LP+c0Lj3Lym8Xj8Lw==
X-Received: by 2002:ac8:f91:: with SMTP id b17mr128454qtk.352.1562795008984;
        Wed, 10 Jul 2019 14:43:28 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id r205sm1975641qke.115.2019.07.10.14.43.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jul 2019 14:43:28 -0700 (PDT)
Message-ID: <1562795006.8510.19.camel@lca.pw>
Subject: list corruption in deferred_split_scan()
From: Qian Cai <cai@lca.pw>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Wed, 10 Jul 2019 17:43:26 -0400
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Running LTP oom01 test case with swap triggers a crash below. Revert the series
"Make deferred split shrinker memcg aware" [1] seems fix the issue.

aefde94195ca mm: thp: make deferred split shrinker memcg aware
cf402211cacc mm-shrinker-make-shrinker-not-depend-on-memcg-kmem-fix-2-fix
ca37e9e5f18d mm-shrinker-make-shrinker-not-depend-on-memcg-kmem-fix-2
5f419d89cab4 mm-shrinker-make-shrinker-not-depend-on-memcg-kmem-fix
c9d49e69e887 mm: shrinker: make shrinker not depend on memcg kmem
1c0af4b86bcf mm: move mem_cgroup_uncharge out of __page_cache_release()
4e050f2df876 mm: thp: extract split_queue_* into a struct

[1] https://lore.kernel.org/linux-mm/1561507361-59349-1-git-send-email-yang.shi@
linux.alibaba.com/

[ 1145.730682][ T5764] list_del corruption, ffffea00251c8098->next is
LIST_POISON1 (dead000000000100)
[ 1145.739763][ T5764] ------------[ cut here ]------------
[ 1145.745126][ T5764] kernel BUG at lib/list_debug.c:47!
[ 1145.750320][ T5764] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN NOPTI
[ 1145.757513][ T5764] CPU: 1 PID: 5764 Comm: oom01 Tainted:
G        W         5.2.0-next-20190710+ #7
[ 1145.766709][ T5764] Hardware name: HPE ProLiant DL385 Gen10/ProLiant DL385
Gen10, BIOS A40 01/25/2019
[ 1145.776000][ T5764] RIP: 0010:__list_del_entry_valid.cold.0+0x12/0x4a
[ 1145.782491][ T5764] Code: c7 40 5a 33 af e8 ac fe bc ff 0f 0b 48 c7 c7 80 9e
a1 af e8 f6 4c 01 00 4c 89 ea 48 89 de 48 c7 c7 20 59 33 af e8 8c fe bc ff <0f>
0b 48 c7 c7 40 9f a1 af e8 d6 4c 01 00 4c 89 e2 48 89 de 48 c7
[ 1145.802078][ T5764] RSP: 0018:ffff888514d773c0 EFLAGS: 00010082
[ 1145.808042][ T5764] RAX: 000000000000004e RBX: ffffea00251c8098 RCX:
ffffffffae95d318
[ 1145.815923][ T5764] RDX: 0000000000000000 RSI: 0000000000000008 RDI:
ffff8888440bd380
[ 1145.823806][ T5764] RBP: ffff888514d773d8 R08: ffffed1108817a71 R09:
ffffed1108817a70
[ 1145.831689][ T5764] R10: ffffed1108817a70 R11: ffff8888440bd387 R12:
dead000000000122
[ 1145.839571][ T5764] R13: dead000000000100 R14: ffffea00251c8034 R15:
dead000000000100
[ 1145.847455][ T5764] FS:  00007f765ad4d700(0000) GS:ffff888844080000(0000)
knlGS:0000000000000000
[ 1145.856299][ T5764] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1145.862784][ T5764] CR2: 00007f8cebec7000 CR3: 0000000459338000 CR4:
00000000001406a0
[ 1145.870664][ T5764] Call Trace:
[ 1145.873835][ T5764]  deferred_split_scan+0x337/0x740
[ 1145.878835][ T5764]  ? split_huge_page_to_list+0xe30/0xe30
[ 1145.884364][ T5764]  ? __radix_tree_lookup+0x12d/0x1e0
[ 1145.889539][ T5764]  ? node_tag_get.part.0.constprop.6+0x40/0x40
[ 1145.895592][ T5764]  do_shrink_slab+0x244/0x5a0
[ 1145.900159][ T5764]  shrink_slab+0x253/0x440
[ 1145.904462][ T5764]  ? unregister_shrinker+0x110/0x110
[ 1145.909641][ T5764]  ? kasan_check_read+0x11/0x20
[ 1145.914383][ T5764]  ? mem_cgroup_protected+0x20f/0x260
[ 1145.919645][ T5764]  shrink_node+0x31e/0xa30
[ 1145.923949][ T5764]  ? shrink_node_memcg+0x1560/0x1560
[ 1145.929126][ T5764]  ? ktime_get+0x93/0x110
[ 1145.933340][ T5764]  do_try_to_free_pages+0x22f/0x820
[ 1145.938429][ T5764]  ? shrink_node+0xa30/0xa30
[ 1145.942906][ T5764]  ? kasan_check_read+0x11/0x20
[ 1145.947647][ T5764]  ? check_chain_key+0x1df/0x2e0
[ 1145.952474][ T5764]  try_to_free_pages+0x242/0x4d0
[ 1145.957299][ T5764]  ? do_try_to_free_pages+0x820/0x820
[ 1145.962566][ T5764]  __alloc_pages_nodemask+0x9ce/0x1bc0
[ 1145.967917][ T5764]  ? kasan_check_read+0x11/0x20
[ 1145.972657][ T5764]  ? gfp_pfmemalloc_allowed+0xc0/0xc0
[ 1145.977920][ T5764]  ? kasan_check_read+0x11/0x20
[ 1145.982659][ T5764]  ? check_chain_key+0x1df/0x2e0
[ 1145.987487][ T5764]  ? do_anonymous_page+0x343/0xe30
[ 1145.992489][ T5764]  ? lock_downgrade+0x390/0x390
[ 1145.997230][ T5764]  ? __count_memcg_events+0x8b/0x1c0
[ 1146.002404][ T5764]  ? kasan_check_read+0x11/0x20
[ 1146.007145][ T5764]  ? __lru_cache_add+0x122/0x160
[ 1146.011974][ T5764]  alloc_pages_vma+0x89/0x2c0
[ 1146.016538][ T5764]  do_anonymous_page+0x3e1/0xe30
[ 1146.021367][ T5764]  ? __update_load_avg_cfs_rq+0x2c/0x490
[ 1146.026893][ T5764]  ? finish_fault+0x120/0x120
[ 1146.031461][ T5764]  ? call_function_interrupt+0xa/0x20
[ 1146.036724][ T5764]  handle_pte_fault+0x457/0x12c0
[ 1146.041552][ T5764]  __handle_mm_fault+0x79a/0xa50
[ 1146.046378][ T5764]  ? vmf_insert_mixed_mkwrite+0x20/0x20
[ 1146.051817][ T5764]  ? kasan_check_read+0x11/0x20
[ 1146.056557][ T5764]  ? __count_memcg_events+0x8b/0x1c0
[ 1146.061732][ T5764]  handle_mm_fault+0x17f/0x370
[ 1146.066386][ T5764]  __do_page_fault+0x25b/0x5d0
[ 1146.071037][ T5764]  do_page_fault+0x4c/0x2cf
[ 1146.075426][ T5764]  ? page_fault+0x5/0x20
[ 1146.079553][ T5764]  page_fault+0x1b/0x20
[ 1146.083594][ T5764] RIP: 0033:0x410be0
[ 1146.087373][ T5764] Code: 89 de e8 e3 23 ff ff 48 83 f8 ff 0f 84 86 00 00 00
48 89 c5 41 83 fc 02 74 28 41 83 fc 03 74 62 e8 95 29 ff ff 31 d2 48 98 90 <c6>
44 15 00 07 48 01 c2 48 39 d3 7f f3 31 c0 5b 5d 41 5c c3 0f 1f
[ 1146.106959][ T5764] RSP: 002b:00007f765ad4cec0 EFLAGS: 00010206
[ 1146.112921][ T5764] RAX: 0000000000001000 RBX: 00000000c0000000 RCX:
00007f98f2674497
[ 1146.120804][ T5764] RDX: 0000000001d95000 RSI: 00000000c0000000 RDI:
0000000000000000
[ 1146.128687][ T5764] RBP: 00007f74d9d4c000 R08: 00000000ffffffff R09:
0000000000000000
[ 1146.136569][ T5764] R10: 0000000000000022 R11: 000000000[ 1147.588181][
T5764] Shutting down cpus with NMI
[ 1147.592756][ T5764] Kernel Offset: 0x2d400000 from 0xffffffff81000000
(relocation range: 0xffffffff80000000-0xffffffffbfffffff)
[ 1147.604414][ T5764] ---[ end Kernel panic - not syncing: Fatal exception ]---

