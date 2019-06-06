Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAFD8C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 16:09:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 332E920868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 16:09:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="gswcG7Pt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 332E920868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CABFA6B027C; Thu,  6 Jun 2019 12:09:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C37226B027D; Thu,  6 Jun 2019 12:09:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAEAF6B027E; Thu,  6 Jun 2019 12:09:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 838C16B027C
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 12:09:50 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n5so2365891qkf.7
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 09:09:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=Zzx0oR9OY2SLT9LrHv5yPWqxvZv/4fKN+OQR2sv3RI4=;
        b=qWbewkZhNEJdpSUZCybA2hfrNaas+qsx8gUT2vAP/5rCYqk+U2p9LfWikFM12HaN0b
         iHbdcyDY3lEWALMa2IMW+w/Bh9MVuzoHsl0kGKm8+JrUalOfiH0qvH2zE5q7lQsRW/0o
         H2swkweX8/S+8Oup9g1ezk1wJvhR9jB/lmfOpL6Ggq9cnB74ipKdQ0iS5Gby0yFauPjc
         o4q47V4LfUAZ2lO2Z1fqgO7OSVidaum4ipdK0BpXmsklkvl922Gj6nl8LYAtxGm7XIxc
         h8eGV4ML3y1atHp1ZI7T7q+vX8K+uPqs/6P2niJoaMdwH40gN9g/BXrAF5A58rhmecWJ
         bE9A==
X-Gm-Message-State: APjAAAVGa3izA/lnlO9rtbCu6NlYt3Rq85oEoxM94q0GlQnYbs9a1psR
	vwWVe/BgsonEhsoLsP4pTPHi8pKekcpEJEkHSvIQZqDIKM5VT8CG5SaopbUBn/1Dc2ZLzr47PFN
	Zz9GZ+rm3tw1zoBCF2bz+ABVe1wPHvfkdMY2gKEA8cP81nTXuWQf55YmgLFO1+jadzA==
X-Received: by 2002:ac8:2202:: with SMTP id o2mr41466775qto.132.1559837390300;
        Thu, 06 Jun 2019 09:09:50 -0700 (PDT)
X-Received: by 2002:ac8:2202:: with SMTP id o2mr41466677qto.132.1559837389133;
        Thu, 06 Jun 2019 09:09:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559837389; cv=none;
        d=google.com; s=arc-20160816;
        b=TWuAqMHHpmpFqLcWFJsLFHMfkrCn7dJT9Ee1kCOUUMxqXds3JWp4vmy38NqcT0HJN6
         ClPPf5jKYS6YjLvKP3YplQZlv3EiBxWn9QVC0JsBBsKrCfORfXov1uqrQLc51ZWNaT9L
         0SP/E2iGYHAbSfRWT7LwvRyRPdN7ljIVJQYwSmH8jAjhBgoNhPshThqkRd6XXExrWaqT
         b53ZZ1tectD1jTFQwpoEdXQCgouujf9SoYDeLYLcFa4dHeJb0GD4bv+S8e0ODXMj1Ddy
         o0k+1zIESf3X91tMIo8nERI1h7H6y6oL1U4I1xX1TFC781drxgWdHqf2GxKWdLNguES8
         2orQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=Zzx0oR9OY2SLT9LrHv5yPWqxvZv/4fKN+OQR2sv3RI4=;
        b=KUGcEsCZlTEcEw7KRFUKTTYm0FDbE6bVbBESBjYkCiNmciznui8Lt6habpGggFImLa
         717ERp3KX/83lENnX5Akg8MJiFwwlu8wlfxNRz4HlCpV7QQLW4iGYjH6aSDXGSsh8i2t
         /sKV9EOAEToPbpFuCzDopWvG0hucx6vmwa1rGY2pS52BtLota19TW3BAfCd5lxXjN5Dd
         Qt+PIrHoc7MVpLgngsz9mx/t5MIyRt7pecWsJSEtpmvp+Bej4NbbTvf1pgxhL8YMB6eM
         1Xin24DYh7alKUQHpdE/jemmbxcZNhK5htf3fEcwWSLx5aUEcFCCuLf3anU9KMrGWciV
         fb9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=gswcG7Pt;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 11sor1778726qvx.14.2019.06.06.09.09.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 09:09:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=gswcG7Pt;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Zzx0oR9OY2SLT9LrHv5yPWqxvZv/4fKN+OQR2sv3RI4=;
        b=gswcG7PtRkOK37NsX5KHMpecpcBG9Tm20jWxK3Y7Rs0EXkeZ2aw0WI86bELqzxX8Hi
         IZzE+dwoHd1YoQk2eVOH2+W3aeAQBJskhPmrlBT8CwcNJYY74I0iuqVIcsgAwtBTN3Mj
         j4o6aW1a9lf4/8RhOwcx5ByRmoPh8FRedCnDtI9N/NPf3LQUAcO7RkqCXqbuzYDT6mrk
         CHx1plfwOidOzfSEvTYYWSExNUOGIv++iw16x6Qe2IM2n0nfWxp/oyl4ffL6PhwTA16+
         dpAqMH6RhK8VTXnDhwN+A2OZ/crNsRjt6YO0dOPVVz263Yz0noRfAt0G1iRVfIsjA5xx
         ceHQ==
