Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83099C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 10:37:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4652B21738
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 10:37:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4652B21738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D11246B000E; Fri,  5 Apr 2019 06:37:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC0A56B0266; Fri,  5 Apr 2019 06:37:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB0A96B0269; Fri,  5 Apr 2019 06:37:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6D2416B000E
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 06:37:52 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c40so3010848eda.10
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 03:37:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=R9SuVrVQgHhoCw3EVeXyjKEqziYpi6m09o0xOHqRy7k=;
        b=nsDuKaCh+4AGJvK+06FSLDrSxjEPvkaG+GtcSI3o8wQhXwLCv9RH6k8ciFPJtLSpzz
         4f/gRBhlE5rlqP2WCObcmgPhxVZrhG4a6E8iyWu4WpM0FG/e7ovthLP5FjZWTzLM/7Ri
         ZB7jqzKYZOFWhvfXaepRcf51gOCwjtdbgIwwxb9MMt9Paam5lGuKy8tDv/jvQbrMJmXs
         zeMf0ySnZGMkKmEG4jVFvTORX59PALULYUGLYBTIo7iCBB/xO60PFV/1ZeVhVWAyXJjg
         g21T24K99Pm5IFcMSfpF8e2e+ka3F6GK9OyPUMFweTxAlr2NWlbwfG3d1acPtXFiadAm
         cNpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUjekf22tpyK+LWvXpwy/3aVIjFKKL2utpKkeYTZ1hdOk1lE/FJ
	4htpki5ncSHcMa3Fmqy+cI8y3DgkNy4HpRLyr4UNdKZ/2pNLkEV0HL2fzyF2pEOOPK2j0O5UWVN
	aM3Wc2nad+yQlSCh7dP7OjSzBz4gdafq6MQsmCYJCjvuqQgERSUbJu9r8KxtjQOwekA==
X-Received: by 2002:a05:6402:1352:: with SMTP id y18mr7669275edw.100.1554460671907;
        Fri, 05 Apr 2019 03:37:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw57FoaWKT6+gdX7wRiRAWMbNPKu/ODMJJGPdqMS5dTlasl4mCaxy0+0fndUEcSbQO4KZ1U
X-Received: by 2002:a05:6402:1352:: with SMTP id y18mr7669211edw.100.1554460670813;
        Fri, 05 Apr 2019 03:37:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554460670; cv=none;
        d=google.com; s=arc-20160816;
        b=wOvNFRwYAvF2F2i+6bDlCMubuo40nIMlRCevC/n/HsJUh2fibWntFZX93TDLJN8fGS
         kwsg6FNP9H2cHso9VF+0uZT+FqOHVxr9/XSx2lgcrWCr8rhIyhzc8P6AXOS9yVkCDe81
         5y0ReedaArSLbo/ijKK75J9XzlOxSsTzl1JyxeRiq8LFKxV3DFNI55BMstplzqw2eoKv
         zj3JqTGemCuK5DIHE2S96WgJNdVR4h9Zfc/QyZvQIw5/id4KV5thXEsX+Qd1Vv0MBe8F
         O2IWqCLXZ8qKCW6TdYwStlO+Kgr/+4wJjXM5DoT3fVfwKHBEUcCV68/vwadYb1DzW+aB
         uL3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=R9SuVrVQgHhoCw3EVeXyjKEqziYpi6m09o0xOHqRy7k=;
        b=B+Nm5IdXlJ6hc76KvpMpR8ekZ/TS5PxKv+I6TpvPcOR6Tv91RHnF/l/FaqLserjMZa
         J8Djdc1XhR+8lrJ7Hg6IE4y8ryomuV/jmfgpc0CWewtYfNlMdr+8MOPOQA0Pe+5Ie5ni
         i0NaAxL+R/zwIr2msXkOJ75fPfMVW/OckGbCNSzSE0qqy/yQ6f761tJTuyGLU/M+oqLv
         mG7tczDtzSt9K/+jqnyMWRDuLe6qP1ZL85WvZuVmHwVtOd10gF5pPP5npxpFqHdE67Vv
         jX6KS8URI7TdlSnMhocKZnjXrVaY6zx8n+pvnqp+kq2BVnd9em1zKYvsZ6/zSUa6RalE
         KxYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f43si3157398edf.196.2019.04.05.03.37.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 03:37:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D67A3AE0F;
	Fri,  5 Apr 2019 10:37:49 +0000 (UTC)
Subject: Re: debug linux kernel memory management / pressure
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: l.roehrs@profihost.ag,
 Daniel Aberger - Profihost AG <d.aberger@profihost.ag>,
 "n.fahldieck@profihost.ag" <n.fahldieck@profihost.ag>,
 Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>
References: <36329138-4a6f-9560-b36c-02dc528a8e12@profihost.ag>
 <3c98c75c-b554-499e-d42e-8b9286f3176b@profihost.ag>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2b0cd84c-b5e5-033c-3bae-e108b038209b@suse.cz>
Date: Fri, 5 Apr 2019 12:37:49 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <3c98c75c-b554-499e-d42e-8b9286f3176b@profihost.ag>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/29/19 10:41 AM, Stefan Priebe - Profihost AG wrote:
> Hi,
> 
> nobody an idea? I had another system today:

Well, isn't it still the same thing as we discussed in last autumn?
You did report success with the ill-fated patch "mm: thp:  relax __GFP_THISNODE
for MADV_HUGEPAGE mappings", or not?

