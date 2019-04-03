Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,
	UPPERCASE_50_75,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CC1CC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 02:01:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6EE0206B7
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 02:01:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6EE0206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F6BD6B0266; Tue,  2 Apr 2019 22:01:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A44F6B026B; Tue,  2 Apr 2019 22:01:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E27086B026D; Tue,  2 Apr 2019 22:01:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 653D86B0266
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 22:01:45 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d1so11143001pgk.21
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 19:01:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:user-agent:mime-version;
        bh=fL/7cstjbbmKJ9fsmkM37KOADPml/Cs5mbDdKevXqfI=;
        b=tBhRIM/BKhL4EUezsp17wqg8gHB9aXx5/BKioe8uGfZFfQStNIFo2Jbc+K6bqrKhSU
         pIGMsTPN7luxz5aQiMyD+9RSWdn8ugf1f+4W4Xt6ZCprszoZPhzEStu+7UJ4CZE8mwvt
         9Q/sg5XtH6xP+Tt1yRAWWY0Rc247Pq92busLS+IGSenN2tIbwrOpKKfTed4WmMAxr1J/
         l3IPmTJAO7BlltOOgen0uPBcuR7xi2SSr6oUI2hBvA3CQq9rSLn6BZc/Rl5ijznxQlJM
         nnDKR6b2AdpxOfsxAyIbxiCfGCaa9srr+zNj8X+lFb8KpcIvcpsGNLRPd6LSM/5kAxfV
         bHXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXAvjNoA8q74VSCC4RakboH02qd274/xXWBmVcJqUAr/03DML0b
	wEhlSuLPJ7t2DVanjPJQUI6Hdok6BXbr0E3+DnlKzLUqKmhh5XOkW3ENeHsqQoNdw5x9pgMNLwx
	QtBPQwBGIH3oVygrjOzuusidb8+zdGjY0cy481q33VNYD+LHm/0X9Dif997Fa13smWQ==
X-Received: by 2002:a17:902:a607:: with SMTP id u7mr16254740plq.66.1554256903639;
        Tue, 02 Apr 2019 19:01:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypv+9ybo0+XLM0Pt4rXCvCrt9nsGHnog5dacofeUBFJrcLVNBO9FrKc6z8v5wBuKSlppS/
X-Received: by 2002:a17:902:a607:: with SMTP id u7mr16254516plq.66.1554256901052;
        Tue, 02 Apr 2019 19:01:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554256901; cv=none;
        d=google.com; s=arc-20160816;
        b=NG+CgltV+jEfBipoxFxSOmg3M2MZHDACgYYuA+1J5smJsddcGlwQssyGZk0wwmCXNA
         Ec2/scVj3+BcEjqhD9eGdzoAK+2hFAOEMp1qMzIa38cSiZIr0gjlnkG5tOirF6WWTpp7
         gz/3Cmt5vqhNV/GAgCXJmJXYoNkcEakr9BEXlIo7gfIHxJXSE04Ni63bG94po43/k2r8
         7roLxK8rUMM6rdl3pSoPp1hxxS2Mg/E8N4khpW53zFoFxHkg1qtU5nWHpIgeKFw31+lc
         qxTlQ+FujsH+iv1ggs+dR6PFchFlVRVFwm6Sn7nctNezQkTLSJOWZH8xhPQ0WypHQvdb
         PzzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:subject:cc:to:from:date;
        bh=fL/7cstjbbmKJ9fsmkM37KOADPml/Cs5mbDdKevXqfI=;
        b=iCiDrx+BzVmxlkJGO/1JK1RmolxtyztASh+C0x9xeaQQSgn9MIma1xGVNrdqnTEjqL
         CDzyFvsWIpBjWLgsQCT5FoR4xI9j1DkRkZEumFK5Ew/11xwKJqL1MQxp1/Dq7fDlseCT
         x/j+68gsrii+L8jZyJlQqrMahInxQ96Vp5Qt0DaOeYGzbvG4aTueFkHqXxxtoo9qyu3f
         Z1EN2Yuy19q/Hq8v/5JW9iNckdiZRDGwpRtuPNEGKIES2QRp/p9ZWJntkagcxx/V2mSK
         lCb00VAuU+5ISWrlB+GETMz85b7SzspTheKdCyVtaaxo5kmMQcDxxBSGVSdL/51mUCV7
         lqPA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id h185si12031111pfc.241.2019.04.02.19.01.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 19:01:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 02 Apr 2019 19:01:39 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,302,1549958400"; 
   d="gz'50?scan'50,208,50";a="334474998"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by fmsmga005.fm.intel.com with ESMTP; 02 Apr 2019 19:01:36 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hBVDb-000DL1-WC; Wed, 03 Apr 2019 10:01:36 +0800
Date: Wed, 03 Apr 2019 10:00:38 +0800
From: kernel test robot <lkp@intel.com>
To: "Tobin C. Harding" <tobin@kernel.org>
Cc: LKP <lkp@01.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Linux Memory Management List <linux-mm@kvack.org>,
 Andrew Morton <akpm@linux-foundation.org>
Subject: 15c8410c67 ("mm/slob.c: respect list_head abstraction layer"):
  WARNING: CPU: 0 PID: 1 at lib/list_debug.c:28 __list_add_valid
Message-ID: <5ca413c6.9TM84kwWw8lLhnmK%lkp@intel.com>
User-Agent: Heirloom mailx 12.5 6/20/10
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_5ca413c6.6e1RpLTvSig2RpCN6BdVKv6zspW2Szy5lyGUlDuJX7tL0uhQ"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

--=_5ca413c6.6e1RpLTvSig2RpCN6BdVKv6zspW2Szy5lyGUlDuJX7tL0uhQ
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master

commit 15c8410c67adefd26ea0df1f1b86e1836051784b
Author:     Tobin C. Harding <tobin@kernel.org>
AuthorDate: Fri Mar 29 10:01:23 2019 +1100
Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
CommitDate: Sat Mar 30 16:09:41 2019 +1100

    mm/slob.c: respect list_head abstraction layer
    
    Currently we reach inside the list_head.  This is a violation of the layer
    of abstraction provided by the list_head.  It makes the code fragile.
    More importantly it makes the code wicked hard to understand.
    
    The code logic is based on the page in which an allocation was made, we
    want to modify the slob_list we are working on to have this page at the
    front.  We already have a function to check if an entry is at the front of
    the list.  Recently a function was added to list.h to do the list
    rotation.  We can use these two functions to reduce line count, reduce
    code fragility, and reduce cognitive load required to read the code.
    
    Use list_head functions to interact with lists thereby maintaining the
    abstraction provided by the list_head structure.
    
    Link: http://lkml.kernel.org/r/20190318000234.22049-3-tobin@kernel.org
    Signed-off-by: Tobin C. Harding <tobin@kernel.org>
    Cc: Christoph Lameter <cl@linux.com>
    Cc: David Rientjes <rientjes@google.com>
    Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
    Cc: Pekka Enberg <penberg@kernel.org>
    Cc: Roman Gushchin <guro@fb.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

2e1f88301e  include/linux/list.h: add list_rotate_to_front()
15c8410c67  mm/slob.c: respect list_head abstraction layer
05d08e2995  Add linux-next specific files for 20190402
+-------------------------------------------------------+------------+------------+---------------+
|                                                       | 2e1f88301e | 15c8410c67 | next-20190402 |
+-------------------------------------------------------+------------+------------+---------------+
| boot_successes                                        | 1009       | 198        | 299           |
| boot_failures                                         | 0          | 2          | 44            |
| WARNING:at_lib/list_debug.c:#__list_add_valid         | 0          | 2          | 44            |
| RIP:__list_add_valid                                  | 0          | 2          | 44            |
| WARNING:at_lib/list_debug.c:#__list_del_entry_valid   | 0          | 2          | 25            |
| RIP:__list_del_entry_valid                            | 0          | 2          | 25            |
| WARNING:possible_circular_locking_dependency_detected | 0          | 2          | 44            |
| RIP:_raw_spin_unlock_irqrestore                       | 0          | 2          | 2             |
| BUG:kernel_hang_in_test_stage                         | 0          | 0          | 6             |
| BUG:unable_to_handle_kernel                           | 0          | 0          | 1             |
| Oops:#[##]                                            | 0          | 0          | 1             |
| RIP:slob_page_alloc                                   | 0          | 0          | 1             |
| Kernel_panic-not_syncing:Fatal_exception              | 0          | 0          | 1             |
| RIP:delay_tsc                                         | 0          | 0          | 2             |
+-------------------------------------------------------+------------+------------+---------------+

[    2.618737] db_root: cannot open: /etc/target
[    2.620114] mtdoops: mtd device (mtddev=name/number) must be supplied
[    2.620967] slram: not enough parameters.
[    2.621614] ------------[ cut here ]------------
[    2.622254] list_add corruption. prev->next should be next (ffffffffaeeb71b0), but was ffffcee1406d3f70. (prev=ffffcee140422508).
[    2.623645] WARNING: CPU: 0 PID: 1 at lib/list_debug.c:28 __list_add_valid+0x42/0x79
[    2.624760] CPU: 0 PID: 1 Comm: swapper Tainted: G                T 5.1.0-rc2-00286-g15c8410 #1
[    2.625498] RIP: 0010:__list_add_valid+0x42/0x79
[    2.625498] Code: 74 47 48 89 d9 48 89 c2 48 c7 c7 e4 e3 9f ae e8 ad 90 ae ff 0f 0b eb 2d 48 89 c1 48 89 de 48 c7 c7 5a e4 9f ae e8 97 90 ae ff <0f> 0b eb 17 48 89 f2 48 89 d9 48 89 ee 48 c7 c7 aa e4 9f ae e8 7e
[    2.625498] RSP: 0000:ffff8e630000bc08 EFLAGS: 00010086
[    2.625498] RAX: 0000000000000075 RBX: ffffffffaeeb71b0 RCX: 0000000000000099
[    2.625498] RDX: 0000000000000046 RSI: 0000000000000099 RDI: 0000000000000001
[    2.625498] RBP: ffffffffaeeb71b0 R08: 0000000000000001 R09: 0000000000000001
[    2.625498] R10: 000000000000004c R11: 0000000000000005 R12: ffff8b9f1f0fc268
[    2.625498] R13: 0000000000000dc0 R14: ffffffffaeeb71b0 R15: ffffcee140422508
[    2.625498] FS:  0000000000000000(0000) GS:ffffffffaeca3000(0000) knlGS:0000000000000000
[    2.625498] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    2.625498] CR2: 0000000000000000 CR3: 0000000017e79000 CR4: 00000000000006b0
[    2.625498] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    2.625498] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[    2.625498] Call Trace:
[    2.625498]  slob_alloc+0xc9/0x1e9
[    2.625498]  kmem_cache_alloc+0x3f/0x1d0
[    2.625498]  __kernfs_new_node+0x54/0x196
[    2.625498]  ? kernfs_add_one+0x108/0x13f
[    2.625498]  ? __mutex_unlock_slowpath+0x3c/0x1ef
[    2.625498]  kernfs_new_node+0x4e/0x6e
[    2.625498]  __kernfs_create_file+0x65/0x10c
[    2.625498]  sysfs_add_file_mode_ns+0x14a/0x18f
[    2.625498]  sysfs_create_file_ns+0x5c/0x63
[    2.625498]  bus_add_driver+0x136/0x1a3
[    2.625498]  ? m25p80_driver_init+0x40/0x40
[    2.625498]  driver_register+0x99/0xcb
[    2.625498]  do_one_initcall+0x1e6/0x4d9
[    2.625498]  kernel_init_freeable+0x491/0x5db
[    2.625498]  ? rest_init+0x219/0x219
[    2.625498]  kernel_init+0xa/0xf0
[    2.625498]  ret_from_fork+0x3a/0x50
[    2.625498] irq event stamp: 884120
[    2.625498] hardirqs last  enabled at (884119): [<ffffffffadf74f16>] _raw_spin_unlock_irqrestore+0x3c/0x5a
[    2.625498] hardirqs last disabled at (884120): [<ffffffffadf74c74>] _raw_spin_lock_irqsave+0x15/0x75
[    2.625498] softirqs last  enabled at (884092): [<ffffffffae200353>] __do_softirq+0x353/0x393
[    2.625498] softirqs last disabled at (884069): [<ffffffffad100134>] irq_exit+0x67/0x82
[    2.625498] ---[ end trace 2b1c6a5e2748f253 ]---
[    2.651195] ------------[ cut here ]------------
[    2.651195] ------------[ cut here ]------------
[    2.651812] list_del corruption. prev->next should be ffffffffaeeb71b0, but was ffffcee1406d3f70
[    2.652857] WARNING: CPU: 0 PID: 7 at lib/list_debug.c:53 __list_del_entry_valid+0x51/0x8e
[    2.654047] CPU: 0 PID: 7 Comm: kworker/u2:0 Tainted: G        W       T 5.1.0-rc2-00286-g15c8410 #1
[    2.655122] Workqueue: events_unbound async_run_entry_fn
[    2.655122] RIP: 0010:__list_del_entry_valid+0x51/0x8e
[    2.655122] Code: 9f ae e8 32 90 ae ff 0f 0b eb 34 48 c7 c7 13 e5 9f ae e8 22 90 ae ff 0f 0b eb 24 48 89 c2 48 c7 c7 49 e5 9f ae e8 0f 90 ae ff <0f> 0b eb 11 48 89 c6 48 c7 c7 85 e5 9f ae e8 fc 8f ae ff 0f 0b 31
[    2.655122] RSP: 0000:ffff8e630003bcf0 EFLAGS: 00010082
[    2.655122] RAX: 0000000000000054 RBX: ffffffffaeeb71b0 RCX: 0000000000000090
[    2.655122] RDX: 0000000000000046 RSI: 0000000000000090 RDI: 0000000000000001
[    2.655122] RBP: 0000000000000048 R08: 0000000000000001 R09: 0000000000000001
[    2.655122] R10: 0000000000000002 R11: 0000000000000005 R12: ffff8b9f1f36bfb8
[    2.655122] R13: 0000000000000cc0 R14: ffffcee1406d3f70 R15: ffffcee1406d3f68
[    2.655122] FS:  0000000000000000(0000) GS:ffffffffaeca3000(0000) knlGS:0000000000000000
[    2.655122] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    2.655122] CR2: 0000000000000000 CR3: 0000000017e79000 CR4: 00000000000006b0
[    2.655122] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    2.655122] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[    2.655122] Call Trace:
[    2.655122]  slob_alloc+0xa5/0x1e9
[    2.655122]  ? sd_revalidate_disk+0x752/0x17a4
[    2.655122]  __kmalloc+0x60/0x1ab
[    2.655122]  sd_revalidate_disk+0x752/0x17a4
[    2.655122]  sd_probe_async+0xb6/0x1cd
[    2.655122]  async_run_entry_fn+0x3a/0xe5
[    2.655122]  process_one_work+0x2a0/0x491
[    2.655122]  ? worker_thread+0x239/0x2b0
[    2.655122]  worker_thread+0x1df/0x2b0
[    2.655122]  ? process_scheduled_works+0x2c/0x2c
[    2.655122]  kthread+0x11d/0x125
[    2.655122]  ? __kthread_create_on_node+0x169/0x169
[    2.655122]  ret_from_fork+0x3a/0x50
[    2.655122] irq event stamp: 506
[    2.655122] hardirqs last  enabled at (505): [<ffffffffadf74ebe>] _raw_spin_unlock_irq+0x29/0x45
[    2.655122] hardirqs last disabled at (506): [<ffffffffadf74c74>] _raw_spin_lock_irqsave+0x15/0x75
[    2.655122] softirqs last  enabled at (484): [<ffffffffae200353>] __do_softirq+0x353/0x393
[    2.655122] softirqs last disabled at (475): [<ffffffffad100134>] irq_exit+0x67/0x82
[    2.655122] ---[ end trace 2b1c6a5e2748f254 ]---
[    2.679270] sd 0:0:0:0: [sda] 16384 512-byte logical blocks: (8.39 MB/8.00 MiB)

                                                          # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
git bisect start 05d08e2995cbe6efdb993482ee0d38a77040861a 79a3aaa7b82e3106be97842dedfd8429248896e6 --
git bisect good 2dbd2d8f2c2ccd640f9cb6462e23f0a5ac67e1a2  # 06:13  G    909     0    0   0  Merge remote-tracking branch 'net-next/master'
git bisect good d177ed11c13c43e0f5a289727c0237b9141ca458  # 06:32  G    904     0    0   0  Merge remote-tracking branch 'kvm-arm/next'
git bisect good a1a606c7831374d6ef20ed04c16a76b44f79bcab  # 06:48  G    900     0    0   0  Merge remote-tracking branch 'rpmsg/for-next'
git bisect good f2ea30d060707080d2d5f8532f0efebfa3a04302  # 07:03  G    903     0    0   0  Merge remote-tracking branch 'nvdimm/libnvdimm-for-next'
git bisect good e006c7613228cfa7abefd1c5175e171e6ae2c4b7  # 07:20  G    902     0    1   1  Merge remote-tracking branch 'xarray/xarray'
git bisect good 046b78627faba9a4b85c9f7a0bba764bbbbe76ff  # 07:38  G    906     0    2   2  Merge remote-tracking branch 'devfreq/for-next'
git bisect  bad 1999d633921bdbbf76c7f1065d15ec237a977c02  # 07:38  B     15    42    0   0  Merge branch 'akpm-current/current'
git bisect  bad 4aa445a97c1da9d169f63377262709254e496f65  # 07:38  B     39    18    0   0  mm: introduce put_user_page*(), placeholder versions
git bisect  bad 7a12d85195df96396eb2ba121ff6f4635a5af451  # 07:38  B    902     8    0   0  mm/gup: replace get_user_pages_longterm() with FOLL_LONGTERM
git bisect good 2e1f88301e46de5bad7a8342f5bb41f228225462  # 08:24  G    906     0    1   1  include/linux/list.h: add list_rotate_to_front()
git bisect  bad 3203d9ca496aeb0a55dbd8d2fc6f821cf6bb105f  # 08:36  B      0     2   16   0  mm/cma_debug.c: fix the break condition in cma_maxchunk_get()
git bisect  bad f46dc6b6ca0271d51721c2b5b054ef2ffcdcbfa0  # 09:10  B    271     1    0   0  mm/slab.c: use slab_list instead of lru
git bisect  bad 179f17e589d7c0ce1433aa967113b71e4db992a5  # 09:21  B      7     2    0   0  mm/slob.c: use slab_list instead of lru
git bisect  bad 15c8410c67adefd26ea0df1f1b86e1836051784b  # 09:35  B     19     1    0   0  mm/slob.c: respect list_head abstraction layer
# first bad commit: [15c8410c67adefd26ea0df1f1b86e1836051784b] mm/slob.c: respect list_head abstraction layer
git bisect good 2e1f88301e46de5bad7a8342f5bb41f228225462  # 09:50  G   1003     0    0   1  include/linux/list.h: add list_rotate_to_front()
# extra tests with debug options
git bisect  bad 15c8410c67adefd26ea0df1f1b86e1836051784b  # 09:59  B      2     1    0   0  mm/slob.c: respect list_head abstraction layer
# extra tests on HEAD of linux-next/master
git bisect  bad 05d08e2995cbe6efdb993482ee0d38a77040861a  # 09:59  B    299    44    0   0  Add linux-next specific files for 20190402
# extra tests on tree/branch linux-next/master
git bisect  bad 05d08e2995cbe6efdb993482ee0d38a77040861a  # 10:00  B    299    44    0   0  Add linux-next specific files for 20190402

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--=_5ca413c6.6e1RpLTvSig2RpCN6BdVKv6zspW2Szy5lyGUlDuJX7tL0uhQ
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-quantal-vm-quantal-127:20190403093917:x86_64-randconfig-a0-04021905:5.1.0-rc2-00286-g15c8410:1.gz"

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

--=_5ca413c6.6e1RpLTvSig2RpCN6BdVKv6zspW2Szy5lyGUlDuJX7tL0uhQ
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-quantal-vm-quantal-222:20190403081045:x86_64-randconfig-a0-04021905:5.1.0-rc2-00285-g2e1f883:1.gz"

