Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 963C2C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 09:41:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1494820811
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 09:41:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1494820811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=profihost.ag
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC0056B000E; Fri, 29 Mar 2019 05:41:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A477C6B0269; Fri, 29 Mar 2019 05:41:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EA236B026A; Fri, 29 Mar 2019 05:41:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3DFA86B000E
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 05:41:20 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id e14so1280924wrt.18
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 02:41:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=C+gp/sFfABSI0IJhGTZoit6T68ALJASK6ybpPOqmEKA=;
        b=BGeyUZJkfCc4LI+JC2q7Vo3vvxCOv47c3sbIugrnmJAypzUE/WQvt1aTX2GAKyyZOR
         5JHzRcIiaSY/cmTouhheerhZAUKv8mY9gY+VdgNebe6xZASs6j/Wq2h2PK0YgM0hbJEt
         oBIkrejlZIO92ZqJd84nsQRP9+Kmkbgp/8drEADIBYpLq5zmO6OWLsKEHZDdeptm6RYQ
         MMvVJUhqtMzc+wi5zk0QDd3dzJSqS/ADc2vyKZLC5gdkwkgjJv7ZKFfDUktFdSAt7CmV
         jnw22z0/5M10jQPmlok2gH3cyQTsAOn7922fNFIkFa6mKwgsVrogBbuRYA80FZsTOmIE
         w5dA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
X-Gm-Message-State: APjAAAW0a0W/cyle0MXXv7kIipjYlJRAKdl2AdDZo/Jjo82Ygdt21FYQ
	Ah1T6UMpqXXG4y1c1KAMno2OqIVDEoH6pCrb90Fwhqhovl8c/Hls6NKgjlimUvNQfU94YcDAqNw
	HwWB8JWPvBQp7k2y5wo16rW1oErKVFgV1UcoDAtDRgVZGC7pesP3PEkVkXJu/PG8=
X-Received: by 2002:adf:afd0:: with SMTP id y16mr29346815wrd.328.1553852479734;
        Fri, 29 Mar 2019 02:41:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4BHrpQhDGXoPR52Xydwhy1UubDS5YNAbbHgYkEUY9SyCO09O1KoefOrFjy96SAog9Xjpo
X-Received: by 2002:adf:afd0:: with SMTP id y16mr29346768wrd.328.1553852478811;
        Fri, 29 Mar 2019 02:41:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553852478; cv=none;
        d=google.com; s=arc-20160816;
        b=HfkASAnq+M0mDLD1L3YQ4/74dWDQlPT4Y85wcQS7Hi0MaDKOem4y6H7euKQKqTZhF2
         z8ryldT1NI0xnYEmiJ4zMdHriw2pZcqAaQCAHwhLuvtJFaU0ltjyYmo5dIpr4+FFc3U1
         L4aQZE6CJAiEyRvsN0/qeBr+9ePZQdgD92gzXIaI5TDZr+LKGcCw7d1GM7AS5XKp9LuC
         gg21ioX4LMqxJx+UVbm1DgFvMIIrThIumR+7IWV7ZIBnJeHOfoA6TS1JfxP01un543oy
         o38B9O7eHWG8uBJ25GqYiMtqlG+GgD5TZp/Ev3+FT93uyFi/eIp+ecmal8E/qxnwmPzI
         qdzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=C+gp/sFfABSI0IJhGTZoit6T68ALJASK6ybpPOqmEKA=;
        b=WbS97Trg8z8zOs1gPxXhxMX0Ex35BXVNPvpayOQR25PxZhzvgEMAiP/phx/pKbD+sN
         j04WG07K/WZXQqYEVyRNr2nEl05tgVrjzKFX86KPtGybDym7M4xK3vVI7cndnt5qEUo2
         jxOa1s7dOeg11bM/GLjFaACbfOp67gqtfAH7Vo5VtzUYzLWNL4Lwia71c9d1jEdIaTRx
         n4TO3IPflC63hTuQwnM1CZFAJ7T/MdRIAfMdvWMjx5qeqrcTILAPblZb+Pf/I+AFmW/p
         f8HxL2ck6/5o3C/Ui/1pBJL9Y66J/uJz51RZ9/+ymKR14A3eF0x3HFihPIMST7V+ZRpE
         +hUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
Received: from cloud1-vm154.de-nserver.de (cloud1-vm154.de-nserver.de. [178.250.10.56])
        by mx.google.com with ESMTPS id g4si1015357wrm.317.2019.03.29.02.41.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 02:41:18 -0700 (PDT)
Received-SPF: neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) client-ip=178.250.10.56;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
Received: (qmail 31621 invoked from network); 29 Mar 2019 10:41:18 +0100
X-Fcrdns: No
Received: from phoffice.de-nserver.de (HELO [10.242.2.6]) (185.39.223.5)
  (smtp-auth username hostmaster@profihost.com, mechanism plain)
  by cloud1-vm154.de-nserver.de (qpsmtpd/0.92) with (ECDHE-RSA-AES256-GCM-SHA384 encrypted) ESMTPSA; Fri, 29 Mar 2019 10:41:18 +0100
Subject: Re: debug linux kernel memory management / pressure
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: l.roehrs@profihost.ag,
 Daniel Aberger - Profihost AG <d.aberger@profihost.ag>,
 "n.fahldieck@profihost.ag" <n.fahldieck@profihost.ag>
