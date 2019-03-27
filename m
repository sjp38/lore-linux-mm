Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A850C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 10:56:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF98320651
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 10:56:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF98320651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=profihost.ag
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8755E6B0003; Wed, 27 Mar 2019 06:56:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 825736B0006; Wed, 27 Mar 2019 06:56:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 714676B0007; Wed, 27 Mar 2019 06:56:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 258936B0003
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 06:56:16 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id t16so3473734wmi.5
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 03:56:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:from
         :subject:cc:message-id:date:user-agent:mime-version:content-language
         :content-transfer-encoding;
        bh=/0g7oChqljqKuezSInItVZ2Rw4PQjcjEqmGfGEwZnTY=;
        b=qYJSl5xTdhPJmuDFFJbIQsL5pm2GlhWDF1ThgcB5Oc5pLXjo/2kdk+GxMN5NlTFEFv
         TokUy3+cPhkV4zNP6lpnt99idWC6r8IyKqLXipU9IUFGSZYv/TSOdCpDtyrjIi07jNhp
         T9Pu1XQ9Y+WvpYFSTOyCt5vHbb/qBr+bA8CNK5b3myVrhJuc3B7U5NVRQ7Pks5zhjHih
         +ViHmieHkJRCFDdqErHZn+kvKyMzSd7TEUq3lfl9JO277P8h9AqM23LQYGZUwuN/T0fK
         QR4jTbL5k0ggSyq33NfnysP2jD0xIl5Teh3e95grfms8XbzQffxAYzYjoEwPZlOjWk7+
         I9bw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
X-Gm-Message-State: APjAAAXTn9autxTKVb456pqSuAhYXy41CxgJFT1Rn16k7pdb4hHrCNhN
	6H5N2rm6+mFnQyfMPNSbdyIrre9nF554OMhAy2E9W9zjBs8TGq20cQBaUPw2L9JbXWpb+J7t76A
	toH8Bx/bszlFvU7oBMLOYu87A139CUtve2u/imtlb5I3bneqV61wa4fzvo16lhSg=
X-Received: by 2002:a1c:23cc:: with SMTP id j195mr12671277wmj.74.1553684175573;
        Wed, 27 Mar 2019 03:56:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoMOP0d9S6SGvZGEVUsr9qPfbl/MX9CPPewgAni/aIPhqforH7rSfYB2KZpN5tcDRwoZfX
X-Received: by 2002:a1c:23cc:: with SMTP id j195mr12671231wmj.74.1553684174626;
        Wed, 27 Mar 2019 03:56:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553684174; cv=none;
        d=google.com; s=arc-20160816;
        b=NuwV0QW+qchciMLK7zPCiNPQhJsag9b49I4vdGCd2Id4OPS4WeH+u/dHYtKngEdu/A
         zGDJDg3y8q9g5DAMdrrkYb0VaeLnKrxc4B1/FtB3K1zI2ZgAP35ca9yYZaZbq09JuC5D
         z105lCjaijJvgHjYexHg6QMiriYF1fOjWgaHl53dzOtvMCMQdKKxlyt8OgUW1iXFos+N
         ppeabfseKAzJO5S2+LjHhv6D/gZbhlkRFeFGukdzLIkIjnnxRBUAgJ8EH12kmuMvfFvJ
         CUwaWMzQGwLriSo774WEAIV2MKxqZd3kuSlE/e9Cj2NNPqOlmLUKaL2gpSXZEVXhqj0F
         vd9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:cc:subject:from:to;
        bh=/0g7oChqljqKuezSInItVZ2Rw4PQjcjEqmGfGEwZnTY=;
        b=J6R7vErsxaheQp4HdAMCeVC/J2PaHbkAdi2tIe1vd9l3OLj5E9fYQjz4H/fef1BpSg
         EW2xndjOA1qqeTxgX6VS4rGa2053iCvBHllYL7ioRlOWSE0OccO02blhyU61tW2Va8SD
         t9yqYBCCYaDOnUIdmrP0YFwbiLNxO3FzpGfv0BnnIArizBRoD+FzKP78pczDGljL9LZw
         GoRbm0Nd2adeJyMsXWolDWd3l+pFLn4hkoZUkjnSMA6+UMvUuXBtI98bNCOlspDtll6y
         VWqdUav5FL+7RRME5j6AFLaG5VSMNUhZ6St+8QMZNnQOwqPgeTI2gTPh6OrwDDk+ZaM9
         HzEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
