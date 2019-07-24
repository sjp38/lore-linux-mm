Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UPPERCASE_50_75,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0589FC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 22:54:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46F6F2190F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 22:54:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46F6F2190F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4DA98E0014; Wed, 24 Jul 2019 18:54:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D25FD8E0002; Wed, 24 Jul 2019 18:54:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8F028E0014; Wed, 24 Jul 2019 18:54:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 33ABC8E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 18:54:20 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id i33so24999757pld.15
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:54:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:user-agent:mime-version;
        bh=L7XnvKU0RjlFS7i0HZG5z2WaS57p5ZL3HTty9Xcjcig=;
        b=a3GNytvS1ul/Xk52ggNmzWnbbyuwJmvAlnlQrypmnNb4NIXezDF5k+a/9cv5vmuFar
         ai0BEfS7DZU74Pk53pqIoJ2ZPfzvLrz5BUPnwYLb5JF3zCr4QsORW6bKSIlwD/9rrp04
         LlzaY4COJs+bklpeLK9XP3uKy16myNRJtfrgr2g538GN7s2UdI2VyiC0p3CYscBSQPw4
         2cm2js2EnSYwVKUZFc3j13DF9frwX1iUghJZ8dSbFRgZO1Y15b/cdyKumcwLW73rfYcX
         hnWbB4iFuYv95B8PFFdn/sd7jjxrDvFxXIUSoViK5HTXePdPr/8582rsP+T+VUJOf7J+
         5GZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXL3X22+DTwabW9bo1rEpxC3TbesLpjqlCdeGk+dbtTU1nNeMQ1
	zI1v8LoTzGo0/J7eZA5Hjm7MlXr61MP2JtLB6ZPA2311t8jYycKAl6E3iZ3j0ep17Qoy8cwRwvu
	Ma2KfRI2oNJiKUNjPzFf7dVn+9O69tJ4tQ+/xpyALA5RnXPvs4WJKuLCKF3IbSzqR2A==
X-Received: by 2002:a63:f857:: with SMTP id v23mr58617634pgj.228.1564008858482;
        Wed, 24 Jul 2019 15:54:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFWIJrOjyL7HequsJ2ykwYRWTHj15lsgD/sfLB1D99Bw5MxDC9WLv7PlS82jsutQuWbh9S
X-Received: by 2002:a63:f857:: with SMTP id v23mr58617551pgj.228.1564008856386;
        Wed, 24 Jul 2019 15:54:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564008856; cv=none;
        d=google.com; s=arc-20160816;
        b=xqV1cdr4xSbVZzUVwhkeiHtOCr5YhXyTArw0U325KxysU+OpIWfQJgvjOdehnRG5dq
         U1mYisTcWk3vw7IZsa6PPIYWa3vNYckKPYOLzhKazt0cuR9n7ggb6LnT3uIl3tEUqdXF
         Szk69fjoBNDaVOg5qmhw1iOQGp2FdhuSpmjUmtcLedjPmlCgq9tyBPlnoH54OGTcQOxx
         tCk/J0Nnh0D4IBJbRfC7Xlzv92QJGdbCxMkt03ImAgK1d/zBlr36zo5c7+bfsByaUf/H
         ClLRO/QhprPewFCSxAi1Omif7g8uxJJatw2hTR+vx/svwZVGm/KTgG+1CqjxkZt3vpmJ
         OJug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:subject:cc:to:from:date;
        bh=L7XnvKU0RjlFS7i0HZG5z2WaS57p5ZL3HTty9Xcjcig=;
        b=Z7mswoit+L6vWI+qKsokOdsZBAuqr+yMyBhRTsNRFhgcIfZvtTkhGtjv+JZ5aJFxM+
         Ua4a1WH0pD1Cmo1UbcDElzwaGmaW397EJSfEnUFA89+wR2yayWj9zzNl3o+TaXlMbJBP
         b7zlCjT2oxnx09sEx2lOFvCeIOIyE7p3NeCyu9vyCjhSb5rRBZm2DnA6jfBfCQ2KGXWh
         NtBap2KD8MnJVJn9ok4Meyr+5fQXk5Y3fDdqIakFnGxUpYsgUon9W7Tb5+IXCu77NJQX
         xgDUuhK6SytL+KeAF4HjxWb8mVbqSBLCLTUJk3kKBphuAJhphx8RejiqijOh76z+i3pC
         LWlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id n21si17595234pgf.339.2019.07.24.15.54.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 15:54:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jul 2019 15:54:15 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,304,1559545200"; 
   d="gz'50?scan'50,208,50";a="181269310"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga002.jf.intel.com with ESMTP; 24 Jul 2019 15:54:11 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hqQ9C-000GeK-OM; Thu, 25 Jul 2019 06:54:10 +0800
Date: Thu, 25 Jul 2019 06:54:01 +0800
From: kernel test robot <lkp@intel.com>
To: Alexander Potapenko <glider@google.com>
Cc: LKP <lkp@01.org>, linux-kernel@vger.kernel.org,
 Linux Memory Management List <linux-mm@kvack.org>,
 Andrew Morton <akpm@linux-foundation.org>, philip.li@intel.com
Subject: 5015a300a5 ("lib: introduce test_meminit module"):  BUG: sleeping function called from invalid context at mm/page_alloc.c:4664
Message-ID: <5d38e189.rF5nqXyx5om2sy16%lkp@intel.com>
User-Agent: Heirloom mailx 12.5 6/20/10
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_5d38e189.pwMdpwxOIvHtesRvotcq8HpjKn1pXETahLhfmsG191XEpLEH"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

--=_5d38e189.pwMdpwxOIvHtesRvotcq8HpjKn1pXETahLhfmsG191XEpLEH
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://kernel.googlesource.com/pub/scm/linux/kernel/git/torvalds/linux.git master

commit 5015a300a522c8fb542dc993140e4c360cf4cf5f
Author:     Alexander Potapenko <glider@google.com>
AuthorDate: Tue Jul 16 16:27:27 2019 -0700
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Tue Jul 16 19:23:22 2019 -0700

    lib: introduce test_meminit module
    
    Add tests for heap and pagealloc initialization.  These can be used to
    check init_on_alloc and init_on_free implementations as well as other
    approaches to initialization.
    
    Expected test output in the case the kernel provides heap initialization
    (e.g.  when running with either init_on_alloc=1 or init_on_free=1):
    
      test_meminit: all 10 tests in test_pages passed
      test_meminit: all 40 tests in test_kvmalloc passed
      test_meminit: all 60 tests in test_kmemcache passed
      test_meminit: all 10 tests in test_rcu_persistent passed
      test_meminit: all 120 tests passed!
    
    Link: http://lkml.kernel.org/r/20190529123812.43089-4-glider@google.com
    Signed-off-by: Alexander Potapenko <glider@google.com>
    Acked-by: Kees Cook <keescook@chromium.org>
    Cc: Christoph Lameter <cl@linux.com>
    Cc: Nick Desaulniers <ndesaulniers@google.com>
    Cc: Kostya Serebryany <kcc@google.com>
    Cc: Dmitry Vyukov <dvyukov@google.com>
    Cc: Sandeep Patil <sspatil@android.com>
    Cc: Laura Abbott <labbott@redhat.com>
    Cc: Jann Horn <jannh@google.com>
    Cc: Marco Elver <elver@google.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

8e060c21ae  lib/test_overflow.c: avoid tainting the kernel and fix wrap size
5015a300a5  lib: introduce test_meminit module
bed38c3e2d  Merge tag 'powerpc-5.3-2' of git://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux
9e6dfe8045  Add linux-next specific files for 20190724
+----------------------------------------------------------------------+------------+------------+------------+---------------+
|                                                                      | 8e060c21ae | 5015a300a5 | bed38c3e2d | next-20190724 |
+----------------------------------------------------------------------+------------+------------+------------+---------------+
| boot_successes                                                       | 190        | 2          | 0          | 0             |
| boot_failures                                                        | 1          | 64         | 66         | 3             |
| kernel_BUG_at_security/keys/keyring.c                                | 1          |            |            |               |
| invalid_opcode:#[##]                                                 | 1          |            |            |               |
| RIP:__key_link_begin                                                 | 1          |            |            |               |
| Kernel_panic-not_syncing:Fatal_exception                             | 1          | 56         |            |               |
| BUG:sleeping_function_called_from_invalid_context_at_mm/page_alloc.c | 0          | 43         | 66         | 3             |
| BUG:unable_to_handle_page_fault_for_address                          | 0          | 56         |            |               |
| Oops:#[##]                                                           | 0          | 56         |            |               |
| RIP:slob_page_alloc                                                  | 0          | 42         |            |               |
| RIP:fill_with_garbage_skip                                           | 0          | 14         |            |               |
+----------------------------------------------------------------------+------------+------------+------------+---------------+

If you fix the issue, kindly add following tag
Reported-by: kernel test robot <lkp@intel.com>

[    8.991602] test_stackinit: packed_none FAIL (uninit bytes: 32)
[    8.992253] test_stackinit: user FAIL (uninit bytes: 32)
[    8.992842] test_stackinit: failures: 23
[    9.006247] test_meminit: all 10 tests in test_pages passed
[    9.014607] test_meminit: test_kvmalloc failed 10 out of 40 times
[    9.017906] BUG: sleeping function called from invalid context at mm/page_alloc.c:4664
[    9.019075] in_atomic(): 0, irqs_disabled(): 0, pid: 1, name: swapper
[    9.019793] 1 lock held by swapper/1:
[    9.020207]  #0: (____ptrval____) (rcu_read_lock){....}, at: test_meminit_init+0x64b/0xc9f
[    9.021156] Preemption disabled at:
[    9.021161] [<ffffffff812b1e1a>] slob_alloc+0x62/0x2eb
[    9.022305] CPU: 0 PID: 1 Comm: swapper Tainted: G                T 5.2.0-10846-g5015a30 #1
[    9.023218] Call Trace:
[    9.023505]  dump_stack+0x2e/0x3e
[    9.023883]  ___might_sleep+0x28c/0x2ad
[    9.024406]  __might_sleep+0xa1/0xaf
[    9.024815]  __alloc_pages_nodemask+0x138/0xf74
[    9.025318]  ? kvm_clock_read+0x2b/0x62
[    9.025745]  ? kvm_sched_clock_read+0x10/0x20
[    9.026351]  ? sched_clock_cpu+0xe1/0x11f
[    9.026800]  slob_new_pages+0x14/0x4b
[    9.027286]  slob_alloc+0x19f/0x2eb
[    9.027746]  __kmalloc+0x69/0xc4
[    9.028110]  test_meminit_init+0x6a4/0xc9f
[    9.028567]  ? test_meminit_init+0x64b/0xc9f
[    9.029043]  ? fill_with_garbage+0x43/0x43
[    9.029501]  do_one_initcall+0x9a/0x274
[    9.029980]  kernel_init_freeable+0x268/0x3e4
[    9.030543]  ? rest_init+0x1ac/0x1ac
[    9.030962]  kernel_init+0x10/0x1b1
[    9.031369]  ret_from_fork+0x35/0x40
[    9.032240] BUG: unable to handle page fault for address: ffff88801b033ac4
[    9.033000] #PF: supervisor read access in kernel mode
[    9.033566] #PF: error_code(0x0000) - not-present page
[    9.034276] PGD 5c00067 P4D 5c00067 PUD 5c01067 PMD 1f928067 PTE 800fffffe4fcc060
[    9.034280] Oops: 0000 [#1] PREEMPT DEBUG_PAGEALLOC PTI
[    9.034280] CPU: 0 PID: 1 Comm: swapper Tainted: G        W       T 5.2.0-10846-g5015a30 #1
[    9.034280] RIP: 0010:slob_page_alloc+0x31/0x262
[    9.034280] Code: c9 48 89 e5 41 57 41 56 41 55 49 89 cd 41 54 53 c6 01 00 4c 63 f2 48 8b 4f 20 49 d1 ea 49 89 fc 4d 89 f3 45 89 d7 31 db 31 d2 <66> 44 8b 01 66 45 85 c0 7e 09 48 ff 05 28 1f 82 03 eb 06 41 b8 01
[    9.034280] RSP: 0000:ffff88801e843d68 EFLAGS: 00010006
[    9.034280] RAX: ffff88801b033ac4 RBX: ffff88801b02b230 RCX: ffff88801b033ac4
[    9.034280] RDX: ffff88801b02b230 RSI: 000000000000010c RDI: ffff88801b02b230
[    9.034280] RBP: ffff88801e843d90 R08: 0000000000000101 R09: 0000000000000000
[    9.034280] R10: 000000000000010c R11: 0000000000000008 R12: ffffea00006c0ac0
[    9.034280] R13: ffff88801e843dbf R14: 0000000000000008 R15: 000000000000010c
[    9.034280] FS:  0000000000000000(0000) GS:ffffffff8387a000(0000) knlGS:0000000000000000
[    9.034280] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    9.034280] CR2: ffff88801b033ac4 CR3: 0000000003824001 CR4: 00000000003606f0
[    9.034280] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    9.034280] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[    9.034280] Call Trace:
[    9.034280]  slob_alloc+0xb2/0x2eb
[    9.034280]  kmem_cache_alloc+0x56/0xf2
[    9.034280]  test_meminit_init+0x5bf/0xc9f
[    9.034280]  ? fill_with_garbage+0x43/0x43
[    9.034280]  do_one_initcall+0x9a/0x274
[    9.034280]  kernel_init_freeable+0x268/0x3e4
[    9.034280]  ? rest_init+0x1ac/0x1ac
[    9.034280]  kernel_init+0x10/0x1b1
[    9.034280]  ret_from_fork+0x35/0x40
[    9.034280] Modules linked in:
[    9.034280] CR2: ffff88801b033ac4
[    9.034280] ---[ end trace a392338ad698f6fd ]---
[    9.034280] RIP: 0010:slob_page_alloc+0x31/0x262

                                                          # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
git bisect start 5f9e832c137075045d15cd6899ab0505cfb2ca4b v5.2 --
git bisect good 106f1466e7e7057ec6f4dc9516c13ea8cb9dffa0  # 22:47  G     10     0    0   0  Merge tag 'kconfig-v5.3' of git://git.kernel.org/pub/scm/linux/kernel/git/masahiroy/linux-kbuild
git bisect  bad fdcec00405fae0befdd7bbcbe738b7325e5746fb  # 23:05  B      0     3   18   0  Merge tag 'rproc-v5.3' of git://github.com/andersson/remoteproc
git bisect good fa6e951a2a440babd7a7310d0f4713e618061767  # 23:41  G     10     0    1   1  Merge tag 'ecryptfs-5.3-rc1-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/tyhicks/ecryptfs
git bisect good c309b6f24222246c18a8b65d3950e6e755440865  # 00:06  G     10     0    0   0  Merge tag 'docs/v5.3-1' of git://git.kernel.org/pub/scm/linux/kernel/git/mchehab/linux-media
git bisect  bad fa121bb3fed6313b1f0af23952301e06cf6d32ed  # 00:22  B      0     1   16   0  Merge tag 'mips_5.3' of git://git.kernel.org/pub/scm/linux/kernel/git/mips/linux
git bisect good 0a8ad0ffa4d80a544f6cbff703bf6394339afcdf  # 00:48  G     10     0    1   1  Merge tag 'for-linus-5.3-ofs1' of git://git.kernel.org/pub/scm/linux/kernel/git/hubcap/linux
git bisect  bad 415bfd9cdb175cf870fb173ae9d3958862de2c97  # 00:56  B      0     2   17   0  Merge tag 'for-linus-20190617' of git://git.sourceforge.jp/gitroot/uclinux-h8/linux
git bisect  bad 57a8ec387e1441ea5e1232bc0749fb99a8cba7e7  # 01:13  B      0     1   16   0  Merge branch 'akpm' (patches from Andrew)
git bisect  bad 6e51f8aa76b67d0a6eb168fd41a81e8478ae07a9  # 01:47  B      0     1   16   0  coda: potential buffer overflow in coda_psdev_write()
git bisect good fe6ba88b251aa76a94be2cb441d2e6b7c623b989  # 02:14  G     10     0    0   0  arch: replace _BITUL() in kernel-space headers with BIT()
git bisect  bad b4658cdd8cab49c978334dc5db9070d0d881e3dd  # 02:33  B      3     1    3   3  lib/string_helpers: fix some kerneldoc warnings
git bisect good 33d6e0ff68af74be0c846c8e042e84a9a1a0561e  # 04:15  G     61     0    1   1  lib/test_string.c: avoid masking memset16/32/64 failures
git bisect  bad 5015a300a522c8fb542dc993140e4c360cf4cf5f  # 04:29  B      1     1    1   1  lib: introduce test_meminit module
git bisect good 8e060c21ae2c265a2b596e9e7f9f97ec274151a4  # 05:35  G     61     0    4   4  lib/test_overflow.c: avoid tainting the kernel and fix wrap size
# first bad commit: [5015a300a522c8fb542dc993140e4c360cf4cf5f] lib: introduce test_meminit module
git bisect good 8e060c21ae2c265a2b596e9e7f9f97ec274151a4  # 06:27  G    180     0    5   9  lib/test_overflow.c: avoid tainting the kernel and fix wrap size
# extra tests on HEAD of internal-eywa/master
git bisect  bad 5a380be2937f374c3207f002f9d823a382e9e9ae  # 06:27  B      0    13   31   0  Intel Next: Add release files for v5.3-rc1 2019-07-23
# extra tests on tree/branch linus/master
git bisect  bad bed38c3e2dca01b358a62b5e73b46e875742fd75  # 06:40  B      0     2   17   0  Merge tag 'powerpc-5.3-2' of git://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux
# extra tests on tree/branch linux-next/master
git bisect  bad 9e6dfe8045f85f9b5aade47e4192482927e2791a  # 06:51  B      0     2   17   0  Add linux-next specific files for 20190724

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--=_5d38e189.pwMdpwxOIvHtesRvotcq8HpjKn1pXETahLhfmsG191XEpLEH
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-yocto-vm-yocto-8a0139c85771:20190725043221:x86_64-randconfig-n0-07242049:5.2.0-10846-g5015a30:1.gz"

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
/vzh349Y304tBs/su5tv4XHvP/QMQCNhfwAA

--=_5d38e189.pwMdpwxOIvHtesRvotcq8HpjKn1pXETahLhfmsG191XEpLEH
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-yocto-vm-yocto-206b1f8b98e6:20190725053224:x86_64-randconfig-n0-07242049:5.2.0-10845-g8e060c2:1.gz"

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

--=_5d38e189.pwMdpwxOIvHtesRvotcq8HpjKn1pXETahLhfmsG191XEpLEH
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="reproduce-yocto-vm-yocto-8a0139c85771:20190725043221:x86_64-randconfig-n0-07242049:5.2.0-10846-g5015a30:1"

#!/bin/bash

kernel=$1
initrd=yocto-trinity-x86_64.cgz

wget --no-clobber https://download.01.org/0day-ci/lkp-qemu/osimage/yocto/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu Haswell,+smep,+smap
	-kernel $kernel
	-initrd $initrd
	-m 512
	-smp 2
	-device e1000,netdev=net0
	-netdev user,id=net0,hostfwd=tcp::32032-:22
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

--=_5d38e189.pwMdpwxOIvHtesRvotcq8HpjKn1pXETahLhfmsG191XEpLEH
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="config-5.2.0-10846-g5015a30"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 5.2.0 Kernel Configuration
#

#
# Compiler: gcc-7 (Debian 7.4.0-9) 7.4.0
#
CONFIG_CC_IS_GCC=y
CONFIG_GCC_VERSION=70400
CONFIG_CLANG_VERSION=0
CONFIG_CC_CAN_LINK=y
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
# CONFIG_HEADER_TEST is not set
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
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_USELIB=y
CONFIG_AUDIT=y
CONFIG_HAVE_ARCH_AUDITSYSCALL=y
CONFIG_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_SIM=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_IRQ_MATRIX_ALLOCATOR=y
CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_GENERIC_IRQ_DEBUGFS=y
# end of IRQ subsystem

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
CONFIG_CONTEXT_TRACKING=y
# CONFIG_CONTEXT_TRACKING_FORCE is not set
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y
# end of Timers subsystem

# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
# CONFIG_TICK_CPU_ACCOUNTING is not set
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set
CONFIG_PSI=y
CONFIG_PSI_DEFAULT_DISABLED=y
# end of CPU/Task time and stats accounting

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
# CONFIG_RCU_BOOST is not set
# CONFIG_RCU_NOCB_CPU is not set
# end of RCU Subsystem

CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_IKHEADERS=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y

#
# Scheduler features
#
# end of Scheduler features

CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
# CONFIG_RT_GROUP_SCHED is not set
# CONFIG_CGROUP_PIDS is not set
# CONFIG_CGROUP_RDMA is not set
# CONFIG_CGROUP_FREEZER is not set
CONFIG_CGROUP_DEVICE=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_CGROUP_PERF=y
# CONFIG_CGROUP_BPF is not set
CONFIG_CGROUP_DEBUG=y
CONFIG_SOCK_CGROUP_DATA=y
# CONFIG_NAMESPACES is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
# CONFIG_RD_LZMA is not set
CONFIG_RD_XZ=y
# CONFIG_RD_LZO is not set
CONFIG_RD_LZ4=y
# CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_UID16=y
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_FHANDLE=y
CONFIG_POSIX_TIMERS=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
CONFIG_FUTEX_PI=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
# CONFIG_IO_URING is not set
# CONFIG_ADVISE_SYSCALLS is not set
CONFIG_MEMBARRIER=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_BPF_SYSCALL=y
# CONFIG_USERFAULTFD is not set
CONFIG_ARCH_HAS_MEMBARRIER_SYNC_CORE=y
# CONFIG_RSEQ is not set
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
# CONFIG_PC104 is not set

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
# end of Kernel Performance Events And Counters

CONFIG_VM_EVENT_COUNTERS=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
# CONFIG_SLUB is not set
CONFIG_SLOB=y
CONFIG_SLAB_MERGE_DEFAULT=y
CONFIG_SHUFFLE_PAGE_ALLOCATOR=y
# CONFIG_PROFILING is not set
# end of General setup

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
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
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
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_CC_HAS_SANE_STACKPROTECTOR=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
# CONFIG_SMP is not set
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_X2APIC=y
CONFIG_X86_MPPARSE=y
# CONFIG_GOLDFISH is not set
CONFIG_RETPOLINE=y
CONFIG_X86_CPU_RESCTRL=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_MID is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
# CONFIG_IOSF_MBI is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
CONFIG_PARAVIRT_XXL=y
CONFIG_PARAVIRT_DEBUG=y
CONFIG_X86_HV_CALLBACK_VECTOR=y
CONFIG_XEN=y
CONFIG_XEN_PV=y
CONFIG_XEN_DOM0=y
CONFIG_XEN_PVHVM=y
# CONFIG_XEN_512GB is not set
CONFIG_XEN_SAVE_RESTORE=y
# CONFIG_XEN_DEBUG_FS is not set
# CONFIG_XEN_PVH is not set
CONFIG_KVM_GUEST=y
CONFIG_PVH=y
CONFIG_KVM_DEBUG_FS=y
CONFIG_PARAVIRT_TIME_ACCOUNTING=y
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_JAILHOUSE_GUEST is not set
# CONFIG_ACRN_GUEST is not set
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_HYGON=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_CPU_SUP_ZHAOXIN=y
CONFIG_HPET_TIMER=y
# CONFIG_DMI is not set
# CONFIG_GART_IOMMU is not set
# CONFIG_CALGARY_IOMMU is not set
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
# CONFIG_X86_MCE_INTEL is not set
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=y

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
CONFIG_PERF_EVENTS_INTEL_RAPL=y
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
CONFIG_PERF_EVENTS_AMD_POWER=y
# end of Performance monitoring

CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=y
# CONFIG_MICROCODE is not set
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
# CONFIG_X86_5LEVEL is not set
# CONFIG_X86_CPA_STATISTICS is not set
CONFIG_ARCH_HAS_MEM_ENCRYPT=y
# CONFIG_AMD_MEM_ENCRYPT is not set
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
# CONFIG_MTRR is not set
# CONFIG_ARCH_RANDOM is not set
CONFIG_X86_SMAP=y
CONFIG_X86_INTEL_UMIP=y
# CONFIG_X86_INTEL_MPX is not set
CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS=y
CONFIG_EFI=y
# CONFIG_EFI_STUB is not set
CONFIG_SECCOMP=y
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_300=y
# CONFIG_HZ_1000 is not set
CONFIG_HZ=300
CONFIG_SCHED_HRTICK=y
# CONFIG_KEXEC is not set
# CONFIG_KEXEC_FILE is not set
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
# CONFIG_RANDOMIZE_BASE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_COMPAT_VDSO=y
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_XONLY is not set
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
# CONFIG_MODIFY_LDT_SYSCALL is not set
CONFIG_HAVE_LIVEPATCH=y
# end of Processor type and features

CONFIG_ARCH_HAS_ADD_PAGES=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_ARCH_ENABLE_THP_MIGRATION=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_SUSPEND_SKIP_SYNC is not set
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_PM_SLEEP=y
# CONFIG_PM_AUTOSLEEP is not set
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
CONFIG_PM_WAKELOCKS_GC=y
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_PM_CLK=y
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_ARCH_SUPPORTS_ACPI=y
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
CONFIG_ACPI_DEBUGGER=y
CONFIG_ACPI_DEBUGGER_USER=y
# CONFIG_ACPI_SPCR_TABLE is not set
CONFIG_ACPI_LPIT=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_REV_OVERRIDE_POSSIBLE is not set
CONFIG_ACPI_EC_DEBUGFS=y
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_TAD=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR_CSTATE=y
# CONFIG_ACPI_PROCESSOR is not set
# CONFIG_ACPI_IPMI is not set
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_TABLE_UPGRADE is not set
CONFIG_ACPI_DEBUG=y
# CONFIG_ACPI_PCI_SLOT is not set
# CONFIG_ACPI_CONTAINER is not set
CONFIG_ACPI_HOTPLUG_MEMORY=y
CONFIG_ACPI_HOTPLUG_IOAPIC=y
CONFIG_ACPI_SBS=y
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
CONFIG_ACPI_BGRT=y
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
CONFIG_ACPI_APEI=y
# CONFIG_ACPI_APEI_GHES is not set
# CONFIG_ACPI_APEI_EINJ is not set
CONFIG_ACPI_APEI_ERST_DEBUG=y
CONFIG_DPTF_POWER=y
CONFIG_ACPI_WATCHDOG=y
CONFIG_PMIC_OPREGION=y
CONFIG_CHT_DC_TI_PMIC_OPREGION=y
CONFIG_ACPI_CONFIGFS=y
CONFIG_X86_PM_TIMER=y
CONFIG_SFI=y

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set
# end of CPU Frequency scaling

#
# CPU Idle
#
# CONFIG_CPU_IDLE is not set
# end of CPU Idle
# end of Power management and ACPI options

#
# Bus options (PCI etc.)
#
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_XEN=y
CONFIG_MMCONF_FAM10H=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_ISA_BUS=y
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
# CONFIG_X86_SYSFB is not set
# end of Bus options (PCI etc.)

#
# Binary Emulations
#
CONFIG_IA32_EMULATION=y
# CONFIG_X86_X32 is not set
CONFIG_COMPAT_32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
# end of Binary Emulations

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
# CONFIG_FIRMWARE_MEMMAP is not set
CONFIG_ISCSI_IBFT_FIND=y
# CONFIG_FW_CFG_SYSFS is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# EFI (Extensible Firmware Interface) Support
#
CONFIG_EFI_VARS=y
CONFIG_EFI_ESRT=y
CONFIG_EFI_VARS_PSTORE=y
CONFIG_EFI_VARS_PSTORE_DEFAULT_DISABLE=y
# CONFIG_EFI_FAKE_MEMMAP is not set
CONFIG_EFI_RUNTIME_WRAPPERS=y
CONFIG_EFI_BOOTLOADER_CONTROL=y
CONFIG_EFI_CAPSULE_LOADER=y
CONFIG_EFI_TEST=y
# end of EFI (Extensible Firmware Interface) Support

CONFIG_UEFI_CPER=y
CONFIG_UEFI_CPER_X86=y
CONFIG_EFI_EARLYCON=y

#
# Tegra firmware driver
#
# end of Tegra firmware driver
# end of Firmware Drivers

CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_KVM is not set
CONFIG_VHOST_NET=y
CONFIG_VHOST_VSOCK=y
CONFIG_VHOST=y
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY is not set

#
# General architecture-dependent options
#
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_KPROBES is not set
CONFIG_JUMP_LABEL=y
CONFIG_STATIC_KEYS_SELFTEST=y
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
CONFIG_ARCH_HAS_SET_DIRECT_MAP=y
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
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_ARCH_STACKLEAK=y
CONFIG_HAVE_STACKPROTECTOR=y
CONFIG_CC_HAS_STACKPROTECTOR_NONE=y
# CONFIG_STACKPROTECTOR is not set
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
CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS=y
CONFIG_ARCH_MMAP_RND_COMPAT_BITS=8
CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES=y
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
CONFIG_HAVE_RELIABLE_STACKTRACE=y
CONFIG_ISA_BUS_API=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y
CONFIG_64BIT_TIME=y
CONFIG_COMPAT_32BIT_TIME=y
CONFIG_HAVE_ARCH_VMAP_STACK=y
# CONFIG_VMAP_STACK is not set
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_STRICT_MODULE_RWX=y
CONFIG_ARCH_HAS_REFCOUNT=y
# CONFIG_REFCOUNT_FULL is not set
CONFIG_HAVE_ARCH_PREL32_RELOCATIONS=y
CONFIG_ARCH_USE_MEMREMAP_PROT=y
# CONFIG_LOCK_EVENT_COUNTS is not set

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
CONFIG_GCOV_PROFILE_ALL=y
CONFIG_GCOV_FORMAT_4_7=y
# end of GCOV-based kernel profiling

CONFIG_PLUGIN_HOSTCC="g++"
CONFIG_HAVE_GCC_PLUGINS=y
CONFIG_GCC_PLUGINS=y

#
# GCC plugins
#
CONFIG_GCC_PLUGIN_CYC_COMPLEXITY=y
CONFIG_GCC_PLUGIN_LATENT_ENTROPY=y
CONFIG_GCC_PLUGIN_RANDSTRUCT=y
CONFIG_GCC_PLUGIN_RANDSTRUCT_PERFORMANCE=y
# end of GCC plugins
# end of General architecture-dependent options

CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
CONFIG_MODULES=y
# CONFIG_MODULE_FORCE_LOAD is not set
# CONFIG_MODULE_UNLOAD is not set
CONFIG_MODVERSIONS=y
# CONFIG_MODULE_SRCVERSION_ALL is not set
# CONFIG_MODULE_SIG is not set
# CONFIG_MODULE_COMPRESS is not set
CONFIG_MODULES_TREE_LOOKUP=y
# CONFIG_BLOCK is not set
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
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ELFCORE=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
CONFIG_BINFMT_SCRIPT=y
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
# end of Executable file formats

#
# Memory Management options
#
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_HAVE_FAST_GUP=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_HAVE_BOOTMEM_INFO_NODE=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE is not set
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_MEMORY_BALLOON=y
# CONFIG_BALLOON_COMPACTION is not set
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_CONTIG_ALLOC=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_MEMORY_FAILURE is not set
CONFIG_TRANSPARENT_HUGEPAGE=y
# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
CONFIG_ARCH_WANTS_THP_SWAP=y
CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
CONFIG_NEED_PER_CPU_KM=y
# CONFIG_CLEANCACHE is not set
CONFIG_CMA=y
CONFIG_CMA_DEBUG=y
CONFIG_CMA_DEBUGFS=y
CONFIG_CMA_AREAS=7
CONFIG_ZPOOL=y
CONFIG_ZBUD=y
CONFIG_Z3FOLD=y
# CONFIG_ZSMALLOC is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
# CONFIG_IDLE_PAGE_TRACKING is not set
CONFIG_ARCH_HAS_ZONE_DEVICE=y
CONFIG_ZONE_DEVICE=y
CONFIG_HMM_MIRROR=y
# CONFIG_DEVICE_PRIVATE is not set
CONFIG_FRAME_VECTOR=y
CONFIG_ARCH_USES_HIGH_VMA_FLAGS=y
CONFIG_ARCH_HAS_PKEYS=y
# CONFIG_PERCPU_STATS is not set
# CONFIG_GUP_BENCHMARK is not set
CONFIG_ARCH_HAS_PTE_SPECIAL=y
# end of Memory Management options

CONFIG_NET=y
CONFIG_NET_INGRESS=y
CONFIG_SKB_EXTENSIONS=y

#
# Networking options
#
CONFIG_PACKET=y
# CONFIG_PACKET_DIAG is not set
CONFIG_UNIX=y
CONFIG_UNIX_SCM=y
CONFIG_UNIX_DIAG=y
CONFIG_TLS=y
CONFIG_TLS_DEVICE=y
CONFIG_XFRM=y
CONFIG_XFRM_OFFLOAD=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
# CONFIG_XFRM_INTERFACE is not set
# CONFIG_XFRM_SUB_POLICY is not set
CONFIG_XFRM_MIGRATE=y
# CONFIG_XFRM_STATISTICS is not set
CONFIG_NET_KEY=y
CONFIG_NET_KEY_MIGRATE=y
CONFIG_XDP_SOCKETS=y
CONFIG_XDP_SOCKETS_DIAG=y
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
# CONFIG_NET_IPIP is not set
CONFIG_NET_IPGRE_DEMUX=y
CONFIG_NET_IP_TUNNEL=y
CONFIG_NET_IPGRE=y
# CONFIG_NET_IPGRE_BROADCAST is not set
CONFIG_IP_MROUTE_COMMON=y
# CONFIG_IP_MROUTE is not set
# CONFIG_SYN_COOKIES is not set
# CONFIG_NET_IPVTI is not set
CONFIG_NET_UDP_TUNNEL=y
CONFIG_NET_FOU=y
CONFIG_NET_FOU_IP_TUNNELS=y
# CONFIG_INET_AH is not set
CONFIG_INET_ESP=y
# CONFIG_INET_ESP_OFFLOAD is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_DIAG is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_TCP_MD5SIG=y
CONFIG_IPV6=y
CONFIG_IPV6_ROUTER_PREF=y
# CONFIG_IPV6_ROUTE_INFO is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
CONFIG_INET6_AH=y
CONFIG_INET6_ESP=y
CONFIG_INET6_ESP_OFFLOAD=y
# CONFIG_INET6_IPCOMP is not set
CONFIG_IPV6_MIP6=y
# CONFIG_IPV6_ILA is not set
CONFIG_INET6_TUNNEL=y
CONFIG_IPV6_VTI=y
# CONFIG_IPV6_SIT is not set
CONFIG_IPV6_TUNNEL=y
# CONFIG_IPV6_GRE is not set
CONFIG_IPV6_FOU=y
CONFIG_IPV6_FOU_TUNNEL=y
CONFIG_IPV6_MULTIPLE_TABLES=y
# CONFIG_IPV6_SUBTREES is not set
CONFIG_IPV6_MROUTE=y
# CONFIG_IPV6_MROUTE_MULTIPLE_TABLES is not set
# CONFIG_IPV6_PIMSM_V2 is not set
# CONFIG_IPV6_SEG6_LWTUNNEL is not set
# CONFIG_IPV6_SEG6_HMAC is not set
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_ADVANCED is not set

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_INGRESS=y
CONFIG_NETFILTER_NETLINK=y
CONFIG_NETFILTER_FAMILY_BRIDGE=y
CONFIG_NETFILTER_NETLINK_LOG=y
CONFIG_NF_CONNTRACK=y
CONFIG_NF_LOG_COMMON=y
CONFIG_NF_LOG_NETDEV=y
CONFIG_NF_CONNTRACK_SECMARK=y
CONFIG_NF_CONNTRACK_PROCFS=y
# CONFIG_NF_CONNTRACK_LABELS is not set
CONFIG_NF_CONNTRACK_FTP=y
# CONFIG_NF_CONNTRACK_IRC is not set
CONFIG_NF_CONNTRACK_BROADCAST=y
CONFIG_NF_CONNTRACK_NETBIOS_NS=y
# CONFIG_NF_CONNTRACK_SIP is not set
CONFIG_NF_CT_NETLINK=y
# CONFIG_NETFILTER_NETLINK_GLUE_CT is not set
CONFIG_NF_NAT=y
CONFIG_NF_NAT_FTP=y
CONFIG_NF_NAT_REDIRECT=y
CONFIG_NF_NAT_MASQUERADE=y
CONFIG_NF_TABLES=y
CONFIG_NF_TABLES_SET=y
# CONFIG_NF_TABLES_INET is not set
# CONFIG_NF_TABLES_NETDEV is not set
# CONFIG_NFT_NUMGEN is not set
CONFIG_NFT_CT=y
# CONFIG_NFT_FLOW_OFFLOAD is not set
CONFIG_NFT_COUNTER=y
CONFIG_NFT_LOG=y
# CONFIG_NFT_LIMIT is not set
CONFIG_NFT_MASQ=y
CONFIG_NFT_REDIR=y
# CONFIG_NFT_TUNNEL is not set
# CONFIG_NFT_OBJREF is not set
# CONFIG_NFT_QUOTA is not set
CONFIG_NFT_REJECT=y
# CONFIG_NFT_COMPAT is not set
# CONFIG_NFT_HASH is not set
CONFIG_NFT_XFRM=y
# CONFIG_NFT_SOCKET is not set
CONFIG_NFT_TPROXY=y
CONFIG_NF_FLOW_TABLE_INET=y
CONFIG_NF_FLOW_TABLE=y
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=y

#
# Xtables targets
#
# CONFIG_NETFILTER_XT_TARGET_CONNSECMARK is not set
# CONFIG_NETFILTER_XT_TARGET_LOG is not set
CONFIG_NETFILTER_XT_NAT=y
CONFIG_NETFILTER_XT_TARGET_NETMAP=y
# CONFIG_NETFILTER_XT_TARGET_NFLOG is not set
# CONFIG_NETFILTER_XT_TARGET_REDIRECT is not set
CONFIG_NETFILTER_XT_TARGET_MASQUERADE=y
CONFIG_NETFILTER_XT_TARGET_SECMARK=y
# CONFIG_NETFILTER_XT_TARGET_TCPMSS is not set

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y
# CONFIG_NETFILTER_XT_MATCH_CONNTRACK is not set
# CONFIG_NETFILTER_XT_MATCH_POLICY is not set
CONFIG_NETFILTER_XT_MATCH_STATE=y
# end of Core Netfilter Configuration

CONFIG_IP_SET=y
CONFIG_IP_SET_MAX=256
CONFIG_IP_SET_BITMAP_IP=y
CONFIG_IP_SET_BITMAP_IPMAC=y
CONFIG_IP_SET_BITMAP_PORT=y
CONFIG_IP_SET_HASH_IP=y
# CONFIG_IP_SET_HASH_IPMARK is not set
# CONFIG_IP_SET_HASH_IPPORT is not set
CONFIG_IP_SET_HASH_IPPORTIP=y
# CONFIG_IP_SET_HASH_IPPORTNET is not set
CONFIG_IP_SET_HASH_IPMAC=y
# CONFIG_IP_SET_HASH_MAC is not set
# CONFIG_IP_SET_HASH_NETPORTNET is not set
CONFIG_IP_SET_HASH_NET=y
# CONFIG_IP_SET_HASH_NETNET is not set
# CONFIG_IP_SET_HASH_NETPORT is not set
# CONFIG_IP_SET_HASH_NETIFACE is not set
CONFIG_IP_SET_LIST_SET=y
CONFIG_IP_VS=y
# CONFIG_IP_VS_IPV6 is not set
CONFIG_IP_VS_DEBUG=y
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
# CONFIG_IP_VS_PROTO_TCP is not set
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_AH_ESP=y
# CONFIG_IP_VS_PROTO_ESP is not set
CONFIG_IP_VS_PROTO_AH=y
CONFIG_IP_VS_PROTO_SCTP=y

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=y
CONFIG_IP_VS_WRR=y
# CONFIG_IP_VS_LC is not set
CONFIG_IP_VS_WLC=y
CONFIG_IP_VS_FO=y
# CONFIG_IP_VS_OVF is not set
CONFIG_IP_VS_LBLC=y
CONFIG_IP_VS_LBLCR=y
CONFIG_IP_VS_DH=y
CONFIG_IP_VS_SH=y
CONFIG_IP_VS_MH=y
CONFIG_IP_VS_SED=y
# CONFIG_IP_VS_NQ is not set

#
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=8

#
# IPVS MH scheduler
#
CONFIG_IP_VS_MH_TAB_INDEX=12

#
# IPVS application helper
#
# CONFIG_IP_VS_NFCT is not set

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
# CONFIG_NF_SOCKET_IPV4 is not set
CONFIG_NF_TPROXY_IPV4=y
# CONFIG_NF_TABLES_IPV4 is not set
# CONFIG_NF_TABLES_ARP is not set
# CONFIG_NF_FLOW_TABLE_IPV4 is not set
CONFIG_NF_DUP_IPV4=y
CONFIG_NF_LOG_ARP=y
# CONFIG_NF_LOG_IPV4 is not set
CONFIG_NF_REJECT_IPV4=y
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=y
# CONFIG_IP_NF_NAT is not set
# CONFIG_IP_NF_MANGLE is not set
# CONFIG_IP_NF_RAW is not set
# end of IP: Netfilter Configuration

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_SOCKET_IPV6=y
CONFIG_NF_TPROXY_IPV6=y
# CONFIG_NF_TABLES_IPV6 is not set
CONFIG_NF_FLOW_TABLE_IPV6=y
# CONFIG_NF_DUP_IPV6 is not set
CONFIG_NF_REJECT_IPV6=y
CONFIG_NF_LOG_IPV6=y
CONFIG_IP6_NF_IPTABLES=y
CONFIG_IP6_NF_MATCH_IPV6HEADER=y
CONFIG_IP6_NF_FILTER=y
CONFIG_IP6_NF_TARGET_REJECT=y
CONFIG_IP6_NF_MANGLE=y
CONFIG_IP6_NF_RAW=y
# end of IPv6: Netfilter Configuration

CONFIG_NF_DEFRAG_IPV6=y
# CONFIG_NF_TABLES_BRIDGE is not set
CONFIG_BRIDGE_NF_EBTABLES=y
# CONFIG_BRIDGE_EBT_BROUTE is not set
CONFIG_BRIDGE_EBT_T_FILTER=y
# CONFIG_BRIDGE_EBT_T_NAT is not set
CONFIG_BRIDGE_EBT_802_3=y
# CONFIG_BRIDGE_EBT_AMONG is not set
CONFIG_BRIDGE_EBT_ARP=y
CONFIG_BRIDGE_EBT_IP=y
# CONFIG_BRIDGE_EBT_IP6 is not set
# CONFIG_BRIDGE_EBT_LIMIT is not set
CONFIG_BRIDGE_EBT_MARK=y
CONFIG_BRIDGE_EBT_PKTTYPE=y
CONFIG_BRIDGE_EBT_STP=y
CONFIG_BRIDGE_EBT_VLAN=y
# CONFIG_BRIDGE_EBT_ARPREPLY is not set
CONFIG_BRIDGE_EBT_DNAT=y
CONFIG_BRIDGE_EBT_MARK_T=y
# CONFIG_BRIDGE_EBT_REDIRECT is not set
CONFIG_BRIDGE_EBT_SNAT=y
CONFIG_BRIDGE_EBT_LOG=y
CONFIG_BRIDGE_EBT_NFLOG=y
# CONFIG_BPFILTER is not set
CONFIG_IP_DCCP=y

#
# DCCP CCIDs Configuration
#
CONFIG_IP_DCCP_CCID2_DEBUG=y
# CONFIG_IP_DCCP_CCID3 is not set
# end of DCCP CCIDs Configuration

#
# DCCP Kernel Hacking
#
CONFIG_IP_DCCP_DEBUG=y
# end of DCCP Kernel Hacking

CONFIG_IP_SCTP=y
# CONFIG_SCTP_DBG_OBJCNT is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE=y
CONFIG_SCTP_COOKIE_HMAC_MD5=y
# CONFIG_SCTP_COOKIE_HMAC_SHA1 is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
CONFIG_ATM=y
# CONFIG_ATM_CLIP is not set
CONFIG_ATM_LANE=y
CONFIG_ATM_MPOA=y
# CONFIG_ATM_BR2684 is not set
# CONFIG_L2TP is not set
CONFIG_STP=y
CONFIG_GARP=y
CONFIG_BRIDGE=y
# CONFIG_BRIDGE_IGMP_SNOOPING is not set
CONFIG_BRIDGE_VLAN_FILTERING=y
CONFIG_HAVE_NET_DSA=y
CONFIG_NET_DSA=y
CONFIG_NET_DSA_TAG_8021Q=y
CONFIG_NET_DSA_TAG_BRCM_COMMON=y
CONFIG_NET_DSA_TAG_BRCM=y
CONFIG_NET_DSA_TAG_BRCM_PREPEND=y
CONFIG_NET_DSA_TAG_GSWIP=y
CONFIG_NET_DSA_TAG_DSA=y
CONFIG_NET_DSA_TAG_EDSA=y
CONFIG_NET_DSA_TAG_MTK=y
CONFIG_NET_DSA_TAG_KSZ_COMMON=y
CONFIG_NET_DSA_TAG_KSZ=y
CONFIG_NET_DSA_TAG_KSZ9477=y
CONFIG_NET_DSA_TAG_QCA=y
CONFIG_NET_DSA_TAG_LAN9303=y
CONFIG_NET_DSA_TAG_SJA1105=y
# CONFIG_NET_DSA_TAG_TRAILER is not set
CONFIG_VLAN_8021Q=y
CONFIG_VLAN_8021Q_GVRP=y
# CONFIG_VLAN_8021Q_MVRP is not set
CONFIG_DECNET=y
# CONFIG_DECNET_ROUTER is not set
CONFIG_LLC=y
# CONFIG_LLC2 is not set
CONFIG_ATALK=y
CONFIG_DEV_APPLETALK=y
CONFIG_IPDDP=y
# CONFIG_IPDDP_ENCAP is not set
CONFIG_X25=y
CONFIG_LAPB=y
# CONFIG_PHONET is not set
CONFIG_6LOWPAN=y
CONFIG_6LOWPAN_DEBUGFS=y
CONFIG_6LOWPAN_NHC=y
# CONFIG_6LOWPAN_NHC_DEST is not set
CONFIG_6LOWPAN_NHC_FRAGMENT=y
CONFIG_6LOWPAN_NHC_HOP=y
CONFIG_6LOWPAN_NHC_IPV6=y
# CONFIG_6LOWPAN_NHC_MOBILITY is not set
CONFIG_6LOWPAN_NHC_ROUTING=y
# CONFIG_6LOWPAN_NHC_UDP is not set
# CONFIG_6LOWPAN_GHC_EXT_HDR_HOP is not set
# CONFIG_6LOWPAN_GHC_UDP is not set
# CONFIG_6LOWPAN_GHC_ICMPV6 is not set
CONFIG_6LOWPAN_GHC_EXT_HDR_DEST=y
CONFIG_6LOWPAN_GHC_EXT_HDR_FRAG=y
CONFIG_6LOWPAN_GHC_EXT_HDR_ROUTE=y
CONFIG_IEEE802154=y
CONFIG_IEEE802154_NL802154_EXPERIMENTAL=y
CONFIG_IEEE802154_SOCKET=y
# CONFIG_IEEE802154_6LOWPAN is not set
# CONFIG_MAC802154 is not set
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=y
# CONFIG_NET_SCH_HTB is not set
CONFIG_NET_SCH_HFSC=y
CONFIG_NET_SCH_ATM=y
CONFIG_NET_SCH_PRIO=y
# CONFIG_NET_SCH_MULTIQ is not set
CONFIG_NET_SCH_RED=y
# CONFIG_NET_SCH_SFB is not set
# CONFIG_NET_SCH_SFQ is not set
CONFIG_NET_SCH_TEQL=y
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_CBS=y
# CONFIG_NET_SCH_ETF is not set
CONFIG_NET_SCH_TAPRIO=y
# CONFIG_NET_SCH_GRED is not set
# CONFIG_NET_SCH_DSMARK is not set
# CONFIG_NET_SCH_NETEM is not set
# CONFIG_NET_SCH_DRR is not set
# CONFIG_NET_SCH_MQPRIO is not set
CONFIG_NET_SCH_SKBPRIO=y
CONFIG_NET_SCH_CHOKE=y
CONFIG_NET_SCH_QFQ=y
CONFIG_NET_SCH_CODEL=y
CONFIG_NET_SCH_FQ_CODEL=y
CONFIG_NET_SCH_CAKE=y
# CONFIG_NET_SCH_FQ is not set
CONFIG_NET_SCH_HHF=y
CONFIG_NET_SCH_PIE=y
# CONFIG_NET_SCH_PLUG is not set
CONFIG_NET_SCH_DEFAULT=y
CONFIG_DEFAULT_CODEL=y
# CONFIG_DEFAULT_FQ_CODEL is not set
# CONFIG_DEFAULT_PFIFO_FAST is not set
CONFIG_DEFAULT_NET_SCH="pfifo_fast"

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=y
CONFIG_NET_CLS_TCINDEX=y
CONFIG_NET_CLS_ROUTE4=y
CONFIG_NET_CLS_FW=y
CONFIG_NET_CLS_U32=y
CONFIG_CLS_U32_PERF=y
# CONFIG_CLS_U32_MARK is not set
CONFIG_NET_CLS_RSVP=y
CONFIG_NET_CLS_RSVP6=y
CONFIG_NET_CLS_FLOW=y
# CONFIG_NET_CLS_CGROUP is not set
# CONFIG_NET_CLS_BPF is not set
CONFIG_NET_CLS_FLOWER=y
CONFIG_NET_CLS_MATCHALL=y
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=y
CONFIG_NET_EMATCH_NBYTE=y
# CONFIG_NET_EMATCH_U32 is not set
CONFIG_NET_EMATCH_META=y
# CONFIG_NET_EMATCH_TEXT is not set
CONFIG_NET_EMATCH_CANID=y
CONFIG_NET_EMATCH_IPSET=y
CONFIG_NET_EMATCH_IPT=y
# CONFIG_NET_CLS_ACT is not set
CONFIG_NET_SCH_FIFO=y
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
CONFIG_OPENVSWITCH=y
CONFIG_OPENVSWITCH_GRE=y
CONFIG_VSOCKETS=y
# CONFIG_VSOCKETS_DIAG is not set
CONFIG_VIRTIO_VSOCKETS=y
CONFIG_VIRTIO_VSOCKETS_COMMON=y
CONFIG_HYPERV_VSOCKETS=y
CONFIG_NETLINK_DIAG=y
CONFIG_MPLS=y
CONFIG_NET_MPLS_GSO=y
# CONFIG_MPLS_ROUTING is not set
CONFIG_NET_NSH=y
CONFIG_HSR=y
CONFIG_NET_SWITCHDEV=y
CONFIG_NET_L3_MASTER_DEV=y
CONFIG_NET_NCSI=y
CONFIG_NCSI_OEM_CMD_GET_MAC=y
CONFIG_CGROUP_NET_PRIO=y
CONFIG_CGROUP_NET_CLASSID=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
# CONFIG_BPF_JIT is not set

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# end of Network testing
# end of Networking options