X-Google-Smtp-Source: APXvYqx7ymgh8MwFfR2ocpfKbYzrgD59R+18cSNmqg+2pNcoAEXqK4wEp9A3wsSjaPa4Y5g9m1E/YA==
X-Received: by 2002:a0c:bd18:: with SMTP id m24mr17509137qvg.118.1559837388722;
        Thu, 06 Jun 2019 09:09:48 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id g65sm1057444qkb.1.2019.06.06.09.09.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 09:09:48 -0700 (PDT)
Message-ID: <1559837386.6132.47.camel@lca.pw>
Subject: Re: "lib: rework bitmap_parse()" triggers invalid access errors
From: Qian Cai <cai@lca.pw>
To: Yuri Norov <ynorov@marvell.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, Andy Shevchenko
 <andriy.shevchenko@linux.intel.com>, Andrew Morton
 <akpm@linux-foundation.org>,  "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Yury Norov <yury.norov@gmail.com>
Date: Thu, 06 Jun 2019 12:09:46 -0400
In-Reply-To: <BN6PR1801MB20655CFFEA0CEA242C088C25CB160@BN6PR1801MB2065.namprd18.prod.outlook.com>
References: <1559242868.6132.35.camel@lca.pw>
	,<1559672593.6132.44.camel@lca.pw>
	 <BN6PR1801MB20655CFFEA0CEA242C088C25CB160@BN6PR1801MB2065.namprd18.prod.outlook.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-06-05 at 08:01 +0000, Yuri Norov wrote:
> (Sorry for top-posting)
> 
> I can reproduce this on next-20190604. Is it new trace, or like one you've
> posted before?

Same thing, "nbits" causes an invalid access.

# ./scripts/faddr2line vmlinux bitmap_parse+0x20c/0x2d8
bitmap_parse+0x20c/0x2d8:
__bitmap_clear at lib/bitmap.c:280
(inlined by) bitmap_clear at include/linux/bitmap.h:390
(inlined by) bitmap_parse at lib/bitmap.c:662

This line,

