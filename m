Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,
	UPPERCASE_50_75 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4839EC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 14:55:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A27120693
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 14:55:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A27120693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCCB26B0299; Wed, 10 Apr 2019 10:55:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7BC46B029A; Wed, 10 Apr 2019 10:55:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B0C296B029B; Wed, 10 Apr 2019 10:55:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3BDCF6B0299
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 10:55:34 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d1so2100109pgk.21
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 07:55:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:user-agent:mime-version;
        bh=VHsE7DO5j3TIT+r4IrPLZrTe7SMSJy5IRivkjgB8Q9U=;
        b=JFF/GzlCQGAXjFxzl6in2HiD2D5wdCtxTgv4Ygr6X4BjyNSVZWVfzoPzK77wJfCYHg
         AWwX4TQCFrmigDONf3g2/8UL+WJDi878E0nEa765+GRx47LDUHgY7loq71Tsnkvgzbdb
         qBq5tOeGg/DOdrVWfxDPbSl6RGz6uBcysQrSnZwPFTNPiItFANLhM+aDsJdZSBQLsmMN
         6dNGlknLmF7UtITkSMqCNTYKpS1C1WQaE0Q3m7199OkktOVbiki6992i1AE6QYhHnKq/
         vM6aTH0lLfGm6cjrTaQb84GQMoXdjFCmQRbBtPNT4S7nCiKAP1tqAxLwsa78jkbavJ9E
         L0nw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUZnc9OhC/UfYojii0iR7Kh520kZasQVShjh8ynetZS/Et2zqSh
	mXqjXGTZ0ZcqhBCU3NdM6b5+k3skzEGPkSVO+dR9xDn3XWnr1e9Bh+zQKKyutIPZ7GqZoxrWbGB
	3YPaTG6V/xtURCsI1WY9dsUDgLQ+b1ksTHeFu6EQqXAUlv15jisEHI9OMyjC6uRsEuA==
X-Received: by 2002:a62:305:: with SMTP id 5mr43534317pfd.65.1554908130695;
        Wed, 10 Apr 2019 07:55:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzimbwQ9AeVC6e03DUz/7uFzgcyyUIcEbTXV50vjmhQ03RHx1NOwgJaMtMz7a/mrCigcibK
X-Received: by 2002:a62:305:: with SMTP id 5mr43534139pfd.65.1554908128284;
        Wed, 10 Apr 2019 07:55:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554908128; cv=none;
        d=google.com; s=arc-20160816;
        b=qFO6qvAiuPcqzYymHojRrV/rotPqzI4OY5RQrLgp2In/D7hR3EF0ycN0PrMUb2NGO5
         j0MHDNZ42iEP4YZuFBhkKSW9jpw+dHjWywTcGij1sEM2ifM5AAtqe2woQehC0eV9N2Vh
         iKCAKcngiOCWBZOhBA8YreWtqvMx9zrLzgQ7JPjTEmegXTRiyzMOeSKdGm7Y6Pf1mnYV
         RGEHndIY/1fjuKdE0b2KJyXY+7oNpNMsE9fBLpvreEYrLko+6+5HRqJ+PnXoVTpMsPzy
         36AuHsMhmtiLaTh93d+ibKZuWGirPNXWOW5qxvV2/HBhlorH7bzVzAH+apQgDvhbS9yt
         qq+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:subject:cc:to:from:date;
        bh=VHsE7DO5j3TIT+r4IrPLZrTe7SMSJy5IRivkjgB8Q9U=;
        b=Xi0WSsAeqPFpShVWctglqaO4SPDlD3OyaQbNQvGVP9d8WOrASxL0hkuY8UTIaNfxaS
         GNIjL9+ZO0bAtQqZcgxKFiwzrgHmpva4jg/Q3LeRETp0PZT1e8MhoUJg6KiET2P2FrSq
         TOlluU8QwLIOHauSjAewmI39pGpUm2UTyaQAiHBppSkR5OtPt8VjtHMPiify068qYaJe
         5IIvPa8ZltzCXZKM7GlZT6A78ZaF+aDuGTNVQ5SZQJULnwxSZtjeTmEUOs3JTamlVQnz
         QiWMIXrgGRCNKV8c1/YzpvDCpgdbfBeWBe2/8CoK7gqUb3J5MbNrPaWcykNpeBpgVXQF
         yalA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id u70si22005830pgu.119.2019.04.10.07.55.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 07:55:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Apr 2019 07:55:27 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,332,1549958400"; 
   d="gz'50?scan'50,208,50";a="159977158"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by fmsmga002.fm.intel.com with ESMTP; 10 Apr 2019 07:55:24 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hEEdH-000837-HF; Wed, 10 Apr 2019 22:55:23 +0800
Date: Wed, 10 Apr 2019 22:55:00 +0800
From: kernel test robot <lkp@intel.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: LKP <lkp@01.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-arch@vger.kernel.org, Ingo Molnar <mingo@kernel.org>
Subject: 1808d65b55 ("asm-generic/tlb: Remove arch_tlb*_mmu()"):  BUG:
 KASAN: stack-out-of-bounds in __change_page_attr_set_clr
Message-ID: <5cae03c4.iIPk2cWlfmzP0Zgy%lkp@intel.com>
User-Agent: Heirloom mailx 12.5 6/20/10
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_5cae03c4.pZ1fFpRFLxwqetjY3Bjgi2GHnZwA46345mT2xZX1gF8H0QcA"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

--=_5cae03c4.pZ1fFpRFLxwqetjY3Bjgi2GHnZwA46345mT2xZX1gF8H0QcA
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git core/mm

commit 1808d65b55e4489770dd4f76fb0dff5b81eb9b11
Author:     Peter Zijlstra <peterz@infradead.org>
AuthorDate: Thu Sep 20 10:50:11 2018 +0200
Commit:     Ingo Molnar <mingo@kernel.org>
CommitDate: Wed Apr 3 10:32:58 2019 +0200

    asm-generic/tlb: Remove arch_tlb*_mmu()
    
    Now that all architectures are converted to the generic code, remove
    the arch hooks.
    
    No change in behavior intended.
    
    Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
    Acked-by: Will Deacon <will.deacon@arm.com>
    Cc: Andrew Morton <akpm@linux-foundation.org>
    Cc: Andy Lutomirski <luto@kernel.org>
    Cc: Borislav Petkov <bp@alien8.de>
    Cc: Dave Hansen <dave.hansen@linux.intel.com>
    Cc: H. Peter Anvin <hpa@zytor.com>
    Cc: Linus Torvalds <torvalds@linux-foundation.org>
    Cc: Peter Zijlstra <peterz@infradead.org>
    Cc: Rik van Riel <riel@surriel.com>
    Cc: Thomas Gleixner <tglx@linutronix.de>
    Signed-off-by: Ingo Molnar <mingo@kernel.org>

9de7d833e3  s390/tlb: Convert to generic mmu_gather
1808d65b55  asm-generic/tlb: Remove arch_tlb*_mmu()
6455959819  ia64/tlb: Eradicate tlb_migrate_finish() callback
31437a258f  Merge branch 'perf/urgent'
+------------------------------------------------------------+------------+------------+------------+------------+
|                                                            | 9de7d833e3 | 1808d65b55 | 6455959819 | 31437a258f |
+------------------------------------------------------------+------------+------------+------------+------------+
| boot_successes                                             | 0          | 0          | 0          | 0          |
| boot_failures                                              | 44         | 11         | 11         | 11         |
| BUG:KASAN:stack-out-of-bounds_in__unwind_start             | 44         |            |            |            |
| BUG:KASAN:stack-out-of-bounds_in__change_page_attr_set_clr | 0          | 11         | 11         | 11         |
+------------------------------------------------------------+------------+------------+------------+------------+

[   13.977997] rodata_test: all tests were successful
[   13.979792] x86/mm: Checking user space page tables
[   14.011779] x86/mm: Checked W+X mappings: passed, no W+X pages found.
[   14.013022] Run /init as init process
[   14.015154] ==================================================================
[   14.016489] BUG: KASAN: stack-out-of-bounds in __change_page_attr_set_clr+0xa8/0x4df
[   14.017853] Read of size 8 at addr ffff8880191ef8b0 by task init/1
[   14.018976] 
[   14.019259] CPU: 0 PID: 1 Comm: init Not tainted 5.1.0-rc3-00029-g1808d65 #3
[   14.020509] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[   14.022028] Call Trace:
[   14.022471]  print_address_description+0x9d/0x26b
[   14.023295]  ? __change_page_attr_set_clr+0xa8/0x4df
[   14.024161]  ? __change_page_attr_set_clr+0xa8/0x4df
[   14.025031]  kasan_report+0x145/0x18a
[   14.025667]  ? __change_page_attr_set_clr+0xa8/0x4df
[   14.026542]  __change_page_attr_set_clr+0xa8/0x4df
[   14.027433]  ? __change_page_attr+0xad0/0xad0
[   14.028260]  ? kasan_unpoison_shadow+0xf/0x2e
[   14.029062]  ? preempt_latency_start+0x22/0x68
[   14.029962]  ? get_page_from_freelist+0xf37/0x1281
[   14.030796]  ? native_flush_tlb_one_user+0x54/0x95
[   14.031602]  ? trace_tlb_flush+0x1f/0x106
[   14.032352]  ? flush_tlb_func_common+0x26a/0x289
[   14.033322]  ? trace_irq_enable_rcuidle+0x21/0xf5
[   14.034109]  __kernel_map_pages+0x148/0x1b1
[   14.034777]  ? set_pages_rw+0x94/0x94
[   14.035408]  ? flush_tlb_mm_range+0x161/0x1ae
[   14.036134]  ? atomic_read+0xe/0x3f
[   14.036715]  ? page_expected_state+0x46/0x81
[   14.037442]  free_unref_page_prepare+0xe1/0x192
[   14.038201]  free_unref_page_list+0xd3/0x319
[   14.038960]  release_pages+0x5d1/0x612
[   14.039581]  ? __put_compound_page+0x91/0x91
[   14.040346]  ? tlb_flush_mmu_tlbonly+0x107/0x1c5
[   14.041193]  ? preempt_latency_start+0x22/0x68
[   14.041922]  ? free_swap_cache+0x51/0xd5
[   14.042566]  tlb_flush_mmu_free+0x31/0xca
[   14.043254]  tlb_finish_mmu+0xf6/0x1b5
[   14.043883]  shift_arg_pages+0x280/0x30b
[   14.044535]  ? __register_binfmt+0x18d/0x18d
[   14.045259]  ? trace_irq_enable_rcuidle+0x21/0xf5
[   14.046029]  ? ___might_sleep+0xac/0x33e
[   14.046666]  setup_arg_pages+0x46a/0x56e
[   14.047347]  ? shift_arg_pages+0x30b/0x30b
[   14.048208]  load_elf_binary+0x888/0x20dd
[   14.048872]  ? _raw_read_unlock+0x14/0x24
[   14.049532]  ? ima_bprm_check+0x18c/0x1c2
[   14.050199]  ? elf_map+0x1e8/0x1e8
[   14.050756]  ? ima_file_mmap+0xf3/0xf3
[   14.051583]  search_binary_handler+0x154/0x511
[   14.052323]  __do_execve_file+0x10b5/0x15e9
[   14.053004]  ? open_exec+0x3a/0x3a
[   14.053564]  ? memcpy+0x34/0x46
[   14.054095]  ? rest_init+0xdd/0xdd
[   14.054669]  kernel_init+0x66/0x10d
[   14.055262]  ? rest_init+0xdd/0xdd
[   14.055833]  ret_from_fork+0x3a/0x50
[   14.056516] 
[   14.056769] The buggy address belongs to the page:
[   14.057552] page:ffff88801de82c48 count:0 mapcount:0 mapping:0000000000000000 index:0x0
[   14.058923] flags: 0x680000000000()
[   14.059495] raw: 0000680000000000 ffff88801de82c50 ffff88801de82c50 0000000000000000

                                                          # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
git bisect start 73f7e0e993d885606124134bd88c4c0e6b8b45bd 15ade5d2e7775667cf191cf2f94327a4889f8b9d --
git bisect  bad 9b748775c7b377ae207813cb9ecdb0153b74ca55  # 17:54  B      0     9   24   0  Merge 'hwmon/hwmon' into devel-hourly-2019040920
git bisect  bad a891bf73affea7bf5e4a7ef78b23b1c3f5b29d58  # 18:05  B      0    11   26   0  Merge 'linux-review/Heiner-Kallweit/net-phy-switch-drivers-to-use-dynamic-feature-detection/20190408-065213' into devel-hourly-2019040920
git bisect good 7ccb8fbbe4f0de58aeaac0f783d926a091de2942  # 18:18  G     11     0   11  11  Merge 'brgl-linux/gpio/for-next' into devel-hourly-2019040920
git bisect  bad 081419eb685d308d93e12e1ddea3d02bfa52c0a4  # 18:33  B      0     4   19   0  Merge 'csky-linux/linux-next' into devel-hourly-2019040920
git bisect good 95041a63b3167fdc27aa36ef3b54daeeff12bdae  # 18:52  G     11     0   11  11  Merge 'linux-review/Ido-Schimmel/mlxsw-Add-support-for-devlink-info-command/20190408-210315' into devel-hourly-2019040920
git bisect good 404993d745381524b38243176df8f1a11dd99d3b  # 19:14  G     11     0   11  11  Merge 'linux-review/Simon-Horman/ravb-Avoid-unsupported-internal-delay-mode-for-R-Car-E3-D3/20190408-204324' into devel-hourly-2019040920
git bisect good 8cad949760cbcba41a6981993d0c65b4604a9e18  # 19:31  G     11     0   11  11  Merge 'gfs2/for-next.glock-refcount' into devel-hourly-2019040920
git bisect good 2c0d83617d30e6e747067a08e48a0e2de7404aa2  # 19:43  G     11     0   11  11  Merge 'pinctrl/devel' into devel-hourly-2019040920
git bisect good 14fb0415d4eba1e4f63efc98d4b3f1b8ceea047f  # 19:57  G     11     0   11  11  Merge 'linux-review/Kristian-Evensen/qmi_wwan-Add-quirk-for-Quectel-dynamic-config/20190408-073833' into devel-hourly-2019040920
git bisect  bad 8e115919d3366790a875d7dfad33bcb7009a957d  # 20:10  B      0     1   16   0  Merge 'tip/master' into devel-hourly-2019040920
git bisect  bad 9402fa854486829a7792fbb4038b5585473f3b1a  # 20:31  B      0     8   23   0  Merge branch 'perf/urgent'
git bisect good 2e8623e9bc0ba4907e94c4d94a1caeac23d1fadb  # 20:44  G     11     0   11  11  Merge branch 'linus'
git bisect good 64604d54d3115fee89598bfb6d8d2252f8a2d114  # 20:54  G     11     0   11  11  sched/x86_64: Don't save flags on context switch
git bisect  bad b3fa8ed4e48802e6ba0aa5f3283313a27dcbf46f  # 21:04  B      0    11   26   0  asm-generic/tlb: Remove CONFIG_HAVE_GENERIC_MMU_GATHER
git bisect good b78180b97dcf667350aac716cd3f32356eaf4984  # 21:20  G     11     0   11  11  arm/tlb: Convert to generic mmu_gather
git bisect good 6137fed0823247e32306bde2b48cac627c24f894  # 21:30  G     11     0   11  11  arch/tlb: Clean up simple architectures
git bisect good 9de7d833e3708213bf99d75c37483e0f773f5e16  # 21:43  G     11     0   11  11  s390/tlb: Convert to generic mmu_gather
git bisect  bad 1808d65b55e4489770dd4f76fb0dff5b81eb9b11  # 21:52  B      0    11   26   0  asm-generic/tlb: Remove arch_tlb*_mmu()
# first bad commit: [1808d65b55e4489770dd4f76fb0dff5b81eb9b11] asm-generic/tlb: Remove arch_tlb*_mmu()
git bisect good 9de7d833e3708213bf99d75c37483e0f773f5e16  # 21:53  G     33     0   33  44  s390/tlb: Convert to generic mmu_gather
# extra tests with debug options
git bisect  bad 1808d65b55e4489770dd4f76fb0dff5b81eb9b11  # 22:07  B      0     1   16   0  asm-generic/tlb: Remove arch_tlb*_mmu()
# extra tests on HEAD of linux-devel/devel-hourly-2019040920
git bisect  bad 73f7e0e993d885606124134bd88c4c0e6b8b45bd  # 22:13  B      0    13   31   0  0day head guard for 'devel-hourly-2019040920'
# extra tests on tree/branch tip/core/mm
git bisect  bad 6455959819bf2469190ae9f6b4ccebaa9827e884  # 22:37  B      0     4   19   0  ia64/tlb: Eradicate tlb_migrate_finish() callback
# extra tests on tree/branch tip/master
git bisect  bad 31437a258fa637d7449385ef2e1b33efc6786397  # 22:54  B      0    11   26   0  Merge branch 'perf/urgent'

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--=_5cae03c4.pZ1fFpRFLxwqetjY3Bjgi2GHnZwA46345mT2xZX1gF8H0QcA
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-quantal-vm-quantal-217:20190410215134:x86_64-randconfig-s3-04092154:5.1.0-rc3-00029-g1808d65:3.gz"

H4sICKsDrlwAA2RtZXNnLXF1YW50YWwtdm0tcXVhbnRhbC0yMTc6MjAxOTA0MTAyMTUxMzQ6
eDg2XzY0LXJhbmRjb25maWctczMtMDQwOTIxNTQ6NS4xLjAtcmMzLTAwMDI5LWcxODA4ZDY1
OjMA7Ftbc9s4sn7e/Iqu2oe1z1oSAV6hKm0dXxOVI0djOZk5m0qpKBKUuaZIDi+ONb/+dIOi
SN0se/act1UlFi/dHxoNdKO7AUk3i5bgJXGeRBLCGHJZlCk+8OUHuf1OvhSZ6xXTJ5nFMvoQ
xmlZTH23cPugvWj1x9B8zj1n9TqS8cZbbaZrjmt8SMoCX2+8YtXX6tUOp6553OHah6r1aZEU
bjTNwz/kJpXHLQJBSRdpEoWxnOp8Fm62pGnCJ6IPV9JLFmkm8zyM5/A5jMuXbrcLYzdTD64/
39Ctn8Sy++EiSQp6WDxKqGTofvgO+NG6FeaPCgCeJXInMZhd1tU6mad38CUXnTlzNMe3TDh5
mpVh5P939JR2fuaLjkzZKZzMPW/Nanf1rgYnV3IWuqu7Djs9hb/qML6/vh6NH+BX6cN5mgHT
gLO+4fS5BpeTB+AaE9tyXSaLhRv7QOroQ4YdGfR8+dxDHWnwWMbzaeHmT9PUjUNvwMCXs3IO
boo31WW+zLPfp270013mUxm7swgbz7wyxcGXXbyYemk5zXFAcFzChcQRHOBoQiyLbhjE7kLm
Aw3SLIyLpy42/LTI5wPsZtVgh0GeBEWUeE9luhYiXoTTn27hPfrJfKAeQpKk+eoySlx/iuL7
Yf404AiNw1isH2jgZzO/uwjjJJt6SRkXA4c6UciF342SOc6tZxkNZJZBOEcaOcWH6lk93QdF
sdRAWUAlNj2YaGeMmRw71qJqHj7P3QGCLdwIsp+k66dBz5PpY5D3qgHvZWXc+b2Upez9Xrox
qqvzvOisLnsvjjW1jE6GA4XwQTjv5DhzDE1wZhq9iKZWxycZ++pv5zEpUboOjbei0vqr+TUz
TWkYjrBtzfeNwLaCmeYHgTlzmJyJGWP9WZhLr+hUmKLXfV7Q5R+dtwKsGmUaiqaZVodp/d0O
dTizYYbd8R4HLel7B6SHiy9fHqbD0fnH60EvfZpXPT6iFbSZjt17q9i9up8HLXPPtKFpLrOg
mz+WhZ/8jAfatnXdXt/fXX+GvEzTJCvQMtAY8v42FcD56ArOS3QfcRF6eLNL8Wk5R6tQfz/K
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
0+ve/wC1HIbS57AAAA==

--=_5cae03c4.pZ1fFpRFLxwqetjY3Bjgi2GHnZwA46345mT2xZX1gF8H0QcA
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-quantal-vm-quantal-101:20190410215248:x86_64-randconfig-s3-04092154:5.1.0-rc3-00028-g9de7d83:1.gz"

H4sICJoDrlwAA2RtZXNnLXF1YW50YWwtdm0tcXVhbnRhbC0xMDE6MjAxOTA0MTAyMTUyNDg6
eDg2XzY0LXJhbmRjb25maWctczMtMDQwOTIxNTQ6NS4xLjAtcmMzLTAwMDI4LWc5ZGU3ZDgz
OjEA7Ftbc+M4rn7e/hWo2odNdmNbpK50lbdOrt2uxIknTvfMOV0plyxRjjaypNElHfevX4Cy
LfkWJ7N73iZV3boBH0ESAAGQlm4WzcFL4jyJJIQx5LIoU3zhy09y85t8LTLXK8bPMotl9CmM
07IY+27hdkF71ZZ/huYz7jmLz5GM175qE51xXfuUlAV+XvvEqsvi0xanrnnc4dqnqvVxkRRu
NM7Dn3KdyuMWgaCkszSJwliOdT4J11vSNOET0acL6SWzNJN5HsZTuAnj8rXdbsPQzdSLy5sr
evSTWLY/nSVJQS+LJwmVDO1P3wH/tHaF+VgBwItE7iQGs83aWivz9BZ+5E5rKnxp+44OR8+T
Moz8/4me09aPfNaSKT+Go6nnrVjttt7W4OhCTkJ38dRix8fwVwbD+8vLwfABfpU+nKYZMA04
6+pml1twPnoArjGxKdd5Mpu5sQ80HF3IsCO9ji9fOjhGGjyV8XRcuPnzOHXj0Osx8OWknIKb
4kN1m8/z7PexG/1w5/lYxu4kwsYzr0xx8mUbb8ZeWo5znBCcl3AmcQZ7OJsQy6IdBrE7k3lP
gzQL4+K5jQ0/z/JpD7tZNdhikCdBESXec5muhIhn4fiHW3hPfjLtqZeQJGm+uI0S1x+j+H6Y
P/c4QuM0FqsXGvjZxG/PwjjJxl5SxkXPoU4Ucua3o2SKuvUio57MMginSCPH+FK9W6p7ryjm
GigLqMSmFyPthDGTY8caVPXLl6nbQ7CZG0H2g8b6udfxZPoU5J1qwjtZGbd+L2UpO7+XbozD
1XqZtRa3nVfHGltGK8OJQvggnLZy1BxDE5yZRici1Wr5JGNX/d96SkqUrkXzrai07kK/dKnb
msOZPgmE8G3T023D0aUW2LYemJJZ3UmYS69oVZii036Z0e3P1nsBFo0yDUXjzGjpvLvdoRbT
GEywO95TryF9Z4/0cHZ39zDuD04/X/Y66fO06vGBUUGbadmd94rdWfZzr2XuUBtSc5kF7fyp
LPzkR9zTNq3r+vL+9vIG8jJNk6xAy0BjyLubVACngws4LdF9xEXo4cM2xZf5FK1C/f9ZxiVa
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
AA==