H4sICKoTpFwAA2RtZXNnLXF1YW50YWwtdm0tcXVhbnRhbC0yMjI6MjAxOTA0MDMwODEwNDU6
eDg2XzY0LXJhbmRjb25maWctYTAtMDQwMjE5MDU6NS4xLjAtcmMyLTAwMjg1LWcyZTFmODgz
OjEA7FtZc+M4kn6e+RWImBd7x5IBELwUoYn1IZcVtlxqy1Xd2xUVCooEZY4pks1DZfev30xQ
pEhKKtm9+ziKKlMkMz8kgERegKSThm/EjaMsDiUJIpLJvEjggSf/Pk3jRRAtyej6mpxIzxvG
vk/ymHhB5ixCedrv90n88vdvBD60T9XnO7kPouKVrGWaBXFE9D7r017q8h6l3NJ7Sy6Zb1ka
OXlZFEHo/XewXgh+Sk6WrlszmX2tT8nJtVwEzuaux05PyT8YmT6ORpPpE/lVeuQiSYlGqDkQ
2oBZ5Gr2RDhldlegq3i1ciKPhEEkBySN43x47sn1eeqsKHkuouU8d7KXeeJEgTtkxJOLYkmc
BG7Kr9lblv4xd8Ifzls2lxF23SOpWySek8s+fJm7STHPcicM53mwknGRDxmlJJJ5P/AjZyWz
ISVJGkT5Sx8aflllyyH0smywx0gW+3kYuy9FUgsRrYL5Dyd3n714OVQPSRwn2eZrGDveHMSH
iXgZcoCOV0leP6DESxdefxVEcTp34yLKhxZ2Ipcrrx/Gy3ko1zIcyjQlwRJo5BweqmeVHgzz
/I0SiapRio0PZvSMMZ1DxxpU24frpTMEsJUTkvQHjvXL8NyVybOfnZczfZ4WUe+PQhby/I/C
iWC4eutVb/P1/NUy5obopTBRAO8Hy55De1RQzmyqn4eoU71IvuaDlQMdSQcbNaJMCsOT+sLx
TMfSBPf1xUIwn3OLc10YfLAIMunmvRKB0/P+eoXf/+y9F6GHOgWSaNSinNOeYMZgtwM9zjlZ
gPju83Ar7XkpLbn8/PlpPp5cfBoNz5OXZdmfI32GBdEzz98r5XnVrYMLbo9SoBLL1O9nz0Xu
xT+iIe2unbvR48PonmRFksRpDnoPqp4NulSEjKMc1OeTjApYZOpml+ZKwkAVaXW9dYow61LB
kJz7STGALya5mX4hP4IwJEUmyc1vs4uvoy795fjzrAf6vw48EC55fssCFzTw8WJCVk6yI6gi
lxanA/JtJVeEvtLOp9d6ZPsL3/8O7eOi/xCY7bu7YD6CpTKT6Vp6H4Lzd2Xz/zoc63aV+b5X
wn20q8Apd8H+smy+9HHgmnD46C/DlWgtuKPSlSZvUDqCQWkj0Q3WVhJcZA4P+l3Gh9/IyehV
ukUuyfXGR6JxzsEAgVsbEAeu653BvX2DRbgOsjiFJpFWegNy93XSpXsBa+OinxiQLxkKtMrS
jIiFbgiPMoIubnPTXsZaixUWMKFnyEuY7pkWzNcZdnnlpG/qpaL7CUCh2s7cZ1hwEBDAYMCF
MMZNsEsa14j75oaytbI5SK+4s7hIXXDCDTiwkPCXvvqdD7x4nZdQ+Jq5nuBSgJYuztSrwAvl
PIJ3lsV0sJc2E2Dkola7wv5O8swdkOvNuBKu2Vrftg0yuf0Tp8aVGYz7lkfjwvhOSl0qHXxX
pSpVaqwWMhz+a482adxgFVYqV/G6ieVssfz9K0/jJogfggOZJ35EhjgIuNhU753Ufa4fi0q2
BrMm9O9k8vT4CDrlg6XNSQ5qNiA/0iCXvYXTnGJN07UNsR+8YnDjREuZkU2sM2hSGhqa8nIk
7Bv4HEA0OdJdKLpLRVdEruM+d/qoWUy5BkV308DbLJsWqb0Rcu2kgRr3n8hp20pOsnDAd1Bw
3eVHqRu5uanv90olqIncrIp0m5MqmI7v+N53XI2Otvedpnoq9r+z8J2+9x0qJCHG3ne6wHfm
3neWXrrT6cXTAGJgjC+K1EFDRL7Rnvl9QH69JOTXK0K+XPXgP9m5b6DpDFqauRCN+2CmZpMp
pgoHVoYG2txkxSk+zNpwlKWDbLAa4qetNpyi32bVTEODqfAhzvEU32Tay5XKOHkTwHCsCgC+
tgDMMmhZJWA+4KVNe76xMEVNIQTFtQBmEK0YChmhXQQ7nEonUwKH8Q8CbcVoWOM0LRIc/CaA
Bd27RAXdUOUQwicx5ilKzpM5fJI8XTshfjv9TmwbdTYL/pSEC900GmCcwTBfPt7B5L4yszQJ
Z2TzXRmY6aeni8v7UZOH2y0e1uBhh3iE1uLhDR5+gEezrBaP1uDRDvDYRrsd0eAR+3l0NSMQ
+12PZ3d1LMCk5RqlotRhToOH4Vq/uJqOB2SkcuFST9S8ZsUKc9LAh6BSLZyddQb8vOZ/nF1P
22HbjWGZVFlLJsjJGubu8vPV7YycNgEM2gB4asZWNzcjpl/ZCkCjCMA2AOTyt+lVSb6hVU/q
u1YDOPplAzdw6TYg7GvFZoqdBkryow1wVjdwvdsDcMM4BEzo1zsNXL+vB1zQRg9mOw3QcowF
bfIYvOK5mI6vdoaVMcVj7Q5rSX5cKDSwZQO309HuvNllA5q100BJfrQBbTus9zFmNUowx/Mg
1MgwYpIq8m52WsOBgsQnweoIUucx2YZUuu/hUJ2QzacCaDRqWxiz/B5HlXMdtN4pp3o9udA4
PtyTQjG6P69oopjKgT6UtQJC5CrJ35rv0V9M4rVahn+iJFnupLmyqBJ8NYmwNtWkB7xy6W7M
KBJsxG/S2cqgq5fwaG8G2BEfPrbsim/rR2AOZ1cNGBuj6t9lGsNMZXlauDlJnKWqwBWRs3aC
sBHhDIhtqddZCwECg3EU5Nh+WbVTQtG/OC82uvjPUQWSx7kTqjYHhGnUFrxJy9lWE3COgMa0
eSkjpuuemi6QA5SxxWd0+TjbcO0E0ECu7TajRClZzsj9+OYzhHi5+zzQWM2oC7FdOtNJ7ylY
yZSMP5NpnOaYTBjUahKjUB9ZZ8Ci4doHsgF5eJxfTb/MzpM4ywKYMiwGZiQMVkGZF0G/HMyV
+mRapRuEnYMv2hTfvH4TV9RG6x7h5w+TMTlx3CSAfOcbJknfieeH6j+ECTn6xu+nDQCdA8D4
M/J+oxDiYRkTWDHjq4qrzDxrdU4lyPD+02xMaI9rTTStNnHjh6f57PFq/vnrIzlZQA8htC6y
eZD+Ad+WYbyAGAVveCVfSyrBUFVh7DEJQWEgysFLngZLvCpAuI4ff1FXNQPja1J/fQCDyVuI
xjsk05uS6eQ5WD4TlcK3hNPpHuHYRjitI5x+QDi9hSjeIZzdFM4+KJz9AeHsA8LZTUSMkY4K
x1qTCncHxDOsD4jnHBDPaSKa/D3isZZ47JB4pvkB8RYHxFs0Ea2teI+/0NLULd4IJPdpGniy
36Ld1/ohrWcHWm+aNd3mH0DUDiC2VrhtfABRHEAUDUSD0sYI6T8dIYPqH2jdONC60ULct14O
IZoHEM0mIrrFdyNaBxCtFqLVGCH75yOEjramZT9XOIPrTWJ2hPgjI+Ue6JfbRNQ+MlLeAUSv
hfgRGeUBRNlEFB+R0T+A6DcR0X2U9VgcenIyubh+Oq0LFm6r8BJEPoa9rToAQrQzicDDIMWi
luFwSBCwhKUqpNLrxiEGWstNvF96/W7E76qIv/LyTeNoYuJ793WyiR2d7C1yyfRGSa6KxE1a
LHph0TbLpRPiJmenkMwd021JZmowLJtAlG+izh72wcctFQhjtjEuNji9GhNPrgO3EeIiCBZI
4hir7RDypc46SPPCCYM/ob8vMo1kSGBUm7VyYBLdanMq/SCSXu/fge8HGM92a86dWnP1uFNo
Ng1wx8wGA8cZA89XF5tZH+JaHZOjBAal54TQ+IBklKSUeBo3gbQoL+rVkP2XumsyY27SZIbg
Ddxdg8LAKsFlEYQ5hJQYCodBlkMEvIoXQRjkb2SZxkWC4xRHfUKeMHonVfjObfjXBEMvdleO
n/uf3fH/7I7/Z3f8A7vjuIRMHcugSvcH5YWUS6DajOjXtBrluBdzLaMcC8GYDJJnJ3veFBrx
sTJK4AU0g5zEqQcTSCA00bnglgX+O5fZaQNO4ypmgzS9dxittDcVGoROHEIJIXbQNB035yaq
cDIgkAozQe/Oda4B+13DSJ8wC5Leu8rq4vmgMyJsZt+BQsNSh9jeFJoBd3F5x3QT7oIoyKFt
jRnijiwyMFi2aXBArrL9M0LviLtyetWDpmw2RkqPRVlZf7z6Aq4q9Al0IM+aVFiBhcmCXD+V
WE3CNBwyApniLll5HgB4g1USyhWePUD3228C4D6hAvgbEqKx8WRSloCx5WDfrGq2DsIpBsj/
iTJw5IeToqwZ2Vg69K3okdHgney1hactSAMU5W9PYG8zJfK+VtHjK1mRAPrmFqGDO5trJywk
VhzUzmwRyrQnI3QS2GUw26Hzhh3hOtm4wS0qeHcbHO3D4xyinhloASjFGYlSTK5AlYSFG8RS
eSbVVPmYbeJu3jdMwVAnq43z6jTZN2UCv1fd2JKD8wTyexhnECyRkScj9w17EIDuxCluVyVv
EJA95+TEPSVgQA3yCA3fOqBM48jt499lTCZxGDlpjWsxC7dM8Vja5OK3+f3nq7vr0XQ++3J5
dX8xm42ga8TaUtsUy0tN6jmQP90OSP0RW3K73F3ogt+N/mdWM1jMZhWDSamtbRhU87cXs9v5
bPz7qIlPbWPLYDKMTrstjB6eHsejTSONwAE4GNeNPRxXtxfjh0oqZVa2HEIzK6GQap9QnTYg
jcXd0E1ttUopws7kYWQ7IJaArOPlcstsCqwQELCjBMOI3qbUuQHzIdpQSjMA81SZui2zZZt1
IeUKPDEYjXWgaljK6XCm17ScqvirFfY9JzL/q7EeTCSoNBUQYddhHjbDVRyGyGVbEBfA6krl
MkBPttVxk2uKsqwRzn4EEKygIcjeVisJJtol4/PPELx5sgy/az6NgTerlwwZveaYcUCXwcj8
g9ZkOhOYNIweLi7vxw+fIPjvlenJ4y9baXXDwPWANhgI5nsIbEZxejCcg3ATwkf4G8U5ruBI
HZioSQ1qmLRVWpzBGEDMqWLz0redUAjXev+CUZU+XjGHYrBIPTmg5EKdfYEv12C+B9VGByJr
XDePI/MSWaMVMj2OrHOLH0fWujJrx5FNtdV/DFl0kcVxZPB5+nFkvYusl8jsMLLFKBYTjiEb
XWTjqMy2xvk7xtnsIpvHkC0KWeo7RsPqIlvHkU37PeNsd5HtY+MMw6y/Z5wZ3Vkq9Dg2Bp7v
wN5dhuw4tjDNd+g04zvY/OhoQ/D5nnlkO0uRHV2LlmarMPEo9s5iZEdXo6VTCw8SHcXeWY5M
P44NJqRjfJmx3/paug62rENrHqIFT0o7tNYhWosys0NrH6K1qTpU1aDlB7yFZfDyoFiTlh2i
hSTC6NDyA7Tgsajo0GoHaC1ho/Xv95/Gk9HjgKzhdZwOlQtBfjZUAGzI1S3HWgPc47XGsIWO
x2paYUWeuT2V/L/77CKmodR3HY67R60wQwiwQzrkqGDoGnEGKB3FzYMriIgXWDoEZSsj+DCO
E3KSvQRY8sPDpRIzDBX7Q0gnTMvs2za5jJfxZDydkZMw+ffQ1mHYLFFrnk2ZoWG4HnhzkGZQ
nRAcqHCUQBIcrIoVpJCUbVk0hgJNMDX+SdYJLkbUSSc7w4CYt1JOhNJBmzdQSRz8n/HAX2IJ
9t7J8nIHiARP95dbDHF3iXVKPlEXgZctr81wI7HB6x3jhcz2UxMCclsMBSA8G2xOwePvTcqq
5PaEKTnxnVWAOgPacqYCv1DtRJ9B5igTLNypU67bbnGIaWG5zRJQWwh9v3IyIJMgD5ZOeZb4
poB8cykjicFkKvPy3FjNDlJhfbfFXt2sOTmvbh5nlzDjDdggDFW2Dc+hE7CscvkKeayKYLfo
uiY26Jh+goEjsxwj9Mu3xMlg4L4WIUi2PVYJPFitBns3lamqgUeuJCOMnoG6iLY/MHiQ+aJI
YT4wq1bjRNAqkunkC/FSaCk9UyVBSLVBURQACBq+9euGDEZttkmSb5tVgNnBMgBy6RzzHNxw
r0qLAyVs6xFmMiA7sIdvndNgiGGqfelyNyDcniXI1QEEUHWpTgFm/S6H21joDQ5I02pKE3yR
XmZuoTJ/MDK5Q4bEAOuh6WwfYX32oaLVdAh7fk4KFgVPC1e/62pRAV2JdLhNIFkpWwIJndCp
rh0gqnsMSlY2ieaHUs7FfgZUB2WHSZZILEJkeJhb9KluaXiae99IAdtzDKqEmzodXjwQ08fW
2rwWYwxWnSfX+SrxQTUxeQrKHYeSSMODqQy9MVYmY7CTS4nVZfw+LzSOPcPMzU/jFTQMKWI+
V1Ztrgoo/4RFTnU8/yFsAovqmbhptJxjM1V9EVrgBrO1jt/5f9i9oIKZll6eT6rdDTZnclya
fgFrfb8d3hYmexxre5rRMsOAAWOCR5pesXyzkk5WqN9M1Cu1Pk+pZqDmwkRWnRRHV+ZLWGSG
6GW430UgweV4ip9MLs8z6VYsjGHuq1g21m++oWe6uZfeZugflGDlbxf8Itr8IKPdKDnptFn3
Dky8htYY7DQYTSx/prKlG/WbrFiUmwk1qwaZl4G/NlmiqYzTnlesVuAIwKbhltZKglWopwJE
NTGafRg9DchjXVZQvyKJ3TgkpRupi2/AYcIaA3M3Gs8ulKJ3ixFIYqiddjcpUB2qYVjitnCE
55QdD6a2prYot+szIoiotkpxh24PNKQN6AngbfWrlPaOp+Jlao9PHcV3XHSIFbswBbOB3U3f
ktwblJqcFPM/Qhk1aqf1wlD7ilisdQLPGBCYM/4qSk04OYUFDEGKmrqKHpYRdH6XHpQB6Ykl
RJseyz5mm55v8bHE3aI3DYiL+C59hW/SNr0FRtPS2vSsgQ8JR4veRm3YQ1/h67wtP4jPxHZ8
ynl2wmWcgqVZVf0vW9sZLFgnqhKzYVbms2yoGqYzkq5+tMu5mgqi8Mhmq03wda949M1FHXvb
ilAzcQjaYGKWSRD3fOikBXHoA8TxDkQg4CdfNrvBeA6+OrbI5ZbbNLFi/RFuseXW/pe3K21u
29iyf6Wfv1jKEyjsC2c0NbQWWxUtjGg7eaVSoUASIDEmCYYgJev9+rnnNtANLrIoZyZOVSSR
fU83erl9d3iuqTzunSEyB+Pb3uUBaWwr4npnTHuom0fMcLaa63i+TQpXyoRbFMhqjnunXZj1
0hksmWWDKHitm85oRCcQPGSrRw9scQcxJ2MbZ+lkYnzNh2nRoIiYbbxAcZXOisfCuPlqfDq7
vjQ6q2HeoKVdr8O0tmg/dS+NT8/9RT40Pi6SOcle9VPSbW0Ggam6tWTIROf6Sl44JbFP5g8Z
Cbe0awZ/rnJwP/ZPF8mw3nSE44SOXkPI3Qvi5XAmru1ONIxsvRYHlZxZip4peo7oeXpkrsmp
DbKhZGVVSAWYlxLeau1f0zkhMpMaHFDKHPT8o5SueBIMnkopDgD7P0SeCVJV6SmTxfMR57a+
mw/yk1kxWJTv+FkXKQZJu7m/0v14xMPVzJ1X9mFbfOyel4ga7rN8YyJwV5gXNRVxPztQoZLg
4XcFnZMPcnD39AFdjQckuiSw/eLmu5cRMEaWPai5sZDZRygIRBXdm67ZMZ22abax6qdtcdsT
al7ve+kI0nX5oIlhZthBnCX5BKOl20dcX5/e3lxcfmxGyByRKDV7v6yuDJHizGCr4SnWL5ly
ntBhX9G3C7Eck3QnJ7+lhhDZfCBB2Vwc6lw+LQ2nvmTQ2gksjsfI48bXMjiiumKlUCbu80JU
HAbR1YMsqBZcPz0dTchFbwAbykgZSHZbYH4E3XkfsF2Zhv3doJH03u0NuhbP0892gdqmvBj3
B7VMjWoFtWi7BUtasbsfrN7HitqymfETtaKEFtAW9wi2atMeoetPBoaZJHwnHCFt+jroijAc
03bMDQxLYwQm4h93YFgNDBKZZLTQGoalMaxdGJZJopnCCGmCt8dhIdppxGvUrjfUgFibwT8a
UxFFrreTfEI3zOBZXJ6dC3DfbzWgpQFNK+MNZWWBAnSgALhvAnQ1oJP5DaSAZbY3IIWNoQVy
aEFjaCQUeTun+0XAQWNoQWNotm/7mxvIajlq4SzL2bX4YWMDOaRJ7BgNYVRDqDv25an1nQyK
YELKOTteu5eXf7jMzzWix47jVxEDiRiYuxB71x8UoGtG3uZj2rzH6Yi4bZpPa8djOs1z4rik
U+7EaGwnefKzoWYnw+rcQzHT007yBqTyF7FCjUX8qMGazKxx/J3I4xv+JRjHbMKkGibdHpJL
x3nrCDsNVmKa6Y4psptT5Np0ZDY3urN7itL+QI+nmbpDMI63PTtNGLfBCUzJCZwGOYS58GXy
9VkJ9Sj6O2YliDi8YA3L1bNie0l/x6yEzfPhhpG3xdjcl2Yls/Ri0696KB4ytaMdNwWJCzdf
rjtVmpNq7gQNpRdywqUS+Eiq/Sbur25+7ZCoBP+58MQvliksSwlInhv6ofUK+YeXyUkYh6f+
h+Snmpyof2mSByQZeq+Qn/2A3GkEWrxA3qvJf4kUIV1qbnXJbxyox1GSLPrtulKGSEgkww39
9WOnUs00hsPWupcxNA0kRdTGGKYIPytP8uKftBGOiqeZ+p0NZiRKz5odcIrvyx1UwiBM3Yti
IupELg3gRjD31c3XFRGfRo8YnN5p71Ibf7bNhtQSqWv0pJO8nywTlY4Fe2KF2dJNPc5f3zDB
fOl92DLBUGNiKsgLWZV9aZbSTUjPeJKaSwYBWZrP0TArNbXDUdZ7U49XfU0bhJCnXqKtVk13
qwgdP8JpQ9UeWsnHdl00DH+T1D9frhap7pqWClY5RY3MeazovIxlv0zd7fZgO8fEtjjtbmui
EMZuNel6tXWSabyW0/KF0Qg+o5n1DPpfQFrTsJhkhfiYF1PsafGfo+q3/+Zo1Va+/C/Vj2c5
PvH17udubXWW2tGuMdFUQB++6NIunyazZEQzlcEq+FQsvulWIfF42g/DR/hNhtV09bi8QQfu
DdTKwJydybm+1NtPb6rA4rTNhqLK2je0W7isN/RaP/BYoOPm4KLspYvhZIq5AEFlnvPdZtgW
0ZGuaPq67glHdXJBpv4qy2hsr5Z+AEbgWtbrGI3iQ6roUI0BQRyy2muW1FAT0HXsvE5gm5oi
igIa5iwjeZH+x1b8tri5OJXhalgJs2Wp5hZpRebrHTiRoiCBEwFaa34AGUxGdDT5jS90TR1J
7cNpa8NK9vWi10Y9om8kDxZLYsVD/Iz9lt8yVVsnoDusbovvf+CVpb1YuQPYKwqncdMZQGie
HUKEv+gZp0BBYq1mmvQ97XnEXs5nc7pwZl25ETF7qgXNLSIHqYWoLu7uBIkHtOG7cIQzhWQw
RyTAl2xZ6CPMVhZZ0mMJvZBl9grJ2guJ1JkNJPgWbNtpINl7IWXWDiQr5NiEGgkKxHCaCPtB
tbARTr/WYo++gq3nDzirGNyoRnL3QnJ3IYWWhwNSI3l7IXmmtY0UhVbQQPJ/GsmywhBxiWs7
qV0VfgnWU4qotR3Z9uZ54uzq+XTTr7bTq7bhU7Pp8oeybrvKm0ad0HTb3i4bRW2acF+1GxGK
F3jhTqtMjeK9ajAiFN9xo/BHKP7eliKg+U6labyAFuxtIgJa6Lk/nKfwDbYhwgssVqxf5d+K
gMMLSR8ZzGMEyqezGLc0cuNjZnu7eJ/taVeofSRsm1jdGvcj3Ii0AcL9fNoVaQn6vAS/3gXH
zLPGc46qtI11PNplJm5/4PXpmV8H8isgcxPJJrYTMVJbfFIopTKn0igPmkOWvB194jeN4zom
LA5fzrqvTpLDaSKevTkUT9ZPIgjjisSXn8YJHA6Ne9VhqghIptjHw+q6ioIu0i0VhU1+sJw4
lTEe8lSXFFrEwtylkzQp0xqAJiuMNlVatjuygSaeS7J4Icn+SSfw2Pzuo9Zu8U1YNNmc9ztQ
LMZB3NKm9YEBr1B3gsPF8gWJhJDejqHRLRfJrMyUo5kg6IJxtq1sBMEBizIUBS7lM9KVxwn9
AYE0WYCxahDHDLd0ddat2NlUKwAc5lCOEzqtNNF3t9frVbgaFRqblg3AOyFqF7EIenrVE9V+
PlI17XxXt/UihDJ+mc2TKmuHxAkSpLOyjqKxaGQBlCUSTBZpqtoMq3QE2m+0l/xfVePQ4ZTm
zei//6e4P/QIT6O/XVTsxWJiCICiD3yTpHE6w0OFZJk+yyqkJjtxOkwNmU3XRvySCr+Cex7e
EoTWPBWryVD0U+iwBWFPk0m7CnCS0YdrOGpCEV2BC4Yd+MV0tIiRnSUObPdQpoqMFmnCHxFX
kRkjy3Gb9nQUVnqDmKTZUsHZKCGJeKhpOpnkyV8d9gaOHrbtc1WsPs1qRqzur/azgdPoJ2QN
eflUNL42nKfk+af72oGl+0PhO3ZGXl1/ufrt7DfjBnK1zLqBuxnV6Thetq40qkldZAiQjvn1
DwFf83nvDbQeqbwuB0GKjNYbmuh7ANUKb/keMVegVYF+mth3TevniUMfx/7niEnJgN3sJ4lt
LhNJ7e23T1jgBPAKMvG+JMi2fBDlPJ/F4EjGkgZEQ24bhiF6XCKrkMmRpEwgNfuBlFIuprko
Y+ohLcsTW8zoPA4bn5g4mMuYbS2PyeSEWAmxlH5RpicW8WxSt4llqW8dar1a0h8nnqjTYmPc
TIRTzIos003rD8bFZEg/q+A2PEgYuqa960HEKZgF73H5SVwNgHPHanoYZeCv3Itejnad3jID
bzf9rm5l9bFKd2Vy14Gm/KPu8XFcg8kl2BiCb4evDKEx8u0hBAGnH/+lIUQOqjLtwHiJdGsY
Nl0yryzkGhZ2Wrk+Ctt1cfb/yihIw4FWWjfFlR736QDPIN5lMhxpMVgJaZxRPYmFzCtWB4yG
wskQr41FP8XWUDyLxetdQ7mdpfXn8owmiO9AmO8/NDki7/4vnsRH6dSfH4cvKzr+mj5Lu3N/
Qlc3NKRNAyYa04UDQw2kQ2Q+I+USaDQ103ncz5fliW+z8MNy/IkV1EGx8m/FFuhAsHn83/3V
cM3ITt+RAOxhac6urplbcoSt/tKxEGA5WyJetzI2E5shEVfcX0ySEX16d3z70NIEsuhn7+Ol
+OOiJ8XTzukVyZXEylYLVNNIlqSC9FcsbC6qkidHCNmURS+aQUaMiEwh0ikurwivtuzbm09B
vcKqOcpKuy0+XvTsHQ8TOJ65j40wVBTETWFL/8BbYZI809OzM6LODTjol6PDel7qsZkttxqd
OJgm/0P3l+2Ghwoz8i1EdeaFziYX0z+NId0dXJ12ex84UcipFGsk/ezPnU0jDzZvVPBqw36M
rH6Ds/oFVCEuCsDRQZrGRVHmUEb8xfkyDNpyMZQridugKGLV5imf9UkgbpMsnc9RwIf2uZ3i
Ooegrkm8CPLmOgnu32QmSOJnat045DiCF/HdbXyS550tkpfwqQNIUfRgl7d1iT6OiZvPJ3lj
LlxSU2h1xqMkown89LFDci5pMTvFBpcUCjg9qsa0j/pcJYD/btXTLM9AuljQRjBsWxF7TuD+
wMGz7VoaTrK+okawRPAG6nJaDlbZd0UfmCEu+vFj/Djtr0oNwBpJ5Y7i4vlxo9cw5Pp7q8e0
5EeunnBZiLSqzX9c9vPZ8WPo6ymNfBMc8xvYWLo4XtltUxyQTPuKFkP65A4thrQ6F34BNYRp
8g3SPFjumPbJcpwK9C7G6QSZ8XmpGQHbQOVAVfYMQ9KNHzQgP1ae1a8fzjlmror/qx72IE2+
n5jf3QylrGhZTwz7UENFXBdPQT325RVxcLi2Gxr7gPhlBHVJkahtVH3y2kaCR8zmVPT5ii6I
bvGEsi8k4RArSkpxXNlpj69u/uj9q/f5um2a+L37+92HG/zOdPL/6sLwkIWhas2tQd4T4cWD
aujaPqy+v8viHO1GIc7uJFlCB5N2E5lOpM4QioEt+VSNaVEmjUPleaaNPXZKEnsON8igmM5z
1s5Il8gW6Z/K5UebvBDPOOqyckqF4eDOsGCA6dF2hoIX2p55bPkErdKcXMExlbIYWTlO5L5v
Jh0BJ6BDQstZWeS55AaYEeoLmN+dLBQHqJF4ItwjjsCP+8lqSH/KwkSH2HyJ4H47NSQdXI5x
q0zzgLQ0pK0hnf0hQy+AR3s+Z3cvHaqFIaM2kQNBG3/Cz1o9uqYKPE67SBb4Np4PaheGjJCt
4pe2XAeaPgrZiyLpYbE7Ncrl86SKDKe5O0I1E9itu6e9bvfgqNVqHT4o+sgOkUrW6F//2oo8
mpwvLAlwaQfUhCjGxN6wh6ZJZSXSivvZtZoOOlAycmIncBiGPw1sBxESBnYD+47908COfKMA
J68YOcoe4Z6ijTmiFUPJsS9lirk8uVEkXsjZ+7NsUOZTEjnsrbAItPJdDhTb+5bAw9TBlKAP
HAuxM19mOZ/k6xUJa4Y62OcGovvWt5UX+B6qg9PRjSspiVga216rcGywtxizgXTh7B3yEJEZ
oPJ12CI3r16PhsI/dSRhr8PRhHxuVXeh6eJep+6M0bB+DIsUYd3CZzEBXlI2S7IAxzZbPhUy
UgpBEAZNqWIhdGdxOPBimAzatbFV8qrFltyFZBiSBHCfzuPyaa/2EXvp0ule6AixpklNJqtk
r+Yk8BNTzkvaHGuLrh/7YDmYHyoCJ2QDbz6dtsXXWsRumZ44wGLIiAi6yVumJvFopa3XBIhH
0uiKxWM5UGS+7cEvVC4bHZmWb9oosCvfkNJfZRwEwW4W0huOR3SaRiiv5GsY38fq8Fpep8M8
EacwpCMdsxLG6Uh4QrUPvAhxPJgQjlIndoXf4+o9REp0t8JQ3HMFHMv2HjbJBeaeIzTiaf+E
xlbMSQczv5MgUK76dMvFXGWuPLGO2PRD85HDflPjBBYpf1E1DGK2/J84Y3eC0ZGh+PgnJ5z+
6TEK+Y8H2P2tTUJ856ZHd3OgsQN2+pRDjcwXt0HPxa8/4l0jk9qLAelijR2Dc47VvIMLghew
eCLpYZKPZrQg0DBLzvCvci1cOyKpLrAjD6yu/itUZw6ZZzhzzbHcl8PkgW4u0qkQ5GBAtMNr
nzh7mAUs2kMHIWkwSIcKEbl1nX9Q+w2ZeMhmHPZjxKO3kb8A8aGYp6R5H6fLwfEyWYzSpSLw
kZH5IKbLIeoXtvFLPQkH9Dv9eoIKicez1bSfLg7FdIXkhXRDJQCQHbJxcEIMSioY6axYjcaN
FMOWbuxzvPD2k/8OMwvEIwhAuMaLWpUBVWDDC7lNhUIXJMbMkIUZOIjstMy64i0IQ9tFgYeX
uhvICJFKpWZ1e7j1ocovOeve8l1/8UVdTai6Bfluu4NbaT1X3i/55pRmXT2FQUIirA83hSxD
xvEyt7NTKHeVcCqDCjSBx1bM+xmNhq63h7r2W5sfIAY6EtvT73P55ilUxSOVb0kirHxDljx+
rDL2Pnc+n8d3552zfyGVf7WYwTOmuwpc3Ol/R1dgy+bf0xUykf+mp4osNmf8LV1FQfT3TGBk
ktwPu1cyG6oLl/fokbhOZiuSmWDlW5BAAmdkRFfBqbRV4M8qyIxxXAdMSOJ8Lspx3k/ETefm
jFSdkPibsI7CryI0+vlS03j8HixJQ83AB49E7+oU6ibkKJw0zhv/FV/wqy3kR8RXj8Tt7QfV
QmMGbMjKJogEqL6VyI0mAScmrMGtn+TIDF3sK3SBVzHpkaw3s0xOjJN3xtpwdRMv4Hgnfj2F
ZMHtqo6mamObAYeZcxso8xIQBTh1Gxo3dYUgl6d8CMuBYo6R4/gYLQyl8u27zeHoblzb9RvN
GhOg19F1XZSkrNvoOW7AeBxPqKdY6uvUFG/WIOkwXJsA0n+k+jRK1SsjeBabmB6JIa6ayI1m
TqMZ55QU7Ldm97irZ8izWXZRDm+1m5E1PqyuXtmaBDwsnbOL33eWS37XhpS5UO5X0YTUBQkP
2XISD6j3i89XYsyeML4s+di0VOMI7xh50F4MS1x/PsNVusyll47ElXe7T8i7do1imU4AAWP9
RSz1S1iqF9CJdgVEvEKWB9DdCPOdwvJCrve31/AdmwTfsKn1dr7esWmEFKnJs25GmuJas0pc
GdFtSfLD98FkxdEsVf5lpgW0cp4bk2lgTiZzheZariPdk3H1Vbv5R2UygpVIcjg6DIZlK3JS
43DxPNIYED3CZb7FaedmS/9TFL4TQax4/L5F8nk1Q43azfZehIy3FMFkVameg7tD0b27PcZH
KDwD618dQm2svY3atoxvoXHTqW0LwJN2xgpvvWKpFUWRwWVL65JAmONGxRnLJ/2ArgoZj/1C
ukddBBKmF67hJkmDlhuCEVZ9r2XtiHQ5ptEcIGTGca4//bvt2NiWhyT1tD0XzSy77bjtWk8B
mOPAHvgi2MtTdSqLbtXV7BnMtxBF8EOVa5UXMTWoVG9NGrDa9RP78VtJPCHUQJGJCHT5aVuc
393d3rVrXGILQ2QV1+NqZCooAFTIQr2MLBnRAffdvgKRmHVUwJY5A7SWjRhJTZtpav3hDxEQ
sox5mKFG1ICjQbjEGVL26qdfFmqiWqLTp5/aAxi0PFyCnsLgH/XsA+o53fblEZUVWLhl9s8F
eUqMhVpAz/ZMLODe5LlFG9kYZiujzg1hlIiLlaTjQR6PByReIO2FFH3x/nw25vSH9+ITkrhP
ZcIO7AsH559OLw+ro6uQYCCOJJIxH+S0DNSKz9u8Ng8NNyioc0VRtanIanfai6R4HyPdb2vD
tlqWeH9L6t+OId/uHLJv4oIu1JBvXx2yz68SK9aHfLvPkF3EQz+oU2k5Nkauvw6DNxnmsBvG
ejd4AduDsmI5si1TzsnF7eeP9Mee64eXHtjKbv+PJpQox3wuqqLr/bT2ZvbTDKkXq2oZWFes
1+RIet6yZaOPwI2wbG9JnqovPVAH/L7gvakHw0H8NJxq+sj9UQLVrt6XUz3F0HzfcuCS+Zzu
k7ykDfGsQQJ+ycz+z/CMqoNlPHgOBr6jYKLAQtDAG2CW43ShpoLOvOO95VnSae7bdEtn+WLK
OVy8AdTC+pY8j9lymMfpBCJCRYhPDHyim5L2/5YUuG0E2wyttyDkJUSFuB67xrHZ47k3ziQd
FdgTsKFpEJeDJd60qdJyqem9yH3LLUAN43Rcos7ZGgxJdG8ZBow0A7qHURWu+F/erq25bVxJ
v+dXYOs8jF1FKcSFBKnaTK2vczwZJx7LycyeVMpLUXSsY92OKNlxfv12N0iAuosj1agqsS2i
G0ATaDSA7q8rvYnCqI5oX2HP+91Sy4AukHYfld+TdDKz5EoqXYecwM1KoERkAFuqWgNjliXf
+lkjmbqJAWYryvE78ICv8TK5j8oczzwXbiVySxNqCoXoRb7CKKUPN/Bf+62oqtwvRZhT6/3p
uVcEKrWuP376aq7GQt+D/xTdjnGvNNQ1RhFKvHXNYWUZtUwNDFiY67tlUkcnCT52ju7k05/r
6CoVKhoAu3gBPGWvnVEyKZawqOkL5eOmZDDCW3y8eCQp0J+l7ZgatE60JvEiZ2DtQCQPY7on
MrfWJ3fsDg8STb4FBAIWrKxx7ha7XG/fUi/fUpfn7rC5rUHxWNSJ3e2kA9C0ytLjKltHeeev
w2SMB/731uQCLgjBXnMRvIc/08RJOgxkVEdpJL3xNHty5JoCGna3NZLhS1IEqxJ9VM/VZJx9
S/JZfg8GQTZNnkrtGWGEQIjjNClM58vZv3vTfMZOrxDlqPdtWLgJX/76/uJ/rz5c/lTZgJdx
BsgFXUPqiGPau59kA2iNsDwiBJmos6gM8vtxOrP0sZBxnbcKYzmHXhftKNlwH73BnOvGGaK+
osRWD/lxmo+fJtXBLi0nrrisd9P7gmirlbaISIV1hvtrlmCuJUuvtMat7mSa3qeDUV6Glt7e
neFmk72gnw7dHrXtFONBREC8QIP/oHTST8CWRjWK4HZgV5TGFBRG7Fl/uYL0MbGb1SP46tgR
CIr/XiSodAzEjPU6CkWKdJGCWpWz2Ri3hpg1GZrlsVf55DEQfOGlNHyGpcIz+Sswi4tlCpY+
nnj1RErvtAzBmtsxQDHYEeC2Eoo1it0nVNwFjYLrN7qKzoawBKa9B3s3FWE4HG0LK0SNPpo/
20kxUkvUmQK3o85oejn78YPhpgsD5DGOkE5XLhOMJf3Yvrp03DWh+ew+waAHsM1+bVR0J6Y2
Qru3I1LReOhn39PRuMVOxZlgl+avq6u3V1dHnWP4H88kv/UwM9vdZwRHzIzNgafyxfalin9n
qwB7rhbAQ/e5c08q+iH2ixwpyAadc/4qG1lho5SqMwctm+FrnmWOTahUnf2CZfMDtsjasYko
krw2mzQLhfQdG9j311k/SjZZyotcOcgFZn9QZ0CVXL71o5A7LjL8S1wm076Ivn+3CwAY4ISk
U8f/sjqyI1HP8sYpcF9Mgap5IWLp19oa/pjIUH3/7ugj7tcycoQI7HiVPmKC1bJMJvn41ZHz
qNYpyCDvicD3Hb1UQZ1Z99gdP08ctaq3IYSCJkWS4xD6qNk/tU8/m9xJeC5lwjMNiGh54O28
aFrMb8ZNzh0PLWtN+Xz6xHnoZMB5FNcZSel3UKtuAMCGg8JlapwN4ESw5NIkGjbfzrnVH13Q
d+xZ9YUDZT02WJNzYlSCcI438CCM1C1MVIQunxuYwFzewgI2UpvbcYVG1xYmUVBLaeIJwbOj
jiMClBiDuVkaAfNenAjFk/Z7YERYooAblLH6h/uVehw3sJr0QhPooHzuZJ/uNssaHW0Q4n66
Mup546WH2DnQAzC2hsXlRhlyYY16GRon5p3Fdt6OVezfWnptHJjO2/yPa/bC8UK4yIDZLe+c
inR3irV/JJ1RP83ZL6+zydPI8ohga09b0mnWvycDOe0nAzA5MIixO8rmwhXZ9R8nV3eWFlPX
Bl9LWN2XLgjtj/M7e6qFQYzmEcNQo37GzNYWnZtnU0pgYC4r8p7becEeJcbL2CpT9BMu74Hx
ulNJsE7R/QHTxKGHpSOOQvQrrxJb13L35Srfcqvf0ZcH758TxEaaZunjyn6VD+v0TMEkiRcZ
Vy5smmWWx3cm/podDUcvySt+4Qx8FeApArqBPGQT2ErIVc37Ax8yfFqnfYG5t5vnvCB7tV72
QSAU+flxGHBES4locfghTpF0BUOJe+tKwV4Fut75pC1a7yrQGj3TMaxD6o6O9D1Rt6/zMyb1
KXzh8mpgV0dDckS2/rFz3a7srkEHavLdWGDsPJutChj08hT3M7DuUXJXxp3Rp3Qc4Ab5JZKw
r3m4rym/SFOqCKCOLXXp2MmbzgLAsF0dLhQstN/adr6DdrIjitzgoRtMcUAaaJCkjz9eui12
Db/8i/3rsvEbOinCOCqkWW5YysFaHTaxDvCC0vIYjhyDiosblowD8tkvr4+yXp4Q7EXh+GxT
Dti+guETEkTSIgkWBR1lel1mEnVILzgJEIJ67vQOZo7A6428+4g3YW2MzQMtXeygFq+Qrlb6
CUQEBImefQUXe0+PmvamBxLO2Mcc9PDQESgKNfv86RSBN4p1Ag8FXpLe1Hhn5RjtcIZb6DHU
brO9vmMInOQYRXSZt/N68TzryAq5gGbUMVxneXn7FuHdnkRAyg8j1ju9vFuMC8MCuCJ/ZY+9
7iR5AebJC/vn1XmZUadgeXR2zH7tTXrs/QjmYOKIY+1vPZPtde/NuawlA3nwmjcLwMWRh6Ul
D9+aC1ZsMvJafOlRTI7G2zy/OzgUnWGEECJoaMKC85Q1HgZpI00mk15GKU1+/EiGGPvoXhDm
aDLJS+BTdblrGQYgyu7ItSmWBFVgPjCHupgJFd17i+LdDM8XGzAXKBiyMmcDdJACUmjRuqKN
Bx+hzc7L49GcwjPO8boA0eJynHSOnY4xEADY3U+BgOKP7Lq7qYJVK3Fsl2JMhoHD4tsQU0D9
8qHdLkVdedFEWoScSruPD3Xso0XXncDecTACvYU+dFcV/WXtMizCiiJ4nfBcObEPI+PpuRUD
KnQUBo756uZzeyVJzo7uzm48dvJPj120b44doaK83obQecJUgYyqsErobfcOUZS8AsblXaje
V7CMiGWgMSbCsLwABV2mtSOoF8o2OMyybo6ZkooTvQQTlyX51PHQAhc1w6M3fs7nwEVNidi3
Df/yMpl8rYTsujflCGIeKCuiL/10a3mtUHEV5R9GW8pr31w/FOVHzw9bCWJaessGdbY2SXPQ
6q7P3cdt5YWv8TqjKD/YXl6GsX1zX/Ksu5UgILOwIBj+Z2v5MKKrqHEPbP2rm2dFng3XN7+1
2YgQP/GrKTm+ORVnqaXPKSdpdT79eXl7jZMKD8hZjrmMp64855ST9wbNWio4h+XqygnKob0V
fMvqTK1wO4BRj5QlAoM5yMOStAL0IXQFQRkD60FvHIKdAwYHzKe5AgFsPNA6QCwEfODVF4sW
Su4ABRY7Aklog3+KoISs/WwD6oUrBftrzBqJTgeps1DIG7nUYrRoHU3A5BN4PqVEwJJOj8XH
jkuo4l3g7CqtM9GSVG9nArM+xbyGJaqsJZyvdVqpEY/3C/pyYHwDawc2NfNExxRu8zga5+/s
IZGOfO7vgLeqKhScomj7WdrqJ8Ps3txnFyiq8G0zXc6/RnQixggl2DAkrWQ6uMdfCqrBeD0V
bH+htsgX/D8t/NHkv7PPv518YO1itwxmuz3L1XEc41nN+Rli5RWYaNCdszOwOAStCY1+7ymz
0ot8TceleTodrwfXIyw9Kd4G3BHy0MfVeNobp9Wajp5dkFvTrxSPyK9iK0KEnXMReqfosoK2
wSwhZ3Oz1yQkdMy06AiEj2fz8XiIcB5XJjYd5098g8CO5fGCKy8DFK0FDOkO83u07fvza78r
rwJRBRhJs/HjynIB3er2ex0s0XKIFaPh21Fe9Jnx4K1QTj5Cy10mtXLykfDq8M0RhtKYgE6c
Jws8D31zbAevbtXTIEL0dMyWZTKsg9FFn9Llmx1V3l6oCVXZlv58cdu++vihhaVh98RVpaTA
Q1d/z88h+dlUbMgPxIxbPRMXgYbj9Y0JVKctHSYNDJqucECeaq5wmbD+H75D22oxoRxJxGMC
sTHmJ4EmXH0koTVXfxxlLALKZM2KKhaex1IUb6zpduD/wEvUJaHFsa/LXJJQGj5gKT++5j2b
2xN3Io4ALCu6IZ0jOIfFh3D67mCwt1ilMOgYuVD4t7s2s59qYViSI7ncao7Vg1r23Xk9hsPh
5q/Cl1FuPaAzuJClPWmSO2pHqAh+b57wBl6qzZqK+PuVNgXBckWl3Av91WLVloVhKJY7IZZF
D1uxoJgpFd7JpIOojiZ7Y7VwZBtuwMwrHSU13HJFY6FstnrmVx8QRAGmckTYjBJowWMZpgfw
YEP77dFjn498/xghGW6P8Geb/i+HhMfOzePrypzH5FO08UPG3LNu/UuMhVxiXAafEmO+yFj6
Ag+DibHYwFgut3gzY8VjdD0hxvKQoghkaGWsDso4ohsBYhwcknHIfbRDiXF4UMaStiTEWG8a
FbzmywsVJRwlxtEmxqou41AFpYzjKmNKnV1hXHe4gfZCg44YJ4eUMViYccm4c0jGsfDDcoKk
m2Qs6ogiJox5vColxt2DtRgZBwKjSohxdlDGOuSlEno4KOOY4OaRMT+cPgbGnEtRTBDOD8pY
RHHZYnFQxoGOChnzw+njGDM/c1WMY344fRxjfk6rj/nh9DEwVgZwmBgfTh8D40D4pdrk+qCM
YceMhy9glmDUFmy8Bsl4jGCJLVcm4LhpgTI+a/wMVomoPNJ0+nb7OzePuHsUSjJlbn+X5pGs
PKIVHB4p80i5R1pFpj2BeRS4R5GPwUTwKDSPwsqjAE9W4ZE2j7R7FJOXNTyKzKOo8igo+h6b
R7F9FIKuU6ZfRZ/LYyJ6WNLxsteu27Akq4JSFA9F5WGgTBd4IRTupBJKSryIDwuxcCcXtN1D
87AQDHeSAZNIO2t044d1R8Mi9yhRRopwM/B4756wxPHejtAyWW7OiY84brl5EKoQhnQEc50L
oDtu/HyEd4ewhmkVwrxvwAocgm0fx3Z0cV8KFZkY7fvRy5CCSxZAwrAUZtr+yk6nk4fyQNhj
6SSVIn1nfjSKaDEE4HhogO3ee3h9V16NIAct8Hhj0e20zPBV5L0y+Y5gmCM+TcNXDV/e+VHL
j1s8Yp/uzqCrYNULjUneXB84V+gGcPJb26b6wn12yxUIKcUdw/usHO8oEfAwn4t7hlKYiVc6
cPfZkLD7DO4a7GAwir1EegeFWgK9I2EY4AG0wSMZG/iTcs9ZkOMVcGM07L8SYgPsVHE//WQ5
BDB6ot2qFmDsuKoDTISwG6EOKk0OJCFGTUbYHAq8aVH8goHRfMnQicP6kjqqKEBj9nY2ZG/x
jAydi+nn2EDilQWFVJQqa5IMu6NBq0CcnQ2rGe9n5qHBazkqYRjoz+M3700HqDUtdoq53z6+
/6+SvZR+jOfGiHKEF2BAHsqNUIvREsxibNDZ0BuZGjfuvw5GM7pbQoAE0x9grMUxe+oRtGLn
lbUvfvls3PitUEBTUnKtsq+wKwaGr5u7q+Z6W3DCmH683yyOImFwwna5gU1ZbFQUHINsJoPe
kI76TIIEExTP3xAhvMsWuyA8wioSKlQSmFFeNteVrvF6kJfwMUhOY9DdvAQbYKEuNFiIcEOD
C254LUN+mjCFu18w/UDLnKnhwC4PM2FX/6YoAEvXKnTOnww852DUpSvJnxa/YI3OMyXtaVm0
yJ9apBhm6SN7wHsCdB6j7T/MG1tb8NdrM7EPHXi78TOeUYzxRZvMY5nvce9JK2+SDPr5w8tO
TVGH6Pjpp/ZOHQcb+u+sbQ8xPwzSnaqI9+wQRrud+Zc79Qd2eX9fZbC73r8ysAh2qyzcszJE
2sQz4ZZJ6h7sVmt0gC6e7NjFkP+dI2VfdVarsn0nda3K9tBXCGJAOhMTAFOiZ0zMmNNX/ORS
5fQd577fSf0wT33e8/2dGrXHXFluFKZ+39Aof9dG7aGaVkmKr5MUJ0lFOzVK7zELlhslgpPT
NY2K8jTaVVL6EAN4V1Wn95iaK14L53L9WNldAnvoX9soTJhUNIDzNY2SNQaw3mcAl+gjhC2/
S23RvosrmCZnN592GgPRAazNneva18Azi1y4W2WHmEk7V7aHeUeV/X5x/Qm1yG617Wui7NQ1
2r4I9BmNeWVj9YDOM7Q5xvOcoklSHMKkkLvpLSkO8WoDn+9W2SHsF+X7u1W27ziq1bND2Jyn
u/bsEGP2ku84QA6xYdC79myPtcHAfkxffT6ewGIEy1P2facVSco91gi7IpW/NCi1ukkivlPl
e8wJd2jgw7rML4tDA14cGgjviY4MuCe8nY4NpNxD9bjGcDQSuGnMyani5gRDeZx7XHlPmnta
eFp6Wnk68HToae3p2NMnnj719Jmnzz194elLL/K96MyLLrzo0otPvfjMi8+9+MKLL70T6Z0o
7yTwTkLv5Mw7OfdOtXcaeaexdx57FwIPS5TXx4qFt9uhiZR76EI7Dop0JTvVt8cansPMGky7
93g2S1ir29efsKnQG1KVh3FYMzQ1WziIk0FYPc68u7i9rh5nCt3UkaZ83+Uy1u1uOcm06dur
Z4MxOuAKd5iJQmk8JP1+J0mfGt8myfixl+YLjVO+WH9KKHTJOQrDEMFRcroKKan/rzh3bSBP
yrtoEp6NOvmon4Hk82yKFKPxlLU/3p+2z88+Xt+c3G06apZ+E7qnnVQL71vku9B0Hm044JzR
IWuLvZ1ipGVxQwEt7Mzy1+ab0lnr6GoIfRogojmmbZrl2cOsb5LzJB0MDypqg2eUBgiDyayn
F141OMYmfzm84H4+ejiCpsGAecCkKUf8+PjNnZEU+quq8SRj7Dx5ztivYKXk7L+78Pu//2eS
daGKZjoa/FxKAgF40Wt+n3NuLPjV3V695ineOXzLpvcw9mf5lPJos6NQdUDaQismBf4mOQyM
hEArYYaUl1PNN+eIUzJOJvSik8m3GXqY5c03ZQXIvKgkR/rCzaJZNuTcZiqxpQZAakBTympQ
jAjyhI7hlLysgCCu9gZKhQpxUtf3CXpDfehmSemi21xgYaBW17MoxbCKxTwtIicHvoO/505o
bKGlWJTLlUXfnJ98+OXitsVuP334cPXhF3bSZrcfP94133wa9nHYv45mlHC0SCCIPsEJey6Q
dDFAEMTlmcS0BoY0TRA5ixZzmBio8PrZIDeKDTqGLveYqpESIV1/bL8hKOtBr59M2AsojMeC
zXg0hRcNI67/anJjURVFhTAeOzCJ6WIUpyHOnMTB/FFyiOabN+l00m+kbDh6AQLbG8zVB0yf
8OsXnGRlF7sji48qEWMjjkKr3KbTVzWvD7Jh16QiyMfJy7CMxJIYf81DP64QBosKOuZbbkok
xj1ryoyzjsva6pVGAIAKoViqfoMKtlyiIIzVei5rqw8DIdBHwhLKperl9urDABYotZ7L2uo1
YllUhR8uVb/pXq2YacV68YL6KMGQwy5G3dJF1WzcZH/A4spgRcX4jAfMHmmUNY6hMhCYBmDB
rXSnt4HMRWM8dnN1jqpcYZAbNhPVRA/TPJNmxRxZ6BXcLB+27fJ2xFnKwliCicZA5yA4XZdF
7EvcClr+1xXlRcwCzJj4UBaO2Rfut2QLPWVW8ueirEDykoj7QBUilVhN9FDSpMLSSPZF+i2x
ul0cVvuljnAFJDGQ8DUkyxQBNAz6vpIgZHKZIGRfgH8rXFNDx3bekWySbxSBVl2qxAh5fddd
LUlJIzg0LAQavbJp4YpqhCAJ8+3VpJZEobzWChje81IlAQoMKPQakmWK0MkLJqfiCACv0ePr
uwjuMcqlVcSUkZ1kwsqXOXPNlCC3b7VcRYxZjqBVGLawulndZRFLn0QML1/tKmKpzHBZJ+Hl
ESnDzbORLw97qYs5qeTKavxovSSkkQTMgGDrKNBBSaU4jZw1raxMtNhWpGTNmaY2ig60A/QJ
83XbPnFpSWHMRS0QyeoXxZntUpxZmk1yhxe73L64GA3Bmkr0EgmYXbuJTduuBJxUGl8745ZH
UCA2zlGxPEcDiaIG7Rysoeksk4TlOiC36gLheqPLdSBYTRQsVRT6G5eBVQoklJtVTrJMoXDA
rBmcILLl0RkGG4aLv6pR4Uad7mer+m7EJdatNnbV5KElofxtOPaFv6Y3ekmr6y3j0r7+pGNJ
toxLsWxmaLFBA1R1oehaknJgijUtc3K2Y0yrYvL/P3fX3uO2keT/tj8FsRdgbccj9/sh3NzC
cRLHWDsOxs7hDouAkEhqPOsZSZFm/Djch7+qbrKbGjWbkj0+HM4IMiTV1d0sVlfVr/pRuPr4
UJHR3dcZkhlW79N0X4cOeUJhBNjg1WjTWR4+8FHj59HBQfPMHtYbi73OGZ73U/ZZYBzfgCZJ
gpbHFP3iUQEMsGxfno3uhJMOKYA41HhQzS4noXI8Sxu4Yt8mWjLCsn0taGlebwa1IYNHYFle
0/TehgQakTU0Qc5MIFDt69MBQ5PwuqwecZ6rxMuYPMsSTEY/dUgHEHTH9zxbQvyIlgOCGeRy
oSMN7Ub0kD0Pn2ZRRSruBHTIgQCFm/DuiejG9AATTBidMhKNMHtfFaJLlhfPfYtLacs6XP14
rJtHacfDIbUTB0TVo2JZWQ0jfDGPJHm2JxwpinAno6uCQqQRGyLaybEvwQGELl6LJNU1eO8J
IIboJQuRUg2pPAoNynoWSUyWAwmkiwjGfU8zYHz29Qge+5WHFkG4dROJ6NgwClLQxMHHWevo
DfQueroq0sgR7zjwWvcaUiMDqdnnncNLQ98H+MAKHAsxqEBaSzekfRLGlCJC8opk4JsGrtHI
a8FaSAGfNy2j0dBH4RE8L6MJDghxoKqf95pRGTyG0sOBbaaO5UOkaEAG4jiIHJBdoGggThSd
RNsjYu3IVkNORWhKRnGTeR6kvEQqVc7ek+gox8iXNHl9yEyiGdsKDzvcu6aKtFwYcpISXiJV
NG+6gmFVJNKwEdc/qB4adY8S3nip0XEqoy1RDseLqRoYQxHIxc+qumDIIGZIscF0YjcKmhdx
RCgfOxlScqRKKW7dBZGYSAoRRpF2ytMRCxRGROSB5hkF14u1mPhRdT5QFYS0F9PV0gMGmdRV
oBEStlHHrzPAtD4Ojmpej32gMCB47526CA0bimukNLfJIluSitlRk404QEn4pLFfJh8K6Nus
+E1NAPZiQDeGbxRROrUjyDHhjdkcTN8JV0cNbEciLhEJ0MgG2wF1dXjYhdpc3AWlJyF0VufV
adZxtqYd5CxNrUAL9SPLhOTHayJgxwjNe4z7aoSRfJAvGCKziCRtkEslP1I70WNJLN8hfEzU
e+jwYSSE+IYYEMyD6vWtG6p2NM4ZNRBm+8tar6jpY//oWCxlP9DDaBceHBp6YcDqXufUiOFP
fFUaQkpDHA92aMYilencRjlg+iP3ooPGEHZlYwT7ngljY2GVMGRrE4loNvAXBaKZR5o2sjLq
nM3i3BSCtXwQb99tYojWfEBuSMoTMy6M6Y7ldsCK7+suhijvWNWAOC/jbPUYwSPzELNlw1L7
vhbDmSo32m2aDf14SR1nHRG0ed06ZssWPSJzYLw58sGBsEEZSk4jCpoToZRSRfxlnJ1IujT9
MdvTQqLj3FAgdH++AXy//NjbR+9MmBG3OzH3KnIBur7HENAukyQfOI6oLWoSSb1+1ANsS04L
Z0NLyQ8q+cj4DrLWqEg0FtGLRsw0kUqNIfFqx+pLPeKl74NwJvMfpwdaY78cyBsSG5DOnRA9
UzxY8LFoa5QzFV6dDMDpQFXxSKXzQ3rf0WRqTKAT8/ZqhGeBhEWzoEckOqFt3FSVZ1yaqu9o
VpF3DngdhiN7jYkwKzK0piYarigKCL/8aoQBCxRELsZNGc5z5eQ0oXcQsh2rdxxcG/JOSW/I
RS3qwBpyLr0OgSSto2FjFj9Bw1uDbw4P5zEjWmYPxN57s0M9Ip2xWSQOicgEB/JyOCphtIxt
5+3YAFHim7p5KxytgytZAgiPk7EMAdth64V6C21UflIttTbHjjjO+7qUE9oNhqHg174zywnL
G+Ew8WBVpOEjoyGxBohkF02lTB0nMq/nASiABe6tTDKdwhIDUp16fzsC1RIQhdORRWNBqmc0
0uRXje175ZzKvM4OYqN6NCMrp4JIz0ykCfGog11RTrtY1MEzL5x2kcLBWf+EduOMjFniCLes
jmQjEcMYae01JfKKJzHkWHbBVE+qIxLkTI/o64hmovSwLjZAhyLbQYDqgGc4H4kNBNFuWKQZ
icMktBXnYmxyOqEWOe9iK3pskc6MRKJuHYROvhNizj7M4tyO6OvgYcb1ZlyMIPyEJLi5roxK
DKqHLiINa1f26AHRDt9HRfHBma7cCJ8XO90S+ZnL3KpIXEHYLqMaVI77gSI+grcSik6Sjg9D
3AsMj942l9np7+RaMi55C4TGpnporx3RrQ4dQEGgc3faGHEvo/9C40iVYw5m4l3yKwYSeJOr
3OQ3Sel5lZ/57i8Rji+jvGclpnQIAuwvC+VK5METTYgazo0N66reWuRZj0bnrep+zIojSMMp
OJoeBjDoAlETPEWuyZieT7wRznQ5x3wAc/fGTyMjVTf5OwTVoufDoibR2YnctKbXuXX8qh9j
7dF8gS9rSBexiKqRA9pDKqAtKneKXV3MZ1u/v8RtA3SpxX2RoppV7xrcDBp2gDzHAxhnbvOU
2yRaN9tqc7G+Xm22XZGndd147wFL4NF5W18pJu32K/Fxew93x9AObW56IPjYJiGBKbSYxINW
j9siJTAxizE8s7kJmh/bJCRcOg2fkfyoLVICD9XXQrHMFimBuz7GmreCSXb0FilhJ1wad3Lp
4BYpwbN7lHwtgrDdfV4HbZFCQo3ZPjJbpAQfO8kPapHUCEaHa0k3L/GoewPDKSt6dqR5aScE
5MfQY0VPIvOpy8UxLHqCjDcvCHdZ4I4TPSBUkkhFcqInxjYHQi2aMHP87jwgtFpozXOiJ8bG
vSITwq3d+YQHiR4QUimtzO3OE2Js3EMtjFF3ROlxoqfwNFBNiciJnhgb91CLhPGxM/AOEj0g
NBqPv8yK3ti4h1osl+5wz+NETyPbwEXObQwVYmzcYy0aviE9VvSAUAMs47mNoULo8eY1Zm08
WvSA0FjMppAVvdz2/rYWC5J/vOhpgYlSVWJnvTvJ4NhjZKE6Q32+pjuqDnNQoz65k+rkRGrL
0LtwhyVvp0XxdnWN+SMpeBXEYh7MT09eYc3kCQGKn2cX8CMpHLkheD630BndDp9qzEJALZQz
oY9yTlyyymnx1001weSzl38tmk8Xbu/vzfX2om7cAQzNp7XLklpUmBJrcbn66HeMGwpDA7od
Btjm9om+4HHlzuWACjiTuyN0T0HIMduEtYBvtzNE9sa5pCMdAROsbWaUQRVsrAprlM6qeslH
qrDK9PZyv/voDg4/2eJBFreqUsNs0f7AeMPAamkSLX84yfhm7fZ1n8w3F3iI/+2ax6yxleCL
aHAY/wijpiLQxocVHvewWl2duHcEuTpfrMur2fb9KflECamq2YPnP/9W/vLi+S+/v/nprHz1
+t+f/vDyp4ePi9Wmbjan5DFSl1vMAljO6n+eyjaXEbSIdhQ5g4fNwcD5DfOJCcDfz1ZXvdEL
/Xg7u/D5mJ4Xt/69LaCaCTnZVOyEgDshT85ZQxdgWop/CW9GLYxEUJrP8KyKt5tZ1eZIcj8x
6XLT1DdX6/IdDP9m8z35JOdPyCexkLEYN3h8dPE3YGrTXK2vywoPSim3N3MoXmkoXotYWuLx
gli63Mw+ltv1xbK8WeJ3Ly82f8JYBaTTAJ0wQCdnkU5pPB3ecQz5XbZfEIoaUDKfuOCxrHbn
OuCoLleL0h+dDgX5DDvDK9aVxBTnLvNFWbp01CUeoL8tMRcefkcgmTHsRyVVIKHMpbkrtu+g
3h4Z1l8ja3pFLRjcUPS8uXbn84OUQFmmFBRWtQmlmXWpA4EzCOuuZihLa98j5Me8wcqbwBHG
hctU0Na+mN1cXkM5qrHD1NaxnNJcu3rff0BpCxkISlTp+EXxC8XiBs/3w+K9om2p2Fluhets
Wdar0LbgUGZehUKCgCvuCr0Di3LZlFexn7KusJ9UN7E41dR/DDw0BQ+6iW/PKHKrIrGwctkD
i/VqfXMJI7f8cDVzxUGslu5rVCgWlQ0UUrjUj1A9dKMj+x47jB0hsdtK0rbgJyXK7edteYU8
gE/9vSvo+x2Ka+ZSshXAiPY0llIJLFnPUNpIfEFtXbZtn8S3fPOfb549ffkSCpezBWig8t1H
dzAZvq5FRkZCQ102w7MXv2G+M86n5JNe0FkD7m6t6viKmPYQROIZyC8UpAVGKwxuSqwEGEy8
9f81tmhEsQDrtsD/LGn/w8K2WJjuQrcXtWovqlkhanfBugsoXBVmjv9noiCmIIuCyOJfhfm3
gtfYiwVp29EcbyvuKpsXxG2I1xonzd1EQlEz/Im56lXQGZwQjVmLzt6412fzKcaC9WJREbKY
GZzD/unnl0+fv2nzx4FsFK/PXjwvz57+x/RWqkMbvhvH3Ogg6K7QYudfPSvOftgjhS6ePWuf
prjv8hmA3Jz9CIWMiGS84Q10/oXL+hD/4TLPsx9f7DUTdDPHBJnYwx9+23+N4oyY2/1WC3hq
p8W8LeWfsiDZHNw2xLRnlOySYkl4Sm81g4w8o2yfEaFCDWrMVchTPaQi+VRmegiSjq/8qrk6
ebFcrKbxB4ZnUxbuzCSwlsvVcgpeEJjh/hMuiovtCsd17R+Q2/RdBahipySSd/cdtb/fo75Z
4ulcPpcgWE4Q+Ppic/0ZKPHEowbPRYPrm6VP6ZKoYHs5m4PerS5nF1e+iH90s9x5uEeHyYLA
yoP3CaPDafypBoBAXcoXn2IWtxu6QzaqVAULsM1T8CqIuyrX1Xoqhb+urmY9AksNRn1+ReeX
7PCbc8ne/3CL5YD44NkOF/tlwpM+57iSyiJZx+4HWNVDT9k9Qkr/qH13Bj4vRaqW5XDVYzrc
ebYwA7BA9H8s8cA234fuu2CXQU/vcP1vxedm27FBMCXQ//rx1VPOPPMUjF7sDcAaIzR2BKDB
FNNswiXmhZqC30EiM74Rz9xrrQHbAKBxpdZ4GNbyeioZ18o4fmGu53oqpPAtOfOFHLREKyTx
mWVKl1xlSn2hniBZgYU6UYLLIDKM+vcGK9e7j1L0/ofAQC4tpqAHHqF7gn3cfGj+8Qd6s6QI
4iYEdzlmHJ9BQT7CL/fg94e48uWRaa8ps49cQ3gjxCPO2mv1SHXlySP/IcgjJpX7Kylzfyno
Mf8DEb4EnnYIF6eF/6ShL0oRPJAL872q4hoRreOKC9K7qygeGsAn+CoUdL5g/jewJK/i78xl
0SbtT7+AeIBOe/Jq9QFZ/Hp5+TkWFYKBpFEtwHj64i236lgGZJ/F6oDXiTJWYjqdt+C4bh2C
aYoH3vUtPswubxpM8uPpHwa1KgzmCPuj+AdmPKuLArMr3eDF9flF7VkAjpXHExuAS+tzLyKl
jwlsP87WeFjfLo4pcEoitAC9QicYbwufORL+EX9T4GGVBmfmMazALLcYAROcaNahGNJDNICP
etCna0GCHsa0r74FjPqHFpSvBuxoW58Gk4F/tGEi1QLebYI1koxKzDjV1iz7Ncu2ZmrbmoUe
rfkNIzBSa8DA29iEkKprQhIVm4CbW00IS/w7aGaOakIZDEi3Teh+E67PBVjdth7Jx98C+V9d
X8bqvWy21Zt+9b6bVDHfTsEt963gGumB6s83zTrULajLGN3Wbft1e6Yw3B3avoRrRGpcTjBQ
9zYOFwnYFrMpdvh9Wq3AOmwQTZ8+e/3rm7dnT1/8+rb89fWvPz3u8ODpg+XN5eXDx9d4HQXx
MQydU5DmxzByTqNYAoxAYXx9c42prrv8XX/38ZAu/oCD4EGs6qEfcycfrkAtg9OPmvlxgUbj
BIbfVHPpHqCFcA+oQFP32Js+9wQwgMVCsRtgoaR7T8R7a4xTuL/DfXjszlPMNkpGGjUC0650
ojIWLJEYLGE7wZL/Lku8ffrs2evff307HDIJ7FbUWNS4/YAJyrcPmHQd+cpoieKWsHS0RAkw
z3w0WqKkMZhl7rBoidJQqzw+WqI0tEMOi5YoDYaDHhItUQazDh4VLVHWGOXzaa6b0rkuiIxn
GCjhdahZUwxPQ7FlAy/5eVnFomyBcFuSWNS4vI/Fh8U2lGowlgI/hEKMaaeJ3iN670pJ7JwV
sRDoPXMIcNdMWGdXjgXuAI84mtcd4N4sFlTXizmNOArMksHDkD1w34fJguD/WZ2EyYjCAQhg
YY5wHKBcMy+aWYvp4SHA8NqdHeVrwGVkEpfezE0bJGj/ywF3HnrEi6ZCnN+YAiDCnPQCDbYA
TMsChw1RFkNUe8C9AegiOWdHAPcIiw1gTgwhHgrcVb3oAfcE91GsMeGpA+77pG9e9EgxZSXB
SEAOuBuXRaIH3HdJEbjjUymbai4XjfZPbb+Hc2IZjz00mP2zBe6xQlItFjMzBty7sjVToUIA
AgS11T5wd6/cAfeu31xjDxG433rlWCEXLg3jHnC3QhMMD+eBu+Cgsoawe1fFl2H3QN1HU0KD
e34gdg8VHIndA13E7pz0sDsbw+6hghR25wnsDrjFxXcOxu6IY8XRUJSaFlIdDd8ZOQy+m6+D
72pCFHPW+JvAd0bBqpHj2QYOZ3yzL0PwmmgHXb8CwLNbAJ4lAbyaUIXGewTAQzHn+v1fAPBq
wphyahIBvM4BeIXTHBbd4jSAh98BvOAExyiAh6JKGUtyAF5h6J/gqpxhAA9lLHHrlo4A8GrC
CY6qbwfgoQVuMXvoncNrqFkD778lvIYmrHHpnL4ZvFYTARJE+DeC11C9tBSh1N3Da6gbVDIa
7TuH1wqDMhrnlb8YXvc47fG1kn18jS3AmBKj+Bok6UGvrj7ANkTvwmuh2Q7QZZKqXaCLyuZJ
c125vNmT+smmmvp0EgBgpoUX3LYHe/++q5v5zXnxl+/8gt6/FN+htWiTq+MLCaON/F8EzdAk
5mqW3xQ0qwnoaDe490Az/mQkrkrKgmaFGQe8dB4AmqG0Et2E9xGgGeiMJkwdAprVRBNB9QFL
DKAkI9rVeihoVph0R4ox0AzFNKHo7Y2CZigKatBh/GHQrCYAyaRbmjEMmqEQOERuPmkENENJ
XOPFjwbNCtfxue+QB81qAgDJRWf/X4FmPSHg9qBFv0vQrCfAN4vm745AM1QoGO5jvivQrHFl
ENmZ7f460Kxx+YlbJXdHoBkqNITigqg7As0aXCttcWHDLdAMP0jujP4ORBbgjt9GIqAZB2Bz
rORLYHOPegfCAMCUB8HmXgVHweYeXYcbcQvI4bC5V4GDfRzPRQ3wh7ZosI+bNa73dotjE7iZ
MZxy34OAEgbT8cBZK252QPIhuFka6zDht4fNeqLAudPyK9PGYT1KM/QrevCbemfqSPyNs4Ou
wC77tbXsS7ivv3ICPTF37uIDfejt2viauXMNlh2cCzYCvaGYpdT05s45bcH3q4e4O6xF33AD
zmkHv+FOsg5/40+8Q+CuXIvBH8CNbXE4XrMWi+M17fA43qQwOehIquLL4E4oxI+joFzj9gmN
zkUalMPvMPrZIbPqWJQxDAUMg3I9AfYRXLE/DMqhDAMX1RwFypFISM2/HSiHFiS6xCOg3ANc
gM4OFR4Eys2EUNLHhHePmKEJpdzSkG+CmA24OtotKr97xGxwWTah9BsgZqjaih5XaC8aAjee
3V0byPFRrrzh1GesXC62k+27rhnwcqwOU+roaIZmmK+CSt1KDmboGOPOu9nldagbRhTuCvli
0L+pWqzP+ljfgEkH3XwA1mfFg021A/EpEbsQ3+7OZTOhExC/a9Z4BTuw3QPa6+9v+PuLly+7
/Q33f7qcrXHT7/XFFYAT9Jvvv/9wdfrg/r0/m6ubE4BO19DeJ6MAEN2/d+ITN55AEbip1je4
VNv94K1N8Z3/Cw+wL5u6eLLagv0+b578eTNbwtt2f0+6eXxf9aQ6/y8gugIZYvB3e7Uu8G+b
Y7SBfpHHy+Ya7k/hD4Gf/B2mJd08hk/QPsVcjG00YVlhqdXJpsGHcB2S3l0oTkiznfeenfgQ
R+FCH/B8c1253dCnzgwic7BXzQbcC1Cu9cUKO3exXV/OPhdLTLgOfV/B+6w2BYrJ/Yf376NX
tKyRkxto/xT3PD8BIAm9fHezPC9RjgBjLy+qU3r/XtvubA237TWwfvMnYPGPM0C5bcJMqKu6
Wdeg3CdwUcIHQPsOrhL2ECD+KX7Ae8CLycXC7bcG0by3Bk5fv59A+++vtuenqyU8cu2eQMPb
1eIanYabdezM8uqi7Bhz6p7ev7darbfd9eVqVpfwKsCA96cMG1hhqKN7Ak3Wm3k9AQ9qtfEB
kFPj3gdEqZ5crs7Ly+ZDc3nabDb37/nkhSU8dQ//Z1ycoLyYn5NqW1JSCTQpNbEopxLiA5BI
sIEOqCkD8iWSOiTRsvREW6CBucC0zVlUzsWZBGwHJmfY5mTmlVYA00xFiT4wMwO79VycTv7+
IfGevo7urrb6Bdnp+mAl+pDkqAtqPQItSMsEpgwDXQMTAyNgl8JUPz05WddcHzp0ZGCYamKW
kmqalJhinmhhbGKUZpqUZGKYBqyJjUCL+I30y3JBhlbp4hp8wh5QoChOLUoDloWlJSn55XnA
AAUmJyWVamBei3aIrVVS0IWkLQWgGIQVrQUU5gIAWYRG3R5HAQA=