> # cat /proc/meminfo
> MemTotal:       131911684 kB
> MemFree:        25734836 kB
> MemAvailable:   78158816 kB
> Buffers:            2916 kB
> Cached:         20650184 kB
> SwapCached:       544016 kB
> Active:         58999352 kB
> Inactive:       10084060 kB
> Active(anon):   43412532 kB
> Inactive(anon):  5583220 kB
> Active(file):   15586820 kB
> Inactive(file):  4500840 kB
> Unevictable:       35032 kB
> Mlocked:           35032 kB
> SwapTotal:       3905532 kB
> SwapFree:              0 kB
> Dirty:              1048 kB
> Writeback:         20144 kB
> AnonPages:      47923392 kB
> Mapped:           775376 kB
> Shmem:            561420 kB
> Slab:           35798052 kB
> SReclaimable:   34309112 kB

That's rather significant. Got a /proc/slabinfo from such system state?

> SUnreclaim:      1488940 kB
> KernelStack:       42160 kB
> PageTables:       248008 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:    69861372 kB
> Committed_AS:   100328892 kB
> VmallocTotal:   34359738367 kB
> VmallocUsed:           0 kB
> VmallocChunk:          0 kB
> HardwareCorrupted:     0 kB
> AnonHugePages:  19177472 kB
> ShmemHugePages:        0 kB
> ShmemPmdMapped:        0 kB
> HugePages_Total:       0
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       2048 kB
> DirectMap4k:      951376 kB
> DirectMap2M:    87015424 kB
> DirectMap1G:    48234496 kB
> 
> # cat /proc/buddyinfo
> Node 0, zone      DMA      1      0      0      0      2      1      1
>     0      1      1      3
> Node 0, zone    DMA32    372    418    403    395    371    322    262
>   179    114      0      0
> Node 0, zone   Normal  89147  96397  76496  56407  41671  29289  18142
> 10278   4075      0      0
> Node 1, zone   Normal 113266      0      1      1      1      1      1
>     1      1      0      0

Node 1 seems quite fragmented. Again from last year I recall somebody (was it
you?) capturing a larger series of snapshots where we saw a Sreclaimable rise
due to some overnight 'find /' activity inflating dentry/inode caches which then
got slowly reclaimed, but memory remained fragmented until enough of slab was
reclaimed, and compaction couldn't help. drop_caches did help. Looks like this
might be the same case. Add in something that tries to get large-order
allocations on node 1 (e.g. with __GFP_THISNODE) and overreclaim will happen.

> But with high PSI / memory pressure values above 10-30.
> 
> Greets,
> Stefan
> Am 27.03.19 um 11:56 schrieb Stefan Priebe - Profihost AG:
>> Hello list,
>> 
>> i hope this is the right place to ask. If not i would be happy to point
>> me to something else.
>> 
>> I'm seeing the following behaviour on some of our hosts running a SLES
>> 15 kernel (kernel v4.12 as it's base) but i don't think it's related to
>> the kernel.
>> 
>> At some "random" interval - mostly 3-6 weeks of uptime. Suddenly mem
>> pressure rises and the linux cache (Cached: /proc/meminfo) drops from
>> 12G to 3G. After that io pressure rises most probably due to low cache.
>> But at the same time i've MemFree und MemAvailable at 19-22G.
>> 
>> Why does this happen? How can i debug this situation? I would expect
>> that the page / file cache never drops if there is so much free mem.
>> 
>> Thanks a lot for your help.
>> 
>> Greets,
>> Stefan
>> 
>> Not sure whether needed but these are the vm. kernel settings:
>> vm.admin_reserve_kbytes = 8192
>> vm.block_dump = 0
>> vm.compact_unevictable_allowed = 1
>> vm.dirty_background_bytes = 0
>> vm.dirty_background_ratio = 10
>> vm.dirty_bytes = 0
>> vm.dirty_expire_centisecs = 3000
>> vm.dirty_ratio = 20
>> vm.dirty_writeback_centisecs = 500
>> vm.dirtytime_expire_seconds = 43200
>> vm.drop_caches = 0
>> vm.extfrag_threshold = 500
>> vm.hugepages_treat_as_movable = 0
>> vm.hugetlb_shm_group = 0
>> vm.laptop_mode = 0
>> vm.legacy_va_layout = 0
>> vm.lowmem_reserve_ratio = 256   256     32      1
>> vm.max_map_count = 65530
>> vm.memory_failure_early_kill = 0
>> vm.memory_failure_recovery = 1
>> vm.min_free_kbytes = 393216
>> vm.min_slab_ratio = 5
>> vm.min_unmapped_ratio = 1
>> vm.mmap_min_addr = 65536
>> vm.mmap_rnd_bits = 28
>> vm.mmap_rnd_compat_bits = 8
>> vm.nr_hugepages = 0
>> vm.nr_hugepages_mempolicy = 0
>> vm.nr_overcommit_hugepages = 0
>> vm.nr_pdflush_threads = 0
>> vm.numa_zonelist_order = default
>> vm.oom_dump_tasks = 1
>> vm.oom_kill_allocating_task = 0
>> vm.overcommit_kbytes = 0
>> vm.overcommit_memory = 0
>> vm.overcommit_ratio = 50
>> vm.page-cluster = 3
>> vm.panic_on_oom = 0
>> vm.percpu_pagelist_fraction = 0
>> vm.stat_interval = 1
>> vm.swappiness = 50
>> vm.user_reserve_kbytes = 131072
>> vm.vfs_cache_pressure = 100
>> vm.watermark_scale_factor = 10
>> vm.zone_reclaim_mode = 0
>> 
> 