--=_5cae03c4.pZ1fFpRFLxwqetjY3Bjgi2GHnZwA46345mT2xZX1gF8H0QcA
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="reproduce-quantal-vm-quantal-217:20190410215134:x86_64-randconfig-s3-04092154:5.1.0-rc3-00029-g1808d65:3"

#!/bin/bash

kernel=$1
initrd=quantal-trinity-x86_64.cgz

wget --no-clobber https://download.01.org/0day-ci/lkp-qemu/osimage/quantal/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu kvm64
	-kernel $kernel
	-initrd $initrd
	-m 512
	-smp 2
	-device e1000,netdev=net0
	-netdev user,id=net0
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-watchdog-action debug
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null
)

append=(
	root=/dev/ram0
	hung_task_panic=1
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	net.ifnames=0
	printk.devkmsg=on
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	drbd.minor_count=8
	systemd.log_level=err
	ignore_loglevel
	console=tty0
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	vga=normal
	rw
	drbd.minor_count=8
	rcuperf.shutdown=0
)

"${kvm[@]}" -append "${append[*]}"

--=_5cae03c4.pZ1fFpRFLxwqetjY3Bjgi2GHnZwA46345mT2xZX1gF8H0QcA
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="config-5.1.0-rc3-00029-g1808d65"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 5.1.0-rc3 Kernel Configuration
#

#
# Compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
#
CONFIG_CC_IS_GCC=y
CONFIG_GCC_VERSION=70300
CONFIG_CLANG_VERSION=0
CONFIG_CC_HAS_ASM_GOTO=y
CONFIG_CC_HAS_WARN_MAYBE_UNINITIALIZED=y
CONFIG_CC_DISABLE_WARN_MAYBE_UNINITIALIZED=y
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_BUILD_SALT=""
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
# CONFIG_USELIB is not set
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_SIM=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_MSI_IRQ=y
CONFIG_GENERIC_MSI_IRQ_DOMAIN=y
CONFIG_GENERIC_IRQ_MATRIX_ALLOCATOR=y
CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_GENERIC_IRQ_DEBUGFS=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_ARCH_CLOCKSOURCE_INIT=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
# CONFIG_NO_HZ is not set
# CONFIG_HIGH_RES_TIMERS is not set
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
CONFIG_IRQ_TIME_ACCOUNTING=y
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
# CONFIG_TASKSTATS is not set
# CONFIG_PSI is not set

#
# RCU Subsystem
#
CONFIG_PREEMPT_RCU=y
CONFIG_RCU_EXPERT=y
CONFIG_SRCU=y
CONFIG_TREE_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_NEED_SEGCBLIST=y
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
CONFIG_RCU_BOOST=y
CONFIG_RCU_BOOST_DELAY=500
# CONFIG_RCU_NOCB_CPU is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
# CONFIG_MEMCG is not set
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_RT_GROUP_SCHED=y
# CONFIG_CGROUP_PIDS is not set
CONFIG_CGROUP_RDMA=y
CONFIG_CGROUP_FREEZER=y
# CONFIG_CGROUP_HUGETLB is not set
# CONFIG_CGROUP_DEVICE is not set
CONFIG_CGROUP_CPUACCT=y
CONFIG_CGROUP_PERF=y
# CONFIG_CGROUP_DEBUG is not set
# CONFIG_NAMESPACES is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
# CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
# CONFIG_SYSFS_SYSCALL is not set
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_FHANDLE=y
# CONFIG_POSIX_TIMERS is not set
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
# CONFIG_PCSPKR_PLATFORM is not set
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_FUTEX_PI=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
# CONFIG_EVENTFD is not set
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_IO_URING=y
# CONFIG_ADVISE_SYSCALLS is not set
CONFIG_MEMBARRIER=y
CONFIG_KALLSYMS=y
# CONFIG_KALLSYMS_ALL is not set
CONFIG_KALLSYMS_BASE_RELATIVE=y
# CONFIG_BPF_SYSCALL is not set
CONFIG_USERFAULTFD=y
CONFIG_ARCH_HAS_MEMBARRIER_SYNC_CORE=y
# CONFIG_RSEQ is not set
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PC104=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
# CONFIG_VM_EVENT_COUNTERS is not set
# CONFIG_COMPAT_BRK is not set
CONFIG_SLAB=y
# CONFIG_SLUB is not set
# CONFIG_SLOB is not set
# CONFIG_SLAB_MERGE_DEFAULT is not set
CONFIG_SLAB_FREELIST_RANDOM=y
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=28
CONFIG_ARCH_MMAP_RND_BITS_MAX=32
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_FILTER_PGPROT=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_KASAN_SHADOW_OFFSET=0xdffffc0000000000
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_DYNAMIC_PHYSICAL_MASK=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_CC_HAS_SANE_STACKPROTECTOR=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
# CONFIG_SMP is not set
CONFIG_X86_FEATURE_NAMES=y
# CONFIG_X86_X2APIC is not set
CONFIG_X86_MPPARSE=y
# CONFIG_GOLDFISH is not set
CONFIG_RETPOLINE=y
CONFIG_X86_CPU_RESCTRL=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_MID is not set
CONFIG_X86_INTEL_LPSS=y
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=y
CONFIG_IOSF_MBI_DEBUG=y
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_PVH is not set
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_JAILHOUSE_GUEST is not set
# CONFIG_MK8 is not set
CONFIG_MPSC=y
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
# CONFIG_GENERIC_CPU is not set
CONFIG_X86_INTERNODE_CACHE_SHIFT=7
CONFIG_X86_L1_CACHE_SHIFT=7
CONFIG_X86_P6_NOP=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_PROCESSOR_SELECT=y
# CONFIG_CPU_SUP_INTEL is not set
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_HYGON=y
# CONFIG_CPU_SUP_CENTAUR is not set
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
CONFIG_CALGARY_IOMMU=y
# CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT is not set
CONFIG_NR_CPUS_RANGE_BEGIN=1
CONFIG_NR_CPUS_RANGE_END=1
CONFIG_NR_CPUS_DEFAULT=1
CONFIG_NR_CPUS=1
CONFIG_UP_LATE_INIT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
# CONFIG_X86_MCELOG_LEGACY is not set
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
# CONFIG_X86_MCE_INJECT is not set
CONFIG_X86_THERMAL_VECTOR=y

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_AMD_POWER=y
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX64=y
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=y
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=m
# CONFIG_X86_CPUID is not set
# CONFIG_X86_5LEVEL is not set
# CONFIG_X86_CPA_STATISTICS is not set
CONFIG_ARCH_HAS_MEM_ENCRYPT=y
CONFIG_AMD_MEM_ENCRYPT=y
# CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT is not set
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
# CONFIG_X86_PMEM_LEGACY is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
# CONFIG_MTRR is not set
# CONFIG_ARCH_RANDOM is not set
CONFIG_X86_SMAP=y
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
CONFIG_KEXEC=y
CONFIG_KEXEC_FILE=y
CONFIG_ARCH_HAS_KEXEC_PURGATORY=y
# CONFIG_KEXEC_VERIFY_SIG is not set
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_HAVE_LIVEPATCH=y
CONFIG_ARCH_HAS_ADD_PAGES=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_SUSPEND_SKIP_SYNC=y
# CONFIG_HIBERNATION is not set
CONFIG_PM_SLEEP=y
CONFIG_PM_AUTOSLEEP=y
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_PM_CLK=y
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_ARCH_SUPPORTS_ACPI=y
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
# CONFIG_ACPI_SPCR_TABLE is not set
CONFIG_ACPI_LPIT=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_REV_OVERRIDE_POSSIBLE is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=m
CONFIG_ACPI_BATTERY=m
CONFIG_ACPI_BUTTON=m
CONFIG_ACPI_VIDEO=m
CONFIG_ACPI_FAN=m
CONFIG_ACPI_TAD=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR_CSTATE=y
# CONFIG_ACPI_PROCESSOR is not set
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_DEBUG=y
CONFIG_ACPI_PCI_SLOT=y
# CONFIG_ACPI_CONTAINER is not set
CONFIG_ACPI_HOTPLUG_IOAPIC=y
CONFIG_ACPI_SBS=y
CONFIG_ACPI_HED=y
CONFIG_ACPI_CUSTOM_METHOD=m
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_ACPI_NFIT=m
CONFIG_NFIT_SECURITY_DEBUG=y
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
CONFIG_ACPI_APEI=y
# CONFIG_ACPI_APEI_GHES is not set
# CONFIG_ACPI_APEI_MEMORY_FAILURE is not set
CONFIG_ACPI_APEI_EINJ=y
CONFIG_ACPI_APEI_ERST_DEBUG=y
CONFIG_DPTF_POWER=y
CONFIG_ACPI_WATCHDOG=y
CONFIG_ACPI_EXTLOG=m
CONFIG_PMIC_OPREGION=y
# CONFIG_XPOWER_PMIC_OPREGION is not set
# CONFIG_BXT_WC_PMIC_OPREGION is not set
CONFIG_ACPI_CONFIGFS=m
CONFIG_X86_PM_TIMER=y
CONFIG_SFI=y

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# CPU Idle
#
# CONFIG_CPU_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_ISA_BUS=y
# CONFIG_ISA_DMA_API is not set
CONFIG_AMD_NB=y
# CONFIG_X86_SYSFB is not set

#
# Binary Emulations
#
# CONFIG_IA32_EMULATION is not set
# CONFIG_X86_X32 is not set
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_HAVE_GENERIC_GUP=y

#
# Firmware Drivers
#
# CONFIG_EDD is not set
# CONFIG_FIRMWARE_MEMMAP is not set
# CONFIG_DMIID is not set
CONFIG_DMI_SYSFS=m
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
CONFIG_ISCSI_IBFT_FIND=y
# CONFIG_ISCSI_IBFT is not set
CONFIG_FW_CFG_SYSFS=m
CONFIG_FW_CFG_SYSFS_CMDLINE=y
CONFIG_GOOGLE_FIRMWARE=y
CONFIG_GOOGLE_SMI=y
CONFIG_GOOGLE_COREBOOT_TABLE=y
CONFIG_GOOGLE_MEMCONSOLE=y
CONFIG_GOOGLE_MEMCONSOLE_X86_LEGACY=y
CONFIG_GOOGLE_FRAMEBUFFER_COREBOOT=y
CONFIG_GOOGLE_MEMCONSOLE_COREBOOT=m
CONFIG_GOOGLE_VPD=m
CONFIG_UEFI_CPER=y
CONFIG_UEFI_CPER_X86=y
CONFIG_EFI_EARLYCON=y

#
# Tegra firmware driver
#
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY is not set

#
# General architecture-dependent options
#
CONFIG_CRASH_CORE=y
CONFIG_KEXEC_CORE=y
CONFIG_OPROFILE=m
CONFIG_OPROFILE_EVENT_MULTIPLEX=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_KPROBES is not set
# CONFIG_JUMP_LABEL is not set
CONFIG_UPROBES=y
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_FUNCTION_ERROR_INJECTION=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_HAS_FORTIFY_SOURCE=y
CONFIG_ARCH_HAS_SET_MEMORY=y
CONFIG_HAVE_ARCH_THREAD_STRUCT_WHITELIST=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_RSEQ=y
CONFIG_HAVE_FUNCTION_ARG_ACCESS_API=y
CONFIG_HAVE_CLK=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_HAVE_ARCH_JUMP_LABEL_RELATIVE=y
CONFIG_HAVE_RCU_TABLE_FREE=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_ARCH_STACKLEAK=y
CONFIG_HAVE_STACKPROTECTOR=y
CONFIG_CC_HAS_STACKPROTECTOR_NONE=y
CONFIG_STACKPROTECTOR=y
CONFIG_STACKPROTECTOR_STRONG=y
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_MOVE_PMD=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_HAVE_MOD_ARCH_SPECIFIC=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=28
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
CONFIG_HAVE_RELIABLE_STACKTRACE=y
CONFIG_ISA_BUS_API=y
CONFIG_HAVE_ARCH_VMAP_STACK=y
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_STRICT_MODULE_RWX=y
CONFIG_ARCH_HAS_REFCOUNT=y
# CONFIG_REFCOUNT_FULL is not set
CONFIG_HAVE_ARCH_PREL32_RELOCATIONS=y
CONFIG_ARCH_USE_MEMREMAP_PROT=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
CONFIG_PLUGIN_HOSTCC="g++"
CONFIG_HAVE_GCC_PLUGINS=y
# CONFIG_GCC_PLUGINS is not set
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
# CONFIG_MODULE_FORCE_LOAD is not set
# CONFIG_MODULE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
# CONFIG_MODULE_SIG is not set
# CONFIG_MODULE_COMPRESS is not set
# CONFIG_TRIM_UNUSED_KSYMS is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
CONFIG_BLK_SCSI_REQUEST=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
CONFIG_BLK_DEV_ZONED=y
# CONFIG_BLK_DEV_THROTTLING is not set
# CONFIG_BLK_CMDLINE_PARSER is not set
CONFIG_BLK_WBT=y
CONFIG_BLK_CGROUP_IOLATENCY=y
CONFIG_BLK_WBT_MQ=y
# CONFIG_BLK_DEBUG_FS is not set
CONFIG_BLK_SED_OPAL=y

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_EFI_PARTITION=y
CONFIG_BLK_MQ_PCI=y
CONFIG_BLK_MQ_VIRTIO=y
CONFIG_BLK_PM=y

#
# IO Schedulers
#
# CONFIG_MQ_IOSCHED_DEADLINE is not set
CONFIG_MQ_IOSCHED_KYBER=y
CONFIG_IOSCHED_BFQ=m
CONFIG_BFQ_GROUP_IOSCHED=y
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_ARCH_HAS_SYNC_CORE_BEFORE_USERMODE=y
CONFIG_ARCH_HAS_SYSCALL_WRAPPER=y
CONFIG_FREEZER=y

#
# Executable file formats
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_BINFMT_MISC=y
# CONFIG_COREDUMP is not set

#
# Memory Management options
#
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
# CONFIG_SPARSEMEM_VMEMMAP is not set
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
# CONFIG_COMPACTION is not set
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
# CONFIG_BOUNCE is not set
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
# CONFIG_HWPOISON_INJECT is not set
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_ARCH_WANTS_THP_SWAP=y
CONFIG_NEED_PER_CPU_KM=y
# CONFIG_CLEANCACHE is not set
CONFIG_FRONTSWAP=y
CONFIG_CMA=y
CONFIG_CMA_DEBUG=y
CONFIG_CMA_DEBUGFS=y
CONFIG_CMA_AREAS=7
CONFIG_ZSWAP=y
CONFIG_ZPOOL=y
CONFIG_ZBUD=y
# CONFIG_Z3FOLD is not set
CONFIG_ZSMALLOC=m
CONFIG_PGTABLE_MAPPING=y
# CONFIG_ZSMALLOC_STAT is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
# CONFIG_IDLE_PAGE_TRACKING is not set
CONFIG_ARCH_HAS_ZONE_DEVICE=y
CONFIG_FRAME_VECTOR=y
CONFIG_PERCPU_STATS=y
# CONFIG_GUP_BENCHMARK is not set
CONFIG_ARCH_HAS_PTE_SPECIAL=y
CONFIG_NET=y
CONFIG_SKB_EXTENSIONS=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
CONFIG_UNIX_SCM=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_TLS is not set
CONFIG_XFRM=y
# CONFIG_XFRM_USER is not set
# CONFIG_XFRM_INTERFACE is not set
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
# CONFIG_NET_KEY is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
# CONFIG_SYN_COOKIES is not set
# CONFIG_NET_IPVTI is not set
# CONFIG_NET_FOU is not set
# CONFIG_NET_FOU_IP_TUNNELS is not set
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
CONFIG_INET_XFRM_MODE_TUNNEL=y
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_INET_UDP_DIAG is not set
# CONFIG_INET_RAW_DIAG is not set
# CONFIG_INET_DIAG_DESTROY is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
# CONFIG_INET6_AH is not set
# CONFIG_INET6_ESP is not set
# CONFIG_INET6_IPCOMP is not set
# CONFIG_IPV6_MIP6 is not set
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
CONFIG_INET6_XFRM_MODE_BEET=y
# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
# CONFIG_IPV6_VTI is not set
CONFIG_IPV6_SIT=y
# CONFIG_IPV6_SIT_6RD is not set
CONFIG_IPV6_NDISC_NODETYPE=y
# CONFIG_IPV6_TUNNEL is not set
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_IPV6_MROUTE is not set
# CONFIG_IPV6_SEG6_LWTUNNEL is not set
# CONFIG_IPV6_SEG6_HMAC is not set
# CONFIG_NETLABEL is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_BPFILTER is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_L2TP is not set
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
# CONFIG_NET_DSA is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_6LOWPAN is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=m
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_MPLS is not set
# CONFIG_NET_NSH is not set
# CONFIG_HSR is not set
# CONFIG_NET_SWITCHDEV is not set
# CONFIG_NET_L3_MASTER_DEV is not set
# CONFIG_NET_NCSI is not set
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
# CONFIG_BPF_JIT is not set

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_NET_DROP_MONITOR is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
# CONFIG_AF_KCM is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
# CONFIG_CEPH_LIB is not set
# CONFIG_NFC is not set
# CONFIG_PSAMPLE is not set
# CONFIG_NET_IFE is not set
# CONFIG_LWTUNNEL is not set
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
# CONFIG_NET_DEVLINK is not set
# CONFIG_FAILOVER is not set
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#
CONFIG_HAVE_EISA=y
CONFIG_EISA=y
CONFIG_EISA_VLB_PRIMING=y
# CONFIG_EISA_PCI_EISA is not set
CONFIG_EISA_VIRTUAL_ROOT=y
CONFIG_EISA_NAMES=y
CONFIG_HAVE_PCI=y
CONFIG_PCI=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCIEPORTBUS is not set
CONFIG_PCI_MSI=y
CONFIG_PCI_MSI_IRQ_DOMAIN=y
CONFIG_PCI_QUIRKS=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=m
# CONFIG_PCI_PF_STUB is not set
CONFIG_PCI_ATS=y
CONFIG_PCI_LOCKLESS_CONFIG=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y
# CONFIG_HOTPLUG_PCI is not set

#
# PCI controller drivers
#

#
# Cadence PCIe controllers support
#
CONFIG_VMD=y

#
# DesignWare PCI Core Support
#
CONFIG_PCIE_DW=y
CONFIG_PCIE_DW_HOST=y
CONFIG_PCIE_DW_PLAT=y
CONFIG_PCIE_DW_PLAT_HOST=y
# CONFIG_PCI_MESON is not set

#
# PCI Endpoint
#
# CONFIG_PCI_ENDPOINT is not set

#
# PCI switch controller drivers
#
# CONFIG_PCI_SW_SWITCHTEC is not set
# CONFIG_PCCARD is not set
# CONFIG_RAPIDIO is not set

#
# Generic Driver Options
#
# CONFIG_UEVENT_HELPER is not set
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
# CONFIG_STANDALONE is not set
CONFIG_PREVENT_FIRMWARE_BUILD=y

#
# Firmware loader
#
CONFIG_FW_LOADER=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
CONFIG_WANT_DEV_COREDUMP=y
CONFIG_ALLOW_DEV_COREDUMP=y
CONFIG_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
CONFIG_DEBUG_TEST_DRIVER_REMOVE=y
# CONFIG_TEST_ASYNC_DRIVER_PROBE is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_GENERIC_CPU_VULNERABILITIES=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_DMA_FENCE_TRACE=y

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
# CONFIG_GNSS is not set
CONFIG_MTD=y
CONFIG_MTD_TESTS=m
# CONFIG_MTD_CMDLINE_PARTS is not set
CONFIG_MTD_AR7_PARTS=m

#
# Partition parsers
#
CONFIG_MTD_REDBOOT_PARTS=m
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED=y
CONFIG_MTD_REDBOOT_PARTS_READONLY=y

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=y
# CONFIG_FTL is not set
CONFIG_NFTL=y
CONFIG_NFTL_RW=y
CONFIG_INFTL=y
CONFIG_RFD_FTL=y
CONFIG_SSFDC=y
CONFIG_SM_FTL=m
# CONFIG_MTD_OOPS is not set
# CONFIG_MTD_SWAP is not set
CONFIG_MTD_PARTITIONED_MASTER=y

#
# RAM/ROM/Flash chip drivers
#
# CONFIG_MTD_CFI is not set
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_INTELEXT is not set
CONFIG_MTD_CFI_AMDSTD=m
CONFIG_MTD_CFI_STAA=y
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
CONFIG_MTD_ROM=y
CONFIG_MTD_ABSENT=m

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
CONFIG_MTD_PHYSMAP=y
CONFIG_MTD_PHYSMAP_COMPAT=y
CONFIG_MTD_PHYSMAP_START=0x8000000
CONFIG_MTD_PHYSMAP_LEN=0
CONFIG_MTD_PHYSMAP_BANKWIDTH=2
CONFIG_MTD_AMD76XROM=m
CONFIG_MTD_ICHXROM=m
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=m
# CONFIG_MTD_INTEL_VR_NOR is not set
CONFIG_MTD_PLATRAM=m