References: <36329138-4a6f-9560-b36c-02dc528a8e12@profihost.ag>
Message-ID: <3c98c75c-b554-499e-d42e-8b9286f3176b@profihost.ag>
Date: Fri, 29 Mar 2019 10:41:17 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <36329138-4a6f-9560-b36c-02dc528a8e12@profihost.ag>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-User-Auth: Auth by hostmaster@profihost.com through 185.39.223.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

nobody an idea? I had another system today:

# cat /proc/meminfo
MemTotal:       131911684 kB
MemFree:        25734836 kB
MemAvailable:   78158816 kB
Buffers:            2916 kB
Cached:         20650184 kB
SwapCached:       544016 kB
Active:         58999352 kB
Inactive:       10084060 kB
Active(anon):   43412532 kB
Inactive(anon):  5583220 kB
Active(file):   15586820 kB
Inactive(file):  4500840 kB
Unevictable:       35032 kB
Mlocked:           35032 kB
SwapTotal:       3905532 kB
SwapFree:              0 kB
Dirty:              1048 kB
Writeback:         20144 kB
AnonPages:      47923392 kB
Mapped:           775376 kB
Shmem:            561420 kB
Slab:           35798052 kB
SReclaimable:   34309112 kB
SUnreclaim:      1488940 kB
KernelStack:       42160 kB
PageTables:       248008 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:    69861372 kB
Committed_AS:   100328892 kB
VmallocTotal:   34359738367 kB
VmallocUsed:           0 kB
VmallocChunk:          0 kB
HardwareCorrupted:     0 kB
AnonHugePages:  19177472 kB
ShmemHugePages:        0 kB
ShmemPmdMapped:        0 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:      951376 kB
DirectMap2M:    87015424 kB
DirectMap1G:    48234496 kB

# cat /proc/buddyinfo
Node 0, zone      DMA      1      0      0      0      2      1      1
    0      1      1      3
Node 0, zone    DMA32    372    418    403    395    371    322    262
  179    114      0      0
Node 0, zone   Normal  89147  96397  76496  56407  41671  29289  18142
10278   4075      0      0
Node 1, zone   Normal 113266      0      1      1      1      1      1
    1      1      0      0

But with high PSI / memory pressure values above 10-30.

Greets,
Stefan
Am 27.03.19 um 11:56 schrieb Stefan Priebe - Profihost AG:
> Hello list,
> 
> i hope this is the right place to ask. If not i would be happy to point
> me to something else.
> 
> I'm seeing the following behaviour on some of our hosts running a SLES
> 15 kernel (kernel v4.12 as it's base) but i don't think it's related to
> the kernel.
> 
> At some "random" interval - mostly 3-6 weeks of uptime. Suddenly mem
> pressure rises and the linux cache (Cached: /proc/meminfo) drops from
> 12G to 3G. After that io pressure rises most probably due to low cache.
> But at the same time i've MemFree und MemAvailable at 19-22G.
> 
> Why does this happen? How can i debug this situation? I would expect
> that the page / file cache never drops if there is so much free mem.
> 
> Thanks a lot for your help.
> 
> Greets,
> Stefan
> 
> Not sure whether needed but these are the vm. kernel settings:
> vm.admin_reserve_kbytes = 8192
> vm.block_dump = 0
> vm.compact_unevictable_allowed = 1
> vm.dirty_background_bytes = 0
> vm.dirty_background_ratio = 10
> vm.dirty_bytes = 0
> vm.dirty_expire_centisecs = 3000
> vm.dirty_ratio = 20
> vm.dirty_writeback_centisecs = 500
> vm.dirtytime_expire_seconds = 43200
> vm.drop_caches = 0
> vm.extfrag_threshold = 500
> vm.hugepages_treat_as_movable = 0
> vm.hugetlb_shm_group = 0
> vm.laptop_mode = 0
> vm.legacy_va_layout = 0
> vm.lowmem_reserve_ratio = 256   256     32      1
> vm.max_map_count = 65530
> vm.memory_failure_early_kill = 0
> vm.memory_failure_recovery = 1
> vm.min_free_kbytes = 393216
> vm.min_slab_ratio = 5
> vm.min_unmapped_ratio = 1
> vm.mmap_min_addr = 65536
> vm.mmap_rnd_bits = 28
> vm.mmap_rnd_compat_bits = 8
> vm.nr_hugepages = 0
> vm.nr_hugepages_mempolicy = 0
> vm.nr_overcommit_hugepages = 0
> vm.nr_pdflush_threads = 0
> vm.numa_zonelist_order = default
> vm.oom_dump_tasks = 1
> vm.oom_kill_allocating_task = 0
> vm.overcommit_kbytes = 0
> vm.overcommit_memory = 0
> vm.overcommit_ratio = 50
> vm.page-cluster = 3
> vm.panic_on_oom = 0
> vm.percpu_pagelist_fraction = 0
> vm.stat_interval = 1
> vm.swappiness = 50
> vm.user_reserve_kbytes = 131072
> vm.vfs_cache_pressure = 100
> vm.watermark_scale_factor = 10
> vm.zone_reclaim_mode = 0
> 