# CONFIG_HAMRADIO is not set
CONFIG_CAN=y
# CONFIG_CAN_RAW is not set
CONFIG_CAN_BCM=y
CONFIG_CAN_GW=y

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
# CONFIG_CAN_VXCAN is not set
CONFIG_CAN_SLCAN=y
CONFIG_CAN_DEV=y
# CONFIG_CAN_CALC_BITTIMING is not set
# CONFIG_CAN_FLEXCAN is not set
CONFIG_CAN_GRCAN=y
# CONFIG_CAN_C_CAN is not set
CONFIG_CAN_CC770=y
# CONFIG_CAN_CC770_ISA is not set
# CONFIG_CAN_CC770_PLATFORM is not set
CONFIG_CAN_IFI_CANFD=y
# CONFIG_CAN_M_CAN is not set
# CONFIG_CAN_PEAK_PCIEFD is not set
# CONFIG_CAN_SJA1000 is not set
# CONFIG_CAN_SOFTING is not set

#
# CAN USB interfaces
#
# CONFIG_CAN_8DEV_USB is not set
# CONFIG_CAN_EMS_USB is not set
CONFIG_CAN_ESD_USB2=y
CONFIG_CAN_GS_USB=y
# CONFIG_CAN_KVASER_USB is not set
CONFIG_CAN_MCBA_USB=y
CONFIG_CAN_PEAK_USB=y
CONFIG_CAN_UCAN=y
# end of CAN USB interfaces

# CONFIG_CAN_DEBUG_DEVICES is not set
# end of CAN Device Drivers

CONFIG_BT=y
CONFIG_BT_BREDR=y
CONFIG_BT_RFCOMM=y
CONFIG_BT_RFCOMM_TTY=y
CONFIG_BT_BNEP=y
# CONFIG_BT_BNEP_MC_FILTER is not set
# CONFIG_BT_BNEP_PROTO_FILTER is not set
CONFIG_BT_HIDP=y
CONFIG_BT_HS=y
CONFIG_BT_LE=y
CONFIG_BT_6LOWPAN=y
CONFIG_BT_LEDS=y
CONFIG_BT_SELFTEST=y
CONFIG_BT_SELFTEST_ECDH=y
# CONFIG_BT_SELFTEST_SMP is not set
CONFIG_BT_DEBUGFS=y

#
# Bluetooth device drivers
#
# CONFIG_BT_HCIBTUSB is not set
CONFIG_BT_HCIUART=y
CONFIG_BT_HCIUART_H4=y
CONFIG_BT_HCIUART_BCSP=y
CONFIG_BT_HCIUART_ATH3K=y
# CONFIG_BT_HCIUART_INTEL is not set
# CONFIG_BT_HCIUART_AG6XX is not set
CONFIG_BT_HCIBCM203X=y
# CONFIG_BT_HCIBPA10X is not set
# CONFIG_BT_HCIBFUSB is not set
CONFIG_BT_HCIDTL1=y
# CONFIG_BT_HCIBT3C is not set
# CONFIG_BT_HCIBLUECARD is not set
CONFIG_BT_HCIVHCI=y
CONFIG_BT_MRVL=y
CONFIG_BT_WILINK=y
# end of Bluetooth device drivers

CONFIG_AF_RXRPC=y
CONFIG_AF_RXRPC_IPV6=y
# CONFIG_AF_RXRPC_INJECT_LOSS is not set
# CONFIG_AF_RXRPC_DEBUG is not set
CONFIG_RXKAD=y
# CONFIG_AF_KCM is not set
CONFIG_STREAM_PARSER=y
CONFIG_FIB_RULES=y
# CONFIG_WIRELESS is not set
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_XEN is not set
# CONFIG_NET_9P_DEBUG is not set
CONFIG_CAIF=y
# CONFIG_CAIF_DEBUG is not set
CONFIG_CAIF_NETDEV=y
# CONFIG_CAIF_USB is not set
CONFIG_CEPH_LIB=y
CONFIG_CEPH_LIB_PRETTYDEBUG=y
CONFIG_CEPH_LIB_USE_DNS_RESOLVER=y
# CONFIG_NFC is not set
CONFIG_PSAMPLE=y
CONFIG_NET_IFE=y
# CONFIG_LWTUNNEL is not set
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
CONFIG_SOCK_VALIDATE_XMIT=y
CONFIG_NET_SOCK_MSG=y
CONFIG_NET_DEVLINK=y
CONFIG_FAILOVER=y
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#
CONFIG_HAVE_EISA=y
# CONFIG_EISA is not set
CONFIG_HAVE_PCI=y
CONFIG_PCI=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCIEPORTBUS is not set
# CONFIG_PCI_MSI is not set
CONFIG_PCI_QUIRKS=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_STUB is not set
CONFIG_XEN_PCIDEV_FRONTEND=y
CONFIG_PCI_LOCKLESS_CONFIG=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
# CONFIG_PCI_P2PDMA is not set
CONFIG_PCI_LABEL=y
# CONFIG_HOTPLUG_PCI is not set

#
# PCI controller drivers
#

#
# Cadence PCIe controllers support
#
# CONFIG_PCIE_CADENCE_HOST is not set
# end of Cadence PCIe controllers support

# CONFIG_PCI_FTPCI100 is not set
# CONFIG_PCI_HOST_GENERIC is not set
# CONFIG_PCIE_XILINX is not set

#
# DesignWare PCI Core Support
#
# end of DesignWare PCI Core Support
# end of PCI controller drivers

#
# PCI Endpoint
#
# CONFIG_PCI_ENDPOINT is not set
# end of PCI Endpoint

#
# PCI switch controller drivers
#
# CONFIG_PCI_SW_SWITCHTEC is not set
# end of PCI switch controller drivers

CONFIG_PCCARD=y
CONFIG_PCMCIA=y
CONFIG_PCMCIA_LOAD_CIS=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
# CONFIG_RAPIDIO is not set

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER=y
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y

#
# Firmware loader
#
CONFIG_FW_LOADER=y
CONFIG_FW_LOADER_PAGED_BUF=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
# CONFIG_FW_LOADER_COMPRESS is not set
# end of Firmware loader

CONFIG_WANT_DEV_COREDUMP=y
# CONFIG_ALLOW_DEV_COREDUMP is not set
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
# CONFIG_TEST_ASYNC_DRIVER_PROBE is not set
CONFIG_SYS_HYPERVISOR=y
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_GENERIC_CPU_VULNERABILITIES=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_W1=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
# CONFIG_DMA_FENCE_TRACE is not set
# end of Generic Driver Options

#
# Bus devices
#
# CONFIG_SIMPLE_PM_BUS is not set
# end of Bus devices

CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
CONFIG_GNSS=y
# CONFIG_MTD is not set
CONFIG_DTC=y
CONFIG_OF=y
CONFIG_OF_UNITTEST=y
CONFIG_OF_FLATTREE=y
CONFIG_OF_EARLY_FLATTREE=y
CONFIG_OF_KOBJ=y
CONFIG_OF_DYNAMIC=y
CONFIG_OF_ADDRESS=y
CONFIG_OF_IRQ=y
CONFIG_OF_NET=y
CONFIG_OF_MDIO=y
CONFIG_OF_RESERVED_MEM=y
CONFIG_OF_RESOLVE=y
CONFIG_OF_OVERLAY=y
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
# CONFIG_PARPORT_PC is not set
CONFIG_PARPORT_AX88796=y
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y

#
# NVME Support
#
# end of NVME Support

#
# Misc devices
#
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_ICS932S401 is not set
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
# CONFIG_ISL29003 is not set
CONFIG_ISL29020=y
# CONFIG_SENSORS_TSL2550 is not set
CONFIG_SENSORS_BH1770=y
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
# CONFIG_DS1682 is not set
# CONFIG_SRAM is not set
# CONFIG_PCI_ENDPOINT_TEST is not set
# CONFIG_XILINX_SDFEC is not set
CONFIG_MISC_RTSX=y
CONFIG_PVPANIC=y
CONFIG_C2PORT=y
# CONFIG_C2PORT_DURAMAR_2150 is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
CONFIG_EEPROM_LEGACY=y
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=y
CONFIG_EEPROM_IDT_89HPESX=y
CONFIG_EEPROM_EE1004=y
# end of EEPROM support

# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
CONFIG_TI_ST=y
# end of Texas Instruments shared transport line discipline

# CONFIG_SENSORS_LIS3_I2C is not set
CONFIG_ALTERA_STAPL=y
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_INTEL_MEI_TXE is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC & related support
#

#
# Intel MIC Bus Driver
#
# CONFIG_INTEL_MIC_BUS is not set

#
# SCIF Bus Driver
#
# CONFIG_SCIF_BUS is not set

#
# VOP Bus Driver
#
# CONFIG_VOP_BUS is not set

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
CONFIG_VHOST_RING=y
# end of Intel MIC & related support

# CONFIG_GENWQE is not set
# CONFIG_ECHO is not set
# CONFIG_MISC_ALCOR_PCI is not set
# CONFIG_MISC_RTSX_PCI is not set
CONFIG_MISC_RTSX_USB=y
# CONFIG_HABANA_AI is not set
# end of Misc devices

CONFIG_HAVE_IDE=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# end of SCSI device support

# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# end of IEEE 1394 (FireWire) support

# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_MII=y
CONFIG_NET_CORE=y
CONFIG_BONDING=y
CONFIG_DUMMY=y
CONFIG_EQUALIZER=y
CONFIG_NET_TEAM=y
CONFIG_NET_TEAM_MODE_BROADCAST=y
# CONFIG_NET_TEAM_MODE_ROUNDROBIN is not set
CONFIG_NET_TEAM_MODE_RANDOM=y
CONFIG_NET_TEAM_MODE_ACTIVEBACKUP=y
# CONFIG_NET_TEAM_MODE_LOADBALANCE is not set
CONFIG_MACVLAN=y
CONFIG_MACVTAP=y
CONFIG_IPVLAN_L3S=y
CONFIG_IPVLAN=y
CONFIG_IPVTAP=y
# CONFIG_VXLAN is not set
# CONFIG_GENEVE is not set
CONFIG_GTP=y
# CONFIG_MACSEC is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_TUN is not set
CONFIG_TAP=y
# CONFIG_TUN_VNET_CROSS_LE is not set
CONFIG_VETH=y
CONFIG_VIRTIO_NET=y
CONFIG_NLMON=y
CONFIG_VSOCKMON=y
# CONFIG_ARCNET is not set
CONFIG_ATM_DRIVERS=y
CONFIG_ATM_DUMMY=y
# CONFIG_ATM_TCP is not set
# CONFIG_ATM_LANAI is not set
# CONFIG_ATM_ENI is not set
# CONFIG_ATM_FIRESTREAM is not set
# CONFIG_ATM_ZATM is not set
# CONFIG_ATM_NICSTAR is not set
# CONFIG_ATM_IDT77252 is not set
# CONFIG_ATM_AMBASSADOR is not set
# CONFIG_ATM_HORIZON is not set
# CONFIG_ATM_IA is not set
# CONFIG_ATM_FORE200E is not set
# CONFIG_ATM_HE is not set
# CONFIG_ATM_SOLOS is not set

#
# CAIF transport drivers
#
# CONFIG_CAIF_TTY is not set
CONFIG_CAIF_SPI_SLAVE=y
# CONFIG_CAIF_SPI_SYNC is not set
# CONFIG_CAIF_HSI is not set
CONFIG_CAIF_VIRTIO=y

#
# Distributed Switch Architecture drivers
#
CONFIG_B53=y
# CONFIG_B53_MDIO_DRIVER is not set
CONFIG_B53_MMAP_DRIVER=y
CONFIG_B53_SRAB_DRIVER=y
# CONFIG_B53_SERDES is not set
CONFIG_NET_DSA_BCM_SF2=y
CONFIG_NET_DSA_LOOP=y
CONFIG_NET_DSA_LANTIQ_GSWIP=y
CONFIG_NET_DSA_MT7530=y
# CONFIG_NET_DSA_MV88E6060 is not set
# CONFIG_NET_DSA_MICROCHIP_KSZ9477 is not set
CONFIG_NET_DSA_MV88E6XXX=y
CONFIG_NET_DSA_MV88E6XXX_GLOBAL2=y
CONFIG_NET_DSA_MV88E6XXX_PTP=y
# CONFIG_NET_DSA_QCA8K is not set
# CONFIG_NET_DSA_REALTEK_SMI is not set
CONFIG_NET_DSA_SMSC_LAN9303=y
CONFIG_NET_DSA_SMSC_LAN9303_I2C=y
CONFIG_NET_DSA_SMSC_LAN9303_MDIO=y
CONFIG_NET_DSA_VITESSE_VSC73XX=y
CONFIG_NET_DSA_VITESSE_VSC73XX_PLATFORM=y
# end of Distributed Switch Architecture drivers

CONFIG_ETHERNET=y
CONFIG_NET_VENDOR_3COM=y
CONFIG_PCMCIA_3C574=y
CONFIG_PCMCIA_3C589=y
# CONFIG_VORTEX is not set
# CONFIG_TYPHOON is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_AGERE=y
# CONFIG_ET131X is not set
# CONFIG_NET_VENDOR_ALACRITECH is not set
CONFIG_NET_VENDOR_ALTEON=y
# CONFIG_ACENIC is not set
CONFIG_ALTERA_TSE=y
# CONFIG_NET_VENDOR_AMAZON is not set
# CONFIG_NET_VENDOR_AMD is not set
# CONFIG_NET_VENDOR_AQUANTIA is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_ALX is not set
# CONFIG_NET_VENDOR_AURORA is not set
CONFIG_NET_VENDOR_BROADCOM=y
CONFIG_B44=y
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y
CONFIG_BCMGENET=y
# CONFIG_BNX2 is not set
# CONFIG_CNIC is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2X is not set
CONFIG_SYSTEMPORT=y
# CONFIG_BNXT is not set
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
CONFIG_NET_VENDOR_CADENCE=y
CONFIG_MACB=y
# CONFIG_MACB_USE_HWSTAMP is not set
# CONFIG_MACB_PCI is not set
CONFIG_NET_VENDOR_CAVIUM=y
# CONFIG_THUNDER_NIC_PF is not set
# CONFIG_THUNDER_NIC_VF is not set
# CONFIG_THUNDER_NIC_BGX is not set
# CONFIG_THUNDER_NIC_RGX is not set
# CONFIG_CAVIUM_PTP is not set
# CONFIG_LIQUIDIO is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
# CONFIG_NET_VENDOR_CORTINA is not set
# CONFIG_CX_ECAT is not set
CONFIG_DNET=y
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DL2K is not set
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
# CONFIG_NET_VENDOR_EZCHIP is not set
CONFIG_NET_VENDOR_FUJITSU=y
# CONFIG_PCMCIA_FMVJ18X is not set
# CONFIG_NET_VENDOR_GOOGLE is not set
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_HUAWEI=y
CONFIG_NET_VENDOR_I825XX=y
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
# CONFIG_E1000E is not set
# CONFIG_IGB is not set
# CONFIG_IGBVF is not set
# CONFIG_IXGB is not set
# CONFIG_IXGBE is not set
# CONFIG_I40E is not set
# CONFIG_IGC is not set
# CONFIG_JME is not set
CONFIG_NET_VENDOR_MARVELL=y
CONFIG_MVMDIO=y
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX5_CORE is not set
# CONFIG_MLXSW_CORE is not set
# CONFIG_MLXFW is not set
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8851_MLL is not set
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MICROCHIP=y
# CONFIG_LAN743X is not set
CONFIG_NET_VENDOR_MICROSEMI=y
# CONFIG_MSCC_OCELOT_SWITCH is not set
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
# CONFIG_FEALNX is not set
# CONFIG_NET_VENDOR_NATSEMI is not set
CONFIG_NET_VENDOR_NETERION=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
# CONFIG_NET_VENDOR_NETRONOME is not set
# CONFIG_NET_VENDOR_NI is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
CONFIG_ETHOC=y
CONFIG_NET_VENDOR_PACKET_ENGINES=y
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
# CONFIG_QED is not set
# CONFIG_NET_VENDOR_QUALCOMM is not set
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
# CONFIG_NET_VENDOR_REALTEK is not set
CONFIG_NET_VENDOR_RENESAS=y
# CONFIG_NET_VENDOR_ROCKER is not set
CONFIG_NET_VENDOR_SAMSUNG=y
CONFIG_SXGBE_ETH=y
# CONFIG_NET_VENDOR_SEEQ is not set
CONFIG_NET_VENDOR_SOLARFLARE=y
# CONFIG_SFC is not set
# CONFIG_SFC_FALCON is not set
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
# CONFIG_SIS190 is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_PCMCIA_SMC91C92 is not set
# CONFIG_EPIC100 is not set
CONFIG_SMSC911X=y
# CONFIG_SMSC9420 is not set
# CONFIG_NET_VENDOR_SOCIONEXT is not set
# CONFIG_NET_VENDOR_STMICRO is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_SYNOPSYS=y
CONFIG_DWC_XLGMAC=y
# CONFIG_DWC_XLGMAC_PCI is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TI_CPSW_PHY_SEL is not set
# CONFIG_TLAN is not set
# CONFIG_NET_VENDOR_VIA is not set
CONFIG_NET_VENDOR_WIZNET=y
CONFIG_WIZNET_W5100=y
CONFIG_WIZNET_W5300=y
CONFIG_WIZNET_BUS_DIRECT=y
# CONFIG_WIZNET_BUS_INDIRECT is not set
# CONFIG_WIZNET_BUS_ANY is not set
# CONFIG_NET_VENDOR_XILINX is not set
# CONFIG_NET_VENDOR_XIRCOM is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_MDIO_DEVICE=y
CONFIG_MDIO_BUS=y
CONFIG_MDIO_BCM_UNIMAC=y
CONFIG_MDIO_BITBANG=y
CONFIG_MDIO_BUS_MUX=y
CONFIG_MDIO_BUS_MUX_GPIO=y
CONFIG_MDIO_BUS_MUX_MMIOREG=y
CONFIG_MDIO_BUS_MUX_MULTIPLEXER=y
CONFIG_MDIO_CAVIUM=y
# CONFIG_MDIO_GPIO is not set
CONFIG_MDIO_HISI_FEMAC=y
# CONFIG_MDIO_MSCC_MIIM is not set
CONFIG_MDIO_OCTEON=y
# CONFIG_MDIO_THUNDER is not set
CONFIG_PHYLINK=y
CONFIG_PHYLIB=y
CONFIG_SWPHY=y
# CONFIG_LED_TRIGGER_PHY is not set