#
# Self-contained MTD device drivers
#
CONFIG_MTD_PMC551=y
# CONFIG_MTD_PMC551_BUGFIX is not set
# CONFIG_MTD_PMC551_DEBUG is not set
CONFIG_MTD_DATAFLASH=y
CONFIG_MTD_DATAFLASH_WRITE_VERIFY=y
CONFIG_MTD_DATAFLASH_OTP=y
# CONFIG_MTD_M25P80 is not set
# CONFIG_MTD_MCHP23K256 is not set
# CONFIG_MTD_SST25L is not set
CONFIG_MTD_SLRAM=m
# CONFIG_MTD_PHRAM is not set
CONFIG_MTD_MTDRAM=y
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTD_BLOCK2MTD=y

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
# CONFIG_MTD_ONENAND is not set
CONFIG_MTD_NAND_ECC=m
CONFIG_MTD_NAND_ECC_SMC=y
CONFIG_MTD_NAND=m
# CONFIG_MTD_NAND_ECC_BCH is not set
CONFIG_MTD_SM_COMMON=m
# CONFIG_MTD_NAND_DENALI_PCI is not set
# CONFIG_MTD_NAND_GPIO is not set
CONFIG_MTD_NAND_RICOH=m
CONFIG_MTD_NAND_DISKONCHIP=m
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED=y
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
CONFIG_MTD_NAND_DISKONCHIP_PROBE_HIGH=y
CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE=y
# CONFIG_MTD_NAND_CAFE is not set
CONFIG_MTD_NAND_NANDSIM=m
# CONFIG_MTD_NAND_PLATFORM is not set
# CONFIG_MTD_SPI_NAND is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
CONFIG_MTD_SPI_NOR=m
CONFIG_MTD_SPI_NOR_USE_4K_SECTORS=y
# CONFIG_SPI_MTK_QUADSPI is not set
CONFIG_SPI_INTEL_SPI=m
# CONFIG_SPI_INTEL_SPI_PCI is not set
CONFIG_SPI_INTEL_SPI_PLATFORM=m
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
CONFIG_MTD_UBI_FASTMAP=y
CONFIG_MTD_UBI_GLUEBI=y
CONFIG_MTD_UBI_BLOCK=y
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
# CONFIG_PARPORT is not set
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
CONFIG_CDROM=y
CONFIG_BLK_DEV_PCIESSD_MTIP32XX=y
# CONFIG_ZRAM is not set
# CONFIG_BLK_DEV_UMEM is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
CONFIG_BLK_DEV_CRYPTOLOOP=y
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
CONFIG_BLK_DEV_SKD=m
CONFIG_BLK_DEV_SX8=y
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=4096
CONFIG_CDROM_PKTCDVD=m
CONFIG_CDROM_PKTCDVD_BUFFERS=8
CONFIG_CDROM_PKTCDVD_WCACHE=y
# CONFIG_ATA_OVER_ETH is not set
CONFIG_VIRTIO_BLK=y
# CONFIG_VIRTIO_BLK_SCSI is not set
# CONFIG_BLK_DEV_RBD is not set
CONFIG_BLK_DEV_RSXX=m

#
# NVME Support
#
CONFIG_NVME_CORE=m
# CONFIG_BLK_DEV_NVME is not set
CONFIG_NVME_MULTIPATH=y
CONFIG_NVME_FABRICS=m
# CONFIG_NVME_FC is not set
CONFIG_NVME_TARGET=m
CONFIG_NVME_TARGET_LOOP=m
CONFIG_NVME_TARGET_FC=m
# CONFIG_NVME_TARGET_TCP is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=m
CONFIG_AD525X_DPOT=m
# CONFIG_AD525X_DPOT_I2C is not set
CONFIG_AD525X_DPOT_SPI=m
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
CONFIG_PHANTOM=y
CONFIG_SGI_IOC4=m
CONFIG_TIFM_CORE=m
CONFIG_TIFM_7XX1=m
CONFIG_ICS932S401=m
CONFIG_ENCLOSURE_SERVICES=m
CONFIG_HP_ILO=m
CONFIG_APDS9802ALS=y
# CONFIG_ISL29003 is not set
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=m
CONFIG_SENSORS_BH1770=m
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
CONFIG_DS1682=m
# CONFIG_VMWARE_BALLOON is not set
# CONFIG_USB_SWITCH_FSA9480 is not set
CONFIG_LATTICE_ECP3_CONFIG=m
CONFIG_SRAM=y
CONFIG_PCI_ENDPOINT_TEST=m
CONFIG_PVPANIC=y
CONFIG_C2PORT=m
# CONFIG_C2PORT_DURAMAR_2150 is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_AT25=m
# CONFIG_EEPROM_LEGACY is not set
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=m
CONFIG_EEPROM_93XX46=m
CONFIG_EEPROM_IDT_89HPESX=m
CONFIG_EEPROM_EE1004=m
CONFIG_CB710_CORE=m
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=m
CONFIG_ALTERA_STAPL=y
CONFIG_INTEL_MEI=m
CONFIG_INTEL_MEI_ME=m
CONFIG_INTEL_MEI_TXE=m
CONFIG_INTEL_MEI_HDCP=m
CONFIG_VMWARE_VMCI=y

#
# Intel MIC & related support
#

#
# Intel MIC Bus Driver
#
CONFIG_INTEL_MIC_BUS=y

#
# SCIF Bus Driver
#
# CONFIG_SCIF_BUS is not set

#
# VOP Bus Driver
#
CONFIG_VOP_BUS=y

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#

#
# SCIF Driver
#

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#

#
# VOP Driver
#
CONFIG_VOP=y
CONFIG_VHOST_RING=y
CONFIG_GENWQE=y
CONFIG_GENWQE_PLATFORM_ERROR_RECOVERY=0
CONFIG_ECHO=m
# CONFIG_MISC_ALCOR_PCI is not set
# CONFIG_MISC_RTSX_PCI is not set
CONFIG_HABANA_AI=y
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
CONFIG_BLK_DEV_IDE_SATA=y
CONFIG_IDE_GD=y
# CONFIG_IDE_GD_ATA is not set
# CONFIG_IDE_GD_ATAPI is not set
CONFIG_BLK_DEV_IDECD=y
# CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS is not set
# CONFIG_BLK_DEV_IDETAPE is not set
# CONFIG_BLK_DEV_IDEACPI is not set
CONFIG_IDE_TASK_IOCTL=y
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
# CONFIG_IDE_GENERIC is not set
# CONFIG_BLK_DEV_PLATFORM is not set
# CONFIG_BLK_DEV_CMD640 is not set
CONFIG_BLK_DEV_IDEPNP=m
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
# CONFIG_IDEPCI_PCIBUS_ORDER is not set
# CONFIG_BLK_DEV_OFFBOARD is not set
# CONFIG_BLK_DEV_GENERIC is not set
CONFIG_BLK_DEV_OPTI621=m
CONFIG_BLK_DEV_RZ1000=m
CONFIG_BLK_DEV_IDEDMA_PCI=y
CONFIG_BLK_DEV_AEC62XX=y
CONFIG_BLK_DEV_ALI15X3=m
# CONFIG_BLK_DEV_AMD74XX is not set
# CONFIG_BLK_DEV_ATIIXP is not set
CONFIG_BLK_DEV_CMD64X=m
CONFIG_BLK_DEV_TRIFLEX=m
CONFIG_BLK_DEV_HPT366=y
CONFIG_BLK_DEV_JMICRON=y
CONFIG_BLK_DEV_PIIX=m
# CONFIG_BLK_DEV_IT8172 is not set
# CONFIG_BLK_DEV_IT8213 is not set
# CONFIG_BLK_DEV_IT821X is not set
CONFIG_BLK_DEV_NS87415=m
CONFIG_BLK_DEV_PDC202XX_OLD=y
CONFIG_BLK_DEV_PDC202XX_NEW=y
CONFIG_BLK_DEV_SVWKS=m
CONFIG_BLK_DEV_SIIMAGE=m
CONFIG_BLK_DEV_SIS5513=m
# CONFIG_BLK_DEV_SLC90E66 is not set
CONFIG_BLK_DEV_TRM290=m
CONFIG_BLK_DEV_VIA82CXXX=m
CONFIG_BLK_DEV_TC86C001=y
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=m
CONFIG_RAID_ATTRS=m
CONFIG_SCSI=m
CONFIG_SCSI_DMA=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
# CONFIG_BLK_DEV_SD is not set
CONFIG_CHR_DEV_ST=m
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=m
# CONFIG_BLK_DEV_SR_VENDOR is not set
# CONFIG_CHR_DEV_SG is not set
# CONFIG_CHR_DEV_SCH is not set
CONFIG_SCSI_ENCLOSURE=m
# CONFIG_SCSI_CONSTANTS is not set
# CONFIG_SCSI_LOGGING is not set
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=m
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
CONFIG_SCSI_SAS_ATTRS=m
CONFIG_SCSI_SAS_LIBSAS=m
# CONFIG_SCSI_SAS_HOST_SMP is not set
CONFIG_SCSI_SRP_ATTRS=m
CONFIG_SCSI_LOWLEVEL=y
# CONFIG_ISCSI_TCP is not set
CONFIG_ISCSI_BOOT_SYSFS=m
# CONFIG_SCSI_CXGB3_ISCSI is not set
# CONFIG_SCSI_CXGB4_ISCSI is not set
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_BE2ISCSI is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_HPSA is not set
CONFIG_SCSI_3W_9XXX=m
CONFIG_SCSI_3W_SAS=m
# CONFIG_SCSI_ACARD is not set
CONFIG_SCSI_AHA1740=m
CONFIG_SCSI_AACRAID=m
CONFIG_SCSI_AIC7XXX=m
CONFIG_AIC7XXX_CMDS_PER_DEVICE=32
CONFIG_AIC7XXX_RESET_DELAY_MS=5000
# CONFIG_AIC7XXX_DEBUG_ENABLE is not set
CONFIG_AIC7XXX_DEBUG_MASK=0
# CONFIG_AIC7XXX_REG_PRETTY_PRINT is not set
CONFIG_SCSI_AIC79XX=m
CONFIG_AIC79XX_CMDS_PER_DEVICE=32
CONFIG_AIC79XX_RESET_DELAY_MS=5000
# CONFIG_AIC79XX_DEBUG_ENABLE is not set
CONFIG_AIC79XX_DEBUG_MASK=0
# CONFIG_AIC79XX_REG_PRETTY_PRINT is not set
CONFIG_SCSI_AIC94XX=m
# CONFIG_AIC94XX_DEBUG is not set
CONFIG_SCSI_MVSAS=m
# CONFIG_SCSI_MVSAS_DEBUG is not set
# CONFIG_SCSI_MVSAS_TASKLET is not set
# CONFIG_SCSI_MVUMI is not set
CONFIG_SCSI_DPT_I2O=m
CONFIG_SCSI_ADVANSYS=m
# CONFIG_SCSI_ARCMSR is not set
CONFIG_SCSI_ESAS2R=m
# CONFIG_MEGARAID_NEWGEN is not set
CONFIG_MEGARAID_LEGACY=m
# CONFIG_MEGARAID_SAS is not set
# CONFIG_SCSI_MPT3SAS is not set
# CONFIG_SCSI_MPT2SAS is not set
# CONFIG_SCSI_SMARTPQI is not set
CONFIG_SCSI_UFSHCD=m
CONFIG_SCSI_UFSHCD_PCI=m
# CONFIG_SCSI_UFS_DWC_TC_PCI is not set
CONFIG_SCSI_UFSHCD_PLATFORM=m
CONFIG_SCSI_UFS_CDNS_PLATFORM=m
CONFIG_SCSI_UFS_DWC_TC_PLATFORM=m
# CONFIG_SCSI_UFS_BSG is not set
CONFIG_SCSI_HPTIOP=m
CONFIG_SCSI_MYRB=m
CONFIG_SCSI_MYRS=m
CONFIG_VMWARE_PVSCSI=m
CONFIG_SCSI_SNIC=m
CONFIG_SCSI_SNIC_DEBUG_FS=y
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_ISCI is not set
CONFIG_SCSI_IPS=m
CONFIG_SCSI_INITIO=m
CONFIG_SCSI_INIA100=m
CONFIG_SCSI_STEX=m
CONFIG_SCSI_SYM53C8XX_2=m
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
# CONFIG_SCSI_SYM53C8XX_MMIO is not set
CONFIG_SCSI_QLOGIC_1280=m
# CONFIG_SCSI_QLA_ISCSI is not set
CONFIG_SCSI_SIM710=m
CONFIG_SCSI_DC395x=m
CONFIG_SCSI_AM53C974=m
CONFIG_SCSI_WD719X=m
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_PMCRAID is not set
CONFIG_SCSI_PM8001=m
CONFIG_SCSI_VIRTIO=m
# CONFIG_SCSI_DH is not set
# CONFIG_ATA is not set
# CONFIG_MD is not set
# CONFIG_TARGET_CORE is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
CONFIG_FIREWIRE_NOSY=m
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_MAC_EMUMOUSEBTN is not set
CONFIG_NETDEVICES=y
CONFIG_NET_CORE=y
# CONFIG_BONDING is not set
# CONFIG_DUMMY is not set
# CONFIG_EQUALIZER is not set
# CONFIG_NET_FC is not set
# CONFIG_NET_TEAM is not set
# CONFIG_MACVLAN is not set
# CONFIG_IPVLAN is not set
# CONFIG_VXLAN is not set
# CONFIG_GENEVE is not set
# CONFIG_GTP is not set
# CONFIG_MACSEC is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_TUN is not set
# CONFIG_TUN_VNET_CROSS_LE is not set
# CONFIG_VETH is not set
# CONFIG_VIRTIO_NET is not set
# CONFIG_NLMON is not set
# CONFIG_ARCNET is not set

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
CONFIG_ETHERNET=y
CONFIG_NET_VENDOR_3COM=y
# CONFIG_EL3 is not set
# CONFIG_VORTEX is not set
# CONFIG_TYPHOON is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_AGERE=y
# CONFIG_ET131X is not set
CONFIG_NET_VENDOR_ALACRITECH=y
# CONFIG_SLICOSS is not set
CONFIG_NET_VENDOR_ALTEON=y
# CONFIG_ACENIC is not set
# CONFIG_ALTERA_TSE is not set
CONFIG_NET_VENDOR_AMAZON=y
# CONFIG_ENA_ETHERNET is not set
CONFIG_NET_VENDOR_AMD=y
# CONFIG_AMD8111_ETH is not set
# CONFIG_PCNET32 is not set
# CONFIG_AMD_XGBE is not set
CONFIG_NET_VENDOR_AQUANTIA=y
# CONFIG_AQTION is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_ALX is not set
CONFIG_NET_VENDOR_AURORA=y
# CONFIG_AURORA_NB8800 is not set
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
# CONFIG_BCMGENET is not set
# CONFIG_BNX2 is not set
# CONFIG_CNIC is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2X is not set
# CONFIG_SYSTEMPORT is not set
# CONFIG_BNXT is not set
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
CONFIG_NET_VENDOR_CADENCE=y
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_CAVIUM=y
# CONFIG_THUNDER_NIC_PF is not set
# CONFIG_THUNDER_NIC_VF is not set
# CONFIG_THUNDER_NIC_BGX is not set
# CONFIG_THUNDER_NIC_RGX is not set
# CONFIG_CAVIUM_PTP is not set
# CONFIG_LIQUIDIO is not set
# CONFIG_LIQUIDIO_VF is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CIRRUS=y
# CONFIG_CS89x0 is not set
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
CONFIG_NET_VENDOR_CORTINA=y
# CONFIG_CX_ECAT is not set
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DL2K is not set
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
CONFIG_NET_VENDOR_EZCHIP=y
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_HUAWEI=y
# CONFIG_HINIC is not set
CONFIG_NET_VENDOR_I825XX=y
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
# CONFIG_E1000E is not set
# CONFIG_IGB is not set
# CONFIG_IGBVF is not set
# CONFIG_IXGB is not set
# CONFIG_IXGBE is not set
# CONFIG_IXGBEVF is not set
# CONFIG_I40E is not set
# CONFIG_I40EVF is not set
# CONFIG_ICE is not set
# CONFIG_FM10K is not set
# CONFIG_IGC is not set
# CONFIG_JME is not set
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_MVMDIO is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX5_CORE is not set
# CONFIG_MLXSW_CORE is not set
# CONFIG_MLXFW is not set
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8851 is not set
# CONFIG_KS8851_MLL is not set
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MICROCHIP=y
# CONFIG_ENC28J60 is not set
# CONFIG_ENCX24J600 is not set
# CONFIG_LAN743X is not set
CONFIG_NET_VENDOR_MICROSEMI=y
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
# CONFIG_FEALNX is not set
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
# CONFIG_NS83820 is not set
CONFIG_NET_VENDOR_NETERION=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
CONFIG_NET_VENDOR_NETRONOME=y
# CONFIG_NFP is not set
CONFIG_NET_VENDOR_NI=y
# CONFIG_NI_XGE_MANAGEMENT_ENET is not set
CONFIG_NET_VENDOR_8390=y
# CONFIG_NE2K_PCI is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_ETHOC is not set
CONFIG_NET_VENDOR_PACKET_ENGINES=y
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
# CONFIG_QED is not set
CONFIG_NET_VENDOR_QUALCOMM=y
# CONFIG_QCOM_EMAC is not set
# CONFIG_RMNET is not set
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_R8169 is not set
CONFIG_NET_VENDOR_RENESAS=y
CONFIG_NET_VENDOR_ROCKER=y
CONFIG_NET_VENDOR_SAMSUNG=y
# CONFIG_SXGBE_ETH is not set
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SOLARFLARE=y
# CONFIG_SFC is not set
# CONFIG_SFC_FALCON is not set
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
# CONFIG_SIS190 is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_EPIC100 is not set
# CONFIG_SMSC911X is not set
# CONFIG_SMSC9420 is not set
CONFIG_NET_VENDOR_SOCIONEXT=y
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_SYNOPSYS=y
# CONFIG_DWC_XLGMAC is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TI_CPSW_PHY_SEL is not set
# CONFIG_TI_CPSW_ALE is not set
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
# CONFIG_VIA_VELOCITY is not set
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_MDIO_DEVICE is not set
# CONFIG_PHYLIB is not set
# CONFIG_MICREL_KS8995MA is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set