--=_5ca413c6.6e1RpLTvSig2RpCN6BdVKv6zspW2Szy5lyGUlDuJX7tL0uhQ
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="reproduce-quantal-vm-quantal-127:20190403093917:x86_64-randconfig-a0-04021905:5.1.0-rc2-00286-g15c8410:1"

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

--=_5ca413c6.6e1RpLTvSig2RpCN6BdVKv6zspW2Szy5lyGUlDuJX7tL0uhQ
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="config-5.1.0-rc2-00286-g15c8410"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 5.1.0-rc2 Kernel Configuration
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
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
CONFIG_KERNEL_LZO=y
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SWAP is not set
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
# CONFIG_POSIX_MQUEUE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_USELIB=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_SIM=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_IRQ_MATRIX_ALLOCATOR=y
CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
# CONFIG_GENERIC_IRQ_DEBUGFS is not set
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
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
CONFIG_CONTEXT_TRACKING=y
CONFIG_CONTEXT_TRACKING_FORCE=y
# CONFIG_NO_HZ is not set
# CONFIG_HIGH_RES_TIMERS is not set
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
# CONFIG_PSI is not set

#
# RCU Subsystem
#
CONFIG_PREEMPT_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
CONFIG_TREE_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_NEED_SEGCBLIST=y
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
# CONFIG_BLK_CGROUP is not set
# CONFIG_CGROUP_SCHED is not set
# CONFIG_CGROUP_PIDS is not set
# CONFIG_CGROUP_RDMA is not set
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_CGROUP_PERF is not set
# CONFIG_CGROUP_BPF is not set
# CONFIG_CGROUP_DEBUG is not set
# CONFIG_NAMESPACES is not set
CONFIG_CHECKPOINT_RESTORE=y
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
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
# CONFIG_SGETMASK_SYSCALL is not set
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_FHANDLE=y
CONFIG_POSIX_TIMERS=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_PCSPKR_PLATFORM=y
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
CONFIG_FUTEX_PI=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
# CONFIG_EVENTFD is not set
CONFIG_SHMEM=y
# CONFIG_AIO is not set
CONFIG_IO_URING=y
CONFIG_ADVISE_SYSCALLS=y
CONFIG_MEMBARRIER=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_BPF_SYSCALL=y
# CONFIG_USERFAULTFD is not set
CONFIG_ARCH_HAS_MEMBARRIER_SYNC_CORE=y
CONFIG_RSEQ=y
CONFIG_DEBUG_RSEQ=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y
CONFIG_PC104=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
# CONFIG_SLUB is not set
CONFIG_SLOB=y
# CONFIG_SLAB_MERGE_DEFAULT is not set
# CONFIG_PROFILING is not set
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
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_CC_HAS_SANE_STACKPROTECTOR=y

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
# CONFIG_SMP is not set
CONFIG_X86_FEATURE_NAMES=y
# CONFIG_X86_X2APIC is not set
CONFIG_X86_MPPARSE=y
CONFIG_GOLDFISH=y
CONFIG_RETPOLINE=y
# CONFIG_X86_CPU_RESCTRL is not set
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_AMD_PLATFORM_DEVICE=y
# CONFIG_IOSF_MBI is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_XEN=y
# CONFIG_XEN_PV is not set
CONFIG_XEN_PVHVM=y
CONFIG_XEN_SAVE_RESTORE=y
CONFIG_XEN_DEBUG_FS=y
# CONFIG_XEN_PVH is not set
CONFIG_KVM_GUEST=y
# CONFIG_PVH is not set
# CONFIG_KVM_DEBUG_FS is not set
CONFIG_PARAVIRT_TIME_ACCOUNTING=y
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_JAILHOUSE_GUEST is not set
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
CONFIG_PROCESSOR_SELECT=y
CONFIG_CPU_SUP_INTEL=y
# CONFIG_CPU_SUP_AMD is not set
# CONFIG_CPU_SUP_HYGON is not set
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
# CONFIG_DMI is not set
# CONFIG_CALGARY_IOMMU is not set
CONFIG_NR_CPUS_RANGE_BEGIN=1
CONFIG_NR_CPUS_RANGE_END=1
CONFIG_NR_CPUS_DEFAULT=1
CONFIG_NR_CPUS=1
CONFIG_UP_LATE_INIT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
# CONFIG_X86_MCE is not set

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
CONFIG_PERF_EVENTS_INTEL_RAPL=y
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX64=y
CONFIG_X86_VSYSCALL_EMULATION=y
# CONFIG_I8K is not set
# CONFIG_MICROCODE is not set
CONFIG_X86_MSR=y
# CONFIG_X86_CPUID is not set
# CONFIG_X86_5LEVEL is not set
CONFIG_X86_DIRECT_GBPAGES=y
CONFIG_X86_CPA_STATISTICS=y
CONFIG_ARCH_HAS_MEM_ENCRYPT=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
# CONFIG_X86_PMEM_LEGACY is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
# CONFIG_ARCH_RANDOM is not set
# CONFIG_X86_SMAP is not set
# CONFIG_X86_INTEL_UMIP is not set
# CONFIG_X86_INTEL_MPX is not set
CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS=y
CONFIG_EFI=y
CONFIG_EFI_STUB=y
CONFIG_EFI_MIXED=y
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_KEXEC=y
CONFIG_KEXEC_FILE=y
CONFIG_ARCH_HAS_KEXEC_PURGATORY=y
# CONFIG_KEXEC_VERIFY_SIG is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_RANDOMIZE_BASE=y
CONFIG_X86_NEED_RELOCS=y
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_DYNAMIC_MEMORY_LAYOUT=y
CONFIG_RANDOMIZE_MEMORY=y
CONFIG_RANDOMIZE_MEMORY_PHYSICAL_PADDING=0x0
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_HAVE_LIVEPATCH=y
CONFIG_ARCH_HAS_ADD_PAGES=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_SUSPEND_SKIP_SYNC is not set
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_PM_SLEEP=y
CONFIG_PM_AUTOSLEEP=y
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_PM_CLK=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
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
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
CONFIG_ACPI_EC_DEBUGFS=y
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
# CONFIG_ACPI_FAN is not set
# CONFIG_ACPI_TAD is not set
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_TABLE_UPGRADE is not set
CONFIG_ACPI_DEBUG=y
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_IOAPIC=y
CONFIG_ACPI_SBS=y
# CONFIG_ACPI_HED is not set
CONFIG_ACPI_CUSTOM_METHOD=y
# CONFIG_ACPI_BGRT is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
# CONFIG_ACPI_NFIT is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
CONFIG_DPTF_POWER=y
CONFIG_ACPI_WATCHDOG=y
CONFIG_PMIC_OPREGION=y
# CONFIG_CHT_WC_PMIC_OPREGION is not set
# CONFIG_CHT_DC_TI_PMIC_OPREGION is not set
CONFIG_ACPI_CONFIGFS=y
CONFIG_X86_PM_TIMER=y
CONFIG_SFI=y

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
# CONFIG_CPU_IDLE_GOV_MENU is not set
CONFIG_CPU_IDLE_GOV_TEO=y
CONFIG_INTEL_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_XEN=y
CONFIG_MMCONF_FAM10H=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_ISA_BUS=y
# CONFIG_ISA_DMA_API is not set
# CONFIG_X86_SYSFB is not set