while (len - bits_to_clear >= 0) {

[  151.025490][ T3745]
==================================================================
[  151.033437][ T3745] BUG: KASAN: invalid-access in bitmap_parse+0x20c/0x2d8
[  151.040313][ T3745] Write of size 8 at addr 88ff80961f5637a0 by task
irqbalance/3745
[  151.048052][ T3745] Pointer tag: [88], memory tag: [fe]
[  151.053272][ T3745] 
[  151.055462][ T3745] CPU: 191 PID: 3745 Comm: irqbalance Tainted:
G        W         5.2.0-rc3-next-20190606+ #2
[  151.065548][ T3745] Hardware name: HPE Apollo
70             /C01_APACHE_MB         , BIOS L50_5.13_1.0.9 03/01/2019
[  151.076064][ T3745] Call trace:
[  151.079218][ T3745]  dump_backtrace+0x0/0x268
[  151.083574][ T3745]  show_stack+0x20/0x2c
[  151.087589][ T3745]  dump_stack+0xb4/0x108
[  151.091691][ T3745]  print_address_description+0x7c/0x330
[  151.097088][ T3745]  __kasan_report+0x194/0x1dc
[  151.101616][ T3745]  kasan_report+0x10/0x18
[  151.105799][ T3745]  __hwasan_store8_noabort+0x74/0x7c
[  151.110935][ T3745]  bitmap_parse+0x20c/0x2d8
[  151.115291][ T3745]  bitmap_parse_user+0x40/0x64
[  151.119910][ T3745]  write_irq_affinity+0x118/0x1a8
[  151.124786][ T3745]  irq_affinity_proc_write+0x34/0x44
[  151.129925][ T3745]  proc_reg_write+0xf4/0x130
[  151.134376][ T3745]  __vfs_write+0x88/0x33c
[  151.138561][ T3745]  vfs_write+0x118/0x208
[  151.142656][ T3745]  ksys_write+0xa0/0x110
[  151.146752][ T3745]  __arm64_sys_write+0x54/0x88
[  151.151377][ T3745]  el0_svc_handler+0x198/0x260
[  151.155992][ T3745]  el0_svc+0x8/0xc
[  151.159566][ T3745] 
[  151.161751][ T3745] Allocated by task 3745:
[  151.165933][ T3745]  __kasan_kmalloc+0x114/0x1d0
[  151.170553][ T3745]  kasan_kmalloc+0x10/0x18
[  151.174830][ T3745]  __kmalloc_node+0x1e0/0x788
[  151.179358][ T3745]  alloc_cpumask_var_node+0x48/0x94
[  151.184407][ T3745]  alloc_cpumask_var+0x10/0x1c
[  151.189022][ T3745]  write_irq_affinity+0xa8/0x1a8
[  151.193811][ T3745]  irq_affinity_proc_write+0x34/0x44
[  151.198947][ T3745]  proc_reg_write+0xf4/0x130
[  151.203389][ T3745]  __vfs_write+0x88/0x33c
[  151.207573][ T3745]  vfs_write+0x118/0x208
[  151.211668][ T3745]  ksys_write+0xa0/0x110
[  151.215764][ T3745]  __arm64_sys_write+0x54/0x88
[  151.220380][ T3745]  el0_svc_handler+0x198/0x260
[  151.224996][ T3745]  el0_svc+0x8/0xc
[  151.228566][ T3745] 
[  151.230749][ T3745] Freed by task 3745:
[  151.234585][ T3745]  __kasan_slab_free+0x154/0x228
[  151.239374][ T3745]  kasan_slab_free+0xc/0x18
[  151.243729][ T3745]  kfree+0x268/0xb70
[  151.247484][ T3745]  free_cpumask_var+0xc/0x14
[  151.251932][ T3745]  write_irq_affinity+0x19c/0x1a8
[  151.256807][ T3745]  irq_affinity_proc_write+0x34/0x44
[  151.261943][ T3745]  proc_reg_write+0xf4/0x130
[  151.266386][ T3745]  __vfs_write+0x88/0x33c
[  151.270567][ T3745]  vfs_write+0x118/0x208
[  151.274661][ T3745]  ksys_write+0xa0/0x110
[  151.278756][ T3745]  __arm64_sys_write+0x54/0x88
[  151.283371][ T3745]  el0_svc_handler+0x198/0x260
[  151.287986][ T3745]  el0_svc+0x8/0xc
[  151.291556][ T3745] 
[  151.293742][ T3745] The buggy address belongs to the object at
ffff80961f563780
[  151.293742][ T3745]  which belongs to the cache kmalloc-128 of size 128
[  151.307647][ T3745] The buggy address is located 32 bytes inside of
[  151.307647][ T3745]  128-byte region [ffff80961f563780, ffff80961f563800)
[  151.320681][ T3745] The buggy address belongs to the page:
[  151.326167][ T3745] page:ffff7fe02587d580 refcount:1 mapcount:0
mapping:fdff800800010480 index:0x8aff80961f56dc80
[  151.336429][ T3745] flags: 0x17ffffffc000200(slab)
[  151.341222][ T3745] raw: 017ffffffc000200 ffff7fe025843788 e3ff808b7d00fd40
fdff800800010480
[  151.349659][ T3745] raw: 8aff80961f56dc80 000000000066001d 00000001ffffffff
0000000000000000
[  151.358092][ T3745] page dumped because: kasan: bad access detected
[  151.364361][ T3745] page allocated via order 0, migratetype Unmovable,
gfp_mask 0x12800(GFP_NOWAIT|__GFP_NOWARN|__GFP_NORETRY)
[  151.375757][ T3745]  prep_new_page+0x2f4/0x378
[  151.380201][ T3745]  get_page_from_freelist+0x253c/0x2868
[  151.385598][ T3745]  __alloc_pages_nodemask+0x360/0x1c60
[  151.390908][ T3745]  alloc_pages_current+0xd0/0xe0
[  151.395699][ T3745]  new_slab+0x15c/0x9d4
[  151.399707][ T3745]  ___slab_alloc+0x57c/0x9e4
[  151.404148][ T3745]  __kmalloc+0x58c/0x5e0
[  151.408247][ T3745]  memcg_kmem_get_cache+0x150/0x65c
[  151.413296][ T3745]  kmem_cache_alloc+0x208/0x568
[  151.418010][ T3745]  __anon_vma_prepare+0x60/0x210
[  151.422799][ T3745]  do_fault+0xc64/0xf80
[  151.426807][ T3745]  handle_pte_fault+0x4e4/0x15e8
[  151.431597][ T3745]  handle_mm_fault+0x6a4/0x95c
[  151.436216][ T3745]  do_page_fault+0x4a0/0x770
[  151.440657][ T3745]  do_translation_fault+0x60/0xa0
[  151.445537][ T3745]  do_mem_abort+0x58/0xf4
[  151.449715][ T3745] 
[  151.451897][ T3745] Memory state around the buggy address:
[  151.457381][ T3745]  ffff80961f563500: 93 93 93 93 93 93 93 93 fe fe fe fe fe
fe fe fe
[  151.465295][ T3745]  ffff80961f563600: fe fe fe fe fe fe fe fe fe fe fe fe fe
fe fe fe
[  151.473209][ T3745] >ffff80961f563700: fe fe fe fe fe fe fe fe 88 88 fe fe fe
fe fe fe
[  151.481120][ T3745]                                                  ^
[  151.487645][ T3745]  ffff80961f563800: fe fe fe fe fe fe fe fe fe fe fe fe fe
fe fe fe
[  151.495562][ T3745]  ffff80961f563900: fe fe fe fe fe fe fe fe fe fe fe fe fe
fe fe fe
[  151.503481][ T3745]
==================================================================
[  151.511399][ T3745] Disabling lock debugging due to kernel taint