#
# MII PHY device drivers
#
# CONFIG_SFP is not set
# CONFIG_AMD_PHY is not set
CONFIG_AQUANTIA_PHY=y
CONFIG_AX88796B_PHY=y
CONFIG_AT803X_PHY=y
CONFIG_BCM7XXX_PHY=y
# CONFIG_BCM87XX_PHY is not set
CONFIG_BCM_NET_PHYLIB=y
CONFIG_BROADCOM_PHY=y
CONFIG_CICADA_PHY=y
# CONFIG_CORTINA_PHY is not set
# CONFIG_DAVICOM_PHY is not set
CONFIG_DP83822_PHY=y
CONFIG_DP83TC811_PHY=y
CONFIG_DP83848_PHY=y
# CONFIG_DP83867_PHY is not set
CONFIG_FIXED_PHY=y
CONFIG_ICPLUS_PHY=y
CONFIG_INTEL_XWAY_PHY=y
CONFIG_LSI_ET1011C_PHY=y
# CONFIG_LXT_PHY is not set
CONFIG_MARVELL_PHY=y
CONFIG_MARVELL_10G_PHY=y
CONFIG_MICREL_PHY=y
# CONFIG_MICROCHIP_PHY is not set
CONFIG_MICROCHIP_T1_PHY=y
CONFIG_MICROSEMI_PHY=y
# CONFIG_NATIONAL_PHY is not set
CONFIG_NXP_TJA11XX_PHY=y
CONFIG_QSEMI_PHY=y
CONFIG_REALTEK_PHY=y
# CONFIG_RENESAS_PHY is not set
CONFIG_ROCKCHIP_PHY=y
CONFIG_SMSC_PHY=y
# CONFIG_STE10XP is not set
# CONFIG_TERANETICS_PHY is not set
CONFIG_VITESSE_PHY=y
CONFIG_XILINX_GMII2RGMII=y
CONFIG_PLIP=y
CONFIG_PPP=y
CONFIG_PPP_BSDCOMP=y
CONFIG_PPP_DEFLATE=y
# CONFIG_PPP_FILTER is not set
CONFIG_PPP_MPPE=y
# CONFIG_PPP_MULTILINK is not set
CONFIG_PPPOATM=y
# CONFIG_PPPOE is not set
CONFIG_PPTP=y
CONFIG_PPP_ASYNC=y
CONFIG_PPP_SYNC_TTY=y
CONFIG_SLIP=y
CONFIG_SLHC=y
# CONFIG_SLIP_COMPRESSED is not set
# CONFIG_SLIP_SMART is not set
# CONFIG_SLIP_MODE_SLIP6 is not set
CONFIG_USB_NET_DRIVERS=y
CONFIG_USB_CATC=y
CONFIG_USB_KAWETH=y
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
CONFIG_USB_RTL8152=y
# CONFIG_USB_LAN78XX is not set
# CONFIG_USB_USBNET is not set
# CONFIG_USB_IPHETH is not set
# CONFIG_WLAN is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
CONFIG_WAN=y
# CONFIG_LANMEDIA is not set
CONFIG_HDLC=y
# CONFIG_HDLC_RAW is not set
# CONFIG_HDLC_RAW_ETH is not set
# CONFIG_HDLC_CISCO is not set
CONFIG_HDLC_FR=y
CONFIG_HDLC_PPP=y
CONFIG_HDLC_X25=y
# CONFIG_PCI200SYN is not set
# CONFIG_WANXL is not set
# CONFIG_PC300TOO is not set
# CONFIG_FARSYNC is not set
# CONFIG_DSCC4 is not set
CONFIG_DLCI=y
CONFIG_DLCI_MAX=8
# CONFIG_LAPBETHER is not set
CONFIG_X25_ASY=y
# CONFIG_SBNI is not set
# CONFIG_IEEE802154_DRIVERS is not set
CONFIG_XEN_NETDEV_FRONTEND=y
CONFIG_XEN_NETDEV_BACKEND=y
# CONFIG_VMXNET3 is not set
CONFIG_FUJITSU_ES=y
# CONFIG_HYPERV_NET is not set
CONFIG_NETDEVSIM=y
CONFIG_NET_FAILOVER=y
# CONFIG_ISDN is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_LEDS is not set
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
CONFIG_INPUT_JOYDEV=y
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADC is not set
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1050 is not set
# CONFIG_KEYBOARD_QT1070 is not set
CONFIG_KEYBOARD_QT2160=y
# CONFIG_KEYBOARD_DLINK_DIR685 is not set
CONFIG_KEYBOARD_LKKBD=y
# CONFIG_KEYBOARD_GPIO is not set
CONFIG_KEYBOARD_GPIO_POLLED=y
CONFIG_KEYBOARD_TCA6416=y
CONFIG_KEYBOARD_TCA8418=y
# CONFIG_KEYBOARD_MATRIX is not set
CONFIG_KEYBOARD_LM8323=y
CONFIG_KEYBOARD_LM8333=y
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
CONFIG_KEYBOARD_NEWTON=y
CONFIG_KEYBOARD_OPENCORES=y
# CONFIG_KEYBOARD_SAMSUNG is not set
CONFIG_KEYBOARD_STOWAWAY=y
CONFIG_KEYBOARD_SUNKBD=y
CONFIG_KEYBOARD_OMAP4=y
CONFIG_KEYBOARD_TM2_TOUCHKEY=y
CONFIG_KEYBOARD_TWL4030=y
CONFIG_KEYBOARD_XTKBD=y
CONFIG_KEYBOARD_CROS_EC=y
CONFIG_KEYBOARD_CAP11XX=y
CONFIG_KEYBOARD_BCM=y
CONFIG_KEYBOARD_MTK_PMIC=y
CONFIG_INPUT_MOUSE=y
# CONFIG_MOUSE_PS2 is not set
CONFIG_MOUSE_SERIAL=y
CONFIG_MOUSE_APPLETOUCH=y
CONFIG_MOUSE_BCM5974=y
# CONFIG_MOUSE_CYAPA is not set
# CONFIG_MOUSE_ELAN_I2C is not set
CONFIG_MOUSE_VSXXXAA=y
CONFIG_MOUSE_GPIO=y
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
CONFIG_MOUSE_SYNAPTICS_USB=y
CONFIG_INPUT_JOYSTICK=y
CONFIG_JOYSTICK_ANALOG=y
CONFIG_JOYSTICK_A3D=y
# CONFIG_JOYSTICK_ADI is not set
# CONFIG_JOYSTICK_COBRA is not set
# CONFIG_JOYSTICK_GF2K is not set
CONFIG_JOYSTICK_GRIP=y
CONFIG_JOYSTICK_GRIP_MP=y
# CONFIG_JOYSTICK_GUILLEMOT is not set
# CONFIG_JOYSTICK_INTERACT is not set
CONFIG_JOYSTICK_SIDEWINDER=y
CONFIG_JOYSTICK_TMDC=y
# CONFIG_JOYSTICK_IFORCE is not set
CONFIG_JOYSTICK_WARRIOR=y
CONFIG_JOYSTICK_MAGELLAN=y
CONFIG_JOYSTICK_SPACEORB=y
CONFIG_JOYSTICK_SPACEBALL=y
CONFIG_JOYSTICK_STINGER=y
# CONFIG_JOYSTICK_TWIDJOY is not set
# CONFIG_JOYSTICK_ZHENHUA is not set
# CONFIG_JOYSTICK_DB9 is not set
CONFIG_JOYSTICK_GAMECON=y
CONFIG_JOYSTICK_TURBOGRAFX=y
# CONFIG_JOYSTICK_AS5011 is not set
CONFIG_JOYSTICK_JOYDUMP=y
CONFIG_JOYSTICK_XPAD=y
# CONFIG_JOYSTICK_XPAD_FF is not set
CONFIG_JOYSTICK_XPAD_LEDS=y
CONFIG_JOYSTICK_WALKERA0701=y
# CONFIG_JOYSTICK_PXRC is not set
# CONFIG_INPUT_TABLET is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_PROPERTIES=y
CONFIG_TOUCHSCREEN_88PM860X=y
# CONFIG_TOUCHSCREEN_AD7879 is not set
CONFIG_TOUCHSCREEN_ADC=y
CONFIG_TOUCHSCREEN_AR1021_I2C=y
CONFIG_TOUCHSCREEN_ATMEL_MXT=y
CONFIG_TOUCHSCREEN_ATMEL_MXT_T37=y
CONFIG_TOUCHSCREEN_AUO_PIXCIR=y
CONFIG_TOUCHSCREEN_BU21013=y
# CONFIG_TOUCHSCREEN_BU21029 is not set
CONFIG_TOUCHSCREEN_CHIPONE_ICN8318=y
CONFIG_TOUCHSCREEN_CHIPONE_ICN8505=y
# CONFIG_TOUCHSCREEN_CY8CTMG110 is not set
CONFIG_TOUCHSCREEN_CYTTSP_CORE=y
CONFIG_TOUCHSCREEN_CYTTSP_I2C=y
# CONFIG_TOUCHSCREEN_CYTTSP4_CORE is not set
# CONFIG_TOUCHSCREEN_DA9034 is not set
CONFIG_TOUCHSCREEN_DA9052=y
CONFIG_TOUCHSCREEN_DYNAPRO=y
CONFIG_TOUCHSCREEN_HAMPSHIRE=y
# CONFIG_TOUCHSCREEN_EETI is not set
CONFIG_TOUCHSCREEN_EGALAX=y
# CONFIG_TOUCHSCREEN_EGALAX_SERIAL is not set
# CONFIG_TOUCHSCREEN_EXC3000 is not set
CONFIG_TOUCHSCREEN_FUJITSU=y
# CONFIG_TOUCHSCREEN_GOODIX is not set
# CONFIG_TOUCHSCREEN_HIDEEP is not set
CONFIG_TOUCHSCREEN_ILI210X=y
CONFIG_TOUCHSCREEN_S6SY761=y
CONFIG_TOUCHSCREEN_GUNZE=y
# CONFIG_TOUCHSCREEN_EKTF2127 is not set
# CONFIG_TOUCHSCREEN_ELAN is not set
# CONFIG_TOUCHSCREEN_ELO is not set
# CONFIG_TOUCHSCREEN_WACOM_W8001 is not set
# CONFIG_TOUCHSCREEN_WACOM_I2C is not set
# CONFIG_TOUCHSCREEN_MAX11801 is not set
# CONFIG_TOUCHSCREEN_MCS5000 is not set
CONFIG_TOUCHSCREEN_MMS114=y
CONFIG_TOUCHSCREEN_MELFAS_MIP4=y
# CONFIG_TOUCHSCREEN_MTOUCH is not set
# CONFIG_TOUCHSCREEN_IMX6UL_TSC is not set
# CONFIG_TOUCHSCREEN_INEXIO is not set
CONFIG_TOUCHSCREEN_MK712=y
CONFIG_TOUCHSCREEN_PENMOUNT=y
CONFIG_TOUCHSCREEN_EDT_FT5X06=y
# CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
CONFIG_TOUCHSCREEN_TOUCHWIN=y
# CONFIG_TOUCHSCREEN_PIXCIR is not set
CONFIG_TOUCHSCREEN_WDT87XX_I2C=y
CONFIG_TOUCHSCREEN_USB_COMPOSITE=y
CONFIG_TOUCHSCREEN_USB_EGALAX=y
# CONFIG_TOUCHSCREEN_USB_PANJIT is not set
# CONFIG_TOUCHSCREEN_USB_3M is not set
# CONFIG_TOUCHSCREEN_USB_ITM is not set
# CONFIG_TOUCHSCREEN_USB_ETURBO is not set
CONFIG_TOUCHSCREEN_USB_GUNZE=y
# CONFIG_TOUCHSCREEN_USB_DMC_TSC10 is not set
# CONFIG_TOUCHSCREEN_USB_IRTOUCH is not set
CONFIG_TOUCHSCREEN_USB_IDEALTEK=y
CONFIG_TOUCHSCREEN_USB_GENERAL_TOUCH=y
CONFIG_TOUCHSCREEN_USB_GOTOP=y
# CONFIG_TOUCHSCREEN_USB_JASTEC is not set
CONFIG_TOUCHSCREEN_USB_ELO=y
CONFIG_TOUCHSCREEN_USB_E2I=y
# CONFIG_TOUCHSCREEN_USB_ZYTRONIC is not set
CONFIG_TOUCHSCREEN_USB_ETT_TC45USB=y
# CONFIG_TOUCHSCREEN_USB_NEXIO is not set
# CONFIG_TOUCHSCREEN_USB_EASYTOUCH is not set
CONFIG_TOUCHSCREEN_TOUCHIT213=y
CONFIG_TOUCHSCREEN_TSC_SERIO=y
CONFIG_TOUCHSCREEN_TSC200X_CORE=y
CONFIG_TOUCHSCREEN_TSC2004=y
# CONFIG_TOUCHSCREEN_TSC2007 is not set
CONFIG_TOUCHSCREEN_RM_TS=y
CONFIG_TOUCHSCREEN_SILEAD=y
CONFIG_TOUCHSCREEN_SIS_I2C=y
CONFIG_TOUCHSCREEN_ST1232=y
CONFIG_TOUCHSCREEN_STMFTS=y
CONFIG_TOUCHSCREEN_SUR40=y
# CONFIG_TOUCHSCREEN_SX8654 is not set
# CONFIG_TOUCHSCREEN_TPS6507X is not set
# CONFIG_TOUCHSCREEN_ZET6223 is not set
# CONFIG_TOUCHSCREEN_ZFORCE is not set
# CONFIG_TOUCHSCREEN_COLIBRI_VF50 is not set
CONFIG_TOUCHSCREEN_ROHM_BU21023=y
# CONFIG_TOUCHSCREEN_IQS5XX is not set
# CONFIG_INPUT_MISC is not set
CONFIG_RMI4_CORE=y
CONFIG_RMI4_I2C=y
CONFIG_RMI4_SMB=y
CONFIG_RMI4_F03=y
CONFIG_RMI4_F03_SERIO=y
CONFIG_RMI4_2D_SENSOR=y
CONFIG_RMI4_F11=y
CONFIG_RMI4_F12=y
CONFIG_RMI4_F30=y
# CONFIG_RMI4_F34 is not set
CONFIG_RMI4_F54=y
CONFIG_RMI4_F55=y

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
CONFIG_SERIO_CT82C710=y
CONFIG_SERIO_PARKBD=y
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_SERIO_PS2MULT=y
# CONFIG_SERIO_ARC_PS2 is not set
CONFIG_SERIO_APBPS2=y
CONFIG_HYPERV_KEYBOARD=y
CONFIG_SERIO_GPIO_PS2=y
# CONFIG_USERIO is not set
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
CONFIG_GAMEPORT_L4=y
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set
# end of Hardware I/O ports
# end of Input device support

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_ROCKETPORT is not set
# CONFIG_CYCLADES is not set
# CONFIG_MOXA_INTELLIO is not set
# CONFIG_MOXA_SMARTIO is not set
# CONFIG_SYNCLINK is not set
# CONFIG_SYNCLINKMP is not set
# CONFIG_SYNCLINK_GT is not set
# CONFIG_NOZOMI is not set
# CONFIG_ISI is not set
CONFIG_N_HDLC=y
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
CONFIG_NULL_TTY=y
# CONFIG_LDISC_AUTOLOAD is not set
# CONFIG_DEVMEM is not set
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_EXAR=y
# CONFIG_SERIAL_8250_CS is not set
CONFIG_SERIAL_8250_MEN_MCB=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
CONFIG_SERIAL_8250_ASPEED_VUART=y
CONFIG_SERIAL_8250_DW=y
# CONFIG_SERIAL_8250_RT288X is not set
CONFIG_SERIAL_8250_LPSS=y
CONFIG_SERIAL_8250_MID=y
# CONFIG_SERIAL_8250_MOXA is not set
CONFIG_SERIAL_OF_PLATFORM=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_UARTLITE=y
# CONFIG_SERIAL_UARTLITE_CONSOLE is not set
CONFIG_SERIAL_UARTLITE_NR_UARTS=1
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_SIFIVE=y
CONFIG_SERIAL_SIFIVE_CONSOLE=y
# CONFIG_SERIAL_SCCNXP is not set
CONFIG_SERIAL_SC16IS7XX=y
# CONFIG_SERIAL_SC16IS7XX_I2C is not set
CONFIG_SERIAL_ALTERA_JTAGUART=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE_BYPASS=y
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_XILINX_PS_UART is not set
CONFIG_SERIAL_ARC=y
CONFIG_SERIAL_ARC_CONSOLE=y
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
CONFIG_SERIAL_CONEXANT_DIGICOLOR=y
CONFIG_SERIAL_CONEXANT_DIGICOLOR_CONSOLE=y
CONFIG_SERIAL_MEN_Z135=y
# end of Serial drivers

CONFIG_SERIAL_MCTRL_GPIO=y
# CONFIG_SERIAL_DEV_BUS is not set
CONFIG_TTY_PRINTK=y
CONFIG_TTY_PRINTK_LEVEL=6
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=y
CONFIG_HVC_DRIVER=y
CONFIG_HVC_IRQ=y
CONFIG_HVC_XEN=y
CONFIG_HVC_XEN_FRONTEND=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=y
CONFIG_IPMI_PLAT_DATA=y
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
# CONFIG_IPMI_SSIF is not set
CONFIG_IPMI_WATCHDOG=y
CONFIG_IPMI_POWEROFF=y
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_NVRAM=y
# CONFIG_APPLICOM is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
CONFIG_CARDMAN_4000=y
# CONFIG_CARDMAN_4040 is not set
CONFIG_SCR24X=y
# CONFIG_IPWIRELESS is not set
# end of PCMCIA character devices

CONFIG_MWAVE=y
CONFIG_HPET=y
# CONFIG_HPET_MMAP is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
# CONFIG_HW_RANDOM_TPM is not set
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
# CONFIG_TCG_TIS_I2C_ATMEL is not set
# CONFIG_TCG_TIS_I2C_INFINEON is not set
# CONFIG_TCG_TIS_I2C_NUVOTON is not set
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
CONFIG_TCG_INFINEON=y
CONFIG_TCG_XEN=y
CONFIG_TCG_CRB=y
# CONFIG_TCG_VTPM_PROXY is not set
CONFIG_TCG_TIS_ST33ZP24=y
CONFIG_TCG_TIS_ST33ZP24_I2C=y
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
CONFIG_XILLYBUS=y
CONFIG_XILLYBUS_OF=y
# end of Character devices

# CONFIG_RANDOM_TRUST_CPU is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
# CONFIG_I2C_CHARDEV is not set
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_ARB_GPIO_CHALLENGE=y
# CONFIG_I2C_MUX_GPIO is not set
CONFIG_I2C_MUX_GPMUX=y
CONFIG_I2C_MUX_LTC4306=y
# CONFIG_I2C_MUX_PCA9541 is not set
# CONFIG_I2C_MUX_PCA954x is not set
# CONFIG_I2C_MUX_PINCTRL is not set
CONFIG_I2C_MUX_REG=y
CONFIG_I2C_DEMUX_PINCTRL=y
CONFIG_I2C_MUX_MLXCPLD=y
# end of Multiplexer I2C Chip support

# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=y

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
# CONFIG_I2C_ALGOPCF is not set
CONFIG_I2C_ALGOPCA=y
# end of I2C Algorithms

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_AMD_MP2 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_NVIDIA_GPU is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
CONFIG_I2C_SCMI=y

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
# CONFIG_I2C_DESIGNWARE_SLAVE is not set
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EMEV2 is not set
CONFIG_I2C_GPIO=y
# CONFIG_I2C_GPIO_FAULT_INJECTOR is not set
CONFIG_I2C_KEMPLD=y
CONFIG_I2C_OCORES=y
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_RK3X is not set
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
CONFIG_I2C_PARPORT=y
# CONFIG_I2C_PARPORT_LIGHT is not set
CONFIG_I2C_ROBOTFUZZ_OSIF=y
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=y
# CONFIG_I2C_VIPERBOARD is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_MLXCPLD is not set
CONFIG_I2C_CROS_EC_TUNNEL=y
# CONFIG_I2C_FSI is not set
# end of I2C Hardware Bus support

# CONFIG_I2C_STUB is not set
# CONFIG_I2C_SLAVE is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# end of I2C support

CONFIG_I3C=y
CONFIG_CDNS_I3C_MASTER=y
# CONFIG_DW_I3C_MASTER is not set
# CONFIG_SPI is not set
# CONFIG_SPMI is not set
# CONFIG_HSI is not set
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
CONFIG_PPS_CLIENT_LDISC=y
CONFIG_PPS_CLIENT_PARPORT=y
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
# end of PTP clock support

CONFIG_PINCTRL=y
CONFIG_GENERIC_PINCTRL_GROUPS=y
CONFIG_PINMUX=y
CONFIG_GENERIC_PINMUX_FUNCTIONS=y
CONFIG_PINCONF=y
CONFIG_GENERIC_PINCONF=y
CONFIG_DEBUG_PINCTRL=y
CONFIG_PINCTRL_AXP209=y
CONFIG_PINCTRL_AMD=y
CONFIG_PINCTRL_MCP23S08=y
CONFIG_PINCTRL_SINGLE=y
CONFIG_PINCTRL_SX150X=y
CONFIG_PINCTRL_STMFX=y
CONFIG_PINCTRL_OCELOT=y
# CONFIG_PINCTRL_BAYTRAIL is not set
# CONFIG_PINCTRL_CHERRYVIEW is not set
CONFIG_PINCTRL_INTEL=y
CONFIG_PINCTRL_BROXTON=y
CONFIG_PINCTRL_CANNONLAKE=y
CONFIG_PINCTRL_CEDARFORK=y
CONFIG_PINCTRL_DENVERTON=y
CONFIG_PINCTRL_GEMINILAKE=y
CONFIG_PINCTRL_ICELAKE=y
CONFIG_PINCTRL_LEWISBURG=y
# CONFIG_PINCTRL_SUNRISEPOINT is not set
CONFIG_PINCTRL_LOCHNAGAR=y
CONFIG_PINCTRL_MADERA=y
CONFIG_PINCTRL_CS47L35=y
CONFIG_PINCTRL_CS47L90=y
CONFIG_GPIOLIB=y
CONFIG_GPIOLIB_FASTPATH_LIMIT=512
CONFIG_OF_GPIO=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
CONFIG_DEBUG_GPIO=y
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
# CONFIG_GPIO_74XX_MMIO is not set
CONFIG_GPIO_ALTERA=y
CONFIG_GPIO_AMDPT=y
CONFIG_GPIO_CADENCE=y
CONFIG_GPIO_DWAPB=y
# CONFIG_GPIO_EXAR is not set
CONFIG_GPIO_FTGPIO010=y
CONFIG_GPIO_GENERIC_PLATFORM=y
CONFIG_GPIO_GRGPIO=y
CONFIG_GPIO_HLWD=y
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_LYNXPOINT is not set
CONFIG_GPIO_MB86S7X=y
CONFIG_GPIO_MENZ127=y
CONFIG_GPIO_SAMA5D2_PIOBU=y
CONFIG_GPIO_SYSCON=y
# CONFIG_GPIO_VX855 is not set
CONFIG_GPIO_XILINX=y
CONFIG_GPIO_AMD_FCH=y
# end of Memory mapped GPIO drivers

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_F7188X=y
# CONFIG_GPIO_IT87 is not set
# CONFIG_GPIO_SCH is not set
CONFIG_GPIO_SCH311X=y
CONFIG_GPIO_WINBOND=y
CONFIG_GPIO_WS16C48=y
# end of Port-mapped I/O GPIO drivers

#
# I2C GPIO expanders
#
# CONFIG_GPIO_ADP5588 is not set
CONFIG_GPIO_ADNP=y
CONFIG_GPIO_GW_PLD=y
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
CONFIG_GPIO_MAX732X_IRQ=y
CONFIG_GPIO_PCA953X=y
CONFIG_GPIO_PCA953X_IRQ=y
# CONFIG_GPIO_PCF857X is not set
CONFIG_GPIO_TPIC2810=y
# end of I2C GPIO expanders

#
# MFD GPIO expanders
#
CONFIG_GPIO_ARIZONA=y
# CONFIG_GPIO_BD70528 is not set
CONFIG_GPIO_BD9571MWV=y
# CONFIG_GPIO_DA9052 is not set
CONFIG_GPIO_DA9055=y
# CONFIG_GPIO_KEMPLD is not set
CONFIG_GPIO_LP873X=y
CONFIG_GPIO_MADERA=y
CONFIG_GPIO_MAX77650=y
# CONFIG_GPIO_TPS65910 is not set
CONFIG_GPIO_TPS65912=y
CONFIG_GPIO_TWL4030=y
CONFIG_GPIO_WM8350=y
# CONFIG_GPIO_WM8994 is not set
# end of MFD GPIO expanders

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_PCI_IDIO_16 is not set
# CONFIG_GPIO_PCIE_IDIO_24 is not set
# CONFIG_GPIO_RDC321X is not set
# CONFIG_GPIO_SODAVILLE is not set
# end of PCI GPIO expanders

#
# USB GPIO expanders
#
# CONFIG_GPIO_VIPERBOARD is not set
# end of USB GPIO expanders

CONFIG_GPIO_MOCKUP=y
CONFIG_W1=y
# CONFIG_W1_CON is not set

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2490=y
# CONFIG_W1_MASTER_DS2482 is not set
CONFIG_W1_MASTER_DS1WM=y
# CONFIG_W1_MASTER_GPIO is not set
# end of 1-wire Bus Masters

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
CONFIG_W1_SLAVE_DS2405=y
CONFIG_W1_SLAVE_DS2408=y
# CONFIG_W1_SLAVE_DS2408_READBACK is not set
CONFIG_W1_SLAVE_DS2413=y
CONFIG_W1_SLAVE_DS2406=y
CONFIG_W1_SLAVE_DS2423=y
# CONFIG_W1_SLAVE_DS2805 is not set
# CONFIG_W1_SLAVE_DS2431 is not set
CONFIG_W1_SLAVE_DS2433=y
CONFIG_W1_SLAVE_DS2433_CRC=y
CONFIG_W1_SLAVE_DS2438=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_DS28E17=y
# end of 1-wire Slaves