#
# Binary Emulations
#
# CONFIG_IA32_EMULATION is not set
CONFIG_X86_X32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_HAVE_GENERIC_GUP=y

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
# CONFIG_FIRMWARE_MEMMAP is not set
CONFIG_ISCSI_IBFT_FIND=y
CONFIG_ISCSI_IBFT=y
CONFIG_FW_CFG_SYSFS=y
# CONFIG_FW_CFG_SYSFS_CMDLINE is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# EFI (Extensible Firmware Interface) Support
#
# CONFIG_EFI_VARS is not set
CONFIG_EFI_ESRT=y
CONFIG_EFI_RUNTIME_MAP=y
CONFIG_EFI_FAKE_MEMMAP=y
CONFIG_EFI_MAX_FAKE_MEM=8
CONFIG_EFI_RUNTIME_WRAPPERS=y
CONFIG_EFI_CAPSULE_LOADER=y
CONFIG_EFI_TEST=y
CONFIG_APPLE_PROPERTIES=y
# CONFIG_RESET_ATTACK_MITIGATION is not set
CONFIG_EFI_DEV_PATH_PARSER=y
CONFIG_EFI_EARLYCON=y

#
# Tegra firmware driver
#
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set

#
# General architecture-dependent options
#
CONFIG_CRASH_CORE=y
CONFIG_KEXEC_CORE=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
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
CONFIG_HAVE_RCU_TABLE_INVALIDATE=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
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
CONFIG_COMPAT_32BIT_TIME=y
CONFIG_HAVE_ARCH_VMAP_STACK=y
CONFIG_VMAP_STACK=y
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
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
CONFIG_GCC_PLUGINS=y
# CONFIG_GCC_PLUGIN_CYC_COMPLEXITY is not set
CONFIG_GCC_PLUGIN_LATENT_ENTROPY=y
# CONFIG_GCC_PLUGIN_STRUCTLEAK is not set
CONFIG_GCC_PLUGIN_RANDSTRUCT=y
# CONFIG_GCC_PLUGIN_RANDSTRUCT_PERFORMANCE is not set
CONFIG_GCC_PLUGIN_STACKLEAK=y
CONFIG_STACKLEAK_TRACK_MIN_SIZE=100
CONFIG_STACKLEAK_METRICS=y
# CONFIG_STACKLEAK_RUNTIME_DISABLE is not set
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
# CONFIG_MODULES is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
CONFIG_BLK_SCSI_REQUEST=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
CONFIG_BLK_DEV_ZONED=y
# CONFIG_BLK_CMDLINE_PARSER is not set
# CONFIG_BLK_WBT is not set
CONFIG_BLK_DEBUG_FS=y
CONFIG_BLK_DEBUG_FS_ZONED=y
CONFIG_BLK_SED_OPAL=y

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
CONFIG_AIX_PARTITION=y
# CONFIG_OSF_PARTITION is not set
# CONFIG_AMIGA_PARTITION is not set
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
# CONFIG_BSD_DISKLABEL is not set
CONFIG_MINIX_SUBPARTITION=y
CONFIG_SOLARIS_X86_PARTITION=y
CONFIG_UNIXWARE_DISKLABEL=y
# CONFIG_LDM_PARTITION is not set
# CONFIG_SGI_PARTITION is not set
# CONFIG_ULTRIX_PARTITION is not set
# CONFIG_SUN_PARTITION is not set
# CONFIG_KARMA_PARTITION is not set
CONFIG_EFI_PARTITION=y
CONFIG_SYSV68_PARTITION=y
# CONFIG_CMDLINE_PARTITION is not set
CONFIG_BLOCK_COMPAT=y
CONFIG_BLK_MQ_PCI=y
CONFIG_BLK_MQ_VIRTIO=y
CONFIG_BLK_PM=y

#
# IO Schedulers
#
CONFIG_MQ_IOSCHED_DEADLINE=y
# CONFIG_MQ_IOSCHED_KYBER is not set
CONFIG_IOSCHED_BFQ=y
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
# CONFIG_BINFMT_MISC is not set
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
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_ARCH_WANTS_THP_SWAP=y
CONFIG_NEED_PER_CPU_KM=y
CONFIG_CLEANCACHE=y
CONFIG_CMA=y
# CONFIG_CMA_DEBUG is not set
CONFIG_CMA_DEBUGFS=y
CONFIG_CMA_AREAS=7
# CONFIG_MEM_SOFT_DIRTY is not set
CONFIG_ZPOOL=y
CONFIG_ZBUD=y
CONFIG_Z3FOLD=y
CONFIG_ZSMALLOC=y
# CONFIG_PGTABLE_MAPPING is not set
# CONFIG_ZSMALLOC_STAT is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
# CONFIG_IDLE_PAGE_TRACKING is not set
CONFIG_ARCH_HAS_ZONE_DEVICE=y
CONFIG_FRAME_VECTOR=y
CONFIG_ARCH_USES_HIGH_VMA_FLAGS=y
CONFIG_ARCH_HAS_PKEYS=y
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
CONFIG_TLS=y
# CONFIG_TLS_DEVICE is not set
CONFIG_XFRM=y
CONFIG_XFRM_OFFLOAD=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
CONFIG_XFRM_INTERFACE=y
# CONFIG_XFRM_SUB_POLICY is not set
CONFIG_XFRM_MIGRATE=y
CONFIG_XFRM_STATISTICS=y
CONFIG_XFRM_IPCOMP=y
# CONFIG_NET_KEY is not set
CONFIG_XDP_SOCKETS=y
# CONFIG_XDP_SOCKETS_DIAG is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_IP_PNP_BOOTP=y
CONFIG_IP_PNP_RARP=y
CONFIG_NET_IPIP=y
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
CONFIG_IP_MROUTE_COMMON=y
# CONFIG_IP_MROUTE is not set
CONFIG_SYN_COOKIES=y
# CONFIG_NET_IPVTI is not set
CONFIG_NET_UDP_TUNNEL=y
CONFIG_NET_FOU=y
CONFIG_NET_FOU_IP_TUNNELS=y
# CONFIG_INET_AH is not set
CONFIG_INET_ESP=y
CONFIG_INET_ESP_OFFLOAD=y
# CONFIG_INET_IPCOMP is not set
CONFIG_INET_TUNNEL=y
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
CONFIG_INET_XFRM_MODE_TUNNEL=y
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_INET_UDP_DIAG is not set
# CONFIG_INET_RAW_DIAG is not set
CONFIG_INET_DIAG_DESTROY=y
CONFIG_TCP_CONG_ADVANCED=y
# CONFIG_TCP_CONG_BIC is not set
CONFIG_TCP_CONG_CUBIC=y
# CONFIG_TCP_CONG_WESTWOOD is not set
CONFIG_TCP_CONG_HTCP=y
# CONFIG_TCP_CONG_HSTCP is not set
CONFIG_TCP_CONG_HYBLA=y
CONFIG_TCP_CONG_VEGAS=y
CONFIG_TCP_CONG_NV=y
# CONFIG_TCP_CONG_SCALABLE is not set
CONFIG_TCP_CONG_LP=y
CONFIG_TCP_CONG_VENO=y
# CONFIG_TCP_CONG_YEAH is not set
# CONFIG_TCP_CONG_ILLINOIS is not set
CONFIG_TCP_CONG_DCTCP=y
CONFIG_TCP_CONG_CDG=y
CONFIG_TCP_CONG_BBR=y
# CONFIG_DEFAULT_CUBIC is not set
# CONFIG_DEFAULT_HTCP is not set
CONFIG_DEFAULT_HYBLA=y
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_VENO is not set
# CONFIG_DEFAULT_DCTCP is not set
# CONFIG_DEFAULT_CDG is not set
# CONFIG_DEFAULT_BBR is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="hybla"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
CONFIG_IPV6_ROUTER_PREF=y
CONFIG_IPV6_ROUTE_INFO=y
CONFIG_IPV6_OPTIMISTIC_DAD=y
# CONFIG_INET6_AH is not set
# CONFIG_INET6_ESP is not set
CONFIG_INET6_IPCOMP=y
CONFIG_IPV6_MIP6=y
CONFIG_IPV6_ILA=y
CONFIG_INET6_XFRM_TUNNEL=y
CONFIG_INET6_TUNNEL=y
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
CONFIG_INET6_XFRM_MODE_BEET=y
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=y
# CONFIG_IPV6_VTI is not set
CONFIG_IPV6_SIT=y
CONFIG_IPV6_SIT_6RD=y
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=y
CONFIG_IPV6_FOU=y
CONFIG_IPV6_FOU_TUNNEL=y
CONFIG_IPV6_MULTIPLE_TABLES=y
# CONFIG_IPV6_SUBTREES is not set
CONFIG_IPV6_MROUTE=y
CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y
# CONFIG_IPV6_PIMSM_V2 is not set
# CONFIG_IPV6_SEG6_LWTUNNEL is not set
# CONFIG_IPV6_SEG6_HMAC is not set
CONFIG_NETWORK_SECMARK=y
CONFIG_NET_PTP_CLASSIFY=y
CONFIG_NETWORK_PHY_TIMESTAMPING=y
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_ADVANCED is not set

#
# Core Netfilter Configuration
#
# CONFIG_NETFILTER_INGRESS is not set
CONFIG_NETFILTER_NETLINK=y
CONFIG_NETFILTER_FAMILY_BRIDGE=y
CONFIG_NETFILTER_FAMILY_ARP=y
CONFIG_NETFILTER_NETLINK_LOG=y
# CONFIG_NF_CONNTRACK is not set
CONFIG_NF_LOG_COMMON=y
# CONFIG_NF_LOG_NETDEV is not set
CONFIG_NF_TABLES=y
CONFIG_NF_TABLES_SET=y
CONFIG_NF_TABLES_INET=y
# CONFIG_NF_TABLES_NETDEV is not set
CONFIG_NFT_NUMGEN=y
# CONFIG_NFT_COUNTER is not set
# CONFIG_NFT_LOG is not set
CONFIG_NFT_LIMIT=y
# CONFIG_NFT_TUNNEL is not set
CONFIG_NFT_OBJREF=y
# CONFIG_NFT_QUOTA is not set
CONFIG_NFT_REJECT=y
CONFIG_NFT_REJECT_INET=y
# CONFIG_NFT_COMPAT is not set
CONFIG_NFT_HASH=y
CONFIG_NFT_FIB=y
CONFIG_NFT_FIB_INET=y
CONFIG_NFT_XFRM=y
CONFIG_NFT_SOCKET=y
CONFIG_NFT_TPROXY=y
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=y

#
# Xtables targets
#
# CONFIG_NETFILTER_XT_TARGET_LOG is not set
CONFIG_NETFILTER_XT_TARGET_NFLOG=y
# CONFIG_NETFILTER_XT_TARGET_SECMARK is not set
# CONFIG_NETFILTER_XT_TARGET_TCPMSS is not set

#
# Xtables matches
#
# CONFIG_NETFILTER_XT_MATCH_ADDRTYPE is not set
CONFIG_NETFILTER_XT_MATCH_POLICY=y
CONFIG_IP_SET=y
CONFIG_IP_SET_MAX=256
CONFIG_IP_SET_BITMAP_IP=y
CONFIG_IP_SET_BITMAP_IPMAC=y
CONFIG_IP_SET_BITMAP_PORT=y
# CONFIG_IP_SET_HASH_IP is not set
CONFIG_IP_SET_HASH_IPMARK=y
CONFIG_IP_SET_HASH_IPPORT=y
CONFIG_IP_SET_HASH_IPPORTIP=y
# CONFIG_IP_SET_HASH_IPPORTNET is not set
CONFIG_IP_SET_HASH_IPMAC=y
CONFIG_IP_SET_HASH_MAC=y
CONFIG_IP_SET_HASH_NETPORTNET=y
# CONFIG_IP_SET_HASH_NET is not set
CONFIG_IP_SET_HASH_NETNET=y
CONFIG_IP_SET_HASH_NETPORT=y
# CONFIG_IP_SET_HASH_NETIFACE is not set
CONFIG_IP_SET_LIST_SET=y
CONFIG_IP_VS=y
# CONFIG_IP_VS_IPV6 is not set
CONFIG_IP_VS_DEBUG=y
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
# CONFIG_IP_VS_PROTO_UDP is not set
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y
# CONFIG_IP_VS_PROTO_SCTP is not set

#
# IPVS scheduler
#
# CONFIG_IP_VS_RR is not set
CONFIG_IP_VS_WRR=y
CONFIG_IP_VS_LC=y
# CONFIG_IP_VS_WLC is not set
CONFIG_IP_VS_FO=y
CONFIG_IP_VS_OVF=y
CONFIG_IP_VS_LBLC=y
# CONFIG_IP_VS_LBLCR is not set
CONFIG_IP_VS_DH=y
# CONFIG_IP_VS_SH is not set
CONFIG_IP_VS_MH=y
CONFIG_IP_VS_SED=y
CONFIG_IP_VS_NQ=y

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

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
CONFIG_NF_SOCKET_IPV4=y
CONFIG_NF_TPROXY_IPV4=y
CONFIG_NF_TABLES_IPV4=y
CONFIG_NFT_CHAIN_ROUTE_IPV4=y
CONFIG_NFT_REJECT_IPV4=y
# CONFIG_NFT_DUP_IPV4 is not set
CONFIG_NFT_FIB_IPV4=y
CONFIG_NF_TABLES_ARP=y
# CONFIG_NF_DUP_IPV4 is not set
CONFIG_NF_LOG_ARP=y
# CONFIG_NF_LOG_IPV4 is not set
CONFIG_NF_REJECT_IPV4=y
CONFIG_IP_NF_IPTABLES=y
# CONFIG_IP_NF_FILTER is not set
CONFIG_IP_NF_MANGLE=y
CONFIG_IP_NF_RAW=y

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_SOCKET_IPV6=y
CONFIG_NF_TPROXY_IPV6=y
CONFIG_NF_TABLES_IPV6=y
CONFIG_NFT_CHAIN_ROUTE_IPV6=y
CONFIG_NFT_REJECT_IPV6=y
CONFIG_NFT_DUP_IPV6=y
CONFIG_NFT_FIB_IPV6=y
CONFIG_NF_DUP_IPV6=y
CONFIG_NF_REJECT_IPV6=y
# CONFIG_NF_LOG_IPV6 is not set
# CONFIG_IP6_NF_IPTABLES is not set
CONFIG_NF_DEFRAG_IPV6=y
CONFIG_NF_TABLES_BRIDGE=y
CONFIG_NFT_BRIDGE_REJECT=y
CONFIG_NF_LOG_BRIDGE=y
CONFIG_BRIDGE_NF_EBTABLES=y
CONFIG_BRIDGE_EBT_BROUTE=y
CONFIG_BRIDGE_EBT_T_FILTER=y
CONFIG_BRIDGE_EBT_T_NAT=y
# CONFIG_BRIDGE_EBT_802_3 is not set
# CONFIG_BRIDGE_EBT_AMONG is not set
CONFIG_BRIDGE_EBT_ARP=y
CONFIG_BRIDGE_EBT_IP=y
CONFIG_BRIDGE_EBT_IP6=y
# CONFIG_BRIDGE_EBT_LIMIT is not set
CONFIG_BRIDGE_EBT_MARK=y
CONFIG_BRIDGE_EBT_PKTTYPE=y
CONFIG_BRIDGE_EBT_STP=y
# CONFIG_BRIDGE_EBT_VLAN is not set
# CONFIG_BRIDGE_EBT_ARPREPLY is not set
CONFIG_BRIDGE_EBT_DNAT=y
CONFIG_BRIDGE_EBT_MARK_T=y
# CONFIG_BRIDGE_EBT_REDIRECT is not set
CONFIG_BRIDGE_EBT_SNAT=y
# CONFIG_BRIDGE_EBT_LOG is not set
CONFIG_BRIDGE_EBT_NFLOG=y
# CONFIG_BPFILTER is not set
CONFIG_IP_DCCP=y
CONFIG_INET_DCCP_DIAG=y

#
# DCCP CCIDs Configuration
#
CONFIG_IP_DCCP_CCID2_DEBUG=y
# CONFIG_IP_DCCP_CCID3 is not set