#
# Host-side USB support is needed for USB Network Adapter support
#
CONFIG_WLAN=y
# CONFIG_WIRELESS_WDS is not set
CONFIG_WLAN_VENDOR_ADMTEK=y
CONFIG_WLAN_VENDOR_ATH=y
# CONFIG_ATH_DEBUG is not set
# CONFIG_ATH5K_PCI is not set
CONFIG_WLAN_VENDOR_ATMEL=y
CONFIG_WLAN_VENDOR_BROADCOM=y
CONFIG_WLAN_VENDOR_CISCO=y
CONFIG_WLAN_VENDOR_INTEL=y
CONFIG_WLAN_VENDOR_INTERSIL=y
# CONFIG_HOSTAP is not set
# CONFIG_PRISM54 is not set
CONFIG_WLAN_VENDOR_MARVELL=y
CONFIG_WLAN_VENDOR_MEDIATEK=y
CONFIG_WLAN_VENDOR_RALINK=y
CONFIG_WLAN_VENDOR_REALTEK=y
CONFIG_WLAN_VENDOR_RSI=y
CONFIG_WLAN_VENDOR_ST=y
CONFIG_WLAN_VENDOR_TI=y
CONFIG_WLAN_VENDOR_ZYDAS=y
CONFIG_WLAN_VENDOR_QUANTENNA=y

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
# CONFIG_WAN is not set
# CONFIG_VMXNET3 is not set
# CONFIG_FUJITSU_ES is not set
# CONFIG_THUNDERBOLT_NET is not set
# CONFIG_NETDEVSIM is not set
# CONFIG_NET_FAILOVER is not set
# CONFIG_ISDN is not set
CONFIG_NVM=y
CONFIG_NVM_PBLK=m
CONFIG_NVM_PBLK_DEBUG=y

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=m
CONFIG_INPUT_FF_MEMLESS=m
CONFIG_INPUT_POLLDEV=m
CONFIG_INPUT_SPARSEKMAP=m
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
CONFIG_INPUT_JOYDEV=m
# CONFIG_INPUT_EVDEV is not set
CONFIG_INPUT_EVBUG=m

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADC is not set
# CONFIG_KEYBOARD_ADP5520 is not set
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_DLINK_DIR685 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_SAMSUNG is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_TM2_TOUCHKEY is not set
# CONFIG_KEYBOARD_TWL4030 is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_PROPERTIES=y
# CONFIG_TOUCHSCREEN_88PM860X is not set
CONFIG_TOUCHSCREEN_ADS7846=m
CONFIG_TOUCHSCREEN_AD7877=m
CONFIG_TOUCHSCREEN_AD7879=m
CONFIG_TOUCHSCREEN_AD7879_I2C=m
CONFIG_TOUCHSCREEN_AD7879_SPI=m
CONFIG_TOUCHSCREEN_ADC=m
CONFIG_TOUCHSCREEN_ATMEL_MXT=m
# CONFIG_TOUCHSCREEN_ATMEL_MXT_T37 is not set
CONFIG_TOUCHSCREEN_AUO_PIXCIR=m
# CONFIG_TOUCHSCREEN_BU21013 is not set
# CONFIG_TOUCHSCREEN_BU21029 is not set
CONFIG_TOUCHSCREEN_CHIPONE_ICN8505=m
# CONFIG_TOUCHSCREEN_CY8CTMG110 is not set
# CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set
CONFIG_TOUCHSCREEN_CYTTSP4_CORE=m
# CONFIG_TOUCHSCREEN_CYTTSP4_I2C is not set
CONFIG_TOUCHSCREEN_CYTTSP4_SPI=m
CONFIG_TOUCHSCREEN_DA9052=m
CONFIG_TOUCHSCREEN_DYNAPRO=m
CONFIG_TOUCHSCREEN_HAMPSHIRE=m
# CONFIG_TOUCHSCREEN_EETI is not set
# CONFIG_TOUCHSCREEN_EGALAX_SERIAL is not set
CONFIG_TOUCHSCREEN_EXC3000=m
# CONFIG_TOUCHSCREEN_FUJITSU is not set
# CONFIG_TOUCHSCREEN_GOODIX is not set
CONFIG_TOUCHSCREEN_HIDEEP=m
CONFIG_TOUCHSCREEN_ILI210X=m
CONFIG_TOUCHSCREEN_S6SY761=m
CONFIG_TOUCHSCREEN_GUNZE=m
# CONFIG_TOUCHSCREEN_EKTF2127 is not set
CONFIG_TOUCHSCREEN_ELAN=m
CONFIG_TOUCHSCREEN_ELO=m
CONFIG_TOUCHSCREEN_WACOM_W8001=m
CONFIG_TOUCHSCREEN_WACOM_I2C=m
CONFIG_TOUCHSCREEN_MAX11801=m
CONFIG_TOUCHSCREEN_MCS5000=m
CONFIG_TOUCHSCREEN_MMS114=m
CONFIG_TOUCHSCREEN_MELFAS_MIP4=m
# CONFIG_TOUCHSCREEN_MTOUCH is not set
# CONFIG_TOUCHSCREEN_INEXIO is not set
CONFIG_TOUCHSCREEN_MK712=m
# CONFIG_TOUCHSCREEN_PENMOUNT is not set
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
CONFIG_TOUCHSCREEN_TOUCHRIGHT=m
CONFIG_TOUCHSCREEN_TOUCHWIN=m
CONFIG_TOUCHSCREEN_UCB1400=m
# CONFIG_TOUCHSCREEN_PIXCIR is not set
CONFIG_TOUCHSCREEN_WDT87XX_I2C=m
# CONFIG_TOUCHSCREEN_WM97XX is not set
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
# CONFIG_TOUCHSCREEN_MC13783 is not set
# CONFIG_TOUCHSCREEN_TOUCHIT213 is not set
CONFIG_TOUCHSCREEN_TSC_SERIO=m
# CONFIG_TOUCHSCREEN_TSC2004 is not set
# CONFIG_TOUCHSCREEN_TSC2005 is not set
CONFIG_TOUCHSCREEN_TSC2007=m
# CONFIG_TOUCHSCREEN_TSC2007_IIO is not set
CONFIG_TOUCHSCREEN_PCAP=m
# CONFIG_TOUCHSCREEN_RM_TS is not set
CONFIG_TOUCHSCREEN_SILEAD=m
CONFIG_TOUCHSCREEN_SIS_I2C=m
CONFIG_TOUCHSCREEN_ST1232=m
CONFIG_TOUCHSCREEN_STMFTS=m
CONFIG_TOUCHSCREEN_SURFACE3_SPI=m
# CONFIG_TOUCHSCREEN_SX8654 is not set
CONFIG_TOUCHSCREEN_TPS6507X=m
CONFIG_TOUCHSCREEN_ZET6223=m
# CONFIG_TOUCHSCREEN_ZFORCE is not set
CONFIG_TOUCHSCREEN_ROHM_BU21023=m
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_88PM860X_ONKEY is not set
CONFIG_INPUT_88PM80X_ONKEY=m
CONFIG_INPUT_AD714X=m
CONFIG_INPUT_AD714X_I2C=m
CONFIG_INPUT_AD714X_SPI=m
CONFIG_INPUT_ARIZONA_HAPTICS=m
CONFIG_INPUT_BMA150=m
CONFIG_INPUT_E3X0_BUTTON=m
CONFIG_INPUT_MSM_VIBRATOR=m
# CONFIG_INPUT_MAX8925_ONKEY is not set
CONFIG_INPUT_MC13783_PWRBUTTON=m
CONFIG_INPUT_MMA8450=m
CONFIG_INPUT_APANEL=m
CONFIG_INPUT_GP2A=m
CONFIG_INPUT_GPIO_BEEPER=m
CONFIG_INPUT_GPIO_DECODER=m
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
CONFIG_INPUT_KXTJ9=m
CONFIG_INPUT_KXTJ9_POLLED_MODE=y
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
# CONFIG_INPUT_REGULATOR_HAPTIC is not set
CONFIG_INPUT_RETU_PWRBUTTON=m
# CONFIG_INPUT_AXP20X_PEK is not set
CONFIG_INPUT_TWL4030_PWRBUTTON=m
# CONFIG_INPUT_TWL4030_VIBRA is not set
CONFIG_INPUT_TWL6040_VIBRA=m
CONFIG_INPUT_UINPUT=m
CONFIG_INPUT_PCF8574=m
# CONFIG_INPUT_GPIO_ROTARY_ENCODER is not set
CONFIG_INPUT_DA9052_ONKEY=m
CONFIG_INPUT_DA9063_ONKEY=m
CONFIG_INPUT_PCAP=m
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_CMA3000 is not set
CONFIG_INPUT_IDEAPAD_SLIDEBAR=m
CONFIG_INPUT_DRV260X_HAPTICS=m
CONFIG_INPUT_DRV2665_HAPTICS=m
CONFIG_INPUT_DRV2667_HAPTICS=m
CONFIG_RMI4_CORE=m
CONFIG_RMI4_I2C=m
CONFIG_RMI4_SPI=m
CONFIG_RMI4_SMB=m
CONFIG_RMI4_F03=y
CONFIG_RMI4_F03_SERIO=m
CONFIG_RMI4_2D_SENSOR=y
CONFIG_RMI4_F11=y
CONFIG_RMI4_F12=y
CONFIG_RMI4_F30=y
CONFIG_RMI4_F34=y
# CONFIG_RMI4_F54 is not set
CONFIG_RMI4_F55=y

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
CONFIG_SERIO_PCIPS2=m
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=m
CONFIG_SERIO_ALTERA_PS2=m
CONFIG_SERIO_PS2MULT=m
CONFIG_SERIO_ARC_PS2=m
# CONFIG_SERIO_OLPC_APSP is not set
# CONFIG_SERIO_GPIO_PS2 is not set
CONFIG_USERIO=m
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
CONFIG_LDISC_AUTOLOAD=y
# CONFIG_DEVMEM is not set
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_EXAR=y
# CONFIG_SERIAL_8250_MEN_MCB is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_DW is not set
# CONFIG_SERIAL_8250_RT288X is not set
CONFIG_SERIAL_8250_LPSS=y
CONFIG_SERIAL_8250_MID=y
# CONFIG_SERIAL_8250_MOXA is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MAX3100 is not set
# CONFIG_SERIAL_MAX310X is not set
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_SC16IS7XX is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_MEN_Z135 is not set
# CONFIG_SERIAL_DEV_BUS is not set
# CONFIG_TTY_PRINTK is not set
# CONFIG_VIRTIO_CONSOLE is not set
# CONFIG_IPMI_HANDLER is not set
# CONFIG_HW_RANDOM is not set
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
CONFIG_APPLICOM=y
# CONFIG_MWAVE is not set
CONFIG_RAW_DRIVER=m
CONFIG_MAX_RAW_DEVS=256
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
CONFIG_HPET_MMAP_DEFAULT=y
CONFIG_HANGCHECK_TIMER=m
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_SPI=m
# CONFIG_TCG_TIS_I2C_ATMEL is not set
# CONFIG_TCG_TIS_I2C_INFINEON is not set
CONFIG_TCG_TIS_I2C_NUVOTON=y
# CONFIG_TCG_NSC is not set
CONFIG_TCG_ATMEL=m
# CONFIG_TCG_INFINEON is not set
CONFIG_TCG_CRB=y
CONFIG_TCG_VTPM_PROXY=y
CONFIG_TCG_TIS_ST33ZP24=y
CONFIG_TCG_TIS_ST33ZP24_I2C=m
CONFIG_TCG_TIS_ST33ZP24_SPI=y
CONFIG_TELCLOCK=y
# CONFIG_DEVPORT is not set
# CONFIG_XILLYBUS is not set
CONFIG_RANDOM_TRUST_CPU=y

#
# I2C support
#
CONFIG_I2C=y
# CONFIG_ACPI_I2C_OPREGION is not set
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=m
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_GPIO=m
# CONFIG_I2C_MUX_LTC4306 is not set
# CONFIG_I2C_MUX_PCA9541 is not set
CONFIG_I2C_MUX_PCA954x=y
# CONFIG_I2C_MUX_REG is not set
CONFIG_I2C_MUX_MLXCPLD=m
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=m
CONFIG_I2C_ALI1563=m
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
CONFIG_I2C_AMD8111=y
CONFIG_I2C_I801=m
CONFIG_I2C_ISCH=y
CONFIG_I2C_ISMT=m
# CONFIG_I2C_PIIX4 is not set
CONFIG_I2C_NFORCE2=m
CONFIG_I2C_NFORCE2_S4985=m
# CONFIG_I2C_NVIDIA_GPU is not set
CONFIG_I2C_SIS5595=y
CONFIG_I2C_SIS630=y
CONFIG_I2C_SIS96X=m
CONFIG_I2C_VIA=m
CONFIG_I2C_VIAPRO=m

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=m
CONFIG_I2C_DESIGNWARE_CORE=y
# CONFIG_I2C_DESIGNWARE_PLATFORM is not set
CONFIG_I2C_DESIGNWARE_PCI=y
CONFIG_I2C_EMEV2=y
CONFIG_I2C_GPIO=y
CONFIG_I2C_GPIO_FAULT_INJECTOR=y
CONFIG_I2C_KEMPLD=m
CONFIG_I2C_OCORES=m
CONFIG_I2C_PCA_PLATFORM=y
CONFIG_I2C_SIMTEC=m
CONFIG_I2C_XILINX=m

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_PARPORT_LIGHT=y
# CONFIG_I2C_TAOS_EVM is not set

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_MLXCPLD=m
CONFIG_I2C_CROS_EC_TUNNEL=m
# CONFIG_I2C_STUB is not set
CONFIG_I2C_SLAVE=y
# CONFIG_I2C_SLAVE_EEPROM is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_I3C=y
# CONFIG_CDNS_I3C_MASTER is not set
CONFIG_DW_I3C_MASTER=m
CONFIG_SPI=y
CONFIG_SPI_DEBUG=y
CONFIG_SPI_MASTER=y
CONFIG_SPI_MEM=y

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=y
CONFIG_SPI_AXI_SPI_ENGINE=m
CONFIG_SPI_BITBANG=y
CONFIG_SPI_CADENCE=y
CONFIG_SPI_DESIGNWARE=y
# CONFIG_SPI_DW_PCI is not set
CONFIG_SPI_DW_MMIO=m
CONFIG_SPI_NXP_FLEXSPI=m
# CONFIG_SPI_GPIO is not set
# CONFIG_SPI_OC_TINY is not set
CONFIG_SPI_PXA2XX=y
CONFIG_SPI_PXA2XX_PCI=y
# CONFIG_SPI_ROCKCHIP is not set
# CONFIG_SPI_SC18IS602 is not set
CONFIG_SPI_SIFIVE=m
CONFIG_SPI_MXIC=m
CONFIG_SPI_XCOMM=m
CONFIG_SPI_XILINX=y
# CONFIG_SPI_ZYNQMP_GQSPI is not set

#
# SPI Protocol Masters
#
# CONFIG_SPI_SPIDEV is not set
# CONFIG_SPI_LOOPBACK_TEST is not set
# CONFIG_SPI_TLE62X0 is not set
CONFIG_SPI_SLAVE=y
# CONFIG_SPI_SLAVE_TIME is not set
# CONFIG_SPI_SLAVE_SYSTEM_CONTROL is not set
# CONFIG_SPMI is not set
# CONFIG_HSI is not set
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=m
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_GPIO=m

#
# PPS generators support
#

#
# PTP clock support
#

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PINCTRL=y
CONFIG_PINMUX=y
CONFIG_PINCONF=y
CONFIG_GENERIC_PINCONF=y
CONFIG_DEBUG_PINCTRL=y
CONFIG_PINCTRL_AMD=y
CONFIG_PINCTRL_MCP23S08=y
CONFIG_PINCTRL_SX150X=y
CONFIG_PINCTRL_BAYTRAIL=y
CONFIG_PINCTRL_CHERRYVIEW=m
CONFIG_PINCTRL_INTEL=y
CONFIG_PINCTRL_BROXTON=y
# CONFIG_PINCTRL_CANNONLAKE is not set
# CONFIG_PINCTRL_CEDARFORK is not set
CONFIG_PINCTRL_DENVERTON=m
CONFIG_PINCTRL_GEMINILAKE=m
# CONFIG_PINCTRL_ICELAKE is not set
CONFIG_PINCTRL_LEWISBURG=y
CONFIG_PINCTRL_SUNRISEPOINT=y
CONFIG_PINCTRL_MADERA=y
CONFIG_PINCTRL_CS47L85=y
CONFIG_PINCTRL_CS47L90=y
CONFIG_GPIOLIB=y
CONFIG_GPIOLIB_FASTPATH_LIMIT=512
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
CONFIG_DEBUG_GPIO=y
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=m
CONFIG_GPIO_MAX730X=m

#
# Memory mapped GPIO drivers
#
CONFIG_GPIO_AMDPT=m
CONFIG_GPIO_DWAPB=m
# CONFIG_GPIO_EXAR is not set
# CONFIG_GPIO_GENERIC_PLATFORM is not set
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_LYNXPOINT is not set
CONFIG_GPIO_MB86S7X=m
CONFIG_GPIO_MENZ127=m
CONFIG_GPIO_MOCKUP=m
CONFIG_GPIO_VX855=y
CONFIG_GPIO_AMD_FCH=y

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_104_DIO_48E=y
# CONFIG_GPIO_104_IDIO_16 is not set
CONFIG_GPIO_104_IDI_48=m
CONFIG_GPIO_F7188X=y
CONFIG_GPIO_GPIO_MM=y
CONFIG_GPIO_IT87=m
CONFIG_GPIO_SCH=y
# CONFIG_GPIO_SCH311X is not set
# CONFIG_GPIO_WINBOND is not set
# CONFIG_GPIO_WS16C48 is not set

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=y
# CONFIG_GPIO_ADP5588_IRQ is not set
CONFIG_GPIO_MAX7300=m
CONFIG_GPIO_MAX732X=m
CONFIG_GPIO_PCA953X=y
# CONFIG_GPIO_PCA953X_IRQ is not set
# CONFIG_GPIO_PCF857X is not set
CONFIG_GPIO_TPIC2810=y

#
# MFD GPIO expanders
#
CONFIG_GPIO_ADP5520=m
# CONFIG_GPIO_ARIZONA is not set
CONFIG_GPIO_BD9571MWV=m
CONFIG_GPIO_DA9052=y
CONFIG_GPIO_KEMPLD=m
CONFIG_GPIO_MADERA=m
CONFIG_GPIO_TPS65086=m
CONFIG_GPIO_TPS6586X=y
CONFIG_GPIO_TPS65912=m
CONFIG_GPIO_TQMX86=y
# CONFIG_GPIO_TWL4030 is not set
# CONFIG_GPIO_TWL6040 is not set
CONFIG_GPIO_UCB1400=m
CONFIG_GPIO_WHISKEY_COVE=m
CONFIG_GPIO_WM8350=m

#
# PCI GPIO expanders
#
CONFIG_GPIO_AMD8111=m
# CONFIG_GPIO_BT8XX is not set
CONFIG_GPIO_ML_IOH=y
CONFIG_GPIO_PCI_IDIO_16=y
CONFIG_GPIO_PCIE_IDIO_24=y
CONFIG_GPIO_RDC321X=m

#
# SPI GPIO expanders
#
# CONFIG_GPIO_MAX3191X is not set
CONFIG_GPIO_MAX7301=m
# CONFIG_GPIO_MC33880 is not set
# CONFIG_GPIO_PISOSR is not set
# CONFIG_GPIO_XRA1403 is not set
CONFIG_W1=y

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=m
CONFIG_W1_MASTER_DS2482=m
# CONFIG_W1_MASTER_DS1WM is not set
# CONFIG_W1_MASTER_GPIO is not set

#
# 1-wire Slaves
#
# CONFIG_W1_SLAVE_THERM is not set
# CONFIG_W1_SLAVE_SMEM is not set
CONFIG_W1_SLAVE_DS2405=m
# CONFIG_W1_SLAVE_DS2408 is not set
# CONFIG_W1_SLAVE_DS2413 is not set
# CONFIG_W1_SLAVE_DS2406 is not set
CONFIG_W1_SLAVE_DS2423=y
# CONFIG_W1_SLAVE_DS2805 is not set
CONFIG_W1_SLAVE_DS2431=y
CONFIG_W1_SLAVE_DS2433=m
CONFIG_W1_SLAVE_DS2433_CRC=y
CONFIG_W1_SLAVE_DS2438=y
CONFIG_W1_SLAVE_DS2780=m
CONFIG_W1_SLAVE_DS2781=y
# CONFIG_W1_SLAVE_DS28E04 is not set
# CONFIG_W1_SLAVE_DS28E17 is not set
CONFIG_POWER_AVS=y
CONFIG_POWER_RESET=y
# CONFIG_POWER_RESET_RESTART is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=m
# CONFIG_GENERIC_ADC_BATTERY is not set
# CONFIG_MAX8925_POWER is not set
# CONFIG_WM8350_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_88PM860X is not set
CONFIG_CHARGER_ADP5061=y
CONFIG_BATTERY_DS2760=m
# CONFIG_BATTERY_DS2780 is not set
CONFIG_BATTERY_DS2781=m
CONFIG_BATTERY_DS2782=m
# CONFIG_BATTERY_SBS is not set
# CONFIG_CHARGER_SBS is not set
CONFIG_MANAGER_SBS=y
# CONFIG_BATTERY_BQ27XXX is not set
CONFIG_BATTERY_DA9052=m
CONFIG_CHARGER_AXP20X=m
CONFIG_BATTERY_AXP20X=m
CONFIG_AXP20X_POWER=m
CONFIG_AXP288_FUEL_GAUGE=m
CONFIG_BATTERY_MAX17040=m
CONFIG_BATTERY_MAX17042=y
# CONFIG_BATTERY_MAX1721X is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_TWL4030 is not set
CONFIG_CHARGER_LP8727=y
CONFIG_CHARGER_LP8788=m
CONFIG_CHARGER_GPIO=y
CONFIG_CHARGER_MANAGER=y
CONFIG_CHARGER_LTC3651=m
CONFIG_CHARGER_MAX14577=m
# CONFIG_CHARGER_MAX8998 is not set
CONFIG_CHARGER_BQ2415X=m
CONFIG_CHARGER_BQ24190=m
CONFIG_CHARGER_BQ24257=y
# CONFIG_CHARGER_BQ24735 is not set
# CONFIG_CHARGER_BQ25890 is not set
CONFIG_CHARGER_SMB347=m
CONFIG_CHARGER_TPS65090=m
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
CONFIG_BATTERY_RT5033=m
CONFIG_CHARGER_RT9455=y
# CONFIG_CHARGER_CROS_USBPD is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=m
CONFIG_SENSORS_ABITUGURU3=m
# CONFIG_SENSORS_AD7314 is not set
# CONFIG_SENSORS_AD7414 is not set
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
CONFIG_SENSORS_ADM1026=y
CONFIG_SENSORS_ADM1029=y
# CONFIG_SENSORS_ADM1031 is not set
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7310=y
CONFIG_SENSORS_ADT7410=m
# CONFIG_SENSORS_ADT7411 is not set
# CONFIG_SENSORS_ADT7462 is not set
# CONFIG_SENSORS_ADT7470 is not set
CONFIG_SENSORS_ADT7475=m
CONFIG_SENSORS_ASC7621=m
CONFIG_SENSORS_K8TEMP=m
# CONFIG_SENSORS_K10TEMP is not set
CONFIG_SENSORS_FAM15H_POWER=y
# CONFIG_SENSORS_APPLESMC is not set
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ASPEED is not set
CONFIG_SENSORS_ATXP1=m
CONFIG_SENSORS_DS620=m
CONFIG_SENSORS_DS1621=m
CONFIG_SENSORS_DELL_SMM=y
CONFIG_SENSORS_DA9052_ADC=y
CONFIG_SENSORS_I5K_AMB=y
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_MC13783_ADC=m
CONFIG_SENSORS_FSCHMD=m
CONFIG_SENSORS_FTSTEUTATES=m
CONFIG_SENSORS_GL518SM=y
# CONFIG_SENSORS_GL520SM is not set
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_G762=y
CONFIG_SENSORS_HIH6130=m
CONFIG_SENSORS_IIO_HWMON=m
CONFIG_SENSORS_I5500=m
CONFIG_SENSORS_CORETEMP=m
# CONFIG_SENSORS_IT87 is not set
CONFIG_SENSORS_JC42=m
CONFIG_SENSORS_POWR1220=y
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LTC2945=m
CONFIG_SENSORS_LTC2990=y
CONFIG_SENSORS_LTC4151=m
# CONFIG_SENSORS_LTC4215 is not set
CONFIG_SENSORS_LTC4222=m
CONFIG_SENSORS_LTC4245=y
# CONFIG_SENSORS_LTC4260 is not set
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_MAX1111=y
CONFIG_SENSORS_MAX16065=m
# CONFIG_SENSORS_MAX1619 is not set
CONFIG_SENSORS_MAX1668=m
# CONFIG_SENSORS_MAX197 is not set
# CONFIG_SENSORS_MAX31722 is not set
CONFIG_SENSORS_MAX6621=y
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=y
# CONFIG_SENSORS_MAX6697 is not set
# CONFIG_SENSORS_MAX31790 is not set
# CONFIG_SENSORS_MCP3021 is not set
CONFIG_SENSORS_TC654=m
CONFIG_SENSORS_MENF21BMC_HWMON=y
CONFIG_SENSORS_ADCXX=y
# CONFIG_SENSORS_LM63 is not set
CONFIG_SENSORS_LM70=m
CONFIG_SENSORS_LM73=y
# CONFIG_SENSORS_LM75 is not set
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=m
CONFIG_SENSORS_LM80=m
CONFIG_SENSORS_LM83=m
CONFIG_SENSORS_LM85=m
CONFIG_SENSORS_LM87=m
CONFIG_SENSORS_LM90=m
CONFIG_SENSORS_LM92=y
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_LM95234 is not set
# CONFIG_SENSORS_LM95241 is not set
# CONFIG_SENSORS_LM95245 is not set
CONFIG_SENSORS_PC87360=y
# CONFIG_SENSORS_PC87427 is not set
CONFIG_SENSORS_NTC_THERMISTOR=m
CONFIG_SENSORS_NCT6683=m
CONFIG_SENSORS_NCT6775=y
# CONFIG_SENSORS_NCT7802 is not set
CONFIG_SENSORS_NCT7904=y
CONFIG_SENSORS_NPCM7XX=m
CONFIG_SENSORS_OCC_P8_I2C=m
CONFIG_SENSORS_OCC=y
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=m
# CONFIG_SENSORS_SHT3x is not set
CONFIG_SENSORS_SHTC1=y
CONFIG_SENSORS_SIS5595=y
CONFIG_SENSORS_DME1737=m
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=m
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SMSC47B397=y
CONFIG_SENSORS_SCH56XX_COMMON=y
CONFIG_SENSORS_SCH5627=m
CONFIG_SENSORS_SCH5636=y
# CONFIG_SENSORS_STTS751 is not set
# CONFIG_SENSORS_SMM665 is not set
# CONFIG_SENSORS_ADC128D818 is not set
CONFIG_SENSORS_ADS1015=m
CONFIG_SENSORS_ADS7828=m
CONFIG_SENSORS_ADS7871=y
CONFIG_SENSORS_AMC6821=m
CONFIG_SENSORS_INA209=y
CONFIG_SENSORS_INA2XX=m
# CONFIG_SENSORS_INA3221 is not set
# CONFIG_SENSORS_TC74 is not set
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=m
CONFIG_SENSORS_TMP103=y
# CONFIG_SENSORS_TMP108 is not set
CONFIG_SENSORS_TMP401=m
# CONFIG_SENSORS_TMP421 is not set
CONFIG_SENSORS_VIA_CPUTEMP=y
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=m
CONFIG_SENSORS_VT8231=m
CONFIG_SENSORS_W83773G=m
CONFIG_SENSORS_W83781D=m
CONFIG_SENSORS_W83791D=y
CONFIG_SENSORS_W83792D=m
# CONFIG_SENSORS_W83793 is not set
CONFIG_SENSORS_W83795=y
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=m
# CONFIG_SENSORS_W83627EHF is not set
CONFIG_SENSORS_WM8350=m

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=y
CONFIG_SENSORS_ATK0110=y
CONFIG_THERMAL=m
# CONFIG_THERMAL_STATISTICS is not set
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
# CONFIG_THERMAL_HWMON is not set
CONFIG_THERMAL_WRITABLE_TRIPS=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_BANG_BANG=y
CONFIG_THERMAL_GOV_USER_SPACE=y
CONFIG_THERMAL_GOV_POWER_ALLOCATOR=y
# CONFIG_CLOCK_THERMAL is not set
CONFIG_DEVFREQ_THERMAL=y
CONFIG_THERMAL_EMULATION=y