CONFIG_POWER_AVS=y
# CONFIG_POWER_RESET is not set
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
CONFIG_POWER_SUPPLY_HWMON=y
CONFIG_PDA_POWER=y
# CONFIG_GENERIC_ADC_BATTERY is not set
# CONFIG_WM8350_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_88PM860X is not set
CONFIG_CHARGER_ADP5061=y
CONFIG_BATTERY_ACT8945A=y
CONFIG_BATTERY_DS2760=y
CONFIG_BATTERY_DS2780=y
# CONFIG_BATTERY_DS2781 is not set
CONFIG_BATTERY_DS2782=y
# CONFIG_BATTERY_LEGO_EV3 is not set
CONFIG_BATTERY_SBS=y
CONFIG_CHARGER_SBS=y
CONFIG_MANAGER_SBS=y
# CONFIG_BATTERY_BQ27XXX is not set
CONFIG_BATTERY_DA9030=y
CONFIG_BATTERY_DA9052=y
CONFIG_BATTERY_DA9150=y
# CONFIG_CHARGER_AXP20X is not set
CONFIG_BATTERY_AXP20X=y
# CONFIG_AXP20X_POWER is not set
# CONFIG_AXP288_CHARGER is not set
CONFIG_AXP288_FUEL_GAUGE=y
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
CONFIG_BATTERY_MAX1721X=y
CONFIG_BATTERY_TWL4030_MADC=y
CONFIG_CHARGER_PCF50633=y
CONFIG_BATTERY_RX51=y
# CONFIG_CHARGER_ISP1704 is not set
CONFIG_CHARGER_MAX8903=y
CONFIG_CHARGER_TWL4030=y
CONFIG_CHARGER_LP8727=y
CONFIG_CHARGER_GPIO=y
CONFIG_CHARGER_MANAGER=y
# CONFIG_CHARGER_LT3651 is not set
CONFIG_CHARGER_MAX14577=y
CONFIG_CHARGER_DETECTOR_MAX14656=y
CONFIG_CHARGER_MAX77650=y
# CONFIG_CHARGER_MAX77693 is not set
# CONFIG_CHARGER_BQ2415X is not set
CONFIG_CHARGER_BQ24190=y
CONFIG_CHARGER_BQ24257=y
CONFIG_CHARGER_BQ24735=y
CONFIG_CHARGER_BQ25890=y
CONFIG_CHARGER_SMB347=y
# CONFIG_CHARGER_TPS65090 is not set
CONFIG_CHARGER_TPS65217=y
CONFIG_BATTERY_GAUGE_LTC2941=y
CONFIG_CHARGER_RT9455=y
CONFIG_CHARGER_CROS_USBPD=y
# CONFIG_CHARGER_UCS1002 is not set
CONFIG_CHARGER_BD70528=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7410=y
# CONFIG_SENSORS_ADT7411 is not set
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_APPLESMC is not set
CONFIG_SENSORS_ASB100=y
# CONFIG_SENSORS_ASPEED is not set
CONFIG_SENSORS_ATXP1=y
CONFIG_SENSORS_DS620=y
# CONFIG_SENSORS_DS1621 is not set
CONFIG_SENSORS_DELL_SMM=y
CONFIG_SENSORS_DA9052_ADC=y
CONFIG_SENSORS_DA9055=y
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_FSCHMD is not set
CONFIG_SENSORS_FTSTEUTATES=y
CONFIG_SENSORS_GL518SM=y
# CONFIG_SENSORS_GL520SM is not set
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_G762=y
CONFIG_SENSORS_GPIO_FAN=y
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_IBMAEM=y
CONFIG_SENSORS_IBMPEX=y
CONFIG_SENSORS_IIO_HWMON=y
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IT87=y
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_POWR1220=y
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LOCHNAGAR=y
# CONFIG_SENSORS_LTC2945 is not set
# CONFIG_SENSORS_LTC2990 is not set
# CONFIG_SENSORS_LTC4151 is not set
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4222=y
CONFIG_SENSORS_LTC4245=y
CONFIG_SENSORS_LTC4260=y
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_MAX16065=y
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX1668 is not set
CONFIG_SENSORS_MAX197=y
# CONFIG_SENSORS_MAX6621 is not set
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=y
# CONFIG_SENSORS_MAX6697 is not set
# CONFIG_SENSORS_MAX31790 is not set
CONFIG_SENSORS_MCP3021=y
CONFIG_SENSORS_MLXREG_FAN=y
CONFIG_SENSORS_TC654=y
CONFIG_SENSORS_MENF21BMC_HWMON=y
CONFIG_SENSORS_LM63=y
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=y
# CONFIG_SENSORS_LM78 is not set
# CONFIG_SENSORS_LM80 is not set
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
# CONFIG_SENSORS_LM87 is not set
CONFIG_SENSORS_LM90=y
# CONFIG_SENSORS_LM92 is not set
CONFIG_SENSORS_LM93=y
# CONFIG_SENSORS_LM95234 is not set
# CONFIG_SENSORS_LM95241 is not set
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_PC87360=y
# CONFIG_SENSORS_PC87427 is not set
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_NCT6683=y
CONFIG_SENSORS_NCT6775=y
# CONFIG_SENSORS_NCT7802 is not set
# CONFIG_SENSORS_NCT7904 is not set
CONFIG_SENSORS_NPCM7XX=y
# CONFIG_SENSORS_PCF8591 is not set
CONFIG_PMBUS=y
CONFIG_SENSORS_PMBUS=y
CONFIG_SENSORS_ADM1275=y
CONFIG_SENSORS_IBM_CFFPS=y
CONFIG_SENSORS_IR35221=y
# CONFIG_SENSORS_IR38064 is not set
# CONFIG_SENSORS_IRPS5401 is not set
CONFIG_SENSORS_ISL68137=y
# CONFIG_SENSORS_LM25066 is not set
CONFIG_SENSORS_LTC2978=y
# CONFIG_SENSORS_LTC2978_REGULATOR is not set
CONFIG_SENSORS_LTC3815=y
CONFIG_SENSORS_MAX16064=y
CONFIG_SENSORS_MAX20751=y
CONFIG_SENSORS_MAX31785=y
CONFIG_SENSORS_MAX34440=y
CONFIG_SENSORS_MAX8688=y
CONFIG_SENSORS_PXE1610=y
# CONFIG_SENSORS_TPS40422 is not set
# CONFIG_SENSORS_TPS53679 is not set
# CONFIG_SENSORS_UCD9000 is not set
CONFIG_SENSORS_UCD9200=y
# CONFIG_SENSORS_ZL6100 is not set
CONFIG_SENSORS_PWM_FAN=y
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=y
# CONFIG_SENSORS_SHT3x is not set
CONFIG_SENSORS_SHTC1=y
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
# CONFIG_SENSORS_EMC6W201 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
CONFIG_SENSORS_SMSC47M192=y
# CONFIG_SENSORS_SMSC47B397 is not set
CONFIG_SENSORS_SCH56XX_COMMON=y
CONFIG_SENSORS_SCH5627=y
# CONFIG_SENSORS_SCH5636 is not set
# CONFIG_SENSORS_STTS751 is not set
CONFIG_SENSORS_SMM665=y
# CONFIG_SENSORS_ADC128D818 is not set
# CONFIG_SENSORS_ADS1015 is not set
# CONFIG_SENSORS_ADS7828 is not set
CONFIG_SENSORS_AMC6821=y
# CONFIG_SENSORS_INA209 is not set
CONFIG_SENSORS_INA2XX=y
# CONFIG_SENSORS_INA3221 is not set
CONFIG_SENSORS_TC74=y
# CONFIG_SENSORS_THMC50 is not set
CONFIG_SENSORS_TMP102=y
# CONFIG_SENSORS_TMP103 is not set
CONFIG_SENSORS_TMP108=y
CONFIG_SENSORS_TMP401=y
# CONFIG_SENSORS_TMP421 is not set
CONFIG_SENSORS_VIA_CPUTEMP=y
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83773G=y
# CONFIG_SENSORS_W83781D is not set
CONFIG_SENSORS_W83791D=y
# CONFIG_SENSORS_W83792D is not set
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=y
# CONFIG_SENSORS_W83L786NG is not set
CONFIG_SENSORS_W83627HF=y
# CONFIG_SENSORS_W83627EHF is not set
CONFIG_SENSORS_WM8350=y
# CONFIG_SENSORS_XGENE is not set

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=y
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_STATISTICS is not set
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_OF=y
CONFIG_THERMAL_WRITABLE_TRIPS=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_BANG_BANG is not set
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_THERMAL_MMIO is not set
# CONFIG_QORIQ_THERMAL is not set
CONFIG_DA9062_THERMAL=y

#
# Intel thermal drivers
#
# CONFIG_INTEL_POWERCLAMP is not set
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
# end of ACPI INT340X thermal drivers

# CONFIG_INTEL_PCH_THERMAL is not set
# end of Intel thermal drivers

CONFIG_GENERIC_ADC_THERMAL=y
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set
# CONFIG_WATCHDOG_HANDLE_BOOT_ENABLED is not set
CONFIG_WATCHDOG_SYSFS=y

#
# Watchdog Pretimeout Governors
#
CONFIG_WATCHDOG_PRETIMEOUT_GOV=y
CONFIG_WATCHDOG_PRETIMEOUT_GOV_SEL=m
CONFIG_WATCHDOG_PRETIMEOUT_GOV_NOOP=y
CONFIG_WATCHDOG_PRETIMEOUT_GOV_PANIC=y
CONFIG_WATCHDOG_PRETIMEOUT_DEFAULT_GOV_NOOP=y
# CONFIG_WATCHDOG_PRETIMEOUT_DEFAULT_GOV_PANIC is not set

#
# Watchdog Device Drivers
#
# CONFIG_SOFT_WATCHDOG is not set
CONFIG_BD70528_WATCHDOG=y
# CONFIG_DA9052_WATCHDOG is not set
# CONFIG_DA9055_WATCHDOG is not set
# CONFIG_DA9063_WATCHDOG is not set
CONFIG_DA9062_WATCHDOG=y
# CONFIG_GPIO_WATCHDOG is not set
CONFIG_MENF21BMC_WATCHDOG=y
CONFIG_MENZ069_WATCHDOG=y
CONFIG_WDAT_WDT=y
# CONFIG_WM8350_WATCHDOG is not set
# CONFIG_XILINX_WATCHDOG is not set
CONFIG_ZIIRAVE_WATCHDOG=y
CONFIG_MLX_WDT=y
CONFIG_CADENCE_WATCHDOG=y
# CONFIG_DW_WATCHDOG is not set
CONFIG_RN5T618_WATCHDOG=y
CONFIG_TWL4030_WATCHDOG=y
CONFIG_MAX63XX_WATCHDOG=y
CONFIG_RETU_WATCHDOG=y
# CONFIG_STPMIC1_WATCHDOG is not set
# CONFIG_ACQUIRE_WDT is not set
CONFIG_ADVANTECH_WDT=y
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
CONFIG_EBC_C384_WDT=y
# CONFIG_F71808E_WDT is not set
# CONFIG_SP5100_TCO is not set
# CONFIG_SBC_FITPC2_WATCHDOG is not set
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
CONFIG_IBMASR=y
# CONFIG_WAFER_WDT is not set
# CONFIG_I6300ESB_WDT is not set
# CONFIG_IE6XX_WDT is not set
# CONFIG_ITCO_WDT is not set
# CONFIG_IT8712F_WDT is not set
CONFIG_IT87_WDT=y
# CONFIG_HP_WATCHDOG is not set
# CONFIG_KEMPLD_WDT is not set
CONFIG_SC1200_WDT=y
# CONFIG_PC87413_WDT is not set
# CONFIG_NV_TCO is not set
CONFIG_60XX_WDT=y
CONFIG_CPU5_WDT=y
CONFIG_SMSC_SCH311X_WDT=y
CONFIG_SMSC37B787_WDT=y
CONFIG_TQMX86_WDT=y
# CONFIG_VIA_WDT is not set
# CONFIG_W83627HF_WDT is not set
# CONFIG_W83877F_WDT is not set
CONFIG_W83977F_WDT=y
CONFIG_MACHZ_WDT=y
# CONFIG_SBC_EPX_C3_WATCHDOG is not set
CONFIG_NI903X_WDT=y
CONFIG_NIC7018_WDT=y
CONFIG_MEN_A21_WDT=y
CONFIG_XEN_WDT=y

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=y
CONFIG_SSB_POSSIBLE=y
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
CONFIG_SSB_PCMCIAHOST=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
CONFIG_SSB_DRIVER_GPIO=y
CONFIG_BCMA_POSSIBLE=y
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
# CONFIG_BCMA_HOST_SOC is not set
CONFIG_BCMA_DRIVER_PCI=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
# CONFIG_BCMA_DRIVER_GPIO is not set
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_ACT8945A=y
# CONFIG_MFD_AS3711 is not set
# CONFIG_MFD_AS3722 is not set
# CONFIG_PMIC_ADP5520 is not set
CONFIG_MFD_AAT2870_CORE=y
CONFIG_MFD_ATMEL_FLEXCOM=y
# CONFIG_MFD_ATMEL_HLCDC is not set
CONFIG_MFD_BCM590XX=y
CONFIG_MFD_BD9571MWV=y
CONFIG_MFD_AXP20X=y
CONFIG_MFD_AXP20X_I2C=y
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_CHARDEV=y
CONFIG_MFD_MADERA=y
CONFIG_MFD_MADERA_I2C=y
# CONFIG_MFD_CS47L15 is not set
CONFIG_MFD_CS47L35=y
# CONFIG_MFD_CS47L85 is not set
CONFIG_MFD_CS47L90=y
CONFIG_MFD_CS47L92=y
CONFIG_PMIC_DA903X=y
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_I2C=y
CONFIG_MFD_DA9055=y
CONFIG_MFD_DA9062=y
CONFIG_MFD_DA9063=y
CONFIG_MFD_DA9150=y
# CONFIG_MFD_DLN2 is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_MFD_HI6421_PMIC is not set
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
# CONFIG_MFD_INTEL_QUARK_I2C_GPIO is not set
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
# CONFIG_INTEL_SOC_PMIC is not set
# CONFIG_INTEL_SOC_PMIC_CHTWC is not set
CONFIG_INTEL_SOC_PMIC_CHTDC_TI=y
CONFIG_MFD_INTEL_LPSS=y
CONFIG_MFD_INTEL_LPSS_ACPI=y
# CONFIG_MFD_INTEL_LPSS_PCI is not set
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
CONFIG_MFD_MAX14577=y
# CONFIG_MFD_MAX77620 is not set
CONFIG_MFD_MAX77650=y
CONFIG_MFD_MAX77686=y
CONFIG_MFD_MAX77693=y
# CONFIG_MFD_MAX77843 is not set
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
CONFIG_MFD_MT6397=y
CONFIG_MFD_MENF21BMC=y
CONFIG_MFD_VIPERBOARD=y
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
# CONFIG_PCF50633_ADC is not set
CONFIG_PCF50633_GPIO=y
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RT5033 is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_RK808 is not set
CONFIG_MFD_RN5T618=y
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=y
# CONFIG_MFD_SM501 is not set
CONFIG_MFD_SKY81452=y
CONFIG_MFD_SMSC=y
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_STMPE is not set
CONFIG_MFD_SYSCON=y
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_MFD_LP3943 is not set
CONFIG_MFD_LP8788=y
# CONFIG_MFD_TI_LMU is not set
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
# CONFIG_MFD_TPS65086 is not set
CONFIG_MFD_TPS65090=y
CONFIG_MFD_TPS65217=y
# CONFIG_MFD_TPS68470 is not set
CONFIG_MFD_TI_LP873X=y
# CONFIG_MFD_TI_LP87565 is not set
# CONFIG_MFD_TPS65218 is not set
# CONFIG_MFD_TPS6586X is not set
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
CONFIG_MFD_TPS80031=y
CONFIG_TWL4030_CORE=y
CONFIG_MFD_TWL4030_AUDIO=y
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TQMX86 is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_LOCHNAGAR=y
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_CS47L24=y
# CONFIG_MFD_WM5102 is not set
CONFIG_MFD_WM5110=y
CONFIG_MFD_WM8997=y
CONFIG_MFD_WM8998=y
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
CONFIG_MFD_WM8994=y
CONFIG_MFD_ROHM_BD718XX=y
CONFIG_MFD_ROHM_BD70528=y
CONFIG_MFD_STPMIC1=y
CONFIG_MFD_STMFX=y
# end of Multifunction device drivers

CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
CONFIG_REGULATOR_88PG86X=y
CONFIG_REGULATOR_88PM800=y
CONFIG_REGULATOR_88PM8607=y
CONFIG_REGULATOR_ACT8865=y
CONFIG_REGULATOR_ACT8945A=y
# CONFIG_REGULATOR_AD5398 is not set
# CONFIG_REGULATOR_ANATOP is not set
# CONFIG_REGULATOR_AAT2870 is not set
CONFIG_REGULATOR_AXP20X=y
# CONFIG_REGULATOR_BCM590XX is not set
CONFIG_REGULATOR_BD70528=y
CONFIG_REGULATOR_BD718XX=y
# CONFIG_REGULATOR_BD9571MWV is not set
CONFIG_REGULATOR_DA903X=y
CONFIG_REGULATOR_DA9052=y
CONFIG_REGULATOR_DA9055=y
# CONFIG_REGULATOR_DA9062 is not set
CONFIG_REGULATOR_DA9063=y
CONFIG_REGULATOR_DA9210=y
# CONFIG_REGULATOR_DA9211 is not set
CONFIG_REGULATOR_FAN53555=y
# CONFIG_REGULATOR_GPIO is not set
CONFIG_REGULATOR_ISL9305=y
CONFIG_REGULATOR_ISL6271A=y
CONFIG_REGULATOR_LOCHNAGAR=y
CONFIG_REGULATOR_LP3971=y
# CONFIG_REGULATOR_LP3972 is not set
CONFIG_REGULATOR_LP872X=y
# CONFIG_REGULATOR_LP873X is not set
CONFIG_REGULATOR_LP8755=y
# CONFIG_REGULATOR_LP8788 is not set
# CONFIG_REGULATOR_LTC3589 is not set
CONFIG_REGULATOR_LTC3676=y
# CONFIG_REGULATOR_MAX14577 is not set
CONFIG_REGULATOR_MAX1586=y
# CONFIG_REGULATOR_MAX77650 is not set
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8952=y
# CONFIG_REGULATOR_MAX8973 is not set
CONFIG_REGULATOR_MAX77686=y
# CONFIG_REGULATOR_MAX77693 is not set
CONFIG_REGULATOR_MAX77802=y
CONFIG_REGULATOR_MCP16502=y
CONFIG_REGULATOR_MT6311=y
CONFIG_REGULATOR_MT6323=y
# CONFIG_REGULATOR_MT6397 is not set
CONFIG_REGULATOR_PCF50633=y
CONFIG_REGULATOR_PFUZE100=y
# CONFIG_REGULATOR_PV88060 is not set
# CONFIG_REGULATOR_PV88080 is not set
CONFIG_REGULATOR_PV88090=y
# CONFIG_REGULATOR_PWM is not set
CONFIG_REGULATOR_RN5T618=y
CONFIG_REGULATOR_S2MPA01=y
CONFIG_REGULATOR_S2MPS11=y
# CONFIG_REGULATOR_S5M8767 is not set
CONFIG_REGULATOR_SKY81452=y
# CONFIG_REGULATOR_SLG51000 is not set
CONFIG_REGULATOR_STPMIC1=y
CONFIG_REGULATOR_SY8106A=y
CONFIG_REGULATOR_TPS51632=y
# CONFIG_REGULATOR_TPS6105X is not set
CONFIG_REGULATOR_TPS62360=y
# CONFIG_REGULATOR_TPS65023 is not set
CONFIG_REGULATOR_TPS6507X=y
# CONFIG_REGULATOR_TPS65090 is not set
CONFIG_REGULATOR_TPS65132=y
CONFIG_REGULATOR_TPS65217=y
# CONFIG_REGULATOR_TPS65910 is not set
CONFIG_REGULATOR_TPS65912=y
CONFIG_REGULATOR_TPS80031=y
CONFIG_REGULATOR_TWL4030=y
CONFIG_REGULATOR_VCTRL=y
# CONFIG_REGULATOR_WM8350 is not set
CONFIG_REGULATOR_WM8994=y
CONFIG_CEC_CORE=y
CONFIG_CEC_NOTIFIER=y
CONFIG_RC_CORE=y
CONFIG_RC_MAP=y
CONFIG_LIRC=y
# CONFIG_BPF_LIRC_MODE2 is not set
# CONFIG_RC_DECODERS is not set
CONFIG_RC_DEVICES=y
# CONFIG_RC_ATI_REMOTE is not set
CONFIG_IR_ENE=y
CONFIG_IR_HIX5HD2=y
# CONFIG_IR_IMON is not set
CONFIG_IR_IMON_RAW=y
CONFIG_IR_MCEUSB=y
CONFIG_IR_ITE_CIR=y
CONFIG_IR_FINTEK=y
CONFIG_IR_NUVOTON=y
CONFIG_IR_REDRAT3=y
CONFIG_IR_STREAMZAP=y
# CONFIG_IR_WINBOND_CIR is not set
CONFIG_IR_IGORPLUGUSB=y
# CONFIG_IR_IGUANA is not set
# CONFIG_IR_TTUSBIR is not set
# CONFIG_RC_LOOPBACK is not set
CONFIG_IR_GPIO_CIR=y
# CONFIG_IR_GPIO_TX is not set
CONFIG_IR_PWM_TX=y
CONFIG_IR_SERIAL=y
CONFIG_IR_SERIAL_TRANSMITTER=y
CONFIG_IR_SIR=y
CONFIG_RC_XBOX_DVD=y
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
# CONFIG_MEDIA_CAMERA_SUPPORT is not set
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
# CONFIG_MEDIA_DIGITAL_TV_SUPPORT is not set
CONFIG_MEDIA_RADIO_SUPPORT=y
CONFIG_MEDIA_SDR_SUPPORT=y
# CONFIG_MEDIA_CEC_SUPPORT is not set
CONFIG_MEDIA_CEC_RC=y
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_VIDEO_TUNER=y
CONFIG_V4L2_FWNODE=y
CONFIG_VIDEOBUF_GEN=y
CONFIG_VIDEOBUF_VMALLOC=y

#
# Media drivers
#
CONFIG_MEDIA_USB_SUPPORT=y

#
# Analog TV USB devices
#
CONFIG_VIDEO_PVRUSB2=y
# CONFIG_VIDEO_PVRUSB2_SYSFS is not set
CONFIG_VIDEO_HDPVR=y
CONFIG_VIDEO_USBVISION=y
CONFIG_VIDEO_STK1160_COMMON=y
CONFIG_VIDEO_STK1160=y

#
# Analog/digital TV USB devices
#
CONFIG_VIDEO_CX231XX=y
CONFIG_VIDEO_CX231XX_RC=y
CONFIG_VIDEO_TM6000=y

#
# Webcam, TV (analog/digital) USB devices
#
# CONFIG_VIDEO_EM28XX is not set

#
# Software defined radio USB devices
#
CONFIG_USB_AIRSPY=y
# CONFIG_USB_HACKRF is not set
# CONFIG_MEDIA_PCI_SUPPORT is not set
CONFIG_SDR_PLATFORM_DRIVERS=y

#
# Supported MMC/SDIO adapters
#
# CONFIG_RADIO_ADAPTERS is not set
CONFIG_VIDEO_CX2341X=y
CONFIG_VIDEO_TVEEPROM=y
# CONFIG_CYPRESS_FIRMWARE is not set
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_V4L2=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_VMALLOC=y
CONFIG_VIDEOBUF2_DMA_SG=y

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y
CONFIG_MEDIA_ATTACH=y
# CONFIG_VIDEO_IR_I2C is not set