#
# DCCP Kernel Hacking
#
CONFIG_IP_DCCP_DEBUG=y
CONFIG_IP_SCTP=y
# CONFIG_SCTP_DBG_OBJCNT is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
CONFIG_SCTP_COOKIE_HMAC_MD5=y
CONFIG_SCTP_COOKIE_HMAC_SHA1=y
CONFIG_INET_SCTP_DIAG=y
# CONFIG_RDS is not set
CONFIG_TIPC=y
# CONFIG_TIPC_MEDIA_UDP is not set
CONFIG_TIPC_DIAG=y
CONFIG_ATM=y
CONFIG_ATM_CLIP=y
CONFIG_ATM_CLIP_NO_ICMP=y
CONFIG_ATM_LANE=y
CONFIG_ATM_MPOA=y
CONFIG_ATM_BR2684=y
# CONFIG_ATM_BR2684_IPFILTER is not set
# CONFIG_L2TP is not set
CONFIG_STP=y
CONFIG_BRIDGE=y
CONFIG_BRIDGE_IGMP_SNOOPING=y
# CONFIG_BRIDGE_VLAN_FILTERING is not set
CONFIG_HAVE_NET_DSA=y
# CONFIG_NET_DSA is not set
CONFIG_VLAN_8021Q=y
# CONFIG_VLAN_8021Q_GVRP is not set
# CONFIG_VLAN_8021Q_MVRP is not set
# CONFIG_DECNET is not set
CONFIG_LLC=y
CONFIG_LLC2=y
# CONFIG_ATALK is not set
CONFIG_X25=y
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
CONFIG_6LOWPAN=y
# CONFIG_6LOWPAN_DEBUGFS is not set
CONFIG_6LOWPAN_NHC=y
# CONFIG_6LOWPAN_NHC_DEST is not set
CONFIG_6LOWPAN_NHC_FRAGMENT=y
CONFIG_6LOWPAN_NHC_HOP=y
CONFIG_6LOWPAN_NHC_IPV6=y
# CONFIG_6LOWPAN_NHC_MOBILITY is not set
CONFIG_6LOWPAN_NHC_ROUTING=y
CONFIG_6LOWPAN_NHC_UDP=y
# CONFIG_6LOWPAN_GHC_EXT_HDR_HOP is not set
CONFIG_6LOWPAN_GHC_UDP=y
CONFIG_6LOWPAN_GHC_ICMPV6=y
CONFIG_6LOWPAN_GHC_EXT_HDR_DEST=y
CONFIG_6LOWPAN_GHC_EXT_HDR_FRAG=y
CONFIG_6LOWPAN_GHC_EXT_HDR_ROUTE=y
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
CONFIG_VSOCKETS=y
# CONFIG_VSOCKETS_DIAG is not set
CONFIG_VIRTIO_VSOCKETS=y
CONFIG_VIRTIO_VSOCKETS_COMMON=y
CONFIG_HYPERV_VSOCKETS=y
# CONFIG_NETLINK_DIAG is not set
CONFIG_MPLS=y
# CONFIG_NET_MPLS_GSO is not set
CONFIG_MPLS_ROUTING=y
# CONFIG_MPLS_IPTUNNEL is not set
# CONFIG_NET_NSH is not set
CONFIG_HSR=y
# CONFIG_NET_SWITCHDEV is not set
CONFIG_NET_L3_MASTER_DEV=y
CONFIG_NET_NCSI=y
CONFIG_NCSI_OEM_CMD_GET_MAC=y
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
CONFIG_NET_DROP_MONITOR=y
# CONFIG_HAMRADIO is not set
CONFIG_CAN=y
# CONFIG_CAN_RAW is not set
CONFIG_CAN_BCM=y
CONFIG_CAN_GW=y

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
CONFIG_CAN_VXCAN=y
# CONFIG_CAN_SLCAN is not set
# CONFIG_CAN_DEV is not set
# CONFIG_CAN_DEBUG_DEVICES is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
CONFIG_AF_KCM=y
CONFIG_STREAM_PARSER=y
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
CONFIG_WIMAX=y
CONFIG_WIMAX_DEBUG_LEVEL=8
CONFIG_RFKILL=y
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
# CONFIG_RFKILL_GPIO is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_XEN is not set
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
CONFIG_CEPH_LIB=y
# CONFIG_CEPH_LIB_PRETTYDEBUG is not set
CONFIG_CEPH_LIB_USE_DNS_RESOLVER=y
CONFIG_NFC=y
CONFIG_NFC_DIGITAL=y
CONFIG_NFC_NCI=y
CONFIG_NFC_NCI_SPI=y
# CONFIG_NFC_NCI_UART is not set
CONFIG_NFC_HCI=y
CONFIG_NFC_SHDLC=y

#
# Near Field Communication (NFC) devices
#
CONFIG_NFC_TRF7970A=y
CONFIG_NFC_SIM=y
CONFIG_NFC_PORT100=y
CONFIG_NFC_FDP=y
CONFIG_NFC_FDP_I2C=y
# CONFIG_NFC_PN544_I2C is not set
CONFIG_NFC_PN533=y
# CONFIG_NFC_PN533_USB is not set
CONFIG_NFC_PN533_I2C=y
CONFIG_NFC_MICROREAD=y
CONFIG_NFC_MICROREAD_I2C=y
# CONFIG_NFC_MRVL_USB is not set
CONFIG_NFC_ST21NFCA=y
CONFIG_NFC_ST21NFCA_I2C=y
CONFIG_NFC_ST_NCI=y
# CONFIG_NFC_ST_NCI_I2C is not set
CONFIG_NFC_ST_NCI_SPI=y
CONFIG_NFC_NXP_NCI=y
# CONFIG_NFC_NXP_NCI_I2C is not set
# CONFIG_NFC_S3FWRN5_I2C is not set
# CONFIG_NFC_ST95HF is not set
CONFIG_PSAMPLE=y
CONFIG_NET_IFE=y
CONFIG_LWTUNNEL=y
# CONFIG_LWTUNNEL_BPF is not set
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
CONFIG_NET_SOCK_MSG=y
CONFIG_NET_DEVLINK=y
CONFIG_FAILOVER=y
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#
CONFIG_HAVE_EISA=y
CONFIG_EISA=y
# CONFIG_EISA_VLB_PRIMING is not set
CONFIG_EISA_PCI_EISA=y
CONFIG_EISA_VIRTUAL_ROOT=y
CONFIG_EISA_NAMES=y
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
CONFIG_PCI_LABEL=y
# CONFIG_HOTPLUG_PCI is not set

#
# PCI controller drivers
#

#
# Cadence PCIe controllers support
#

#
# DesignWare PCI Core Support
#

#
# PCI Endpoint
#
# CONFIG_PCI_ENDPOINT is not set

#
# PCI switch controller drivers
#
# CONFIG_PCI_SW_SWITCHTEC is not set
CONFIG_PCCARD=y
# CONFIG_PCMCIA is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
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
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
CONFIG_WANT_DEV_COREDUMP=y
CONFIG_ALLOW_DEV_COREDUMP=y
CONFIG_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
CONFIG_SYS_HYPERVISOR=y
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_GENERIC_CPU_VULNERABILITIES=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SLIMBUS=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_W1=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_REGMAP_SCCB=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_DMA_FENCE_TRACE=y

#
# Bus devices
#
CONFIG_CONNECTOR=y
# CONFIG_PROC_EVENTS is not set
CONFIG_GNSS=y
CONFIG_GNSS_SERIAL=y
CONFIG_GNSS_MTK_SERIAL=y
CONFIG_GNSS_SIRF_SERIAL=y
# CONFIG_GNSS_UBX_SERIAL is not set
CONFIG_MTD=y
CONFIG_MTD_CMDLINE_PARTS=y
# CONFIG_MTD_AR7_PARTS is not set

#
# Partition parsers
#
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED=y
# CONFIG_MTD_REDBOOT_PARTS_READONLY is not set

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=y
CONFIG_FTL=y
# CONFIG_NFTL is not set
CONFIG_INFTL=y
CONFIG_RFD_FTL=y
# CONFIG_SSFDC is not set
CONFIG_SM_FTL=y
CONFIG_MTD_OOPS=y
CONFIG_MTD_PARTITIONED_MASTER=y

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
CONFIG_MTD_CFI_ADV_OPTIONS=y
# CONFIG_MTD_CFI_NOSWAP is not set
# CONFIG_MTD_CFI_BE_BYTE_SWAP is not set
CONFIG_MTD_CFI_LE_BYTE_SWAP=y
CONFIG_MTD_CFI_GEOMETRY=y
# CONFIG_MTD_MAP_BANK_WIDTH_1 is not set
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
CONFIG_MTD_MAP_BANK_WIDTH_16=y
CONFIG_MTD_MAP_BANK_WIDTH_32=y
# CONFIG_MTD_CFI_I1 is not set
# CONFIG_MTD_CFI_I2 is not set
# CONFIG_MTD_CFI_I4 is not set
CONFIG_MTD_CFI_I8=y
CONFIG_MTD_OTP=y
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
CONFIG_MTD_CFI_STAA=y
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
CONFIG_MTD_ROM=y
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
# CONFIG_MTD_PHYSMAP is not set
# CONFIG_MTD_SBC_GXX is not set
CONFIG_MTD_AMD76XROM=y
# CONFIG_MTD_ICHXROM is not set
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
# CONFIG_MTD_L440GX is not set
# CONFIG_MTD_PCI is not set
# CONFIG_MTD_INTEL_VR_NOR is not set
CONFIG_MTD_PLATRAM=y

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
CONFIG_MTD_DATAFLASH=y
# CONFIG_MTD_DATAFLASH_WRITE_VERIFY is not set
CONFIG_MTD_DATAFLASH_OTP=y
CONFIG_MTD_M25P80=y
# CONFIG_MTD_MCHP23K256 is not set
CONFIG_MTD_SST25L=y
CONFIG_MTD_SLRAM=y
# CONFIG_MTD_PHRAM is not set
# CONFIG_MTD_MTDRAM is not set
CONFIG_MTD_BLOCK2MTD=y

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
CONFIG_MTD_ONENAND=y
CONFIG_MTD_ONENAND_VERIFY_WRITE=y
# CONFIG_MTD_ONENAND_GENERIC is not set
# CONFIG_MTD_ONENAND_OTP is not set
# CONFIG_MTD_ONENAND_2X_PROGRAM is not set
CONFIG_MTD_NAND_ECC=y
CONFIG_MTD_NAND_ECC_SMC=y
CONFIG_MTD_NAND=y
# CONFIG_MTD_NAND_ECC_BCH is not set
# CONFIG_MTD_NAND_DENALI_PCI is not set
# CONFIG_MTD_NAND_GPIO is not set
# CONFIG_MTD_NAND_RICOH is not set
CONFIG_MTD_NAND_DISKONCHIP=y
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED=y
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
CONFIG_MTD_NAND_DISKONCHIP_PROBE_HIGH=y
CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE=y
# CONFIG_MTD_NAND_CAFE is not set
CONFIG_MTD_NAND_NANDSIM=y
# CONFIG_MTD_NAND_PLATFORM is not set
# CONFIG_MTD_SPI_NAND is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
# CONFIG_MTD_LPDDR is not set
CONFIG_MTD_SPI_NOR=y
# CONFIG_MTD_SPI_NOR_USE_4K_SECTORS is not set
# CONFIG_SPI_MTK_QUADSPI is not set
CONFIG_SPI_INTEL_SPI=y
# CONFIG_SPI_INTEL_SPI_PCI is not set
CONFIG_SPI_INTEL_SPI_PLATFORM=y
# CONFIG_MTD_UBI is not set
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
# CONFIG_PARPORT_SERIAL is not set
CONFIG_PARPORT_PC_FIFO=y
# CONFIG_PARPORT_PC_SUPERIO is not set
# CONFIG_PARPORT_AX88796 is not set
# CONFIG_PARPORT_1284 is not set
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
# CONFIG_PARIDE is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_ZRAM is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_LOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SKD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
CONFIG_XEN_BLKDEV_FRONTEND=y
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_RBD is not set
# CONFIG_BLK_DEV_RSXX is not set

#
# NVME Support
#
CONFIG_NVME_CORE=y
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_NVME_MULTIPATH is not set
CONFIG_NVME_FABRICS=y
# CONFIG_NVME_FC is not set
CONFIG_NVME_TARGET=y
CONFIG_NVME_TARGET_LOOP=y
CONFIG_NVME_TARGET_FC=y
CONFIG_NVME_TARGET_TCP=y

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
CONFIG_AD525X_DPOT_SPI=y
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_ICS932S401 is not set
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
CONFIG_ISL29020=y
# CONFIG_SENSORS_TSL2550 is not set
CONFIG_SENSORS_BH1770=y
# CONFIG_SENSORS_APDS990X is not set
CONFIG_HMC6352=y
CONFIG_DS1682=y
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_LATTICE_ECP3_CONFIG=y
CONFIG_SRAM=y
# CONFIG_PCI_ENDPOINT_TEST is not set
CONFIG_PVPANIC=y
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_AT25=y
CONFIG_EEPROM_LEGACY=y
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
# CONFIG_EEPROM_93XX46 is not set
CONFIG_EEPROM_IDT_89HPESX=y
# CONFIG_EEPROM_EE1004 is not set
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=y
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
# CONFIG_VOP is not set
# CONFIG_GENWQE is not set
# CONFIG_ECHO is not set
# CONFIG_MISC_ALCOR_PCI is not set
# CONFIG_MISC_RTSX_PCI is not set
# CONFIG_MISC_RTSX_USB is not set
# CONFIG_HABANA_AI is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
# CONFIG_BLK_DEV_IDE_SATA is not set
CONFIG_IDE_GD=y
CONFIG_IDE_GD_ATA=y
CONFIG_IDE_GD_ATAPI=y
# CONFIG_BLK_DEV_DELKIN is not set
# CONFIG_BLK_DEV_IDECD is not set
CONFIG_BLK_DEV_IDETAPE=y
# CONFIG_BLK_DEV_IDEACPI is not set
# CONFIG_IDE_TASK_IOCTL is not set
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
CONFIG_BLK_DEV_PLATFORM=y
CONFIG_BLK_DEV_CMD640=y
# CONFIG_BLK_DEV_CMD640_ENHANCED is not set
CONFIG_BLK_DEV_IDEPNP=y

#
# PCI IDE chipsets support
#
# CONFIG_BLK_DEV_GENERIC is not set
# CONFIG_BLK_DEV_OPTI621 is not set
# CONFIG_BLK_DEV_RZ1000 is not set
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
# CONFIG_BLK_DEV_ATIIXP is not set
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_HPT366 is not set
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_PIIX is not set
# CONFIG_BLK_DEV_IT8172 is not set
# CONFIG_BLK_DEV_IT8213 is not set
# CONFIG_BLK_DEV_IT821X is not set
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_SVWKS is not set
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
# CONFIG_BLK_DEV_VIA82CXXX is not set
# CONFIG_BLK_DEV_TC86C001 is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
CONFIG_CHR_DEV_ST=y
# CONFIG_CHR_DEV_OSST is not set
# CONFIG_BLK_DEV_SR is not set
# CONFIG_CHR_DEV_SG is not set
CONFIG_CHR_DEV_SCH=y
# CONFIG_SCSI_CONSTANTS is not set
CONFIG_SCSI_LOGGING=y
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
# CONFIG_SCSI_SAS_ATA is not set
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=y
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=y
CONFIG_ISCSI_BOOT_SYSFS=y
# CONFIG_SCSI_CXGB3_ISCSI is not set
# CONFIG_SCSI_CXGB4_ISCSI is not set
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_BE2ISCSI is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_HPSA is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_3W_SAS is not set
# CONFIG_SCSI_ACARD is not set
CONFIG_SCSI_AHA1740=y
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_MVSAS is not set
# CONFIG_SCSI_MVUMI is not set
# CONFIG_SCSI_DPT_I2O is not set
CONFIG_SCSI_ADVANSYS=y
# CONFIG_SCSI_ARCMSR is not set
# CONFIG_SCSI_ESAS2R is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
# CONFIG_MEGARAID_SAS is not set
# CONFIG_SCSI_MPT3SAS is not set
# CONFIG_SCSI_MPT2SAS is not set
# CONFIG_SCSI_SMARTPQI is not set
# CONFIG_SCSI_UFSHCD is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_MYRB is not set
# CONFIG_SCSI_MYRS is not set
# CONFIG_VMWARE_PVSCSI is not set
CONFIG_XEN_SCSI_FRONTEND=y
CONFIG_HYPERV_STORAGE=y
# CONFIG_LIBFC is not set
# CONFIG_SCSI_SNIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_ISCI is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_PPA is not set
CONFIG_SCSI_IMM=y
# CONFIG_SCSI_IZIP_EPP16 is not set
CONFIG_SCSI_IZIP_SLOW_CTR=y
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
# CONFIG_SCSI_QLOGIC_1280 is not set
# CONFIG_SCSI_QLA_FC is not set
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_LPFC is not set
CONFIG_SCSI_SIM710=y
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_AM53C974 is not set
# CONFIG_SCSI_WD719X is not set
CONFIG_SCSI_DEBUG=y
# CONFIG_SCSI_PMCRAID is not set
# CONFIG_SCSI_PM8001 is not set
# CONFIG_SCSI_BFA_FC is not set
# CONFIG_SCSI_VIRTIO is not set
# CONFIG_SCSI_CHELSIO_FCOE is not set
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
CONFIG_SCSI_DH_HP_SW=y
CONFIG_SCSI_DH_EMC=y
CONFIG_SCSI_DH_ALUA=y
CONFIG_ATA=y
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
CONFIG_SATA_ZPODD=y
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
# CONFIG_SATA_AHCI is not set
CONFIG_SATA_AHCI_PLATFORM=y
# CONFIG_SATA_INIC162X is not set
# CONFIG_SATA_ACARD_AHCI is not set
# CONFIG_SATA_SIL24 is not set
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_SX4 is not set
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
# CONFIG_ATA_PIIX is not set
# CONFIG_SATA_MV is not set
# CONFIG_SATA_NV is not set
# CONFIG_SATA_PROMISE is not set
# CONFIG_SATA_SIL is not set
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_SVW is not set
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
# CONFIG_SATA_VITESSE is not set

#
# PATA SFF controllers with BMDMA
#
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_ATP867X is not set
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT8213 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_MARVELL is not set
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NINJA32 is not set
# CONFIG_PATA_NS87415 is not set
# CONFIG_PATA_OLDPIIX is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RDC is not set
# CONFIG_PATA_SCH is not set
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
# CONFIG_PATA_TOSHIBA is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_PLATFORM is not set
# CONFIG_PATA_RZ1000 is not set

#
# Generic fallback / legacy drivers
#
# CONFIG_PATA_ACPI is not set
# CONFIG_ATA_GENERIC is not set
# CONFIG_PATA_LEGACY is not set
# CONFIG_MD is not set
CONFIG_TARGET_CORE=y
# CONFIG_TCM_IBLOCK is not set
CONFIG_TCM_FILEIO=y
CONFIG_TCM_PSCSI=y
CONFIG_TCM_USER2=y
# CONFIG_LOOPBACK_TARGET is not set
# CONFIG_ISCSI_TARGET is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
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
CONFIG_ATM_DRIVERS=y
# CONFIG_ATM_DUMMY is not set
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
# CONFIG_ATP is not set
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
# CONFIG_PLIP is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
CONFIG_USB_NET_DRIVERS=y
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_RTL8152 is not set
# CONFIG_USB_LAN78XX is not set
# CONFIG_USB_USBNET is not set
# CONFIG_USB_HSO is not set
# CONFIG_USB_IPHETH is not set
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
# WiMAX Wireless Broadband devices
#
# CONFIG_WIMAX_I2400M_USB is not set
# CONFIG_WAN is not set
CONFIG_XEN_NETDEV_FRONTEND=y
# CONFIG_VMXNET3 is not set
# CONFIG_FUJITSU_ES is not set
# CONFIG_HYPERV_NET is not set
# CONFIG_NETDEVSIM is not set
# CONFIG_NET_FAILOVER is not set
# CONFIG_ISDN is not set
CONFIG_NVM=y
# CONFIG_NVM_PBLK is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=y
# CONFIG_INPUT_EVDEV is not set
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5520 is not set
CONFIG_KEYBOARD_ADP5588=y
CONFIG_KEYBOARD_ADP5589=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
CONFIG_KEYBOARD_QT2160=y
CONFIG_KEYBOARD_DLINK_DIR685=y
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
CONFIG_KEYBOARD_GPIO_POLLED=y
CONFIG_KEYBOARD_TCA6416=y
CONFIG_KEYBOARD_TCA8418=y
# CONFIG_KEYBOARD_MATRIX is not set
CONFIG_KEYBOARD_LM8323=y
CONFIG_KEYBOARD_LM8333=y
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
CONFIG_KEYBOARD_MPR121=y
# CONFIG_KEYBOARD_NEWTON is not set
CONFIG_KEYBOARD_OPENCORES=y
# CONFIG_KEYBOARD_SAMSUNG is not set
# CONFIG_KEYBOARD_GOLDFISH_EVENTS is not set
CONFIG_KEYBOARD_STOWAWAY=y
CONFIG_KEYBOARD_SUNKBD=y
# CONFIG_KEYBOARD_TM2_TOUCHKEY is not set
# CONFIG_KEYBOARD_TWL4030 is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
# CONFIG_KEYBOARD_MTK_PMIC is not set
CONFIG_INPUT_MOUSE=y
# CONFIG_MOUSE_PS2 is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
CONFIG_MOUSE_BCM5974=y
CONFIG_MOUSE_CYAPA=y
# CONFIG_MOUSE_ELAN_I2C is not set
CONFIG_MOUSE_VSXXXAA=y
CONFIG_MOUSE_GPIO=y
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
CONFIG_MOUSE_SYNAPTICS_USB=y
# CONFIG_INPUT_JOYSTICK is not set
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=y
CONFIG_TABLET_USB_AIPTEK=y
# CONFIG_TABLET_USB_GTCO is not set
CONFIG_TABLET_USB_HANWANG=y
# CONFIG_TABLET_USB_KBTAB is not set
CONFIG_TABLET_USB_PEGASUS=y
CONFIG_TABLET_SERIAL_WACOM4=y
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_PROPERTIES=y
# CONFIG_TOUCHSCREEN_88PM860X is not set
CONFIG_TOUCHSCREEN_ADS7846=y
# CONFIG_TOUCHSCREEN_AD7877 is not set
# CONFIG_TOUCHSCREEN_AD7879 is not set
# CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
# CONFIG_TOUCHSCREEN_AUO_PIXCIR is not set
CONFIG_TOUCHSCREEN_BU21013=y
# CONFIG_TOUCHSCREEN_BU21029 is not set
# CONFIG_TOUCHSCREEN_CHIPONE_ICN8505 is not set
# CONFIG_TOUCHSCREEN_CY8CTMG110 is not set
CONFIG_TOUCHSCREEN_CYTTSP_CORE=y
# CONFIG_TOUCHSCREEN_CYTTSP_I2C is not set
CONFIG_TOUCHSCREEN_CYTTSP_SPI=y
CONFIG_TOUCHSCREEN_CYTTSP4_CORE=y
# CONFIG_TOUCHSCREEN_CYTTSP4_I2C is not set
CONFIG_TOUCHSCREEN_CYTTSP4_SPI=y
CONFIG_TOUCHSCREEN_DA9052=y
CONFIG_TOUCHSCREEN_DYNAPRO=y
# CONFIG_TOUCHSCREEN_HAMPSHIRE is not set
CONFIG_TOUCHSCREEN_EETI=y
CONFIG_TOUCHSCREEN_EGALAX_SERIAL=y
CONFIG_TOUCHSCREEN_EXC3000=y
CONFIG_TOUCHSCREEN_FUJITSU=y
CONFIG_TOUCHSCREEN_GOODIX=y
CONFIG_TOUCHSCREEN_HIDEEP=y
CONFIG_TOUCHSCREEN_ILI210X=y
# CONFIG_TOUCHSCREEN_S6SY761 is not set
CONFIG_TOUCHSCREEN_GUNZE=y
# CONFIG_TOUCHSCREEN_EKTF2127 is not set
CONFIG_TOUCHSCREEN_ELAN=y
# CONFIG_TOUCHSCREEN_ELO is not set
CONFIG_TOUCHSCREEN_WACOM_W8001=y
# CONFIG_TOUCHSCREEN_WACOM_I2C is not set
# CONFIG_TOUCHSCREEN_MAX11801 is not set
CONFIG_TOUCHSCREEN_MCS5000=y
CONFIG_TOUCHSCREEN_MMS114=y
CONFIG_TOUCHSCREEN_MELFAS_MIP4=y
CONFIG_TOUCHSCREEN_MTOUCH=y
CONFIG_TOUCHSCREEN_INEXIO=y
# CONFIG_TOUCHSCREEN_MK712 is not set
# CONFIG_TOUCHSCREEN_PENMOUNT is not set
CONFIG_TOUCHSCREEN_EDT_FT5X06=y
# CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
CONFIG_TOUCHSCREEN_TOUCHWIN=y
# CONFIG_TOUCHSCREEN_TI_AM335X_TSC is not set
# CONFIG_TOUCHSCREEN_PIXCIR is not set
# CONFIG_TOUCHSCREEN_WDT87XX_I2C is not set
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
CONFIG_TOUCHSCREEN_MC13783=y
CONFIG_TOUCHSCREEN_TOUCHIT213=y
CONFIG_TOUCHSCREEN_TSC_SERIO=y
CONFIG_TOUCHSCREEN_TSC200X_CORE=y
CONFIG_TOUCHSCREEN_TSC2004=y
CONFIG_TOUCHSCREEN_TSC2005=y
# CONFIG_TOUCHSCREEN_TSC2007 is not set
CONFIG_TOUCHSCREEN_PCAP=y
CONFIG_TOUCHSCREEN_RM_TS=y
# CONFIG_TOUCHSCREEN_SILEAD is not set
# CONFIG_TOUCHSCREEN_SIS_I2C is not set
CONFIG_TOUCHSCREEN_ST1232=y
# CONFIG_TOUCHSCREEN_STMFTS is not set
# CONFIG_TOUCHSCREEN_SUR40 is not set
# CONFIG_TOUCHSCREEN_SURFACE3_SPI is not set
CONFIG_TOUCHSCREEN_SX8654=y
CONFIG_TOUCHSCREEN_TPS6507X=y
CONFIG_TOUCHSCREEN_ZET6223=y
# CONFIG_TOUCHSCREEN_ZFORCE is not set
# CONFIG_TOUCHSCREEN_ROHM_BU21023 is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_88PM860X_ONKEY is not set
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_ARIZONA_HAPTICS is not set
CONFIG_INPUT_BMA150=y
# CONFIG_INPUT_E3X0_BUTTON is not set
# CONFIG_INPUT_MSM_VIBRATOR is not set
CONFIG_INPUT_PCSPKR=y
CONFIG_INPUT_MC13783_PWRBUTTON=y
# CONFIG_INPUT_MMA8450 is not set
CONFIG_INPUT_APANEL=y
CONFIG_INPUT_GP2A=y
# CONFIG_INPUT_GPIO_BEEPER is not set
CONFIG_INPUT_GPIO_DECODER=y
CONFIG_INPUT_ATLAS_BTNS=y
CONFIG_INPUT_ATI_REMOTE2=y
CONFIG_INPUT_KEYSPAN_REMOTE=y
# CONFIG_INPUT_KXTJ9 is not set
CONFIG_INPUT_POWERMATE=y
CONFIG_INPUT_YEALINK=y
# CONFIG_INPUT_CM109 is not set
CONFIG_INPUT_REGULATOR_HAPTIC=y
CONFIG_INPUT_RETU_PWRBUTTON=y
CONFIG_INPUT_TWL4030_PWRBUTTON=y
CONFIG_INPUT_TWL4030_VIBRA=y
# CONFIG_INPUT_TWL6040_VIBRA is not set
CONFIG_INPUT_UINPUT=y
CONFIG_INPUT_PALMAS_PWRBUTTON=y
# CONFIG_INPUT_PCF50633_PMU is not set
CONFIG_INPUT_PCF8574=y
# CONFIG_INPUT_GPIO_ROTARY_ENCODER is not set
CONFIG_INPUT_DA9052_ONKEY=y
CONFIG_INPUT_DA9063_ONKEY=y
CONFIG_INPUT_PCAP=y
CONFIG_INPUT_ADXL34X=y
CONFIG_INPUT_ADXL34X_I2C=y
CONFIG_INPUT_ADXL34X_SPI=y
CONFIG_INPUT_IMS_PCU=y
# CONFIG_INPUT_CMA3000 is not set
CONFIG_INPUT_XEN_KBDDEV_FRONTEND=y
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set
CONFIG_INPUT_DRV260X_HAPTICS=y
# CONFIG_INPUT_DRV2665_HAPTICS is not set
CONFIG_INPUT_DRV2667_HAPTICS=y
CONFIG_INPUT_RAVE_SP_PWRBUTTON=y
CONFIG_RMI4_CORE=y
CONFIG_RMI4_I2C=y
CONFIG_RMI4_SPI=y
CONFIG_RMI4_SMB=y
CONFIG_RMI4_F03=y
CONFIG_RMI4_F03_SERIO=y
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
CONFIG_SERIO_CT82C710=y
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
CONFIG_SERIO_OLPC_APSP=y
CONFIG_HYPERV_KEYBOARD=y
CONFIG_SERIO_GPIO_PS2=y
CONFIG_USERIO=y
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
CONFIG_GAMEPORT_L4=y
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

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
# CONFIG_GOLDFISH_TTY is not set
CONFIG_LDISC_AUTOLOAD=y
CONFIG_DEVMEM=y
CONFIG_DEVKMEM=y

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
CONFIG_SERIAL_DEV_BUS=y
CONFIG_SERIAL_DEV_CTRL_TTYPORT=y
# CONFIG_TTY_PRINTK is not set
# CONFIG_PRINTER is not set
CONFIG_PPDEV=y
CONFIG_HVC_DRIVER=y
CONFIG_HVC_IRQ=y
CONFIG_HVC_XEN=y
CONFIG_HVC_XEN_FRONTEND=y
# CONFIG_VIRTIO_CONSOLE is not set
# CONFIG_IPMI_HANDLER is not set
# CONFIG_HW_RANDOM is not set
# CONFIG_NVRAM is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
# CONFIG_HANGCHECK_TIMER is not set
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set
CONFIG_RANDOM_TRUST_CPU=y

#
# I2C support
#
CONFIG_I2C=y
# CONFIG_ACPI_I2C_OPREGION is not set
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
# CONFIG_I2C_MUX_GPIO is not set
# CONFIG_I2C_MUX_LTC4306 is not set
CONFIG_I2C_MUX_PCA9541=y
CONFIG_I2C_MUX_PCA954x=y
CONFIG_I2C_MUX_REG=y
CONFIG_I2C_MUX_MLXCPLD=y
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y

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
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
CONFIG_I2C_CHT_WC=y
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
CONFIG_I2C_DESIGNWARE_SLAVE=y
# CONFIG_I2C_DESIGNWARE_PCI is not set
CONFIG_I2C_EMEV2=y
CONFIG_I2C_GPIO=y
# CONFIG_I2C_GPIO_FAULT_INJECTOR is not set
CONFIG_I2C_OCORES=y
# CONFIG_I2C_PCA_PLATFORM is not set
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
CONFIG_I2C_PARPORT=y
CONFIG_I2C_PARPORT_LIGHT=y
CONFIG_I2C_ROBOTFUZZ_OSIF=y
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=y

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_MLXCPLD=y
CONFIG_I2C_CROS_EC_TUNNEL=y
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_I3C is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y
CONFIG_SPI_MEM=y