#
# Intel thermal drivers
#
CONFIG_X86_PKG_TEMP_THERMAL=m
CONFIG_INTEL_SOC_DTS_IOSF_CORE=m
CONFIG_INTEL_SOC_DTS_THERMAL=m

#
# ACPI INT340X thermal drivers
#
CONFIG_INT340X_THERMAL=m
CONFIG_ACPI_THERMAL_REL=m
CONFIG_INT3406_THERMAL=m
CONFIG_INTEL_BXT_PMIC_THERMAL=m
CONFIG_INTEL_PCH_THERMAL=m
CONFIG_GENERIC_ADC_THERMAL=m
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set
# CONFIG_WATCHDOG_HANDLE_BOOT_ENABLED is not set
CONFIG_WATCHDOG_SYSFS=y

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
CONFIG_DA9052_WATCHDOG=m
# CONFIG_DA9063_WATCHDOG is not set
# CONFIG_DA9062_WATCHDOG is not set
CONFIG_MENF21BMC_WATCHDOG=m
# CONFIG_MENZ069_WATCHDOG is not set
CONFIG_WDAT_WDT=y
CONFIG_WM8350_WATCHDOG=y
CONFIG_XILINX_WATCHDOG=m
CONFIG_ZIIRAVE_WATCHDOG=y
CONFIG_CADENCE_WATCHDOG=m
# CONFIG_DW_WATCHDOG is not set
CONFIG_TWL4030_WATCHDOG=y
# CONFIG_MAX63XX_WATCHDOG is not set
# CONFIG_RETU_WATCHDOG is not set
CONFIG_ACQUIRE_WDT=y
# CONFIG_ADVANTECH_WDT is not set
CONFIG_ALIM1535_WDT=m
CONFIG_ALIM7101_WDT=y
CONFIG_EBC_C384_WDT=y
CONFIG_F71808E_WDT=m
# CONFIG_SP5100_TCO is not set
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
# CONFIG_IBMASR is not set
CONFIG_WAFER_WDT=m
# CONFIG_I6300ESB_WDT is not set
CONFIG_IE6XX_WDT=m
CONFIG_ITCO_WDT=m
CONFIG_ITCO_VENDOR_SUPPORT=y
# CONFIG_IT8712F_WDT is not set
# CONFIG_IT87_WDT is not set
CONFIG_HP_WATCHDOG=y
# CONFIG_KEMPLD_WDT is not set
CONFIG_HPWDT_NMI_DECODING=y
CONFIG_SC1200_WDT=m
CONFIG_PC87413_WDT=y
# CONFIG_NV_TCO is not set
# CONFIG_60XX_WDT is not set
# CONFIG_CPU5_WDT is not set
CONFIG_SMSC_SCH311X_WDT=m
CONFIG_SMSC37B787_WDT=m
CONFIG_TQMX86_WDT=y
CONFIG_VIA_WDT=y
CONFIG_W83627HF_WDT=m
# CONFIG_W83877F_WDT is not set
CONFIG_W83977F_WDT=y
# CONFIG_MACHZ_WDT is not set
CONFIG_SBC_EPX_C3_WATCHDOG=m
# CONFIG_INTEL_MEI_WDT is not set
CONFIG_NI903X_WDT=y
# CONFIG_NIC7018_WDT is not set
CONFIG_MEN_A21_WDT=y

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=y
# CONFIG_WDTPCI is not set

#
# Watchdog Pretimeout Governors
#
# CONFIG_WATCHDOG_PRETIMEOUT_GOV is not set
CONFIG_SSB_POSSIBLE=y
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_AS3711 is not set
CONFIG_PMIC_ADP5520=y
CONFIG_MFD_AAT2870_CORE=y
# CONFIG_MFD_BCM590XX is not set
CONFIG_MFD_BD9571MWV=y
CONFIG_MFD_AXP20X=m
CONFIG_MFD_AXP20X_I2C=m
CONFIG_MFD_CROS_EC=m
CONFIG_MFD_CROS_EC_CHARDEV=m
CONFIG_MFD_MADERA=y
# CONFIG_MFD_MADERA_I2C is not set
# CONFIG_MFD_MADERA_SPI is not set
# CONFIG_MFD_CS47L35 is not set
CONFIG_MFD_CS47L85=y
CONFIG_MFD_CS47L90=y
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_SPI=y
CONFIG_MFD_DA9052_I2C=y
# CONFIG_MFD_DA9055 is not set
CONFIG_MFD_DA9062=y
CONFIG_MFD_DA9063=m
# CONFIG_MFD_DA9150 is not set
CONFIG_MFD_MC13XXX=m
CONFIG_MFD_MC13XXX_SPI=m
CONFIG_MFD_MC13XXX_I2C=m
# CONFIG_HTC_PASIC3 is not set
# CONFIG_HTC_I2CPLD is not set
CONFIG_MFD_INTEL_QUARK_I2C_GPIO=y
CONFIG_LPC_ICH=m
CONFIG_LPC_SCH=y
CONFIG_INTEL_SOC_PMIC_BXTWC=m
# CONFIG_INTEL_SOC_PMIC_CHTDC_TI is not set
CONFIG_MFD_INTEL_LPSS=y
CONFIG_MFD_INTEL_LPSS_ACPI=y
CONFIG_MFD_INTEL_LPSS_PCI=y
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
CONFIG_MFD_MAX14577=y
# CONFIG_MFD_MAX77693 is not set
CONFIG_MFD_MAX77843=y
CONFIG_MFD_MAX8907=y
CONFIG_MFD_MAX8925=y
# CONFIG_MFD_MAX8997 is not set
CONFIG_MFD_MAX8998=y
# CONFIG_MFD_MT6397 is not set
CONFIG_MFD_MENF21BMC=y
CONFIG_EZX_PCAP=y
CONFIG_MFD_RETU=y
# CONFIG_MFD_PCF50633 is not set
CONFIG_UCB1400_CORE=m
CONFIG_MFD_RDC321X=m
CONFIG_MFD_RT5033=m
# CONFIG_MFD_RC5T583 is not set
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=y
# CONFIG_MFD_SM501 is not set
CONFIG_MFD_SKY81452=y
CONFIG_MFD_SMSC=y
CONFIG_ABX500_CORE=y
CONFIG_AB3100_CORE=y
CONFIG_AB3100_OTP=y
CONFIG_MFD_SYSCON=y
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_MFD_LP3943 is not set
CONFIG_MFD_LP8788=y
CONFIG_MFD_TI_LMU=m
# CONFIG_MFD_PALMAS is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
CONFIG_MFD_TPS65086=y
CONFIG_MFD_TPS65090=y
# CONFIG_MFD_TI_LP873X is not set
CONFIG_MFD_TPS6586X=y
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=m
# CONFIG_MFD_TPS65912_I2C is not set
CONFIG_MFD_TPS65912_SPI=m
CONFIG_MFD_TPS80031=y
CONFIG_TWL4030_CORE=y
CONFIG_MFD_TWL4030_AUDIO=y
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=m
CONFIG_MFD_TQMX86=y
CONFIG_MFD_VX855=y
CONFIG_MFD_ARIZONA=y
# CONFIG_MFD_ARIZONA_I2C is not set
CONFIG_MFD_ARIZONA_SPI=y
CONFIG_MFD_CS47L24=y
# CONFIG_MFD_WM5102 is not set
CONFIG_MFD_WM5110=y
CONFIG_MFD_WM8997=y
# CONFIG_MFD_WM8998 is not set
CONFIG_MFD_WM8400=y
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM831X_SPI is not set
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
# CONFIG_MFD_WM8994 is not set
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
CONFIG_REGULATOR_88PG86X=m
CONFIG_REGULATOR_88PM800=m
# CONFIG_REGULATOR_88PM8607 is not set
CONFIG_REGULATOR_ACT8865=y
# CONFIG_REGULATOR_AD5398 is not set
# CONFIG_REGULATOR_ANATOP is not set
CONFIG_REGULATOR_AAT2870=y
CONFIG_REGULATOR_AB3100=y
# CONFIG_REGULATOR_ARIZONA_LDO1 is not set
CONFIG_REGULATOR_ARIZONA_MICSUPP=m
CONFIG_REGULATOR_AXP20X=m
CONFIG_REGULATOR_BD9571MWV=m
# CONFIG_REGULATOR_DA9052 is not set
CONFIG_REGULATOR_DA9062=y
CONFIG_REGULATOR_DA9063=m
CONFIG_REGULATOR_DA9210=m
CONFIG_REGULATOR_DA9211=y
CONFIG_REGULATOR_FAN53555=y
# CONFIG_REGULATOR_GPIO is not set
# CONFIG_REGULATOR_ISL9305 is not set
CONFIG_REGULATOR_ISL6271A=m
CONFIG_REGULATOR_LM363X=m
CONFIG_REGULATOR_LP3971=m
# CONFIG_REGULATOR_LP3972 is not set
CONFIG_REGULATOR_LP872X=y
CONFIG_REGULATOR_LP8755=m
CONFIG_REGULATOR_LP8788=y
CONFIG_REGULATOR_LTC3589=m
# CONFIG_REGULATOR_LTC3676 is not set
# CONFIG_REGULATOR_MAX14577 is not set
# CONFIG_REGULATOR_MAX1586 is not set
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8907=y
# CONFIG_REGULATOR_MAX8925 is not set
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX8998=y
# CONFIG_REGULATOR_MAX77693 is not set
CONFIG_REGULATOR_MC13XXX_CORE=m
# CONFIG_REGULATOR_MC13783 is not set
CONFIG_REGULATOR_MC13892=m
CONFIG_REGULATOR_MT6311=m
CONFIG_REGULATOR_PCAP=y
# CONFIG_REGULATOR_PFUZE100 is not set
# CONFIG_REGULATOR_PV88060 is not set
CONFIG_REGULATOR_PV88080=y
# CONFIG_REGULATOR_PV88090 is not set
CONFIG_REGULATOR_RT5033=m
CONFIG_REGULATOR_S2MPA01=y
# CONFIG_REGULATOR_S2MPS11 is not set
CONFIG_REGULATOR_S5M8767=y
CONFIG_REGULATOR_SKY81452=m
# CONFIG_REGULATOR_TPS51632 is not set
CONFIG_REGULATOR_TPS62360=m
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=m
# CONFIG_REGULATOR_TPS65086 is not set
# CONFIG_REGULATOR_TPS65090 is not set
# CONFIG_REGULATOR_TPS65132 is not set
CONFIG_REGULATOR_TPS6524X=y
CONFIG_REGULATOR_TPS6586X=m
# CONFIG_REGULATOR_TPS65912 is not set
CONFIG_REGULATOR_TPS80031=y
CONFIG_REGULATOR_TWL4030=m
# CONFIG_REGULATOR_WM8350 is not set
CONFIG_REGULATOR_WM8400=m
CONFIG_CEC_CORE=m
CONFIG_CEC_NOTIFIER=y
# CONFIG_RC_CORE is not set
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_SDR_SUPPORT is not set
# CONFIG_MEDIA_CEC_SUPPORT is not set
CONFIG_MEDIA_CONTROLLER=y
CONFIG_MEDIA_CONTROLLER_DVB=y
CONFIG_VIDEO_DEV=y
# CONFIG_VIDEO_V4L2_SUBDEV_API is not set
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEO_ADV_DEBUG=y
CONFIG_VIDEO_FIXED_MINOR_RANGES=y
CONFIG_V4L2_MEM2MEM_DEV=y
CONFIG_DVB_CORE=y
# CONFIG_DVB_MMAP is not set
CONFIG_DVB_NET=y
CONFIG_DVB_MAX_ADAPTERS=16
# CONFIG_DVB_DYNAMIC_MINORS is not set
CONFIG_DVB_DEMUX_SECTION_LOSS_LOG=y
# CONFIG_DVB_ULE_DEBUG is not set

#
# Media drivers
#
# CONFIG_MEDIA_PCI_SUPPORT is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
CONFIG_V4L_MEM2MEM_DRIVERS=y
CONFIG_VIDEO_MEM2MEM_DEINTERLACE=y
CONFIG_VIDEO_SH_VEU=m
# CONFIG_V4L_TEST_DRIVERS is not set
# CONFIG_DVB_PLATFORM_DRIVERS is not set

#
# Supported MMC/SDIO adapters
#
# CONFIG_SMS_SDIO_DRV is not set
CONFIG_RADIO_ADAPTERS=y
CONFIG_RADIO_SI470X=m
CONFIG_I2C_SI470X=m
CONFIG_RADIO_SI4713=m
# CONFIG_PLATFORM_SI4713 is not set
CONFIG_I2C_SI4713=m
CONFIG_RADIO_SI476X=y
# CONFIG_RADIO_MAXIRADIO is not set
CONFIG_RADIO_TEA5764=y
# CONFIG_RADIO_TEA5764_XTAL is not set
CONFIG_RADIO_SAA7706H=y
CONFIG_RADIO_TEF6862=y
CONFIG_RADIO_WL1273=y

#
# Texas Instruments WL128x FM driver (ST based)
#
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_V4L2=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_DMA_CONTIG=y

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y
CONFIG_MEDIA_ATTACH=y

#
# Audio decoders, processors and mixers
#

#
# RDS decoders
#

#
# Video decoders
#

#
# Video and audio decoders
#

#
# Video encoders
#

#
# Camera sensor devices
#

#
# Flash devices
#

#
# Video improvement chips
#

#
# Audio/Video compression chips
#

#
# SDR tuner chips
#

#
# Miscellaneous helper chips
#

#
# Media SPI Adapters
#
# CONFIG_CXD2880_SPI_DRV is not set
CONFIG_MEDIA_TUNER=y
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MC44S803=y

#
# Multistandard (satellite) frontends
#

#
# Multistandard (cable + terrestrial) frontends
#

#
# DVB-S (satellite) frontends
#

#
# DVB-T (terrestrial) frontends
#

#
# DVB-C (cable) frontends
#

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#

#
# ISDB-T (terrestrial) frontends
#

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#

#
# Digital terrestrial only tuners/PLL
#

#
# SEC control devices for DVB-S
#

#
# Common Interface (EN50221) controller drivers
#

#
# Tools to develop new frontends
#

#
# Graphics support
#
CONFIG_AGP=m
# CONFIG_AGP_AMD64 is not set
# CONFIG_AGP_INTEL is not set
# CONFIG_AGP_SIS is not set
CONFIG_AGP_VIA=m
CONFIG_INTEL_GTT=m
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=m
CONFIG_DRM_MIPI_DSI=y
CONFIG_DRM_DP_AUX_CHARDEV=y
CONFIG_DRM_DEBUG_SELFTEST=m
CONFIG_DRM_KMS_HELPER=m
# CONFIG_DRM_FBDEV_EMULATION is not set
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
# CONFIG_DRM_DP_CEC is not set
CONFIG_DRM_TTM=m
CONFIG_DRM_SCHED=m

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_CH7006 is not set
CONFIG_DRM_I2C_SIL164=m
CONFIG_DRM_I2C_NXP_TDA998X=m
CONFIG_DRM_I2C_NXP_TDA9950=m

#
# ARM devices
#
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_AMDGPU is not set

#
# ACP (Audio CoProcessor) Configuration
#

#
# AMD Library routines
#
# CONFIG_DRM_NOUVEAU is not set
CONFIG_DRM_I915=m
CONFIG_DRM_I915_ALPHA_SUPPORT=y
# CONFIG_DRM_I915_CAPTURE_ERROR is not set
# CONFIG_DRM_I915_USERPTR is not set
# CONFIG_DRM_I915_GVT is not set

#
# drm/i915 Debugging
#
# CONFIG_DRM_I915_WERROR is not set
CONFIG_DRM_I915_DEBUG=y
CONFIG_DRM_I915_SW_FENCE_DEBUG_OBJECTS=y
# CONFIG_DRM_I915_SW_FENCE_CHECK_DAG is not set
# CONFIG_DRM_I915_DEBUG_GUC is not set
CONFIG_DRM_I915_SELFTEST=y
CONFIG_DRM_I915_LOW_LEVEL_TRACEPOINTS=y
# CONFIG_DRM_I915_DEBUG_VBLANK_EVADE is not set
CONFIG_DRM_I915_DEBUG_RUNTIME_PM=y
CONFIG_DRM_VGEM=m
CONFIG_DRM_VKMS=m
CONFIG_DRM_VMWGFX=m
# CONFIG_DRM_VMWGFX_FBCON is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
CONFIG_DRM_AST=m
CONFIG_DRM_MGAG200=m
CONFIG_DRM_CIRRUS_QEMU=m
CONFIG_DRM_QXL=m
# CONFIG_DRM_BOCHS is not set
# CONFIG_DRM_VIRTIO_GPU is not set
CONFIG_DRM_PANEL=y

#
# Display Panels
#
CONFIG_DRM_PANEL_RASPBERRYPI_TOUCHSCREEN=m
CONFIG_DRM_BRIDGE=y
CONFIG_DRM_PANEL_BRIDGE=y

#
# Display Interface Bridges
#
CONFIG_DRM_ANALOGIX_ANX78XX=m
CONFIG_DRM_ETNAVIV=m
# CONFIG_DRM_ETNAVIV_THERMAL is not set
# CONFIG_DRM_HISI_HIBMC is not set
# CONFIG_DRM_TINYDRM is not set
# CONFIG_DRM_LEGACY is not set
CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=m
CONFIG_DRM_LIB_RANDOM=y

#
# Frame buffer Devices
#
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_DDC=y
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=m
CONFIG_FB_SVGALIB=y
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
CONFIG_FB_CIRRUS=m
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=y
CONFIG_FB_ASILIANT=y
CONFIG_FB_IMSTT=y
# CONFIG_FB_VGA16 is not set
CONFIG_FB_VESA=y
CONFIG_FB_N411=m
CONFIG_FB_HGA=y
# CONFIG_FB_OPENCORES is not set
CONFIG_FB_S1D13XXX=y
CONFIG_FB_NVIDIA=m
# CONFIG_FB_NVIDIA_I2C is not set
CONFIG_FB_NVIDIA_DEBUG=y
CONFIG_FB_NVIDIA_BACKLIGHT=y
# CONFIG_FB_RIVA is not set
CONFIG_FB_I740=y
CONFIG_FB_LE80578=y
CONFIG_FB_CARILLO_RANCH=y
# CONFIG_FB_MATROX is not set
CONFIG_FB_RADEON=y
# CONFIG_FB_RADEON_I2C is not set
CONFIG_FB_RADEON_BACKLIGHT=y
# CONFIG_FB_RADEON_DEBUG is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
CONFIG_FB_SAVAGE=y
# CONFIG_FB_SAVAGE_I2C is not set
# CONFIG_FB_SAVAGE_ACCEL is not set
CONFIG_FB_SIS=m
CONFIG_FB_SIS_300=y
CONFIG_FB_SIS_315=y
CONFIG_FB_VIA=m
# CONFIG_FB_VIA_DIRECT_PROCFS is not set
CONFIG_FB_VIA_X_COMPATIBILITY=y
CONFIG_FB_NEOMAGIC=y
CONFIG_FB_KYRO=y
# CONFIG_FB_3DFX is not set
CONFIG_FB_VOODOO1=y
CONFIG_FB_VT8623=y
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
CONFIG_FB_PM3=y
CONFIG_FB_CARMINE=y
# CONFIG_FB_CARMINE_DRAM_EVAL is not set
CONFIG_CARMINE_DRAM_CUSTOM=y
CONFIG_FB_IBM_GXT4500=y
CONFIG_FB_VIRTUAL=m
CONFIG_FB_METRONOME=m
CONFIG_FB_MB862XX=m
CONFIG_FB_MB862XX_PCI_GDC=y
CONFIG_FB_MB862XX_I2C=y
CONFIG_FB_SIMPLE=y
CONFIG_FB_SM712=m
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=m
# CONFIG_LCD_L4F00242T03 is not set
CONFIG_LCD_LMS283GF05=m
CONFIG_LCD_LTV350QV=m
# CONFIG_LCD_ILI922X is not set
CONFIG_LCD_ILI9320=m
CONFIG_LCD_TDO24M=m
CONFIG_LCD_VGG2432A4=m
# CONFIG_LCD_PLATFORM is not set
CONFIG_LCD_AMS369FG06=m
# CONFIG_LCD_LMS501KF03 is not set
CONFIG_LCD_HX8357=m
# CONFIG_LCD_OTM3225A is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=m
CONFIG_BACKLIGHT_LM3533=m
# CONFIG_BACKLIGHT_CARILLO_RANCH is not set
CONFIG_BACKLIGHT_DA9052=m
# CONFIG_BACKLIGHT_MAX8925 is not set
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_PM8941_WLED=y
# CONFIG_BACKLIGHT_SAHARA is not set
CONFIG_BACKLIGHT_ADP5520=y
CONFIG_BACKLIGHT_ADP8860=y
# CONFIG_BACKLIGHT_ADP8870 is not set
CONFIG_BACKLIGHT_88PM860X=y
CONFIG_BACKLIGHT_AAT2870=y
CONFIG_BACKLIGHT_LM3639=m
CONFIG_BACKLIGHT_PANDORA=m
CONFIG_BACKLIGHT_SKY81452=y
CONFIG_BACKLIGHT_GPIO=y
CONFIG_BACKLIGHT_LV5207LP=y
CONFIG_BACKLIGHT_BD6107=m
CONFIG_BACKLIGHT_ARCXCNN=m
CONFIG_VGASTATE=y
CONFIG_HDMI=y
# CONFIG_LOGO is not set
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
CONFIG_SOUND_OSS_CORE_PRECLAIM=y
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_PCM_ELD=y
CONFIG_SND_PCM_IEC958=y
CONFIG_SND_DMAENGINE_PCM=y
CONFIG_SND_JACK=y
CONFIG_SND_JACK_INPUT_DEV=y
CONFIG_SND_OSSEMUL=y
# CONFIG_SND_MIXER_OSS is not set
CONFIG_SND_PCM_OSS=y
# CONFIG_SND_PCM_OSS_PLUGINS is not set
CONFIG_SND_PCM_TIMER=y
# CONFIG_SND_DYNAMIC_MINORS is not set
CONFIG_SND_SUPPORT_OLD_API=y
CONFIG_SND_PROC_FS=y
CONFIG_SND_VERBOSE_PROCFS=y
# CONFIG_SND_VERBOSE_PRINTK is not set
CONFIG_SND_DEBUG=y
# CONFIG_SND_DEBUG_VERBOSE is not set
# CONFIG_SND_PCM_XRUN_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_DMA_SGBUF=y
# CONFIG_SND_SEQUENCER is not set
CONFIG_SND_AC97_CODEC=y
# CONFIG_SND_DRIVERS is not set
# CONFIG_SND_PCI is not set

