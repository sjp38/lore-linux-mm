Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BA26C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 09:20:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30D2E217F9
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 09:20:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30D2E217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 822E96B0005; Fri, 24 May 2019 05:20:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AC806B0006; Fri, 24 May 2019 05:20:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EB1F6B0007; Fri, 24 May 2019 05:20:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 244156B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 05:20:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id 18so13264337eds.5
        for <linux-mm@kvack.org>; Fri, 24 May 2019 02:20:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=1Oep8B5Snw30NbcWJQ1nliRj5M0L7J6JDn7Mvw/k8Sc=;
        b=bx+vwX4VdYqDnKmW0VMFDyLhyhJR+WxIyXxPnxDv7cKtHgha2XqEPDXY2PfIr3G28a
         hglyVrE41zfWhauwolqDuvUPZux3Tq7LUL6LltWqQGWFL7W3o+mTTTTXO7H6Eev6wlMm
         qt/noz1VctEN2t4hpWM8NrFl7B4r/quuQ9pjS5DKcXrZxOk7skT+miH4Lkh/8ziFnymI
         EcJjwSAb3w1m9YV01Ug4OFIB2xlCly1IHjqDsMGh/tYhKAyhFYRbQ3NAYgKP2z4S+jeu
         kUKnCFGAmaQr7gEXWXWHFXYQ1MEqhYdPb3j/LZrBYzotWfPdVsLIkspvLbsP0W+wz8qr
         Kc0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of suzuki.poulose@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=suzuki.poulose@arm.com
X-Gm-Message-State: APjAAAXW9lJuNRuXsWxAed5wVICghoPoqCo0Q4ZdvISV7y5KUtbkC1BY
	08/YF864IZMNOpj7uimIsSr0oaIwJDSgts4zesNdRR3gBsMQIdUlRcHQQD++v8PUrj7gIpp86gG
	OoqJARGh04sVWBMqgjNKYOGhBB/5Zm3C//44CUv1Lzgo3unrQWQ288orgYBxDrrx//A==
X-Received: by 2002:a50:ec87:: with SMTP id e7mr102657138edr.126.1558689637481;
        Fri, 24 May 2019 02:20:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5irxhqgh1+9RuTZqdA4g9ep8wQdWXHaR/z2506UakGCgyyxnr63RT6GSUqkyDap2P/rJY
X-Received: by 2002:a50:ec87:: with SMTP id e7mr102657050edr.126.1558689636475;
        Fri, 24 May 2019 02:20:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558689636; cv=none;
        d=google.com; s=arc-20160816;
        b=OiYOGNntuPLqHMCu+7k6s0RJ75vHz9DdWldSysycRrRRhifF4BQgofQH8+tUHIgAwY
         iM4od26wEOjr7Kl4Uz0mzo1WOewMUgD5w2fNZMGSHdPw9NdR1wUdGHEU/mcScG73nzws
         GtQLxUKHeGYLgJ0dtCjgJRH5KM6ADYeLM47R84zq6FQ4izmILnFQcuaa8gBKcDhZ/Hkd
         3pt1TSs4LOGdaRY/k16D5XQvnTXreTPUUNRQgm0o+xlWlFrwjv9Y2ER6uMo0B+lPbleZ
         5lGhXXhy5Xdyz17Zcjmhw+ocbtpi0AK7qKE9CskoGpnozejoGPMcgV+emFTb+vNQ6kci
         bFYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=1Oep8B5Snw30NbcWJQ1nliRj5M0L7J6JDn7Mvw/k8Sc=;
        b=BO5LeCP0Uli45CvzteQTjnrgBiTGnNP+D5vacIAGcWDx9Y6XDe5Csjba+/I4cVCAYZ
         xwImtewhWe3pUYQlZSJISJUoCuCDVZiK/QhID0fLaihfshR7wcyddNfYjRHb2qeTcEPP
         +dHPgjQBHTt72bd9LdIvNu7xLRZeGz44VEZgnvPfIfSdEcBNnQixhG680YB4wz6dr+Dj
         SD2NL9tlh2hFAwnT5f8RlW6ISnQ8rPy5wxvMM5cYxXuAGW0/aQNHU/rbe91TV1O+acV6
         wx7LTLUtUsp48NgnNUPZyKWcs0i6OMsTYJX7wojcc6aFkc5/9dZFJyQiRRfY2UQEvjMp
         UFJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of suzuki.poulose@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=suzuki.poulose@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v3si1365621eju.281.2019.05.24.02.20.35
        for <linux-mm@kvack.org>;
        Fri, 24 May 2019 02:20:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of suzuki.poulose@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of suzuki.poulose@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=suzuki.poulose@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 10AE7A78;
	Fri, 24 May 2019 02:20:35 -0700 (PDT)