#
# SPI Master Controller Drivers
#
# CONFIG_SPI_ALTERA is not set
CONFIG_SPI_AXI_SPI_ENGINE=y
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=y
CONFIG_SPI_CADENCE=y
CONFIG_SPI_DESIGNWARE=y
# CONFIG_SPI_DW_PCI is not set
# CONFIG_SPI_DW_MMIO is not set
CONFIG_SPI_NXP_FLEXSPI=y
# CONFIG_SPI_GPIO is not set
CONFIG_SPI_LM70_LLP=y
CONFIG_SPI_OC_TINY=y
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_ROCKCHIP is not set
CONFIG_SPI_SC18IS602=y
# CONFIG_SPI_SIFIVE is not set
# CONFIG_SPI_MXIC is not set
CONFIG_SPI_XCOMM=y
CONFIG_SPI_XILINX=y
CONFIG_SPI_ZYNQMP_GQSPI=y

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=y
CONFIG_SPI_TLE62X0=y
# CONFIG_SPI_SLAVE is not set
CONFIG_SPMI=y
# CONFIG_HSI is not set
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
# CONFIG_NTP_PPS is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_PARPORT=y
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PTP_1588_CLOCK_KVM=y
CONFIG_PINCTRL=y
CONFIG_PINMUX=y
CONFIG_PINCONF=y
CONFIG_GENERIC_PINCONF=y
CONFIG_DEBUG_PINCTRL=y
# CONFIG_PINCTRL_AMD is not set
CONFIG_PINCTRL_MCP23S08=y
CONFIG_PINCTRL_SX150X=y
# CONFIG_PINCTRL_BAYTRAIL is not set
# CONFIG_PINCTRL_CHERRYVIEW is not set
CONFIG_PINCTRL_INTEL=y
# CONFIG_PINCTRL_BROXTON is not set
CONFIG_PINCTRL_CANNONLAKE=y
CONFIG_PINCTRL_CEDARFORK=y
CONFIG_PINCTRL_DENVERTON=y
CONFIG_PINCTRL_GEMINILAKE=y
CONFIG_PINCTRL_ICELAKE=y
CONFIG_PINCTRL_LEWISBURG=y
CONFIG_PINCTRL_SUNRISEPOINT=y
CONFIG_GPIOLIB=y
CONFIG_GPIOLIB_FASTPATH_LIMIT=512
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
CONFIG_DEBUG_GPIO=y
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
# CONFIG_GPIO_AMDPT is not set
# CONFIG_GPIO_DWAPB is not set
# CONFIG_GPIO_EXAR is not set
CONFIG_GPIO_GENERIC_PLATFORM=y
# CONFIG_GPIO_ICH is not set
CONFIG_GPIO_LYNXPOINT=y
CONFIG_GPIO_MB86S7X=y
CONFIG_GPIO_MENZ127=y
CONFIG_GPIO_MOCKUP=y
# CONFIG_GPIO_SIOX is not set
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_AMD_FCH is not set

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_104_DIO_48E=y
# CONFIG_GPIO_104_IDIO_16 is not set
CONFIG_GPIO_104_IDI_48=y
CONFIG_GPIO_F7188X=y
# CONFIG_GPIO_GPIO_MM is not set
CONFIG_GPIO_IT87=y
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_SCH311X is not set
CONFIG_GPIO_WINBOND=y
CONFIG_GPIO_WS16C48=y

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=y
# CONFIG_GPIO_ADP5588_IRQ is not set
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
# CONFIG_GPIO_MAX732X_IRQ is not set
# CONFIG_GPIO_PCA953X is not set
# CONFIG_GPIO_PCF857X is not set
CONFIG_GPIO_TPIC2810=y

#
# MFD GPIO expanders
#
# CONFIG_GPIO_ADP5520 is not set
# CONFIG_GPIO_ARIZONA is not set
CONFIG_GPIO_BD9571MWV=y
CONFIG_GPIO_DA9052=y
CONFIG_GPIO_LP873X=y
# CONFIG_GPIO_PALMAS is not set
# CONFIG_GPIO_TPS65086 is not set
# CONFIG_GPIO_TPS6586X is not set
# CONFIG_GPIO_TPS65912 is not set
CONFIG_GPIO_TWL4030=y
# CONFIG_GPIO_TWL6040 is not set
CONFIG_GPIO_WM8350=y
CONFIG_GPIO_WM8994=y

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_PCI_IDIO_16 is not set
# CONFIG_GPIO_PCIE_IDIO_24 is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders
#
CONFIG_GPIO_MAX3191X=y
CONFIG_GPIO_MAX7301=y
CONFIG_GPIO_MC33880=y
# CONFIG_GPIO_PISOSR is not set
CONFIG_GPIO_XRA1403=y

#
# USB GPIO expanders
#
CONFIG_W1=y
CONFIG_W1_CON=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2490=y
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y
# CONFIG_W1_MASTER_GPIO is not set

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
# CONFIG_W1_SLAVE_SMEM is not set
CONFIG_W1_SLAVE_DS2405=y
CONFIG_W1_SLAVE_DS2408=y
# CONFIG_W1_SLAVE_DS2408_READBACK is not set
CONFIG_W1_SLAVE_DS2413=y
CONFIG_W1_SLAVE_DS2406=y
# CONFIG_W1_SLAVE_DS2423 is not set
# CONFIG_W1_SLAVE_DS2805 is not set
CONFIG_W1_SLAVE_DS2431=y
CONFIG_W1_SLAVE_DS2433=y
CONFIG_W1_SLAVE_DS2433_CRC=y
CONFIG_W1_SLAVE_DS2438=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
CONFIG_W1_SLAVE_DS28E17=y
CONFIG_POWER_AVS=y
CONFIG_POWER_RESET=y
CONFIG_POWER_RESET_RESTART=y
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=y
CONFIG_WM8350_POWER=y
# CONFIG_TEST_POWER is not set
CONFIG_BATTERY_88PM860X=y
CONFIG_CHARGER_ADP5061=y
CONFIG_BATTERY_DS2760=y
CONFIG_BATTERY_DS2780=y
# CONFIG_BATTERY_DS2781 is not set
CONFIG_BATTERY_DS2782=y
# CONFIG_BATTERY_SBS is not set
CONFIG_CHARGER_SBS=y
CONFIG_MANAGER_SBS=y
CONFIG_BATTERY_BQ27XXX=y
CONFIG_BATTERY_BQ27XXX_I2C=y
# CONFIG_BATTERY_BQ27XXX_HDQ is not set
CONFIG_BATTERY_BQ27XXX_DT_UPDATES_NVM=y
CONFIG_BATTERY_DA9052=y
# CONFIG_BATTERY_DA9150 is not set
# CONFIG_BATTERY_MAX17040 is not set
CONFIG_BATTERY_MAX17042=y
CONFIG_BATTERY_MAX1721X=y
# CONFIG_CHARGER_88PM860X is not set
# CONFIG_CHARGER_PCF50633 is not set
CONFIG_CHARGER_ISP1704=y
# CONFIG_CHARGER_MAX8903 is not set
CONFIG_CHARGER_LP8727=y
# CONFIG_CHARGER_GPIO is not set
CONFIG_CHARGER_MANAGER=y
CONFIG_CHARGER_LTC3651=y
CONFIG_CHARGER_MAX77693=y
CONFIG_CHARGER_MAX8997=y
# CONFIG_CHARGER_MAX8998 is not set
CONFIG_CHARGER_BQ2415X=y
# CONFIG_CHARGER_BQ24190 is not set
# CONFIG_CHARGER_BQ24257 is not set
CONFIG_CHARGER_BQ24735=y
CONFIG_CHARGER_BQ25890=y
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_CHARGER_TPS65090 is not set
CONFIG_BATTERY_GAUGE_LTC2941=y
CONFIG_BATTERY_GOLDFISH=y
CONFIG_BATTERY_RT5033=y
CONFIG_CHARGER_RT9455=y
CONFIG_CHARGER_CROS_USBPD=y
# CONFIG_HWMON is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_STATISTICS=y
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
CONFIG_THERMAL_WRITABLE_TRIPS=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_GOV_STEP_WISE is not set
CONFIG_THERMAL_GOV_BANG_BANG=y
# CONFIG_THERMAL_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
# CONFIG_CLOCK_THERMAL is not set
# CONFIG_DEVFREQ_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set

#
# Intel thermal drivers
#
CONFIG_INTEL_POWERCLAMP=y
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
# CONFIG_INTEL_PCH_THERMAL is not set
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set
CONFIG_WATCHDOG_HANDLE_BOOT_ENABLED=y
CONFIG_WATCHDOG_SYSFS=y

#
# Watchdog Device Drivers
#
# CONFIG_SOFT_WATCHDOG is not set
CONFIG_DA9052_WATCHDOG=y
CONFIG_DA9063_WATCHDOG=y
CONFIG_DA9062_WATCHDOG=y
CONFIG_MENF21BMC_WATCHDOG=y
CONFIG_MENZ069_WATCHDOG=y
CONFIG_WDAT_WDT=y
CONFIG_WM8350_WATCHDOG=y
# CONFIG_XILINX_WATCHDOG is not set
CONFIG_ZIIRAVE_WATCHDOG=y
# CONFIG_RAVE_SP_WATCHDOG is not set
# CONFIG_CADENCE_WATCHDOG is not set
# CONFIG_DW_WATCHDOG is not set
CONFIG_TWL4030_WATCHDOG=y
# CONFIG_MAX63XX_WATCHDOG is not set
CONFIG_RETU_WATCHDOG=y
CONFIG_ACQUIRE_WDT=y
CONFIG_ADVANTECH_WDT=y
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
CONFIG_EBC_C384_WDT=y
# CONFIG_F71808E_WDT is not set
# CONFIG_SP5100_TCO is not set
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
CONFIG_IBMASR=y
CONFIG_WAFER_WDT=y
# CONFIG_I6300ESB_WDT is not set
# CONFIG_IE6XX_WDT is not set
# CONFIG_ITCO_WDT is not set
# CONFIG_IT8712F_WDT is not set
# CONFIG_IT87_WDT is not set
# CONFIG_HP_WATCHDOG is not set
CONFIG_SC1200_WDT=y
# CONFIG_PC87413_WDT is not set
# CONFIG_NV_TCO is not set
# CONFIG_60XX_WDT is not set
# CONFIG_CPU5_WDT is not set
# CONFIG_SMSC_SCH311X_WDT is not set
CONFIG_SMSC37B787_WDT=y
CONFIG_TQMX86_WDT=y
# CONFIG_VIA_WDT is not set
# CONFIG_W83627HF_WDT is not set
CONFIG_W83877F_WDT=y
CONFIG_W83977F_WDT=y
CONFIG_MACHZ_WDT=y
# CONFIG_SBC_EPX_C3_WATCHDOG is not set
CONFIG_NI903X_WDT=y
CONFIG_NIC7018_WDT=y
CONFIG_MEN_A21_WDT=y
# CONFIG_XEN_WDT is not set

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set

#
# USB-based Watchdog Cards
#
# CONFIG_USBPCWATCHDOG is not set

#
# Watchdog Pretimeout Governors
#
CONFIG_WATCHDOG_PRETIMEOUT_GOV=y
# CONFIG_WATCHDOG_PRETIMEOUT_DEFAULT_GOV_NOOP is not set
CONFIG_WATCHDOG_PRETIMEOUT_DEFAULT_GOV_PANIC=y
# CONFIG_WATCHDOG_PRETIMEOUT_GOV_NOOP is not set
CONFIG_WATCHDOG_PRETIMEOUT_GOV_PANIC=y
CONFIG_SSB_POSSIBLE=y
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_SDIOHOST_POSSIBLE=y
# CONFIG_SSB_SDIOHOST is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
# CONFIG_SSB_DRIVER_PCICORE is not set
CONFIG_SSB_DRIVER_GPIO=y
CONFIG_BCMA_POSSIBLE=y
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_AS3711 is not set
CONFIG_PMIC_ADP5520=y
CONFIG_MFD_AAT2870_CORE=y
CONFIG_MFD_BCM590XX=y
CONFIG_MFD_BD9571MWV=y
# CONFIG_MFD_AXP20X_I2C is not set
CONFIG_MFD_CROS_EC=y
# CONFIG_MFD_CROS_EC_CHARDEV is not set
# CONFIG_MFD_MADERA is not set
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_SPI=y
CONFIG_MFD_DA9052_I2C=y
# CONFIG_MFD_DA9055 is not set
CONFIG_MFD_DA9062=y
CONFIG_MFD_DA9063=y
CONFIG_MFD_DA9150=y
# CONFIG_MFD_DLN2 is not set
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_SPI=y
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
# CONFIG_MFD_INTEL_QUARK_I2C_GPIO is not set
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
# CONFIG_INTEL_SOC_PMIC is not set
CONFIG_INTEL_SOC_PMIC_CHTWC=y
CONFIG_INTEL_SOC_PMIC_CHTDC_TI=y
CONFIG_MFD_INTEL_LPSS=y
CONFIG_MFD_INTEL_LPSS_ACPI=y
# CONFIG_MFD_INTEL_LPSS_PCI is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_KEMPLD is not set
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
CONFIG_MFD_88PM860X=y
# CONFIG_MFD_MAX14577 is not set
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX77843=y
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
CONFIG_MFD_MAX8997=y
CONFIG_MFD_MAX8998=y
CONFIG_MFD_MT6397=y
CONFIG_MFD_MENF21BMC=y
CONFIG_EZX_PCAP=y
# CONFIG_MFD_VIPERBOARD is not set
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
# CONFIG_MFD_RDC321X is not set
CONFIG_MFD_RT5033=y
# CONFIG_MFD_RC5T583 is not set
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=y
# CONFIG_MFD_SM501_GPIO is not set
# CONFIG_MFD_SKY81452 is not set
# CONFIG_MFD_SMSC is not set
CONFIG_ABX500_CORE=y
CONFIG_AB3100_CORE=y
# CONFIG_AB3100_OTP is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
# CONFIG_MFD_LP3943 is not set
# CONFIG_MFD_LP8788 is not set
CONFIG_MFD_TI_LMU=y
CONFIG_MFD_PALMAS=y
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
CONFIG_MFD_TPS65086=y
CONFIG_MFD_TPS65090=y
# CONFIG_MFD_TPS68470 is not set
CONFIG_MFD_TI_LP873X=y
CONFIG_MFD_TPS6586X=y
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
CONFIG_MFD_TPS65912_SPI=y
# CONFIG_MFD_TPS80031 is not set
CONFIG_TWL4030_CORE=y
CONFIG_MFD_TWL4030_AUDIO=y
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=y
# CONFIG_MFD_TQMX86 is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_ARIZONA_SPI=y
# CONFIG_MFD_CS47L24 is not set
CONFIG_MFD_WM5102=y
# CONFIG_MFD_WM5110 is not set
# CONFIG_MFD_WM8997 is not set
# CONFIG_MFD_WM8998 is not set
CONFIG_MFD_WM8400=y
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM831X_SPI is not set
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
CONFIG_MFD_WM8994=y
CONFIG_RAVE_SP_CORE=y
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
CONFIG_REGULATOR_88PG86X=y
# CONFIG_REGULATOR_88PM8607 is not set
# CONFIG_REGULATOR_ACT8865 is not set
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_ANATOP=y
CONFIG_REGULATOR_AAT2870=y
# CONFIG_REGULATOR_AB3100 is not set
# CONFIG_REGULATOR_ARIZONA_LDO1 is not set
CONFIG_REGULATOR_ARIZONA_MICSUPP=y
CONFIG_REGULATOR_BCM590XX=y
CONFIG_REGULATOR_BD9571MWV=y
# CONFIG_REGULATOR_DA9052 is not set
# CONFIG_REGULATOR_DA9062 is not set
CONFIG_REGULATOR_DA9063=y
CONFIG_REGULATOR_DA9210=y
CONFIG_REGULATOR_DA9211=y
CONFIG_REGULATOR_FAN53555=y
# CONFIG_REGULATOR_GPIO is not set
CONFIG_REGULATOR_ISL9305=y
# CONFIG_REGULATOR_ISL6271A is not set
# CONFIG_REGULATOR_LM363X is not set
CONFIG_REGULATOR_LP3971=y
# CONFIG_REGULATOR_LP3972 is not set
CONFIG_REGULATOR_LP872X=y
CONFIG_REGULATOR_LP8755=y
# CONFIG_REGULATOR_LTC3589 is not set
# CONFIG_REGULATOR_LTC3676 is not set
# CONFIG_REGULATOR_MAX1586 is not set
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX8997=y
CONFIG_REGULATOR_MAX8998=y
# CONFIG_REGULATOR_MAX77693 is not set
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
CONFIG_REGULATOR_MC13892=y
CONFIG_REGULATOR_MT6311=y
CONFIG_REGULATOR_MT6323=y
CONFIG_REGULATOR_MT6397=y
CONFIG_REGULATOR_PALMAS=y
CONFIG_REGULATOR_PCAP=y
# CONFIG_REGULATOR_PCF50633 is not set
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_PV88060=y
# CONFIG_REGULATOR_PV88080 is not set
CONFIG_REGULATOR_PV88090=y
CONFIG_REGULATOR_QCOM_SPMI=y
CONFIG_REGULATOR_RT5033=y
CONFIG_REGULATOR_S2MPA01=y
CONFIG_REGULATOR_S2MPS11=y
CONFIG_REGULATOR_S5M8767=y
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS6105X=y
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
# CONFIG_REGULATOR_TPS6507X is not set
CONFIG_REGULATOR_TPS65086=y
CONFIG_REGULATOR_TPS65090=y
CONFIG_REGULATOR_TPS65132=y
CONFIG_REGULATOR_TPS6524X=y
CONFIG_REGULATOR_TPS6586X=y
# CONFIG_REGULATOR_TPS65912 is not set
CONFIG_REGULATOR_TWL4030=y
# CONFIG_REGULATOR_WM8350 is not set
CONFIG_REGULATOR_WM8400=y
CONFIG_REGULATOR_WM8994=y
CONFIG_CEC_CORE=y
CONFIG_RC_CORE=y
# CONFIG_RC_MAP is not set
# CONFIG_LIRC is not set
# CONFIG_RC_DECODERS is not set
# CONFIG_RC_DEVICES is not set
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
CONFIG_MEDIA_RADIO_SUPPORT=y
CONFIG_MEDIA_SDR_SUPPORT=y
# CONFIG_MEDIA_CEC_SUPPORT is not set
# CONFIG_MEDIA_CEC_RC is not set
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_VIDEO_TUNER=y
CONFIG_V4L2_FWNODE=y
CONFIG_VIDEOBUF_GEN=y
CONFIG_VIDEOBUF_VMALLOC=y
CONFIG_DVB_CORE=y
# CONFIG_DVB_MMAP is not set
CONFIG_DVB_NET=y
CONFIG_DVB_MAX_ADAPTERS=16
CONFIG_DVB_DYNAMIC_MINORS=y
# CONFIG_DVB_DEMUX_SECTION_LOSS_LOG is not set
CONFIG_DVB_ULE_DEBUG=y

#
# Media drivers
#
CONFIG_MEDIA_USB_SUPPORT=y

#
# Webcam devices
#
# CONFIG_USB_VIDEO_CLASS is not set
# CONFIG_USB_GSPCA is not set
# CONFIG_USB_PWC is not set
# CONFIG_VIDEO_CPIA2 is not set
CONFIG_USB_ZR364XX=y
# CONFIG_USB_STKWEBCAM is not set
CONFIG_USB_S2255=y
CONFIG_VIDEO_USBTV=y

#
# Analog TV USB devices
#
# CONFIG_VIDEO_PVRUSB2 is not set
CONFIG_VIDEO_HDPVR=y
CONFIG_VIDEO_USBVISION=y
CONFIG_VIDEO_STK1160_COMMON=y
CONFIG_VIDEO_STK1160=y
# CONFIG_VIDEO_GO7007 is not set

#
# Analog/digital TV USB devices
#
# CONFIG_VIDEO_AU0828 is not set
CONFIG_VIDEO_CX231XX=y
CONFIG_VIDEO_CX231XX_RC=y
CONFIG_VIDEO_CX231XX_ALSA=y
CONFIG_VIDEO_CX231XX_DVB=y
# CONFIG_VIDEO_TM6000 is not set

#
# Digital TV USB devices
#
# CONFIG_DVB_USB is not set
CONFIG_DVB_USB_V2=y
CONFIG_DVB_USB_AF9015=y
CONFIG_DVB_USB_AF9035=y
CONFIG_DVB_USB_ANYSEE=y
# CONFIG_DVB_USB_AU6610 is not set
CONFIG_DVB_USB_AZ6007=y
CONFIG_DVB_USB_CE6230=y
CONFIG_DVB_USB_EC168=y
CONFIG_DVB_USB_GL861=y
# CONFIG_DVB_USB_LME2510 is not set
# CONFIG_DVB_USB_MXL111SF is not set
CONFIG_DVB_USB_RTL28XXU=y
# CONFIG_DVB_USB_DVBSKY is not set
# CONFIG_DVB_USB_ZD1301 is not set
# CONFIG_DVB_TTUSB_BUDGET is not set
# CONFIG_DVB_TTUSB_DEC is not set
CONFIG_SMS_USB_DRV=y
CONFIG_DVB_B2C2_FLEXCOP_USB=y
# CONFIG_DVB_B2C2_FLEXCOP_USB_DEBUG is not set
# CONFIG_DVB_AS102 is not set

#
# Webcam, TV (analog/digital) USB devices
#
CONFIG_VIDEO_EM28XX=y
CONFIG_VIDEO_EM28XX_V4L2=y
CONFIG_VIDEO_EM28XX_ALSA=y
CONFIG_VIDEO_EM28XX_DVB=y
CONFIG_VIDEO_EM28XX_RC=y

#
# Software defined radio USB devices
#
CONFIG_USB_AIRSPY=y
# CONFIG_USB_HACKRF is not set
CONFIG_USB_MSI2500=y
# CONFIG_MEDIA_PCI_SUPPORT is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
# CONFIG_V4L_TEST_DRIVERS is not set
CONFIG_DVB_PLATFORM_DRIVERS=y
CONFIG_SDR_PLATFORM_DRIVERS=y

#
# Supported MMC/SDIO adapters
#
# CONFIG_SMS_SDIO_DRV is not set
# CONFIG_RADIO_ADAPTERS is not set
CONFIG_MEDIA_COMMON_OPTIONS=y

#
# common driver options
#
CONFIG_VIDEO_CX2341X=y
CONFIG_VIDEO_TVEEPROM=y
CONFIG_CYPRESS_FIRMWARE=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_V4L2=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_VMALLOC=y
CONFIG_DVB_B2C2_FLEXCOP=y
CONFIG_SMS_SIANO_MDTV=y
# CONFIG_SMS_SIANO_RC is not set

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
# CONFIG_MEDIA_SUBDRV_AUTOSELECT is not set
CONFIG_VIDEO_IR_I2C=y

#
# I2C Encoders, decoders, sensors and other helper chips
#

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TVAUDIO=y
CONFIG_VIDEO_TDA7432=y
CONFIG_VIDEO_TDA9840=y
CONFIG_VIDEO_TEA6415C=y
CONFIG_VIDEO_TEA6420=y
# CONFIG_VIDEO_MSP3400 is not set
# CONFIG_VIDEO_CS3308 is not set
CONFIG_VIDEO_CS5345=y
# CONFIG_VIDEO_CS53L32A is not set
CONFIG_VIDEO_TLV320AIC23B=y
CONFIG_VIDEO_UDA1342=y
CONFIG_VIDEO_WM8775=y
# CONFIG_VIDEO_WM8739 is not set
# CONFIG_VIDEO_VP27SMPX is not set
# CONFIG_VIDEO_SONY_BTF_MPX is not set

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=y

#
# Video decoders
#
# CONFIG_VIDEO_ADV7183 is not set
# CONFIG_VIDEO_BT819 is not set
CONFIG_VIDEO_BT856=y
# CONFIG_VIDEO_BT866 is not set
CONFIG_VIDEO_KS0127=y
CONFIG_VIDEO_ML86V7667=y
CONFIG_VIDEO_SAA7110=y
CONFIG_VIDEO_SAA711X=y
CONFIG_VIDEO_TVP514X=y
CONFIG_VIDEO_TVP5150=y
# CONFIG_VIDEO_TVP7002 is not set
CONFIG_VIDEO_TW2804=y
CONFIG_VIDEO_TW9903=y
# CONFIG_VIDEO_TW9906 is not set
CONFIG_VIDEO_TW9910=y
# CONFIG_VIDEO_VPX3220 is not set

#
# Video and audio decoders
#
# CONFIG_VIDEO_SAA717X is not set
CONFIG_VIDEO_CX25840=y

#
# Video encoders
#
CONFIG_VIDEO_SAA7127=y
# CONFIG_VIDEO_SAA7185 is not set
# CONFIG_VIDEO_ADV7170 is not set
CONFIG_VIDEO_ADV7175=y
CONFIG_VIDEO_ADV7343=y
CONFIG_VIDEO_ADV7393=y
CONFIG_VIDEO_AK881X=y
# CONFIG_VIDEO_THS8200 is not set

#
# Camera sensor devices
#
CONFIG_VIDEO_OV2640=y
# CONFIG_VIDEO_OV2659 is not set
# CONFIG_VIDEO_OV6650 is not set
CONFIG_VIDEO_OV5695=y
CONFIG_VIDEO_OV772X=y
CONFIG_VIDEO_OV7640=y
CONFIG_VIDEO_OV7670=y
CONFIG_VIDEO_OV7740=y
CONFIG_VIDEO_OV9640=y
CONFIG_VIDEO_VS6624=y
CONFIG_VIDEO_MT9M111=y
CONFIG_VIDEO_MT9T112=y
CONFIG_VIDEO_MT9V011=y
CONFIG_VIDEO_MT9V111=y
CONFIG_VIDEO_SR030PC30=y
CONFIG_VIDEO_RJ54N1=y

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
# CONFIG_SDR_MAX2175 is not set

#
# Miscellaneous helper chips
#
CONFIG_VIDEO_THS7303=y
# CONFIG_VIDEO_M52790 is not set
# CONFIG_VIDEO_I2C is not set

#
# SPI helper chips
#

#
# Media SPI Adapters
#
# CONFIG_CXD2880_SPI_DRV is not set
CONFIG_MEDIA_TUNER=y

#
# Customize TV tuners
#
# CONFIG_MEDIA_TUNER_SIMPLE is not set
CONFIG_MEDIA_TUNER_TDA18250=y
# CONFIG_MEDIA_TUNER_TDA8290 is not set
# CONFIG_MEDIA_TUNER_TDA827X is not set
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MSI001=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_MT2060=y
CONFIG_MEDIA_TUNER_MT2063=y
# CONFIG_MEDIA_TUNER_MT2266 is not set
CONFIG_MEDIA_TUNER_MT2131=y
# CONFIG_MEDIA_TUNER_QT1010 is not set
CONFIG_MEDIA_TUNER_XC2028=y
# CONFIG_MEDIA_TUNER_XC5000 is not set
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MXL5005S=y
CONFIG_MEDIA_TUNER_MXL5007T=y
# CONFIG_MEDIA_TUNER_MC44S803 is not set
CONFIG_MEDIA_TUNER_MAX2165=y
CONFIG_MEDIA_TUNER_TDA18218=y
CONFIG_MEDIA_TUNER_FC0011=y
# CONFIG_MEDIA_TUNER_FC0012 is not set
CONFIG_MEDIA_TUNER_FC0013=y
CONFIG_MEDIA_TUNER_TDA18212=y
# CONFIG_MEDIA_TUNER_E4000 is not set
CONFIG_MEDIA_TUNER_FC2580=y
# CONFIG_MEDIA_TUNER_M88RS6000T is not set
# CONFIG_MEDIA_TUNER_TUA9001 is not set
# CONFIG_MEDIA_TUNER_SI2157 is not set
# CONFIG_MEDIA_TUNER_IT913X is not set
CONFIG_MEDIA_TUNER_R820T=y
CONFIG_MEDIA_TUNER_MXL301RF=y
# CONFIG_MEDIA_TUNER_QM1D1C0042 is not set
CONFIG_MEDIA_TUNER_QM1D1B0004=y

#
# Customise DVB Frontends
#

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STB0899=y
# CONFIG_DVB_STB6100 is not set
CONFIG_DVB_STV090x=y
CONFIG_DVB_STV0910=y
# CONFIG_DVB_STV6110x is not set
CONFIG_DVB_STV6111=y
CONFIG_DVB_MXL5XX=y
CONFIG_DVB_M88DS3103=y