#
# HD-Audio
#
CONFIG_SND_HDA_PREALLOC_SIZE=64
CONFIG_SND_SPI=y
CONFIG_SND_SOC=y
CONFIG_SND_SOC_AC97_BUS=y
CONFIG_SND_SOC_GENERIC_DMAENGINE_PCM=y
CONFIG_SND_SOC_AMD_ACP=m
# CONFIG_SND_SOC_AMD_CZ_DA7219MX98357_MACH is not set
CONFIG_SND_SOC_AMD_CZ_RT5645_MACH=m
# CONFIG_SND_SOC_AMD_ACP3x is not set
CONFIG_SND_ATMEL_SOC=y
# CONFIG_SND_DESIGNWARE_I2S is not set

#
# SoC Audio for Freescale CPUs
#

#
# Common SoC Audio options for Freescale CPUs:
#
# CONFIG_SND_SOC_FSL_ASRC is not set
CONFIG_SND_SOC_FSL_SAI=y
# CONFIG_SND_SOC_FSL_SSI is not set
CONFIG_SND_SOC_FSL_SPDIF=y
# CONFIG_SND_SOC_FSL_ESAI is not set
CONFIG_SND_SOC_FSL_MICFIL=y
# CONFIG_SND_SOC_IMX_AUDMUX is not set
# CONFIG_SND_I2S_HI6210_I2S is not set
CONFIG_SND_SOC_IMG=y
CONFIG_SND_SOC_IMG_I2S_IN=y
CONFIG_SND_SOC_IMG_I2S_OUT=y
CONFIG_SND_SOC_IMG_PARALLEL_OUT=y
CONFIG_SND_SOC_IMG_SPDIF_IN=y
CONFIG_SND_SOC_IMG_SPDIF_OUT=y
# CONFIG_SND_SOC_IMG_PISTACHIO_INTERNAL_DAC is not set
# CONFIG_SND_SOC_INTEL_SST_TOPLEVEL is not set
# CONFIG_SND_SOC_MTK_BTCVSD is not set

#
# STMicroelectronics STM32 SOC audio support
#
CONFIG_SND_SOC_XILINX_I2S=m
CONFIG_SND_SOC_XILINX_AUDIO_FORMATTER=m
CONFIG_SND_SOC_XILINX_SPDIF=m
CONFIG_SND_SOC_XTFPGA_I2S=y
CONFIG_ZX_TDM=m
CONFIG_SND_SOC_I2C_AND_SPI=y

#
# CODEC drivers
#
CONFIG_SND_SOC_AC97_CODEC=y
CONFIG_SND_SOC_ADAU_UTILS=y
# CONFIG_SND_SOC_ADAU1701 is not set
CONFIG_SND_SOC_ADAU17X1=y
CONFIG_SND_SOC_ADAU1761=y
CONFIG_SND_SOC_ADAU1761_I2C=y
CONFIG_SND_SOC_ADAU1761_SPI=y
# CONFIG_SND_SOC_ADAU7002 is not set
# CONFIG_SND_SOC_AK4104 is not set
CONFIG_SND_SOC_AK4118=m
CONFIG_SND_SOC_AK4458=m
CONFIG_SND_SOC_AK4554=m
CONFIG_SND_SOC_AK4613=m
# CONFIG_SND_SOC_AK4642 is not set
CONFIG_SND_SOC_AK5386=y
# CONFIG_SND_SOC_AK5558 is not set
CONFIG_SND_SOC_ALC5623=y
CONFIG_SND_SOC_BD28623=m
CONFIG_SND_SOC_BT_SCO=y
CONFIG_SND_SOC_CROS_EC_CODEC=m
# CONFIG_SND_SOC_CS35L32 is not set
# CONFIG_SND_SOC_CS35L33 is not set
CONFIG_SND_SOC_CS35L34=m
CONFIG_SND_SOC_CS35L35=m
# CONFIG_SND_SOC_CS35L36 is not set
CONFIG_SND_SOC_CS42L42=m
CONFIG_SND_SOC_CS42L51=y
CONFIG_SND_SOC_CS42L51_I2C=y
CONFIG_SND_SOC_CS42L52=m
CONFIG_SND_SOC_CS42L56=m
CONFIG_SND_SOC_CS42L73=m
# CONFIG_SND_SOC_CS4265 is not set
CONFIG_SND_SOC_CS4270=y
CONFIG_SND_SOC_CS4271=m
# CONFIG_SND_SOC_CS4271_I2C is not set
CONFIG_SND_SOC_CS4271_SPI=m
# CONFIG_SND_SOC_CS42XX8_I2C is not set
CONFIG_SND_SOC_CS43130=m
# CONFIG_SND_SOC_CS4341 is not set
CONFIG_SND_SOC_CS4349=y
CONFIG_SND_SOC_CS53L30=y
CONFIG_SND_SOC_DMIC=y
CONFIG_SND_SOC_HDMI_CODEC=m
CONFIG_SND_SOC_ES7134=y
CONFIG_SND_SOC_ES7241=y
# CONFIG_SND_SOC_ES8316 is not set
CONFIG_SND_SOC_ES8328=m
# CONFIG_SND_SOC_ES8328_I2C is not set
CONFIG_SND_SOC_ES8328_SPI=m
# CONFIG_SND_SOC_GTM601 is not set
# CONFIG_SND_SOC_INNO_RK3036 is not set
# CONFIG_SND_SOC_MAX98088 is not set
CONFIG_SND_SOC_MAX98504=y
CONFIG_SND_SOC_MAX9867=y
CONFIG_SND_SOC_MAX98927=m
# CONFIG_SND_SOC_MAX98373 is not set
CONFIG_SND_SOC_MAX9860=y
CONFIG_SND_SOC_MSM8916_WCD_DIGITAL=m
# CONFIG_SND_SOC_PCM1681 is not set
# CONFIG_SND_SOC_PCM1789_I2C is not set
# CONFIG_SND_SOC_PCM179X_I2C is not set
# CONFIG_SND_SOC_PCM179X_SPI is not set
CONFIG_SND_SOC_PCM186X=m
CONFIG_SND_SOC_PCM186X_I2C=m
CONFIG_SND_SOC_PCM186X_SPI=m
CONFIG_SND_SOC_PCM3060=y
CONFIG_SND_SOC_PCM3060_I2C=m
CONFIG_SND_SOC_PCM3060_SPI=y
CONFIG_SND_SOC_PCM3168A=y
CONFIG_SND_SOC_PCM3168A_I2C=y
CONFIG_SND_SOC_PCM3168A_SPI=y
CONFIG_SND_SOC_PCM512x=m
# CONFIG_SND_SOC_PCM512x_I2C is not set
CONFIG_SND_SOC_PCM512x_SPI=m
# CONFIG_SND_SOC_RK3328 is not set
CONFIG_SND_SOC_RL6231=y
CONFIG_SND_SOC_RT5616=y
CONFIG_SND_SOC_RT5631=y
CONFIG_SND_SOC_RT5645=m
CONFIG_SND_SOC_SGTL5000=m
CONFIG_SND_SOC_SI476X=y
CONFIG_SND_SOC_SIGMADSP=y
CONFIG_SND_SOC_SIGMADSP_REGMAP=y
CONFIG_SND_SOC_SIMPLE_AMPLIFIER=m
# CONFIG_SND_SOC_SIRF_AUDIO_CODEC is not set
CONFIG_SND_SOC_SPDIF=y
CONFIG_SND_SOC_SSM2305=y
# CONFIG_SND_SOC_SSM2602_SPI is not set
# CONFIG_SND_SOC_SSM2602_I2C is not set
CONFIG_SND_SOC_SSM4567=y
# CONFIG_SND_SOC_STA32X is not set
CONFIG_SND_SOC_STA350=y
# CONFIG_SND_SOC_STI_SAS is not set
CONFIG_SND_SOC_TAS2552=y
CONFIG_SND_SOC_TAS5086=y
# CONFIG_SND_SOC_TAS571X is not set
CONFIG_SND_SOC_TAS5720=m
CONFIG_SND_SOC_TAS6424=y
CONFIG_SND_SOC_TDA7419=m
CONFIG_SND_SOC_TFA9879=y
CONFIG_SND_SOC_TLV320AIC23=m
CONFIG_SND_SOC_TLV320AIC23_I2C=m
CONFIG_SND_SOC_TLV320AIC23_SPI=m
CONFIG_SND_SOC_TLV320AIC31XX=y
CONFIG_SND_SOC_TLV320AIC32X4=y
CONFIG_SND_SOC_TLV320AIC32X4_I2C=m
CONFIG_SND_SOC_TLV320AIC32X4_SPI=y
# CONFIG_SND_SOC_TLV320AIC3X is not set
CONFIG_SND_SOC_TS3A227E=m
CONFIG_SND_SOC_TSCS42XX=y
# CONFIG_SND_SOC_TSCS454 is not set
CONFIG_SND_SOC_WM8510=y
CONFIG_SND_SOC_WM8523=m
CONFIG_SND_SOC_WM8524=y
CONFIG_SND_SOC_WM8580=y
CONFIG_SND_SOC_WM8711=y
CONFIG_SND_SOC_WM8728=m
CONFIG_SND_SOC_WM8731=m
CONFIG_SND_SOC_WM8737=y
CONFIG_SND_SOC_WM8741=m
CONFIG_SND_SOC_WM8750=y
CONFIG_SND_SOC_WM8753=m
CONFIG_SND_SOC_WM8770=y
CONFIG_SND_SOC_WM8776=y
CONFIG_SND_SOC_WM8782=y
CONFIG_SND_SOC_WM8804=m
CONFIG_SND_SOC_WM8804_I2C=m
# CONFIG_SND_SOC_WM8804_SPI is not set
CONFIG_SND_SOC_WM8903=y
# CONFIG_SND_SOC_WM8904 is not set
# CONFIG_SND_SOC_WM8960 is not set
# CONFIG_SND_SOC_WM8962 is not set
CONFIG_SND_SOC_WM8974=m
CONFIG_SND_SOC_WM8978=m
CONFIG_SND_SOC_WM8985=y
# CONFIG_SND_SOC_ZX_AUD96P22 is not set
# CONFIG_SND_SOC_MAX9759 is not set
CONFIG_SND_SOC_MT6351=y
CONFIG_SND_SOC_MT6358=m
CONFIG_SND_SOC_NAU8540=m
CONFIG_SND_SOC_NAU8810=m
CONFIG_SND_SOC_NAU8822=m
# CONFIG_SND_SOC_NAU8824 is not set
# CONFIG_SND_SOC_TPA6130A2 is not set
CONFIG_SND_SIMPLE_CARD_UTILS=y
CONFIG_SND_SIMPLE_CARD=y
CONFIG_SND_X86=y
CONFIG_HDMI_LPE_AUDIO=m
CONFIG_AC97_BUS=y

#
# HID support
#
CONFIG_HID=m
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
CONFIG_UHID=m
# CONFIG_HID_GENERIC is not set

#
# Special HID drivers
#
CONFIG_HID_A4TECH=m
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=m
CONFIG_HID_ASUS=m
# CONFIG_HID_AUREAL is not set
# CONFIG_HID_BELKIN is not set
CONFIG_HID_CHERRY=m
CONFIG_HID_CHICONY=m
CONFIG_HID_COUGAR=m
# CONFIG_HID_PRODIKEYS is not set
# CONFIG_HID_CMEDIA is not set
CONFIG_HID_CYPRESS=m
CONFIG_HID_DRAGONRISE=m
CONFIG_DRAGONRISE_FF=y
CONFIG_HID_EMS_FF=m
CONFIG_HID_ELECOM=m
# CONFIG_HID_EZKEY is not set
CONFIG_HID_GEMBIRD=m
CONFIG_HID_GFRM=m
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_WALTOP is not set
# CONFIG_HID_VIEWSONIC is not set
CONFIG_HID_GYRATION=m
CONFIG_HID_ICADE=m
CONFIG_HID_ITE=m
# CONFIG_HID_JABRA is not set
# CONFIG_HID_TWINHAN is not set
CONFIG_HID_KENSINGTON=m
# CONFIG_HID_LCPOWER is not set
CONFIG_HID_LED=m
# CONFIG_HID_LENOVO is not set
# CONFIG_HID_LOGITECH is not set
# CONFIG_HID_MAGICMOUSE is not set
# CONFIG_HID_MALTRON is not set
# CONFIG_HID_MAYFLASH is not set
CONFIG_HID_REDRAGON=m
# CONFIG_HID_MICROSOFT is not set
CONFIG_HID_MONTEREY=m
CONFIG_HID_MULTITOUCH=m
# CONFIG_HID_NTI is not set
CONFIG_HID_ORTEK=m
CONFIG_HID_PANTHERLORD=m
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=m
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PLANTRONICS is not set
CONFIG_HID_PRIMAX=m
CONFIG_HID_SAITEK=m
CONFIG_HID_SAMSUNG=m
CONFIG_HID_SPEEDLINK=m
# CONFIG_HID_STEAM is not set
CONFIG_HID_STEELSERIES=m
# CONFIG_HID_SUNPLUS is not set
CONFIG_HID_RMI=m
CONFIG_HID_GREENASIA=m
CONFIG_GREENASIA_FF=y
# CONFIG_HID_SMARTJOYPLUS is not set
CONFIG_HID_TIVO=m
CONFIG_HID_TOPSEED=m
CONFIG_HID_THINGM=m
# CONFIG_HID_THRUSTMASTER is not set
CONFIG_HID_UDRAW_PS3=m
# CONFIG_HID_WIIMOTE is not set
CONFIG_HID_XINMO=m
CONFIG_HID_ZEROPLUS=m
# CONFIG_ZEROPLUS_FF is not set
# CONFIG_HID_ZYDACRON is not set
CONFIG_HID_SENSOR_HUB=m
CONFIG_HID_SENSOR_CUSTOM_SENSOR=m
# CONFIG_HID_ALPS is not set

#
# I2C HID support
#
CONFIG_I2C_HID=m

#
# Intel ISH HID support
#
CONFIG_INTEL_ISH_HID=m
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set
CONFIG_USB_PCI=y

#
# USB port drivers
#

#
# USB Physical Layer drivers
#
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_TAHVO_USB is not set
# CONFIG_USB_GADGET is not set
# CONFIG_TYPEC is not set
# CONFIG_USB_ROLE_SWITCH is not set
# CONFIG_USB_LED_TRIG is not set
# CONFIG_USB_ULPI_BUS is not set
CONFIG_UWB=m
CONFIG_UWB_WHCI=m
CONFIG_MMC=m
# CONFIG_MMC_BLOCK is not set
# CONFIG_SDIO_UART is not set
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_DEBUG=y
CONFIG_MMC_SDHCI=m
# CONFIG_MMC_SDHCI_PCI is not set
CONFIG_MMC_SDHCI_ACPI=m
CONFIG_MMC_SDHCI_PLTFM=m
CONFIG_MMC_SDHCI_F_SDH30=m
# CONFIG_MMC_TIFM_SD is not set
# CONFIG_MMC_SPI is not set
CONFIG_MMC_CB710=m
CONFIG_MMC_VIA_SDMMC=m
CONFIG_MMC_USDHI6ROL0=m
CONFIG_MMC_CQHCI=m
CONFIG_MMC_TOSHIBA_PCI=m
CONFIG_MMC_MTK=m
CONFIG_MMC_SDHCI_XENON=m
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
# CONFIG_LEDS_CLASS_FLASH is not set
# CONFIG_LEDS_BRIGHTNESS_HW_CHANGED is not set

#
# LED drivers
#
CONFIG_LEDS_88PM860X=y
CONFIG_LEDS_APU=y
CONFIG_LEDS_LM3530=m
# CONFIG_LEDS_LM3533 is not set
CONFIG_LEDS_LM3642=m
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=m
CONFIG_LEDS_LP3952=y
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=m
# CONFIG_LEDS_LP5562 is not set
CONFIG_LEDS_LP8501=m
CONFIG_LEDS_LP8788=m
CONFIG_LEDS_CLEVO_MAIL=m
CONFIG_LEDS_PCA955X=y
# CONFIG_LEDS_PCA955X_GPIO is not set
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_WM8350=m
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_DAC124S085=m
CONFIG_LEDS_REGULATOR=m
CONFIG_LEDS_BD2802=y
CONFIG_LEDS_INTEL_SS4200=y
CONFIG_LEDS_LT3593=m
CONFIG_LEDS_ADP5520=y
CONFIG_LEDS_MC13783=m
CONFIG_LEDS_TCA6507=y
CONFIG_LEDS_TLC591XX=y
# CONFIG_LEDS_LM355x is not set
# CONFIG_LEDS_MENF21BMC is not set

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
CONFIG_LEDS_MLXCPLD=m
CONFIG_LEDS_MLXREG=y
CONFIG_LEDS_USER=m
# CONFIG_LEDS_NIC78BX is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
# CONFIG_LEDS_TRIGGER_ONESHOT is not set
CONFIG_LEDS_TRIGGER_MTD=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=m
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_ACTIVITY=y
CONFIG_LEDS_TRIGGER_GPIO=y
CONFIG_LEDS_TRIGGER_DEFAULT_ON=m

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
CONFIG_LEDS_TRIGGER_CAMERA=y
# CONFIG_LEDS_TRIGGER_PANIC is not set
# CONFIG_LEDS_TRIGGER_NETDEV is not set
CONFIG_LEDS_TRIGGER_PATTERN=y
CONFIG_LEDS_TRIGGER_AUDIO=m
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
CONFIG_EDAC_DEBUG=y
CONFIG_EDAC_DECODE_MCE=y
CONFIG_EDAC_AMD64=m
# CONFIG_EDAC_AMD64_ERROR_INJECTION is not set
# CONFIG_EDAC_E752X is not set
CONFIG_EDAC_I82975X=m
# CONFIG_EDAC_I3000 is not set
CONFIG_EDAC_I3200=m
CONFIG_EDAC_IE31200=y
# CONFIG_EDAC_X38 is not set
CONFIG_EDAC_I5400=y
# CONFIG_EDAC_I7CORE is not set
CONFIG_EDAC_I5000=m
# CONFIG_EDAC_I5100 is not set
CONFIG_EDAC_I7300=y
CONFIG_EDAC_PND2=m
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
# CONFIG_RTC_CLASS is not set
# CONFIG_DMADEVICES is not set

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
CONFIG_SW_SYNC=y
# CONFIG_UDMABUF is not set
CONFIG_AUXDISPLAY=y
CONFIG_HD44780=m
CONFIG_IMG_ASCII_LCD=y
CONFIG_PANEL_CHANGE_MESSAGE=y
CONFIG_PANEL_BOOT_MESSAGE=""
# CONFIG_CHARLCD_BL_OFF is not set
# CONFIG_CHARLCD_BL_ON is not set
CONFIG_CHARLCD_BL_FLASH=y
CONFIG_CHARLCD=m
CONFIG_UIO=m
CONFIG_UIO_CIF=m
CONFIG_UIO_PDRV_GENIRQ=m
CONFIG_UIO_DMEM_GENIRQ=m
CONFIG_UIO_AEC=m
CONFIG_UIO_SERCOS3=m
# CONFIG_UIO_PCI_GENERIC is not set
CONFIG_UIO_NETX=m
CONFIG_UIO_PRUSS=m
CONFIG_UIO_MF624=m
CONFIG_VFIO_IOMMU_TYPE1=m
CONFIG_VFIO=m
# CONFIG_VFIO_NOIOMMU is not set
# CONFIG_VFIO_MDEV is not set
CONFIG_VIRT_DRIVERS=y
CONFIG_VBOXGUEST=m
CONFIG_VIRTIO=y
# CONFIG_VIRTIO_MENU is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=m
CONFIG_ACER_WIRELESS=m
CONFIG_ACERHDF=m
# CONFIG_ALIENWARE_WMI is not set
CONFIG_ASUS_LAPTOP=m
CONFIG_DCDBAS=m
CONFIG_DELL_SMBIOS=m
CONFIG_DELL_SMBIOS_WMI=y
# CONFIG_DELL_SMBIOS_SMM is not set
CONFIG_DELL_LAPTOP=m
# CONFIG_DELL_WMI is not set
CONFIG_DELL_WMI_DESCRIPTOR=m
CONFIG_DELL_WMI_AIO=m
CONFIG_DELL_WMI_LED=m
CONFIG_DELL_SMO8800=m
# CONFIG_DELL_RBU is not set
CONFIG_FUJITSU_LAPTOP=m
CONFIG_FUJITSU_TABLET=m
# CONFIG_GPD_POCKET_FAN is not set
CONFIG_HP_ACCEL=m
# CONFIG_HP_WIRELESS is not set
CONFIG_HP_WMI=m
CONFIG_LG_LAPTOP=m
CONFIG_PANASONIC_LAPTOP=m
CONFIG_SURFACE3_WMI=m
# CONFIG_THINKPAD_ACPI is not set
CONFIG_SENSORS_HDAPS=m
CONFIG_ASUS_WIRELESS=m
CONFIG_ACPI_WMI=m
CONFIG_WMI_BMOF=m
CONFIG_INTEL_WMI_THUNDERBOLT=m
# CONFIG_MSI_WMI is not set
# CONFIG_PEAQ_WMI is not set
CONFIG_TOPSTAR_LAPTOP=m
CONFIG_ACPI_TOSHIBA=m
CONFIG_TOSHIBA_BT_RFKILL=m
CONFIG_TOSHIBA_HAPS=m
CONFIG_TOSHIBA_WMI=m
CONFIG_ACPI_CMPC=m
CONFIG_INTEL_INT0002_VGPIO=m
CONFIG_INTEL_HID_EVENT=m
CONFIG_INTEL_VBTN=m
CONFIG_INTEL_IPS=y
# CONFIG_INTEL_PMC_CORE is not set
CONFIG_IBM_RTL=m
CONFIG_SAMSUNG_LAPTOP=m
CONFIG_MXM_WMI=m
CONFIG_SAMSUNG_Q10=m
# CONFIG_APPLE_GMUX is not set
CONFIG_INTEL_RST=m
CONFIG_INTEL_SMARTCONNECT=y
CONFIG_INTEL_PMC_IPC=m
CONFIG_INTEL_BXTWC_PMIC_TMU=m
CONFIG_SURFACE_PRO3_BUTTON=m
# CONFIG_INTEL_PUNIT_IPC is not set
CONFIG_MLX_PLATFORM=m
CONFIG_TOUCHSCREEN_DMI=y
# CONFIG_I2C_MULTI_INSTANTIATE is not set
CONFIG_INTEL_ATOMISP2_PM=y
CONFIG_HUAWEI_WMI=m
# CONFIG_PCENGINES_APU2 is not set
CONFIG_PMC_ATOM=y
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_LAPTOP=m
CONFIG_CHROMEOS_PSTORE=y
CONFIG_CHROMEOS_TBMC=m
CONFIG_CROS_EC_I2C=m
# CONFIG_CROS_EC_SPI is not set
CONFIG_CROS_EC_LPC=m
CONFIG_CROS_EC_LPC_MEC=y
CONFIG_CROS_EC_PROTO=y
CONFIG_CROS_KBD_LED_BACKLIGHT=m
CONFIG_CROS_EC_LIGHTBAR=m
# CONFIG_CROS_EC_DEBUGFS is not set
CONFIG_CROS_EC_SYSFS=m
CONFIG_WILCO_EC=m
CONFIG_WILCO_EC_DEBUGFS=m
# CONFIG_MELLANOX_PLATFORM is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
CONFIG_COMMON_CLK_MAX9485=y
# CONFIG_COMMON_CLK_SI5351 is not set
# CONFIG_COMMON_CLK_SI544 is not set
CONFIG_COMMON_CLK_CDCE706=m
CONFIG_COMMON_CLK_CS2000_CP=y
CONFIG_COMMON_CLK_S2MPS11=y
CONFIG_CLK_TWL6040=y
CONFIG_HWSPINLOCK=y

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
CONFIG_IOMMU_IOVA=y
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
# CONFIG_IOMMU_DEBUGFS is not set
CONFIG_IOMMU_DEFAULT_PASSTHROUGH=y
CONFIG_AMD_IOMMU=y
CONFIG_AMD_IOMMU_V2=m
# CONFIG_INTEL_IOMMU is not set
# CONFIG_IRQ_REMAP is not set

