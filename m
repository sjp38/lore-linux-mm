Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E45EDC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:27:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A076B2073D
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:27:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A076B2073D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F39D8E0002; Thu, 14 Feb 2019 21:27:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A3688E0001; Thu, 14 Feb 2019 21:27:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 293A58E0002; Thu, 14 Feb 2019 21:27:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id F30988E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 21:27:16 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id 135so13531313itb.6
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 18:27:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:mime-version:date:content-transfer-encoding;
        bh=AJVS5rwWh/Joo1wc3/TDAVTF9c9bL7hRBodxSTeasy4=;
        b=O0AwxgPJSaPQZ//XlUWj0N9km94vFXt2Bb3WUmCdDjCaSPp8Zl+r/ZDeUxEXE6cYXJ
         odIEA+T+GusMpWJnoPZ0+Y0qN//Mh3+qZQ7CeQ3XPGQ7/hQYYxtIItblEV9RI01b5yDn
         DEyfnBUnWRy8tKgY5rbHQxM9WrJKOMDKFJmsMANxkjd2o+lvADxEuQbfFPnRKYQjCrX+
         bZ1iMlQ+Va/gLAjgKvWRwJa71dgn6xUwC/3qgMrXDTDcwFsVOmRXaMfZHX1Lblr+BWJu
         XQNUVMMXdWqq6vQmbOARicVIn2g+1iAIFogxZ4UB7JSNh/LXsPtEaRWtQA9zl/D+7xdK
         Vp7Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAuZnq9PsljNWMlQD48Dh/jVcu87ZO0psuW2Thid+LWJLbV26xBx1
	dvxQxOT3Ooq39ZQ4uIIxHSh7NvFw0KaUVNmXCI+KtHQjtpw5aFPRhmVWJZLkCJ4+ctYvnsaVtRK
	rPMZHFhiUZEReywOsVqw5qPDQwTML/a1W+ABLlaI3Pj56l7vRjzO35vFspOXW2vbW4g==
X-Received: by 2002:a24:ed4f:: with SMTP id r76mr3520089ith.17.1550197636740;
        Thu, 14 Feb 2019 18:27:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYRDrlfJq2dyHYF3fdGRGt5S4x7oh4CAfmbYGX/+BrwcAV5X4uzvXc6v/THkw/XOvjqJSSj
X-Received: by 2002:a24:ed4f:: with SMTP id r76mr3520061ith.17.1550197635292;
        Thu, 14 Feb 2019 18:27:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550197635; cv=none;
        d=google.com; s=arc-20160816;
        b=tqgRLgte0JvEVMHRrDeVPUFxb4BZ3+5SEUV7q4vU+UFHrXG+XANqpdWH9/kr9peDw3
         h4JjMK51hbAMBiauvqybFbqWSWNea79ZdmuA85NfvAnIlT0LzuLgbbZhURPq2d7Nxr0/
         1QhtutvdGamWvf9OLFt5dn0C09IqpuEC4UA24TBLc//0gKiBgAgDMpSOxO0o0wRwTX0h
         AjME/37RI++OFs3CyKIMFNyVrFv6BZJW2GZPbDFZAgyU83BI/EodPKO3mYVI9nQsK/8z
         nZWQojzBC3IH0I62mz2uVx+2kqA8w0P8/G1iYbUrzXGZq0/NgTJBnWQNpaKFWbyPUFef
         Vg/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:date:mime-version:cc:to:from:subject
         :message-id;
        bh=AJVS5rwWh/Joo1wc3/TDAVTF9c9bL7hRBodxSTeasy4=;
        b=Qoo/Rc2KVVhjtIk+PHC854z5Y31QcoIxMgXhetqtnbi3YW8RJb1nf6pcyfkXGZ8ShB
         IAzl+Nb8Uxxyylb8DdH5nYhXUwAa1CTuCcIcHdDMBeWJztsm5pVAHmd5Q3lDxJX2vvWm
         alGzWjk8HsH2Kl2GenfyBSjssHYpGO3gJZHcawZl1GFaMOdPKT2Q8SeDaFvf6iQPs+mP
         lL6W+qxch3IG1W+YbG+0tNts0Yslm+4xjKRTjUGUD28aXavi3FuH/L8Od00C84OqgVK7
         cYofsK16KOouVKF+DrccBQW/ujiOEfarqlUqueqep2iX2GH2lKGxf2u0lbsY2OhSSGyF
         FBow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id r65si1778752iod.30.2019.02.14.18.27.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 18:27:15 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav404.sakura.ne.jp (fsav404.sakura.ne.jp [133.242.250.103])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x1F2RBgd041783;
	Fri, 15 Feb 2019 11:27:11 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav404.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav404.sakura.ne.jp);
 Fri, 15 Feb 2019 11:27:11 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav404.sakura.ne.jp)