#
# Multistandard (cable + terrestrial) frontends
#
# CONFIG_DVB_DRXK is not set
CONFIG_DVB_TDA18271C2DD=y
CONFIG_DVB_SI2165=y
CONFIG_DVB_MN88472=y
CONFIG_DVB_MN88473=y

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24110=y
CONFIG_DVB_CX24123=y
CONFIG_DVB_MT312=y
CONFIG_DVB_ZL10036=y
CONFIG_DVB_ZL10039=y
CONFIG_DVB_S5H1420=y
# CONFIG_DVB_STV0288 is not set
CONFIG_DVB_STB6000=y
CONFIG_DVB_STV0299=y
# CONFIG_DVB_STV6110 is not set
# CONFIG_DVB_STV0900 is not set
CONFIG_DVB_TDA8083=y
# CONFIG_DVB_TDA10086 is not set
# CONFIG_DVB_TDA8261 is not set
CONFIG_DVB_VES1X93=y
CONFIG_DVB_TUNER_ITD1000=y
CONFIG_DVB_TUNER_CX24113=y
# CONFIG_DVB_TDA826X is not set
# CONFIG_DVB_TUA6100 is not set
# CONFIG_DVB_CX24116 is not set
CONFIG_DVB_CX24117=y
# CONFIG_DVB_CX24120 is not set
CONFIG_DVB_SI21XX=y
CONFIG_DVB_TS2020=y
CONFIG_DVB_DS3000=y
# CONFIG_DVB_MB86A16 is not set
CONFIG_DVB_TDA10071=y

#
# DVB-T (terrestrial) frontends
#
# CONFIG_DVB_SP8870 is not set
CONFIG_DVB_SP887X=y
# CONFIG_DVB_CX22700 is not set
CONFIG_DVB_CX22702=y
CONFIG_DVB_S5H1432=y
CONFIG_DVB_DRXD=y
CONFIG_DVB_L64781=y
CONFIG_DVB_TDA1004X=y
# CONFIG_DVB_NXT6000 is not set
# CONFIG_DVB_MT352 is not set
CONFIG_DVB_ZL10353=y
# CONFIG_DVB_DIB3000MB is not set
CONFIG_DVB_DIB3000MC=y
# CONFIG_DVB_DIB7000M is not set
CONFIG_DVB_DIB7000P=y
# CONFIG_DVB_DIB9000 is not set
CONFIG_DVB_TDA10048=y
CONFIG_DVB_AF9013=y
CONFIG_DVB_EC100=y
# CONFIG_DVB_STV0367 is not set
CONFIG_DVB_CXD2820R=y
CONFIG_DVB_CXD2841ER=y
CONFIG_DVB_RTL2830=y
CONFIG_DVB_RTL2832=y
CONFIG_DVB_RTL2832_SDR=y
CONFIG_DVB_SI2168=y
CONFIG_DVB_ZD1301_DEMOD=y
# CONFIG_DVB_CXD2880 is not set

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=y
CONFIG_DVB_TDA10021=y
# CONFIG_DVB_TDA10023 is not set
CONFIG_DVB_STV0297=y

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=y
# CONFIG_DVB_OR51211 is not set
# CONFIG_DVB_OR51132 is not set
CONFIG_DVB_BCM3510=y
# CONFIG_DVB_LGDT330X is not set
CONFIG_DVB_LGDT3305=y
CONFIG_DVB_LGDT3306A=y
CONFIG_DVB_LG2160=y
CONFIG_DVB_S5H1409=y
CONFIG_DVB_AU8522=y
CONFIG_DVB_AU8522_DTV=y
CONFIG_DVB_AU8522_V4L=y
CONFIG_DVB_S5H1411=y

#
# ISDB-T (terrestrial) frontends
#
# CONFIG_DVB_S921 is not set
CONFIG_DVB_DIB8000=y
# CONFIG_DVB_MB86A20S is not set

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#
CONFIG_DVB_TC90522=y
# CONFIG_DVB_MN88443X is not set

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=y
CONFIG_DVB_TUNER_DIB0070=y
CONFIG_DVB_TUNER_DIB0090=y

#
# SEC control devices for DVB-S
#
CONFIG_DVB_DRX39XYJ=y
# CONFIG_DVB_LNBH25 is not set
CONFIG_DVB_LNBH29=y
# CONFIG_DVB_LNBP21 is not set
CONFIG_DVB_LNBP22=y
CONFIG_DVB_ISL6405=y
CONFIG_DVB_ISL6421=y
CONFIG_DVB_ISL6423=y
CONFIG_DVB_A8293=y
# CONFIG_DVB_LGS8GL5 is not set
# CONFIG_DVB_LGS8GXX is not set
# CONFIG_DVB_ATBM8830 is not set
CONFIG_DVB_TDA665x=y
CONFIG_DVB_IX2505V=y
CONFIG_DVB_M88RS2000=y
CONFIG_DVB_AF9033=y
# CONFIG_DVB_HORUS3A is not set
CONFIG_DVB_ASCOT2E=y
CONFIG_DVB_HELENE=y

#
# Common Interface (EN50221) controller drivers
#
CONFIG_DVB_CXD2099=y
CONFIG_DVB_SP2=y

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
# CONFIG_DRM is not set
CONFIG_DRM_DP_CEC=y

#
# ARM devices
#

#
# ACP (Audio CoProcessor) Configuration
#

#
# AMD Library routines
#
CONFIG_DRM_XEN=y
CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=y

#
# Frame buffer Devices
#
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

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
CONFIG_FB_UVESA=y
# CONFIG_FB_VESA is not set
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
# CONFIG_FB_SM501 is not set
CONFIG_FB_SMSCUFX=y
CONFIG_FB_UDL=y
CONFIG_FB_IBM_GXT4500=y
CONFIG_FB_GOLDFISH=y
# CONFIG_FB_VIRTUAL is not set
CONFIG_XEN_FBDEV_FRONTEND=y
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
CONFIG_FB_HYPERV=y
CONFIG_FB_SIMPLE=y
# CONFIG_FB_SM712 is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_L4F00242T03=y
# CONFIG_LCD_LMS283GF05 is not set
CONFIG_LCD_LTV350QV=y
CONFIG_LCD_ILI922X=y
# CONFIG_LCD_ILI9320 is not set
CONFIG_LCD_TDO24M=y
# CONFIG_LCD_VGG2432A4 is not set
CONFIG_LCD_PLATFORM=y
CONFIG_LCD_AMS369FG06=y
CONFIG_LCD_LMS501KF03=y
CONFIG_LCD_HX8357=y
CONFIG_LCD_OTM3225A=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_LM3533=y
CONFIG_BACKLIGHT_DA9052=y
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_PM8941_WLED=y
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_ADP5520=y
CONFIG_BACKLIGHT_ADP8860=y
CONFIG_BACKLIGHT_ADP8870=y
CONFIG_BACKLIGHT_88PM860X=y
CONFIG_BACKLIGHT_PCF50633=y
CONFIG_BACKLIGHT_AAT2870=y
CONFIG_BACKLIGHT_LM3639=y
# CONFIG_BACKLIGHT_PANDORA is not set
CONFIG_BACKLIGHT_GPIO=y
# CONFIG_BACKLIGHT_LV5207LP is not set
CONFIG_BACKLIGHT_BD6107=y
CONFIG_BACKLIGHT_ARCXCNN=y
# CONFIG_BACKLIGHT_RAVE_SP is not set
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
CONFIG_LOGO_LINUX_VGA16=y
# CONFIG_LOGO_LINUX_CLUT224 is not set
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
# CONFIG_SOUND_OSS_CORE_PRECLAIM is not set
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_DMAENGINE_PCM=y
CONFIG_SND_SEQ_DEVICE=y
CONFIG_SND_RAWMIDI=y
CONFIG_SND_JACK=y
CONFIG_SND_JACK_INPUT_DEV=y
CONFIG_SND_OSSEMUL=y
# CONFIG_SND_MIXER_OSS is not set
CONFIG_SND_PCM_OSS=y
CONFIG_SND_PCM_OSS_PLUGINS=y
# CONFIG_SND_PCM_TIMER is not set
# CONFIG_SND_DYNAMIC_MINORS is not set
# CONFIG_SND_SUPPORT_OLD_API is not set
# CONFIG_SND_PROC_FS is not set
CONFIG_SND_VERBOSE_PRINTK=y
# CONFIG_SND_DEBUG is not set
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_SEQUENCER=y
CONFIG_SND_SEQ_DUMMY=y
CONFIG_SND_SEQUENCER_OSS=y
CONFIG_SND_SEQ_MIDI_EVENT=y
CONFIG_SND_SEQ_MIDI=y
# CONFIG_SND_DRIVERS is not set
CONFIG_SND_PCI=y
# CONFIG_SND_AD1889 is not set
# CONFIG_SND_ASIHPI is not set
# CONFIG_SND_ATIIXP is not set
# CONFIG_SND_ATIIXP_MODEM is not set
# CONFIG_SND_AU8810 is not set
# CONFIG_SND_AU8820 is not set
# CONFIG_SND_AU8830 is not set
# CONFIG_SND_AW2 is not set
# CONFIG_SND_BT87X is not set
# CONFIG_SND_CA0106 is not set
# CONFIG_SND_CMIPCI is not set
# CONFIG_SND_OXYGEN is not set
# CONFIG_SND_CS4281 is not set
# CONFIG_SND_CS46XX is not set
# CONFIG_SND_CTXFI is not set
# CONFIG_SND_DARLA20 is not set
# CONFIG_SND_GINA20 is not set
# CONFIG_SND_LAYLA20 is not set
# CONFIG_SND_DARLA24 is not set
# CONFIG_SND_GINA24 is not set
# CONFIG_SND_LAYLA24 is not set
# CONFIG_SND_MONA is not set
# CONFIG_SND_MIA is not set
# CONFIG_SND_ECHO3G is not set
# CONFIG_SND_INDIGO is not set
# CONFIG_SND_INDIGOIO is not set
# CONFIG_SND_INDIGODJ is not set
# CONFIG_SND_INDIGOIOX is not set
# CONFIG_SND_INDIGODJX is not set
# CONFIG_SND_ENS1370 is not set
# CONFIG_SND_ENS1371 is not set
# CONFIG_SND_FM801 is not set
# CONFIG_SND_HDSP is not set
# CONFIG_SND_HDSPM is not set
# CONFIG_SND_ICE1724 is not set
# CONFIG_SND_INTEL8X0 is not set
# CONFIG_SND_INTEL8X0M is not set
# CONFIG_SND_KORG1212 is not set
# CONFIG_SND_LOLA is not set
# CONFIG_SND_LX6464ES is not set
# CONFIG_SND_MIXART is not set
# CONFIG_SND_NM256 is not set
# CONFIG_SND_PCXHR is not set
# CONFIG_SND_RIPTIDE is not set
# CONFIG_SND_RME32 is not set
# CONFIG_SND_RME96 is not set
# CONFIG_SND_RME9652 is not set
# CONFIG_SND_SE6X is not set
# CONFIG_SND_VIA82XX is not set
# CONFIG_SND_VIA82XX_MODEM is not set
# CONFIG_SND_VIRTUOSO is not set
# CONFIG_SND_VX222 is not set
# CONFIG_SND_YMFPCI is not set

#
# HD-Audio
#
# CONFIG_SND_HDA_INTEL is not set
CONFIG_SND_HDA_PREALLOC_SIZE=64
CONFIG_SND_SPI=y
# CONFIG_SND_USB is not set
CONFIG_SND_SOC=y
CONFIG_SND_SOC_GENERIC_DMAENGINE_PCM=y
CONFIG_SND_SOC_AMD_ACP=y
CONFIG_SND_SOC_AMD_CZ_DA7219MX98357_MACH=y
CONFIG_SND_SOC_AMD_CZ_RT5645_MACH=y
# CONFIG_SND_SOC_AMD_ACP3x is not set
CONFIG_SND_ATMEL_SOC=y
CONFIG_SND_DESIGNWARE_I2S=y
CONFIG_SND_DESIGNWARE_PCM=y

#
# SoC Audio for Freescale CPUs
#

#
# Common SoC Audio options for Freescale CPUs:
#
CONFIG_SND_SOC_FSL_ASRC=y
# CONFIG_SND_SOC_FSL_SAI is not set
# CONFIG_SND_SOC_FSL_SSI is not set
# CONFIG_SND_SOC_FSL_SPDIF is not set
# CONFIG_SND_SOC_FSL_ESAI is not set
CONFIG_SND_SOC_FSL_MICFIL=y
CONFIG_SND_SOC_IMX_AUDMUX=y
# CONFIG_SND_I2S_HI6210_I2S is not set
# CONFIG_SND_SOC_IMG is not set
# CONFIG_SND_SOC_INTEL_SST_TOPLEVEL is not set
# CONFIG_SND_SOC_MTK_BTCVSD is not set

#
# STMicroelectronics STM32 SOC audio support
#
CONFIG_SND_SOC_XILINX_I2S=y
CONFIG_SND_SOC_XILINX_AUDIO_FORMATTER=y
CONFIG_SND_SOC_XILINX_SPDIF=y
# CONFIG_SND_SOC_XTFPGA_I2S is not set
CONFIG_ZX_TDM=y
CONFIG_SND_SOC_I2C_AND_SPI=y

#
# CODEC drivers
#
# CONFIG_SND_SOC_AC97_CODEC is not set
CONFIG_SND_SOC_ADAU_UTILS=y
CONFIG_SND_SOC_ADAU1701=y
CONFIG_SND_SOC_ADAU17X1=y
CONFIG_SND_SOC_ADAU1761=y
# CONFIG_SND_SOC_ADAU1761_I2C is not set
CONFIG_SND_SOC_ADAU1761_SPI=y
CONFIG_SND_SOC_ADAU7002=y
CONFIG_SND_SOC_AK4104=y
CONFIG_SND_SOC_AK4118=y
CONFIG_SND_SOC_AK4458=y
# CONFIG_SND_SOC_AK4554 is not set
# CONFIG_SND_SOC_AK4613 is not set
CONFIG_SND_SOC_AK4642=y
# CONFIG_SND_SOC_AK5386 is not set
CONFIG_SND_SOC_AK5558=y
CONFIG_SND_SOC_ALC5623=y
CONFIG_SND_SOC_BD28623=y
# CONFIG_SND_SOC_BT_SCO is not set
CONFIG_SND_SOC_CROS_EC_CODEC=y
CONFIG_SND_SOC_CS35L32=y
CONFIG_SND_SOC_CS35L33=y
# CONFIG_SND_SOC_CS35L34 is not set
CONFIG_SND_SOC_CS35L35=y
CONFIG_SND_SOC_CS35L36=y
CONFIG_SND_SOC_CS42L42=y
# CONFIG_SND_SOC_CS42L51_I2C is not set
# CONFIG_SND_SOC_CS42L52 is not set
# CONFIG_SND_SOC_CS42L56 is not set
CONFIG_SND_SOC_CS42L73=y
CONFIG_SND_SOC_CS4265=y
# CONFIG_SND_SOC_CS4270 is not set
CONFIG_SND_SOC_CS4271=y
# CONFIG_SND_SOC_CS4271_I2C is not set
CONFIG_SND_SOC_CS4271_SPI=y
CONFIG_SND_SOC_CS42XX8=y
CONFIG_SND_SOC_CS42XX8_I2C=y
CONFIG_SND_SOC_CS43130=y
CONFIG_SND_SOC_CS4341=y
CONFIG_SND_SOC_CS4349=y
# CONFIG_SND_SOC_CS53L30 is not set
CONFIG_SND_SOC_DA7219=y
CONFIG_SND_SOC_DMIC=y
# CONFIG_SND_SOC_ES7134 is not set
# CONFIG_SND_SOC_ES7241 is not set
# CONFIG_SND_SOC_ES8316 is not set
CONFIG_SND_SOC_ES8328=y
# CONFIG_SND_SOC_ES8328_I2C is not set
CONFIG_SND_SOC_ES8328_SPI=y
CONFIG_SND_SOC_GTM601=y
CONFIG_SND_SOC_INNO_RK3036=y
CONFIG_SND_SOC_MAX98088=y
CONFIG_SND_SOC_MAX98357A=y
CONFIG_SND_SOC_MAX98504=y
# CONFIG_SND_SOC_MAX9867 is not set
CONFIG_SND_SOC_MAX98927=y
# CONFIG_SND_SOC_MAX98373 is not set
CONFIG_SND_SOC_MAX9860=y
# CONFIG_SND_SOC_MSM8916_WCD_ANALOG is not set
CONFIG_SND_SOC_MSM8916_WCD_DIGITAL=y
CONFIG_SND_SOC_PCM1681=y
CONFIG_SND_SOC_PCM1789=y
CONFIG_SND_SOC_PCM1789_I2C=y
CONFIG_SND_SOC_PCM179X=y
CONFIG_SND_SOC_PCM179X_I2C=y
CONFIG_SND_SOC_PCM179X_SPI=y
CONFIG_SND_SOC_PCM186X=y
CONFIG_SND_SOC_PCM186X_I2C=y
CONFIG_SND_SOC_PCM186X_SPI=y
CONFIG_SND_SOC_PCM3060=y
CONFIG_SND_SOC_PCM3060_I2C=y
# CONFIG_SND_SOC_PCM3060_SPI is not set
CONFIG_SND_SOC_PCM3168A=y
CONFIG_SND_SOC_PCM3168A_I2C=y
# CONFIG_SND_SOC_PCM3168A_SPI is not set
CONFIG_SND_SOC_PCM512x=y
CONFIG_SND_SOC_PCM512x_I2C=y
# CONFIG_SND_SOC_PCM512x_SPI is not set
CONFIG_SND_SOC_RK3328=y
CONFIG_SND_SOC_RL6231=y
CONFIG_SND_SOC_RT5616=y
CONFIG_SND_SOC_RT5631=y
CONFIG_SND_SOC_RT5645=y
CONFIG_SND_SOC_SGTL5000=y
CONFIG_SND_SOC_SIGMADSP=y
CONFIG_SND_SOC_SIGMADSP_I2C=y
CONFIG_SND_SOC_SIGMADSP_REGMAP=y
CONFIG_SND_SOC_SIMPLE_AMPLIFIER=y
# CONFIG_SND_SOC_SIRF_AUDIO_CODEC is not set
CONFIG_SND_SOC_SPDIF=y
# CONFIG_SND_SOC_SSM2305 is not set
CONFIG_SND_SOC_SSM2602=y
CONFIG_SND_SOC_SSM2602_SPI=y
CONFIG_SND_SOC_SSM2602_I2C=y
# CONFIG_SND_SOC_SSM4567 is not set
CONFIG_SND_SOC_STA32X=y
CONFIG_SND_SOC_STA350=y
# CONFIG_SND_SOC_STI_SAS is not set
CONFIG_SND_SOC_TAS2552=y
# CONFIG_SND_SOC_TAS5086 is not set
CONFIG_SND_SOC_TAS571X=y
CONFIG_SND_SOC_TAS5720=y
CONFIG_SND_SOC_TAS6424=y
CONFIG_SND_SOC_TDA7419=y
# CONFIG_SND_SOC_TFA9879 is not set
CONFIG_SND_SOC_TLV320AIC23=y
# CONFIG_SND_SOC_TLV320AIC23_I2C is not set
CONFIG_SND_SOC_TLV320AIC23_SPI=y
CONFIG_SND_SOC_TLV320AIC31XX=y
CONFIG_SND_SOC_TLV320AIC32X4=y
CONFIG_SND_SOC_TLV320AIC32X4_I2C=y
CONFIG_SND_SOC_TLV320AIC32X4_SPI=y
# CONFIG_SND_SOC_TLV320AIC3X is not set
CONFIG_SND_SOC_TS3A227E=y
CONFIG_SND_SOC_TSCS42XX=y
CONFIG_SND_SOC_TSCS454=y
CONFIG_SND_SOC_WCD9335=y
# CONFIG_SND_SOC_WM8510 is not set
CONFIG_SND_SOC_WM8523=y
CONFIG_SND_SOC_WM8524=y
CONFIG_SND_SOC_WM8580=y
# CONFIG_SND_SOC_WM8711 is not set
# CONFIG_SND_SOC_WM8728 is not set
CONFIG_SND_SOC_WM8731=y
CONFIG_SND_SOC_WM8737=y
# CONFIG_SND_SOC_WM8741 is not set
CONFIG_SND_SOC_WM8750=y
CONFIG_SND_SOC_WM8753=y
# CONFIG_SND_SOC_WM8770 is not set
# CONFIG_SND_SOC_WM8776 is not set
CONFIG_SND_SOC_WM8782=y
CONFIG_SND_SOC_WM8804=y
CONFIG_SND_SOC_WM8804_I2C=y
CONFIG_SND_SOC_WM8804_SPI=y
CONFIG_SND_SOC_WM8903=y
CONFIG_SND_SOC_WM8904=y
CONFIG_SND_SOC_WM8960=y
# CONFIG_SND_SOC_WM8962 is not set
CONFIG_SND_SOC_WM8974=y
# CONFIG_SND_SOC_WM8978 is not set
# CONFIG_SND_SOC_WM8985 is not set
CONFIG_SND_SOC_ZX_AUD96P22=y
CONFIG_SND_SOC_MAX9759=y
# CONFIG_SND_SOC_MT6351 is not set
# CONFIG_SND_SOC_MT6358 is not set
# CONFIG_SND_SOC_NAU8540 is not set
# CONFIG_SND_SOC_NAU8810 is not set
# CONFIG_SND_SOC_NAU8822 is not set
# CONFIG_SND_SOC_NAU8824 is not set
CONFIG_SND_SOC_TPA6130A2=y
CONFIG_SND_SIMPLE_CARD_UTILS=y
CONFIG_SND_SIMPLE_CARD=y
CONFIG_SND_X86=y
CONFIG_SND_XEN_FRONTEND=y

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
CONFIG_HIDRAW=y
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
CONFIG_HID_ACCUTOUCH=y
CONFIG_HID_ACRUX=y
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
# CONFIG_HID_APPLEIR is not set
CONFIG_HID_ASUS=y
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=y
# CONFIG_HID_BETOP_FF is not set
CONFIG_HID_BIGBEN_FF=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
# CONFIG_HID_CORSAIR is not set
CONFIG_HID_COUGAR=y
CONFIG_HID_PRODIKEYS=y
CONFIG_HID_CMEDIA=y
CONFIG_HID_CP2112=y
CONFIG_HID_CYPRESS=y
# CONFIG_HID_DRAGONRISE is not set
CONFIG_HID_EMS_FF=y
# CONFIG_HID_ELAN is not set
# CONFIG_HID_ELECOM is not set
CONFIG_HID_ELO=y
CONFIG_HID_EZKEY=y
CONFIG_HID_GEMBIRD=y
CONFIG_HID_GFRM=y
CONFIG_HID_HOLTEK=y
# CONFIG_HOLTEK_FF is not set
CONFIG_HID_GOOGLE_HAMMER=y
# CONFIG_HID_GT683R is not set
# CONFIG_HID_KEYTOUCH is not set
CONFIG_HID_KYE=y
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
CONFIG_HID_VIEWSONIC=y
CONFIG_HID_GYRATION=y
# CONFIG_HID_ICADE is not set
CONFIG_HID_ITE=y
CONFIG_HID_JABRA=y
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
CONFIG_HID_LED=y
CONFIG_HID_LENOVO=y
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=y
CONFIG_HID_LOGITECH_HIDPP=y
CONFIG_LOGITECH_FF=y
# CONFIG_LOGIRUMBLEPAD2_FF is not set
CONFIG_LOGIG940_FF=y
CONFIG_LOGIWHEELS_FF=y
CONFIG_HID_MAGICMOUSE=y
# CONFIG_HID_MALTRON is not set
# CONFIG_HID_MAYFLASH is not set
CONFIG_HID_REDRAGON=y
# CONFIG_HID_MICROSOFT is not set
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_NTI is not set
CONFIG_HID_NTRIG=y
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
CONFIG_HID_PENMOUNT=y
CONFIG_HID_PETALYNX=y
CONFIG_HID_PICOLCD=y
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
# CONFIG_HID_PICOLCD_LCD is not set
CONFIG_HID_PICOLCD_LEDS=y
# CONFIG_HID_PICOLCD_CIR is not set
CONFIG_HID_PLANTRONICS=y
CONFIG_HID_PRIMAX=y
CONFIG_HID_RETRODE=y
# CONFIG_HID_ROCCAT is not set
# CONFIG_HID_SAITEK is not set
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SONY=y
CONFIG_SONY_FF=y
CONFIG_HID_SPEEDLINK=y
# CONFIG_HID_STEAM is not set
# CONFIG_HID_STEELSERIES is not set
# CONFIG_HID_SUNPLUS is not set
CONFIG_HID_RMI=y
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_HYPERV_MOUSE=y
CONFIG_HID_SMARTJOYPLUS=y
CONFIG_SMARTJOYPLUS_FF=y
CONFIG_HID_TIVO=y
CONFIG_HID_TOPSEED=y
CONFIG_HID_THINGM=y
CONFIG_HID_THRUSTMASTER=y
# CONFIG_THRUSTMASTER_FF is not set
CONFIG_HID_UDRAW_PS3=y
# CONFIG_HID_WACOM is not set
CONFIG_HID_WIIMOTE=y
# CONFIG_HID_XINMO is not set
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
CONFIG_HID_SENSOR_HUB=y
# CONFIG_HID_SENSOR_CUSTOM_SENSOR is not set
CONFIG_HID_ALPS=y

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
# CONFIG_USB_HIDDEV is not set

#
# I2C HID support
#
CONFIG_I2C_HID=y

#
# Intel ISH HID support
#
# CONFIG_INTEL_ISH_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
CONFIG_USB_PCI=y
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
# CONFIG_USB_DEFAULT_PERSIST is not set
CONFIG_USB_DYNAMIC_MINORS=y
# CONFIG_USB_OTG is not set
# CONFIG_USB_OTG_WHITELIST is not set
CONFIG_USB_OTG_BLACKLIST_HUB=y
CONFIG_USB_LEDS_TRIGGER_USBPORT=y
CONFIG_USB_AUTOSUSPEND_DELAY=2
CONFIG_USB_MON=y
CONFIG_USB_WUSB=y
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
CONFIG_USB_XHCI_HCD=y
# CONFIG_USB_XHCI_DBGCAP is not set
CONFIG_USB_XHCI_PCI=y
CONFIG_USB_XHCI_PLATFORM=y
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
CONFIG_USB_EHCI_PCI=y
# CONFIG_USB_EHCI_FSL is not set
CONFIG_USB_EHCI_HCD_PLATFORM=y
CONFIG_USB_OXU210HP_HCD=y
CONFIG_USB_ISP116X_HCD=y
CONFIG_USB_FOTG210_HCD=y
# CONFIG_USB_MAX3421_HCD is not set
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
CONFIG_USB_OHCI_HCD_SSB=y
CONFIG_USB_OHCI_HCD_PLATFORM=y
# CONFIG_USB_UHCI_HCD is not set
CONFIG_USB_U132_HCD=y
CONFIG_USB_SL811_HCD=y
# CONFIG_USB_SL811_HCD_ISO is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_WHCI_HCD is not set
CONFIG_USB_HWA_HCD=y
CONFIG_USB_HCD_SSB=y
CONFIG_USB_HCD_TEST_MODE=y

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
CONFIG_USB_PRINTER=y
CONFIG_USB_WDM=y
CONFIG_USB_TMC=y

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
# CONFIG_USB_STORAGE is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set
# CONFIG_USBIP_CORE is not set
CONFIG_USB_MUSB_HDRC=y
CONFIG_USB_MUSB_HOST=y

#
# Platform Glue Layer
#

#
# MUSB DMA mode
#
# CONFIG_MUSB_PIO_ONLY is not set
# CONFIG_USB_DWC3 is not set
CONFIG_USB_DWC2=y
CONFIG_USB_DWC2_HOST=y

#
# Gadget/Dual-role mode requires USB Gadget support to be enabled
#
# CONFIG_USB_DWC2_PCI is not set
CONFIG_USB_DWC2_DEBUG=y
CONFIG_USB_DWC2_VERBOSE=y
CONFIG_USB_DWC2_TRACK_MISSED_SOFS=y
# CONFIG_USB_DWC2_DEBUG_PERIODIC is not set
CONFIG_USB_CHIPIDEA=y
CONFIG_USB_CHIPIDEA_PCI=y
CONFIG_USB_CHIPIDEA_HOST=y
CONFIG_USB_ISP1760=y
CONFIG_USB_ISP1760_HCD=y
CONFIG_USB_ISP1760_HOST_ROLE=y

#
# USB port drivers
#
# CONFIG_USB_USS720 is not set
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_RIO500 is not set
CONFIG_USB_LEGOTOWER=y
# CONFIG_USB_LCD is not set
CONFIG_USB_CYPRESS_CY7C63=y
CONFIG_USB_CYTHERM=y
# CONFIG_USB_IDMOUSE is not set
CONFIG_USB_FTDI_ELAN=y
CONFIG_USB_APPLEDISPLAY=y
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
CONFIG_USB_TRANCEVIBRATOR=y
# CONFIG_USB_IOWARRIOR is not set
CONFIG_USB_TEST=y
CONFIG_USB_EHSET_TEST_FIXTURE=y
CONFIG_USB_ISIGHTFW=y
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=y
# CONFIG_USB_HUB_USB251XB is not set
CONFIG_USB_HSIC_USB3503=y
CONFIG_USB_HSIC_USB4604=y
# CONFIG_USB_LINK_LAYER_TEST is not set
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
CONFIG_USB_GPIO_VBUS=y
# CONFIG_TAHVO_USB is not set
CONFIG_USB_ISP1301=y
# CONFIG_USB_GADGET is not set
CONFIG_TYPEC=y
CONFIG_TYPEC_TCPM=y
# CONFIG_TYPEC_TCPCI is not set
# CONFIG_TYPEC_FUSB302 is not set
CONFIG_TYPEC_UCSI=y
CONFIG_UCSI_CCG=y
CONFIG_UCSI_ACPI=y
# CONFIG_TYPEC_TPS6598X is not set

#
# USB Type-C Multiplexer/DeMultiplexer Switch support
#
CONFIG_TYPEC_MUX_PI3USB30532=y