#
# Remoteproc drivers
#
# CONFIG_REMOTEPROC is not set

#
# Rpmsg drivers
#
# CONFIG_RPMSG_VIRTIO is not set
# CONFIG_SOUNDWIRE is not set

#
# SOC (System On Chip) specific Drivers
#

#
# Amlogic SoC drivers
#

#
# Broadcom SoC drivers
#

#
# NXP/Freescale QorIQ SoC drivers
#

#
# i.MX SoC drivers
#

#
# Qualcomm SoC drivers
#
# CONFIG_SOC_TI is not set

#
# Xilinx SoC drivers
#
CONFIG_XILINX_VCU=m
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
# CONFIG_DEVFREQ_GOV_PERFORMANCE is not set
CONFIG_DEVFREQ_GOV_POWERSAVE=m
# CONFIG_DEVFREQ_GOV_USERSPACE is not set
CONFIG_DEVFREQ_GOV_PASSIVE=y

#
# DEVFREQ Drivers
#
CONFIG_PM_DEVFREQ_EVENT=y
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_ADC_JACK=m
CONFIG_EXTCON_ARIZONA=m
# CONFIG_EXTCON_AXP288 is not set
CONFIG_EXTCON_GPIO=y
CONFIG_EXTCON_INTEL_INT3496=m
CONFIG_EXTCON_MAX14577=m
# CONFIG_EXTCON_MAX3355 is not set
# CONFIG_EXTCON_MAX77843 is not set
CONFIG_EXTCON_PTN5150=m
# CONFIG_EXTCON_RT8973A is not set
# CONFIG_EXTCON_SM5502 is not set
# CONFIG_EXTCON_USB_GPIO is not set
# CONFIG_EXTCON_USBC_CROS_EC is not set
CONFIG_MEMORY=y
CONFIG_IIO=m
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=m
CONFIG_IIO_BUFFER_HW_CONSUMER=m
CONFIG_IIO_KFIFO_BUF=m
CONFIG_IIO_TRIGGERED_BUFFER=m
CONFIG_IIO_CONFIGFS=m
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2
# CONFIG_IIO_SW_DEVICE is not set
CONFIG_IIO_SW_TRIGGER=m

#
# Accelerometers
#
CONFIG_ADIS16201=m
CONFIG_ADIS16209=m
CONFIG_ADXL345=m
CONFIG_ADXL345_I2C=m
# CONFIG_ADXL345_SPI is not set
CONFIG_ADXL372=m
CONFIG_ADXL372_SPI=m
CONFIG_ADXL372_I2C=m
CONFIG_BMA180=m
CONFIG_BMA220=m
CONFIG_BMC150_ACCEL=m
CONFIG_BMC150_ACCEL_I2C=m
CONFIG_BMC150_ACCEL_SPI=m
CONFIG_DA280=m
# CONFIG_DA311 is not set
# CONFIG_DMARD09 is not set
# CONFIG_DMARD10 is not set
CONFIG_HID_SENSOR_ACCEL_3D=m
# CONFIG_IIO_CROS_EC_ACCEL_LEGACY is not set
# CONFIG_IIO_ST_ACCEL_3AXIS is not set
CONFIG_KXSD9=m
CONFIG_KXSD9_SPI=m
# CONFIG_KXSD9_I2C is not set
CONFIG_KXCJK1013=m
CONFIG_MC3230=m
CONFIG_MMA7455=m
CONFIG_MMA7455_I2C=m
# CONFIG_MMA7455_SPI is not set
CONFIG_MMA7660=m
# CONFIG_MMA8452 is not set
CONFIG_MMA9551_CORE=m
CONFIG_MMA9551=m
CONFIG_MMA9553=m
CONFIG_MXC4005=m
# CONFIG_MXC6255 is not set
CONFIG_SCA3000=m
# CONFIG_STK8312 is not set
# CONFIG_STK8BA50 is not set

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=m
CONFIG_AD7124=m
CONFIG_AD7266=m
CONFIG_AD7291=m
CONFIG_AD7298=m
CONFIG_AD7476=m
# CONFIG_AD7606_IFACE_PARALLEL is not set
# CONFIG_AD7606_IFACE_SPI is not set
CONFIG_AD7766=m
CONFIG_AD7768_1=m
CONFIG_AD7791=m
CONFIG_AD7793=m
CONFIG_AD7887=m
CONFIG_AD7923=m
CONFIG_AD7949=m
# CONFIG_AD799X is not set
CONFIG_AXP20X_ADC=m
# CONFIG_AXP288_ADC is not set
# CONFIG_CC10001_ADC is not set
# CONFIG_HI8435 is not set
CONFIG_HX711=m
CONFIG_INA2XX_ADC=m
CONFIG_LP8788_ADC=m
# CONFIG_LTC2471 is not set
# CONFIG_LTC2485 is not set
CONFIG_LTC2497=m
CONFIG_MAX1027=m
# CONFIG_MAX11100 is not set
# CONFIG_MAX1118 is not set
# CONFIG_MAX1363 is not set
# CONFIG_MAX9611 is not set
# CONFIG_MCP320X is not set
# CONFIG_MCP3422 is not set
CONFIG_MCP3911=m
CONFIG_MEN_Z188_ADC=m
CONFIG_NAU7802=m
# CONFIG_STX104 is not set
CONFIG_TI_ADC081C=m
CONFIG_TI_ADC0832=m
CONFIG_TI_ADC084S021=m
# CONFIG_TI_ADC12138 is not set
CONFIG_TI_ADC108S102=m
CONFIG_TI_ADC128S052=m
CONFIG_TI_ADC161S626=m
# CONFIG_TI_ADS1015 is not set
CONFIG_TI_ADS7950=m
CONFIG_TI_TLC4541=m
# CONFIG_TWL4030_MADC is not set
CONFIG_TWL6030_GPADC=m

#
# Analog Front Ends
#

#
# Amplifiers
#
CONFIG_AD8366=m

#
# Chemical Sensors
#
CONFIG_ATLAS_PH_SENSOR=m
# CONFIG_BME680 is not set
# CONFIG_CCS811 is not set
CONFIG_IAQCORE=m
CONFIG_SPS30=m
CONFIG_VZ89X=m
# CONFIG_IIO_CROS_EC_SENSORS_CORE is not set

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=m
CONFIG_HID_SENSOR_IIO_TRIGGER=m
CONFIG_IIO_MS_SENSORS_I2C=m

#
# SSP Sensor Common
#
CONFIG_IIO_SSP_SENSORS_COMMONS=m
CONFIG_IIO_SSP_SENSORHUB=m
CONFIG_IIO_ST_SENSORS_I2C=m
CONFIG_IIO_ST_SENSORS_SPI=m
CONFIG_IIO_ST_SENSORS_CORE=m

#
# Counters
#
# CONFIG_104_QUAD_8 is not set

#
# Digital to analog converters
#
CONFIG_AD5064=m
# CONFIG_AD5360 is not set
CONFIG_AD5380=m
CONFIG_AD5421=m
# CONFIG_AD5446 is not set
CONFIG_AD5449=m
CONFIG_AD5592R_BASE=m
CONFIG_AD5592R=m
# CONFIG_AD5593R is not set
# CONFIG_AD5504 is not set
CONFIG_AD5624R_SPI=m
CONFIG_LTC1660=m
CONFIG_LTC2632=m
CONFIG_AD5686=m
CONFIG_AD5686_SPI=m
# CONFIG_AD5696_I2C is not set
CONFIG_AD5755=m
# CONFIG_AD5758 is not set
CONFIG_AD5761=m
# CONFIG_AD5764 is not set
# CONFIG_AD5791 is not set
# CONFIG_AD7303 is not set
CONFIG_CIO_DAC=m
CONFIG_AD8801=m
# CONFIG_DS4424 is not set
CONFIG_M62332=m
CONFIG_MAX517=m
CONFIG_MCP4725=m
# CONFIG_MCP4922 is not set
CONFIG_TI_DAC082S085=m
CONFIG_TI_DAC5571=m
CONFIG_TI_DAC7311=m
CONFIG_TI_DAC7612=m

#
# IIO dummy driver
#

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
CONFIG_AD9523=m

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
# CONFIG_ADF4350 is not set

#
# Digital gyroscope sensors
#
CONFIG_ADIS16080=m
# CONFIG_ADIS16130 is not set
CONFIG_ADIS16136=m
CONFIG_ADIS16260=m
CONFIG_ADXRS450=m
# CONFIG_BMG160 is not set
# CONFIG_HID_SENSOR_GYRO_3D is not set
# CONFIG_MPU3050_I2C is not set
CONFIG_IIO_ST_GYRO_3AXIS=m
CONFIG_IIO_ST_GYRO_I2C_3AXIS=m
CONFIG_IIO_ST_GYRO_SPI_3AXIS=m
# CONFIG_ITG3200 is not set

#
# Health Sensors
#

#
# Heart Rate Monitors
#
CONFIG_AFE4403=m
# CONFIG_AFE4404 is not set
CONFIG_MAX30100=m
# CONFIG_MAX30102 is not set

#
# Humidity sensors
#
# CONFIG_AM2315 is not set
# CONFIG_DHT11 is not set
# CONFIG_HDC100X is not set
# CONFIG_HID_SENSOR_HUMIDITY is not set
# CONFIG_HTS221 is not set
CONFIG_HTU21=m
# CONFIG_SI7005 is not set
# CONFIG_SI7020 is not set

#
# Inertial measurement units
#
# CONFIG_ADIS16400 is not set
CONFIG_ADIS16480=m
CONFIG_BMI160=m
# CONFIG_BMI160_I2C is not set
CONFIG_BMI160_SPI=m
CONFIG_KMX61=m
CONFIG_INV_MPU6050_IIO=m
CONFIG_INV_MPU6050_I2C=m
# CONFIG_INV_MPU6050_SPI is not set
# CONFIG_IIO_ST_LSM6DSX is not set
CONFIG_IIO_ADIS_LIB=m
CONFIG_IIO_ADIS_LIB_BUFFER=y

#
# Light sensors
#
CONFIG_ACPI_ALS=m
CONFIG_ADJD_S311=m
CONFIG_AL3320A=m
CONFIG_APDS9300=m
CONFIG_APDS9960=m
# CONFIG_BH1750 is not set
# CONFIG_BH1780 is not set
CONFIG_CM32181=m
CONFIG_CM3232=m
CONFIG_CM3323=m
CONFIG_CM36651=m
CONFIG_GP2AP020A00F=m
# CONFIG_SENSORS_ISL29018 is not set
CONFIG_SENSORS_ISL29028=m
CONFIG_ISL29125=m
CONFIG_HID_SENSOR_ALS=m
CONFIG_HID_SENSOR_PROX=m
CONFIG_JSA1212=m
CONFIG_RPR0521=m
CONFIG_SENSORS_LM3533=m
CONFIG_LTR501=m
CONFIG_LV0104CS=m
CONFIG_MAX44000=m
CONFIG_MAX44009=m
# CONFIG_OPT3001 is not set
CONFIG_PA12203001=m
# CONFIG_SI1133 is not set
CONFIG_SI1145=m
CONFIG_STK3310=m
# CONFIG_ST_UVIS25 is not set
CONFIG_TCS3414=m
CONFIG_TCS3472=m
CONFIG_SENSORS_TSL2563=m
CONFIG_TSL2583=m
CONFIG_TSL2772=m
# CONFIG_TSL4531 is not set
CONFIG_US5182D=m
CONFIG_VCNL4000=m
# CONFIG_VCNL4035 is not set
CONFIG_VEML6070=m
# CONFIG_VL6180 is not set
CONFIG_ZOPT2201=m

#
# Magnetometer sensors
#
CONFIG_AK8975=m
CONFIG_AK09911=m
CONFIG_BMC150_MAGN=m
CONFIG_BMC150_MAGN_I2C=m
# CONFIG_BMC150_MAGN_SPI is not set
# CONFIG_MAG3110 is not set
CONFIG_HID_SENSOR_MAGNETOMETER_3D=m
CONFIG_MMC35240=m
CONFIG_IIO_ST_MAGN_3AXIS=m
CONFIG_IIO_ST_MAGN_I2C_3AXIS=m
CONFIG_IIO_ST_MAGN_SPI_3AXIS=m
CONFIG_SENSORS_HMC5843=m
CONFIG_SENSORS_HMC5843_I2C=m
# CONFIG_SENSORS_HMC5843_SPI is not set
CONFIG_SENSORS_RM3100=m
# CONFIG_SENSORS_RM3100_I2C is not set
CONFIG_SENSORS_RM3100_SPI=m

#
# Multiplexers
#

#
# Inclinometer sensors
#
# CONFIG_HID_SENSOR_INCLINOMETER_3D is not set
CONFIG_HID_SENSOR_DEVICE_ROTATION=m

#
# Triggers - standalone
#
# CONFIG_IIO_HRTIMER_TRIGGER is not set
CONFIG_IIO_INTERRUPT_TRIGGER=m
CONFIG_IIO_TIGHTLOOP_TRIGGER=m
# CONFIG_IIO_SYSFS_TRIGGER is not set

#
# Digital potentiometers
#
CONFIG_AD5272=m
CONFIG_DS1803=m
CONFIG_MAX5481=m
# CONFIG_MAX5487 is not set
CONFIG_MCP4018=m
CONFIG_MCP4131=m
CONFIG_MCP4531=m
CONFIG_MCP41010=m
CONFIG_TPL0102=m

#
# Digital potentiostats
#
CONFIG_LMP91000=m

#
# Pressure sensors
#
# CONFIG_ABP060MG is not set
CONFIG_BMP280=m
CONFIG_BMP280_I2C=m
CONFIG_BMP280_SPI=m
CONFIG_HID_SENSOR_PRESS=m
CONFIG_HP03=m
CONFIG_MPL115=m
CONFIG_MPL115_I2C=m
CONFIG_MPL115_SPI=m
CONFIG_MPL3115=m
CONFIG_MS5611=m
CONFIG_MS5611_I2C=m
CONFIG_MS5611_SPI=m
CONFIG_MS5637=m
CONFIG_IIO_ST_PRESS=m
CONFIG_IIO_ST_PRESS_I2C=m
CONFIG_IIO_ST_PRESS_SPI=m
# CONFIG_T5403 is not set
CONFIG_HP206C=m
CONFIG_ZPA2326=m
CONFIG_ZPA2326_I2C=m
CONFIG_ZPA2326_SPI=m

#
# Lightning sensors
#
CONFIG_AS3935=m

#
# Proximity and distance sensors
#
CONFIG_ISL29501=m
CONFIG_LIDAR_LITE_V2=m
CONFIG_RFD77402=m
CONFIG_SRF04=m
# CONFIG_SX9500 is not set
CONFIG_SRF08=m
# CONFIG_VL53L0X_I2C is not set

#
# Resolver to digital converters
#
CONFIG_AD2S90=m
CONFIG_AD2S1200=m

#
# Temperature sensors
#
CONFIG_MAXIM_THERMOCOUPLE=m
CONFIG_HID_SENSOR_TEMP=m
# CONFIG_MLX90614 is not set
CONFIG_MLX90632=m
CONFIG_TMP006=m
CONFIG_TMP007=m
CONFIG_TSYS01=m
# CONFIG_TSYS02D is not set
# CONFIG_NTB is not set
CONFIG_VME_BUS=y

#
# VME Bridge Drivers
#
CONFIG_VME_CA91CX42=m
CONFIG_VME_TSI148=y
CONFIG_VME_FAKE=y

#
# VME Board Drivers
#
CONFIG_VMIVME_7805=y

#
# VME Device Drivers
#
# CONFIG_PWM is not set

#
# IRQ chip support
#
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_MADERA_IRQ=y
CONFIG_IPACK_BUS=y
CONFIG_BOARD_TPCI200=y
# CONFIG_SERIAL_IPOCTAL is not set
CONFIG_RESET_CONTROLLER=y
# CONFIG_RESET_TI_SYSCON is not set
CONFIG_FMC=m
CONFIG_FMC_FAKEDEV=m
# CONFIG_FMC_TRIVIAL is not set
# CONFIG_FMC_WRITE_EEPROM is not set
CONFIG_FMC_CHARDEV=m

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
# CONFIG_BCM_KONA_USB2_PHY is not set
CONFIG_PHY_PXA_28NM_HSIC=m
CONFIG_PHY_PXA_28NM_USB2=m
# CONFIG_PHY_CPCAP_USB is not set
# CONFIG_POWERCAP is not set
CONFIG_MCB=y
CONFIG_MCB_PCI=m
CONFIG_MCB_LPC=m

#
# Performance monitor support
#
CONFIG_RAS=y
CONFIG_RAS_CEC=y
CONFIG_THUNDERBOLT=m

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_LIBNVDIMM=y
CONFIG_BLK_DEV_PMEM=m
# CONFIG_ND_BLK is not set
CONFIG_ND_CLAIM=y
CONFIG_ND_BTT=m
CONFIG_BTT=y
CONFIG_NVDIMM_KEYS=y
CONFIG_DAX_DRIVER=y
CONFIG_DAX=y
CONFIG_NVMEM=y