Received: from cloud1-vm154.de-nserver.de (cloud1-vm154.de-nserver.de. [178.250.10.56])
        by mx.google.com with ESMTPS id u20si12776412wmc.109.2019.03.27.03.56.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Mar 2019 03:56:14 -0700 (PDT)
Received-SPF: neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) client-ip=178.250.10.56;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
Received: (qmail 16389 invoked from network); 27 Mar 2019 11:56:14 +0100
X-Fcrdns: No
Received: from phoffice.de-nserver.de (HELO [10.11.11.165]) (185.39.223.5)
  (smtp-auth username hostmaster@profihost.com, mechanism plain)
  by cloud1-vm154.de-nserver.de (qpsmtpd/0.92) with (ECDHE-RSA-AES256-GCM-SHA384 encrypted) ESMTPSA; Wed, 27 Mar 2019 11:56:14 +0100
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: debug linux kernel memory management / pressure
Cc: l.roehrs@profihost.ag,
 Daniel Aberger - Profihost AG <d.aberger@profihost.ag>,
 "n.fahldieck@profihost.ag" <n.fahldieck@profihost.ag>
Message-ID: <36329138-4a6f-9560-b36c-02dc528a8e12@profihost.ag>
Date: Wed, 27 Mar 2019 11:56:13 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-User-Auth: Auth by hostmaster@profihost.com through 185.39.223.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello list,

i hope this is the right place to ask. If not i would be happy to point
me to something else.

I'm seeing the following behaviour on some of our hosts running a SLES
15 kernel (kernel v4.12 as it's base) but i don't think it's related to
the kernel.

At some "random" interval - mostly 3-6 weeks of uptime. Suddenly mem
pressure rises and the linux cache (Cached: /proc/meminfo) drops from
12G to 3G. After that io pressure rises most probably due to low cache.
But at the same time i've MemFree und MemAvailable at 19-22G.

Why does this happen? How can i debug this situation? I would expect
that the page / file cache never drops if there is so much free mem.

Thanks a lot for your help.

Greets,
Stefan

Not sure whether needed but these are the vm. kernel settings:
vm.admin_reserve_kbytes = 8192
vm.block_dump = 0
vm.compact_unevictable_allowed = 1
vm.dirty_background_bytes = 0
vm.dirty_background_ratio = 10
vm.dirty_bytes = 0
vm.dirty_expire_centisecs = 3000
vm.dirty_ratio = 20
vm.dirty_writeback_centisecs = 500
vm.dirtytime_expire_seconds = 43200
vm.drop_caches = 0
vm.extfrag_threshold = 500
vm.hugepages_treat_as_movable = 0
vm.hugetlb_shm_group = 0
vm.laptop_mode = 0
vm.legacy_va_layout = 0
vm.lowmem_reserve_ratio = 256   256     32      1
vm.max_map_count = 65530
vm.memory_failure_early_kill = 0
vm.memory_failure_recovery = 1
vm.min_free_kbytes = 393216
vm.min_slab_ratio = 5
vm.min_unmapped_ratio = 1
vm.mmap_min_addr = 65536
vm.mmap_rnd_bits = 28
vm.mmap_rnd_compat_bits = 8
vm.nr_hugepages = 0
vm.nr_hugepages_mempolicy = 0
vm.nr_overcommit_hugepages = 0
vm.nr_pdflush_threads = 0
vm.numa_zonelist_order = default
vm.oom_dump_tasks = 1
vm.oom_kill_allocating_task = 0
vm.overcommit_kbytes = 0
vm.overcommit_memory = 0
vm.overcommit_ratio = 50
vm.page-cluster = 3
vm.panic_on_oom = 0
vm.percpu_pagelist_fraction = 0
vm.stat_interval = 1
vm.swappiness = 50
vm.user_reserve_kbytes = 131072
vm.vfs_cache_pressure = 100
vm.watermark_scale_factor = 10
vm.zone_reclaim_mode = 0