Received: from www262.sakura.ne.jp (localhost [127.0.0.1])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x1F2RBSc041765;
	Fri, 15 Feb 2019 11:27:11 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: (from i-love@localhost)
	by www262.sakura.ne.jp (8.15.2/8.15.2/Submit) id x1F2RBhh041762;
	Fri, 15 Feb 2019 11:27:11 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Message-Id: <201902150227.x1F2RBhh041762@www262.sakura.ne.jp>
X-Authentication-Warning: www262.sakura.ne.jp: i-love set sender to penguin-kernel@i-love.sakura.ne.jp using -f
Subject: [linux-next-20190214] Free pages statistics is broken.
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
MIME-Version: 1.0
Date: Fri, 15 Feb 2019 11:27:10 +0900
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I noticed that amount of free memory reported by DMA: / DMA32: / Normal: fields are
increasing over time. Since 5.0-rc6 is working correctly, some change in linux-next
is causing this problem.

----------
[   92.010105][T14750] Mem-Info:
[   92.012409][T14750] active_anon:623678 inactive_anon:2182 isolated_anon:0
[   92.012409][T14750]  active_file:7 inactive_file:99 isolated_file:0
[   92.012409][T14750]  unevictable:0 dirty:0 writeback:0 unstable:0
[   92.012409][T14750]  slab_reclaimable:16216 slab_unreclaimable:48544
[   92.012409][T14750]  mapped:623 shmem:2334 pagetables:9774 bounce:0
[   92.012409][T14750]  free:21145 free_pcp:332 free_cma:0
[   92.034020][T14750] Node 0 active_anon:2494712kB inactive_anon:8728kB active_file:80kB inactive_file:320kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:2592kB dirty:0kB writeback:0kB shmem:9336kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 2144256kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[   92.052787][T14750] DMA free:12096kB min:352kB low:440kB high:528kB active_anon:3696kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15960kB managed:15876kB mlocked:0kB kernel_stack:0kB pagetables:36kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   92.063686][T14750] lowmem_reserve[]: 0 2647 2941 2941
[   92.066370][T14750] DMA32 free:61212kB min:60508kB low:75632kB high:90756kB active_anon:2411444kB inactive_anon:460kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129152kB managed:2711060kB mlocked:0kB kernel_stack:36544kB pagetables:36212kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   92.084432][T14750] lowmem_reserve[]: 0 0 294 294
[   92.088254][T14750] Normal free:11120kB min:6716kB low:8392kB high:10068kB active_anon:79572kB inactive_anon:8268kB active_file:360kB inactive_file:540kB unevictable:0kB writepending:0kB present:1048576kB managed:301068kB mlocked:0kB kernel_stack:7776kB pagetables:2848kB bounce:0kB free_pcp:140kB local_pcp:88kB free_cma:0kB
[   92.102106][T14750] lowmem_reserve[]: 0 0 0 0
[   92.105259][T14750] DMA: 210*4kB () 105*8kB () 56*16kB (UM) 29*32kB (U) 13*64kB () 9*128kB (UM) 6*256kB (UM) 2*512kB () 2*1024kB (U) 2*2048kB (M) 2*4096kB (M) = 22384kB
[   92.113929][T14750] DMA32: 85952*4kB (UM) 36165*8kB (UM) 17368*16kB (UME) 11953*32kB (UME) 5598*64kB (UME) 2641*128kB (UM) 1252*256kB (ME) 604*512kB (UM) 303*1024kB (UM) 680*2048kB (U) 1*4096kB (M) = 4326600kB
[   92.124563][T14750] Normal: 41430*4kB (UE) 14837*8kB (UME) 10319*16kB (UE) 6379*32kB (UE) 2677*64kB () 1230*128kB () 557*256kB () 239*512kB () 83*1024kB () 42*2048kB () 0*4096kB = 1418384kB
[   92.132526][T14750] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[   92.136838][T14750] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   92.141838][T14750] 2683 total pagecache pages
[   92.144736][T14750] 0 pages in swap cache
[   92.147422][T14750] Swap cache stats: add 0, delete 0, find 0/0
[   92.150690][T14750] Free swap  = 0kB
[   92.153216][T14750] Total swap = 0kB
[   92.156285][T14750] 1048422 pages RAM
[   92.159794][T14750] 0 pages HighMem/MovableOnly
[   92.162966][T14750] 291421 pages reserved
[   92.165806][T14750] 0 pages cma reserved
----------

