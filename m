Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3EB7C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 20:58:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4644F2081C
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 20:58:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="KNN3M9Yz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4644F2081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FCB56B0003; Tue, 30 Apr 2019 16:58:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AD8F6B0005; Tue, 30 Apr 2019 16:58:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8754B6B0006; Tue, 30 Apr 2019 16:58:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 656FC6B0003
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 16:58:27 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id p43so14873059qtf.1
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 13:58:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:mime-version:content-transfer-encoding;
        bh=p4C14CTS2pz4PiazgYmxilGzF8o3AwVg6Fb8ajLHNGQ=;
        b=bsclprJEkv04WHTgQn8soXaYpwi+0m8aZqnE8ORpzfciJvcD0/gNHjdQhwHL0Y+Swz
         cwzqbwX9PM02tbEJs5H5MsABuCH/XiuTP9NvltizAX/gpnP99h6X0TKXNmqbfWrSi60g
         8JO4bs+Nmb1RXbAfjprsiVq15nZiTGpv2YlFL7p4XWViOMB0DmovinYE46mrygE0PW6V
         9w1jO0vaFV0EmEtqe4rHFez8gr2MHIHeNhNQ6O8Ni4sDXwz2wRsfnrT0XnUsQ4Z9h0hc
         QZt3WYP/IXwtYToW7yMVIthUvVOOHbuIenBd86Hlc93rYRPIIO74FYSClmnfO5HkO7qd
         Y2kg==
X-Gm-Message-State: APjAAAX3de9teS9awArFLYFB5crJ5w16EwZizFEZyRnuAseyJVNU8Q3b
	3dZPfAusodKMJoKad72rio2VYY8H5+QuOH1ZJk3nXUqLfyUdxjxRj9eutaZS3dzq2BUIXjACUxi
	BAjBjRtFzMNNkGiAew5l3AIQkEnNF2+wzJr7efieWEsCsOp9lJJAPuYC4mCBMqsx33Q==
X-Received: by 2002:ac8:37f2:: with SMTP id e47mr27426893qtc.233.1556657907133;
        Tue, 30 Apr 2019 13:58:27 -0700 (PDT)
X-Received: by 2002:ac8:37f2:: with SMTP id e47mr27426813qtc.233.1556657905766;
        Tue, 30 Apr 2019 13:58:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556657905; cv=none;
        d=google.com; s=arc-20160816;
        b=FHZnmY4boEXVtVSimOf8mFf4ggkWITTMgDanYrsw/0jC5wvFqVNC1dpWyaaygOtH9L
         +H8A0UHbq/mqQe+jWnkzsz2x3mNgcozibI+tIZxt/w6HQy72eBO32bGe3g/FalzQdZaC
         g/xsA5zyQB6Xrcxhd5mLWoaKcnFW/4I96lTR1HkbISMQZSAwUbaoVJHMYL0faALFRepW
         7BXJFTEz1eC7hg7Hq9C6CApAm0BT8w1v5keZYZ9wNLbQ95Dt08Mqjws44ME7xzANdiBp
         TaPpAKlV2dZso7TIPS/uTV9uozWzc/73cgObYY7oFvCDwHRbUHq+kbcoOG9Wl9YULugq
         QAuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:date:cc:to:from:subject
         :message-id:dkim-signature;
        bh=p4C14CTS2pz4PiazgYmxilGzF8o3AwVg6Fb8ajLHNGQ=;
        b=icH8aIQTQXNlJExS8bXcXOTE08qtNF149y8+fWxbEa7ukLTlT+ygMOI64iuEDxV01p
         kjdDwuBrSfHKCR9cW5o0xVSYj6fc8OLDOti85YbubwuPoA6bCBZvM2KbN1BoF6PYh1XQ
         zH5y+TiD9l4rZDKS0jq4zxrREtSoY8a/Q3CO39/F+tfB3wSzZx9Bl+ICPXO2R4ouihpg
         UA/gOOCqj1DrCBZGoX6WR8gbCo6HbbIwdANucKr+iz3mEdu6Ghz00u+H43ALRgVTZyqt
         tJwvu+wRgHwwdTiFxh1Q5ra6B2XTIV47mkFuPHEx5KEVGVelBB6FBoYpsf8fT7NGmvhL
         FrFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=KNN3M9Yz;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u7sor7330277qkk.42.2019.04.30.13.58.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 13:58:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=KNN3M9Yz;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:mime-version
         :content-transfer-encoding;
        bh=p4C14CTS2pz4PiazgYmxilGzF8o3AwVg6Fb8ajLHNGQ=;
        b=KNN3M9YzUJLLtq2CmUKgHwCruNuWLAtTohnRNP0w+yopwOElC3KoNz9QLdvrFh7skb
         ruOxSmIuceB4sWTxuNzwqewoKgfSnDjmedWJNUYFZa6N1H8+m6U0Tbonpn2+1i/cB3DX
         53yL0IRas+tArh46n0tSdH1Pj1MbPD6cojAg12VqrMuatkU/QK0bPBMkwb+pLp/OMiL4
         JWtCDKzOmQVBadmytywWzewyQyPhS4+6ht2/1XD6555siHn+0G9p0RypWl8Ls6c0BGt/
         I8+bYMARJGX5MVIAtL2sgbI86uggdM7/5sUixVQZzzqC8NDcnLUQVwSxe+zMItPLOmou
         tEzQ==