#
# USB Type-C Alternate Mode drivers
#
# CONFIG_TYPEC_DP_ALTMODE is not set
CONFIG_USB_ROLE_SWITCH=y
CONFIG_USB_ROLES_INTEL_XHCI=y
# CONFIG_USB_LED_TRIG is not set
CONFIG_USB_ULPI_BUS=y
CONFIG_UWB=y
CONFIG_UWB_HWA=y
# CONFIG_UWB_WHCI is not set
CONFIG_UWB_I1480U=y
CONFIG_MMC=y
# CONFIG_MMC_BLOCK is not set
# CONFIG_SDIO_UART is not set
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_DEBUG is not set
CONFIG_MMC_SDHCI=y
# CONFIG_MMC_SDHCI_PCI is not set
# CONFIG_MMC_SDHCI_ACPI is not set
# CONFIG_MMC_SDHCI_PLTFM is not set
# CONFIG_MMC_TIFM_SD is not set
# CONFIG_MMC_GOLDFISH is not set
CONFIG_MMC_SPI=y
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
CONFIG_MMC_VUB300=y
CONFIG_MMC_USHC=y
CONFIG_MMC_USDHI6ROL0=y
CONFIG_MMC_CQHCI=y
# CONFIG_MMC_TOSHIBA_PCI is not set
# CONFIG_MMC_MTK is not set
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=y
# CONFIG_MS_BLOCK is not set

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_CLASS_FLASH=y
# CONFIG_LEDS_BRIGHTNESS_HW_CHANGED is not set

#
# LED drivers
#
CONFIG_LEDS_88PM860X=y
CONFIG_LEDS_AS3645A=y
# CONFIG_LEDS_LM3530 is not set
# CONFIG_LEDS_LM3533 is not set
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_LM3601X=y
CONFIG_LEDS_MT6323=y
CONFIG_LEDS_PCA9532=y
CONFIG_LEDS_PCA9532_GPIO=y
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_LP3944=y
# CONFIG_LEDS_LP3952 is not set
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=y
CONFIG_LEDS_PCA955X=y
# CONFIG_LEDS_PCA955X_GPIO is not set
CONFIG_LEDS_PCA963X=y
# CONFIG_LEDS_WM8350 is not set
# CONFIG_LEDS_DA9052 is not set
CONFIG_LEDS_DAC124S085=y
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
# CONFIG_LEDS_LT3593 is not set
CONFIG_LEDS_ADP5520=y
# CONFIG_LEDS_MC13783 is not set
CONFIG_LEDS_TCA6507=y
# CONFIG_LEDS_TLC591XX is not set
CONFIG_LEDS_MAX8997=y
# CONFIG_LEDS_LM355x is not set
CONFIG_LEDS_MENF21BMC=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
CONFIG_LEDS_MLXREG=y
CONFIG_LEDS_USER=y
CONFIG_LEDS_NIC78BX=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
CONFIG_LEDS_TRIGGER_ONESHOT=y
# CONFIG_LEDS_TRIGGER_DISK is not set
CONFIG_LEDS_TRIGGER_MTD=y
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
# CONFIG_LEDS_TRIGGER_CPU is not set
CONFIG_LEDS_TRIGGER_ACTIVITY=y
CONFIG_LEDS_TRIGGER_GPIO=y
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
# CONFIG_LEDS_TRIGGER_CAMERA is not set
CONFIG_LEDS_TRIGGER_PANIC=y
CONFIG_LEDS_TRIGGER_NETDEV=y
CONFIG_LEDS_TRIGGER_PATTERN=y
CONFIG_LEDS_TRIGGER_AUDIO=y
CONFIG_ACCESSIBILITY=y
# CONFIG_INFINIBAND is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_SYSTOHC is not set
CONFIG_RTC_DEBUG=y
CONFIG_RTC_NVMEM=y

#
# RTC interfaces
#
# CONFIG_RTC_INTF_SYSFS is not set
# CONFIG_RTC_INTF_PROC is not set
# CONFIG_RTC_INTF_DEV is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_88PM860X=y
CONFIG_RTC_DRV_ABB5ZES3=y
# CONFIG_RTC_DRV_ABEOZ9 is not set
CONFIG_RTC_DRV_ABX80X=y
CONFIG_RTC_DRV_DS1307=y
# CONFIG_RTC_DRV_DS1307_CENTURY is not set
# CONFIG_RTC_DRV_DS1374 is not set
CONFIG_RTC_DRV_DS1672=y
CONFIG_RTC_DRV_MAX6900=y
# CONFIG_RTC_DRV_MAX8998 is not set
CONFIG_RTC_DRV_MAX8997=y
CONFIG_RTC_DRV_RS5C372=y
CONFIG_RTC_DRV_ISL1208=y
CONFIG_RTC_DRV_ISL12022=y
# CONFIG_RTC_DRV_X1205 is not set
CONFIG_RTC_DRV_PCF8523=y
# CONFIG_RTC_DRV_PCF85063 is not set
CONFIG_RTC_DRV_PCF85363=y
# CONFIG_RTC_DRV_PCF8563 is not set
CONFIG_RTC_DRV_PCF8583=y
# CONFIG_RTC_DRV_M41T80 is not set
CONFIG_RTC_DRV_BQ32K=y
# CONFIG_RTC_DRV_PALMAS is not set
CONFIG_RTC_DRV_TPS6586X=y
# CONFIG_RTC_DRV_S35390A is not set
# CONFIG_RTC_DRV_FM3130 is not set
# CONFIG_RTC_DRV_RX8010 is not set
# CONFIG_RTC_DRV_RX8581 is not set
# CONFIG_RTC_DRV_RX8025 is not set
CONFIG_RTC_DRV_EM3027=y
CONFIG_RTC_DRV_RV3028=y
# CONFIG_RTC_DRV_RV8803 is not set
CONFIG_RTC_DRV_S5M=y
CONFIG_RTC_DRV_SD3078=y

#
# SPI RTC drivers
#
CONFIG_RTC_DRV_M41T93=y
# CONFIG_RTC_DRV_M41T94 is not set
CONFIG_RTC_DRV_DS1302=y
CONFIG_RTC_DRV_DS1305=y
# CONFIG_RTC_DRV_DS1343 is not set
# CONFIG_RTC_DRV_DS1347 is not set
# CONFIG_RTC_DRV_DS1390 is not set
# CONFIG_RTC_DRV_MAX6916 is not set
CONFIG_RTC_DRV_R9701=y
CONFIG_RTC_DRV_RX4581=y
CONFIG_RTC_DRV_RX6110=y
CONFIG_RTC_DRV_RS5C348=y
CONFIG_RTC_DRV_MAX6902=y
CONFIG_RTC_DRV_PCF2123=y
# CONFIG_RTC_DRV_MCP795 is not set
CONFIG_RTC_I2C_AND_SPI=y

#
# SPI and I2C RTC drivers
#
CONFIG_RTC_DRV_DS3232=y
CONFIG_RTC_DRV_PCF2127=y
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
# CONFIG_RTC_DRV_DS1286 is not set
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1685_FAMILY=y
# CONFIG_RTC_DRV_DS1685 is not set
CONFIG_RTC_DRV_DS1689=y
# CONFIG_RTC_DRV_DS17285 is not set
# CONFIG_RTC_DRV_DS17485 is not set
# CONFIG_RTC_DRV_DS17885 is not set
# CONFIG_RTC_DRV_DS1742 is not set
CONFIG_RTC_DRV_DS2404=y
# CONFIG_RTC_DRV_DA9052 is not set
# CONFIG_RTC_DRV_DA9063 is not set
CONFIG_RTC_DRV_STK17TA8=y
CONFIG_RTC_DRV_M48T86=y
CONFIG_RTC_DRV_M48T35=y
CONFIG_RTC_DRV_M48T59=y
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=y
CONFIG_RTC_DRV_RP5C01=y
CONFIG_RTC_DRV_V3020=y
CONFIG_RTC_DRV_WM8350=y
# CONFIG_RTC_DRV_PCF50633 is not set
CONFIG_RTC_DRV_AB3100=y
CONFIG_RTC_DRV_CROS_EC=y

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_FTRTC010=y
CONFIG_RTC_DRV_PCAP=y
# CONFIG_RTC_DRV_MC13XXX is not set
# CONFIG_RTC_DRV_MT6397 is not set

#
# HID Sensor RTC drivers
#
# CONFIG_DMADEVICES is not set

#
# DMABUF options
#
# CONFIG_SYNC_FILE is not set
# CONFIG_UDMABUF is not set
CONFIG_AUXDISPLAY=y
CONFIG_HD44780=y
CONFIG_KS0108=y
CONFIG_KS0108_PORT=0x378
CONFIG_KS0108_DELAY=2
CONFIG_CFAG12864B=y
CONFIG_CFAG12864B_RATE=20
# CONFIG_IMG_ASCII_LCD is not set
CONFIG_PARPORT_PANEL=y
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
CONFIG_PANEL_CHANGE_MESSAGE=y
CONFIG_PANEL_BOOT_MESSAGE=""
# CONFIG_CHARLCD_BL_OFF is not set
CONFIG_CHARLCD_BL_ON=y
# CONFIG_CHARLCD_BL_FLASH is not set
CONFIG_PANEL=y
CONFIG_CHARLCD=y
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV_GENIRQ=y
CONFIG_UIO_DMEM_GENIRQ=y
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
# CONFIG_UIO_PRUSS is not set
# CONFIG_UIO_MF624 is not set
CONFIG_UIO_HV_GENERIC=y
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y
# CONFIG_VIRTIO_MENU is not set

#
# Microsoft Hyper-V guest support
#
CONFIG_HYPERV=y
CONFIG_HYPERV_TSCPAGE=y
# CONFIG_HYPERV_UTILS is not set
CONFIG_HYPERV_BALLOON=y

#
# Xen driver support
#
CONFIG_XEN_BALLOON=y
# CONFIG_XEN_SCRUB_PAGES_DEFAULT is not set
CONFIG_XEN_DEV_EVTCHN=y
# CONFIG_XEN_BACKEND is not set
CONFIG_XENFS=y
# CONFIG_XEN_COMPAT_XENFS is not set
CONFIG_XEN_SYS_HYPERVISOR=y
CONFIG_XEN_XENBUS_FRONTEND=y
CONFIG_XEN_GNTDEV=y
CONFIG_XEN_GRANT_DEV_ALLOC=y
# CONFIG_XEN_GRANT_DMA_ALLOC is not set
CONFIG_SWIOTLB_XEN=y
CONFIG_XEN_TMEM=y
CONFIG_XEN_PVCALLS_FRONTEND=y
CONFIG_XEN_PRIVCMD=y
CONFIG_XEN_EFI=y
CONFIG_XEN_AUTO_XLATE=y
CONFIG_XEN_ACPI=y
CONFIG_XEN_FRONT_PGDIR_SHBUF=y
# CONFIG_STAGING is not set
# CONFIG_X86_PLATFORM_DEVICES is not set
CONFIG_PMC_ATOM=y
CONFIG_GOLDFISH_PIPE=y
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_PSTORE=y
CONFIG_CHROMEOS_TBMC=y
CONFIG_CROS_EC_I2C=y
# CONFIG_CROS_EC_SPI is not set
# CONFIG_CROS_EC_LPC is not set
CONFIG_CROS_EC_PROTO=y
CONFIG_CROS_KBD_LED_BACKLIGHT=y
# CONFIG_MELLANOX_PLATFORM is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
CONFIG_COMMON_CLK_MAX9485=y
CONFIG_COMMON_CLK_SI5351=y
# CONFIG_COMMON_CLK_SI544 is not set
CONFIG_COMMON_CLK_CDCE706=y
# CONFIG_COMMON_CLK_CS2000_CP is not set
CONFIG_COMMON_CLK_S2MPS11=y
# CONFIG_CLK_TWL6040 is not set
CONFIG_COMMON_CLK_PALMAS=y
CONFIG_HWSPINLOCK=y

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
CONFIG_MAILBOX=y
# CONFIG_PCC is not set
# CONFIG_ALTERA_MBOX is not set
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
# CONFIG_IOMMU_DEBUGFS is not set
# CONFIG_AMD_IOMMU is not set
# CONFIG_HYPERV_IOMMU is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y

#
# Rpmsg drivers
#
CONFIG_RPMSG=y
# CONFIG_RPMSG_CHAR is not set
# CONFIG_RPMSG_QCOM_GLINK_RPM is not set
CONFIG_RPMSG_VIRTIO=y
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
CONFIG_SOC_TI=y

#
# Xilinx SoC drivers
#
CONFIG_XILINX_VCU=y
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
# CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND is not set
# CONFIG_DEVFREQ_GOV_PERFORMANCE is not set
CONFIG_DEVFREQ_GOV_POWERSAVE=y
CONFIG_DEVFREQ_GOV_USERSPACE=y
CONFIG_DEVFREQ_GOV_PASSIVE=y

#
# DEVFREQ Drivers
#
# CONFIG_PM_DEVFREQ_EVENT is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_ARIZONA=y
CONFIG_EXTCON_GPIO=y
# CONFIG_EXTCON_INTEL_INT3496 is not set
# CONFIG_EXTCON_INTEL_CHT_WC is not set
CONFIG_EXTCON_MAX3355=y
CONFIG_EXTCON_MAX77693=y
# CONFIG_EXTCON_MAX77843 is not set
CONFIG_EXTCON_MAX8997=y
CONFIG_EXTCON_PALMAS=y
CONFIG_EXTCON_PTN5150=y
CONFIG_EXTCON_RT8973A=y
# CONFIG_EXTCON_SM5502 is not set
# CONFIG_EXTCON_USB_GPIO is not set
# CONFIG_EXTCON_USBC_CROS_EC is not set
CONFIG_MEMORY=y
# CONFIG_IIO is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set

#
# IRQ chip support
#
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
# CONFIG_SERIAL_IPOCTAL is not set
CONFIG_RESET_CONTROLLER=y
# CONFIG_RESET_TI_SYSCON is not set
CONFIG_FMC=y
CONFIG_FMC_FAKEDEV=y
CONFIG_FMC_TRIVIAL=y
# CONFIG_FMC_WRITE_EEPROM is not set
# CONFIG_FMC_CHARDEV is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_BCM_KONA_USB2_PHY=y
# CONFIG_PHY_PXA_28NM_HSIC is not set
CONFIG_PHY_PXA_28NM_USB2=y
CONFIG_PHY_QCOM_USB_HS=y
# CONFIG_PHY_QCOM_USB_HSIC is not set
CONFIG_PHY_SAMSUNG_USB2=y
# CONFIG_PHY_TUSB1210 is not set
CONFIG_POWERCAP=y
# CONFIG_IDLE_INJECT is not set
CONFIG_MCB=y
# CONFIG_MCB_PCI is not set
CONFIG_MCB_LPC=y

#
# Performance monitor support
#
# CONFIG_RAS is not set
# CONFIG_THUNDERBOLT is not set

#
# Android
#
# CONFIG_ANDROID is not set
# CONFIG_LIBNVDIMM is not set
CONFIG_DAX=y
CONFIG_NVMEM=y
CONFIG_RAVE_SP_EEPROM=y

#
# HW tracing support
#
CONFIG_STM=y
CONFIG_STM_PROTO_BASIC=y
# CONFIG_STM_PROTO_SYS_T is not set
CONFIG_STM_DUMMY=y
CONFIG_STM_SOURCE_CONSOLE=y
CONFIG_STM_SOURCE_HEARTBEAT=y
CONFIG_STM_SOURCE_FTRACE=y
CONFIG_INTEL_TH=y
# CONFIG_INTEL_TH_PCI is not set
CONFIG_INTEL_TH_ACPI=y
CONFIG_INTEL_TH_GTH=y
CONFIG_INTEL_TH_STH=y
CONFIG_INTEL_TH_MSU=y
CONFIG_INTEL_TH_PTI=y
CONFIG_INTEL_TH_DEBUG=y
CONFIG_FPGA=y
CONFIG_ALTERA_PR_IP_CORE=y
# CONFIG_FPGA_MGR_ALTERA_PS_SPI is not set
# CONFIG_FPGA_MGR_ALTERA_CVP is not set
CONFIG_FPGA_MGR_XILINX_SPI=y
CONFIG_FPGA_MGR_MACHXO2_SPI=y
CONFIG_FPGA_BRIDGE=y
CONFIG_ALTERA_FREEZE_BRIDGE=y
CONFIG_XILINX_PR_DECOUPLER=y
CONFIG_FPGA_REGION=y
CONFIG_FPGA_DFL=y
CONFIG_FPGA_DFL_FME=y
# CONFIG_FPGA_DFL_FME_MGR is not set
CONFIG_FPGA_DFL_FME_BRIDGE=y
CONFIG_FPGA_DFL_FME_REGION=y
CONFIG_FPGA_DFL_AFU=y
# CONFIG_FPGA_DFL_PCI is not set
CONFIG_PM_OPP=y
CONFIG_UNISYS_VISORBUS=y
CONFIG_SIOX=y
CONFIG_SIOX_BUS_GPIO=y
CONFIG_SLIMBUS=y
CONFIG_SLIM_QCOM_CTRL=y
# CONFIG_INTERCONNECT is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
# CONFIG_VALIDATE_FS_PARSER is not set
CONFIG_FS_IOMAP=y
CONFIG_EXT2_FS=y
# CONFIG_EXT2_FS_XATTR is not set
CONFIG_EXT3_FS=y
CONFIG_EXT3_FS_POSIX_ACL=y
# CONFIG_EXT3_FS_SECURITY is not set
CONFIG_EXT4_FS=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
# CONFIG_REISERFS_FS_XATTR is not set
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=y
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
CONFIG_XFS_RT=y
# CONFIG_XFS_ONLINE_SCRUB is not set
CONFIG_XFS_WARN=y
# CONFIG_XFS_DEBUG is not set
CONFIG_GFS2_FS=y
CONFIG_GFS2_FS_LOCKING_DLM=y
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
# CONFIG_BTRFS_FS_POSIX_ACL is not set
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
# CONFIG_BTRFS_DEBUG is not set
# CONFIG_BTRFS_ASSERT is not set
CONFIG_BTRFS_FS_REF_VERIFY=y
CONFIG_NILFS2_FS=y
CONFIG_F2FS_FS=y
CONFIG_F2FS_STAT_FS=y
CONFIG_F2FS_FS_XATTR=y
CONFIG_F2FS_FS_POSIX_ACL=y
CONFIG_F2FS_FS_SECURITY=y
# CONFIG_F2FS_CHECK_FS is not set
# CONFIG_F2FS_IO_TRACE is not set
# CONFIG_F2FS_FAULT_INJECTION is not set
CONFIG_FS_DAX=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
# CONFIG_EXPORTFS_BLOCK_OPS is not set
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
CONFIG_PRINT_QUOTA_WARNING=y
CONFIG_QUOTA_DEBUG=y
CONFIG_QUOTA_TREE=y
CONFIG_QFMT_V1=y
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
CONFIG_AUTOFS_FS=y
# CONFIG_FUSE_FS is not set
CONFIG_OVERLAY_FS=y
CONFIG_OVERLAY_FS_REDIRECT_DIR=y
# CONFIG_OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW is not set
CONFIG_OVERLAY_FS_INDEX=y
CONFIG_OVERLAY_FS_XINO_AUTO=y
CONFIG_OVERLAY_FS_METACOPY=y

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
CONFIG_FSCACHE_HISTOGRAM=y
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
# CONFIG_CACHEFILES is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
# CONFIG_JOLIET is not set
# CONFIG_ZISOFS is not set
CONFIG_UDF_FS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_FAT_DEFAULT_UTF8=y
CONFIG_NTFS_FS=y
# CONFIG_NTFS_DEBUG is not set
# CONFIG_NTFS_RW is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_SYSCTL=y
# CONFIG_PROC_PAGE_MONITOR is not set
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
# CONFIG_HUGETLBFS is not set
CONFIG_MEMFD_CREATE=y
CONFIG_ARCH_HAS_GIGANTIC_PAGE=y
CONFIG_CONFIGFS_FS=y
# CONFIG_EFIVAR_FS is not set
# CONFIG_MISC_FILESYSTEMS is not set
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
# CONFIG_NLS_CODEPAGE_850 is not set
CONFIG_NLS_CODEPAGE_852=y
# CONFIG_NLS_CODEPAGE_855 is not set
CONFIG_NLS_CODEPAGE_857=y
# CONFIG_NLS_CODEPAGE_860 is not set
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
# CONFIG_NLS_CODEPAGE_865 is not set
CONFIG_NLS_CODEPAGE_866=y
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
# CONFIG_NLS_CODEPAGE_949 is not set
CONFIG_NLS_CODEPAGE_874=y
# CONFIG_NLS_ISO8859_8 is not set
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=y
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
# CONFIG_NLS_ISO8859_3 is not set
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_14=y
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_KOI8_R=y
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
# CONFIG_NLS_MAC_CENTEURO is not set
# CONFIG_NLS_MAC_CROATIAN is not set
# CONFIG_NLS_MAC_CYRILLIC is not set
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
# CONFIG_NLS_UTF8 is not set
CONFIG_DLM=y
# CONFIG_DLM_DEBUG is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_KEYS_COMPAT=y
CONFIG_PERSISTENT_KEYRINGS=y
# CONFIG_BIG_KEYS is not set
# CONFIG_ENCRYPTED_KEYS is not set
CONFIG_KEY_DH_OPERATIONS=y
CONFIG_SECURITY_DMESG_RESTRICT=y
# CONFIG_SECURITY is not set
# CONFIG_SECURITYFS is not set
# CONFIG_PAGE_TABLE_ISOLATION is not set
CONFIG_FORTIFY_SOURCE=y
# CONFIG_STATIC_USERMODEHELPER is not set
CONFIG_LSM="yama,loadpin,safesetid,integrity"
CONFIG_XOR_BLOCKS=y
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
CONFIG_CRYPTO_USER=y
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_SIMD=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
# CONFIG_CRYPTO_CHACHA20POLY1305 is not set
CONFIG_CRYPTO_AEGIS128=y
CONFIG_CRYPTO_AEGIS128L=y
CONFIG_CRYPTO_AEGIS256=y
# CONFIG_CRYPTO_AEGIS128_AESNI_SSE2 is not set
# CONFIG_CRYPTO_AEGIS128L_AESNI_SSE2 is not set
CONFIG_CRYPTO_AEGIS256_AESNI_SSE2=y
CONFIG_CRYPTO_MORUS640=y
# CONFIG_CRYPTO_MORUS640_SSE2 is not set
# CONFIG_CRYPTO_MORUS1280 is not set
CONFIG_CRYPTO_MORUS1280_GLUE=y
CONFIG_CRYPTO_MORUS1280_SSE2=y
CONFIG_CRYPTO_MORUS1280_AVX2=y
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CFB=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
# CONFIG_CRYPTO_LRW is not set
CONFIG_CRYPTO_OFB=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y
# CONFIG_CRYPTO_KEYWRAP is not set
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
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_POLY1305_X86_64=y
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
CONFIG_CRYPTO_RMD128=y
# CONFIG_CRYPTO_RMD160 is not set
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256_SSSE3=y
# CONFIG_CRYPTO_SHA512_SSSE3 is not set
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA3=y
CONFIG_CRYPTO_SM3=y
CONFIG_CRYPTO_STREEBOG=y
# CONFIG_CRYPTO_TGR192 is not set
# CONFIG_CRYPTO_WP512 is not set
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_TI=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
# CONFIG_CRYPTO_ARC4 is not set
CONFIG_CRYPTO_BLOWFISH=y
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
CONFIG_CRYPTO_DES3_EDE_X86_64=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_CHACHA20_X86_64=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=y
# CONFIG_CRYPTO_SM4 is not set
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
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
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_USER_API_RNG=y
CONFIG_CRYPTO_USER_API_AEAD=y
# CONFIG_CRYPTO_STATS is not set
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
# CONFIG_CRYPTO_DEV_PADLOCK_AES is not set
# CONFIG_CRYPTO_DEV_PADLOCK_SHA is not set
# CONFIG_CRYPTO_DEV_CCP is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCC is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXX is not set
# CONFIG_CRYPTO_DEV_QAT_C62X is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCCVF is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXXVF is not set
# CONFIG_CRYPTO_DEV_QAT_C62XVF is not set
# CONFIG_CRYPTO_DEV_VIRTIO is not set
# CONFIG_ASYMMETRIC_KEY_TYPE is not set

#
# Certificates for signature checking
#
CONFIG_SYSTEM_BLACKLIST_KEYRING=y
CONFIG_SYSTEM_BLACKLIST_HASH_LIST=""
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=y
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
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC64=y
CONFIG_CRC4=y
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
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
CONFIG_XZ_DEC_X86=y
# CONFIG_XZ_DEC_POWERPC is not set
# CONFIG_XZ_DEC_IA64 is not set
CONFIG_XZ_DEC_ARM=y
# CONFIG_XZ_DEC_ARMTHUMB is not set
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_DEC16=y
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
CONFIG_CMA_SIZE_MBYTES=0
CONFIG_CMA_SIZE_SEL_MBYTES=y
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8
# CONFIG_DMA_API_DEBUG is not set
CONFIG_SGL_ALLOC=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_DQL=y
CONFIG_GLOB=y
CONFIG_GLOB_SELFTEST=y
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
# CONFIG_DDR is not set
CONFIG_IRQ_POLL=y
CONFIG_MPILIB=y
CONFIG_UCS2_STRING=y
CONFIG_FONT_SUPPORT=y
CONFIG_FONT_8x16=y
CONFIG_FONT_AUTOSELECT=y
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_UACCESS_FLUSHCACHE=y
CONFIG_STACKDEPOT=y
CONFIG_SBITMAP=y
# CONFIG_STRING_SELFTEST is not set

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
CONFIG_FRAME_WARN=2048
CONFIG_STRIP_ASM_SYMS=y
CONFIG_READABLE_ASM=y
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CONFIG_STACK_VALIDATION=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
# CONFIG_MAGIC_SYSRQ_SERIAL is not set
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_PAGE_OWNER=y
# CONFIG_PAGE_POISONING is not set
CONFIG_DEBUG_PAGE_REF=y
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_OBJECTS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
# CONFIG_DEBUG_VM_VMACACHE is not set
CONFIG_DEBUG_VM_RB=y
# CONFIG_DEBUG_VM_PGFLAGS is not set
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
CONFIG_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_MEMORY_INIT is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KASAN=y
CONFIG_CC_HAS_KASAN_GENERIC=y
CONFIG_KASAN_STACK=1
CONFIG_ARCH_HAS_KCOV=y
CONFIG_CC_HAS_SANCOV_TRACE_PC=y
CONFIG_KCOV=y
# CONFIG_KCOV_INSTRUMENT_ALL is not set
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
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=1
# CONFIG_DETECT_HUNG_TASK is not set
CONFIG_WQ_WATCHDOG=y
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
CONFIG_PROVE_LOCKING=y
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_LOCKDEP=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_LOCK_TORTURE_TEST=y
# CONFIG_WW_MUTEX_SELFTEST is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_WARN_ALL_UNSEEDED_RANDOM is not set
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
CONFIG_DEBUG_PI_LIST=y
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
CONFIG_TORTURE_TEST=y
CONFIG_RCU_PERF_TEST=y
CONFIG_RCU_TORTURE_TEST=y
CONFIG_RCU_CPU_STALL_TIMEOUT=21
# CONFIG_RCU_TRACE is not set
# CONFIG_RCU_EQS_DEBUG is not set
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
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
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_PREEMPTIRQ_TRACEPOINTS=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
# CONFIG_FUNCTION_GRAPH_TRACER is not set
CONFIG_TRACE_PREEMPT_TOGGLE=y
CONFIG_PREEMPTIRQ_EVENTS=y
# CONFIG_IRQSOFF_TRACER is not set
# CONFIG_PREEMPT_TRACER is not set
# CONFIG_SCHED_TRACER is not set
# CONFIG_HWLAT_TRACER is not set
CONFIG_FTRACE_SYSCALLS=y
# CONFIG_TRACER_SNAPSHOT is not set
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
CONFIG_STACK_TRACER=y
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_UPROBE_EVENTS=y
CONFIG_BPF_EVENTS=y
CONFIG_DYNAMIC_EVENTS=y
CONFIG_PROBE_EVENTS=y
# CONFIG_DYNAMIC_FTRACE is not set
# CONFIG_FUNCTION_PROFILER is not set
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
CONFIG_TRACING_MAP=y
CONFIG_HIST_TRIGGERS=y
CONFIG_TRACEPOINT_BENCHMARK=y
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
CONFIG_TRACE_EVAL_MAP_FILE=y
CONFIG_TRACING_EVENTS_GPIO=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_RUNTIME_TESTING_MENU is not set
CONFIG_MEMTEST=y
# CONFIG_BUG_ON_DATA_CORRUPTION is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_UBSAN is not set
CONFIG_UBSAN_ALIGNMENT=y
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
# CONFIG_STRICT_DEVMEM is not set
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_X86_VERBOSE_BOOTUP=y
# CONFIG_EARLY_PRINTK is not set
CONFIG_X86_PTDUMP_CORE=y
CONFIG_X86_PTDUMP=y
# CONFIG_EFI_PGT_DUMP is not set
# CONFIG_DEBUG_WX is not set
# CONFIG_DOUBLEFAULT is not set
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_ENTRY is not set
CONFIG_DEBUG_NMI_SELFTEST=y
# CONFIG_X86_DEBUG_FPU is not set
# CONFIG_PUNIT_ATOM_DEBUG is not set
CONFIG_UNWINDER_ORC=y
# CONFIG_UNWINDER_FRAME_POINTER is not set

--=_5ca413c6.6e1RpLTvSig2RpCN6BdVKv6zspW2Szy5lyGUlDuJX7tL0uhQ--