----------
[ 3204.099198][T42110] Mem-Info:
[ 3204.101094][T42110] active_anon:645144 inactive_anon:14056 isolated_anon:0
[ 3204.101094][T42110]  active_file:0 inactive_file:0 isolated_file:0
[ 3204.101094][T42110]  unevictable:0 dirty:0 writeback:0 unstable:0
[ 3204.101094][T42110]  slab_reclaimable:8328 slab_unreclaimable:47169
[ 3204.101094][T42110]  mapped:990 shmem:22735 pagetables:1462 bounce:0
[ 3204.101094][T42110]  free:22187 free_pcp:181 free_cma:0
[ 3204.116827][T42110] Node 0 active_anon:2580576kB inactive_anon:56224kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:3960kB dirty:0kB writeback:0kB shmem:90940kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 1159168kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[ 3204.127991][T42110] DMA free:12116kB min:352kB low:440kB high:528kB active_anon:3724kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15960kB managed:15876kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 3204.137735][T42110] lowmem_reserve[]: 0 2647 2941 2941
[ 3204.140385][T42110] DMA32 free:61592kB min:60508kB low:75632kB high:90756kB active_anon:2508676kB inactive_anon:9448kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129152kB managed:2711060kB mlocked:0kB kernel_stack:2304kB pagetables:4908kB bounce:0kB free_pcp:540kB local_pcp:0kB free_cma:0kB
[ 3204.151829][T42110] lowmem_reserve[]: 0 0 294 294
[ 3204.154387][T42110] Normal free:15040kB min:21052kB low:22728kB high:24404kB active_anon:68176kB inactive_anon:46776kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:1048576kB managed:301068kB mlocked:0kB kernel_stack:6848kB pagetables:936kB bounce:0kB free_pcp:184kB local_pcp:0kB free_cma:0kB
[ 3204.166972][T42110] lowmem_reserve[]: 0 0 0 0
[ 3204.169666][T42110] DMA: 3842*4kB (M) 1924*8kB () 970*16kB (M) 494*32kB (UM) 254*64kB (UM) 128*128kB (U) 74*256kB (UM) 36*512kB () 19*1024kB (U) 18*2048kB (M) 2*4096kB (M) = 196616kB
[ 3204.177392][T42110] DMA32: 3222548*4kB (UM) 1353981*8kB (U) 579496*16kB (UM) 267125*32kB (UME) 111607*64kB (UME) 46106*128kB (UME) 18144*256kB (UM) 6284*512kB () 1521*1024kB () 7061*2048kB () 0*4096kB = 78467096kB
[ 3204.185907][T42110] Normal: 637045*4kB () 202228*8kB (U) 64530*16kB (U) 19303*32kB (UE) 3969*64kB () 1321*128kB () 562*256kB () 239*512kB () 83*1024kB () 42*2048kB () 0*4096kB = 6676532kB
[ 3204.193851][T42110] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 3204.198253][T42110] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 3204.202507][T42110] 22747 total pagecache pages
[ 3204.205522][T42110] 0 pages in swap cache
[ 3204.208297][T42110] Swap cache stats: add 0, delete 0, find 0/0
[ 3204.211716][T42110] Free swap  = 0kB
[ 3204.214380][T42110] Total swap = 0kB
[ 3204.217017][T42110] 1048422 pages RAM
[ 3204.219747][T42110] 0 pages HighMem/MovableOnly
[ 3204.222754][T42110] 291421 pages reserved
[ 3204.225527][T42110] 0 pages cma reserved
----------