#
# I2C Encoders, decoders, sensors and other helper chips
#

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TVAUDIO=y
CONFIG_VIDEO_TDA7432=y
CONFIG_VIDEO_TDA9840=y
# CONFIG_VIDEO_TEA6415C is not set
# CONFIG_VIDEO_TEA6420 is not set
CONFIG_VIDEO_MSP3400=y
# CONFIG_VIDEO_CS3308 is not set
CONFIG_VIDEO_CS5345=y
CONFIG_VIDEO_CS53L32A=y
# CONFIG_VIDEO_TLV320AIC23B is not set
CONFIG_VIDEO_UDA1342=y
CONFIG_VIDEO_WM8775=y
CONFIG_VIDEO_WM8739=y
# CONFIG_VIDEO_VP27SMPX is not set
CONFIG_VIDEO_SONY_BTF_MPX=y

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=y

#
# Video decoders
#
CONFIG_VIDEO_ADV7183=y
# CONFIG_VIDEO_BT819 is not set
CONFIG_VIDEO_BT856=y
# CONFIG_VIDEO_BT866 is not set
CONFIG_VIDEO_KS0127=y
# CONFIG_VIDEO_ML86V7667 is not set
# CONFIG_VIDEO_SAA7110 is not set
CONFIG_VIDEO_SAA711X=y
CONFIG_VIDEO_TVP514X=y
# CONFIG_VIDEO_TVP5150 is not set
# CONFIG_VIDEO_TVP7002 is not set
CONFIG_VIDEO_TW2804=y
CONFIG_VIDEO_TW9903=y
CONFIG_VIDEO_TW9906=y
CONFIG_VIDEO_TW9910=y
CONFIG_VIDEO_VPX3220=y

#
# Video and audio decoders
#
CONFIG_VIDEO_SAA717X=y
CONFIG_VIDEO_CX25840=y

#
# Video encoders
#
CONFIG_VIDEO_SAA7127=y
CONFIG_VIDEO_SAA7185=y
CONFIG_VIDEO_ADV7170=y
CONFIG_VIDEO_ADV7175=y
CONFIG_VIDEO_ADV7343=y
# CONFIG_VIDEO_ADV7393 is not set
CONFIG_VIDEO_AK881X=y
CONFIG_VIDEO_THS8200=y

#
# Camera sensor devices
#
CONFIG_VIDEO_OV9640=y
CONFIG_VIDEO_MT9M111=y

#
# Lens drivers
#

#
# Flash devices
#

#
# Video improvement chips
#
CONFIG_VIDEO_UPD64031A=y
CONFIG_VIDEO_UPD64083=y

#
# Audio/Video compression chips
#
# CONFIG_VIDEO_SAA6752HS is not set

#
# SDR tuner chips
#
CONFIG_SDR_MAX2175=y

#
# Miscellaneous helper chips
#
CONFIG_VIDEO_THS7303=y
CONFIG_VIDEO_M52790=y
# CONFIG_VIDEO_I2C is not set
# end of I2C Encoders, decoders, sensors and other helper chips

#
# SPI helper chips
#
# end of SPI helper chips

CONFIG_MEDIA_TUNER=y

#
# Customize TV tuners
#
CONFIG_MEDIA_TUNER_SIMPLE=y
# CONFIG_MEDIA_TUNER_TDA18250 is not set
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_MT2060=y
CONFIG_MEDIA_TUNER_MT2063=y
# CONFIG_MEDIA_TUNER_MT2266 is not set
# CONFIG_MEDIA_TUNER_MT2131 is not set
CONFIG_MEDIA_TUNER_QT1010=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MXL5005S=y
# CONFIG_MEDIA_TUNER_MXL5007T is not set
CONFIG_MEDIA_TUNER_MC44S803=y
CONFIG_MEDIA_TUNER_MAX2165=y
CONFIG_MEDIA_TUNER_TDA18218=y
# CONFIG_MEDIA_TUNER_FC0011 is not set
CONFIG_MEDIA_TUNER_FC0012=y
# CONFIG_MEDIA_TUNER_FC0013 is not set
CONFIG_MEDIA_TUNER_TDA18212=y
# CONFIG_MEDIA_TUNER_E4000 is not set
# CONFIG_MEDIA_TUNER_FC2580 is not set
# CONFIG_MEDIA_TUNER_M88RS6000T is not set
# CONFIG_MEDIA_TUNER_TUA9001 is not set
CONFIG_MEDIA_TUNER_SI2157=y
# CONFIG_MEDIA_TUNER_IT913X is not set
CONFIG_MEDIA_TUNER_R820T=y
# CONFIG_MEDIA_TUNER_MXL301RF is not set
# CONFIG_MEDIA_TUNER_QM1D1C0042 is not set
CONFIG_MEDIA_TUNER_QM1D1B0004=y
# end of Customize TV tuners

#
# Customise DVB Frontends
#

#
# Tools to develop new frontends
#
# end of Customise DVB Frontends

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
CONFIG_DRM_MIPI_DSI=y
CONFIG_DRM_DP_AUX_CHARDEV=y
CONFIG_DRM_DEBUG_MM=y
CONFIG_DRM_DEBUG_SELFTEST=y
CONFIG_DRM_KMS_HELPER=y
# CONFIG_DRM_FBDEV_EMULATION is not set
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
# CONFIG_DRM_DP_CEC is not set
CONFIG_DRM_TTM=y
CONFIG_DRM_GEM_CMA_HELPER=y
CONFIG_DRM_KMS_CMA_HELPER=y
CONFIG_DRM_VM=y
CONFIG_DRM_SCHED=y

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=y
CONFIG_DRM_I2C_SIL164=y
CONFIG_DRM_I2C_NXP_TDA998X=y
# CONFIG_DRM_I2C_NXP_TDA9950 is not set
# end of I2C encoder or helper chips

#
# ARM devices
#
CONFIG_DRM_KOMEDA=y
# end of ARM devices

# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_AMDGPU is not set

#
# ACP (Audio CoProcessor) Configuration
#
# end of ACP (Audio CoProcessor) Configuration

# CONFIG_DRM_NOUVEAU is not set
# CONFIG_DRM_I915 is not set
CONFIG_DRM_VGEM=y
CONFIG_DRM_VKMS=y
CONFIG_DRM_ATI_PCIGART=y
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
CONFIG_DRM_RCAR_DW_HDMI=y
CONFIG_DRM_RCAR_LVDS=y
# CONFIG_DRM_QXL is not set
# CONFIG_DRM_BOCHS is not set
CONFIG_DRM_VIRTIO_GPU=y
CONFIG_DRM_PANEL=y

#
# Display Panels
#
# CONFIG_DRM_PANEL_ARM_VERSATILE is not set
CONFIG_DRM_PANEL_LVDS=y
CONFIG_DRM_PANEL_SIMPLE=y
CONFIG_DRM_PANEL_FEIYANG_FY07024DI26A30D=y
# CONFIG_DRM_PANEL_ILITEK_ILI9881C is not set
# CONFIG_DRM_PANEL_INNOLUX_P079ZCA is not set
# CONFIG_DRM_PANEL_JDI_LT070ME05000 is not set
CONFIG_DRM_PANEL_KINGDISPLAY_KD097D04=y
CONFIG_DRM_PANEL_OLIMEX_LCD_OLINUXINO=y
# CONFIG_DRM_PANEL_ORISETECH_OTM8009A is not set
CONFIG_DRM_PANEL_OSD_OSD101T2587_53TS=y
CONFIG_DRM_PANEL_PANASONIC_VVX10F034N00=y
CONFIG_DRM_PANEL_RASPBERRYPI_TOUCHSCREEN=y
CONFIG_DRM_PANEL_RAYDIUM_RM68200=y
CONFIG_DRM_PANEL_ROCKTECH_JH057N00900=y
# CONFIG_DRM_PANEL_RONBO_RB070D30 is not set
CONFIG_DRM_PANEL_SAMSUNG_S6D16D0=y
CONFIG_DRM_PANEL_SAMSUNG_S6E3HA2=y
# CONFIG_DRM_PANEL_SAMSUNG_S6E63J0X03 is not set
CONFIG_DRM_PANEL_SAMSUNG_S6E8AA0=y
# CONFIG_DRM_PANEL_SEIKO_43WVF1G is not set
# CONFIG_DRM_PANEL_SHARP_LQ101R1SX01 is not set
# CONFIG_DRM_PANEL_SHARP_LS043T1LE01 is not set
CONFIG_DRM_PANEL_SITRONIX_ST7701=y
# CONFIG_DRM_PANEL_TRULY_NT35597_WQXGA is not set
# end of Display Panels

CONFIG_DRM_BRIDGE=y
CONFIG_DRM_PANEL_BRIDGE=y

#
# Display Interface Bridges
#
# CONFIG_DRM_ANALOGIX_ANX78XX is not set
CONFIG_DRM_CDNS_DSI=y
# CONFIG_DRM_DUMB_VGA_DAC is not set
CONFIG_DRM_LVDS_ENCODER=y
CONFIG_DRM_MEGACHIPS_STDPXXXX_GE_B850V3_FW=y
# CONFIG_DRM_NXP_PTN3460 is not set
# CONFIG_DRM_PARADE_PS8622 is not set
CONFIG_DRM_SIL_SII8620=y
CONFIG_DRM_SII902X=y
CONFIG_DRM_SII9234=y
CONFIG_DRM_THINE_THC63LVD1024=y
# CONFIG_DRM_TOSHIBA_TC358764 is not set
# CONFIG_DRM_TOSHIBA_TC358767 is not set
# CONFIG_DRM_TI_TFP410 is not set
CONFIG_DRM_TI_SN65DSI86=y
CONFIG_DRM_I2C_ADV7511=y
CONFIG_DRM_I2C_ADV7533=y
# CONFIG_DRM_I2C_ADV7511_CEC is not set
CONFIG_DRM_DW_HDMI=y
CONFIG_DRM_DW_HDMI_CEC=y
# end of Display Interface Bridges

CONFIG_DRM_ETNAVIV=y
CONFIG_DRM_ETNAVIV_THERMAL=y
CONFIG_DRM_ARCPGU=y
# CONFIG_DRM_HISI_HIBMC is not set
# CONFIG_DRM_MXSFB is not set
CONFIG_DRM_TINYDRM=y
CONFIG_DRM_XEN=y
CONFIG_DRM_XEN_FRONTEND=y
# CONFIG_DRM_VBOXVIDEO is not set
CONFIG_DRM_LEGACY=y
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_R128 is not set
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=y
CONFIG_DRM_LIB_RANDOM=y

#
# Frame buffer Devices
#
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
CONFIG_FB_FOREIGN_ENDIAN=y
CONFIG_FB_BOTH_ENDIAN=y
# CONFIG_FB_BIG_ENDIAN is not set
# CONFIG_FB_LITTLE_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
# CONFIG_FB_TILEBLITTING is not set

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
CONFIG_FB_VESA=y
CONFIG_FB_EFI=y
CONFIG_FB_N411=y
CONFIG_FB_HGA=y
CONFIG_FB_OPENCORES=y
CONFIG_FB_S1D13XXX=y
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
CONFIG_FB_SMSCUFX=y
CONFIG_FB_UDL=y
CONFIG_FB_IBM_GXT4500=y
CONFIG_FB_VIRTUAL=y
CONFIG_XEN_FBDEV_FRONTEND=y
CONFIG_FB_METRONOME=y
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_HYPERV is not set
CONFIG_FB_SIMPLE=y
CONFIG_FB_SSD1307=y
# CONFIG_FB_SM712 is not set
# end of Frame buffer Devices

#
# Backlight & LCD device support
#
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_PLATFORM=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_PWM=y
# CONFIG_BACKLIGHT_DA903X is not set
CONFIG_BACKLIGHT_DA9052=y
CONFIG_BACKLIGHT_APPLE=y
CONFIG_BACKLIGHT_PM8941_WLED=y
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_ADP8860=y
CONFIG_BACKLIGHT_ADP8870=y
CONFIG_BACKLIGHT_88PM860X=y
# CONFIG_BACKLIGHT_PCF50633 is not set
CONFIG_BACKLIGHT_AAT2870=y
CONFIG_BACKLIGHT_LM3630A=y
# CONFIG_BACKLIGHT_LM3639 is not set
CONFIG_BACKLIGHT_LP855X=y
CONFIG_BACKLIGHT_LP8788=y
CONFIG_BACKLIGHT_PANDORA=y
CONFIG_BACKLIGHT_SKY81452=y
# CONFIG_BACKLIGHT_TPS65217 is not set
# CONFIG_BACKLIGHT_GPIO is not set
# CONFIG_BACKLIGHT_LV5207LP is not set
CONFIG_BACKLIGHT_BD6107=y
# CONFIG_BACKLIGHT_ARCXCNN is not set
# end of Backlight & LCD device support

CONFIG_VIDEOMODE_HELPERS=y
CONFIG_HDMI=y
# CONFIG_LOGO is not set
# end of Graphics support

# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
CONFIG_UHID=y
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACCUTOUCH is not set
CONFIG_HID_ACRUX=y
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
CONFIG_HID_APPLEIR=y
# CONFIG_HID_ASUS is not set
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=y
# CONFIG_HID_BETOP_FF is not set
CONFIG_HID_BIGBEN_FF=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_CORSAIR=y
# CONFIG_HID_COUGAR is not set
CONFIG_HID_MACALLY=y
CONFIG_HID_CMEDIA=y
# CONFIG_HID_CYPRESS is not set
# CONFIG_HID_DRAGONRISE is not set
# CONFIG_HID_EMS_FF is not set
CONFIG_HID_ELAN=y
# CONFIG_HID_ELECOM is not set
CONFIG_HID_ELO=y
CONFIG_HID_EZKEY=y
# CONFIG_HID_GEMBIRD is not set
# CONFIG_HID_GFRM is not set
CONFIG_HID_HOLTEK=y
# CONFIG_HOLTEK_FF is not set
CONFIG_HID_GOOGLE_HAMMER=y
CONFIG_HID_GT683R=y
CONFIG_HID_KEYTOUCH=y
CONFIG_HID_KYE=y
# CONFIG_HID_UCLOGIC is not set
CONFIG_HID_WALTOP=y
# CONFIG_HID_VIEWSONIC is not set
# CONFIG_HID_GYRATION is not set
CONFIG_HID_ICADE=y
# CONFIG_HID_ITE is not set
CONFIG_HID_JABRA=y
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
CONFIG_HID_LED=y
CONFIG_HID_LENOVO=y
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_HIDPP=y
CONFIG_LOGITECH_FF=y
CONFIG_LOGIRUMBLEPAD2_FF=y
CONFIG_LOGIG940_FF=y
# CONFIG_LOGIWHEELS_FF is not set
CONFIG_HID_MAGICMOUSE=y
# CONFIG_HID_MALTRON is not set
# CONFIG_HID_MAYFLASH is not set
# CONFIG_HID_REDRAGON is not set
CONFIG_HID_MICROSOFT=y
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_NTI is not set
CONFIG_HID_NTRIG=y
CONFIG_HID_ORTEK=y
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
# CONFIG_HID_PENMOUNT is not set
# CONFIG_HID_PETALYNX is not set
# CONFIG_HID_PICOLCD is not set
CONFIG_HID_PLANTRONICS=y
CONFIG_HID_PRIMAX=y
CONFIG_HID_RETRODE=y
CONFIG_HID_ROCCAT=y
CONFIG_HID_SAITEK=y
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SONY=y
# CONFIG_SONY_FF is not set
# CONFIG_HID_SPEEDLINK is not set
CONFIG_HID_STEAM=y
# CONFIG_HID_STEELSERIES is not set
CONFIG_HID_SUNPLUS=y
CONFIG_HID_RMI=y
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_HYPERV_MOUSE is not set
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
# CONFIG_HID_THINGM is not set
CONFIG_HID_THRUSTMASTER=y
CONFIG_THRUSTMASTER_FF=y
# CONFIG_HID_UDRAW_PS3 is not set
# CONFIG_HID_U2FZERO is not set
CONFIG_HID_WACOM=y
CONFIG_HID_WIIMOTE=y
# CONFIG_HID_XINMO is not set
CONFIG_HID_ZEROPLUS=y
CONFIG_ZEROPLUS_FF=y
CONFIG_HID_ZYDACRON=y
CONFIG_HID_SENSOR_HUB=y
CONFIG_HID_SENSOR_CUSTOM_SENSOR=y
# CONFIG_HID_ALPS is not set
# end of Special HID drivers

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
# CONFIG_USB_HIDDEV is not set
# end of USB HID support

#
# I2C HID support
#
CONFIG_I2C_HID=y
# end of I2C HID support

#
# Intel ISH HID support
#
# CONFIG_INTEL_ISH_HID is not set
# end of Intel ISH HID support
# end of HID support

CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
CONFIG_USB_PCI=y
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
# CONFIG_USB_DEFAULT_PERSIST is not set
CONFIG_USB_DYNAMIC_MINORS=y
CONFIG_USB_OTG=y
CONFIG_USB_OTG_WHITELIST=y
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
CONFIG_USB_OTG_FSM=y
CONFIG_USB_LEDS_TRIGGER_USBPORT=y
CONFIG_USB_AUTOSUSPEND_DELAY=2
CONFIG_USB_MON=y
CONFIG_USB_WUSB=y
CONFIG_USB_WUSB_CBAF=y
# CONFIG_USB_WUSB_CBAF_DEBUG is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
CONFIG_USB_XHCI_HCD=y
# CONFIG_USB_XHCI_DBGCAP is not set
CONFIG_USB_XHCI_PCI=y
CONFIG_USB_XHCI_PLATFORM=y
# CONFIG_USB_EHCI_HCD is not set
CONFIG_USB_OXU210HP_HCD=y
CONFIG_USB_ISP116X_HCD=y
CONFIG_USB_FOTG210_HCD=y
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
# CONFIG_USB_OHCI_HCD_SSB is not set
CONFIG_USB_OHCI_HCD_PLATFORM=y
# CONFIG_USB_UHCI_HCD is not set
CONFIG_USB_SL811_HCD=y
CONFIG_USB_SL811_HCD_ISO=y
CONFIG_USB_SL811_CS=y
CONFIG_USB_R8A66597_HCD=y
# CONFIG_USB_WHCI_HCD is not set
CONFIG_USB_HWA_HCD=y
CONFIG_USB_HCD_BCMA=y
CONFIG_USB_HCD_SSB=y
CONFIG_USB_HCD_TEST_MODE=y

#
# USB Device Class drivers
#
CONFIG_USB_ACM=y
CONFIG_USB_PRINTER=y
CONFIG_USB_WDM=y
CONFIG_USB_TMC=y

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#

#
# USB Imaging devices
#
CONFIG_USB_MDC800=y
CONFIG_USBIP_CORE=y
CONFIG_USBIP_VHCI_HCD=y
CONFIG_USBIP_VHCI_HC_PORTS=8
CONFIG_USBIP_VHCI_NR_HCS=1
CONFIG_USBIP_HOST=y
# CONFIG_USBIP_DEBUG is not set
CONFIG_USB_MUSB_HDRC=y
CONFIG_USB_MUSB_HOST=y

#
# Platform Glue Layer
#

#
# MUSB DMA mode
#
# CONFIG_MUSB_PIO_ONLY is not set
CONFIG_USB_DWC3=y
# CONFIG_USB_DWC3_ULPI is not set
CONFIG_USB_DWC3_HOST=y

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_PCI=y
CONFIG_USB_DWC3_HAPS=y
CONFIG_USB_DWC3_OF_SIMPLE=y
CONFIG_USB_DWC2=y
CONFIG_USB_DWC2_HOST=y

#
# Gadget/Dual-role mode requires USB Gadget support to be enabled
#
# CONFIG_USB_DWC2_PCI is not set
# CONFIG_USB_DWC2_DEBUG is not set
CONFIG_USB_DWC2_TRACK_MISSED_SOFS=y
CONFIG_USB_ISP1760=y
CONFIG_USB_ISP1760_HCD=y
CONFIG_USB_ISP1760_HOST_ROLE=y

#
# USB port drivers
#
CONFIG_USB_USS720=y
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
CONFIG_USB_EMI26=y
CONFIG_USB_ADUTUX=y
CONFIG_USB_SEVSEG=y
# CONFIG_USB_RIO500 is not set
CONFIG_USB_LEGOTOWER=y
CONFIG_USB_LCD=y
CONFIG_USB_CYPRESS_CY7C63=y
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
CONFIG_USB_APPLEDISPLAY=y
CONFIG_USB_SISUSBVGA=y
# CONFIG_USB_LD is not set
CONFIG_USB_TRANCEVIBRATOR=y
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
CONFIG_USB_ISIGHTFW=y
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=y
CONFIG_USB_HUB_USB251XB=y
CONFIG_USB_HSIC_USB3503=y
CONFIG_USB_HSIC_USB4604=y
CONFIG_USB_LINK_LAYER_TEST=y
CONFIG_USB_CHAOSKEY=y
CONFIG_USB_ATM=y
CONFIG_USB_SPEEDTOUCH=y
CONFIG_USB_CXACRU=y
CONFIG_USB_UEAGLEATM=y
CONFIG_USB_XUSBATM=y

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_TAHVO_USB is not set
CONFIG_USB_ISP1301=y
# end of USB Physical Layer drivers

# CONFIG_USB_GADGET is not set
# CONFIG_TYPEC is not set
CONFIG_USB_ROLE_SWITCH=y
CONFIG_USB_ROLES_INTEL_XHCI=y
CONFIG_USB_LED_TRIG=y
CONFIG_USB_ULPI_BUS=y
CONFIG_UWB=y
CONFIG_UWB_HWA=y
# CONFIG_UWB_WHCI is not set
CONFIG_UWB_I1480U=y
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_CLASS_FLASH=y
CONFIG_LEDS_BRIGHTNESS_HW_CHANGED=y

#
# LED drivers
#
CONFIG_LEDS_88PM860X=y
# CONFIG_LEDS_AAT1290 is not set
CONFIG_LEDS_AN30259A=y
# CONFIG_LEDS_AS3645A is not set
CONFIG_LEDS_BCM6328=y
CONFIG_LEDS_BCM6358=y
CONFIG_LEDS_LM3530=y
CONFIG_LEDS_LM3532=y
CONFIG_LEDS_LM3642=y
# CONFIG_LEDS_LM3692X is not set
# CONFIG_LEDS_LM3601X is not set
CONFIG_LEDS_MT6323=y
CONFIG_LEDS_PCA9532=y
# CONFIG_LEDS_PCA9532_GPIO is not set
CONFIG_LEDS_GPIO=y
# CONFIG_LEDS_LP3944 is not set
CONFIG_LEDS_LP3952=y
CONFIG_LEDS_LP55XX_COMMON=y
# CONFIG_LEDS_LP5521 is not set
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=y
CONFIG_LEDS_LP8788=y
CONFIG_LEDS_LP8860=y
CONFIG_LEDS_PCA955X=y
# CONFIG_LEDS_PCA955X_GPIO is not set
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_WM8350=y
# CONFIG_LEDS_DA903X is not set
# CONFIG_LEDS_DA9052 is not set
CONFIG_LEDS_PWM=y
# CONFIG_LEDS_REGULATOR is not set
CONFIG_LEDS_BD2802=y
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_TCA6507=y
CONFIG_LEDS_TLC591XX=y
CONFIG_LEDS_MAX77650=y
# CONFIG_LEDS_MAX77693 is not set
CONFIG_LEDS_LM355x=y
# CONFIG_LEDS_MENF21BMC is not set
# CONFIG_LEDS_KTD2692 is not set
CONFIG_LEDS_IS31FL319X=y
CONFIG_LEDS_IS31FL32XX=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
# CONFIG_LEDS_SYSCON is not set
# CONFIG_LEDS_MLXREG is not set
CONFIG_LEDS_USER=y
# CONFIG_LEDS_NIC78BX is not set
# CONFIG_LEDS_TI_LMU_COMMON is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
CONFIG_LEDS_TRIGGER_ONESHOT=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_ACTIVITY=y
# CONFIG_LEDS_TRIGGER_GPIO is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
CONFIG_LEDS_TRIGGER_CAMERA=y
CONFIG_LEDS_TRIGGER_PANIC=y
# CONFIG_LEDS_TRIGGER_NETDEV is not set
CONFIG_LEDS_TRIGGER_PATTERN=y
CONFIG_LEDS_TRIGGER_AUDIO=y
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
# CONFIG_RTC_CLASS is not set
# CONFIG_DMADEVICES is not set

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
# CONFIG_SW_SYNC is not set
CONFIG_UDMABUF=y
# end of DMABUF options