X-Google-Smtp-Source: APXvYqxtH/bVFTAz4Uc3zfoJ+Z7QdXcn47swK/0pwCPQsJaRjAUwQCgAPNlKUvztnG4HM9aVWSKceQ==
X-Received: by 2002:ae9:de87:: with SMTP id s129mr51307545qkf.63.1556657905193;
        Tue, 30 Apr 2019 13:58:25 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id n10sm21150892qte.11.2019.04.30.13.58.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 13:58:24 -0700 (PDT)
Message-ID: <1556657902.6132.13.camel@lca.pw>
Subject: copy_fpstate_to_sigframe()  use-after-free
From: Qian Cai <cai@lca.pw>
To: bigeasy@linutronix.de
Cc: dave.hansen@intel.com, bp@suse.de, tglx@linutronix.de, x86@kernel.org, 
	"linux-mm@kvack.org"
	 <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	 <linux-kernel@vger.kernel.org>, luto@amacapital.net, hpa@zytor.com, 
	mingo@kernel.org
Date: Tue, 30 Apr 2019 16:58:22 -0400
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit eeec00d73be2 ("x86/fpu: Fault-in user stack if
copy_fpstate_to_sigframe() fails") causes use-after-free when running the LTP
signal06 test case. Reverted this commit fixed the issue.

[ 6150.581746] LTP: starting signal06
[ 6151.099635]
==================================================================
[ 6151.137893] BUG: KASAN: use-after-free in follow_page_mask+0x32/0x3e0
[ 6151.169683] Read of size 8 at addr ffff8884ac424048 by task signal06/45144
[ 6151.201832] 
[ 6151.208652] CPU: 45 PID: 45144 Comm: signal06 Kdump: loaded Not tainted
5.1.0-rc7-next-20190430+ #8
[ 6151.251025] Hardware name: HP ProLiant XL420 Gen9/ProLiant XL420 Gen9, BIOS
U19 12/27/2015
[ 6151.289642] Call Trace:
[ 6151.300966]  dump_stack+0x62/0x9a
[ 6151.316552]  print_address_description.cold.2+0x9/0x28b
[ 6151.340859]  __kasan_report.cold.3+0x7a/0xb5
[ 6151.360819]  ? follow_page_mask+0x32/0x3e0
[ 6151.380970]  kasan_report+0xc/0x10
[ 6151.396922]  __asan_load8+0x71/0xa0
[ 6151.413474]  follow_page_mask+0x32/0x3e0
[ 6151.431870]  __get_user_pages+0x3cc/0x7c0
[ 6151.450644]  ? follow_page_mask+0x3e0/0x3e0
[ 6151.470058]  ? lock_downgrade+0x300/0x300
[ 6151.488677]  ? __bad_area_nosemaphore+0x66/0x230
[ 6151.510560]  ? do_raw_spin_unlock+0xa8/0x140
[ 6151.530468]  __gup_longterm_locked+0x32c/0xa90
[ 6151.551432]  ? do_page_fault+0x4c/0x260
[ 6151.569327]  ? get_user_pages_unlocked+0x2b0/0x2b0
[ 6151.591874]  get_user_pages+0x60/0x70
[ 6151.609098]  copy_fpstate_to_sigframe+0x31a/0x670
[ 6151.631612]  ? __fpu__restore_sig+0x7a0/0x7a0
[ 6151.652869]  do_signal+0x40c/0x9d0
[ 6151.669822]  ? do_send_specific+0x87/0xe0
[ 6151.690250]  ? setup_sigcontext+0x280/0x280
[ 6151.710151]  ? check_kill_permission+0x8e/0x1c0
[ 6151.731618]  ? do_send_specific+0xa6/0xe0
[ 6151.750539]  ? do_tkill+0x125/0x160
[ 6151.766493]  ? signal_fault+0x160/0x160
[ 6151.783820]  exit_to_usermode_loop+0x9d/0xc0
[ 6151.803040]  do_syscall_64+0x470/0x5d8
[ 6151.819575]  ? syscall_return_slowpath+0xf0/0xf0
[ 6151.840392]  ? __do_page_fault+0x44d/0x5b0
[ 6151.858886]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 6151.882493] RIP: 0033:0x40377e
[ 6151.896645] Code: b4 00 00 00 0f 85 ae 00 00 00 89 c7 31 db ba c8 00 00 00 be
01 00 00 00 eb 0c 66 90 75 1d 81 fb 30 75 00 00 74 65 89 d0 0f 05 <f2> 0f 10 05
7a b8 21 00 83 c3 01 66 0f 2e c1 7b e1 31 c0 41 89 d8
[ 6151.984032] RSP: 002b:00007fff1fa13190 EFLAGS: 00000287 ORIG_RAX:
00000000000000c8
[ 6152.018779] RAX: 0000000000000000 RBX: 0000000000001e12 RCX: 000000000040377e
[ 6152.052252] RDX: 00000000000000c8 RSI: 0000000000000001 RDI: 000000000000b058
[ 6152.085621] RBP: 0000000000000000 R08: 0000000000000000 R09: 00007f8104e48700
[ 6152.119275] R10: fffffffffffff7a8 R11: 0000000000000287 R12: 00007f81056466c0
[ 6152.155037] R13: 00007fff1fa13360 R14: 0000000000000000 R15: 0000000000000000
[ 6152.190814] 
[ 6152.197777] Allocated by task 45145:
[ 6152.214655]  __kasan_kmalloc.part.0+0x44/0xc0
[ 6152.235078]  __kasan_kmalloc.constprop.1+0xac/0xc0
[ 6152.257665]  kasan_slab_alloc+0x11/0x20
[ 6152.275711]  kmem_cache_alloc+0x131/0x360
[ 6152.294272]  vm_area_dup+0x20/0x80
[ 6152.310227]  __split_vma+0x68/0x270
[ 6152.326595]  split_vma+0x51/0x70
[ 6152.341817]  mprotect_fixup+0x469/0x540
[ 6152.359402]  do_mprotect_pkey+0x2a8/0x480
[ 6152.378313]  __x64_sys_mprotect+0x48/0x60
[ 6152.397014]  do_syscall_64+0xc8/0x5d8
[ 6152.414015]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 6152.437731] 
[ 6152.444797] Freed by task 45145:
[ 6152.459202]  __kasan_slab_free+0x134/0x200
[ 6152.477692]  kasan_slab_free+0xe/0x10
[ 6152.494044]  kmem_cache_free+0xa0/0x300
[ 6152.512009]  vm_area_free+0x18/0x20
[ 6152.528295]  __vma_adjust+0x2f8/0xca0
[ 6152.545417]  vma_merge+0x619/0x6d0
[ 6152.561416]  mprotect_fixup+0x2bf/0x540
[ 6152.579336]  do_mprotect_pkey+0x2a8/0x480
[ 6152.597772]  __x64_sys_mprotect+0x48/0x60
[ 6152.616119]  do_syscall_64+0xc8/0x5d8
[ 6152.633298]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 6152.657665] 
[ 6152.665119] The buggy address belongs to the object at ffff8884ac424008
[ 6152.665119]  which belongs to the cache vm_area_struct(96:user.slice) of size
200
[ 6152.734268] The buggy address is located 64 bytes inside of
[ 6152.734268]  200-byte region [ffff8884ac424008, ffff8884ac4240d0)
[ 6152.788643] The buggy address belongs to the page:
[ 6152.810991] page:ffffea0012b10900 count:1 mapcount:0 mapping:ffff88829c7383c0
index:0x0
[ 6152.848361] flags: 0x15fffe000000200(slab)
[ 6152.867558] raw: 015fffe000000200 ffffea00171b6c08 ffff8885928109a0
ffff88829c7383c0
[ 6152.903840] raw: 0000000000000000 0000000000070007 00000001ffffffff
ffff8884da644008
[ 6152.940077] page dumped because: kasan: bad access detected
[ 6152.966181] page->mem_cgroup:ffff8884da644008
[ 6152.986737] page allocated via order 0, migratetype Unmovable, gfp_mask
0x12cc0(GFP_KERNEL|__GFP_NOWARN|__GFP_NORETRY)
[ 6153.036670]  prep_new_page+0x29d/0x2c0
[ 6153.054207]  get_page_from_freelist+0x95b/0x2050
[ 6153.076165]  __alloc_pages_nodemask+0x2ff/0x1b50
[ 6153.097886]  alloc_pages_current+0x9c/0x110
[ 6153.117199]  allocate_slab+0x3a7/0x850
[ 6153.134763]  new_slab+0x46/0x70
[ 6153.149507]  ___slab_alloc+0x5d3/0x9c0
[ 6153.167080]  __slab_alloc+0x12/0x20
[ 6153.184301]  kmem_cache_alloc+0x30a/0x360
[ 6153.203847]  vm_area_dup+0x20/0x80
[ 6153.221785]  __split_vma+0x68/0x270
[ 6153.238130]  split_vma+0x51/0x70
[ 6153.253442]  mprotect_fixup+0x4be/0x540
[ 6153.271351]  do_mprotect_pkey+0x2a8/0x480
[ 6153.290282]  __x64_sys_mprotect+0x48/0x60
[ 6153.308993]  do_syscall_64+0xc8/0x5d8
[ 6153.326146] 
[ 6153.333065] Memory state around the buggy address:
[ 6153.355172]  ffff8884ac423f00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00
[ 6153.388572]  ffff8884ac423f80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00
[ 6153.422389] >ffff8884ac424000: fc fb fb fb fb fb fb fb fb fb fb fb fb fb fb
fb
[ 6153.456232]                                               ^
[ 6153.482324]  ffff8884ac424080: fb fb fb fb fb fb fb fb fb fb fc fc fc fc fc
fc
[ 6153.516323]  ffff8884ac424100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
fc
[ 6153.549993]
==================================================================
[ 6153.583892] Disabling lock debugging due to kernel taint
[ 6190.482570] general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
[ 6190.519596] CPU: 0 PID: 45144 Comm: signal06 Kdump: loaded Tainted:
G    B             5.1.0-rc7-next-20190430+ #8
[ 6190.568280] Hardware name: HP ProLiant XL420 Gen9/ProLiant XL420 Gen9, BIOS
U19 12/27/2015
[ 6190.605290] RIP: 0010:hugetlb_fault+0x46/0x920
[ 6190.625151] Code: 41 54 53 48 83 ec 48 48 89 7d c8 4c 89 ef 89 4d c4 48 89 55
a0 e8 aa 36 02 00 49 8b 9e a0 00 00 00 48 8d 7b 20 e8 9a 36 02 00 <48> 8b 5b 20
48 8d 7b 28 e8 8d 36 02 00 48 8b 5b 28 48 8d bb 40 06
[ 6190.711533] RSP: 0018:ffff8887c7bcf820 EFLAGS: 00010282
[ 6190.734963] RAX: 0000000000000000 RBX: 6b6b6b6b6b6b6b6b RCX: ffffffff8c33a376
[ 6190.767109] RDX: 0000000000000000 RSI: 0000000000000008 RDI: 6b6b6b6b6b6b6b8b
[ 6190.799329] RBP: ffff8887c7bcf890 R08: fffffbfff1b05102 R09: fffffbfff1b05101
[ 6190.831304] R10: fffffbfff1b05101 R11: ffffffff8d82880b R12: 0000000000000001
[ 6190.863311] R13: ffff8884ac4240a8 R14: ffff8884ac424008 R15: 0000000000629c80
[ 6190.895367] FS:  00007f8105646740(0000) GS:ffff888453400000(0000)
knlGS:0000000000000000
[ 6190.931839] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 6190.957598] CR2: 00007ff1a60018c0 CR3: 0000000834bd8002 CR4: 00000000001606b0
[ 6190.989654] Call Trace:
[ 6191.000738]  ? kasan_check_read+0x11/0x20
[ 6191.019852]  handle_mm_fault+0x313/0x360
[ 6191.040562]  __get_user_pages+0x448/0x7c0
[ 6191.059723]  ? follow_page_mask+0x3e0/0x3e0
[ 6191.078545]  ? lock_downgrade+0x300/0x300
[ 6191.096551]  ? __bad_area_nosemaphore+0x66/0x230
[ 6191.117323]  ? do_raw_spin_unlock+0xa8/0x140
[ 6191.136813]  __gup_longterm_locked+0x32c/0xa90
[ 6191.156738]  ? do_page_fault+0x4c/0x260
[ 6191.174016]  ? get_user_pages_unlocked+0x2b0/0x2b0
[ 6191.195529]  get_user_pages+0x60/0x70
[ 6191.212026]  copy_fpstate_to_sigframe+0x31a/0x670
[ 6191.233252]  ? __fpu__restore_sig+0x7a0/0x7a0
[ 6191.252704]  do_signal+0x40c/0x9d0
[ 6191.267912]  ? do_send_specific+0x87/0xe0
[ 6191.285864]  ? setup_sigcontext+0x280/0x280
[ 6191.304675]  ? check_kill_permission+0x8e/0x1c0
[ 6191.325007]  ? do_send_specific+0xa6/0xe0
[ 6191.343005]  ? do_tkill+0x125/0x160
[ 6191.358809]  ? signal_fault+0x160/0x160
[ 6191.376088]  exit_to_usermode_loop+0x9d/0xc0
[ 6191.395176]  do_syscall_64+0x470/0x5d8
[ 6191.412299]  ? syscall_return_slowpath+0xf0/0xf0
[ 6191.433590]  ? __do_page_fault+0x44d/0x5b0
[ 6191.452211]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 6191.474981] RIP: 0033:0x40377e
[ 6191.488761] Code: b4 00 00 00 0f 85 ae 00 00 00 89 c7 31 db ba c8 00 00 00 be
01 00 00 00 eb 0c 66 90 75 1d 81 fb 30 75 00 00 74 65 89 d0 0f 05 <f2> 0f 10 05
7a b8 21 00 83 c3 01 66 0f 2e c1 7b e1 31 c0 41 89 d8
[ 6191.578915] RSP: 002b:00007fff1fa13190 EFLAGS: 00000287 ORIG_RAX:
00000000000000c8
[ 6191.613071] RAX: 0000000000000000 RBX: 0000000000001e12 RCX: 000000000040377e
[ 6191.645339] RDX: 00000000000000c8 RSI: 0000000000000001 RDI: 000000000000b058
[ 6191.677764] RBP: 0000000000000000 R08: 0000000000000000 R09: 00007f8104e48700
[ 6191.709916] R10: fffffffffffff7a8 R11: 0000000000000287 R12: 00007f81056466c0
[ 6191.741996] R13: 00007fff1fa13360 R14: 0000000000000000 R15: 0000000000000000
[ 6191.774072] Modules linked in: brd vfat fat ext4 crc16 mbcache jbd2 overlay
loop kvm_intel kvm dax_pmem irqbypass dax_pmem_core ip_tables x_tables xfs
sd_mod igb i2c_algo_bit hpsa i2c_core scsi_transport_sas dm_mirror
dm_region_hash dm_log dm_mod