Received: from en101.cambridge.arm.com (en101.cambridge.arm.com [10.1.196.93])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 407523F703;
	Fri, 24 May 2019 02:20:33 -0700 (PDT)
From: Suzuki K Poulose <suzuki.poulose@arm.com>
To: linux-mm@kvack.org
Cc: mgorman@techsingularity.net,
	akpm@linux-foundation.org,
	mhocko@suse.com,
	cai@lca.pw,
	linux-kernel@vger.kernel.org,
	marc.zyngier@arm.com,
	kvmarm@lists.cs.columbia.edu,
	kvm@vger.kernel.org,
	Suzuki K Poulose <suzuki.poulose@arm.com>
Subject: mm/compaction: BUG: NULL pointer dereference
Date: Fri, 24 May 2019 10:20:19 +0100
Message-Id: <1558689619-16891-1-git-send-email-suzuki.poulose@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

We are hitting NULL pointer dereferences while running stress tests with KVM.
See splat [0]. The test is to spawn 100 VMs all doing standard debian
installation (Thanks to Marc's automated scripts, available here [1] ).
The problem has been reproduced with a better rate of success from 5.1-rc6
onwards.

The issue is only reproducible with swapping enabled and the entire
memory is used up, when swapping heavily. Also this issue is only reproducible
on only one server with 128GB, which has the following memory layout:

[32GB@4GB, hole , 96GB@544GB]

Here is my non-expert analysis of the issue so far.

Under extreme memory pressure, the kswapd could trigger reset_isolation_suitable()
to figure out the cached values for migrate/free pfn for a zone, by scanning through
the entire zone. On our server it does so in the range of [ 0x10_0000, 0xa00_0000 ],
with the following area of holes : [ 0x20_0000, 0x880_0000 ].
In the failing case, we end up setting the cached migrate pfn as : 0x508_0000, which
is right in the center of the zone pfn range. i.e ( 0x10_0000 + 0xa00_0000 ) / 2,
with reset_migrate = 0x88_4e00, reset_free = 0x10_0000.

Now these cached values are used by the fast_isolate_freepages() to find a pfn. However,
since we cant find anything during the search we fall back to using the page belonging
to the min_pfn (which is the migrate_pfn), without proper checks to see if that is valid
PFN or not. This is then passed on to fast_isolate_around() which tries to do :
set_pageblock_skip(page) on the page which blows up due to an NULL mem_section pointer.

The following patch seems to fix the issue for me, but I am not quite convinced that
it is the right fix. Thoughts ?


diff --git a/mm/compaction.c b/mm/compaction.c
index 9febc8c..9e1b9ac 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1399,7 +1399,7 @@ fast_isolate_freepages(struct compact_control *cc)
 				page = pfn_to_page(highest);
 				cc->free_pfn = highest;
 			} else {
-				if (cc->direct_compaction) {
+				if (cc->direct_compaction && pfn_valid(min_pfn)) {
 					page = pfn_to_page(min_pfn);
 					cc->free_pfn = min_pfn;
 				}


Suzuki


[ 0 ] Kernel splat
 Unable to handle kernel NULL pointer dereference at virtual address 0000000000000008 [47/1825]
 Mem abort info:
   ESR = 0x96000004
   Exception class = DABT (current EL), IL = 32 bits
   SET = 0, FnV = 0
   EA = 0, S1PTW = 0
 Data abort info:
   ISV = 0, ISS = 0x00000004
   CM = 0, WnR = 0
 user pgtable: 4k pages, 48-bit VAs, pgdp = 0000000082f94ae9
 [0000000000000008] pgd=0000000000000000
 Internal error: Oops: 96000004 [#1] SMP
 ...
 CPU: 10 PID: 6080 Comm: qemu-system-aar Not tainted 510-rc1+ #6
 Hardware name: AmpereComputing(R) OSPREY EV-883832-X3-0001/OSPREY, BIOS 4819 09/25/2018
 pstate: 60000005 (nZCv daif -PAN -UAO)
 pc : set_pfnblock_flags_mask+0x58/0xe8
 lr : compaction_alloc+0x300/0x950
 sp : ffff00001fc03010
 x29: ffff00001fc03010 x28: 0000000000000000 
 x27: 0000000000000000 x26: ffff000010bf7000 
 x25: 0000000006445000 x24: 0000000006444e00 
 x23: ffff7e018f138000 x22: 0000000000000003 
 x21: 0000000000000001 x20: 0000000006444e00 
 x19: 0000000000000001 x18: 0000000000000000 
 x17: 0000000000000000 x16: ffff809f7fe97268 
 x15: 0000000191138000 x14: 0000000000000000 
 x13: 0000000000000070 x12: 0000000000000000 
 x11: ffff00001fc03108 x10: 0000000000000000 
 x9 : 0000000009222400 x8 : 0000000000000187 
 x7 : 00000000063c4e00 x6 : 0000000006444e00 
 x5 : 0000000000080000 x4 : 0000000000000001 
 x3 : 0000000000000003 x2 : ffff809f7fe92840 
 x1 : 0000000000000220 x0 : 0000000000000000 
 Process qemu-system-aar (pid: 6080, stack limit = 0x0000000095070da5)
 Call trace:
  set_pfnblock_flags_mask+0x58/0xe8
  compaction_alloc+0x300/0x950
  migrate_pages+0x1a4/0xbb0
  compact_zone+0x750/0xde8
  compact_zone_order+0xd8/0x118
  try_to_compact_pages+0xb4/0x290
  __alloc_pages_direct_compact+0x84/0x1e0
  __alloc_pages_nodemask+0x5e0/0xe18
  alloc_pages_vma+0x1cc/0x210
  do_huge_pmd_anonymous_page+0x108/0x7c8
  __handle_mm_fault+0xdd4/0x1190
  handle_mm_fault+0x114/0x1c0
  __get_user_pages+0x198/0x3c0
  get_user_pages_unlocked+0xb4/0x1d8
  __gfn_to_pfn_memslot+0x12c/0x3b8
  gfn_to_pfn_prot+0x4c/0x60
  kvm_handle_guest_abort+0x4b0/0xcd8
  handle_exit+0x140/0x1b8
  kvm_arch_vcpu_ioctl_run+0x260/0x768
  kvm_vcpu_ioctl+0x490/0x898
  do_vfs_ioctl+0xc4/0x898
  ksys_ioctl+0x8c/0xa0
  __arm64_sys_ioctl+0x28/0x38
  el0_svc_common+0x74/0x118
  el0_svc_handler+0x38/0x78
  el0_svc+0x8/0xc
 Code: f8607840 f100001f 8b011401 9a801020 (f9400400) 
 ---[ end trace af6a35219325a9b6 ]---


[1] https://git.kernel.org/pub/scm/linux/kernel/git/maz/vminstall.git/