# CONFIG_AUXDISPLAY is not set
# CONFIG_PANEL is not set
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV_GENIRQ=y
CONFIG_UIO_DMEM_GENIRQ=y
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
CONFIG_UIO_PRUSS=y
# CONFIG_UIO_MF624 is not set
CONFIG_UIO_HV_GENERIC=y
CONFIG_VFIO_IOMMU_TYPE1=y
CONFIG_VFIO=y
CONFIG_VFIO_NOIOMMU=y
# CONFIG_VFIO_PCI is not set
CONFIG_VFIO_MDEV=y
# CONFIG_VFIO_MDEV_DEVICE is not set
CONFIG_VIRT_DRIVERS=y
# CONFIG_VBOXGUEST is not set
CONFIG_VIRTIO=y
CONFIG_VIRTIO_MENU=y
# CONFIG_VIRTIO_PCI is not set
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_INPUT=y
CONFIG_VIRTIO_MMIO=y
# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set

#
# Microsoft Hyper-V guest support
#
CONFIG_HYPERV=y
CONFIG_HYPERV_TIMER=y
CONFIG_HYPERV_TSCPAGE=y
CONFIG_HYPERV_UTILS=y
CONFIG_HYPERV_BALLOON=y
# end of Microsoft Hyper-V guest support

#
# Xen driver support
#
CONFIG_XEN_BALLOON=y
# CONFIG_XEN_BALLOON_MEMORY_HOTPLUG is not set
# CONFIG_XEN_SCRUB_PAGES_DEFAULT is not set
# CONFIG_XEN_DEV_EVTCHN is not set
CONFIG_XEN_BACKEND=y
CONFIG_XENFS=y
# CONFIG_XEN_COMPAT_XENFS is not set
CONFIG_XEN_SYS_HYPERVISOR=y
CONFIG_XEN_XENBUS_FRONTEND=y
CONFIG_XEN_GNTDEV=y
# CONFIG_XEN_GRANT_DEV_ALLOC is not set
# CONFIG_XEN_GRANT_DMA_ALLOC is not set
CONFIG_SWIOTLB_XEN=y
CONFIG_XEN_PCIDEV_BACKEND=m
# CONFIG_XEN_PVCALLS_FRONTEND is not set
CONFIG_XEN_PVCALLS_BACKEND=y
CONFIG_XEN_PRIVCMD=y
# CONFIG_XEN_MCE_LOG is not set
CONFIG_XEN_HAVE_PVMMU=y
CONFIG_XEN_EFI=y
CONFIG_XEN_AUTO_XLATE=y
CONFIG_XEN_ACPI=y
CONFIG_XEN_SYMS=y
CONFIG_XEN_HAVE_VPMU=y
CONFIG_XEN_FRONT_PGDIR_SHBUF=y
# end of Xen driver support

CONFIG_STAGING=y
CONFIG_COMEDI=y
CONFIG_COMEDI_DEBUG=y
CONFIG_COMEDI_DEFAULT_BUF_SIZE_KB=2048
CONFIG_COMEDI_DEFAULT_BUF_MAXSIZE_KB=20480
CONFIG_COMEDI_MISC_DRIVERS=y
CONFIG_COMEDI_BOND=y
CONFIG_COMEDI_TEST=y
CONFIG_COMEDI_PARPORT=y
CONFIG_COMEDI_ISA_DRIVERS=y
# CONFIG_COMEDI_PCL711 is not set
# CONFIG_COMEDI_PCL724 is not set
CONFIG_COMEDI_PCL726=y
CONFIG_COMEDI_PCL730=y
# CONFIG_COMEDI_PCL812 is not set
CONFIG_COMEDI_PCL816=y
CONFIG_COMEDI_PCL818=y
# CONFIG_COMEDI_PCM3724 is not set
# CONFIG_COMEDI_AMPLC_DIO200_ISA is not set
# CONFIG_COMEDI_AMPLC_PC236_ISA is not set
CONFIG_COMEDI_AMPLC_PC263_ISA=y
CONFIG_COMEDI_RTI800=y
# CONFIG_COMEDI_RTI802 is not set
# CONFIG_COMEDI_DAC02 is not set
# CONFIG_COMEDI_DAS16M1 is not set
CONFIG_COMEDI_DAS08_ISA=y
CONFIG_COMEDI_DAS16=y
CONFIG_COMEDI_DAS800=y
# CONFIG_COMEDI_DAS1800 is not set
CONFIG_COMEDI_DAS6402=y
CONFIG_COMEDI_DT2801=y
CONFIG_COMEDI_DT2811=y
CONFIG_COMEDI_DT2814=y
CONFIG_COMEDI_DT2815=y
CONFIG_COMEDI_DT2817=y
CONFIG_COMEDI_DT282X=y
# CONFIG_COMEDI_DMM32AT is not set
CONFIG_COMEDI_FL512=y
# CONFIG_COMEDI_AIO_AIO12_8 is not set
CONFIG_COMEDI_AIO_IIRO_16=y
CONFIG_COMEDI_II_PCI20KC=y
# CONFIG_COMEDI_C6XDIGIO is not set
CONFIG_COMEDI_MPC624=y
CONFIG_COMEDI_ADQ12B=y
# CONFIG_COMEDI_NI_AT_A2150 is not set
CONFIG_COMEDI_NI_AT_AO=y
CONFIG_COMEDI_NI_ATMIO=y
# CONFIG_COMEDI_NI_ATMIO16D is not set
CONFIG_COMEDI_NI_LABPC_ISA=y
CONFIG_COMEDI_PCMAD=y
# CONFIG_COMEDI_PCMDA12 is not set
CONFIG_COMEDI_PCMMIO=y
CONFIG_COMEDI_PCMUIO=y
CONFIG_COMEDI_MULTIQ3=y
CONFIG_COMEDI_S526=y
# CONFIG_COMEDI_PCI_DRIVERS is not set
CONFIG_COMEDI_PCMCIA_DRIVERS=y
CONFIG_COMEDI_CB_DAS16_CS=y
# CONFIG_COMEDI_DAS08_CS is not set
CONFIG_COMEDI_NI_DAQ_700_CS=y
CONFIG_COMEDI_NI_DAQ_DIO24_CS=y
# CONFIG_COMEDI_NI_LABPC_CS is not set
CONFIG_COMEDI_NI_MIO_CS=y
# CONFIG_COMEDI_QUATECH_DAQP_CS is not set
# CONFIG_COMEDI_USB_DRIVERS is not set
CONFIG_COMEDI_8254=y
CONFIG_COMEDI_8255=y
CONFIG_COMEDI_8255_SA=y
CONFIG_COMEDI_KCOMEDILIB=y
CONFIG_COMEDI_DAS08=y
CONFIG_COMEDI_ISADMA=y
CONFIG_COMEDI_NI_LABPC=y
CONFIG_COMEDI_NI_LABPC_ISADMA=y
CONFIG_COMEDI_NI_TIO=y
CONFIG_COMEDI_NI_ROUTING=y

#
# IIO staging drivers
#

#
# Accelerometers
#
# end of Accelerometers

#
# Analog to digital converters
#
# end of Analog to digital converters

#
# Analog digital bi-direction converters
#
# CONFIG_ADT7316 is not set
# end of Analog digital bi-direction converters

#
# Capacitance to digital converters
#
# CONFIG_AD7150 is not set
CONFIG_AD7746=y
# end of Capacitance to digital converters

#
# Direct Digital Synthesis
#
# end of Direct Digital Synthesis

#
# Network Analyzer, Impedance Converters
#
CONFIG_AD5933=y
# end of Network Analyzer, Impedance Converters

#
# Active energy metering IC
#
CONFIG_ADE7854=y
# CONFIG_ADE7854_I2C is not set
# end of Active energy metering IC

#
# Resolver to digital converters
#
# end of Resolver to digital converters
# end of IIO staging drivers

# CONFIG_FB_SM750 is not set

#
# Speakup console speech
#
# end of Speakup console speech

# CONFIG_STAGING_MEDIA is not set

#
# Android
#
# end of Android

CONFIG_STAGING_BOARD=y
# CONFIG_LTE_GDM724X is not set
# CONFIG_GS_FPGABOOT is not set
CONFIG_UNISYSSPAR=y
CONFIG_UNISYS_VISORNIC=y
CONFIG_UNISYS_VISORINPUT=y
CONFIG_COMMON_CLK_XLNX_CLKWZRD=y
# CONFIG_MOST is not set
CONFIG_GREYBUS=y
# CONFIG_GREYBUS_ES2 is not set
# CONFIG_GREYBUS_BOOTROM is not set
# CONFIG_GREYBUS_HID is not set
# CONFIG_GREYBUS_LIGHT is not set
CONFIG_GREYBUS_LOG=y
CONFIG_GREYBUS_LOOPBACK=y
CONFIG_GREYBUS_POWER=y
CONFIG_GREYBUS_RAW=y
CONFIG_GREYBUS_VIBRATOR=y
CONFIG_GREYBUS_BRIDGED_PHY=y
CONFIG_GREYBUS_GPIO=y
CONFIG_GREYBUS_I2C=y
CONFIG_GREYBUS_PWM=y
CONFIG_GREYBUS_UART=y
CONFIG_GREYBUS_USB=y

#
# Gasket devices
#
# CONFIG_STAGING_GASKET_FRAMEWORK is not set
# end of Gasket devices

CONFIG_XIL_AXIS_FIFO=y
CONFIG_FIELDBUS_DEV=y
CONFIG_HMS_ANYBUSS_BUS=y
CONFIG_ARCX_ANYBUS_CONTROLLER=y
CONFIG_HMS_PROFINET=y
# CONFIG_KPC2000 is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACER_WIRELESS is not set
# CONFIG_ACERHDF is not set
CONFIG_ASUS_LAPTOP=y
CONFIG_DCDBAS=y
# CONFIG_DELL_SMBIOS is not set
CONFIG_DELL_SMO8800=y
CONFIG_DELL_RBU=y
CONFIG_FUJITSU_LAPTOP=y
CONFIG_FUJITSU_TABLET=y
# CONFIG_GPD_POCKET_FAN is not set
# CONFIG_HP_ACCEL is not set
CONFIG_HP_WIRELESS=y
CONFIG_PANASONIC_LAPTOP=y
CONFIG_THINKPAD_ACPI=y
CONFIG_THINKPAD_ACPI_DEBUGFACILITIES=y
# CONFIG_THINKPAD_ACPI_DEBUG is not set
# CONFIG_THINKPAD_ACPI_UNSAFE_LEDS is not set
# CONFIG_THINKPAD_ACPI_VIDEO is not set
CONFIG_THINKPAD_ACPI_HOTKEY_POLL=y
CONFIG_SENSORS_HDAPS=y
CONFIG_ASUS_WIRELESS=y
# CONFIG_ACPI_WMI is not set
CONFIG_TOPSTAR_LAPTOP=y
CONFIG_TOSHIBA_BT_RFKILL=y
CONFIG_TOSHIBA_HAPS=y
CONFIG_ACPI_CMPC=y
CONFIG_INTEL_INT0002_VGPIO=y
CONFIG_INTEL_HID_EVENT=y
CONFIG_INTEL_VBTN=y
# CONFIG_INTEL_IPS is not set
# CONFIG_INTEL_PMC_CORE is not set
# CONFIG_IBM_RTL is not set
CONFIG_SAMSUNG_LAPTOP=y
CONFIG_SAMSUNG_Q10=y
# CONFIG_APPLE_GMUX is not set
CONFIG_INTEL_RST=y
CONFIG_INTEL_SMARTCONNECT=y
# CONFIG_INTEL_PMC_IPC is not set
CONFIG_SURFACE_PRO3_BUTTON=y
CONFIG_INTEL_PUNIT_IPC=y
CONFIG_MLX_PLATFORM=y
# CONFIG_INTEL_CHTDC_TI_PWRBTN is not set
# CONFIG_I2C_MULTI_INSTANTIATE is not set
# CONFIG_PCENGINES_APU2 is not set

#
# Intel Speed Select Technology interface support
#
# CONFIG_INTEL_SPEED_SELECT_INTERFACE is not set
# end of Intel Speed Select Technology interface support

CONFIG_PMC_ATOM=y
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_PSTORE=y
CONFIG_CHROMEOS_TBMC=y
# CONFIG_CROS_EC_I2C is not set
CONFIG_CROS_EC_RPMSG=y
CONFIG_CROS_EC_LPC=y
CONFIG_CROS_EC_PROTO=y
CONFIG_CROS_KBD_LED_BACKLIGHT=y
CONFIG_CROS_EC_LIGHTBAR=y
CONFIG_CROS_EC_VBC=y
CONFIG_CROS_EC_DEBUGFS=y
CONFIG_CROS_EC_SYSFS=y
CONFIG_CROS_USBPD_LOGGER=y
# CONFIG_WILCO_EC is not set
CONFIG_MELLANOX_PLATFORM=y
CONFIG_MLXREG_HOTPLUG=y
CONFIG_MLXREG_IO=y
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
# CONFIG_CLK_HSDK is not set
CONFIG_COMMON_CLK_MAX77686=y
# CONFIG_COMMON_CLK_MAX9485 is not set
CONFIG_COMMON_CLK_SI5351=y
CONFIG_COMMON_CLK_SI514=y
CONFIG_COMMON_CLK_SI544=y
CONFIG_COMMON_CLK_SI570=y
CONFIG_COMMON_CLK_CDCE706=y
CONFIG_COMMON_CLK_CDCE925=y
CONFIG_COMMON_CLK_CS2000_CP=y
# CONFIG_COMMON_CLK_S2MPS11 is not set
# CONFIG_COMMON_CLK_LOCHNAGAR is not set
CONFIG_COMMON_CLK_PWM=y
CONFIG_COMMON_CLK_VC5=y
CONFIG_COMMON_CLK_BD718XX=y
# CONFIG_COMMON_CLK_FIXED_MMIO is not set
# end of Common Clock Framework

CONFIG_HWSPINLOCK=y

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# end of Clock Source drivers

CONFIG_MAILBOX=y
# CONFIG_PLATFORM_MHU is not set
CONFIG_PCC=y
# CONFIG_ALTERA_MBOX is not set
CONFIG_MAILBOX_TEST=y
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
# end of Generic IOMMU Pagetable Support

# CONFIG_IOMMU_DEBUGFS is not set
# CONFIG_IOMMU_DEFAULT_PASSTHROUGH is not set
CONFIG_OF_IOMMU=y
# CONFIG_AMD_IOMMU is not set
CONFIG_HYPERV_IOMMU=y

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
# end of Remoteproc drivers

#
# Rpmsg drivers
#
CONFIG_RPMSG=y
CONFIG_RPMSG_CHAR=y
CONFIG_RPMSG_QCOM_GLINK_NATIVE=y
CONFIG_RPMSG_QCOM_GLINK_RPM=y
# CONFIG_RPMSG_VIRTIO is not set
# end of Rpmsg drivers

CONFIG_SOUNDWIRE=y

#
# SoundWire Devices
#

#
# SOC (System On Chip) specific Drivers
#

#
# Amlogic SoC drivers
#
# end of Amlogic SoC drivers

#
# Aspeed SoC drivers
#
# end of Aspeed SoC drivers

#
# Broadcom SoC drivers
#
# end of Broadcom SoC drivers

#
# NXP/Freescale QorIQ SoC drivers
#
# end of NXP/Freescale QorIQ SoC drivers

#
# i.MX SoC drivers
#
# end of i.MX SoC drivers

#
# IXP4xx SoC drivers
#
# CONFIG_IXP4XX_QMGR is not set
# CONFIG_IXP4XX_NPE is not set
# end of IXP4xx SoC drivers

#
# Qualcomm SoC drivers
#
# end of Qualcomm SoC drivers

CONFIG_SOC_TI=y

#
# Xilinx SoC drivers
#
CONFIG_XILINX_VCU=y
# end of Xilinx SoC drivers
# end of SOC (System On Chip) specific Drivers

# CONFIG_PM_DEVFREQ is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_ADC_JACK=y
CONFIG_EXTCON_AXP288=y
CONFIG_EXTCON_FSA9480=y
# CONFIG_EXTCON_GPIO is not set
CONFIG_EXTCON_INTEL_INT3496=y
# CONFIG_EXTCON_MAX14577 is not set
CONFIG_EXTCON_MAX3355=y
CONFIG_EXTCON_MAX77693=y
CONFIG_EXTCON_PTN5150=y
CONFIG_EXTCON_RT8973A=y
# CONFIG_EXTCON_SM5502 is not set
CONFIG_EXTCON_USB_GPIO=y
# CONFIG_EXTCON_USBC_CROS_EC is not set
CONFIG_MEMORY=y
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
CONFIG_IIO_BUFFER_HW_CONSUMER=y
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_CONFIGFS=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2
# CONFIG_IIO_SW_DEVICE is not set
CONFIG_IIO_SW_TRIGGER=y

#
# Accelerometers
#
CONFIG_ADXL345=y
CONFIG_ADXL345_I2C=y
CONFIG_ADXL372=y
CONFIG_ADXL372_I2C=y
CONFIG_BMA180=y
# CONFIG_BMC150_ACCEL is not set
# CONFIG_DA280 is not set
# CONFIG_DA311 is not set
# CONFIG_DMARD06 is not set
CONFIG_DMARD09=y
CONFIG_DMARD10=y
CONFIG_HID_SENSOR_ACCEL_3D=y
CONFIG_IIO_CROS_EC_ACCEL_LEGACY=y
# CONFIG_IIO_ST_ACCEL_3AXIS is not set
# CONFIG_KXSD9 is not set
CONFIG_KXCJK1013=y
CONFIG_MC3230=y
CONFIG_MMA7455=y
CONFIG_MMA7455_I2C=y
# CONFIG_MMA7660 is not set
CONFIG_MMA8452=y
CONFIG_MMA9551_CORE=y
# CONFIG_MMA9551 is not set
CONFIG_MMA9553=y
CONFIG_MXC4005=y
CONFIG_MXC6255=y
CONFIG_STK8312=y
CONFIG_STK8BA50=y
# end of Accelerometers

#
# Analog to digital converters
#
CONFIG_AD7291=y
# CONFIG_AD7606_IFACE_PARALLEL is not set
CONFIG_AD799X=y
CONFIG_AXP20X_ADC=y
CONFIG_AXP288_ADC=y
CONFIG_CC10001_ADC=y
# CONFIG_DA9150_GPADC is not set
CONFIG_ENVELOPE_DETECTOR=y
CONFIG_HX711=y
# CONFIG_LP8788_ADC is not set
CONFIG_LTC2471=y
CONFIG_LTC2485=y
CONFIG_LTC2497=y
# CONFIG_MAX1363 is not set
CONFIG_MAX9611=y
CONFIG_MCP3422=y
# CONFIG_MEN_Z188_ADC is not set
# CONFIG_NAU7802 is not set
CONFIG_SD_ADC_MODULATOR=y
# CONFIG_TI_ADC081C is not set
CONFIG_TI_ADS1015=y
CONFIG_TWL4030_MADC=y
CONFIG_TWL6030_GPADC=y
CONFIG_VF610_ADC=y
CONFIG_VIPERBOARD_ADC=y
CONFIG_XILINX_XADC=y
# end of Analog to digital converters

#
# Analog Front Ends
#
# CONFIG_IIO_RESCALE is not set
# end of Analog Front Ends

#
# Amplifiers
#
# end of Amplifiers

#
# Chemical Sensors
#
CONFIG_ATLAS_PH_SENSOR=y
CONFIG_BME680=y
CONFIG_BME680_I2C=y
CONFIG_CCS811=y
# CONFIG_IAQCORE is not set
CONFIG_SENSIRION_SGP30=y
# CONFIG_SPS30 is not set
# CONFIG_VZ89X is not set
# end of Chemical Sensors

CONFIG_IIO_CROS_EC_SENSORS_CORE=y
CONFIG_IIO_CROS_EC_SENSORS=y
CONFIG_IIO_CROS_EC_SENSORS_LID_ANGLE=y

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=y
CONFIG_HID_SENSOR_IIO_TRIGGER=y
# end of Hid Sensor IIO Common

CONFIG_IIO_MS_SENSORS_I2C=y

#
# SSP Sensor Common
#
# end of SSP Sensor Common

CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
CONFIG_AD5064=y
CONFIG_AD5380=y
CONFIG_AD5446=y
CONFIG_AD5592R_BASE=y
CONFIG_AD5593R=y
CONFIG_AD5686=y
CONFIG_AD5696_I2C=y
CONFIG_CIO_DAC=y
CONFIG_DPOT_DAC=y
CONFIG_DS4424=y
CONFIG_M62332=y
CONFIG_MAX517=y
# CONFIG_MAX5821 is not set
CONFIG_MCP4725=y
# CONFIG_TI_DAC5571 is not set
CONFIG_VF610_DAC=y
# end of Digital to analog converters

#
# IIO dummy driver
#
# end of IIO dummy driver

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
# end of Clock Generator/Distribution

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
# end of Phase-Locked Loop (PLL) frequency synthesizers
# end of Frequency Synthesizers DDS/PLL

#
# Digital gyroscope sensors
#
CONFIG_BMG160=y
CONFIG_BMG160_I2C=y
# CONFIG_FXAS21002C is not set
CONFIG_HID_SENSOR_GYRO_3D=y
# CONFIG_MPU3050_I2C is not set
CONFIG_IIO_ST_GYRO_3AXIS=y
CONFIG_IIO_ST_GYRO_I2C_3AXIS=y
# CONFIG_ITG3200 is not set
# end of Digital gyroscope sensors

#
# Health Sensors
#

#
# Heart Rate Monitors
#
CONFIG_AFE4404=y
CONFIG_MAX30100=y
# CONFIG_MAX30102 is not set
# end of Heart Rate Monitors
# end of Health Sensors

#
# Humidity sensors
#
CONFIG_AM2315=y
CONFIG_DHT11=y
CONFIG_HDC100X=y
CONFIG_HID_SENSOR_HUMIDITY=y
# CONFIG_HTS221 is not set
CONFIG_HTU21=y
CONFIG_SI7005=y
CONFIG_SI7020=y
# end of Humidity sensors

#
# Inertial measurement units
#
CONFIG_BMI160=y
CONFIG_BMI160_I2C=y
CONFIG_KMX61=y
CONFIG_INV_MPU6050_IIO=y
CONFIG_INV_MPU6050_I2C=y
CONFIG_IIO_ST_LSM6DSX=y
CONFIG_IIO_ST_LSM6DSX_I2C=y
# end of Inertial measurement units

#
# Light sensors
#
# CONFIG_ACPI_ALS is not set
# CONFIG_ADJD_S311 is not set
CONFIG_AL3320A=y
CONFIG_APDS9300=y
CONFIG_APDS9960=y
CONFIG_BH1750=y
# CONFIG_BH1780 is not set
# CONFIG_CM32181 is not set
# CONFIG_CM3232 is not set
# CONFIG_CM3323 is not set
CONFIG_CM3605=y
# CONFIG_CM36651 is not set
CONFIG_IIO_CROS_EC_LIGHT_PROX=y
# CONFIG_GP2AP020A00F is not set
# CONFIG_SENSORS_ISL29018 is not set
# CONFIG_SENSORS_ISL29028 is not set
CONFIG_ISL29125=y
CONFIG_HID_SENSOR_ALS=y
CONFIG_HID_SENSOR_PROX=y
CONFIG_JSA1212=y
CONFIG_RPR0521=y
CONFIG_LTR501=y
# CONFIG_LV0104CS is not set
CONFIG_MAX44000=y
CONFIG_MAX44009=y
# CONFIG_OPT3001 is not set
# CONFIG_PA12203001 is not set
CONFIG_SI1133=y
# CONFIG_SI1145 is not set
CONFIG_STK3310=y
CONFIG_ST_UVIS25=y
CONFIG_ST_UVIS25_I2C=y
CONFIG_TCS3414=y
# CONFIG_TCS3472 is not set
CONFIG_SENSORS_TSL2563=y
CONFIG_TSL2583=y
CONFIG_TSL2772=y
CONFIG_TSL4531=y
# CONFIG_US5182D is not set
CONFIG_VCNL4000=y
CONFIG_VCNL4035=y
CONFIG_VEML6070=y
# CONFIG_VL6180 is not set
CONFIG_ZOPT2201=y
# end of Light sensors