#
# HW tracing support
#
CONFIG_STM=y
CONFIG_STM_PROTO_BASIC=m
CONFIG_STM_PROTO_SYS_T=m
# CONFIG_STM_DUMMY is not set
CONFIG_STM_SOURCE_CONSOLE=m
CONFIG_STM_SOURCE_HEARTBEAT=y
CONFIG_STM_SOURCE_FTRACE=m
CONFIG_INTEL_TH=y
# CONFIG_INTEL_TH_PCI is not set
CONFIG_INTEL_TH_ACPI=m
CONFIG_INTEL_TH_GTH=m
CONFIG_INTEL_TH_STH=m
CONFIG_INTEL_TH_MSU=m
# CONFIG_INTEL_TH_PTI is not set
# CONFIG_INTEL_TH_DEBUG is not set
CONFIG_FPGA=y
CONFIG_ALTERA_PR_IP_CORE=y
CONFIG_FPGA_MGR_ALTERA_PS_SPI=m
CONFIG_FPGA_MGR_ALTERA_CVP=m
CONFIG_FPGA_MGR_XILINX_SPI=m
# CONFIG_FPGA_MGR_MACHXO2_SPI is not set
CONFIG_FPGA_BRIDGE=y
CONFIG_ALTERA_FREEZE_BRIDGE=m
# CONFIG_XILINX_PR_DECOUPLER is not set
CONFIG_FPGA_REGION=y
CONFIG_FPGA_DFL=y
# CONFIG_FPGA_DFL_FME is not set
CONFIG_FPGA_DFL_AFU=m
# CONFIG_FPGA_DFL_PCI is not set
CONFIG_PM_OPP=y
CONFIG_UNISYS_VISORBUS=y
# CONFIG_SIOX is not set
# CONFIG_SLIMBUS is not set
CONFIG_INTERCONNECT=m

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
# CONFIG_VALIDATE_FS_PARSER is not set
CONFIG_FS_IOMAP=y
CONFIG_EXT2_FS=m
CONFIG_EXT2_FS_XATTR=y
# CONFIG_EXT2_FS_POSIX_ACL is not set
# CONFIG_EXT2_FS_SECURITY is not set
# CONFIG_EXT3_FS is not set
CONFIG_EXT4_FS=y
# CONFIG_EXT4_FS_POSIX_ACL is not set
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=y
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
# CONFIG_XFS_RT is not set
# CONFIG_XFS_ONLINE_SCRUB is not set
CONFIG_XFS_DEBUG=y
CONFIG_XFS_ASSERT_FATAL=y
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=m
# CONFIG_BTRFS_FS_POSIX_ACL is not set
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
CONFIG_BTRFS_DEBUG=y
CONFIG_BTRFS_ASSERT=y
CONFIG_BTRFS_FS_REF_VERIFY=y
# CONFIG_NILFS2_FS is not set
# CONFIG_F2FS_FS is not set
CONFIG_FS_DAX=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
# CONFIG_EXPORTFS_BLOCK_OPS is not set
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
# CONFIG_FS_ENCRYPTION is not set
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
# CONFIG_QUOTA is not set
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_QUOTACTL=y
# CONFIG_AUTOFS4_FS is not set
CONFIG_AUTOFS_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
CONFIG_OVERLAY_FS=m
CONFIG_OVERLAY_FS_REDIRECT_DIR=y
CONFIG_OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW=y
# CONFIG_OVERLAY_FS_INDEX is not set
CONFIG_OVERLAY_FS_XINO_AUTO=y
CONFIG_OVERLAY_FS_METACOPY=y

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
# CONFIG_JOLIET is not set
# CONFIG_ZISOFS is not set
CONFIG_UDF_FS=m

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
# CONFIG_FAT_DEFAULT_UTF8 is not set
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_VMCORE=y
# CONFIG_PROC_VMCORE_DEVICE_DUMP is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_MEMFD_CREATE=y
CONFIG_ARCH_HAS_GIGANTIC_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ORANGEFS_FS is not set
CONFIG_ADFS_FS=m
# CONFIG_ADFS_FS_RW is not set
# CONFIG_AFFS_FS is not set
CONFIG_ECRYPT_FS=m
# CONFIG_ECRYPT_FS_MESSAGING is not set
CONFIG_HFS_FS=m
# CONFIG_HFSPLUS_FS is not set
CONFIG_BEFS_FS=m
CONFIG_BEFS_DEBUG=y
CONFIG_BFS_FS=m
# CONFIG_EFS_FS is not set
# CONFIG_JFFS2_FS is not set
# CONFIG_UBIFS_FS is not set
CONFIG_CRAMFS=m
CONFIG_CRAMFS_BLOCKDEV=y
CONFIG_CRAMFS_MTD=y
CONFIG_SQUASHFS=y
# CONFIG_SQUASHFS_FILE_CACHE is not set
CONFIG_SQUASHFS_FILE_DIRECT=y
# CONFIG_SQUASHFS_DECOMP_SINGLE is not set
# CONFIG_SQUASHFS_DECOMP_MULTI is not set
CONFIG_SQUASHFS_DECOMP_MULTI_PERCPU=y
CONFIG_SQUASHFS_XATTR=y
# CONFIG_SQUASHFS_ZLIB is not set
# CONFIG_SQUASHFS_LZ4 is not set
CONFIG_SQUASHFS_LZO=y
# CONFIG_SQUASHFS_XZ is not set
# CONFIG_SQUASHFS_ZSTD is not set
# CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
# CONFIG_VXFS_FS is not set
CONFIG_MINIX_FS=y
CONFIG_OMFS_FS=y
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
CONFIG_QNX6FS_FS=y
# CONFIG_QNX6FS_DEBUG is not set
CONFIG_ROMFS_FS=m
# CONFIG_ROMFS_BACKED_BY_BLOCK is not set
CONFIG_ROMFS_BACKED_BY_MTD=y
# CONFIG_ROMFS_BACKED_BY_BOTH is not set
CONFIG_ROMFS_ON_MTD=y
CONFIG_PSTORE=y
CONFIG_PSTORE_DEFLATE_COMPRESS=y
# CONFIG_PSTORE_LZO_COMPRESS is not set
CONFIG_PSTORE_LZ4_COMPRESS=y
CONFIG_PSTORE_LZ4HC_COMPRESS=y
CONFIG_PSTORE_842_COMPRESS=y
CONFIG_PSTORE_ZSTD_COMPRESS=y
CONFIG_PSTORE_COMPRESS=y
# CONFIG_PSTORE_DEFLATE_COMPRESS_DEFAULT is not set
# CONFIG_PSTORE_LZ4_COMPRESS_DEFAULT is not set
# CONFIG_PSTORE_LZ4HC_COMPRESS_DEFAULT is not set
# CONFIG_PSTORE_842_COMPRESS_DEFAULT is not set
CONFIG_PSTORE_ZSTD_COMPRESS_DEFAULT=y
CONFIG_PSTORE_COMPRESS_DEFAULT="zstd"
# CONFIG_PSTORE_CONSOLE is not set
# CONFIG_PSTORE_PMSG is not set
CONFIG_PSTORE_FTRACE=y
CONFIG_PSTORE_RAM=m
CONFIG_SYSV_FS=y
CONFIG_UFS_FS=m
CONFIG_UFS_FS_WRITE=y
# CONFIG_UFS_DEBUG is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=m
# CONFIG_NFS_SWAP is not set
# CONFIG_NFS_V4_1 is not set
# CONFIG_ROOT_NFS is not set
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
# CONFIG_NFSD is not set
CONFIG_GRACE_PERIOD=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=m
CONFIG_RPCSEC_GSS_KRB5=m
# CONFIG_CONFIG_SUNRPC_DISABLE_INSECURE_ENCTYPES is not set
# CONFIG_SUNRPC_DEBUG is not set
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=m
# CONFIG_CIFS_STATS2 is not set
CONFIG_CIFS_ALLOW_INSECURE_LEGACY=y
# CONFIG_CIFS_WEAK_PW_HASH is not set
# CONFIG_CIFS_UPCALL is not set
# CONFIG_CIFS_XATTR is not set
CONFIG_CIFS_DEBUG=y
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_DEBUG_DUMP_KEYS is not set
# CONFIG_CIFS_DFS_UPCALL is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
# CONFIG_9P_FS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=m
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=m
CONFIG_NLS_CODEPAGE_852=m
CONFIG_NLS_CODEPAGE_855=y
# CONFIG_NLS_CODEPAGE_857 is not set
CONFIG_NLS_CODEPAGE_860=m
# CONFIG_NLS_CODEPAGE_861 is not set
CONFIG_NLS_CODEPAGE_862=m
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=m
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=m
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=m
CONFIG_NLS_ISO8859_9=m
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_14=m
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_KOI8_R=m
CONFIG_NLS_KOI8_U=m
# CONFIG_NLS_MAC_ROMAN is not set
CONFIG_NLS_MAC_CELTIC=m
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
# CONFIG_NLS_MAC_CYRILLIC is not set
# CONFIG_NLS_MAC_GAELIC is not set
CONFIG_NLS_MAC_GREEK=m
CONFIG_NLS_MAC_ICELAND=m
CONFIG_NLS_MAC_INUIT=m
CONFIG_NLS_MAC_ROMANIAN=y
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y
# CONFIG_DLM is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_PERSISTENT_KEYRINGS is not set
CONFIG_BIG_KEYS=y
CONFIG_TRUSTED_KEYS=m
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEY_DH_OPERATIONS is not set
CONFIG_SECURITY_DMESG_RESTRICT=y
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
# CONFIG_SECURITY_NETWORK is not set
CONFIG_PAGE_TABLE_ISOLATION=y
CONFIG_SECURITY_PATH=y
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
CONFIG_HARDENED_USERCOPY=y
CONFIG_HARDENED_USERCOPY_FALLBACK=y
CONFIG_HARDENED_USERCOPY_PAGESPAN=y
CONFIG_FORTIFY_SOURCE=y
# CONFIG_STATIC_USERMODEHELPER is not set
# CONFIG_SECURITY_SMACK is not set
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
CONFIG_SECURITY_LOADPIN=y
CONFIG_SECURITY_LOADPIN_ENFORCE=y
# CONFIG_SECURITY_YAMA is not set
# CONFIG_SECURITY_SAFESETID is not set
CONFIG_INTEGRITY=y
CONFIG_INTEGRITY_SIGNATURE=y
CONFIG_INTEGRITY_ASYMMETRIC_KEYS=y
CONFIG_INTEGRITY_TRUSTED_KEYRING=y
CONFIG_IMA=y
CONFIG_IMA_MEASURE_PCR_IDX=10
CONFIG_IMA_TEMPLATE=y
# CONFIG_IMA_NG_TEMPLATE is not set
# CONFIG_IMA_SIG_TEMPLATE is not set
CONFIG_IMA_DEFAULT_TEMPLATE="ima"
CONFIG_IMA_DEFAULT_HASH_SHA1=y
CONFIG_IMA_DEFAULT_HASH="sha1"
# CONFIG_IMA_WRITE_POLICY is not set
# CONFIG_IMA_READ_POLICY is not set
CONFIG_IMA_APPRAISE=y
CONFIG_IMA_ARCH_POLICY=y
CONFIG_IMA_APPRAISE_BUILD_POLICY=y
CONFIG_IMA_APPRAISE_REQUIRE_FIRMWARE_SIGS=y
# CONFIG_IMA_APPRAISE_REQUIRE_KEXEC_SIGS is not set
CONFIG_IMA_APPRAISE_REQUIRE_MODULE_SIGS=y
CONFIG_IMA_APPRAISE_REQUIRE_POLICY_SIGS=y
CONFIG_IMA_TRUSTED_KEYRING=y
# CONFIG_IMA_KEYRINGS_PERMIT_SIGNED_BY_BUILTIN_OR_SECONDARY is not set
CONFIG_IMA_BLACKLIST_KEYRING=y
CONFIG_IMA_LOAD_X509=y
CONFIG_IMA_X509_PATH="/etc/keys/x509_ima.der"
CONFIG_IMA_APPRAISE_SIGNED_INIT=y
CONFIG_EVM=y
CONFIG_EVM_ATTR_FSUUID=y
# CONFIG_EVM_ADD_XATTRS is not set
# CONFIG_EVM_LOAD_X509 is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_LSM="yama,loadpin,safesetid,integrity"
CONFIG_XOR_BLOCKS=m
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_AKCIPHER=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_KPP=y
CONFIG_CRYPTO_ACOMP2=y
CONFIG_CRYPTO_RSA=y
CONFIG_CRYPTO_DH=y
CONFIG_CRYPTO_ECDH=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
# CONFIG_CRYPTO_TEST is not set
CONFIG_CRYPTO_SIMD=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=m
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_CHACHA20POLY1305=m
CONFIG_CRYPTO_AEGIS128=m
# CONFIG_CRYPTO_AEGIS128L is not set
CONFIG_CRYPTO_AEGIS256=y
# CONFIG_CRYPTO_AEGIS128_AESNI_SSE2 is not set
CONFIG_CRYPTO_AEGIS128L_AESNI_SSE2=m
CONFIG_CRYPTO_AEGIS256_AESNI_SSE2=m
CONFIG_CRYPTO_MORUS640=m
CONFIG_CRYPTO_MORUS640_GLUE=y
CONFIG_CRYPTO_MORUS640_SSE2=y
CONFIG_CRYPTO_MORUS1280=y
CONFIG_CRYPTO_MORUS1280_GLUE=y
CONFIG_CRYPTO_MORUS1280_SSE2=m
CONFIG_CRYPTO_MORUS1280_AVX2=y
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
# CONFIG_CRYPTO_CFB is not set
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
# CONFIG_CRYPTO_LRW is not set
CONFIG_CRYPTO_OFB=y
# CONFIG_CRYPTO_PCBC is not set
CONFIG_CRYPTO_XTS=y
CONFIG_CRYPTO_KEYWRAP=m
CONFIG_CRYPTO_NHPOLY1305=y
CONFIG_CRYPTO_NHPOLY1305_SSE2=y
CONFIG_CRYPTO_NHPOLY1305_AVX2=y
CONFIG_CRYPTO_ADIANTUM=m

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=m
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=m
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=m
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
# CONFIG_CRYPTO_POLY1305_X86_64 is not set
CONFIG_CRYPTO_MD4=m
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=m
CONFIG_CRYPTO_RMD128=m
# CONFIG_CRYPTO_RMD160 is not set
CONFIG_CRYPTO_RMD256=m
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256_SSSE3=m
CONFIG_CRYPTO_SHA512_SSSE3=m
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA3=m
CONFIG_CRYPTO_SM3=y
# CONFIG_CRYPTO_STREEBOG is not set
# CONFIG_CRYPTO_TGR192 is not set
CONFIG_CRYPTO_WP512=y
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_AES_TI is not set
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=m
CONFIG_CRYPTO_ARC4=m
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_BLOWFISH_COMMON=m
CONFIG_CRYPTO_BLOWFISH_X86_64=m
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64 is not set
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_CAST6_AVX_X86_64=m
CONFIG_CRYPTO_DES=m
# CONFIG_CRYPTO_DES3_EDE_X86_64 is not set
CONFIG_CRYPTO_FCRYPT=m
CONFIG_CRYPTO_KHAZAD=m
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_CHACHA20=m
# CONFIG_CRYPTO_CHACHA20_X86_64 is not set
CONFIG_CRYPTO_SEED=m
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=m
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=m
CONFIG_CRYPTO_SM4=y
CONFIG_CRYPTO_TEA=y
# CONFIG_CRYPTO_TWOFISH is not set
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
# CONFIG_CRYPTO_TWOFISH_AVX_X86_64 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_842=y
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y
CONFIG_CRYPTO_ZSTD=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HASH_INFO=y
# CONFIG_CRYPTO_HW is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_ASYMMETRIC_TPM_KEY_SUBTYPE=m
CONFIG_X509_CERTIFICATE_PARSER=y
# CONFIG_PKCS8_PRIVATE_KEY_PARSER is not set
CONFIG_TPM_KEY_PARSER=m
CONFIG_PKCS7_MESSAGE_PARSER=y

#
# Certificates for signature checking
#
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_TRUSTED_KEYS=""
# CONFIG_SYSTEM_EXTRA_CERTIFICATE is not set
CONFIG_SECONDARY_TRUSTED_KEYRING=y
# CONFIG_SYSTEM_BLACKLIST_KEYRING is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=m
CONFIG_RAID6_PQ_BENCHMARK=y
CONFIG_BITREVERSE=y
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
CONFIG_CRC32_BIT=y
CONFIG_CRC64=y
# CONFIG_CRC4 is not set
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
CONFIG_CRC8=m
CONFIG_XXHASH=y
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_842_COMPRESS=y
CONFIG_842_DECOMPRESS=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_ZSTD_COMPRESS=y
CONFIG_ZSTD_DECOMPRESS=y
CONFIG_XZ_DEC=y
# CONFIG_XZ_DEC_X86 is not set
CONFIG_XZ_DEC_POWERPC=y
# CONFIG_XZ_DEC_IA64 is not set
# CONFIG_XZ_DEC_ARM is not set
# CONFIG_XZ_DEC_ARMTHUMB is not set
# CONFIG_XZ_DEC_SPARC is not set
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=m
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=m
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_INTERVAL_TREE=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_SWIOTLB=y
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=0
CONFIG_CMA_SIZE_PERCENTAGE=0
# CONFIG_CMA_SIZE_SEL_MBYTES is not set
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
# CONFIG_CMA_SIZE_SEL_MIN is not set
CONFIG_CMA_SIZE_SEL_MAX=y
CONFIG_CMA_ALIGNMENT=8
# CONFIG_DMA_API_DEBUG is not set
CONFIG_SGL_ALLOC=y
CONFIG_IOMMU_HELPER=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_DQL=y
CONFIG_GLOB=y
CONFIG_GLOB_SELFTEST=y
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
CONFIG_DDR=y
# CONFIG_IRQ_POLL is not set
CONFIG_MPILIB=y
CONFIG_SIGNATURE=y
CONFIG_OID_REGISTRY=y
CONFIG_FONT_SUPPORT=y
CONFIG_FONT_8x16=y
CONFIG_FONT_AUTOSELECT=y
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_UACCESS_FLUSHCACHE=y
CONFIG_ARCH_HAS_UACCESS_MCSAFE=y
CONFIG_STACKDEPOT=y
CONFIG_SBITMAP=y
CONFIG_PRIME_NUMBERS=m
CONFIG_STRING_SELFTEST=y

#
# Kernel hacking
#

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
# CONFIG_PRINTK_CALLER is not set
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
CONFIG_CONSOLE_LOGLEVEL_QUIET=4
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=y
# CONFIG_DEBUG_INFO_SPLIT is not set
# CONFIG_DEBUG_INFO_DWARF4 is not set
# CONFIG_GDB_SCRIPTS is not set
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=8192
CONFIG_STRIP_ASM_SYMS=y
CONFIG_READABLE_ASM=y
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CONFIG_STACK_VALIDATION=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_MAGIC_SYSRQ_SERIAL=y
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT=y
# CONFIG_PAGE_OWNER is not set
CONFIG_PAGE_POISONING=y
# CONFIG_PAGE_POISONING_NO_SANITY is not set
CONFIG_PAGE_POISONING_ZERO=y
CONFIG_DEBUG_PAGE_REF=y
CONFIG_DEBUG_RODATA_TEST=y
CONFIG_DEBUG_OBJECTS=y
CONFIG_DEBUG_OBJECTS_SELFTEST=y
# CONFIG_DEBUG_OBJECTS_FREE is not set
CONFIG_DEBUG_OBJECTS_TIMERS=y
# CONFIG_DEBUG_OBJECTS_WORK is not set
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
# CONFIG_DEBUG_SLAB is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_VMACACHE=y
CONFIG_DEBUG_VM_RB=y
CONFIG_DEBUG_VM_PGFLAGS=y
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_MEMORY_INIT is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KASAN=y
CONFIG_CC_HAS_KASAN_GENERIC=y
CONFIG_KASAN=y
CONFIG_KASAN_GENERIC=y
# CONFIG_KASAN_OUTLINE is not set
CONFIG_KASAN_INLINE=y
CONFIG_KASAN_STACK=1
CONFIG_TEST_KASAN=m
CONFIG_ARCH_HAS_KCOV=y
CONFIG_CC_HAS_SANCOV_TRACE_PC=y
# CONFIG_KCOV is not set
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_SOFTLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
CONFIG_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HARDLOCKUP_CHECK_TIMESTAMP=y
CONFIG_HARDLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=0
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_WQ_WATCHDOG is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHEDSTATS is not set
CONFIG_SCHED_STACK_END_CHECK=y
# CONFIG_DEBUG_TIMEKEEPING is not set
CONFIG_DEBUG_PREEMPT=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_LOCK_DEBUGGING_SUPPORT=y
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_LOCK_TORTURE_TEST=m
# CONFIG_WW_MUTEX_SELFTEST is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_WARN_ALL_UNSEEDED_RANDOM is not set
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_KOBJECT_RELEASE is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PI_LIST is not set
CONFIG_DEBUG_SG=y
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
CONFIG_TORTURE_TEST=m
CONFIG_RCU_PERF_TEST=m
CONFIG_RCU_TORTURE_TEST=m
CONFIG_RCU_CPU_STALL_TIMEOUT=21
# CONFIG_RCU_TRACE is not set
CONFIG_RCU_EQS_DEBUG=y
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
CONFIG_NOTIFIER_ERROR_INJECTION=m
CONFIG_PM_NOTIFIER_ERROR_INJECT=m
# CONFIG_NETDEV_NOTIFIER_ERROR_INJECT is not set
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
# CONFIG_FAIL_PAGE_ALLOC is not set
# CONFIG_FAIL_MAKE_REQUEST is not set
CONFIG_FAIL_IO_TIMEOUT=y
# CONFIG_FAIL_FUTEX is not set
CONFIG_FAULT_INJECTION_DEBUG_FS=y
# CONFIG_FAIL_MMC_REQUEST is not set
# CONFIG_LATENCYTOP is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_PREEMPTIRQ_TRACEPOINTS=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
# CONFIG_PREEMPTIRQ_EVENTS is not set
CONFIG_IRQSOFF_TRACER=y
# CONFIG_PREEMPT_TRACER is not set
# CONFIG_SCHED_TRACER is not set
CONFIG_HWLAT_TRACER=y
CONFIG_FTRACE_SYSCALLS=y
CONFIG_TRACER_SNAPSHOT=y
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_STACK_TRACER is not set
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_UPROBE_EVENTS=y
CONFIG_DYNAMIC_EVENTS=y
CONFIG_PROBE_EVENTS=y
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
# CONFIG_FUNCTION_PROFILER is not set
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
# CONFIG_HIST_TRIGGERS is not set
# CONFIG_TRACEPOINT_BENCHMARK is not set
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
CONFIG_PREEMPTIRQ_DELAY_TEST=m
# CONFIG_TRACE_EVAL_MAP_FILE is not set
# CONFIG_TRACING_EVENTS_GPIO is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_RUNTIME_TESTING_MENU is not set
CONFIG_MEMTEST=y
# CONFIG_BUG_ON_DATA_CORRUPTION is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
CONFIG_UBSAN=y
# CONFIG_UBSAN_SANITIZE_ALL is not set
CONFIG_UBSAN_NO_ALIGNMENT=y
# CONFIG_TEST_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_EARLY_PRINTK_USB=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_EARLY_PRINTK_USB_XDBC=y
CONFIG_X86_PTDUMP_CORE=y
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_WX=y
# CONFIG_DOUBLEFAULT is not set
CONFIG_DEBUG_TLBFLUSH=y
# CONFIG_IOMMU_DEBUG is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
CONFIG_IO_DELAY_NONE=y
CONFIG_DEFAULT_IO_DELAY_TYPE=3
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_ENTRY is not set
CONFIG_DEBUG_NMI_SELFTEST=y
# CONFIG_X86_DEBUG_FPU is not set
# CONFIG_PUNIT_ATOM_DEBUG is not set
CONFIG_UNWINDER_ORC=y
# CONFIG_UNWINDER_FRAME_POINTER is not set

--=_5cae03c4.pZ1fFpRFLxwqetjY3Bjgi2GHnZwA46345mT2xZX1gF8H0QcA--