#
# Magnetometer sensors
#
CONFIG_AK8974=y
CONFIG_AK8975=y
CONFIG_AK09911=y
# CONFIG_BMC150_MAGN_I2C is not set
# CONFIG_MAG3110 is not set
CONFIG_HID_SENSOR_MAGNETOMETER_3D=y
CONFIG_MMC35240=y
# CONFIG_IIO_ST_MAGN_3AXIS is not set
CONFIG_SENSORS_HMC5843=y
CONFIG_SENSORS_HMC5843_I2C=y
# CONFIG_SENSORS_RM3100_I2C is not set
# end of Magnetometer sensors

#
# Multiplexers
#
CONFIG_IIO_MUX=y
# end of Multiplexers

#
# Inclinometer sensors
#
# CONFIG_HID_SENSOR_INCLINOMETER_3D is not set
# CONFIG_HID_SENSOR_DEVICE_ROTATION is not set
# end of Inclinometer sensors

#
# Triggers - standalone
#
CONFIG_IIO_HRTIMER_TRIGGER=y
CONFIG_IIO_INTERRUPT_TRIGGER=y
# CONFIG_IIO_TIGHTLOOP_TRIGGER is not set
CONFIG_IIO_SYSFS_TRIGGER=y
# end of Triggers - standalone

#
# Digital potentiometers
#
CONFIG_AD5272=y
CONFIG_DS1803=y
# CONFIG_MCP4018 is not set
CONFIG_MCP4531=y
# CONFIG_TPL0102 is not set
# end of Digital potentiometers

#
# Digital potentiostats
#
# CONFIG_LMP91000 is not set
# end of Digital potentiostats

#
# Pressure sensors
#
CONFIG_ABP060MG=y
CONFIG_BMP280=y
CONFIG_BMP280_I2C=y
CONFIG_IIO_CROS_EC_BARO=y
CONFIG_DPS310=y
CONFIG_HID_SENSOR_PRESS=y
# CONFIG_HP03 is not set
CONFIG_MPL115=y
CONFIG_MPL115_I2C=y
CONFIG_MPL3115=y
# CONFIG_MS5611 is not set
CONFIG_MS5637=y
CONFIG_IIO_ST_PRESS=y
CONFIG_IIO_ST_PRESS_I2C=y
CONFIG_T5403=y
CONFIG_HP206C=y
# CONFIG_ZPA2326 is not set
# end of Pressure sensors

#
# Lightning sensors
#
# end of Lightning sensors

#
# Proximity and distance sensors
#
CONFIG_ISL29501=y
# CONFIG_LIDAR_LITE_V2 is not set
CONFIG_MB1232=y
CONFIG_RFD77402=y
CONFIG_SRF04=y
CONFIG_SX9500=y
CONFIG_SRF08=y
# CONFIG_VL53L0X_I2C is not set
# end of Proximity and distance sensors

#
# Resolver to digital converters
#
# end of Resolver to digital converters

#
# Temperature sensors
#
CONFIG_HID_SENSOR_TEMP=y
CONFIG_MLX90614=y
CONFIG_MLX90632=y
CONFIG_TMP006=y
CONFIG_TMP007=y
# CONFIG_TSYS01 is not set
CONFIG_TSYS02D=y
# end of Temperature sensors

# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_PWM_CROS_EC=y
CONFIG_PWM_FSL_FTM=y
CONFIG_PWM_LPSS=y
# CONFIG_PWM_LPSS_PCI is not set
CONFIG_PWM_LPSS_PLATFORM=y
# CONFIG_PWM_PCA9685 is not set
CONFIG_PWM_TWL=y
CONFIG_PWM_TWL_LED=y

#
# IRQ chip support
#
CONFIG_IRQCHIP=y
# CONFIG_AL_FIC is not set
CONFIG_MADERA_IRQ=y
# end of IRQ chip support

CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
CONFIG_SERIAL_IPOCTAL=y
# CONFIG_RESET_CONTROLLER is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_GENERIC_PHY_MIPI_DPHY=y
CONFIG_BCM_KONA_USB2_PHY=y
CONFIG_PHY_CADENCE_DP=y
CONFIG_PHY_CADENCE_DPHY=y
# CONFIG_PHY_FSL_IMX8MQ_USB is not set
# CONFIG_PHY_MIXEL_MIPI_DPHY is not set
# CONFIG_PHY_PXA_28NM_HSIC is not set
CONFIG_PHY_PXA_28NM_USB2=y
CONFIG_PHY_CPCAP_USB=y
CONFIG_PHY_MAPPHONE_MDM6600=y
CONFIG_PHY_OCELOT_SERDES=y
# CONFIG_PHY_QCOM_USB_HS is not set
CONFIG_PHY_QCOM_USB_HSIC=y
CONFIG_PHY_SAMSUNG_USB2=y
# CONFIG_PHY_TUSB1210 is not set
# end of PHY Subsystem

CONFIG_POWERCAP=y
CONFIG_MCB=y
# CONFIG_MCB_PCI is not set
CONFIG_MCB_LPC=y

#
# Performance monitor support
#
# end of Performance monitor support

# CONFIG_RAS is not set
# CONFIG_THUNDERBOLT is not set

#
# Android
#
# CONFIG_ANDROID is not set
# end of Android

# CONFIG_DAX is not set
# CONFIG_NVMEM is not set

#
# HW tracing support
#
CONFIG_STM=y
# CONFIG_STM_PROTO_BASIC is not set
CONFIG_STM_PROTO_SYS_T=y
CONFIG_STM_DUMMY=y
CONFIG_STM_SOURCE_CONSOLE=y
# CONFIG_STM_SOURCE_HEARTBEAT is not set
# CONFIG_INTEL_TH is not set
# end of HW tracing support

CONFIG_FPGA=y
CONFIG_ALTERA_PR_IP_CORE=y
CONFIG_ALTERA_PR_IP_CORE_PLAT=y
# CONFIG_FPGA_MGR_ALTERA_CVP is not set
CONFIG_FPGA_BRIDGE=y
# CONFIG_ALTERA_FREEZE_BRIDGE is not set
# CONFIG_XILINX_PR_DECOUPLER is not set
CONFIG_FPGA_REGION=y
CONFIG_OF_FPGA_REGION=y
CONFIG_FPGA_DFL=y
CONFIG_FPGA_DFL_FME=y
CONFIG_FPGA_DFL_FME_MGR=y
CONFIG_FPGA_DFL_FME_BRIDGE=y
CONFIG_FPGA_DFL_FME_REGION=y
CONFIG_FPGA_DFL_AFU=y
# CONFIG_FPGA_DFL_PCI is not set
CONFIG_FSI=y
CONFIG_FSI_NEW_DEV_NODE=y
# CONFIG_FSI_MASTER_GPIO is not set
CONFIG_FSI_MASTER_HUB=y
# CONFIG_FSI_SCOM is not set
CONFIG_FSI_SBEFIFO=y
# CONFIG_FSI_OCC is not set
CONFIG_MULTIPLEXER=y

#
# Multiplexer drivers
#
# CONFIG_MUX_ADG792A is not set
CONFIG_MUX_GPIO=y
CONFIG_MUX_MMIO=y
# end of Multiplexer drivers

CONFIG_UNISYS_VISORBUS=y
# CONFIG_SIOX is not set
CONFIG_SLIMBUS=y
# CONFIG_SLIM_QCOM_CTRL is not set
CONFIG_INTERCONNECT=y
# CONFIG_COUNTER is not set
# end of Device Drivers

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_VALIDATE_FS_PARSER=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_EXPORTFS_BLOCK_OPS=y
CONFIG_FILE_LOCKING=y
# CONFIG_MANDATORY_FILE_LOCKING is not set
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
CONFIG_QFMT_V1=y
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
CONFIG_AUTOFS_FS=y
# CONFIG_FUSE_FS is not set
# CONFIG_OVERLAY_FS is not set

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
# end of Caches

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_VMCORE=y
# CONFIG_PROC_VMCORE_DEVICE_DUMP is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
# CONFIG_PROC_CHILDREN is not set
CONFIG_PROC_PID_ARCH_STATUS=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
# CONFIG_HUGETLBFS is not set
CONFIG_MEMFD_CREATE=y
CONFIG_ARCH_HAS_GIGANTIC_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_EFIVAR_FS=y
# end of Pseudo filesystems

CONFIG_MISC_FILESYSTEMS=y
CONFIG_ORANGEFS_FS=y
CONFIG_ECRYPT_FS=y
# CONFIG_ECRYPT_FS_MESSAGING is not set
CONFIG_CRAMFS=y
CONFIG_PSTORE=y
CONFIG_PSTORE_DEFLATE_COMPRESS=y
# CONFIG_PSTORE_LZO_COMPRESS is not set
# CONFIG_PSTORE_LZ4_COMPRESS is not set
CONFIG_PSTORE_LZ4HC_COMPRESS=y
# CONFIG_PSTORE_842_COMPRESS is not set
# CONFIG_PSTORE_ZSTD_COMPRESS is not set
CONFIG_PSTORE_COMPRESS=y
CONFIG_PSTORE_DEFLATE_COMPRESS_DEFAULT=y
# CONFIG_PSTORE_LZ4HC_COMPRESS_DEFAULT is not set
CONFIG_PSTORE_COMPRESS_DEFAULT="deflate"
CONFIG_PSTORE_CONSOLE=y
# CONFIG_PSTORE_PMSG is not set
CONFIG_PSTORE_RAM=y
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
# CONFIG_NLS_CODEPAGE_852 is not set
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
# CONFIG_NLS_CODEPAGE_860 is not set
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
# CONFIG_NLS_CODEPAGE_950 is not set
CONFIG_NLS_CODEPAGE_932=y
# CONFIG_NLS_CODEPAGE_949 is not set
CONFIG_NLS_CODEPAGE_874=y
# CONFIG_NLS_ISO8859_8 is not set
CONFIG_NLS_CODEPAGE_1250=y
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
# CONFIG_NLS_ISO8859_6 is not set
CONFIG_NLS_ISO8859_7=y
# CONFIG_NLS_ISO8859_9 is not set
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_14=y
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_KOI8_R=y
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_MAC_ROMAN is not set
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
# CONFIG_NLS_MAC_CROATIAN is not set
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
# CONFIG_NLS_MAC_ROMANIAN is not set
CONFIG_NLS_MAC_TURKISH=y
# CONFIG_NLS_UTF8 is not set
# CONFIG_DLM is not set
# CONFIG_UNICODE is not set
# end of File systems

#
# Security options
#
CONFIG_KEYS=y
CONFIG_KEYS_COMPAT=y
# CONFIG_KEYS_REQUEST_CACHE is not set
CONFIG_PERSISTENT_KEYRINGS=y
CONFIG_BIG_KEYS=y
CONFIG_TRUSTED_KEYS=y
# CONFIG_ENCRYPTED_KEYS is not set
CONFIG_KEY_DH_OPERATIONS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_PAGE_TABLE_ISOLATION=y
CONFIG_FORTIFY_SOURCE=y
CONFIG_STATIC_USERMODEHELPER=y
CONFIG_STATIC_USERMODEHELPER_PATH="/sbin/usermode-helper"
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_LSM="yama,loadpin,safesetid,integrity"

#
# Kernel hardening options
#

#
# Memory initialization
#
CONFIG_INIT_STACK_NONE=y
# CONFIG_GCC_PLUGIN_STRUCTLEAK_USER is not set
# CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF is not set
# CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL is not set
# CONFIG_GCC_PLUGIN_STACKLEAK is not set
CONFIG_INIT_ON_ALLOC_DEFAULT_ON=y
CONFIG_INIT_ON_FREE_DEFAULT_ON=y
# end of Memory initialization
# end of Kernel hardening options
# end of Security options

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
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
# CONFIG_CRYPTO_TEST is not set
CONFIG_CRYPTO_SIMD=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Public-key cryptography
#
CONFIG_CRYPTO_RSA=y
CONFIG_CRYPTO_DH=y
CONFIG_CRYPTO_ECC=y
CONFIG_CRYPTO_ECDH=y
# CONFIG_CRYPTO_ECRDSA is not set

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
# CONFIG_CRYPTO_CHACHA20POLY1305 is not set
# CONFIG_CRYPTO_AEGIS128 is not set
# CONFIG_CRYPTO_AEGIS128L is not set
# CONFIG_CRYPTO_AEGIS256 is not set
CONFIG_CRYPTO_AEGIS128_AESNI_SSE2=y
CONFIG_CRYPTO_AEGIS128L_AESNI_SSE2=y
CONFIG_CRYPTO_AEGIS256_AESNI_SSE2=y
CONFIG_CRYPTO_MORUS640=y
CONFIG_CRYPTO_MORUS640_GLUE=y
CONFIG_CRYPTO_MORUS640_SSE2=y
# CONFIG_CRYPTO_MORUS1280 is not set
CONFIG_CRYPTO_MORUS1280_GLUE=y
CONFIG_CRYPTO_MORUS1280_SSE2=y
# CONFIG_CRYPTO_MORUS1280_AVX2 is not set
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
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y
CONFIG_CRYPTO_KEYWRAP=y
CONFIG_CRYPTO_NHPOLY1305=y
CONFIG_CRYPTO_NHPOLY1305_SSE2=y
CONFIG_CRYPTO_NHPOLY1305_AVX2=y
CONFIG_CRYPTO_ADIANTUM=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
# CONFIG_CRYPTO_XXHASH is not set
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_POLY1305_X86_64=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
# CONFIG_CRYPTO_RMD128 is not set
# CONFIG_CRYPTO_RMD160 is not set
# CONFIG_CRYPTO_RMD256 is not set
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256_SSSE3=y
CONFIG_CRYPTO_SHA512_SSSE3=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA3=y
CONFIG_CRYPTO_SM3=y
CONFIG_CRYPTO_STREEBOG=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_TI=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_LIB_ARC4=y
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_CAST6_AVX_X86_64=y
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_DES3_EDE_X86_64 is not set
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_CHACHA20=y
# CONFIG_CRYPTO_CHACHA20_X86_64 is not set
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=y
# CONFIG_CRYPTO_SM4 is not set
CONFIG_CRYPTO_TEA=y
# CONFIG_CRYPTO_TWOFISH is not set
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y

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
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
CONFIG_CRYPTO_DRBG_HASH=y
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
CONFIG_CRYPTO_USER_API=y
# CONFIG_CRYPTO_USER_API_HASH is not set
CONFIG_CRYPTO_USER_API_SKCIPHER=y
# CONFIG_CRYPTO_USER_API_RNG is not set
CONFIG_CRYPTO_USER_API_AEAD=y
CONFIG_CRYPTO_HASH_INFO=y
# CONFIG_CRYPTO_HW is not set
# CONFIG_ASYMMETRIC_KEY_TYPE is not set

#
# Certificates for signature checking
#
CONFIG_SYSTEM_BLACKLIST_KEYRING=y
CONFIG_SYSTEM_BLACKLIST_HASH_LIST=""
# end of Certificates for signature checking

#
# Library routines
#
CONFIG_PACKING=y
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_CORDIC=y
CONFIG_PRIME_NUMBERS=y
CONFIG_RATIONAL=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
CONFIG_CRC32_SARWATE=y
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC64 is not set
CONFIG_CRC4=y
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
CONFIG_XXHASH=y
CONFIG_RANDOM32_SELFTEST=y
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
CONFIG_XZ_DEC_X86=y
# CONFIG_XZ_DEC_POWERPC is not set
# CONFIG_XZ_DEC_IA64 is not set
# CONFIG_XZ_DEC_ARM is not set
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_XARRAY_MULTI=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DMA_DECLARE_COHERENT=y
CONFIG_SWIOTLB=y
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_PERCENTAGE=0
# CONFIG_CMA_SIZE_SEL_MBYTES is not set
CONFIG_CMA_SIZE_SEL_PERCENTAGE=y
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8
# CONFIG_DMA_API_DEBUG is not set
CONFIG_SGL_ALLOC=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
# CONFIG_DDR is not set
CONFIG_IRQ_POLL=y
CONFIG_MPILIB=y
CONFIG_DIMLIB=y
CONFIG_LIBFDT=y
CONFIG_UCS2_STRING=y
CONFIG_HAVE_GENERIC_VDSO=y
CONFIG_GENERIC_GETTIMEOFDAY=y
CONFIG_FONT_SUPPORT=y
CONFIG_FONT_8x16=y
CONFIG_FONT_AUTOSELECT=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_UACCESS_FLUSHCACHE=y
CONFIG_ARCH_HAS_UACCESS_MCSAFE=y
CONFIG_ARCH_STACKWALK=y
CONFIG_STACKDEPOT=y
# CONFIG_STRING_SELFTEST is not set
# end of Library routines

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
CONFIG_BOOT_PRINTK_DELAY=y
CONFIG_DYNAMIC_DEBUG=y
# end of printk and dmesg options

#
# Compile-time checks and compiler options
#
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=y
# CONFIG_DEBUG_INFO_SPLIT is not set
# CONFIG_DEBUG_INFO_DWARF4 is not set
# CONFIG_DEBUG_INFO_BTF is not set
# CONFIG_GDB_SCRIPTS is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_INSTALL=y
CONFIG_HEADERS_CHECK=y
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CONFIG_FRAME_POINTER=y
CONFIG_STACK_VALIDATION=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
# end of Compile-time checks and compiler options

CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
# CONFIG_MAGIC_SYSRQ_SERIAL is not set
CONFIG_DEBUG_KERNEL=y
# CONFIG_DEBUG_MISC is not set

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT=y
CONFIG_PAGE_OWNER=y
# CONFIG_PAGE_POISONING is not set
# CONFIG_DEBUG_RODATA_TEST is not set
CONFIG_DEBUG_OBJECTS=y
# CONFIG_DEBUG_OBJECTS_SELFTEST is not set
CONFIG_DEBUG_OBJECTS_FREE=y
CONFIG_DEBUG_OBJECTS_TIMERS=y
# CONFIG_DEBUG_OBJECTS_WORK is not set
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
CONFIG_DEBUG_VM=y
# CONFIG_DEBUG_VM_VMACACHE is not set
# CONFIG_DEBUG_VM_RB is not set
# CONFIG_DEBUG_VM_PGFLAGS is not set
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
CONFIG_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_MEMORY_INIT is not set
# CONFIG_MEMORY_NOTIFIER_ERROR_INJECT is not set
CONFIG_HAVE_ARCH_KASAN=y
CONFIG_CC_HAS_KASAN_GENERIC=y
CONFIG_KASAN_STACK=1
# end of Memory Debugging

CONFIG_ARCH_HAS_KCOV=y
CONFIG_CC_HAS_SANCOV_TRACE_PC=y
CONFIG_KCOV=y
# CONFIG_KCOV_INSTRUMENT_ALL is not set
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
# CONFIG_SOFTLOCKUP_DETECTOR is not set
CONFIG_HARDLOCKUP_CHECK_TIMESTAMP=y
# CONFIG_HARDLOCKUP_DETECTOR is not set
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_WQ_WATCHDOG is not set
# end of Debug Lockups and Hangs

# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHED_INFO=y
CONFIG_SCHEDSTATS=y
CONFIG_SCHED_STACK_END_CHECK=y
# CONFIG_DEBUG_TIMEKEEPING is not set
CONFIG_DEBUG_PREEMPT=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_LOCK_DEBUGGING_SUPPORT=y
# CONFIG_PROVE_LOCKING is not set
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
CONFIG_DEBUG_RWSEMS=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_LOCKDEP=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_LOCK_TORTURE_TEST=m
CONFIG_WW_MUTEX_SELFTEST=y
# end of Lock Debugging (spinlocks, mutexes, etc...)

CONFIG_STACKTRACE=y
# CONFIG_WARN_ALL_UNSEEDED_RANDOM is not set
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_KOBJECT_RELEASE is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
CONFIG_DEBUG_PLIST=y
# CONFIG_DEBUG_SG is not set
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
CONFIG_TORTURE_TEST=y
CONFIG_RCU_PERF_TEST=y
CONFIG_RCU_TORTURE_TEST=m
CONFIG_RCU_CPU_STALL_TIMEOUT=21
# CONFIG_RCU_TRACE is not set
# CONFIG_RCU_EQS_DEBUG is not set
# end of RCU Debugging

# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
CONFIG_NOTIFIER_ERROR_INJECTION=y
# CONFIG_PM_NOTIFIER_ERROR_INJECT is not set
CONFIG_OF_RECONFIG_NOTIFIER_ERROR_INJECT=y
CONFIG_NETDEV_NOTIFIER_ERROR_INJECT=y
# CONFIG_FAULT_INJECTION is not set
CONFIG_LATENCYTOP=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
CONFIG_RUNTIME_TESTING_MENU=y
# CONFIG_LKDTM is not set
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_TEST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
# CONFIG_REED_SOLOMON_TEST is not set
# CONFIG_INTERVAL_TREE_TEST is not set
# CONFIG_PERCPU_TEST is not set
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_TEST_HEXDUMP is not set
# CONFIG_TEST_STRING_HELPERS is not set
CONFIG_TEST_STRSCPY=y
# CONFIG_TEST_KSTRTOX is not set
CONFIG_TEST_PRINTF=y
CONFIG_TEST_BITMAP=y
# CONFIG_TEST_BITFIELD is not set
# CONFIG_TEST_UUID is not set
# CONFIG_TEST_XARRAY is not set
# CONFIG_TEST_OVERFLOW is not set
# CONFIG_TEST_RHASHTABLE is not set
# CONFIG_TEST_HASH is not set
# CONFIG_TEST_IDA is not set
# CONFIG_TEST_LKM is not set
# CONFIG_TEST_VMALLOC is not set
# CONFIG_TEST_USER_COPY is not set
# CONFIG_TEST_BPF is not set
# CONFIG_TEST_BLACKHOLE_DEV is not set
# CONFIG_FIND_BIT_BENCHMARK is not set
# CONFIG_TEST_FIRMWARE is not set
# CONFIG_TEST_SYSCTL is not set
# CONFIG_TEST_UDELAY is not set
# CONFIG_TEST_STATIC_KEYS is not set
# CONFIG_TEST_DEBUG_VIRTUAL is not set
# CONFIG_TEST_MEMCAT_P is not set
CONFIG_TEST_STACKINIT=y
CONFIG_TEST_MEMINIT=y
CONFIG_MEMTEST=y
CONFIG_BUG_ON_DATA_CORRUPTION=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_UBSAN is not set
CONFIG_UBSAN_ALIGNMENT=y
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_X86_VERBOSE_BOOTUP=y
# CONFIG_EARLY_PRINTK is not set
CONFIG_X86_PTDUMP_CORE=y
# CONFIG_X86_PTDUMP is not set
CONFIG_EFI_PGT_DUMP=y
CONFIG_DEBUG_WX=y
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
CONFIG_IO_DELAY_UDELAY=y
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
CONFIG_DEBUG_ENTRY=y
CONFIG_DEBUG_NMI_SELFTEST=y
# CONFIG_X86_DEBUG_FPU is not set
# CONFIG_PUNIT_ATOM_DEBUG is not set
# CONFIG_UNWINDER_ORC is not set
CONFIG_UNWINDER_FRAME_POINTER=y
# end of Kernel hacking

--=_5d38e189.pwMdpwxOIvHtesRvotcq8HpjKn1pXETahLhfmsG191XEpLEH--

