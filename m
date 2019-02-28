Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLACK,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23138C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:19:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7006D214D8
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:19:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7006D214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 200988E0006; Thu, 28 Feb 2019 07:19:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18A938E0001; Thu, 28 Feb 2019 07:19:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D488D8E0006; Thu, 28 Feb 2019 07:19:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 38ECE8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 07:19:28 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id z24so14707767pfn.7
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:19:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:x-original-authentication-results:date:from:to
         :cc:subject:message-id:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=pvlRXNKU2OclZQb2hTZrZLxw1v1XRsUh5F2VwVdHQaI=;
        b=miLLipb/yMEArQ1pTFpSvicycUOC6dOIlryq3zKbClbTcRUU8OuIuytJcc/ITo40F0
         Ekl4clgf+APfS3gVtm1dMr4eqZlf6/ijtTA+2xGl1W1Brjnp3roVVBgszvedMxWubyfi
         GBH5cfKZ8+fmUv3ThYJ7OZQY5qVdf+d5JxggBhoEck7FnTKp3sc3pdxAhzNYz4pXWkuD
         7ssWx3KwClDSeg2Ib1eTThuLUfEHWCi4b7N/6MIeAUmXu7msqBue+Wk1F3XjGzNTN900
         LlDU8TL6ieRKjLGH5cypIJKnCFvljx1l9eYxeRRMsSOfJXGg24pV8lfG1blzh9jBDvRA
         yU4w==
X-Gm-Message-State: AHQUAuZXBXHhjFU035+fyYx7SmTnSdrO6JjHVi/dv0AaDey6qaNOJa8r
	LpjLObQyJdJOwxuhnTklnIudHbzsS07UoIbjkx9NziXq5vdXdqC0OPUJ9U88zwnom0kXC09bvGo
	Z76b2evh9JIImFnEWmvWEOxLs/uktZBhsj73tTiBjsDaJ1eFbqeGMIkBR48VGilZEKXyFyfOt3f
	aMFD677ehw05Sntaq0RsIGcxB0kJCfh59n+qUUgUXIXfYyvNSPeiNws7b2oftNNgDdmQfzCwrSi
	epjKls2asMgnit9oX+GCEUvXjjj6kMwE0AudFoWdlsF/Ty+aTe1z1VZmZXPqppmSr+OglxdSLsl
	11nnZ8PE7L0aJmQW+BjI0grfmdX76XCBgViW1i+gyjO26HxU5U5nwIcQLt4sYDIk092UyIijV+W
	N
X-Received: by 2002:a63:e101:: with SMTP id z1mr8273927pgh.190.1551356127546;
        Thu, 28 Feb 2019 04:15:27 -0800 (PST)
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rong.a.chen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Received: by 2002:a63:e101:: with SMTP id z1mr8273893pgh.190.1551356127176;
        Thu, 28 Feb 2019 04:15:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZhY66FTlFXTk2r0CcnPJc5F9ShWyeibF8N6E42HTF48pacjGWJO4oeAe/40Iw7duVd+2lN
X-Received: by 2002:a63:e101:: with SMTP id z1mr8273446pgh.190.1551356121600;
        Thu, 28 Feb 2019 04:15:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551356121; cv=none;
        d=google.com; s=arc-20160816;
        b=k+qXEqZtNmr+xwRi6v4kKwmluisRur9eE+upZzQRiy+roStZgl9/ZsQOARhMTahzap
         UzGNzUSNnetWT6QF1Aju1cDE1+rzCNhmZRVfdh66F7vPn8lgUpX5InZDIKwbMwlGzkOg
         AvZDGPQoowj6CLkIc7taq2vImc1C+5eFlmSQgaJHHLpL7l87mtekiVelqE1HAhCit4ZC
         SZInLGfJQMjCb2xBOuTqxVXEcFr59OPbyS67XrYl8ENURR3rdLK+gSa5sGFVwPx/Wwsz
         CN+Uv4gA+0ponYjnNwEs12ckBWlTZTzEppmeJ5GScwkSHURxBheuPZpu9C+c0ZA3olJT
         VC/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:message-id:subject:cc:to:from:date;
        bh=pvlRXNKU2OclZQb2hTZrZLxw1v1XRsUh5F2VwVdHQaI=;
        b=1FRA9HVsfeh50vo2fyoKZA4RkTgUTPAB500ZdD1v/YWmhiGB4W14NSQy7apqqvoWtg
         +bhZezh3LKb4xPh84qu8Sev/exlkLExISJ80faGpBr/4MijQvMlktVL78iGffaOF+e4M
         2zOi41lXhCUoXHYzI5awhf/XKLfa6TOwYVzGA+zWT8od3VPQeNGprg35TpwnAm/RAJYH
         WCFKWRqRDerdsIMqM0THf+yTolpMTwXSgULf8vffilVZgP9VzdOgD1mQ9RMjRO6TJBSo
         ouPtZqT9+uG2GtyTdjqwT50szs8Ghb/kioaDMcFsOLEOKrJsvFCGhgItjl+k1tPKnxwe
         nwDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rong.a.chen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id t13si17773860pgh.159.2019.02.28.04.15.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 04:15:21 -0800 (PST)
Received-SPF: pass (google.com: domain of rong.a.chen@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rong.a.chen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Feb 2019 04:15:20 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,423,1544515200"; 
   d="yaml'?scan'208";a="127921945"
Received: from shao2-debian.sh.intel.com (HELO localhost) ([10.239.13.107])
  by fmsmga008.fm.intel.com with ESMTP; 28 Feb 2019 04:15:13 -0800
Date: Thu, 28 Feb 2019 20:15:29 +0800
From: kernel test robot <rong.a.chen@intel.com>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>, lkp@01.org
Subject: [LKP] [mm/gup]  cdaa813278:  stress-ng.numa.ops_per_sec 4671.0%
 improvement
Message-ID: <20190228121529.GH10770@shao2-debian>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="orO6xySwJI16pVnm"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190204052135.25784-5-jhubbard@nvidia.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--orO6xySwJI16pVnm
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Greeting,

FYI, we noticed a 4671.0% improvement of stress-ng.numa.ops_per_sec due to commit:


commit: cdaa813278ddc616ee201eacda77f63996b5dd2d ("[PATCH 4/6] mm/gup: track gup-pinned pages")
url: https://github.com/0day-ci/linux/commits/john-hubbard-gmail-com/RFC-v2-mm-gup-dma-tracking/20190205-001101


in testcase: stress-ng
on test machine: 88 threads Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz with 64G memory
with following parameters:

	nr_threads: 50%
	disk: 1HDD
	testtime: 5s
	class: memory
	cpufreq_governor: performance
	ucode: 0xb00002e


In addition to that, the commit also has significant impact on the following tests:

+------------------+---------------------------------------------------------------------------+
| testcase: change | will-it-scale: ltp.cve-2017-18075.pass -100.0% undefined                  |
| test machine     | qemu-system-x86_64 -enable-kvm -cpu SandyBridge -smp 2 -m 8G              |
| test parameters  | cpufreq_governor=performance                                              |
|                  | mode=process                                                              |
|                  | nr_task=100%                                                              |
|                  | test=futex1                                                               |
+------------------+---------------------------------------------------------------------------+
| testcase: change | stress-ng:                                                                |
| test machine     | 192 threads Skylake-4S with 704G memory                                   |
| test parameters  | class=cpu                                                                 |
|                  | cpufreq_governor=performance                                              |
|                  | disk=1HDD                                                                 |
|                  | nr_threads=100%                                                           |
|                  | testtime=1s                                                               |
+------------------+---------------------------------------------------------------------------+
| testcase: change | stress-ng: stress-ng.numa.ops_per_sec 401.7% improvement                  |
| test machine     | 272 threads Intel(R) Xeon Phi(TM) CPU 7255 @ 1.10GHz with 112G memory     |
| test parameters  | class=pipe                                                                |
|                  | cpufreq_governor=performance                                              |
|                  | disk=1HDD                                                                 |
|                  | nr_threads=100%                                                           |
|                  | testtime=1s                                                               |
+------------------+---------------------------------------------------------------------------+
| testcase: change | will-it-scale: stress-ng.vm-splice.ops_per_sec -18.5% regression          |
| test machine     | 272 threads Intel(R) Xeon Phi(TM) CPU 7255 @ 1.10GHz with 112G memory     |
| test parameters  | cpufreq_governor=performance                                              |
|                  | mode=process                                                              |
|                  | nr_task=100%                                                              |
|                  | test=futex2                                                               |
|                  | ucode=0xb00002e                                                           |
+------------------+---------------------------------------------------------------------------+
| testcase: change | stress-ng:                                                                |
| test machine     | 88 threads Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz with 64G memory      |
| test parameters  | class=os                                                                  |
|                  | cpufreq_governor=performance                                              |
|                  | disk=1HDD                                                                 |
|                  | nr_threads=100%                                                           |
|                  | testtime=1s                                                               |
+------------------+---------------------------------------------------------------------------+
| testcase: change | stress-ng: stress-ng.futex.ops_per_sec -58.0% regression                  |
| test machine     | 272 threads Intel(R) Xeon Phi(TM) CPU 7255 @ 1.10GHz with 112G memory     |
| test parameters  | class=vm                                                                  |
|                  | cpufreq_governor=performance                                              |
|                  | disk=1HDD                                                                 |
|                  | nr_threads=100%                                                           |
|                  | testtime=1s                                                               |
|                  | ucode=0xb00002e                                                           |
+------------------+---------------------------------------------------------------------------+
| testcase: change | stress-ng: stress-ng.vm-splice.ops -58.3% undefined                       |
| test machine     | 88 threads Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz with 64G memory      |
| test parameters  | class=pipe                                                                |
|                  | cpufreq_governor=performance                                              |
|                  | disk=1HDD                                                                 |
|                  | nr_threads=100%                                                           |
|                  | testtime=60s                                                              |
|                  | ucode=0xb00002e                                                           |
+------------------+---------------------------------------------------------------------------+
| testcase: change | stress-ng: kernel_selftests.memfd.run_fuse_test.sh.pass -100.0% undefined |
| test machine     | qemu-system-x86_64 -enable-kvm -cpu SandyBridge -smp 2 -m 4G              |
| test parameters  | class=pipe                                                                |
|                  | cpufreq_governor=performance                                              |
|                  | disk=1HDD                                                                 |
|                  | nr_threads=100%                                                           |
|                  | testtime=60s                                                              |
+------------------+---------------------------------------------------------------------------+
| testcase: change | kvm-unit-tests: stress-ng.vm-splice.ops -99.3% undefined                  |
| test machine     | 88 threads Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz with 64G memory      |
+------------------+---------------------------------------------------------------------------+


Details are as below:
-------------------------------------------------------------------------------------------------->


To reproduce:

        git clone https://github.com/intel/lkp-tests.git
        cd lkp-tests
        bin/lkp install job.yaml  # job file is attached in this email
        bin/lkp run     job.yaml

=========================================================================================
class/compiler/cpufreq_governor/disk/kconfig/nr_threads/rootfs/tbox_group/testcase/testtime/ucode:
  memory/gcc-7/performance/1HDD/x86_64-rhel-7.2/50%/debian-x86_64-2018-04-03.cgz/lkp-bdw-ep3/stress-ng/5s/0xb00002e

commit: 
  9627026352 ("mm: page_cache_add_speculative(): refactoring")
  cdaa813278 ("mm/gup: track gup-pinned pages")

96270263521248d5 cdaa813278ddc616ee201eacda7 
---------------- --------------------------- 
         %stddev     %change         %stddev
             \          |                \  
     17845 ±  2%     +25.1%      22326 ± 22%  stress-ng.memcpy.ops
      3568 ±  2%     +25.1%       4464 ± 22%  stress-ng.memcpy.ops_per_sec
     55.50 ±  2%   +3969.8%       2258 ±  3%  stress-ng.numa.ops
      9.41 ±  4%   +4671.0%     449.07 ±  3%  stress-ng.numa.ops_per_sec
    277857 ±  5%     +50.9%     419386 ±  4%  stress-ng.time.involuntary_context_switches
    326.50 ± 10%     -16.2%     273.50 ±  3%  stress-ng.vm-addr.ops
     65.30 ± 10%     -16.2%      54.71 ±  3%  stress-ng.vm-addr.ops_per_sec
      0.01 ±113%      +0.0        0.02 ± 36%  mpstat.cpu.iowait%
    181260           +15.7%     209701        vmstat.system.in
     64963 ± 32%    +315.5%     269897 ± 38%  numa-numastat.node0.other_node
     66083 ± 33%    +904.9%     664072 ± 18%  numa-numastat.node1.other_node
      1670 ±  2%     +36.4%       2279 ±  3%  slabinfo.numa_policy.active_objs
      1670 ±  2%     +36.4%       2279 ±  3%  slabinfo.numa_policy.num_objs
  38695830           +29.5%   50110710        turbostat.IRQ
     10.08            -2.9%       9.79        turbostat.RAMWatt
    917912 ± 10%     +77.1%    1625317 ± 27%  meminfo.Active
    917736 ± 10%     +77.1%    1624942 ± 27%  meminfo.Active(anon)
    425637 ± 10%     +43.8%     611934 ± 18%  meminfo.Inactive
    425296 ± 10%     +43.8%     611561 ± 18%  meminfo.Inactive(anon)
   3195353 ±  3%     +26.7%    4047153 ± 14%  meminfo.Memused
     49.89 ±  5%     -26.7%      36.55 ±  6%  perf-stat.i.MPKI
 4.372e+08 ±  2%      -5.1%  4.151e+08 ±  3%  perf-stat.i.cache-references
      9.75 ±  5%      -8.8%       8.90 ±  3%  perf-stat.i.cpi
      4.84 ±  3%      -8.2%       4.44 ±  4%  perf-stat.overall.MPKI
 4.361e+08 ±  2%      -5.2%  4.137e+08 ±  3%  perf-stat.ps.cache-references
     27667 ± 19%     +32.4%      36627 ± 17%  softirqs.CPU0.RCU
     24079 ±  6%     -12.6%      21054 ±  8%  softirqs.CPU24.SCHED
     29249 ±  4%     +14.0%      33351 ±  4%  softirqs.CPU25.RCU
     29618 ±  4%     +16.8%      34600 ±  8%  softirqs.CPU27.RCU
     37158 ±  3%     -12.6%      32476 ± 12%  softirqs.CPU69.RCU
    446518 ± 23%     +87.1%     835393 ± 18%  numa-meminfo.node0.Active
    446388 ± 23%     +87.1%     835224 ± 18%  numa-meminfo.node0.Active(anon)
    279797 ± 60%     +81.1%     506718 ±  7%  numa-meminfo.node0.Inactive
    279545 ± 60%     +81.2%     506611 ±  7%  numa-meminfo.node0.Inactive(anon)
     57425 ±  7%     +16.8%      67077 ±  3%  numa-meminfo.node0.KReclaimable
   1666995 ± 17%     +37.9%    2299473 ±  4%  numa-meminfo.node0.MemUsed
     57425 ±  7%     +16.8%      67077 ±  3%  numa-meminfo.node0.SReclaimable
     59307 ±  7%     -18.7%      48201 ±  4%  numa-meminfo.node1.KReclaimable
     59307 ±  7%     -18.7%      48201 ±  4%  numa-meminfo.node1.SReclaimable
    114842 ± 19%     +86.4%     214054 ± 15%  numa-vmstat.node0.nr_active_anon
     71405 ± 61%     +78.6%     127550 ±  8%  numa-vmstat.node0.nr_inactive_anon
    257.00 ± 12%     -43.0%     146.50 ± 30%  numa-vmstat.node0.nr_isolated_anon
     14332 ±  7%     +17.2%      16792 ±  3%  numa-vmstat.node0.nr_slab_reclaimable
    114840 ± 19%     +86.4%     214050 ± 15%  numa-vmstat.node0.nr_zone_active_anon
     71404 ± 61%     +78.6%     127549 ±  8%  numa-vmstat.node0.nr_zone_inactive_anon
     39507 ± 32%    +250.0%     138280 ± 37%  numa-vmstat.node0.numa_other
    313.75 ±  5%     -57.1%     134.50 ± 25%  numa-vmstat.node1.nr_isolated_anon
     14816 ±  7%     -18.5%      12069 ±  4%  numa-vmstat.node1.nr_slab_reclaimable
    172051 ±  7%    +177.8%     477913 ± 13%  numa-vmstat.node1.numa_other
    231722 ±  8%     +72.6%     399865 ± 27%  proc-vmstat.nr_active_anon
    291.00 ± 16%     +18.6%     345.00 ± 19%  proc-vmstat.nr_anon_transparent_hugepages
    107048 ±  8%     +43.8%     153932 ± 19%  proc-vmstat.nr_inactive_anon
    643.25 ±  6%     -55.9%     283.75 ± 25%  proc-vmstat.nr_isolated_anon
    231722 ±  8%     +72.6%     399865 ± 27%  proc-vmstat.nr_zone_active_anon
    107048 ±  8%     +43.8%     153932 ± 19%  proc-vmstat.nr_zone_inactive_anon
    131052 ±  3%    +612.7%     933974 ±  3%  proc-vmstat.numa_other
 6.265e+08 ±  3%     -13.6%  5.411e+08 ±  5%  proc-vmstat.pgalloc_normal
 6.264e+08 ±  3%     -13.7%  5.403e+08 ±  5%  proc-vmstat.pgfree
      7486 ±122%   +2087.9%     163793 ±  6%  proc-vmstat.pgmigrate_fail
   1047865 ± 18%    +134.0%    2452064 ± 15%  proc-vmstat.pgmigrate_success
    234795 ± 26%     -60.5%      92683 ± 78%  proc-vmstat.thp_deferred_split_page
    417.00 ±145%   +3214.7%      13822 ±144%  proc-vmstat.unevictable_pgs_cleared
    417.50 ±144%   +3211.2%      13824 ±144%  proc-vmstat.unevictable_pgs_stranded
     46.55           -46.6        0.00        perf-profile.calltrace.cycles-pp.__x64_sys_move_pages.do_syscall_64.entry_SYSCALL_64_after_hwframe
     46.55           -46.6        0.00        perf-profile.calltrace.cycles-pp.kernel_move_pages.__x64_sys_move_pages.do_syscall_64.entry_SYSCALL_64_after_hwframe
     46.47           -46.5        0.00        perf-profile.calltrace.cycles-pp.do_move_pages_to_node.kernel_move_pages.__x64_sys_move_pages.do_syscall_64.entry_SYSCALL_64_after_hwframe
     46.47           -46.5        0.00        perf-profile.calltrace.cycles-pp.migrate_pages.do_move_pages_to_node.kernel_move_pages.__x64_sys_move_pages.do_syscall_64
     45.32           -45.3        0.00        perf-profile.calltrace.cycles-pp.move_to_new_page.migrate_pages.do_move_pages_to_node.kernel_move_pages.__x64_sys_move_pages
     45.32           -45.3        0.00        perf-profile.calltrace.cycles-pp.migrate_page.move_to_new_page.migrate_pages.do_move_pages_to_node.kernel_move_pages
     45.22           -45.2        0.00        perf-profile.calltrace.cycles-pp.migrate_page_copy.migrate_page.move_to_new_page.migrate_pages.do_move_pages_to_node
     43.53           -43.0        0.55 ± 62%  perf-profile.calltrace.cycles-pp.copy_page.migrate_page_copy.migrate_page.move_to_new_page.migrate_pages
     78.97 ±  2%      -6.3       72.65        perf-profile.calltrace.cycles-pp.do_syscall_64.entry_SYSCALL_64_after_hwframe
     79.20 ±  2%      -6.2       72.97        perf-profile.calltrace.cycles-pp.entry_SYSCALL_64_after_hwframe
      5.01 ±  3%      -0.9        4.11 ±  3%  perf-profile.calltrace.cycles-pp.__vm_munmap.__x64_sys_munmap.do_syscall_64.entry_SYSCALL_64_after_hwframe
      5.01 ±  3%      -0.9        4.12 ±  3%  perf-profile.calltrace.cycles-pp.__x64_sys_munmap.do_syscall_64.entry_SYSCALL_64_after_hwframe
      4.94 ±  3%      -0.9        4.05 ±  3%  perf-profile.calltrace.cycles-pp.unmap_region.__do_munmap.__vm_munmap.__x64_sys_munmap.do_syscall_64
      4.99 ±  3%      -0.9        4.10 ±  3%  perf-profile.calltrace.cycles-pp.__do_munmap.__vm_munmap.__x64_sys_munmap.do_syscall_64.entry_SYSCALL_64_after_hwframe
      2.48 ±  3%      -0.5        2.02 ±  3%  perf-profile.calltrace.cycles-pp.tlb_finish_mmu.unmap_region.__do_munmap.__vm_munmap.__x64_sys_munmap
      2.47 ±  3%      -0.5        2.02 ±  3%  perf-profile.calltrace.cycles-pp.arch_tlb_finish_mmu.tlb_finish_mmu.unmap_region.__do_munmap.__vm_munmap
      2.37 ±  3%      -0.4        1.93 ±  3%  perf-profile.calltrace.cycles-pp.tlb_flush_mmu_free.arch_tlb_finish_mmu.tlb_finish_mmu.unmap_region.__do_munmap
      2.35 ±  3%      -0.4        1.92 ±  3%  perf-profile.calltrace.cycles-pp.release_pages.tlb_flush_mmu_free.arch_tlb_finish_mmu.tlb_finish_mmu.unmap_region
      2.38 ±  2%      -0.4        1.96 ±  3%  perf-profile.calltrace.cycles-pp.pagevec_lru_move_fn.lru_add_drain_cpu.lru_add_drain.unmap_region.__do_munmap
      2.38 ±  3%      -0.4        1.96 ±  3%  perf-profile.calltrace.cycles-pp.lru_add_drain_cpu.lru_add_drain.unmap_region.__do_munmap.__vm_munmap
      2.38 ±  3%      -0.4        1.96 ±  3%  perf-profile.calltrace.cycles-pp.lru_add_drain.unmap_region.__do_munmap.__vm_munmap.__x64_sys_munmap
      2.21 ±  3%      -0.4        1.80 ±  2%  perf-profile.calltrace.cycles-pp._raw_spin_lock_irqsave.release_pages.tlb_flush_mmu_free.arch_tlb_finish_mmu.tlb_finish_mmu
      2.19 ±  3%      -0.4        1.78 ±  2%  perf-profile.calltrace.cycles-pp.native_queued_spin_lock_slowpath._raw_spin_lock_irqsave.release_pages.tlb_flush_mmu_free.arch_tlb_finish_mmu
      2.23 ±  2%      -0.4        1.83 ±  3%  perf-profile.calltrace.cycles-pp._raw_spin_lock_irqsave.pagevec_lru_move_fn.lru_add_drain_cpu.lru_add_drain.unmap_region
      2.20 ±  2%      -0.4        1.81 ±  3%  perf-profile.calltrace.cycles-pp.native_queued_spin_lock_slowpath._raw_spin_lock_irqsave.pagevec_lru_move_fn.lru_add_drain_cpu.lru_add_drain
      0.58 ±  5%      +0.2        0.77 ±  4%  perf-profile.calltrace.cycles-pp.touch_atime.pipe_read.__vfs_read.vfs_read.ksys_read
      0.58 ±  7%      +0.2        0.78 ±  4%  perf-profile.calltrace.cycles-pp.anon_pipe_buf_release.pipe_read.__vfs_read.vfs_read.ksys_read
      0.70 ± 16%      +0.2        0.92 ±  6%  perf-profile.calltrace.cycles-pp.try_to_wake_up.autoremove_wake_function.__wake_up_common.__wake_up_common_lock.pipe_read
      0.65 ±  5%      +0.2        0.88        perf-profile.calltrace.cycles-pp.selinux_file_permission.security_file_permission.vfs_write.ksys_write.do_syscall_64
      0.66 ±  5%      +0.2        0.89 ±  2%  perf-profile.calltrace.cycles-pp.selinux_file_permission.security_file_permission.vfs_read.ksys_read.do_syscall_64
      0.70 ± 16%      +0.2        0.94 ±  6%  perf-profile.calltrace.cycles-pp.autoremove_wake_function.__wake_up_common.__wake_up_common_lock.pipe_read.__vfs_read
      0.81 ±  5%      +0.3        1.10 ±  3%  perf-profile.calltrace.cycles-pp._raw_spin_lock_irqsave.__wake_up_common_lock.pipe_read.__vfs_read.vfs_read
      0.83 ± 14%      +0.3        1.12 ±  4%  perf-profile.calltrace.cycles-pp.__wake_up_common.__wake_up_common_lock.pipe_read.__vfs_read.vfs_read
      0.40 ± 57%      +0.3        0.71        perf-profile.calltrace.cycles-pp.__wake_up_common_lock.pipe_write.__vfs_write.vfs_write.ksys_write
      0.58 ±  5%      +0.3        0.92 ± 28%  perf-profile.calltrace.cycles-pp.copy_user_enhanced_fast_string.copyin.copy_page_from_iter.pipe_write.__vfs_write
      0.28 ±100%      +0.4        0.64 ±  8%  perf-profile.calltrace.cycles-pp.pipe_wait.pipe_write.__vfs_write.vfs_write.ksys_write
      0.65 ±  5%      +0.4        1.02 ± 25%  perf-profile.calltrace.cycles-pp.copyin.copy_page_from_iter.pipe_write.__vfs_write.vfs_write
      0.26 ±100%      +0.4        0.65 ±  4%  perf-profile.calltrace.cycles-pp.atime_needs_update.touch_atime.pipe_read.__vfs_read.vfs_read
      1.04 ±  5%      +0.4        1.44        perf-profile.calltrace.cycles-pp.mutex_lock.pipe_write.__vfs_write.vfs_write.ksys_write
      1.06 ±  5%      +0.4        1.46 ±  2%  perf-profile.calltrace.cycles-pp.mutex_lock.pipe_read.__vfs_read.vfs_read.ksys_read
      1.21 ±  5%      +0.4        1.64        perf-profile.calltrace.cycles-pp.security_file_permission.vfs_write.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
      1.14 ±  8%      +0.5        1.61        perf-profile.calltrace.cycles-pp.mutex_unlock.pipe_read.__vfs_read.vfs_read.ksys_read
      1.30 ±  5%      +0.5        1.78 ±  3%  perf-profile.calltrace.cycles-pp.copy_user_enhanced_fast_string.copyout.copy_page_to_iter.pipe_read.__vfs_read
      1.16 ±  9%      +0.5        1.64        perf-profile.calltrace.cycles-pp.mutex_spin_on_owner.__mutex_lock.pipe_write.__vfs_write.vfs_write
      0.13 ±173%      +0.5        0.63 ±  7%  perf-profile.calltrace.cycles-pp.poll_idle.cpuidle_enter_state.do_idle.cpu_startup_entry.start_secondary
      1.37 ±  6%      +0.5        1.86 ±  2%  perf-profile.calltrace.cycles-pp.copyout.copy_page_to_iter.pipe_read.__vfs_read.vfs_read
      1.34 ±  6%      +0.5        1.85        perf-profile.calltrace.cycles-pp.security_file_permission.vfs_read.ksys_read.do_syscall_64.entry_SYSCALL_64_after_hwframe
      0.13 ±173%      +0.5        0.64        perf-profile.calltrace.cycles-pp.file_has_perm.security_file_permission.vfs_write.ksys_write.do_syscall_64
      0.14 ±173%      +0.5        0.67 ±  2%  perf-profile.calltrace.cycles-pp.file_has_perm.security_file_permission.vfs_read.ksys_read.do_syscall_64
      0.00            +0.5        0.54 ±  5%  perf-profile.calltrace.cycles-pp.rmap_walk_file.remove_migration_ptes.migrate_pages.migrate_to_node.do_migrate_pages
      1.25 ±  4%      +0.6        1.82 ± 14%  perf-profile.calltrace.cycles-pp.copy_page_from_iter.pipe_write.__vfs_write.vfs_write.ksys_write
      0.00            +0.6        0.59 ±  4%  perf-profile.calltrace.cycles-pp.fsnotify.vfs_read.ksys_read.do_syscall_64.entry_SYSCALL_64_after_hwframe
      0.00            +0.6        0.59 ±  6%  perf-profile.calltrace.cycles-pp.rmap_walk_anon.try_to_unmap.migrate_pages.migrate_to_node.do_migrate_pages
      0.00            +0.6        0.60 ±  8%  perf-profile.calltrace.cycles-pp.find_next_bit.do_migrate_pages.kernel_migrate_pages.__x64_sys_migrate_pages.do_syscall_64
      1.65 ±  7%      +0.6        2.27 ±  4%  perf-profile.calltrace.cycles-pp.mutex_unlock.pipe_write.__vfs_write.vfs_write.ksys_write
      0.00            +0.6        0.63 ±  6%  perf-profile.calltrace.cycles-pp._raw_spin_lock.queue_pages_pte_range.__walk_page_range.walk_page_range.queue_pages_range
      0.00            +0.7        0.65 ±  5%  perf-profile.calltrace.cycles-pp.remove_migration_ptes.migrate_pages.migrate_to_node.do_migrate_pages.kernel_migrate_pages
      1.89 ±  7%      +0.7        2.56        perf-profile.calltrace.cycles-pp.__wake_up_common_lock.pipe_read.__vfs_read.vfs_read.ksys_read
      0.00            +0.7        0.67 ±  5%  perf-profile.calltrace.cycles-pp.queue_pages_test_walk.walk_page_range.queue_pages_range.migrate_to_node.do_migrate_pages
      2.05 ±  5%      +0.7        2.80 ±  2%  perf-profile.calltrace.cycles-pp.copy_page_to_iter.pipe_read.__vfs_read.vfs_read.ksys_read
      0.00            +0.8        0.82 ± 23%  perf-profile.calltrace.cycles-pp.migrate_page.move_to_new_page.migrate_pages.migrate_to_node.do_migrate_pages
      0.00            +0.8        0.82 ± 23%  perf-profile.calltrace.cycles-pp.move_to_new_page.migrate_pages.migrate_to_node.do_migrate_pages.kernel_migrate_pages
      0.00            +0.8        0.85 ±  5%  perf-profile.calltrace.cycles-pp._vm_normal_page.queue_pages_pte_range.__walk_page_range.walk_page_range.queue_pages_range
      2.79 ±  4%      +0.9        3.68 ±  2%  perf-profile.calltrace.cycles-pp.entry_SYSCALL_64
      0.00            +0.9        0.89 ±  3%  perf-profile.calltrace.cycles-pp.bitmap_ord_to_pos.do_migrate_pages.kernel_migrate_pages.__x64_sys_migrate_pages.do_syscall_64
      2.80 ±  6%      +0.9        3.73        perf-profile.calltrace.cycles-pp.syscall_return_via_sysret
      0.00            +1.2        1.21 ±  7%  perf-profile.calltrace.cycles-pp.smp_call_function_single.on_each_cpu_mask.on_each_cpu_cond_mask.flush_tlb_mm_range.ptep_clear_flush
      0.00            +1.3        1.25 ±  7%  perf-profile.calltrace.cycles-pp.on_each_cpu_mask.on_each_cpu_cond_mask.flush_tlb_mm_range.ptep_clear_flush.try_to_unmap_one
      0.00            +1.4        1.38 ±  7%  perf-profile.calltrace.cycles-pp.on_each_cpu_cond_mask.flush_tlb_mm_range.ptep_clear_flush.try_to_unmap_one.rmap_walk_file
      3.73 ±  7%      +1.4        5.11 ±  2%  perf-profile.calltrace.cycles-pp.__mutex_lock.pipe_write.__vfs_write.vfs_write.ksys_write
      0.00            +1.6        1.56 ±  7%  perf-profile.calltrace.cycles-pp.flush_tlb_mm_range.ptep_clear_flush.try_to_unmap_one.rmap_walk_file.try_to_unmap
      0.00            +1.6        1.63 ±  7%  perf-profile.calltrace.cycles-pp.ptep_clear_flush.try_to_unmap_one.rmap_walk_file.try_to_unmap.migrate_pages
      0.00            +2.2        2.20 ±  6%  perf-profile.calltrace.cycles-pp.try_to_unmap_one.rmap_walk_file.try_to_unmap.migrate_pages.migrate_to_node
      0.00            +2.3        2.30 ±  6%  perf-profile.calltrace.cycles-pp.rmap_walk_file.try_to_unmap.migrate_pages.migrate_to_node.do_migrate_pages
      0.00            +2.9        2.90 ±  6%  perf-profile.calltrace.cycles-pp.try_to_unmap.migrate_pages.migrate_to_node.do_migrate_pages.kernel_migrate_pages
      8.94 ±  5%      +3.4       12.33        perf-profile.calltrace.cycles-pp.pipe_read.__vfs_read.vfs_read.ksys_read.do_syscall_64
      9.24 ±  5%      +3.5       12.73        perf-profile.calltrace.cycles-pp.__vfs_read.vfs_read.ksys_read.do_syscall_64.entry_SYSCALL_64_after_hwframe
     13.65 ± 18%      +3.7       17.34 ±  6%  perf-profile.calltrace.cycles-pp.do_idle.cpu_startup_entry.start_secondary.secondary_startup_64
     13.65 ± 18%      +3.7       17.35 ±  6%  perf-profile.calltrace.cycles-pp.start_secondary.secondary_startup_64
     13.65 ± 18%      +3.7       17.35 ±  6%  perf-profile.calltrace.cycles-pp.cpu_startup_entry.start_secondary.secondary_startup_64
     13.89 ± 17%      +3.9       17.84 ±  6%  perf-profile.calltrace.cycles-pp.secondary_startup_64
     10.58 ±  5%      +4.0       14.54        perf-profile.calltrace.cycles-pp.pipe_write.__vfs_write.vfs_write.ksys_write.do_syscall_64
     10.90 ±  5%      +4.1       14.95        perf-profile.calltrace.cycles-pp.__vfs_write.vfs_write.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
     11.36 ±  5%      +4.3       15.62        perf-profile.calltrace.cycles-pp.vfs_read.ksys_read.do_syscall_64.entry_SYSCALL_64_after_hwframe
     11.83 ±  5%      +4.4       16.24        perf-profile.calltrace.cycles-pp.ksys_read.do_syscall_64.entry_SYSCALL_64_after_hwframe
      0.00            +4.5        4.54 ±  5%  perf-profile.calltrace.cycles-pp.migrate_pages.migrate_to_node.do_migrate_pages.kernel_migrate_pages.__x64_sys_migrate_pages
     12.69 ±  5%      +4.7       17.35        perf-profile.calltrace.cycles-pp.vfs_write.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
     13.15 ±  5%      +4.8       17.99        perf-profile.calltrace.cycles-pp.ksys_write.do_syscall_64.entry_SYSCALL_64_after_hwframe
      0.00            +5.1        5.10 ±  3%  perf-profile.calltrace.cycles-pp.__bitmap_weight.bitmap_bitremap.do_migrate_pages.kernel_migrate_pages.__x64_sys_migrate_pages
      0.00            +6.7        6.65 ±  4%  perf-profile.calltrace.cycles-pp.__bitmap_weight.do_migrate_pages.kernel_migrate_pages.__x64_sys_migrate_pages.do_syscall_64
      0.00            +7.9        7.85 ±  4%  perf-profile.calltrace.cycles-pp.bitmap_bitremap.do_migrate_pages.kernel_migrate_pages.__x64_sys_migrate_pages.do_syscall_64
      0.00            +8.3        8.31 ±  6%  perf-profile.calltrace.cycles-pp.queue_pages_pte_range.__walk_page_range.walk_page_range.queue_pages_range.migrate_to_node
      0.00            +9.4        9.39 ±  6%  perf-profile.calltrace.cycles-pp.__walk_page_range.walk_page_range.queue_pages_range.migrate_to_node.do_migrate_pages
      0.00           +10.3       10.28 ±  6%  perf-profile.calltrace.cycles-pp.walk_page_range.queue_pages_range.migrate_to_node.do_migrate_pages.kernel_migrate_pages
      0.00           +10.3       10.31 ±  6%  perf-profile.calltrace.cycles-pp.queue_pages_range.migrate_to_node.do_migrate_pages.kernel_migrate_pages.__x64_sys_migrate_pages
      0.63 ±  6%     +14.3       14.88 ±  4%  perf-profile.calltrace.cycles-pp.migrate_to_node.do_migrate_pages.kernel_migrate_pages.__x64_sys_migrate_pages.do_syscall_64
      1.25 ±  3%     +31.2       32.42 ±  4%  perf-profile.calltrace.cycles-pp.do_migrate_pages.kernel_migrate_pages.__x64_sys_migrate_pages.do_syscall_64.entry_SYSCALL_64_after_hwframe
      1.26 ±  3%     +31.4       32.62 ±  4%  perf-profile.calltrace.cycles-pp.__x64_sys_migrate_pages.do_syscall_64.entry_SYSCALL_64_after_hwframe
      1.26 ±  3%     +31.4       32.62 ±  4%  perf-profile.calltrace.cycles-pp.kernel_migrate_pages.__x64_sys_migrate_pages.do_syscall_64.entry_SYSCALL_64_after_hwframe
    360536 ±  3%   +1526.6%    5864634 ±  6%  interrupts.CAL:Function_call_interrupts
      4122 ± 31%     +65.0%       6803        interrupts.CPU0.NMI:Non-maskable_interrupts
      4122 ± 31%     +65.0%       6803        interrupts.CPU0.PMI:Performance_monitoring_interrupts
      6247 ±  9%     +23.4%       7708 ± 17%  interrupts.CPU0.RES:Rescheduling_interrupts
      3735 ± 15%   +2257.0%      88044 ± 33%  interrupts.CPU1.CAL:Function_call_interrupts
      6593 ± 16%     +23.6%       8150 ± 11%  interrupts.CPU1.RES:Rescheduling_interrupts
      1605 ± 48%   +5360.4%      87680 ± 33%  interrupts.CPU1.TLB:TLB_shootdowns
      3668 ± 27%   +2395.9%      91551 ± 17%  interrupts.CPU10.CAL:Function_call_interrupts
      3705 ± 45%     +87.8%       6957 ± 14%  interrupts.CPU10.NMI:Non-maskable_interrupts
      3705 ± 45%     +87.8%       6957 ± 14%  interrupts.CPU10.PMI:Performance_monitoring_interrupts
      3692 ±  5%     +50.9%       5571 ±  2%  interrupts.CPU10.RES:Rescheduling_interrupts
      1194 ± 74%   +7530.5%      91146 ± 18%  interrupts.CPU10.TLB:TLB_shootdowns
      3833 ± 29%   +2767.2%     109921 ± 10%  interrupts.CPU11.CAL:Function_call_interrupts
      3631 ±  2%     +86.9%       6787 ±  8%  interrupts.CPU11.RES:Rescheduling_interrupts
      1569 ± 76%   +6909.2%     109992 ± 11%  interrupts.CPU11.TLB:TLB_shootdowns
      3557 ± 35%   +2148.0%      79971 ± 54%  interrupts.CPU12.CAL:Function_call_interrupts
      3760 ± 11%     +58.0%       5942 ± 22%  interrupts.CPU12.RES:Rescheduling_interrupts
      1104 ±119%   +7079.3%      79277 ± 56%  interrupts.CPU12.TLB:TLB_shootdowns
      3639 ± 32%   +2257.8%      85817 ± 28%  interrupts.CPU13.CAL:Function_call_interrupts
      3497 ± 65%     +76.1%       6159 ± 26%  interrupts.CPU13.NMI:Non-maskable_interrupts
      3497 ± 65%     +76.1%       6159 ± 26%  interrupts.CPU13.PMI:Performance_monitoring_interrupts
      3799 ±  3%     +46.3%       5558 ± 11%  interrupts.CPU13.RES:Rescheduling_interrupts
      1329 ± 89%   +6373.1%      86075 ± 29%  interrupts.CPU13.TLB:TLB_shootdowns
      3942 ± 31%   +2512.7%     103013 ± 12%  interrupts.CPU14.CAL:Function_call_interrupts
      3736 ±  4%     +76.7%       6601 ± 14%  interrupts.CPU14.RES:Rescheduling_interrupts
      1491 ± 75%   +6811.2%     103097 ± 12%  interrupts.CPU14.TLB:TLB_shootdowns
      3605 ± 33%   +2212.0%      83354 ± 58%  interrupts.CPU15.CAL:Function_call_interrupts
      3624 ± 62%     +85.4%       6720 ± 22%  interrupts.CPU15.NMI:Non-maskable_interrupts
      3624 ± 62%     +85.4%       6720 ± 22%  interrupts.CPU15.PMI:Performance_monitoring_interrupts
      3751 ±  3%     +41.9%       5325 ± 19%  interrupts.CPU15.RES:Rescheduling_interrupts
      1208 ± 98%   +6788.3%      83227 ± 59%  interrupts.CPU15.TLB:TLB_shootdowns
      3738 ± 28%   +2823.1%     109274 ± 29%  interrupts.CPU16.CAL:Function_call_interrupts
      3584 ±  3%     +73.9%       6232 ± 17%  interrupts.CPU16.RES:Rescheduling_interrupts
      1749 ± 76%   +6151.7%     109343 ± 29%  interrupts.CPU16.TLB:TLB_shootdowns
      3590 ± 36%   +2164.9%      81327 ± 44%  interrupts.CPU17.CAL:Function_call_interrupts
      3515 ± 66%     +67.5%       5887 ± 31%  interrupts.CPU17.NMI:Non-maskable_interrupts
      3515 ± 66%     +67.5%       5887 ± 31%  interrupts.CPU17.PMI:Performance_monitoring_interrupts
      3602 ±  2%     +59.5%       5746 ± 14%  interrupts.CPU17.RES:Rescheduling_interrupts
      1191 ±109%   +6686.6%      80845 ± 46%  interrupts.CPU17.TLB:TLB_shootdowns
      4548 ± 23%   +2020.8%      96469 ± 48%  interrupts.CPU18.CAL:Function_call_interrupts
      3822 ±  8%     +52.3%       5822 ± 21%  interrupts.CPU18.RES:Rescheduling_interrupts
      2195 ± 50%   +4291.9%      96414 ± 48%  interrupts.CPU18.TLB:TLB_shootdowns
      3596 ± 15%   +1942.4%      73450 ± 82%  interrupts.CPU2.CAL:Function_call_interrupts
      5367 ±  6%     +33.2%       7150 ±  6%  interrupts.CPU2.NMI:Non-maskable_interrupts
      5367 ±  6%     +33.2%       7150 ±  6%  interrupts.CPU2.PMI:Performance_monitoring_interrupts
      3608 ± 33%   +1494.0%      57512 ± 48%  interrupts.CPU20.CAL:Function_call_interrupts
      3723 ±  3%     +36.6%       5085 ± 11%  interrupts.CPU20.RES:Rescheduling_interrupts
      1159 ± 97%   +4754.8%      56304 ± 50%  interrupts.CPU20.TLB:TLB_shootdowns
      3686 ± 30%   +2621.0%     100315 ± 33%  interrupts.CPU21.CAL:Function_call_interrupts
      3574 ± 67%     +77.6%       6349 ± 25%  interrupts.CPU21.NMI:Non-maskable_interrupts
      3574 ± 67%     +77.6%       6349 ± 25%  interrupts.CPU21.PMI:Performance_monitoring_interrupts
      3835 ± 13%     +65.2%       6337 ± 15%  interrupts.CPU21.RES:Rescheduling_interrupts
      1162 ± 98%   +8509.6%     100065 ± 34%  interrupts.CPU21.TLB:TLB_shootdowns
      3687 ± 27%   +2336.0%      89813 ± 50%  interrupts.CPU22.CAL:Function_call_interrupts
      3810           +83.5%       6993 ± 27%  interrupts.CPU22.RES:Rescheduling_interrupts
      1484 ± 66%   +5953.7%      89867 ± 51%  interrupts.CPU22.TLB:TLB_shootdowns
      3974 ± 17%   +2750.3%     113270 ± 15%  interrupts.CPU23.CAL:Function_call_interrupts
      3926 ± 11%     +80.7%       7096 ±  9%  interrupts.CPU23.RES:Rescheduling_interrupts
      1464 ± 53%   +7676.5%     113848 ± 15%  interrupts.CPU23.TLB:TLB_shootdowns
      4345 ± 14%   +2287.9%     103770 ± 13%  interrupts.CPU24.CAL:Function_call_interrupts
      4072 ±  9%     +84.4%       7507 ± 13%  interrupts.CPU24.RES:Rescheduling_interrupts
      1858 ± 38%   +5495.7%     103967 ± 14%  interrupts.CPU24.TLB:TLB_shootdowns
      3807 ± 26%   +2463.3%      97585 ± 30%  interrupts.CPU25.CAL:Function_call_interrupts
      3852 ±  4%     +78.3%       6870 ± 14%  interrupts.CPU25.RES:Rescheduling_interrupts
      1368 ± 72%   +7011.0%      97296 ± 31%  interrupts.CPU25.TLB:TLB_shootdowns
      3574 ± 21%   +1729.3%      65390 ± 48%  interrupts.CPU26.CAL:Function_call_interrupts
      6245 ±  7%     -30.6%       4334 ± 26%  interrupts.CPU26.NMI:Non-maskable_interrupts
      6245 ±  7%     -30.6%       4334 ± 26%  interrupts.CPU26.PMI:Performance_monitoring_interrupts
      4092 ± 18%     +37.4%       5623 ± 14%  interrupts.CPU26.RES:Rescheduling_interrupts
      1168 ± 64%   +5429.2%      64594 ± 50%  interrupts.CPU26.TLB:TLB_shootdowns
      6377 ± 10%     -34.5%       4179 ± 23%  interrupts.CPU27.NMI:Non-maskable_interrupts
      6377 ± 10%     -34.5%       4179 ± 23%  interrupts.CPU27.PMI:Performance_monitoring_interrupts
      6425 ± 14%     -38.7%       3937 ± 23%  interrupts.CPU28.NMI:Non-maskable_interrupts
      6425 ± 14%     -38.7%       3937 ± 23%  interrupts.CPU28.PMI:Performance_monitoring_interrupts
      4880 ±  4%    +894.4%      48528 ± 19%  interrupts.CPU29.CAL:Function_call_interrupts
      3951 ±  6%     +25.6%       4962 ±  6%  interrupts.CPU29.RES:Rescheduling_interrupts
      2365 ± 13%   +1898.5%      47274 ± 20%  interrupts.CPU29.TLB:TLB_shootdowns
      3890 ± 13%   +3046.4%     122404 ± 11%  interrupts.CPU3.CAL:Function_call_interrupts
      4834 ± 22%     +53.2%       7407 ±  4%  interrupts.CPU3.NMI:Non-maskable_interrupts
      4834 ± 22%     +53.2%       7407 ±  4%  interrupts.CPU3.PMI:Performance_monitoring_interrupts
      4600 ±  3%     +89.1%       8699 ± 25%  interrupts.CPU3.RES:Rescheduling_interrupts
      1585 ± 50%   +7626.2%     122460 ± 12%  interrupts.CPU3.TLB:TLB_shootdowns
      4598 ± 15%   +1179.7%      58846 ± 45%  interrupts.CPU31.CAL:Function_call_interrupts
      3672 ±  3%     +61.8%       5941 ± 14%  interrupts.CPU31.RES:Rescheduling_interrupts
      2274 ± 27%   +2438.3%      57732 ± 47%  interrupts.CPU31.TLB:TLB_shootdowns
      4554 ± 21%   +1114.9%      55329 ± 56%  interrupts.CPU32.CAL:Function_call_interrupts
      3741           +44.6%       5408 ± 21%  interrupts.CPU32.RES:Rescheduling_interrupts
      2105 ± 41%   +2460.0%      53894 ± 59%  interrupts.CPU32.TLB:TLB_shootdowns
      3907 ± 30%    +860.8%      37539 ± 65%  interrupts.CPU35.CAL:Function_call_interrupts
      3871 ±  9%     +22.8%       4752 ± 18%  interrupts.CPU35.RES:Rescheduling_interrupts
      1638 ± 73%   +2093.4%      35938 ± 68%  interrupts.CPU35.TLB:TLB_shootdowns
      4647 ± 23%   +1627.4%      80281 ± 12%  interrupts.CPU36.CAL:Function_call_interrupts
      3821 ±  5%     +57.4%       6015 ±  9%  interrupts.CPU36.RES:Rescheduling_interrupts
      2181 ± 45%   +3557.4%      79776 ± 12%  interrupts.CPU36.TLB:TLB_shootdowns
      7070 ± 14%     -30.3%       4924 ± 24%  interrupts.CPU38.NMI:Non-maskable_interrupts
      7070 ± 14%     -30.3%       4924 ± 24%  interrupts.CPU38.PMI:Performance_monitoring_interrupts
      3711 ± 12%   +1962.2%      76543 ± 53%  interrupts.CPU4.CAL:Function_call_interrupts
      4987 ± 21%     +43.4%       7152 ±  3%  interrupts.CPU4.NMI:Non-maskable_interrupts
      4987 ± 21%     +43.4%       7152 ±  3%  interrupts.CPU4.PMI:Performance_monitoring_interrupts
      3815 ±  2%     +60.4%       6121 ± 20%  interrupts.CPU4.RES:Rescheduling_interrupts
      1324 ± 33%   +5629.5%      75872 ± 55%  interrupts.CPU4.TLB:TLB_shootdowns
      4648 ± 22%    +814.8%      42517 ± 39%  interrupts.CPU43.CAL:Function_call_interrupts
      2282 ± 35%   +1704.8%      41186 ± 41%  interrupts.CPU43.TLB:TLB_shootdowns
      3602 ± 29%   +2533.9%      94873 ± 42%  interrupts.CPU45.CAL:Function_call_interrupts
      4435 ± 44%     +62.7%       7217 ± 10%  interrupts.CPU45.NMI:Non-maskable_interrupts
      4435 ± 44%     +62.7%       7217 ± 10%  interrupts.CPU45.PMI:Performance_monitoring_interrupts
      3712 ±  4%     +57.8%       5856 ± 21%  interrupts.CPU45.RES:Rescheduling_interrupts
      1180 ± 98%   +7913.7%      94601 ± 44%  interrupts.CPU45.TLB:TLB_shootdowns
      4762 ± 26%     +49.6%       7124 ± 12%  interrupts.CPU46.NMI:Non-maskable_interrupts
      4762 ± 26%     +49.6%       7124 ± 12%  interrupts.CPU46.PMI:Performance_monitoring_interrupts
      1165 ±115%   +5808.7%      68836 ± 84%  interrupts.CPU47.TLB:TLB_shootdowns
      3486 ± 30%   +2453.1%      89006 ± 60%  interrupts.CPU48.CAL:Function_call_interrupts
      4565 ± 46%     +55.6%       7104 ± 14%  interrupts.CPU48.NMI:Non-maskable_interrupts
      4565 ± 46%     +55.6%       7104 ± 14%  interrupts.CPU48.PMI:Performance_monitoring_interrupts
      3695 ±  2%     +70.3%       6295 ± 20%  interrupts.CPU48.RES:Rescheduling_interrupts
      1073 ±111%   +8148.9%      88511 ± 62%  interrupts.CPU48.TLB:TLB_shootdowns
      4106 ± 47%     +69.1%       6944 ± 14%  interrupts.CPU49.NMI:Non-maskable_interrupts
      4106 ± 47%     +69.1%       6944 ± 14%  interrupts.CPU49.PMI:Performance_monitoring_interrupts
      1185 ± 95%   +5391.3%      65112 ± 98%  interrupts.CPU49.TLB:TLB_shootdowns
      3601 ±  8%   +2568.7%      96098 ± 29%  interrupts.CPU5.CAL:Function_call_interrupts
      3785 ± 26%     +91.1%       7233 ±  3%  interrupts.CPU5.NMI:Non-maskable_interrupts
      3785 ± 26%     +91.1%       7233 ±  3%  interrupts.CPU5.PMI:Performance_monitoring_interrupts
      3668 ±  2%     +74.1%       6386 ± 16%  interrupts.CPU5.RES:Rescheduling_interrupts
      1137 ± 29%   +8322.2%      95802 ± 30%  interrupts.CPU5.TLB:TLB_shootdowns
      3745 ± 41%     +84.0%       6890 ± 18%  interrupts.CPU50.NMI:Non-maskable_interrupts
      3745 ± 41%     +84.0%       6890 ± 18%  interrupts.CPU50.PMI:Performance_monitoring_interrupts
    654.50 ± 68%  +12823.4%      84583 ± 66%  interrupts.CPU50.TLB:TLB_shootdowns
      3754 ± 59%     +84.3%       6921 ± 18%  interrupts.CPU51.NMI:Non-maskable_interrupts
      3754 ± 59%     +84.3%       6921 ± 18%  interrupts.CPU51.PMI:Performance_monitoring_interrupts
      3616 ±  4%     +63.4%       5907 ± 23%  interrupts.CPU51.RES:Rescheduling_interrupts
      1051 ±115%   +7965.0%      84783 ± 67%  interrupts.CPU51.TLB:TLB_shootdowns
      3537 ± 35%   +1280.8%      48845 ± 62%  interrupts.CPU52.CAL:Function_call_interrupts
      1067 ±112%   +4353.9%      47545 ± 65%  interrupts.CPU52.TLB:TLB_shootdowns
      1112 ±109%   +4960.5%      56285 ± 97%  interrupts.CPU53.TLB:TLB_shootdowns
      3841 ± 56%     +80.5%       6932 ± 20%  interrupts.CPU54.NMI:Non-maskable_interrupts
      3841 ± 56%     +80.5%       6932 ± 20%  interrupts.CPU54.PMI:Performance_monitoring_interrupts
      3561           +69.5%       6036 ± 23%  interrupts.CPU54.RES:Rescheduling_interrupts
      3543 ± 32%   +1357.6%      51648 ± 60%  interrupts.CPU55.CAL:Function_call_interrupts
      3537 ±  2%     +39.5%       4933 ± 13%  interrupts.CPU55.RES:Rescheduling_interrupts
      1144 ±103%   +4304.4%      50397 ± 63%  interrupts.CPU55.TLB:TLB_shootdowns
      3550 ± 35%   +2444.4%      90343 ± 56%  interrupts.CPU56.CAL:Function_call_interrupts
      3650 ± 65%     +94.0%       7082 ± 11%  interrupts.CPU56.NMI:Non-maskable_interrupts
      3650 ± 65%     +94.0%       7082 ± 11%  interrupts.CPU56.PMI:Performance_monitoring_interrupts
      3651           +65.0%       6023 ± 23%  interrupts.CPU56.RES:Rescheduling_interrupts
      1136 ±112%   +7824.5%      90062 ± 58%  interrupts.CPU56.TLB:TLB_shootdowns
      2575 ± 33%    +170.5%       6966 ± 17%  interrupts.CPU57.NMI:Non-maskable_interrupts
      2575 ± 33%    +170.5%       6966 ± 17%  interrupts.CPU57.PMI:Performance_monitoring_interrupts
      3533 ±  3%     +63.2%       5768 ± 24%  interrupts.CPU57.RES:Rescheduling_interrupts
      1119 ±104%   +7722.0%      87547 ± 60%  interrupts.CPU57.TLB:TLB_shootdowns
      3626           +52.3%       5525 ± 18%  interrupts.CPU58.RES:Rescheduling_interrupts
      3579 ± 35%   +2484.6%      92516 ± 52%  interrupts.CPU59.CAL:Function_call_interrupts
      2676 ± 32%    +152.7%       6762 ± 23%  interrupts.CPU59.NMI:Non-maskable_interrupts
      2676 ± 32%    +152.7%       6762 ± 23%  interrupts.CPU59.PMI:Performance_monitoring_interrupts
      3615           +63.4%       5907 ± 22%  interrupts.CPU59.RES:Rescheduling_interrupts
      1144 ±104%   +7945.0%      92075 ± 53%  interrupts.CPU59.TLB:TLB_shootdowns
      3821 ± 15%   +1528.2%      62212 ± 38%  interrupts.CPU6.CAL:Function_call_interrupts
      3942 ± 39%     +71.2%       6748 ±  9%  interrupts.CPU6.NMI:Non-maskable_interrupts
      3942 ± 39%     +71.2%       6748 ±  9%  interrupts.CPU6.PMI:Performance_monitoring_interrupts
      3903 ±  4%     +47.5%       5759 ± 22%  interrupts.CPU6.RES:Rescheduling_interrupts
      1496 ± 36%   +3987.9%      61185 ± 39%  interrupts.CPU6.TLB:TLB_shootdowns
      2798 ± 22%    +139.4%       6699 ± 21%  interrupts.CPU60.NMI:Non-maskable_interrupts
      2798 ± 22%    +139.4%       6699 ± 21%  interrupts.CPU60.PMI:Performance_monitoring_interrupts
      2957 ± 17%    +123.3%       6604 ± 22%  interrupts.CPU61.NMI:Non-maskable_interrupts
      2957 ± 17%    +123.3%       6604 ± 22%  interrupts.CPU61.PMI:Performance_monitoring_interrupts
      3680 ± 37%   +2380.7%      91308 ± 40%  interrupts.CPU62.CAL:Function_call_interrupts
      4022 ± 14%     +37.9%       5547 ± 11%  interrupts.CPU62.RES:Rescheduling_interrupts
      1136 ±124%   +7892.6%      90855 ± 42%  interrupts.CPU62.TLB:TLB_shootdowns
      3634 ± 36%   +2919.3%     109735 ± 24%  interrupts.CPU63.CAL:Function_call_interrupts
      3521 ± 26%    +114.0%       7538 ±  2%  interrupts.CPU63.NMI:Non-maskable_interrupts
      3521 ± 26%    +114.0%       7538 ±  2%  interrupts.CPU63.PMI:Performance_monitoring_interrupts
      3948 ± 10%     +65.9%       6551 ± 18%  interrupts.CPU63.RES:Rescheduling_interrupts
      1152 ±110%   +9401.5%     109528 ± 24%  interrupts.CPU63.TLB:TLB_shootdowns
      3592 ± 34%   +3034.8%     112602 ± 26%  interrupts.CPU64.CAL:Function_call_interrupts
      2961 ± 17%    +148.8%       7369 ±  9%  interrupts.CPU64.NMI:Non-maskable_interrupts
      2961 ± 17%    +148.8%       7369 ±  9%  interrupts.CPU64.PMI:Performance_monitoring_interrupts
      4193 ± 19%     +66.8%       6996 ± 10%  interrupts.CPU64.RES:Rescheduling_interrupts
      1104 ±106%  +10101.5%     112650 ± 27%  interrupts.CPU64.TLB:TLB_shootdowns
      3509 ± 33%   +2502.5%      91320 ± 30%  interrupts.CPU65.CAL:Function_call_interrupts
      2965 ± 17%    +145.6%       7283 ±  6%  interrupts.CPU65.NMI:Non-maskable_interrupts
      2965 ± 17%    +145.6%       7283 ±  6%  interrupts.CPU65.PMI:Performance_monitoring_interrupts
      3859 ±  8%     +52.9%       5899 ± 13%  interrupts.CPU65.RES:Rescheduling_interrupts
      1037 ±112%   +8669.9%      91009 ± 31%  interrupts.CPU65.TLB:TLB_shootdowns
      3370 ± 10%   +2036.3%      71994 ±  5%  interrupts.CPU7.CAL:Function_call_interrupts
      3469 ± 44%     +72.9%       5999 ± 24%  interrupts.CPU7.NMI:Non-maskable_interrupts
      3469 ± 44%     +72.9%       5999 ± 24%  interrupts.CPU7.PMI:Performance_monitoring_interrupts
      3809 ±  4%     +47.7%       5625 ± 11%  interrupts.CPU7.RES:Rescheduling_interrupts
    988.50 ± 61%   +7115.2%      71322 ±  6%  interrupts.CPU7.TLB:TLB_shootdowns
      3654 ±  4%     +80.9%       6612 ± 24%  interrupts.CPU77.RES:Rescheduling_interrupts
      3569 ± 25%   +2737.1%     101271 ± 22%  interrupts.CPU8.CAL:Function_call_interrupts
      3412 ± 47%     +81.7%       6202 ± 26%  interrupts.CPU8.NMI:Non-maskable_interrupts
      3412 ± 47%     +81.7%       6202 ± 26%  interrupts.CPU8.PMI:Performance_monitoring_interrupts
      3822 ±  6%     +72.8%       6605 ± 13%  interrupts.CPU8.RES:Rescheduling_interrupts
      2371 ± 57%   +4169.2%     101244 ± 23%  interrupts.CPU8.TLB:TLB_shootdowns
      3280 ± 25%   +2403.5%      82113 ± 56%  interrupts.CPU9.CAL:Function_call_interrupts
      3406 ± 50%    +101.8%       6873 ± 11%  interrupts.CPU9.NMI:Non-maskable_interrupts
      3406 ± 50%    +101.8%       6873 ± 11%  interrupts.CPU9.PMI:Performance_monitoring_interrupts
      3636 ±  6%     +66.1%       6041 ± 24%  interrupts.CPU9.RES:Rescheduling_interrupts
    898.75 ±100%   +8966.6%      81486 ± 58%  interrupts.CPU9.TLB:TLB_shootdowns
    441700 ±  6%     +18.5%     523360 ±  5%  interrupts.NMI:Non-maskable_interrupts
    441700 ±  6%     +18.5%     523360 ±  5%  interrupts.PMI:Performance_monitoring_interrupts
    344450 ±  2%     +42.8%     491951 ±  2%  interrupts.RES:Rescheduling_interrupts
    153414 ± 10%   +3677.4%    5795118 ±  6%  interrupts.TLB:TLB_shootdowns


                                                                                
                                stress-ng.numa.ops                              
                                                                                
  3500 +-+------------------------------------------------------------------+   
       |  O                     O                                           |   
  3000 +-+     O   O  O   OO   O       O                                    |   
       O O  O O  O  O        O    O OO                                      |   
  2500 +-+              O                                  O                |   
       |                                  O O O  O OO O OO                  |   
  2000 +-+                               O     O                            |   
       |                                                                    |   
  1500 +-+                                                                  |   
       |                                                                    |   
  1000 +-+                                                                  |   
       |                                                                    |   
   500 +-+                                                                  |   
       |                                                                    |   
     0 +-+------------------------------------------------------------------+   
                                                                                
                                                                                                                                                                
                            stress-ng.numa.ops_per_sec                          
                                                                                
  700 +-+-------------------------------------------------------------------+   
      |  O                                                                  |   
  600 +-+      O  O  O   OO   O O     O                                     |   
      O O  O O  O   O       O    O O O                                      |   
  500 +-+              O                                                    |   
      |                                   O OO   OO O O OO O                |   
  400 +-+                               O      O                            |   
      |                                                                     |   
  300 +-+                                                                   |   
      |                                                                     |   
  200 +-+                                                                   |   
      |                                                                     |   
  100 +-+                                                                   |   
      |                                                                     |   
    0 +-+-------------------------------------------------------------------+   
                                                                                
                                                                                
[*] bisect-good sample
[O] bisect-bad  sample

***************************************************************************************************
vm-snb-8G: qemu-system-x86_64 -enable-kvm -cpu SandyBridge -smp 2 -m 8G
=========================================================================================
compiler/kconfig/rootfs/tbox_group/test/testcase:
  gcc-7/x86_64-rhel-7.2/debian-x86_64-2018-04-03.cgz/vm-snb-8G/cve/ltp

commit: 
  9627026352 ("mm: page_cache_add_speculative(): refactoring")
  cdaa813278 ("mm/gup: track gup-pinned pages")

96270263521248d5 cdaa813278ddc616ee201eacda7 
---------------- --------------------------- 
       fail:runs  %reproduction    fail:runs
           |             |             |    
           :12           8%           1:12    dmesg.BUG:soft_lockup-CPU##stuck_for#s
           :12          83%          10:12    dmesg.Kernel_panic-not_syncing:System_is_deadlocked_on_memory
           :12           8%           1:12    dmesg.Kernel_panic-not_syncing:softlockup:hung_tasks
           :12          83%          10:12    dmesg.Out_of_memory:Kill_process
           :12          83%          10:12    dmesg.Out_of_memory_and_no_killable_processes
           :12           8%           1:12    dmesg.RIP:free_reserved_area
         %stddev     %change         %stddev
             \          |                \  
      1.00          -100.0%       0.00        ltp.cve-2017-18075.pass
    783.53 ± 40%    +165.9%       2083        ltp.time.elapsed_time
    783.53 ± 40%    +165.9%       2083        ltp.time.elapsed_time.max
   1171525 ± 21%     -69.1%     362268        ltp.time.involuntary_context_switches
  11374889 ± 27%     -89.7%    1171686        ltp.time.minor_page_faults
    103.08 ±  9%     -46.6%      55.00        ltp.time.percent_of_cpu_this_job_got
    199802 ± 12%     -36.0%     127912        ltp.time.voluntary_context_switches
    557835 ±  3%    +469.2%    3175044        meminfo.Active
    557602 ±  3%    +469.4%    3174826        meminfo.Active(anon)
    204797           -51.1%     100217        meminfo.CmaFree
    709192 ±  3%     -11.8%     625168        meminfo.Inactive
     22617 ± 16%     -50.8%      11135        meminfo.Inactive(anon)
   4772734           -52.9%    2247863        meminfo.MemAvailable
   4273603           -57.4%    1820264        meminfo.MemFree
   3888307           +63.1%    6341643        meminfo.Memused



***************************************************************************************************
lkp-skl-4sp1: 192 threads Skylake-4S with 704G memory
=========================================================================================
compiler/cpufreq_governor/kconfig/mode/nr_task/rootfs/tbox_group/test/testcase:
  gcc-7/performance/x86_64-rhel-7.2/process/100%/debian-x86_64-2018-04-03.cgz/lkp-skl-4sp1/futex1/will-it-scale

commit: 
  9627026352 ("mm: page_cache_add_speculative(): refactoring")
  cdaa813278 ("mm/gup: track gup-pinned pages")

96270263521248d5 cdaa813278ddc616ee201eacda7 
---------------- --------------------------- 
         %stddev     %change         %stddev
             \          |                \  
      0.42 ± 41%     -37.6%       0.27 ± 38%  turbostat.CPU%c1
    436529           +18.1%     515400 ±  2%  meminfo.Active
    432417           +18.2%     511272 ±  2%  meminfo.Active(anon)
      1.01 ±100%   +1140.2%      12.50 ±141%  irq_exception_noise.__do_page_fault.50th
      1.10 ±100%   +1059.7%      12.70 ±137%  irq_exception_noise.__do_page_fault.60th
      1.18 ±100%   +1002.0%      13.00 ±133%  irq_exception_noise.__do_page_fault.70th
      1.32 ±100%    +934.8%      13.71 ±123%  irq_exception_noise.__do_page_fault.80th
    545804 ± 35%     -56.4%     238144 ± 29%  numa-numastat.node0.local_node
    568271 ± 32%     -54.7%     257664 ± 24%  numa-numastat.node0.numa_hit
    232178 ± 44%    +135.2%     546083 ± 30%  numa-numastat.node2.local_node
    268049 ± 38%    +114.9%     576076 ± 27%  numa-numastat.node2.numa_hit
    330370 ± 19%     -39.1%     201131 ± 50%  numa-numastat.node3.local_node
    342159 ± 15%     -31.7%     233865 ± 42%  numa-numastat.node3.numa_hit
    108167           +18.2%     127807 ±  2%  proc-vmstat.nr_active_anon
      6541            -1.8%       6425        proc-vmstat.nr_inactive_anon
      8474            -2.4%       8271 ±  2%  proc-vmstat.nr_mapped
    108167           +18.2%     127807 ±  2%  proc-vmstat.nr_zone_active_anon
      6541            -1.8%       6425        proc-vmstat.nr_zone_inactive_anon
     29259            +3.5%      30283        proc-vmstat.pgactivate
   1477807            -2.1%    1446297        proc-vmstat.pgfree
     13.29 ±  5%      -2.6       10.72 ±  4%  perf-stat.i.cache-miss-rate%
   1107530 ±  4%     -16.6%     923800 ±  3%  perf-stat.i.cache-misses
     57.31            -2.0%      56.14        perf-stat.i.cpu-migrations
    429491 ±  3%     +14.9%     493355 ±  4%  perf-stat.i.cycles-between-cache-misses
     51.31           +10.9       62.22 ±  6%  perf-stat.i.iTLB-load-miss-rate%
 3.369e+08            +2.2%  3.443e+08        perf-stat.i.iTLB-load-misses
   3.2e+08           -32.8%  2.149e+08 ± 16%  perf-stat.i.iTLB-loads
    863.04            -2.4%     842.12        perf-stat.i.instructions-per-iTLB-miss
    355.57 ±  6%     -13.9%     306.21 ±  5%  sched_debug.cfs_rq:/.exec_clock.stddev
      0.46          +163.6%       1.21 ± 10%  sched_debug.cfs_rq:/.nr_spread_over.avg
    619.50 ±  6%     -13.9%     533.25 ±  7%  sched_debug.cfs_rq:/.util_est_enqueued.max
    128891           +42.6%     183838 ± 30%  sched_debug.cpu.avg_idle.stddev
     11367 ±  2%     +14.6%      13028        sched_debug.cpu.curr->pid.max
      2547 ± 15%     +30.3%       3321        sched_debug.cpu.curr->pid.min
    -11.50           -23.9%      -8.75        sched_debug.cpu.nr_uninterruptible.min
     10647 ± 20%     -40.5%       6331 ± 17%  sched_debug.cpu.sched_goidle.max
    800.32 ± 19%     -31.8%     545.75 ±  5%  sched_debug.cpu.sched_goidle.stddev
     20627           +16.3%      23980 ±  6%  softirqs.CPU0.RCU
    112466 ±  4%      -8.4%     102965 ±  4%  softirqs.CPU0.TIMER
     20826           +10.9%      23088 ±  6%  softirqs.CPU110.RCU
     20775 ±  8%     +22.1%      25361 ±  5%  softirqs.CPU112.RCU
     20835 ± 10%     +22.8%      25592 ±  5%  softirqs.CPU113.RCU
     21208 ±  6%     +21.7%      25811 ±  4%  softirqs.CPU114.RCU
     20691 ±  7%     +24.5%      25764 ±  6%  softirqs.CPU115.RCU
     20809 ±  8%     +22.8%      25550 ±  5%  softirqs.CPU116.RCU
     20870 ±  9%     +23.4%      25754 ±  4%  softirqs.CPU117.RCU
     20714 ±  8%     +23.4%      25568 ±  5%  softirqs.CPU118.RCU
     20652 ±  8%     +22.6%      25310 ±  5%  softirqs.CPU119.RCU
     20909           +10.8%      23171 ±  7%  softirqs.CPU13.RCU
     20488           +10.1%      22548 ±  5%  softirqs.CPU14.RCU
     20955 ±  6%     +21.3%      25421 ±  6%  softirqs.CPU16.RCU
     19946           +15.2%      22982 ± 11%  softirqs.CPU173.RCU
    133691 ± 19%     -22.1%     104181 ±  4%  softirqs.CPU176.TIMER
     21426 ±  3%     +17.6%      25194 ±  4%  softirqs.CPU18.RCU
     20370 ±  6%     +24.1%      25275 ±  3%  softirqs.CPU19.RCU
     21029 ±  4%     +19.6%      25146 ±  5%  softirqs.CPU20.RCU
     20971 ±  8%     +19.7%      25095 ±  4%  softirqs.CPU21.RCU
     20759 ±  6%     +20.2%      24958 ±  5%  softirqs.CPU22.RCU
     20627 ±  6%     +21.6%      25077 ±  5%  softirqs.CPU23.RCU
     20693           +10.5%      22867 ±  6%  softirqs.CPU5.RCU
     18951 ±  4%     +21.1%      22953 ± 12%  softirqs.CPU75.RCU
    110575 ±  4%      -7.5%     102329 ±  2%  softirqs.CPU98.TIMER
     57149           +37.8%      78776 ± 10%  numa-vmstat.node0.nr_file_pages
      1470           +84.0%       2706 ± 37%  numa-vmstat.node0.nr_mapped
      1020 ± 74%   +1687.7%      18243 ± 45%  numa-vmstat.node0.nr_shmem
     16.50 ± 33%   +8503.0%       1419 ±122%  numa-vmstat.node1.nr_inactive_anon
      6205           +19.9%       7437 ± 10%  numa-vmstat.node1.nr_kernel_stack
    594.50 ±  3%    +141.9%       1438 ± 52%  numa-vmstat.node1.nr_page_table_pages
     56.00 ± 33%   +2705.4%       1571 ±112%  numa-vmstat.node1.nr_shmem
      3072 ±  5%    +119.8%       6751 ± 17%  numa-vmstat.node1.nr_slab_reclaimable
     11562 ±  2%     +31.6%      15218 ±  9%  numa-vmstat.node1.nr_slab_unreclaimable
     16.50 ± 33%   +8503.0%       1419 ±122%  numa-vmstat.node1.nr_zone_inactive_anon
    266341 ± 12%    +131.7%     617001 ±  9%  numa-vmstat.node1.numa_hit
    140430 ± 23%    +258.4%     503291 ± 12%  numa-vmstat.node1.numa_local
      1028          -100.0%       0.00        numa-vmstat.node2.nr_active_file
     71145           -19.0%      57616 ±  2%  numa-vmstat.node2.nr_file_pages
      4668 ± 12%     -67.9%       1500 ±104%  numa-vmstat.node2.nr_inactive_anon
    544.50          -100.0%       0.00        numa-vmstat.node2.nr_inactive_file
      9199 ±  4%     -28.3%       6593 ±  5%  numa-vmstat.node2.nr_kernel_stack
      3552           -50.5%       1758 ± 33%  numa-vmstat.node2.nr_mapped
      2955 ±  6%     -65.5%       1018 ± 38%  numa-vmstat.node2.nr_page_table_pages
      4996 ± 11%     -65.4%       1727 ± 95%  numa-vmstat.node2.nr_shmem
     64607           -13.5%      55888        numa-vmstat.node2.nr_unevictable
      1028          -100.0%       0.00        numa-vmstat.node2.nr_zone_active_file
      4668 ± 12%     -67.9%       1500 ±104%  numa-vmstat.node2.nr_zone_inactive_anon
    544.50          -100.0%       0.00        numa-vmstat.node2.nr_zone_inactive_file
     64607           -13.5%      55888        numa-vmstat.node2.nr_zone_unevictable
     31367 ± 22%     -70.8%       9145 ±104%  numa-vmstat.node3.nr_active_anon
     11913 ± 59%     -87.6%       1476 ± 52%  numa-vmstat.node3.nr_anon_pages
      1000 ± 17%     -72.0%     279.75 ±150%  numa-vmstat.node3.nr_inactive_anon
    698.00 ± 11%     -15.7%     588.25        numa-vmstat.node3.nr_page_table_pages
      6430 ± 14%     -39.1%       3918 ± 20%  numa-vmstat.node3.nr_slab_reclaimable
     31366 ± 22%     -70.8%       9145 ±104%  numa-vmstat.node3.nr_zone_active_anon
      1000 ± 17%     -72.0%     279.75 ±150%  numa-vmstat.node3.nr_zone_inactive_anon
    345814 ± 42%     -45.4%     188830 ± 51%  numa-vmstat.node3.numa_local
    228598           +37.8%     315090 ± 10%  numa-meminfo.node0.FilePages
      3152 ± 89%    +354.3%      14320 ± 50%  numa-meminfo.node0.Inactive
      5883           +80.6%      10625 ± 34%  numa-meminfo.node0.Mapped
      4082 ± 74%   +1687.1%      72956 ± 45%  numa-meminfo.node0.Shmem
     68.50 ± 31%   +8993.8%       6229 ±107%  numa-meminfo.node1.Inactive
     68.50 ± 31%   +8191.2%       5679 ±122%  numa-meminfo.node1.Inactive(anon)
     12286 ±  5%    +119.8%      27005 ± 17%  numa-meminfo.node1.KReclaimable
      6207           +19.9%       7441 ± 10%  numa-meminfo.node1.KernelStack
      2372 ±  3%    +142.7%       5757 ± 52%  numa-meminfo.node1.PageTables
     12286 ±  5%    +119.8%      27005 ± 17%  numa-meminfo.node1.SReclaimable
     46242 ±  2%     +31.6%      60873 ±  9%  numa-meminfo.node1.SUnreclaim
    223.50 ± 33%   +2711.9%       6284 ±112%  numa-meminfo.node1.Shmem
     58528           +50.1%      87879 ± 11%  numa-meminfo.node1.Slab
      4112          -100.0%       0.00        numa-meminfo.node2.Active(file)
    284580           -19.0%     230466 ±  2%  numa-meminfo.node2.FilePages
     20854 ± 11%     -71.2%       6004 ±104%  numa-meminfo.node2.Inactive
     18673 ± 12%     -67.8%       6004 ±104%  numa-meminfo.node2.Inactive(anon)
      2180          -100.0%       0.00        numa-meminfo.node2.Inactive(file)
      9203 ±  4%     -28.3%       6594 ±  5%  numa-meminfo.node2.KernelStack
     13712           -48.6%       7054 ± 33%  numa-meminfo.node2.Mapped
    883222 ±  6%     -16.2%     740514 ± 13%  numa-meminfo.node2.MemUsed
     11829 ±  6%     -65.8%       4040 ± 38%  numa-meminfo.node2.PageTables
     19985 ± 11%     -65.4%       6911 ± 95%  numa-meminfo.node2.Shmem
    258431           -13.5%     223554        numa-meminfo.node2.Unevictable
    125256 ± 22%     -70.8%      36547 ±104%  numa-meminfo.node3.Active
    125256 ± 22%     -70.8%      36547 ±104%  numa-meminfo.node3.Active(anon)
     24571 ± 83%     -96.0%     974.75 ±173%  numa-meminfo.node3.AnonHugePages
     47677 ± 59%     -87.7%       5876 ± 52%  numa-meminfo.node3.AnonPages
      3993 ± 18%     -72.1%       1115 ±149%  numa-meminfo.node3.Inactive
      3991 ± 18%     -72.1%       1115 ±149%  numa-meminfo.node3.Inactive(anon)
     25714 ± 14%     -39.1%      15671 ± 20%  numa-meminfo.node3.KReclaimable
    696078 ±  2%     -14.9%     592511 ±  8%  numa-meminfo.node3.MemUsed
      2772 ± 11%     -15.9%       2332        numa-meminfo.node3.PageTables
     25714 ± 14%     -39.1%      15671 ± 20%  numa-meminfo.node3.SReclaimable
     78860 ±  8%     -16.7%      65670 ±  6%  numa-meminfo.node3.Slab
      1702 ± 25%     -44.9%     937.50 ± 17%  interrupts.CPU0.RES:Rescheduling_interrupts
      6102 ±  5%      -3.6%       5884 ±  5%  interrupts.CPU100.CAL:Function_call_interrupts
      6091 ±  5%      -4.1%       5842 ±  5%  interrupts.CPU101.CAL:Function_call_interrupts
      6100 ±  5%      -4.3%       5841 ±  6%  interrupts.CPU102.CAL:Function_call_interrupts
      6099 ±  5%      -3.6%       5882 ±  5%  interrupts.CPU103.CAL:Function_call_interrupts
      6099 ±  5%      -3.5%       5883 ±  5%  interrupts.CPU104.CAL:Function_call_interrupts
      6099 ±  5%      -3.6%       5882 ±  5%  interrupts.CPU106.CAL:Function_call_interrupts
      6119 ±  5%      -3.8%       5886 ±  5%  interrupts.CPU107.CAL:Function_call_interrupts
      6115 ±  5%      -8.8%       5575 ±  4%  interrupts.CPU108.CAL:Function_call_interrupts
      6115 ±  5%      -3.6%       5894 ±  4%  interrupts.CPU109.CAL:Function_call_interrupts
      6118 ±  5%      -3.9%       5879 ±  5%  interrupts.CPU110.CAL:Function_call_interrupts
      6117 ±  5%      -3.8%       5884 ±  4%  interrupts.CPU111.CAL:Function_call_interrupts
    291.50 ± 86%     -90.1%      29.00 ± 33%  interrupts.CPU111.RES:Rescheduling_interrupts
      6117 ±  5%      -3.6%       5897 ±  5%  interrupts.CPU112.CAL:Function_call_interrupts
      6117 ±  5%      -3.5%       5902 ±  5%  interrupts.CPU113.CAL:Function_call_interrupts
      6116 ±  5%      -3.5%       5904 ±  5%  interrupts.CPU114.CAL:Function_call_interrupts
      6116 ±  5%      -3.6%       5897 ±  5%  interrupts.CPU115.CAL:Function_call_interrupts
      6117 ±  5%      -3.6%       5897 ±  5%  interrupts.CPU116.CAL:Function_call_interrupts
      6118 ±  5%      -3.6%       5896 ±  5%  interrupts.CPU117.CAL:Function_call_interrupts
      6088 ±  5%      -5.7%       5744        interrupts.CPU12.CAL:Function_call_interrupts
      1079 ± 78%     -77.3%     245.50 ±134%  interrupts.CPU120.RES:Rescheduling_interrupts
    949.50 ± 91%     -93.4%      63.00 ± 35%  interrupts.CPU122.RES:Rescheduling_interrupts
      6099 ±  5%      -3.6%       5879 ±  4%  interrupts.CPU13.CAL:Function_call_interrupts
      2647 ± 18%     -82.0%     477.00 ± 33%  interrupts.CPU13.RES:Rescheduling_interrupts
    208.50 ± 51%     -51.3%     101.50 ± 36%  interrupts.CPU14.RES:Rescheduling_interrupts
     53.00 ± 50%    +502.4%     319.25 ± 68%  interrupts.CPU140.RES:Rescheduling_interrupts
     20.00 ± 55%    +392.5%      98.50 ± 35%  interrupts.CPU141.RES:Rescheduling_interrupts
      6093 ±  5%      -4.2%       5838 ±  5%  interrupts.CPU144.CAL:Function_call_interrupts
    206.00 ± 59%     -63.7%      74.75 ± 75%  interrupts.CPU145.RES:Rescheduling_interrupts
      6100 ±  5%      -3.9%       5865 ±  5%  interrupts.CPU15.CAL:Function_call_interrupts
      8.00          +575.0%      54.00 ± 60%  interrupts.CPU152.RES:Rescheduling_interrupts
    969.00 ± 67%     -91.8%      79.25 ± 56%  interrupts.CPU153.RES:Rescheduling_interrupts
    922.00 ± 91%     -74.7%     233.50 ±134%  interrupts.CPU159.RES:Rescheduling_interrupts
      6098 ±  5%      -3.9%       5863 ±  5%  interrupts.CPU16.CAL:Function_call_interrupts
      6097 ±  5%      -4.2%       5841 ±  4%  interrupts.CPU17.CAL:Function_call_interrupts
      1077 ± 89%     -94.5%      58.75 ± 78%  interrupts.CPU176.RES:Rescheduling_interrupts
    710144 ± 12%     -13.5%     614236        interrupts.CPU182.LOC:Local_timer_interrupts
    303.50 ± 78%     -92.6%      22.50 ± 50%  interrupts.CPU186.RES:Rescheduling_interrupts
      6096 ±  5%      -6.4%       5704        interrupts.CPU19.CAL:Function_call_interrupts
    271.00 ± 71%     -86.6%      36.25 ± 81%  interrupts.CPU190.RES:Rescheduling_interrupts
      6109 ±  5%      -3.8%       5875 ±  5%  interrupts.CPU26.CAL:Function_call_interrupts
      6114 ±  5%      -4.1%       5864 ±  5%  interrupts.CPU27.CAL:Function_call_interrupts
      6112 ±  5%      -4.1%       5864 ±  5%  interrupts.CPU28.CAL:Function_call_interrupts
      6085 ±  6%      -3.7%       5859 ±  5%  interrupts.CPU29.CAL:Function_call_interrupts
    780665 ± 20%     -21.3%     614413        interrupts.CPU3.LOC:Local_timer_interrupts
      1969 ± 90%     -88.1%     235.00 ±106%  interrupts.CPU3.RES:Rescheduling_interrupts
      6085 ±  6%      -3.8%       5855 ±  5%  interrupts.CPU30.CAL:Function_call_interrupts
      6079 ±  6%      -3.7%       5853 ±  5%  interrupts.CPU31.CAL:Function_call_interrupts
      6080 ±  6%      -3.8%       5847 ±  5%  interrupts.CPU32.CAL:Function_call_interrupts
      6077 ±  6%      -3.7%       5850 ±  5%  interrupts.CPU33.CAL:Function_call_interrupts
    806.00 ± 11%     -73.2%     216.00 ± 74%  interrupts.CPU35.RES:Rescheduling_interrupts
      1731 ±  3%     -83.6%     283.75 ± 58%  interrupts.CPU37.RES:Rescheduling_interrupts
     45.50 ± 45%   +1009.3%     504.75 ± 86%  interrupts.CPU40.RES:Rescheduling_interrupts
     41.50 ± 20%    +222.3%     133.75 ± 47%  interrupts.CPU44.RES:Rescheduling_interrupts
     86.50 ± 26%    +414.7%     445.25 ± 45%  interrupts.CPU49.RES:Rescheduling_interrupts
    129.50 ± 30%   +1750.4%       2396 ± 94%  interrupts.CPU53.RES:Rescheduling_interrupts
    239.50 ± 51%    +291.6%     938.00 ± 34%  interrupts.CPU56.RES:Rescheduling_interrupts
      6153 ±  5%      -4.4%       5881 ±  5%  interrupts.CPU58.CAL:Function_call_interrupts
     87.00 ±  8%   +1240.2%       1166 ± 58%  interrupts.CPU63.RES:Rescheduling_interrupts
    244.50 ± 29%     -51.7%     118.00 ± 30%  interrupts.CPU69.RES:Rescheduling_interrupts
      1242 ± 64%     -82.3%     220.00 ± 33%  interrupts.CPU75.RES:Rescheduling_interrupts
    173.50 ± 18%     -43.4%      98.25 ± 10%  interrupts.CPU76.RES:Rescheduling_interrupts
      2162 ± 60%     -76.4%     510.50 ±123%  interrupts.CPU77.RES:Rescheduling_interrupts
     74.00 ±  5%    +285.5%     285.25 ± 45%  interrupts.CPU8.RES:Rescheduling_interrupts
    633.00 ± 34%     -56.6%     274.50 ± 97%  interrupts.CPU82.RES:Rescheduling_interrupts
      6229 ±  7%      -5.3%       5898 ±  5%  interrupts.CPU84.CAL:Function_call_interrupts
      6123 ±  5%      -3.6%       5900 ±  5%  interrupts.CPU86.CAL:Function_call_interrupts
    943284 ± 34%     -34.8%     614662        interrupts.CPU86.LOC:Local_timer_interrupts
      6122 ±  5%      -3.6%       5899 ±  5%  interrupts.CPU87.CAL:Function_call_interrupts
      6120 ±  5%      -3.6%       5898 ±  5%  interrupts.CPU88.CAL:Function_call_interrupts
      6118 ±  5%      -3.5%       5902 ±  5%  interrupts.CPU89.CAL:Function_call_interrupts
      1286 ± 83%     -66.7%     428.50 ±118%  interrupts.CPU9.RES:Rescheduling_interrupts
      6114 ±  5%      -3.5%       5900 ±  5%  interrupts.CPU91.CAL:Function_call_interrupts
      6118 ±  5%      -3.4%       5908 ±  5%  interrupts.CPU92.CAL:Function_call_interrupts
      6117 ±  5%      -3.4%       5907 ±  5%  interrupts.CPU93.CAL:Function_call_interrupts
      6118 ±  5%      -3.4%       5907 ±  5%  interrupts.CPU94.CAL:Function_call_interrupts
      6074 ±  5%      -3.8%       5841 ±  5%  interrupts.CPU95.CAL:Function_call_interrupts
      8980 ± 11%      -9.6%       8117 ±  4%  interrupts.CPU95.RES:Rescheduling_interrupts
      6116 ±  5%      -3.8%       5882 ±  5%  interrupts.CPU96.CAL:Function_call_interrupts
      6116 ±  5%      -5.4%       5786 ±  2%  interrupts.CPU97.CAL:Function_call_interrupts
      6115 ±  5%      -3.7%       5890 ±  5%  interrupts.CPU99.CAL:Function_call_interrupts
    846020 ± 26%     -27.6%     612307        interrupts.CPU99.LOC:Local_timer_interrupts
    311.00           -34.5%     203.75 ± 44%  interrupts.TLB:TLB_shootdowns



***************************************************************************************************
lkp-knm02: 272 threads Intel(R) Xeon Phi(TM) CPU 7255 @ 1.10GHz with 112G memory
=========================================================================================
class/compiler/cpufreq_governor/disk/kconfig/nr_threads/rootfs/tbox_group/testcase/testtime:
  cpu/gcc-7/performance/1HDD/x86_64-rhel-7.2/100%/debian-x86_64-2018-04-03.cgz/lkp-knm02/stress-ng/1s

commit: 
  9627026352 ("mm: page_cache_add_speculative(): refactoring")
  cdaa813278 ("mm/gup: track gup-pinned pages")

96270263521248d5 cdaa813278ddc616ee201eacda7 
---------------- --------------------------- 
         %stddev     %change         %stddev
             \          |                \  
     66.75 ±  8%    +260.3%     240.50 ±  3%  stress-ng.numa.ops
     46.23 ±  5%    +401.7%     231.92 ±  3%  stress-ng.numa.ops_per_sec
     44912 ±  3%      +6.8%      47988        stress-ng.time.voluntary_context_switches
     34176 ±  8%     -38.7%      20951 ± 11%  numa-numastat.node1.numa_hit
     34176 ±  8%     -38.7%      20951 ± 11%  numa-numastat.node1.other_node
    162.25 ± 13%     -97.5%       4.00 ±106%  numa-vmstat.node0.nr_isolated_anon
    180.50 ± 13%    -100.0%       0.00        numa-vmstat.node1.nr_isolated_anon
     22.10 ±  5%     -21.7%      17.31 ±  4%  perf-stat.i.MPKI
     14.96            -4.5%      14.28        perf-stat.overall.MPKI
      7.58            +0.1        7.65        perf-stat.overall.branch-miss-rate%
     18.33            +0.4       18.73        perf-stat.overall.cache-miss-rate%
      1831            +2.2%       1871        perf-stat.overall.cycles-between-cache-misses
      1.46 ± 33%      -1.1        0.32 ±103%  perf-profile.calltrace.cycles-pp.serial8250_console_putchar.uart_console_write.serial8250_console_write.console_unlock.vprintk_emit
      1.44 ± 35%      -0.8        0.63 ± 78%  perf-profile.calltrace.cycles-pp.wait_for_xmitr.serial8250_console_putchar.uart_console_write.serial8250_console_write.console_unlock
      1.70 ± 15%      -0.6        1.11 ± 62%  perf-profile.calltrace.cycles-pp.run_rebalance_domains.__softirqentry_text_start.irq_exit.smp_apic_timer_interrupt.apic_timer_interrupt
      0.55 ± 66%      +2.6        3.12 ± 75%  perf-profile.calltrace.cycles-pp.__x64_sys_ioctl.do_syscall_64.entry_SYSCALL_64_after_hwframe.__ioctl.perf_evlist__enable
      0.55 ± 66%      +2.6        3.13 ± 74%  perf-profile.calltrace.cycles-pp.entry_SYSCALL_64_after_hwframe.__ioctl.perf_evlist__enable.cmd_record.run_builtin
      0.55 ± 66%      +2.6        3.13 ± 74%  perf-profile.calltrace.cycles-pp.do_syscall_64.entry_SYSCALL_64_after_hwframe.__ioctl.perf_evlist__enable.cmd_record
      2626 ± 10%     +17.0%       3072 ±  6%  slabinfo.avtab_node.active_objs
      2626 ± 10%     +17.0%       3072 ±  6%  slabinfo.avtab_node.num_objs
     44473            +7.0%      47586 ±  4%  slabinfo.filp.active_objs
     44478            +7.1%      47622 ±  4%  slabinfo.filp.num_objs
    828.75 ±  9%     -14.2%     711.00 ±  4%  slabinfo.skbuff_fclone_cache.active_objs
    828.75 ±  9%     -14.2%     711.00 ±  4%  slabinfo.skbuff_fclone_cache.num_objs
    431.00 ± 30%     -99.0%       4.50 ±101%  proc-vmstat.nr_isolated_anon
     34176 ±  8%     -38.7%      20951 ± 11%  proc-vmstat.numa_other
  23394485 ±  9%     -74.5%    5964109 ± 40%  proc-vmstat.pgalloc_normal
  23265642 ±  9%     -75.0%    5825344 ± 41%  proc-vmstat.pgfree
    592.75 ± 15%    +472.5%       3393 ±  8%  proc-vmstat.pgmigrate_fail
     51229 ±  8%     -86.2%       7061 ± 15%  proc-vmstat.pgmigrate_success
     40681 ± 10%     -83.7%       6633 ± 71%  proc-vmstat.thp_deferred_split_page
    497.44 ±  3%     -16.4%     415.64 ±  4%  sched_debug.cfs_rq:/.exec_clock.stddev
      4.59 ± 20%     -24.7%       3.45 ± 10%  sched_debug.cfs_rq:/.load_avg.avg
    321.12 ± 46%     -63.6%     116.75 ± 20%  sched_debug.cfs_rq:/.load_avg.max
     23.22 ± 35%     -51.5%      11.26 ± 12%  sched_debug.cfs_rq:/.load_avg.stddev
     14.50 ± 22%     +62.9%      23.62 ± 23%  sched_debug.cfs_rq:/.nr_spread_over.max
      1.68 ± 12%     +26.8%       2.13 ± 18%  sched_debug.cfs_rq:/.nr_spread_over.stddev
      1078 ±  5%     +17.5%       1267 ±  9%  sched_debug.cfs_rq:/.util_avg.max
      9496 ± 18%     -15.6%       8019 ±  4%  softirqs.CPU0.RCU
     40692 ±  5%      -9.7%      36753 ±  2%  softirqs.CPU0.TIMER
     40960 ±  5%      -9.7%      36968 ±  5%  softirqs.CPU10.TIMER
     42943 ±  5%      -7.9%      39563 ±  5%  softirqs.CPU114.TIMER
      7967 ± 15%     -14.7%       6795 ±  5%  softirqs.CPU128.RCU
     44489 ±  5%     -13.2%      38635 ±  5%  softirqs.CPU128.TIMER
     43555 ±  7%     -13.6%      37648 ±  5%  softirqs.CPU144.TIMER
      7955 ± 16%     -15.9%       6693 ±  4%  softirqs.CPU145.RCU
     43111 ±  7%     -11.9%      37982 ±  4%  softirqs.CPU160.TIMER
      7755 ± 18%     -14.0%       6667 ±  6%  softirqs.CPU186.RCU
     43744 ±  6%      -7.9%      40296 ±  5%  softirqs.CPU187.TIMER
     41152 ±  7%      -9.2%      37362 ±  4%  softirqs.CPU190.TIMER
     43610 ±  3%     -11.9%      38408 ±  5%  softirqs.CPU198.TIMER
     42378 ±  7%     -11.4%      37538 ±  4%  softirqs.CPU240.TIMER
      8735 ± 18%     -21.6%       6845 ±  8%  softirqs.CPU262.RCU
     37455 ±  4%      -7.7%      34575 ±  3%  softirqs.CPU270.TIMER
      8857 ± 20%     -25.2%       6622 ±  5%  softirqs.CPU271.RCU
     40008 ±  5%      -9.7%      36122 ±  2%  softirqs.CPU32.TIMER
     45805 ± 22%     -17.4%      37825 ±  4%  softirqs.CPU37.TIMER
     40227 ±  4%     -10.2%      36125 ±  4%  softirqs.CPU55.TIMER
     44908 ±  6%     -12.3%      39385 ±  5%  softirqs.CPU64.TIMER
     12303 ±  8%     -24.0%       9348 ± 18%  softirqs.CPU69.RCU
     51650 ±  4%     -17.8%      42473 ±  2%  softirqs.CPU69.TIMER
     44028 ±  6%      -9.6%      39794 ±  3%  softirqs.CPU86.TIMER
      2009 ± 12%     -24.9%       1509 ± 17%  interrupts.CPU0.RES:Rescheduling_interrupts
    956.00 ±136%     -91.7%      79.00 ± 24%  interrupts.CPU10.RES:Rescheduling_interrupts
     58.50 ± 38%    +127.4%     133.00 ± 42%  interrupts.CPU101.RES:Rescheduling_interrupts
     33.25 ± 29%    +226.3%     108.50 ± 94%  interrupts.CPU104.RES:Rescheduling_interrupts
      7122 ±  3%     +10.9%       7897 ±  2%  interrupts.CPU115.CAL:Function_call_interrupts
     56.25 ± 27%     +98.2%     111.50 ± 62%  interrupts.CPU118.RES:Rescheduling_interrupts
    446.25 ± 38%     -48.8%     228.50 ± 18%  interrupts.CPU118.TLB:TLB_shootdowns
      7016 ±  5%     +11.8%       7841        interrupts.CPU124.CAL:Function_call_interrupts
    241.00 ±120%     -77.3%      54.75 ± 23%  interrupts.CPU124.RES:Rescheduling_interrupts
    103.00 ± 41%     -54.6%      46.75 ± 28%  interrupts.CPU125.RES:Rescheduling_interrupts
     37.00 ±  8%    +303.4%     149.25 ± 76%  interrupts.CPU156.RES:Rescheduling_interrupts
     66.25 ± 81%    +108.3%     138.00 ± 64%  interrupts.CPU162.RES:Rescheduling_interrupts
     34.75 ± 25%    +656.1%     262.75 ±116%  interrupts.CPU168.RES:Rescheduling_interrupts
    117.25 ± 20%     -42.9%      67.00 ± 29%  interrupts.CPU193.RES:Rescheduling_interrupts
      8393 ±  3%     +11.5%       9359 ±  4%  interrupts.CPU205.CAL:Function_call_interrupts
     87.75 ± 39%     -44.7%      48.50 ± 28%  interrupts.CPU205.RES:Rescheduling_interrupts
      6863 ±  5%     +12.5%       7720 ±  2%  interrupts.CPU21.CAL:Function_call_interrupts
     47.25 ±  9%     +66.7%      78.75 ± 27%  interrupts.CPU224.RES:Rescheduling_interrupts
     47.50 ± 33%     +81.1%      86.00 ± 29%  interrupts.CPU232.RES:Rescheduling_interrupts
     32.25 ± 14%    +106.2%      66.50 ± 50%  interrupts.CPU241.RES:Rescheduling_interrupts
    328.25 ± 25%    +167.6%     878.50 ± 60%  interrupts.CPU248.TLB:TLB_shootdowns
     36.75 ± 43%    +105.4%      75.50 ± 40%  interrupts.CPU256.RES:Rescheduling_interrupts
    377.75 ± 20%     +29.8%     490.25 ± 15%  interrupts.CPU264.TLB:TLB_shootdowns
     73.50 ± 45%    +204.8%     224.00 ± 61%  interrupts.CPU28.RES:Rescheduling_interrupts
     79.25 ± 37%     +76.3%     139.75 ± 35%  interrupts.CPU32.RES:Rescheduling_interrupts
      6892 ±  6%     +14.9%       7919 ±  3%  interrupts.CPU37.CAL:Function_call_interrupts
      6892 ±  4%     +16.9%       8055 ±  8%  interrupts.CPU39.CAL:Function_call_interrupts
     51.75 ± 15%     +68.1%      87.00 ± 34%  interrupts.CPU39.RES:Rescheduling_interrupts
    476.00 ± 17%    +102.9%     966.00 ± 31%  interrupts.CPU40.TLB:TLB_shootdowns
      6847 ±  5%     +12.6%       7711 ±  2%  interrupts.CPU41.CAL:Function_call_interrupts
      6853 ±  4%     +10.9%       7603 ±  3%  interrupts.CPU48.CAL:Function_call_interrupts
    522.50 ± 27%     -48.1%     271.00 ± 74%  interrupts.CPU54.TLB:TLB_shootdowns
    454.25 ± 29%     +85.5%     842.75 ± 49%  interrupts.CPU60.TLB:TLB_shootdowns
    300.00 ± 32%    +148.1%     744.25 ± 55%  interrupts.CPU61.TLB:TLB_shootdowns
     52.75 ± 23%    +130.3%     121.50 ± 50%  interrupts.CPU64.RES:Rescheduling_interrupts
     52.00 ± 22%    +122.6%     115.75 ± 62%  interrupts.CPU70.RES:Rescheduling_interrupts
      6972 ±  5%      +8.9%       7595 ±  5%  interrupts.CPU77.CAL:Function_call_interrupts
      6923 ±  4%     +10.5%       7650 ±  2%  interrupts.CPU8.CAL:Function_call_interrupts
      7233 ±  5%     +11.3%       8049 ±  2%  interrupts.CPU81.CAL:Function_call_interrupts
    585.25 ± 10%     -37.6%     365.00 ± 27%  interrupts.CPU88.TLB:TLB_shootdowns



***************************************************************************************************
lkp-knm02: 272 threads Intel(R) Xeon Phi(TM) CPU 7255 @ 1.10GHz with 112G memory
=========================================================================================
class/compiler/cpufreq_governor/disk/kconfig/nr_threads/rootfs/tbox_group/testcase/testtime:
  pipe/gcc-7/performance/1HDD/x86_64-rhel-7.2/100%/debian-x86_64-2018-04-03.cgz/lkp-knm02/stress-ng/1s

commit: 
  9627026352 ("mm: page_cache_add_speculative(): refactoring")
  cdaa813278 ("mm/gup: track gup-pinned pages")

96270263521248d5 cdaa813278ddc616ee201eacda7 
---------------- --------------------------- 
       fail:runs  %reproduction    fail:runs
           |             |             |    
           :4           25%           1:4     kmsg.DHCP/BOOTP:Reply_not_for_us_on_eth#,op[#]xid[#]
           :4           25%           1:4     dmesg.RIP:get_gup_pin_page
          1:4          -25%            :4     dmesg.WARNING:at#for_ip_swapgs_restore_regs_and_return_to_usermode/0x
           :4           25%           1:4     dmesg.WARNING:at_mm/gup.c:#get_gup_pin_page
          1:4          -25%            :4     dmesg.WARNING:stack_recursion
         %stddev     %change         %stddev
             \          |                \  
     18012           -10.5%      16117 ±  8%  stress-ng.time.percent_of_cpu_this_job_got
      1592            -4.9%       1513        stress-ng.time.system_time
   3995345           -47.5%    2099227        stress-ng.vm-splice.ops
   4001986           -18.5%    3259638 ±  7%  stress-ng.vm-splice.ops_per_sec
      0.24 ±173%      +1.3        1.53 ± 44%  perf-profile.calltrace.cycles-pp.cpu_load_update.scheduler_tick.update_process_times.tick_sched_handle.tick_sched_timer
    185055 ± 59%     +38.4%     256144 ± 49%  meminfo.Active
    184967 ± 59%     +38.4%     256057 ± 49%  meminfo.Active(anon)
    185946 ± 58%     +40.8%     261876 ± 50%  numa-meminfo.node0.Active
    185858 ± 58%     +40.9%     261789 ± 50%  numa-meminfo.node0.Active(anon)
     17098 ±  6%     -11.5%      15128 ±  3%  numa-meminfo.node1.SUnreclaim
     47648 ± 62%     +42.2%      67747 ± 51%  numa-vmstat.node0.nr_active_anon
     47622 ± 62%     +42.2%      67725 ± 51%  numa-vmstat.node0.nr_zone_active_anon
      4274 ±  6%     -11.5%       3782 ±  3%  numa-vmstat.node1.nr_slab_unreclaimable
     24880            +0.9%      25102        proc-vmstat.nr_slab_reclaimable
  18690590            +1.3%   18925901        proc-vmstat.numa_hit
  18690590            +1.3%   18925901        proc-vmstat.numa_local
     10842 ±  3%      +7.3%      11637 ±  5%  softirqs.CPU13.TIMER
     14451 ± 26%     -26.5%      10615 ±  5%  softirqs.CPU18.TIMER
     10649 ±  5%     +15.8%      12333 ± 10%  softirqs.CPU56.TIMER
      3.37 ±  7%     -44.3%       1.88 ± 33%  sched_debug.cfs_rq:/.exec_clock.avg
     22.72 ±  6%     -29.9%      15.92 ± 26%  sched_debug.cfs_rq:/.exec_clock.stddev
      5.80 ± 34%     -40.9%       3.43 ± 11%  sched_debug.cfs_rq:/.load_avg.avg
      1020           -51.2%     498.00 ±  6%  sched_debug.cfs_rq:/.util_est_enqueued.max
     78.11 ± 12%     -33.3%      52.06 ± 21%  sched_debug.cfs_rq:/.util_est_enqueued.stddev
      7243 ± 12%     +79.0%      12964 ± 17%  sched_debug.cpu.avg_idle.min
      2420 ± 18%     -19.7%       1943        perf-stat.i.cycles-between-cache-misses
    137.18 ±  5%     +16.2%     159.47 ±  6%  perf-stat.i.instructions-per-iTLB-miss
      1969 ±  4%      -7.2%       1827 ±  2%  perf-stat.overall.cycles-between-cache-misses
      0.90 ±  3%      -0.0        0.85        perf-stat.overall.iTLB-load-miss-rate%
    111.89 ±  2%      +4.8%     117.28        perf-stat.overall.instructions-per-iTLB-miss
 1.822e+11           -12.8%  1.589e+11 ± 11%  perf-stat.ps.cpu-cycles
     10509 ±  3%     -12.6%       9183 ± 10%  perf-stat.ps.minor-faults
    457963 ±  2%     -12.0%     402874 ± 11%  perf-stat.ps.msec
     10647 ±  4%     -13.0%       9267 ± 10%  perf-stat.ps.page-faults
      1840 ± 34%     -35.6%       1184 ± 19%  interrupts.CPU12.RES:Rescheduling_interrupts
    792.50 ±  7%     +33.7%       1059 ± 17%  interrupts.CPU126.RES:Rescheduling_interrupts
    743.00 ± 50%    +119.2%       1628 ± 20%  interrupts.CPU154.RES:Rescheduling_interrupts
      1490 ±  9%     -37.5%     931.50 ± 21%  interrupts.CPU16.RES:Rescheduling_interrupts
    880.50 ± 30%     +70.6%       1502 ± 10%  interrupts.CPU194.RES:Rescheduling_interrupts
    931.00 ± 23%     +49.5%       1391 ± 18%  interrupts.CPU216.RES:Rescheduling_interrupts
      1158 ± 11%     -31.0%     798.75 ± 30%  interrupts.CPU236.RES:Rescheduling_interrupts
      1253 ± 21%     -32.7%     843.00 ± 31%  interrupts.CPU241.RES:Rescheduling_interrupts
      1700 ± 37%     -58.2%     710.00 ± 48%  interrupts.CPU243.RES:Rescheduling_interrupts
      1399 ± 20%     -40.4%     834.25 ± 35%  interrupts.CPU255.RES:Rescheduling_interrupts
      1064 ± 19%     +32.0%       1405 ±  7%  interrupts.CPU256.RES:Rescheduling_interrupts
    996.75 ± 24%     +32.0%       1316 ± 11%  interrupts.CPU262.RES:Rescheduling_interrupts
      1129 ± 22%     +46.2%       1652 ± 16%  interrupts.CPU267.RES:Rescheduling_interrupts
      1553 ± 19%     -34.4%       1019 ± 25%  interrupts.CPU39.RES:Rescheduling_interrupts
      1110 ±  5%     +25.3%       1390 ± 14%  interrupts.CPU40.RES:Rescheduling_interrupts
      1073 ± 18%     +45.5%       1562 ±  4%  interrupts.CPU41.RES:Rescheduling_interrupts
      1478 ± 20%     -35.3%     956.50 ± 22%  interrupts.CPU47.RES:Rescheduling_interrupts
      1554 ±  7%     -29.6%       1094 ± 24%  interrupts.CPU54.RES:Rescheduling_interrupts
      1613 ± 18%     -37.6%       1007 ± 38%  interrupts.CPU57.RES:Rescheduling_interrupts
    946.25 ± 15%     +45.7%       1379 ± 10%  interrupts.CPU64.RES:Rescheduling_interrupts
    780.00 ± 31%     +81.5%       1415 ± 12%  interrupts.CPU84.RES:Rescheduling_interrupts



***************************************************************************************************
lkp-bdw-ep3b: 88 threads Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz with 64G memory
=========================================================================================
compiler/cpufreq_governor/kconfig/mode/nr_task/rootfs/tbox_group/test/testcase/ucode:
  gcc-7/performance/x86_64-rhel-7.2/process/100%/debian-x86_64-2018-04-03.cgz/lkp-bdw-ep3b/futex2/will-it-scale/0xb00002e

commit: 
  9627026352 ("mm: page_cache_add_speculative(): refactoring")
  cdaa813278 ("mm/gup: track gup-pinned pages")

96270263521248d5 cdaa813278ddc616ee201eacda7 
---------------- --------------------------- 
         %stddev     %change         %stddev
             \          |                \  
     26674 ± 17%     -22.3%      20716 ±  3%  softirqs.CPU30.RCU
     26755 ± 20%     -21.3%      21064 ±  3%  softirqs.CPU59.RCU
    295164           +11.4%     328898        meminfo.Active
    294996           +11.4%     328730        meminfo.Active(anon)
    295368           -25.0%     221640 ± 14%  meminfo.DirectMap4k
     24.48            +0.2       24.66        perf-profile.calltrace.cycles-pp.get_futex_key.futex_wait_setup.futex_wait.do_futex.__x64_sys_futex
     14.88            +0.2       15.09        perf-profile.calltrace.cycles-pp.gup_pgd_range.get_user_pages_fast.get_futex_key.futex_wait_setup.futex_wait
     50.45            +0.2       50.67        perf-profile.calltrace.cycles-pp.do_futex.__x64_sys_futex.do_syscall_64.entry_SYSCALL_64_after_hwframe
     73752           +11.4%      82177        proc-vmstat.nr_active_anon
     73752           +11.4%      82177        proc-vmstat.nr_zone_active_anon
    710645            -2.3%     694065        proc-vmstat.pgfree
 2.108e+08 ± 15%     -53.8%   97334654 ± 18%  cpuidle.C6.time
    262362 ±  3%     -54.2%     120108 ± 14%  cpuidle.C6.usage
     27692 ± 77%     -79.8%       5606 ± 27%  cpuidle.POLL.time
      4498 ± 40%     -44.2%       2509 ±  8%  cpuidle.POLL.usage
    362291           -41.5%     211769 ± 18%  numa-numastat.node0.local_node
    379384           -42.7%     217528 ± 19%  numa-numastat.node0.numa_hit
     17093           -66.3%       5760 ±120%  numa-numastat.node0.other_node
    289553           +50.8%     436751 ±  9%  numa-numastat.node1.local_node
    289591           +54.7%     448130 ±  9%  numa-numastat.node1.numa_hit
    250685 ±  3%     -56.5%     108986 ± 17%  turbostat.C6
      0.77 ± 16%      -0.4        0.34 ± 20%  turbostat.C6%
      0.55 ± 24%     -58.3%       0.23 ± 32%  turbostat.CPU%c6
      0.35 ± 23%     -54.2%       0.16 ± 55%  turbostat.Pkg%pc2
      0.03 ± 66%     -91.7%       0.00 ±173%  turbostat.Pkg%pc6
     34.58 ± 11%     +30.4%      45.08 ±  4%  sched_debug.cfs_rq:/.nr_spread_over.max
      3.94 ±  7%     +25.1%       4.92 ±  5%  sched_debug.cfs_rq:/.nr_spread_over.stddev
      2.39 ±  2%    +183.0%       6.78 ±106%  sched_debug.cpu.cpu_load[0].stddev
     24.58          +107.3%      50.96 ± 62%  sched_debug.cpu.cpu_load[1].max
      2.26 ±  6%    +118.1%       4.94 ± 64%  sched_debug.cpu.cpu_load[1].stddev
     25212 ± 22%     -25.8%      18696 ± 27%  sched_debug.cpu.sched_count.max
    125453           -33.3%      83670 ± 19%  numa-meminfo.node0.AnonHugePages
    168582           -21.2%     132815 ± 14%  numa-meminfo.node0.AnonPages
    124539           +18.2%     147258 ±  4%  numa-meminfo.node1.Active
    124539           +18.2%     147216 ±  4%  numa-meminfo.node1.Active(anon)
     43851 ±  4%     +99.6%      87509 ± 18%  numa-meminfo.node1.AnonHugePages
     75101 ±  2%     +48.9%     111789 ± 16%  numa-meminfo.node1.AnonPages
      2816 ±  2%     +22.4%       3447 ± 17%  numa-meminfo.node1.PageTables
     54950           +11.2%      61121 ±  7%  numa-meminfo.node1.SUnreclaim
     42139           -21.2%      33199 ± 14%  numa-vmstat.node0.nr_anon_pages
    711043           -19.2%     574713 ± 14%  numa-vmstat.node0.numa_hit
    693926           -18.0%     568865 ± 13%  numa-vmstat.node0.numa_local
     17117           -65.8%       5847 ±117%  numa-vmstat.node0.numa_other
     31111           +18.3%      36809 ±  4%  numa-vmstat.node1.nr_active_anon
     18777 ±  2%     +48.8%      27945 ± 16%  numa-vmstat.node1.nr_anon_pages
    699.50 ±  3%     +22.0%     853.50 ± 16%  numa-vmstat.node1.nr_page_table_pages
     13737           +11.2%      15279 ±  7%  numa-vmstat.node1.nr_slab_unreclaimable
     31111           +18.3%      36809 ±  4%  numa-vmstat.node1.nr_zone_active_anon
    426549           +32.8%     566367 ± 15%  numa-vmstat.node1.numa_hit
    288820           +44.7%     417867 ± 20%  numa-vmstat.node1.numa_local
      0.00            -0.0        0.00 ±  2%  perf-stat.i.dTLB-load-miss-rate%
    195436            -4.1%     187470 ±  3%  perf-stat.i.dTLB-load-misses
     67.36            -0.7       66.69        perf-stat.i.iTLB-load-miss-rate%
  1.66e+08            +2.8%  1.707e+08        perf-stat.i.iTLB-loads
     51056            -8.1%      46912 ±  2%  perf-stat.i.node-load-misses
      7153           -30.0%       5006 ± 21%  perf-stat.i.node-loads
      0.00            -0.0        0.00 ±  3%  perf-stat.overall.dTLB-load-miss-rate%
     67.37            -0.7       66.69        perf-stat.overall.iTLB-load-miss-rate%
    194906            -4.1%     186955 ±  3%  perf-stat.ps.dTLB-load-misses
 1.655e+08            +2.8%  1.701e+08        perf-stat.ps.iTLB-loads
     50904            -8.1%      46767 ±  2%  perf-stat.ps.node-load-misses
      7136           -30.0%       4996 ± 21%  perf-stat.ps.node-loads
    352.50 ± 10%     +32.5%     467.00 ± 14%  interrupts.32:PCI-MSI.3145729-edge.eth0-TxRx-0
    222.00 ± 16%     +84.0%     408.50 ± 27%  interrupts.34:PCI-MSI.3145731-edge.eth0-TxRx-2
    275.00 ± 12%     -25.7%     204.25 ± 17%  interrupts.37:PCI-MSI.3145734-edge.eth0-TxRx-5
    352.50 ± 10%     +32.5%     467.00 ± 14%  interrupts.CPU11.32:PCI-MSI.3145729-edge.eth0-TxRx-0
    651.50 ± 59%     -76.4%     154.00 ± 59%  interrupts.CPU11.RES:Rescheduling_interrupts
    222.00 ± 16%     +84.0%     408.50 ± 27%  interrupts.CPU13.34:PCI-MSI.3145731-edge.eth0-TxRx-2
      1011 ±  2%     -82.7%     175.25 ± 50%  interrupts.CPU13.RES:Rescheduling_interrupts
      1680 ± 26%     -64.1%     602.75 ± 85%  interrupts.CPU14.RES:Rescheduling_interrupts
    472.50 ± 53%     -54.1%     217.00 ± 95%  interrupts.CPU15.RES:Rescheduling_interrupts
    275.00 ± 12%     -25.7%     204.25 ± 17%  interrupts.CPU16.37:PCI-MSI.3145734-edge.eth0-TxRx-5
    635.00 ± 62%     -54.5%     289.00 ±113%  interrupts.CPU17.RES:Rescheduling_interrupts
    903.00 ± 12%     -60.4%     357.50 ± 82%  interrupts.CPU18.RES:Rescheduling_interrupts
    109.00 ± 30%    +627.1%     792.50 ± 99%  interrupts.CPU24.RES:Rescheduling_interrupts
    146.00 ±  8%    +365.9%     680.25 ± 62%  interrupts.CPU28.RES:Rescheduling_interrupts
      1609 ± 53%     -79.9%     323.50 ± 83%  interrupts.CPU3.RES:Rescheduling_interrupts
    125.50 ± 25%   +1227.3%       1665 ± 59%  interrupts.CPU30.RES:Rescheduling_interrupts
    381.00 ± 48%    +240.0%       1295 ± 33%  interrupts.CPU31.RES:Rescheduling_interrupts
    127.50 ± 29%   +1944.3%       2606 ± 69%  interrupts.CPU36.RES:Rescheduling_interrupts
    132.00 ± 22%    +141.3%     318.50 ± 23%  interrupts.CPU40.RES:Rescheduling_interrupts
    255.50 ± 69%    +377.2%       1219 ± 71%  interrupts.CPU42.RES:Rescheduling_interrupts
    965.00 ± 90%     -93.8%      60.00 ± 93%  interrupts.CPU45.RES:Rescheduling_interrupts
    945.50 ± 96%     -97.6%      22.75 ± 54%  interrupts.CPU49.RES:Rescheduling_interrupts
    231.50 ± 85%     -88.1%      27.50 ± 89%  interrupts.CPU50.RES:Rescheduling_interrupts
    345.50 ± 91%     -95.0%      17.25 ± 70%  interrupts.CPU57.RES:Rescheduling_interrupts
     71.50 ± 44%     -47.6%      37.50 ± 88%  interrupts.CPU59.RES:Rescheduling_interrupts
      7877           -37.5%       4926 ± 34%  interrupts.CPU6.NMI:Non-maskable_interrupts
      7877           -37.5%       4926 ± 34%  interrupts.CPU6.PMI:Performance_monitoring_interrupts
      1167 ± 44%     -88.0%     139.75 ± 60%  interrupts.CPU6.RES:Rescheduling_interrupts
    331.50 ± 91%     -94.7%      17.50 ± 62%  interrupts.CPU61.RES:Rescheduling_interrupts
    136.50 ±  4%     -81.7%      25.00 ± 57%  interrupts.CPU64.RES:Rescheduling_interrupts
      7897           -37.8%       4913 ± 34%  interrupts.CPU7.NMI:Non-maskable_interrupts
      7897           -37.8%       4913 ± 34%  interrupts.CPU7.PMI:Performance_monitoring_interrupts
      1356 ± 18%     -65.8%     463.75 ±  6%  interrupts.CPU7.RES:Rescheduling_interrupts
     27.50 ±  5%    +335.5%     119.75 ±101%  interrupts.CPU73.RES:Rescheduling_interrupts
    203.00 ± 13%     -80.3%      40.00 ± 31%  interrupts.CPU75.RES:Rescheduling_interrupts
      7885           -37.4%       4934 ± 34%  interrupts.CPU8.NMI:Non-maskable_interrupts
      7885           -37.4%       4934 ± 34%  interrupts.CPU8.PMI:Performance_monitoring_interrupts
      1232 ± 51%     -80.8%     236.50 ± 85%  interrupts.CPU8.RES:Rescheduling_interrupts
    295.00 ± 61%     -58.7%     121.75 ± 65%  interrupts.CPU87.RES:Rescheduling_interrupts



***************************************************************************************************
lkp-knm02: 272 threads Intel(R) Xeon Phi(TM) CPU 7255 @ 1.10GHz with 112G memory
=========================================================================================
class/compiler/cpufreq_governor/disk/kconfig/nr_threads/rootfs/tbox_group/testcase/testtime:
  os/gcc-7/performance/1HDD/x86_64-rhel-7.2/100%/debian-x86_64-2018-04-03.cgz/lkp-knm02/stress-ng/1s

commit: 
  9627026352 ("mm: page_cache_add_speculative(): refactoring")
  cdaa813278 ("mm/gup: track gup-pinned pages")

96270263521248d5 cdaa813278ddc616ee201eacda7 
---------------- --------------------------- 
       fail:runs  %reproduction    fail:runs
           |             |             |    
          7:4           58%          10:4     perf-profile.calltrace.cycles-pp.native_queued_spin_lock_slowpath._raw_spin_lock.key_lookup.lookup_user_key.keyctl_set_timeout
           :4           50%           2:4     dmesg.RIP:get_gup_pin_page
           :4           50%           2:4     dmesg.WARNING:at_mm/gup.c:#get_gup_pin_page
           :4          100%           4:4     kmsg.Memory_failure:#:dirty_LRU_page_still_referenced_by#users
           :4          100%           4:4     kmsg.Memory_failure:#:recovery_action_for_dirty_LRU_page:Failed
          4:4         -100%            :4     kmsg.Memory_failure:#:recovery_action_for_dirty_LRU_page:Recovered
         %stddev     %change         %stddev
             \          |                \  
    291197           -55.0%     131136 ± 11%  stress-ng.futex.ops
    290079           -58.0%     121851 ± 12%  stress-ng.futex.ops_per_sec
      2015 ± 80%    +203.6%       6119 ± 61%  stress-ng.io.ops_per_sec
    122468 ±  2%     +22.4%     149941 ±  2%  stress-ng.mlock.ops_per_sec
     65.00 ±  6%    +251.2%     228.25 ±  5%  stress-ng.numa.ops
     45.61 ±  5%    +383.3%     220.41 ±  5%  stress-ng.numa.ops_per_sec
    625254 ±  6%     -23.1%     480881 ± 10%  stress-ng.sem.ops
    624395 ±  6%     -23.1%     480000 ± 10%  stress-ng.sem.ops_per_sec
  14903791            -2.6%   14517111        stress-ng.time.voluntary_context_switches
    306260 ±  4%      -8.3%     280934 ±  5%  stress-ng.userfaultfd.ops
    306179 ±  4%      -8.2%     280922 ±  5%  stress-ng.userfaultfd.ops_per_sec
   4157856           -49.5%    2098955        stress-ng.vm-splice.ops
   4161453           -13.4%    3603810        stress-ng.vm-splice.ops_per_sec
  1.53e+08 ±  2%      +3.1%  1.578e+08        perf-stat.ps.iTLB-load-misses
   4293169 ± 66%     -44.9%    2363760 ±  2%  cpuidle.POLL.time
     81481 ± 48%     -34.3%      53539 ±  2%  cpuidle.POLL.usage
     33283 ±  6%     -59.2%      13575 ± 11%  numa-numastat.node1.numa_hit
     33283 ±  6%     -59.2%      13575 ± 11%  numa-numastat.node1.other_node
    564127 ±  4%    +185.9%    1612672 ± 19%  meminfo.Active
    563846 ±  4%    +185.9%    1612232 ± 19%  meminfo.Active(anon)
    485.00 ± 22%    +118.9%       1061 ±  7%  meminfo.Inactive(file)
   4144644           +26.3%    5236228 ±  6%  meminfo.Memused
    510156 ±  3%    +205.4%    1558069 ± 20%  numa-meminfo.node0.Active
    509874 ±  3%    +205.5%    1557628 ± 20%  numa-meminfo.node0.Active(anon)
    474.50 ± 21%    +123.8%       1061 ±  9%  numa-meminfo.node0.Inactive(file)
   3534355           +30.6%    4617529 ±  7%  numa-meminfo.node0.MemUsed
    123321 ±  4%    +218.3%     392482 ± 20%  numa-vmstat.node0.nr_active_anon
     70.00 ± 19%     +58.9%     111.25 ±  3%  numa-vmstat.node0.nr_active_file
    119.00 ± 21%    +124.2%     266.75 ±  8%  numa-vmstat.node0.nr_inactive_file
    123242 ±  4%    +218.4%     392451 ± 20%  numa-vmstat.node0.nr_zone_active_anon
     70.00 ± 19%     +58.9%     111.25 ±  3%  numa-vmstat.node0.nr_zone_active_file
    119.00 ± 21%    +124.2%     266.75 ±  8%  numa-vmstat.node0.nr_zone_inactive_file
      3053 ±  6%     -14.4%       2615 ± 12%  sched_debug.cfs_rq:/.exec_clock.stddev
      1.46 ±  6%     -15.1%       1.24 ±  5%  sched_debug.cfs_rq:/.nr_running.max
    585.54 ± 15%     -35.4%     378.27 ± 19%  sched_debug.cfs_rq:/.runnable_load_avg.max
    567.38 ± 15%     -37.7%     353.29 ± 11%  sched_debug.cpu.cpu_load[0].max
     93234 ± 21%     -24.0%      70869 ± 10%  sched_debug.cpu.curr->pid.avg
    185032 ±  4%     -13.7%     159654 ± 10%  sched_debug.cpu.curr->pid.max
     23033 ±  9%      -9.2%      20906 ±  6%  sched_debug.cpu.sched_goidle.max
      2420 ±  6%     -13.9%       2085 ±  4%  sched_debug.cpu.sched_goidle.stddev
     38.68 ± 40%     -60.9%      15.14 ± 30%  sched_debug.rt_rq:/.rt_time.max
      7.03 ± 67%     -61.5%       2.71 ± 40%  sched_debug.rt_rq:/.rt_time.stddev
    134783 ±  5%    +190.2%     391176 ± 17%  proc-vmstat.nr_active_anon
     70.25 ± 17%     +58.4%     111.25 ±  4%  proc-vmstat.nr_active_file
    121.75 ± 20%    +117.9%     265.25 ±  7%  proc-vmstat.nr_inactive_file
    131.00 ± 23%     -99.8%       0.25 ±173%  proc-vmstat.nr_isolated_anon
    105352            -2.8%     102442        proc-vmstat.nr_slab_reclaimable
    134783 ±  5%    +190.2%     391176 ± 17%  proc-vmstat.nr_zone_active_anon
     70.25 ± 17%     +58.4%     111.25 ±  4%  proc-vmstat.nr_zone_active_file
    121.75 ± 20%    +117.9%     265.25 ±  7%  proc-vmstat.nr_zone_inactive_file
    864.50 ± 25%    +638.5%       6384 ± 83%  proc-vmstat.numa_huge_pte_updates
     33283 ±  6%     -59.2%      13575 ± 11%  proc-vmstat.numa_other
    445254 ± 25%    +634.9%    3272027 ± 83%  proc-vmstat.numa_pte_updates
    466.00 ± 12%    +382.9%       2250 ±  9%  proc-vmstat.pgmigrate_fail
     49887 ±  6%     -92.6%       3698 ± 33%  proc-vmstat.pgmigrate_success
   7822768            -1.3%    7721955        proc-vmstat.unevictable_pgs_culled
    352423 ±  2%      +4.2%     367091        proc-vmstat.unevictable_pgs_mlocked
    351801 ±  2%      +4.1%     366356        proc-vmstat.unevictable_pgs_munlocked
    351393 ±  2%      +4.1%     365940        proc-vmstat.unevictable_pgs_rescued
     11075 ±  8%     -16.5%       9245 ±  9%  softirqs.CPU100.NET_RX
      8323 ±  9%     +47.3%      12259 ± 23%  softirqs.CPU111.NET_RX
     10330 ± 11%     -17.8%       8494 ±  5%  softirqs.CPU120.NET_RX
     28219 ±  4%     -13.9%      24292 ±  3%  softirqs.CPU123.RCU
     19316 ±  6%      -8.9%      17600 ±  4%  softirqs.CPU127.SCHED
     11518 ±  2%     -26.4%       8477 ±  9%  softirqs.CPU128.NET_RX
      6724 ± 22%     +67.4%      11258 ± 24%  softirqs.CPU131.NET_RX
      8571 ± 33%     +62.2%      13903 ± 24%  softirqs.CPU138.NET_RX
      7441 ±  4%     +33.9%       9965 ± 14%  softirqs.CPU141.NET_RX
      8270 ± 16%     +44.7%      11966 ± 15%  softirqs.CPU146.NET_RX
     11298 ± 20%     -36.7%       7155 ± 18%  softirqs.CPU148.NET_RX
      8935 ± 23%     +33.2%      11900 ± 29%  softirqs.CPU153.NET_RX
     19787 ±  5%      -9.6%      17897 ±  3%  softirqs.CPU163.SCHED
     26941 ±  5%      -9.5%      24385 ±  3%  softirqs.CPU169.RCU
     12370 ± 25%     -34.7%       8074 ± 13%  softirqs.CPU177.NET_RX
     20748 ±  6%     -10.9%      18487 ±  4%  softirqs.CPU181.SCHED
     20707 ±  9%     -16.1%      17369 ±  2%  softirqs.CPU186.SCHED
     19622 ±  6%     -10.7%      17522 ±  3%  softirqs.CPU187.SCHED
     19406 ±  6%      -8.9%      17672 ±  2%  softirqs.CPU194.SCHED
     32272 ±  8%     -14.2%      27679 ±  7%  softirqs.CPU20.RCU
     12603 ± 21%     -29.4%       8893 ± 16%  softirqs.CPU209.NET_RX
     11432 ±  9%     -14.7%       9749 ± 14%  softirqs.CPU21.NET_RX
      9075 ±  9%     -19.4%       7310 ±  7%  softirqs.CPU214.NET_RX
      8118 ±  9%     +55.0%      12584 ± 24%  softirqs.CPU240.NET_RX
      9232 ± 16%     -27.3%       6708 ±  9%  softirqs.CPU244.NET_RX
      8203 ± 15%     +32.8%      10895 ±  7%  softirqs.CPU265.NET_RX
     14174 ±  8%     -31.4%       9727 ± 23%  softirqs.CPU267.NET_RX
     17401 ± 11%     -55.9%       7675 ± 21%  softirqs.CPU28.NET_RX
     30370 ±  4%     -12.7%      26507 ±  3%  softirqs.CPU3.RCU
     11791 ±  4%     -34.4%       7732 ± 13%  softirqs.CPU46.NET_RX
     19641 ±  7%     -10.5%      17574 ±  4%  softirqs.CPU51.SCHED
      9879 ± 18%     +21.5%      12003 ± 13%  softirqs.CPU53.NET_RX
      9572 ±  7%      -8.3%       8781 ±  6%  softirqs.CPU58.NET_RX
     11786 ± 12%     -33.7%       7818 ±  4%  softirqs.CPU6.NET_RX
     19919 ±  8%     -12.9%      17341 ±  4%  softirqs.CPU69.SCHED
      8365 ± 15%     +64.2%      13734 ± 35%  softirqs.CPU76.NET_RX
      7648 ± 11%     +38.0%      10557 ± 17%  softirqs.CPU77.NET_RX
      9286 ± 15%     +44.2%      13394 ± 16%  softirqs.CPU88.NET_RX
     27697 ±  4%     -11.6%      24482 ±  3%  softirqs.CPU90.RCU
      8763 ± 16%     +34.9%      11818 ± 22%  softirqs.CPU94.NET_RX
      2680 ± 15%     -51.8%       1293 ± 28%  interrupts.CPU100.NMI:Non-maskable_interrupts
      2680 ± 15%     -51.8%       1293 ± 28%  interrupts.CPU100.PMI:Performance_monitoring_interrupts
      2219 ± 20%     -30.4%       1545 ± 22%  interrupts.CPU104.NMI:Non-maskable_interrupts
      2219 ± 20%     -30.4%       1545 ± 22%  interrupts.CPU104.PMI:Performance_monitoring_interrupts
      2314 ± 19%     -31.7%       1580 ± 10%  interrupts.CPU106.TLB:TLB_shootdowns
      2699 ± 18%     -30.8%       1868 ± 10%  interrupts.CPU108.TLB:TLB_shootdowns
     17763 ± 25%     +63.0%      28961 ± 13%  interrupts.CPU113.RES:Rescheduling_interrupts
     16871 ± 22%     +88.1%      31734 ± 27%  interrupts.CPU125.RES:Rescheduling_interrupts
     24894 ± 18%     +27.6%      31769 ±  8%  interrupts.CPU128.RES:Rescheduling_interrupts
      1755 ± 23%     +77.4%       3112 ± 57%  interrupts.CPU130.TLB:TLB_shootdowns
      2644 ± 31%     -35.0%       1719 ± 20%  interrupts.CPU142.TLB:TLB_shootdowns
      1164 ± 14%     +64.3%       1912 ± 46%  interrupts.CPU145.NMI:Non-maskable_interrupts
      1164 ± 14%     +64.3%       1912 ± 46%  interrupts.CPU145.PMI:Performance_monitoring_interrupts
     23656 ± 38%     +53.7%      36365 ± 30%  interrupts.CPU150.RES:Rescheduling_interrupts
     27724 ±  6%     -30.2%      19354 ± 16%  interrupts.CPU151.RES:Rescheduling_interrupts
      2491 ± 23%     -29.6%       1754 ± 18%  interrupts.CPU155.TLB:TLB_shootdowns
      2153 ± 17%     +16.1%       2499 ± 16%  interrupts.CPU167.TLB:TLB_shootdowns
      2170 ± 18%     -20.0%       1735 ± 11%  interrupts.CPU169.TLB:TLB_shootdowns
      2004 ± 30%     -33.3%       1337 ± 17%  interrupts.CPU170.NMI:Non-maskable_interrupts
      2004 ± 30%     -33.3%       1337 ± 17%  interrupts.CPU170.PMI:Performance_monitoring_interrupts
      2079 ± 20%     -25.1%       1557 ±  8%  interrupts.CPU171.TLB:TLB_shootdowns
      1754 ± 10%     +44.1%       2527 ± 17%  interrupts.CPU187.TLB:TLB_shootdowns
      1632 ± 12%     +45.6%       2376 ± 21%  interrupts.CPU191.TLB:TLB_shootdowns
      3271 ± 49%     -50.5%       1618 ± 49%  interrupts.CPU199.NMI:Non-maskable_interrupts
      3271 ± 49%     -50.5%       1618 ± 49%  interrupts.CPU199.PMI:Performance_monitoring_interrupts
      3481 ± 41%     -52.1%       1668 ± 33%  interrupts.CPU200.NMI:Non-maskable_interrupts
      3481 ± 41%     -52.1%       1668 ± 33%  interrupts.CPU200.PMI:Performance_monitoring_interrupts
     20086 ± 22%     +84.1%      36982 ±  5%  interrupts.CPU212.RES:Rescheduling_interrupts
      1738 ± 12%     +17.8%       2048 ±  5%  interrupts.CPU212.TLB:TLB_shootdowns
     18973 ± 23%     +51.8%      28802 ± 19%  interrupts.CPU216.RES:Rescheduling_interrupts
      2301 ± 28%     -51.6%       1113 ± 41%  interrupts.CPU218.NMI:Non-maskable_interrupts
      2301 ± 28%     -51.6%       1113 ± 41%  interrupts.CPU218.PMI:Performance_monitoring_interrupts
      2267 ± 10%     -16.8%       1887 ± 15%  interrupts.CPU220.TLB:TLB_shootdowns
     15399 ± 14%     +61.3%      24836 ±  7%  interrupts.CPU222.RES:Rescheduling_interrupts
     36076 ± 16%     -43.8%      20263 ± 36%  interrupts.CPU226.RES:Rescheduling_interrupts
     19194 ± 10%     +84.8%      35478 ± 13%  interrupts.CPU227.RES:Rescheduling_interrupts
      2425 ±  8%     -19.9%       1942 ±  6%  interrupts.CPU227.TLB:TLB_shootdowns
      2303 ± 22%     -23.9%       1753 ±  8%  interrupts.CPU234.TLB:TLB_shootdowns
      2837 ±  8%     -49.9%       1421 ± 11%  interrupts.CPU239.NMI:Non-maskable_interrupts
      2837 ±  8%     -49.9%       1421 ± 11%  interrupts.CPU239.PMI:Performance_monitoring_interrupts
     17386 ± 17%     +84.6%      32093 ± 30%  interrupts.CPU240.RES:Rescheduling_interrupts
     18801 ± 55%     +92.8%      36248 ± 23%  interrupts.CPU246.RES:Rescheduling_interrupts
      2469 ± 31%     -29.8%       1732 ± 17%  interrupts.CPU247.TLB:TLB_shootdowns
     31757 ± 27%     -35.3%      20541 ± 31%  interrupts.CPU250.RES:Rescheduling_interrupts
     36905 ± 40%     -46.7%      19670 ±  8%  interrupts.CPU252.RES:Rescheduling_interrupts
     20156 ± 12%     +44.7%      29156 ±  7%  interrupts.CPU253.RES:Rescheduling_interrupts
      4880 ± 30%     -48.0%       2539 ± 10%  interrupts.CPU26.TLB:TLB_shootdowns
     30073 ± 26%     -37.2%      18889 ± 28%  interrupts.CPU260.RES:Rescheduling_interrupts
     24487 ±  4%     -23.7%      18693 ± 23%  interrupts.CPU261.RES:Rescheduling_interrupts
      2201 ± 26%     -42.9%       1257 ± 29%  interrupts.CPU262.NMI:Non-maskable_interrupts
      2201 ± 26%     -42.9%       1257 ± 29%  interrupts.CPU262.PMI:Performance_monitoring_interrupts
     16758 ± 30%     +76.3%      29544 ± 16%  interrupts.CPU263.RES:Rescheduling_interrupts
      2958 ± 56%     -54.4%       1350 ± 25%  interrupts.CPU266.NMI:Non-maskable_interrupts
      2958 ± 56%     -54.4%       1350 ± 25%  interrupts.CPU266.PMI:Performance_monitoring_interrupts
     29594 ± 23%     -35.9%      18979 ± 33%  interrupts.CPU268.RES:Rescheduling_interrupts
      2391 ± 20%     -42.8%       1367 ± 25%  interrupts.CPU27.NMI:Non-maskable_interrupts
      2391 ± 20%     -42.8%       1367 ± 25%  interrupts.CPU27.PMI:Performance_monitoring_interrupts
     17135 ± 26%     +74.3%      29873 ± 20%  interrupts.CPU32.RES:Rescheduling_interrupts
     32963 ± 29%     -31.4%      22602 ± 27%  interrupts.CPU36.RES:Rescheduling_interrupts
      2328 ± 28%     -34.4%       1527 ± 50%  interrupts.CPU39.NMI:Non-maskable_interrupts
      2328 ± 28%     -34.4%       1527 ± 50%  interrupts.CPU39.PMI:Performance_monitoring_interrupts
     16869 ± 24%     +69.0%      28507 ± 22%  interrupts.CPU39.RES:Rescheduling_interrupts
      2584 ± 21%     -26.7%       1895 ± 16%  interrupts.CPU51.TLB:TLB_shootdowns
      3155 ± 16%     -36.1%       2015 ± 20%  interrupts.CPU52.TLB:TLB_shootdowns
      4951 ± 28%     -60.4%       1961 ± 25%  interrupts.CPU55.TLB:TLB_shootdowns
      4382 ± 24%     -50.2%       2183 ± 14%  interrupts.CPU56.TLB:TLB_shootdowns
     15835 ± 21%    +108.6%      33033 ± 30%  interrupts.CPU6.RES:Rescheduling_interrupts
      3549 ± 29%     -34.9%       2310 ± 16%  interrupts.CPU61.TLB:TLB_shootdowns
      3466 ± 41%     -51.2%       1691 ± 58%  interrupts.CPU67.NMI:Non-maskable_interrupts
      3466 ± 41%     -51.2%       1691 ± 58%  interrupts.CPU67.PMI:Performance_monitoring_interrupts
     35989 ± 19%     -36.0%      23024 ± 27%  interrupts.CPU75.RES:Rescheduling_interrupts
      2210 ±  6%     -30.4%       1538 ± 14%  interrupts.CPU76.TLB:TLB_shootdowns
      3307 ± 45%     -62.2%       1250 ± 14%  interrupts.CPU78.NMI:Non-maskable_interrupts
      3307 ± 45%     -62.2%       1250 ± 14%  interrupts.CPU78.PMI:Performance_monitoring_interrupts
      1604           +54.6%       2480 ± 12%  interrupts.CPU78.TLB:TLB_shootdowns
      2863 ± 57%     -42.8%       1636 ± 11%  interrupts.CPU90.NMI:Non-maskable_interrupts
      2863 ± 57%     -42.8%       1636 ± 11%  interrupts.CPU90.PMI:Performance_monitoring_interrupts
      2308 ± 11%     -21.7%       1808 ±  8%  interrupts.CPU91.TLB:TLB_shootdowns
     18040 ± 36%     +89.6%      34197 ±  9%  interrupts.CPU94.RES:Rescheduling_interrupts
     21085 ± 18%     +51.0%      31835 ± 16%  interrupts.CPU97.RES:Rescheduling_interrupts



***************************************************************************************************
lkp-bdw-ep3: 88 threads Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz with 64G memory
=========================================================================================
class/compiler/cpufreq_governor/disk/kconfig/nr_threads/rootfs/tbox_group/testcase/testtime/ucode:
  vm/gcc-7/performance/1HDD/x86_64-rhel-7.2/100%/debian-x86_64-2018-04-03.cgz/lkp-bdw-ep3/stress-ng/1s/0xb00002e

commit: 
  9627026352 ("mm: page_cache_add_speculative(): refactoring")
  cdaa813278 ("mm/gup: track gup-pinned pages")

96270263521248d5 cdaa813278ddc616ee201eacda7 
---------------- --------------------------- 
       fail:runs  %reproduction    fail:runs
           |             |             |    
           :4          100%           4:4     kmsg.Memory_failure:#:dirty_LRU_page_still_referenced_by#users
           :4          100%           4:4     kmsg.Memory_failure:#:recovery_action_for_dirty_LRU_page:Failed
          4:4         -100%            :4     kmsg.Memory_failure:#:recovery_action_for_dirty_LRU_page:Recovered
           :4          100%           4:4     dmesg.RIP:get_gup_pin_page
          1:4          -25%            :4     dmesg.WARNING:at#for_ip_swapgs_restore_regs_and_return_to_usermode/0x
           :4          100%           4:4     dmesg.WARNING:at_mm/gup.c:#get_gup_pin_page
          1:4          -25%            :4     dmesg.WARNING:stack_recursion
         %stddev     %change         %stddev
             \          |                \  
      7765            -3.4%       7499        stress-ng.time.percent_of_cpu_this_job_got
      1880            -5.1%       1784        stress-ng.time.system_time
   5023675 ±  2%     -58.3%    2095111        stress-ng.vm-splice.ops
     17.91 ±  8%     +12.9%      20.22 ±  6%  iostat.cpu.idle
      2406            -3.4%       2325        turbostat.Avg_MHz
  59555797           -11.7%   52587698        vmstat.memory.free
     15.47 ±  9%      +2.3       17.80 ±  7%  mpstat.cpu.idle%
      0.10 ±  8%      -0.0        0.08 ±  8%  mpstat.cpu.soft%
     34300 ±  2%      -5.0%      32577        perf-stat.ps.major-faults
    170288            -0.9%     168728        perf-stat.ps.msec
      1131 ±  7%     -17.7%     930.75 ± 14%  slabinfo.nsproxy.active_objs
      1131 ±  7%     -17.7%     930.75 ± 14%  slabinfo.nsproxy.num_objs
      4662 ±  9%     +69.2%       7887 ± 49%  softirqs.CPU22.RCU
      3963 ±  8%    +151.7%       9974 ± 50%  softirqs.CPU78.RCU
   2905249 ± 10%    +192.0%    8483775 ±  3%  meminfo.Active
   2905081 ± 10%    +192.0%    8483607 ±  3%  meminfo.Active(anon)
  23150145 ±  4%      -9.9%   20851826 ±  3%  meminfo.Committed_AS
   1365340 ±  5%     +84.5%    2518784 ±  4%  meminfo.Inactive
   1364952 ±  5%     +84.1%    2512920 ±  4%  meminfo.Inactive(anon)
    387.25 ±  6%   +1414.2%       5863 ±  4%  meminfo.Inactive(file)
  59176014           -11.4%   52417164        meminfo.MemAvailable
  59432778           -11.4%   52671931        meminfo.MemFree
   6419352 ±  3%    +105.3%   13180195 ±  2%  meminfo.Memused
      1.88 ±  6%    +110.3%       3.96 ± 39%  sched_debug.cpu.cpu_load[1].avg
     19.25 ±  2%    +629.9%     140.50 ± 62%  sched_debug.cpu.cpu_load[1].max
      4.41 ±  4%    +258.0%      15.78 ± 53%  sched_debug.cpu.cpu_load[1].stddev
      2.31 ± 14%     +94.2%       4.48 ± 31%  sched_debug.cpu.cpu_load[2].avg
     26.25 ± 47%    +471.4%     150.00 ± 41%  sched_debug.cpu.cpu_load[2].max
      4.71 ± 21%    +248.5%      16.42 ± 38%  sched_debug.cpu.cpu_load[2].stddev
     37.25 ± 37%    +208.1%     114.75 ± 37%  sched_debug.cpu.cpu_load[3].max
      5.87 ± 19%    +125.8%      13.25 ± 34%  sched_debug.cpu.cpu_load[3].stddev
     33.00 ± 19%    +122.0%      73.25 ± 46%  sched_debug.cpu.cpu_load[4].max
     11.46 ± 47%      -7.5        3.97 ± 98%  perf-profile.calltrace.cycles-pp.static_key_slow_dec.sw_perf_event_destroy._free_event.perf_event_release_kernel.perf_release
     11.46 ± 47%      -7.5        3.97 ± 98%  perf-profile.calltrace.cycles-pp.__static_key_slow_dec_cpuslocked.static_key_slow_dec.sw_perf_event_destroy._free_event.perf_event_release_kernel
     11.46 ± 47%      -7.5        3.97 ± 98%  perf-profile.calltrace.cycles-pp.__jump_label_update.__static_key_slow_dec_cpuslocked.static_key_slow_dec.sw_perf_event_destroy._free_event
     11.46 ± 47%      -7.5        3.97 ± 98%  perf-profile.calltrace.cycles-pp.arch_jump_label_transform.__jump_label_update.__static_key_slow_dec_cpuslocked.static_key_slow_dec.sw_perf_event_destroy
     11.46 ± 47%      -7.5        3.97 ± 98%  perf-profile.calltrace.cycles-pp.__jump_label_transform.arch_jump_label_transform.__jump_label_update.__static_key_slow_dec_cpuslocked.static_key_slow_dec
     11.46 ± 47%      -7.5        3.97 ± 98%  perf-profile.calltrace.cycles-pp.smp_call_function_many.on_each_cpu.text_poke_bp.__jump_label_transform.arch_jump_label_transform
     11.46 ± 47%      -7.5        3.97 ± 98%  perf-profile.calltrace.cycles-pp.on_each_cpu.text_poke_bp.__jump_label_transform.arch_jump_label_transform.__jump_label_update
     11.46 ± 47%      -7.5        3.97 ± 98%  perf-profile.calltrace.cycles-pp.text_poke_bp.__jump_label_transform.arch_jump_label_transform.__jump_label_update.__static_key_slow_dec_cpuslocked
     11.46 ± 47%      -6.7        4.78 ± 69%  perf-profile.calltrace.cycles-pp._free_event.perf_event_release_kernel.perf_release.__fput.task_work_run
     11.46 ± 47%      -6.7        4.78 ± 69%  perf-profile.calltrace.cycles-pp.sw_perf_event_destroy._free_event.perf_event_release_kernel.perf_release.__fput
    695203 ±  5%    +213.3%    2177910 ±  3%  proc-vmstat.nr_active_anon
   1473798           -11.8%    1299346        proc-vmstat.nr_dirty_background_threshold
   2952003           -11.8%    2603072        proc-vmstat.nr_dirty_threshold
  14852961           -11.8%   13107633        proc-vmstat.nr_free_pages
    377237 ±  7%     +69.4%     639157 ±  3%  proc-vmstat.nr_inactive_anon
     97.00 ±  3%   +1395.6%       1450 ±  6%  proc-vmstat.nr_inactive_file
    695202 ±  5%    +213.3%    2177910 ±  3%  proc-vmstat.nr_zone_active_anon
    377237 ±  7%     +69.4%     639157 ±  3%  proc-vmstat.nr_zone_inactive_anon
     97.00 ±  3%   +1395.6%       1450 ±  6%  proc-vmstat.nr_zone_inactive_file
  12792774 ±  2%     -10.7%   11419593 ±  7%  proc-vmstat.pgactivate
      2113            -3.3%       2043 ±  2%  proc-vmstat.thp_split_page
   1404817 ±  4%    +213.6%    4405232 ±  9%  numa-meminfo.node0.Active
   1404733 ±  4%    +213.6%    4405148 ±  9%  numa-meminfo.node0.Active(anon)
    828406 ± 12%     +51.0%    1250665 ± 10%  numa-meminfo.node0.Inactive
    828190 ± 12%     +50.7%    1247741 ± 10%  numa-meminfo.node0.Inactive(anon)
    214.75 ± 59%   +1261.6%       2924 ± 10%  numa-meminfo.node0.Inactive(file)
  29574615           -11.6%   26131731 ±  2%  numa-meminfo.node0.MemFree
   3284371 ±  6%    +104.8%    6727255 ±  8%  numa-meminfo.node0.MemUsed
   1476404 ± 11%    +204.2%    4491068 ±  2%  numa-meminfo.node1.Active
   1476320 ± 11%    +204.2%    4490984 ±  2%  numa-meminfo.node1.Active(anon)
    684877 ± 19%     +87.8%    1286317 ±  9%  numa-meminfo.node1.Inactive
    684690 ± 19%     +87.5%    1283519 ±  9%  numa-meminfo.node1.Inactive(anon)
    186.50 ± 65%   +1400.3%       2798 ±  6%  numa-meminfo.node1.Inactive(file)
  29743730           -12.1%   26154353        numa-meminfo.node1.MemFree
   3249412 ±  9%    +110.5%    6838786 ±  3%  numa-meminfo.node1.MemUsed
    377498 ± 12%    +193.5%    1108039 ±  9%  numa-vmstat.node0.nr_active_anon
   7374428           -11.6%    6515488 ±  2%  numa-vmstat.node0.nr_free_pages
    203915 ± 20%     +57.8%     321729 ±  8%  numa-vmstat.node0.nr_inactive_anon
     55.25 ± 59%   +1211.3%     724.50 ± 11%  numa-vmstat.node0.nr_inactive_file
    377455 ± 12%    +193.5%    1108012 ±  9%  numa-vmstat.node0.nr_zone_active_anon
    203887 ± 20%     +57.8%     321697 ±  8%  numa-vmstat.node0.nr_zone_inactive_anon
     55.25 ± 59%   +1211.3%     724.50 ± 11%  numa-vmstat.node0.nr_zone_inactive_file
    392594 ± 12%    +181.8%    1106200 ±  3%  numa-vmstat.node1.nr_active_anon
   7400171           -11.6%    6543657        numa-vmstat.node1.nr_free_pages
    185991 ± 20%     +78.6%     332154 ±  8%  numa-vmstat.node1.nr_inactive_anon
     44.75 ± 65%   +1458.7%     697.50 ±  5%  numa-vmstat.node1.nr_inactive_file
    392558 ± 12%    +181.8%    1106188 ±  3%  numa-vmstat.node1.nr_zone_active_anon
    185980 ± 20%     +78.6%     332130 ±  8%  numa-vmstat.node1.nr_zone_inactive_anon
     44.75 ± 65%   +1458.7%     697.50 ±  5%  numa-vmstat.node1.nr_zone_inactive_file
     92917            -2.7%      90421        interrupts.CAL:Function_call_interrupts
    537.00 ± 10%     +28.6%     690.50 ± 12%  interrupts.CPU13.RES:Rescheduling_interrupts
    574.25 ±  6%     +44.4%     829.50 ± 29%  interrupts.CPU17.RES:Rescheduling_interrupts
      4162 ± 12%     -22.4%       3231 ±  5%  interrupts.CPU22.TLB:TLB_shootdowns
      4051 ± 11%     -20.9%       3203 ±  3%  interrupts.CPU23.TLB:TLB_shootdowns
      4017 ±  5%     -17.4%       3318 ±  3%  interrupts.CPU24.TLB:TLB_shootdowns
      4249 ± 10%     -22.7%       3283 ±  8%  interrupts.CPU25.TLB:TLB_shootdowns
      4003 ±  7%     -17.8%       3291 ±  2%  interrupts.CPU26.TLB:TLB_shootdowns
      4161 ±  8%     -19.8%       3336 ±  7%  interrupts.CPU27.TLB:TLB_shootdowns
      4063 ±  5%     -17.9%       3337 ±  5%  interrupts.CPU28.TLB:TLB_shootdowns
      3970 ±  6%     -17.6%       3271 ±  4%  interrupts.CPU29.TLB:TLB_shootdowns
      4093 ±  7%     -20.1%       3270 ±  3%  interrupts.CPU30.TLB:TLB_shootdowns
      4001 ±  7%     -15.2%       3392 ±  9%  interrupts.CPU31.TLB:TLB_shootdowns
      4246 ±  7%     -22.6%       3284 ±  3%  interrupts.CPU32.TLB:TLB_shootdowns
      3949 ±  6%     -14.9%       3361 ±  6%  interrupts.CPU33.TLB:TLB_shootdowns
      3949 ±  5%     -15.6%       3332 ±  8%  interrupts.CPU34.TLB:TLB_shootdowns
      4057 ±  9%     -20.4%       3228 ±  3%  interrupts.CPU35.TLB:TLB_shootdowns
      4105 ±  7%     -22.5%       3180 ±  8%  interrupts.CPU36.TLB:TLB_shootdowns
      3957 ±  7%     -18.7%       3217 ±  7%  interrupts.CPU37.TLB:TLB_shootdowns
      4071 ±  8%     -20.7%       3229 ±  4%  interrupts.CPU38.TLB:TLB_shootdowns
      4256 ± 18%     -22.8%       3286 ±  4%  interrupts.CPU39.TLB:TLB_shootdowns
      4334 ±  2%     -22.0%       3381 ±  6%  interrupts.CPU40.TLB:TLB_shootdowns
      3858 ±  5%     -17.2%       3195 ±  7%  interrupts.CPU42.TLB:TLB_shootdowns
      4212 ±  9%     -20.3%       3356 ±  3%  interrupts.CPU43.TLB:TLB_shootdowns
      3922 ±  9%     -17.7%       3227 ±  4%  interrupts.CPU66.TLB:TLB_shootdowns
      4021 ±  3%     -16.1%       3372 ±  5%  interrupts.CPU67.TLB:TLB_shootdowns
      4176 ±  4%     -19.0%       3381 ±  4%  interrupts.CPU68.TLB:TLB_shootdowns
      4149 ±  5%     -39.5%       2508 ± 57%  interrupts.CPU69.TLB:TLB_shootdowns
      3993 ±  8%     -18.1%       3270 ±  3%  interrupts.CPU70.TLB:TLB_shootdowns
      4059 ±  4%     -17.4%       3352 ±  4%  interrupts.CPU71.TLB:TLB_shootdowns
    514.50 ±  5%     +49.7%     770.00 ± 24%  interrupts.CPU72.RES:Rescheduling_interrupts
      3994 ±  5%     -20.9%       3158 ±  2%  interrupts.CPU72.TLB:TLB_shootdowns
      4034 ±  7%     -17.1%       3342 ±  3%  interrupts.CPU73.TLB:TLB_shootdowns
      4018 ±  7%     -15.1%       3412 ±  4%  interrupts.CPU74.TLB:TLB_shootdowns
      4052 ±  7%     -14.6%       3459 ±  5%  interrupts.CPU75.TLB:TLB_shootdowns
      4060 ±  6%     -19.6%       3263 ±  5%  interrupts.CPU76.TLB:TLB_shootdowns
      4025 ±  5%     -20.1%       3217 ±  2%  interrupts.CPU77.TLB:TLB_shootdowns
      4071 ±  6%     -21.5%       3197 ±  2%  interrupts.CPU78.TLB:TLB_shootdowns
      4045 ±  5%     -17.7%       3330 ±  7%  interrupts.CPU79.TLB:TLB_shootdowns
    454.00 ± 36%     +51.5%     688.00 ± 13%  interrupts.CPU80.RES:Rescheduling_interrupts
      3963 ±  5%     -18.5%       3229 ±  5%  interrupts.CPU81.TLB:TLB_shootdowns
      4202 ±  5%     -25.3%       3139 ±  5%  interrupts.CPU82.TLB:TLB_shootdowns
      3843 ±  3%     -15.6%       3242        interrupts.CPU83.TLB:TLB_shootdowns
      4169 ±  5%     -40.3%       2489 ± 57%  interrupts.CPU86.TLB:TLB_shootdowns
      4062 ±  6%     -17.6%       3345 ±  2%  interrupts.CPU87.TLB:TLB_shootdowns



***************************************************************************************************
vm-snb-4G: qemu-system-x86_64 -enable-kvm -cpu SandyBridge -smp 2 -m 4G
=========================================================================================
compiler/group/kconfig/rootfs/tbox_group/testcase:
  gcc-7/kselftests-02/x86_64-rhel-7.2/debian-x86_64-2018-04-03.cgz/vm-snb-4G/kernel_selftests

commit: 
  9627026352 ("mm: page_cache_add_speculative(): refactoring")
  cdaa813278 ("mm/gup: track gup-pinned pages")

96270263521248d5 cdaa813278ddc616ee201eacda7 
---------------- --------------------------- 
       fail:runs  %reproduction    fail:runs
           |             |             |    
          4:12         -25%           1:12    kmsg.unregister_netdevice:waiting_for_veth_A-R1_to_become_free.Usage_count=
          1:12          -8%            :12    kmsg.veth0:Failed_to_cycle_device_veth0;route_tables_might_be_wrong
           :12         100%          12:12    kernel_selftests.memfd.run_fuse_test.sh.fail
           :12           8%           1:12    kernel_selftests.net.ip_defrag.sh.fail
         %stddev     %change         %stddev
             \          |                \  
      1.00          -100.0%       0.00        kernel_selftests.memfd.run_fuse_test.sh.pass
    361623          +223.2%    1168751        meminfo.Active
    361623          +223.2%    1168751        meminfo.Active(anon)
    127769 ± 21%     -94.8%       6662 ± 26%  meminfo.CmaFree
   1941240           -41.3%    1139756        meminfo.MemAvailable
   1895394           -42.4%    1091194 ±  2%  meminfo.MemFree
   2137756           +37.6%    2941952        meminfo.Memused
    881.70 ±  5%     +52.8%       1347 ±  4%  meminfo.max_used_kB



***************************************************************************************************
lkp-bdw-ep3: 88 threads Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz with 64G memory
=========================================================================================
class/compiler/cpufreq_governor/disk/kconfig/nr_threads/rootfs/tbox_group/testcase/testtime/ucode:
  pipe/gcc-7/performance/1HDD/x86_64-rhel-7.2/100%/debian-x86_64-2018-04-03.cgz/lkp-bdw-ep3/stress-ng/60s/0xb00002e

commit: 
  9627026352 ("mm: page_cache_add_speculative(): refactoring")
  cdaa813278 ("mm/gup: track gup-pinned pages")

96270263521248d5 cdaa813278ddc616ee201eacda7 
---------------- --------------------------- 
       fail:runs  %reproduction    fail:runs
           |             |             |    
           :4          100%           4:4     dmesg.RIP:get_gup_pin_page
           :4          100%           4:4     dmesg.WARNING:at_mm/gup.c:#get_gup_pin_page
         %stddev     %change         %stddev
             \          |                \  
    360.22           -16.3%     301.59        stress-ng.time.elapsed_time
    360.22           -16.3%     301.59        stress-ng.time.elapsed_time.max
      8342            -1.3%       8234        stress-ng.time.percent_of_cpu_this_job_got
     26890           -19.3%      21707        stress-ng.time.system_time
 2.989e+08           -99.3%    2099213        stress-ng.vm-splice.ops
  12010366           +10.0%   13211802        meminfo.Committed_AS
      5812 ±  4%     +18.0%       6856 ±  3%  meminfo.max_used_kB
      5.64 ±  2%      +1.3        6.94 ±  2%  mpstat.cpu.idle%
      9.90            +1.8       11.68 ±  2%  mpstat.cpu.usr%
    107366 ± 93%     -78.7%      22825 ± 44%  numa-meminfo.node0.AnonPages
     74249 ±  6%     -13.8%      63969 ±  9%  numa-meminfo.node0.SUnreclaim
      5.90 ±  2%     +22.8%       7.24        iostat.cpu.idle
     84.23            -3.7%      81.11        iostat.cpu.system
      9.87           +18.0%      11.64 ±  2%  iostat.cpu.user
     16463            +2.3%      16841        proc-vmstat.nr_kernel_stack
    275921 ± 93%     -50.8%     135706 ±150%  proc-vmstat.numa_pte_updates
   1000818           -14.3%     857522        proc-vmstat.pgfault
     83.75            -3.6%      80.75        vmstat.cpu.sy
      9.25 ±  4%     +21.6%      11.25 ±  3%  vmstat.cpu.us
   1766858           +20.5%    2129192        vmstat.system.cs
    185535            +1.5%     188310        vmstat.system.in
     26840 ± 93%     -78.8%       5697 ± 44%  numa-vmstat.node0.nr_anon_pages
     18563 ±  6%     -13.8%      15992 ±  9%  numa-vmstat.node0.nr_slab_unreclaimable
 1.066e+09 ±  2%     -28.2%  7.648e+08 ±  7%  numa-vmstat.node0.numa_hit
 1.066e+09 ±  2%     -28.2%  7.648e+08 ±  7%  numa-vmstat.node0.numa_local
 9.301e+08 ±  2%     -17.2%  7.701e+08 ±  6%  numa-vmstat.node1.numa_hit
   9.3e+08 ±  2%     -17.2%  7.699e+08 ±  6%  numa-vmstat.node1.numa_local
      2.15 ±  2%      -0.1        2.03 ±  4%  perf-profile.calltrace.cycles-pp.intel_idle.cpuidle_enter_state.do_idle.cpu_startup_entry.start_secondary
      0.87            -0.1        0.81        perf-profile.calltrace.cycles-pp.avc_has_perm.file_has_perm.security_file_permission.vfs_read.ksys_read
      1.35            -0.0        1.30        perf-profile.calltrace.cycles-pp.file_has_perm.security_file_permission.vfs_read.ksys_read.do_syscall_64
      0.83            -0.0        0.80        perf-profile.calltrace.cycles-pp.avc_has_perm.file_has_perm.security_file_permission.vfs_write.ksys_write
      1.31            -0.0        1.27        perf-profile.calltrace.cycles-pp.file_has_perm.security_file_permission.vfs_write.ksys_write.do_syscall_64
      0.55            +0.0        0.57        perf-profile.calltrace.cycles-pp.__inode_security_revalidate.selinux_file_permission.security_file_permission.vfs_write.ksys_write
      2.09            +0.1        2.15        perf-profile.calltrace.cycles-pp.__alloc_pages_nodemask.pipe_write.__vfs_write.vfs_write.ksys_write
      2.62 ±  2%      +0.1        2.68        perf-profile.calltrace.cycles-pp.pipe_wait.pipe_write.__vfs_write.vfs_write.ksys_write
      2650            -1.3%       2616        turbostat.Avg_MHz
      3.85 ±  2%      +0.7        4.55        turbostat.C1%
      0.54 ±  7%      +0.2        0.70 ± 12%  turbostat.C1E%
      4.71 ±  2%     +21.7%       5.73        turbostat.CPU%c1
     77.50 ±  2%     -14.2%      66.50 ±  2%  turbostat.CoreTmp
  67302470           -14.9%   57247592        turbostat.IRQ
     81.75 ±  2%     -13.1%      71.00        turbostat.PkgTmp
    261.28            +3.9%     271.39        turbostat.PkgWatt
   1285315 ±  8%     +15.7%    1487427 ±  6%  sched_debug.cfs_rq:/.MIN_vruntime.stddev
    173175           -16.1%     145379        sched_debug.cfs_rq:/.exec_clock.avg
    174188           -16.1%     146168        sched_debug.cfs_rq:/.exec_clock.max
    171345           -16.0%     143970        sched_debug.cfs_rq:/.exec_clock.min
      5689 ±  7%     -27.5%       4124 ± 10%  sched_debug.cfs_rq:/.load.min
    168.54 ±  6%     +12.3%     189.25 ±  6%  sched_debug.cfs_rq:/.load_avg.max
   1285315 ±  8%     +15.7%    1487427 ±  6%  sched_debug.cfs_rq:/.max_vruntime.stddev
  16247293           -15.8%   13678528        sched_debug.cfs_rq:/.min_vruntime.avg
  17621646 ±  2%     -13.2%   15289779 ±  3%  sched_debug.cfs_rq:/.min_vruntime.max
  14916399           -18.2%   12204755 ±  3%  sched_debug.cfs_rq:/.min_vruntime.min
      0.13 ±  6%     +21.7%       0.16 ±  8%  sched_debug.cfs_rq:/.nr_running.stddev
      4.96 ±  4%     -20.3%       3.96 ±  9%  sched_debug.cfs_rq:/.runnable_load_avg.min
      5426 ±  8%     -19.0%       4397 ± 11%  sched_debug.cfs_rq:/.runnable_weight.min
     10113 ± 21%     -48.9%       5166 ± 13%  sched_debug.cpu.avg_idle.min
    222767           -13.4%     192825        sched_debug.cpu.clock.avg
    222785           -13.4%     192841        sched_debug.cpu.clock.max
    222745           -13.4%     192807        sched_debug.cpu.clock.min
     11.90 ± 12%     -17.7%       9.80 ± 12%  sched_debug.cpu.clock.stddev
    222767           -13.4%     192825        sched_debug.cpu.clock_task.avg
    222785           -13.4%     192841        sched_debug.cpu.clock_task.max
    222745           -13.4%     192807        sched_debug.cpu.clock_task.min
     11.90 ± 12%     -17.7%       9.80 ± 12%  sched_debug.cpu.clock_task.stddev
      5.21 ±  3%     -12.9%       4.54 ±  3%  sched_debug.cpu.cpu_load[0].min
      4955           -19.3%       4001        sched_debug.cpu.curr->pid.avg
      6909           -11.6%       6108        sched_debug.cpu.curr->pid.max
     11634 ±  7%     -10.9%      10363        sched_debug.cpu.load.avg
    193768           -15.5%     163653        sched_debug.cpu.nr_load_updates.avg
    197917           -15.6%     167117        sched_debug.cpu.nr_load_updates.max
    191959           -15.6%     162097        sched_debug.cpu.nr_load_updates.min
      0.50 ±  6%     +10.8%       0.56 ±  6%  sched_debug.cpu.nr_running.stddev
   4644436 ±  2%      -7.8%    4280609 ±  2%  sched_debug.cpu.nr_switches.avg
   4644663 ±  2%      -7.8%    4280771 ±  2%  sched_debug.cpu.sched_count.avg
    409748 ±  4%     -22.5%     317516 ±  3%  sched_debug.cpu.sched_goidle.avg
    572470 ± 11%     -22.4%     444043 ± 13%  sched_debug.cpu.sched_goidle.max
    286861 ±  7%     -22.8%     221401 ±  8%  sched_debug.cpu.sched_goidle.min
    222744           -13.4%     192807        sched_debug.cpu_clk
    219014           -13.7%     189076        sched_debug.ktime
    223427           -13.4%     193488        sched_debug.sched_clk
     14.20           +15.8%      16.44        perf-stat.i.MPKI
 3.166e+10           +17.1%  3.708e+10        perf-stat.i.branch-instructions
      1.57            +0.0        1.59        perf-stat.i.branch-miss-rate%
 4.847e+08           +16.6%  5.653e+08 ±  2%  perf-stat.i.branch-misses
     12.07 ± 23%      -7.1        4.97 ± 55%  perf-stat.i.cache-miss-rate%
 9.997e+08           +18.7%  1.187e+09        perf-stat.i.cache-references
   1782714           +20.5%    2148963        perf-stat.i.context-switches
      4.01           -60.1%       1.60        perf-stat.i.cpi
    269394 ±  5%     +18.6%     319628 ±  2%  perf-stat.i.cpu-migrations
      0.19 ±  3%      +0.0        0.22        perf-stat.i.dTLB-load-miss-rate%
  47856194 ±  3%     +19.6%   57235440        perf-stat.i.dTLB-load-misses
 3.932e+10           +16.8%  4.592e+10        perf-stat.i.dTLB-loads
 2.459e+10           +16.7%  2.871e+10        perf-stat.i.dTLB-stores
     72.03            +1.3       73.35        perf-stat.i.iTLB-load-miss-rate%
  92906511 ±  2%     +16.5%  1.083e+08 ±  3%  perf-stat.i.iTLB-load-misses
  35482612           +12.6%   39969391 ±  2%  perf-stat.i.iTLB-loads
 1.521e+11           +17.0%  1.779e+11        perf-stat.i.instructions
     28571 ±  3%     +14.4%      32688 ±  6%  perf-stat.i.instructions-per-iTLB-miss
      0.64           +16.9%       0.75        perf-stat.i.ipc
      2696            +1.9%       2746        perf-stat.i.minor-faults
    115872 ±  4%     +33.3%     154453 ± 11%  perf-stat.i.node-loads
     69.92 ±  5%      -6.0       63.95 ±  2%  perf-stat.i.node-store-miss-rate%
      2696            +1.9%       2746        perf-stat.i.page-faults
      1.53           -15.3%       1.30        perf-stat.overall.cpi
      0.65           +18.1%       0.77        perf-stat.overall.ipc
 3.153e+10           +16.9%  3.684e+10        perf-stat.ps.branch-instructions
 4.827e+08           +16.3%  5.616e+08 ±  2%  perf-stat.ps.branch-misses
 9.972e+08           +18.4%  1.181e+09        perf-stat.ps.cache-references
   1778082           +20.3%    2138597        perf-stat.ps.context-switches
 2.319e+11            -1.2%  2.292e+11        perf-stat.ps.cpu-cycles
    268859 ±  5%     +18.4%     318278 ±  2%  perf-stat.ps.cpu-migrations
  47762824 ±  3%     +19.4%   57005870        perf-stat.ps.dTLB-load-misses
 3.916e+10           +16.5%  4.563e+10        perf-stat.ps.dTLB-loads
 2.449e+10           +16.5%  2.852e+10        perf-stat.ps.dTLB-stores
  92569828 ±  2%     +16.2%  1.076e+08 ±  3%  perf-stat.ps.iTLB-load-misses
  35350893           +12.4%   39724157 ±  2%  perf-stat.ps.iTLB-loads
 1.515e+11           +16.7%  1.767e+11        perf-stat.ps.instructions
      2690            +1.6%       2733        perf-stat.ps.minor-faults
    115582 ±  4%     +33.0%     153669 ± 11%  perf-stat.ps.node-loads
      2690            +1.6%       2733        perf-stat.ps.page-faults
 5.463e+13            -2.2%  5.344e+13        perf-stat.total.instructions
    423.00           -16.0%     355.50        interrupts.9:IO-APIC.9-fasteoi.acpi
    334285           -13.8%     288189        interrupts.CAL:Function_call_interrupts
      3718 ±  5%     -11.2%       3301        interrupts.CPU0.CAL:Function_call_interrupts
    721763           -16.2%     605183        interrupts.CPU0.LOC:Local_timer_interrupts
     25452 ± 12%     +29.7%      33009 ± 11%  interrupts.CPU0.RES:Rescheduling_interrupts
    423.00           -16.0%     355.50        interrupts.CPU1.9:IO-APIC.9-fasteoi.acpi
      3841           -13.6%       3317        interrupts.CPU1.CAL:Function_call_interrupts
    721450           -16.2%     604748        interrupts.CPU1.LOC:Local_timer_interrupts
      3776 ±  2%     -12.2%       3317        interrupts.CPU10.CAL:Function_call_interrupts
    722124           -16.2%     604931        interrupts.CPU10.LOC:Local_timer_interrupts
     22581 ± 13%     +44.5%      32630 ± 25%  interrupts.CPU10.RES:Rescheduling_interrupts
      3835           -13.4%       3321        interrupts.CPU11.CAL:Function_call_interrupts
    721997           -16.2%     605063        interrupts.CPU11.LOC:Local_timer_interrupts
     21969 ± 12%     +39.6%      30662 ± 10%  interrupts.CPU11.RES:Rescheduling_interrupts
      3828           -12.7%       3340        interrupts.CPU12.CAL:Function_call_interrupts
    721760           -16.2%     604828        interrupts.CPU12.LOC:Local_timer_interrupts
      3790           -12.8%       3303        interrupts.CPU13.CAL:Function_call_interrupts
    721659           -16.2%     604978        interrupts.CPU13.LOC:Local_timer_interrupts
      3796           -12.6%       3317        interrupts.CPU14.CAL:Function_call_interrupts
    721830           -16.2%     605051        interrupts.CPU14.LOC:Local_timer_interrupts
      3745 ±  2%     -11.6%       3313        interrupts.CPU15.CAL:Function_call_interrupts
    721696           -16.1%     605247        interrupts.CPU15.LOC:Local_timer_interrupts
      3796 ±  2%     -13.1%       3298        interrupts.CPU16.CAL:Function_call_interrupts
    721615           -16.1%     605304        interrupts.CPU16.LOC:Local_timer_interrupts
    721686           -16.2%     604977        interrupts.CPU17.LOC:Local_timer_interrupts
     23557 ± 11%     +31.8%      31037 ± 17%  interrupts.CPU17.RES:Rescheduling_interrupts
      3841           -13.9%       3308        interrupts.CPU18.CAL:Function_call_interrupts
    721620           -16.2%     604958        interrupts.CPU18.LOC:Local_timer_interrupts
     22764 ± 17%     +33.8%      30451 ±  8%  interrupts.CPU18.RES:Rescheduling_interrupts
      3790 ±  2%     -12.8%       3304        interrupts.CPU19.CAL:Function_call_interrupts
    721479           -16.1%     604999        interrupts.CPU19.LOC:Local_timer_interrupts
      3845           -14.0%       3307        interrupts.CPU2.CAL:Function_call_interrupts
    721284           -16.1%     605094        interrupts.CPU2.LOC:Local_timer_interrupts
     22880 ± 19%     +42.0%      32484 ± 12%  interrupts.CPU2.RES:Rescheduling_interrupts
    721360           -16.1%     604946        interrupts.CPU20.LOC:Local_timer_interrupts
     21116 ± 18%     +39.1%      29366 ± 17%  interrupts.CPU20.RES:Rescheduling_interrupts
      3811           -13.5%       3297        interrupts.CPU21.CAL:Function_call_interrupts
    721473           -16.2%     604796        interrupts.CPU21.LOC:Local_timer_interrupts
      3827           -15.3%       3241 ±  3%  interrupts.CPU22.CAL:Function_call_interrupts
    721210           -16.2%     604237        interrupts.CPU22.LOC:Local_timer_interrupts
    721987           -16.2%     604725        interrupts.CPU23.LOC:Local_timer_interrupts
      3821           -19.4%       3081 ±  6%  interrupts.CPU24.CAL:Function_call_interrupts
    721544           -16.2%     604685        interrupts.CPU24.LOC:Local_timer_interrupts
      3786           -15.6%       3194 ±  3%  interrupts.CPU25.CAL:Function_call_interrupts
    721135           -16.1%     604853        interrupts.CPU25.LOC:Local_timer_interrupts
      3827           -15.2%       3245 ±  2%  interrupts.CPU26.CAL:Function_call_interrupts
    721813           -16.2%     605191        interrupts.CPU26.LOC:Local_timer_interrupts
      3821           -25.4%       2851 ± 26%  interrupts.CPU27.CAL:Function_call_interrupts
    721056           -16.1%     605078        interrupts.CPU27.LOC:Local_timer_interrupts
      3818           -15.1%       3241 ±  3%  interrupts.CPU28.CAL:Function_call_interrupts
    721295           -16.1%     604867        interrupts.CPU28.LOC:Local_timer_interrupts
      3839           -14.2%       3293        interrupts.CPU29.CAL:Function_call_interrupts
    721791           -16.2%     604635        interrupts.CPU29.LOC:Local_timer_interrupts
      3818           -13.1%       3318        interrupts.CPU3.CAL:Function_call_interrupts
    721555           -16.2%     604385        interrupts.CPU3.LOC:Local_timer_interrupts
     22807 ± 12%     +32.9%      30316 ± 13%  interrupts.CPU3.RES:Rescheduling_interrupts
      3829           -14.3%       3280        interrupts.CPU30.CAL:Function_call_interrupts
    721877           -16.2%     604644        interrupts.CPU30.LOC:Local_timer_interrupts
     29149 ±  5%     -15.8%      24552 ± 10%  interrupts.CPU30.RES:Rescheduling_interrupts
      3838           -13.9%       3304        interrupts.CPU31.CAL:Function_call_interrupts
    721927           -16.2%     604849        interrupts.CPU31.LOC:Local_timer_interrupts
      3836           -14.2%       3290        interrupts.CPU32.CAL:Function_call_interrupts
    720992           -16.1%     604786        interrupts.CPU32.LOC:Local_timer_interrupts
      3826           -14.0%       3292        interrupts.CPU33.CAL:Function_call_interrupts
    721853           -16.2%     604700        interrupts.CPU33.LOC:Local_timer_interrupts
      3809           -13.8%       3283        interrupts.CPU34.CAL:Function_call_interrupts
    721742           -16.2%     605038        interrupts.CPU34.LOC:Local_timer_interrupts
      3833           -14.0%       3296        interrupts.CPU35.CAL:Function_call_interrupts
    721732           -16.2%     604841        interrupts.CPU35.LOC:Local_timer_interrupts
      3700 ±  6%     -12.7%       3229 ±  3%  interrupts.CPU36.CAL:Function_call_interrupts
    721598           -16.2%     604849        interrupts.CPU36.LOC:Local_timer_interrupts
      3835           -14.1%       3293        interrupts.CPU37.CAL:Function_call_interrupts
    721245           -16.2%     604498        interrupts.CPU37.LOC:Local_timer_interrupts
      3831           -13.8%       3301        interrupts.CPU38.CAL:Function_call_interrupts
    721366           -16.1%     605049        interrupts.CPU38.LOC:Local_timer_interrupts
      3843           -15.3%       3253 ±  2%  interrupts.CPU39.CAL:Function_call_interrupts
    721951           -16.2%     604693        interrupts.CPU39.LOC:Local_timer_interrupts
      3823           -13.2%       3316        interrupts.CPU4.CAL:Function_call_interrupts
    721523           -16.2%     604953        interrupts.CPU4.LOC:Local_timer_interrupts
     22707 ± 16%     +33.2%      30241 ±  3%  interrupts.CPU4.RES:Rescheduling_interrupts
      3840           -14.2%       3294        interrupts.CPU40.CAL:Function_call_interrupts
    721636           -16.2%     604810        interrupts.CPU40.LOC:Local_timer_interrupts
      3847           -18.8%       3122 ±  9%  interrupts.CPU41.CAL:Function_call_interrupts
    721928           -16.2%     604884        interrupts.CPU41.LOC:Local_timer_interrupts
      3839           -14.3%       3290        interrupts.CPU42.CAL:Function_call_interrupts
    721753           -16.2%     604811        interrupts.CPU42.LOC:Local_timer_interrupts
      3778           -13.8%       3255        interrupts.CPU43.CAL:Function_call_interrupts
    721315           -16.2%     604691        interrupts.CPU43.LOC:Local_timer_interrupts
      3841           -13.7%       3314        interrupts.CPU44.CAL:Function_call_interrupts
    721306           -16.2%     604640        interrupts.CPU44.LOC:Local_timer_interrupts
     22357 ± 16%     +47.9%      33078 ± 15%  interrupts.CPU44.RES:Rescheduling_interrupts
      3832           -15.0%       3256 ±  3%  interrupts.CPU45.CAL:Function_call_interrupts
    721470           -16.2%     604760        interrupts.CPU45.LOC:Local_timer_interrupts
      3846           -18.1%       3149 ±  9%  interrupts.CPU46.CAL:Function_call_interrupts
    721294           -16.2%     604606        interrupts.CPU46.LOC:Local_timer_interrupts
     22430 ± 19%     +39.5%      31283 ± 10%  interrupts.CPU46.RES:Rescheduling_interrupts
      3795           -12.5%       3320        interrupts.CPU47.CAL:Function_call_interrupts
    721274           -16.2%     604302        interrupts.CPU47.LOC:Local_timer_interrupts
     22255 ± 13%     +29.9%      28907 ±  5%  interrupts.CPU47.RES:Rescheduling_interrupts
      3841           -14.2%       3295        interrupts.CPU48.CAL:Function_call_interrupts
    721357           -16.2%     604782        interrupts.CPU48.LOC:Local_timer_interrupts
     20959 ± 17%     +36.5%      28600 ±  7%  interrupts.CPU48.RES:Rescheduling_interrupts
      3835           -13.3%       3324        interrupts.CPU49.CAL:Function_call_interrupts
    721311           -16.1%     605127        interrupts.CPU49.LOC:Local_timer_interrupts
     22089 ± 15%     +33.1%      29406 ± 11%  interrupts.CPU49.RES:Rescheduling_interrupts
      3842           -14.0%       3305        interrupts.CPU5.CAL:Function_call_interrupts
    721561           -16.1%     605092        interrupts.CPU5.LOC:Local_timer_interrupts
     24272 ± 14%     +25.3%      30413 ± 11%  interrupts.CPU5.RES:Rescheduling_interrupts
      3848           -13.7%       3319        interrupts.CPU50.CAL:Function_call_interrupts
    721251           -16.1%     604921        interrupts.CPU50.LOC:Local_timer_interrupts
      3827           -13.3%       3318        interrupts.CPU51.CAL:Function_call_interrupts
    721474           -16.2%     604842        interrupts.CPU51.LOC:Local_timer_interrupts
      3812           -12.5%       3337        interrupts.CPU52.CAL:Function_call_interrupts
    721284           -16.1%     604942        interrupts.CPU52.LOC:Local_timer_interrupts
     22236 ± 10%     +33.3%      29642 ±  8%  interrupts.CPU52.RES:Rescheduling_interrupts
    721452           -16.1%     605377        interrupts.CPU53.LOC:Local_timer_interrupts
     21926 ± 15%     +38.2%      30305 ± 12%  interrupts.CPU53.RES:Rescheduling_interrupts
    721468           -16.1%     605249        interrupts.CPU54.LOC:Local_timer_interrupts
     22522 ± 13%     +36.4%      30717 ± 17%  interrupts.CPU54.RES:Rescheduling_interrupts
      3842           -13.9%       3307        interrupts.CPU55.CAL:Function_call_interrupts
    721620           -16.2%     604986        interrupts.CPU55.LOC:Local_timer_interrupts
     22201 ± 16%     +31.7%      29239 ± 11%  interrupts.CPU55.RES:Rescheduling_interrupts
      3811           -13.3%       3303        interrupts.CPU56.CAL:Function_call_interrupts
    721916           -16.2%     605011        interrupts.CPU56.LOC:Local_timer_interrupts
    721636           -16.2%     604961        interrupts.CPU57.LOC:Local_timer_interrupts
      3841           -13.9%       3309        interrupts.CPU58.CAL:Function_call_interrupts
    721637           -16.1%     605154        interrupts.CPU58.LOC:Local_timer_interrupts
      3795           -12.7%       3314        interrupts.CPU59.CAL:Function_call_interrupts
    721926           -16.1%     605366        interrupts.CPU59.LOC:Local_timer_interrupts
      3841           -17.0%       3189 ±  7%  interrupts.CPU6.CAL:Function_call_interrupts
    721537           -16.1%     605025        interrupts.CPU6.LOC:Local_timer_interrupts
     21627 ± 16%     +36.9%      29599 ± 15%  interrupts.CPU6.RES:Rescheduling_interrupts
      3839           -13.5%       3319        interrupts.CPU60.CAL:Function_call_interrupts
    721689           -16.2%     604938        interrupts.CPU60.LOC:Local_timer_interrupts
     22724 ± 12%     +31.4%      29852 ± 13%  interrupts.CPU60.RES:Rescheduling_interrupts
    721538           -16.1%     605018        interrupts.CPU61.LOC:Local_timer_interrupts
     22521 ± 15%     +33.2%      29995 ± 19%  interrupts.CPU61.RES:Rescheduling_interrupts
      3795 ±  2%     -12.7%       3313        interrupts.CPU62.CAL:Function_call_interrupts
    721565           -16.2%     604946        interrupts.CPU62.LOC:Local_timer_interrupts
     22054 ± 17%     +38.7%      30598 ± 11%  interrupts.CPU62.RES:Rescheduling_interrupts
    721884           -16.2%     605030        interrupts.CPU63.LOC:Local_timer_interrupts
      3772 ±  3%     -12.3%       3309        interrupts.CPU64.CAL:Function_call_interrupts
    721981           -16.2%     605040        interrupts.CPU64.LOC:Local_timer_interrupts
     21437 ± 20%     +33.6%      28639 ± 19%  interrupts.CPU64.RES:Rescheduling_interrupts
      3779           -19.3%       3051 ± 14%  interrupts.CPU65.CAL:Function_call_interrupts
    721390           -16.1%     605132        interrupts.CPU65.LOC:Local_timer_interrupts
      3825           -13.5%       3309        interrupts.CPU66.CAL:Function_call_interrupts
    722064           -16.3%     604606        interrupts.CPU66.LOC:Local_timer_interrupts
      3819           -26.5%       2808 ± 24%  interrupts.CPU67.CAL:Function_call_interrupts
    721439           -16.2%     604744        interrupts.CPU67.LOC:Local_timer_interrupts
      3821           -13.5%       3306        interrupts.CPU68.CAL:Function_call_interrupts
    722060           -16.3%     604673        interrupts.CPU68.LOC:Local_timer_interrupts
      3821           -13.7%       3297        interrupts.CPU69.CAL:Function_call_interrupts
    722106           -16.3%     604542        interrupts.CPU69.LOC:Local_timer_interrupts
      3842           -14.2%       3297        interrupts.CPU7.CAL:Function_call_interrupts
    721363           -16.1%     605295        interrupts.CPU7.LOC:Local_timer_interrupts
     22221 ± 16%     +40.9%      31317 ± 19%  interrupts.CPU7.RES:Rescheduling_interrupts
      3826           -13.6%       3305        interrupts.CPU70.CAL:Function_call_interrupts
    721764           -16.2%     604627        interrupts.CPU70.LOC:Local_timer_interrupts
      3809           -13.5%       3295        interrupts.CPU71.CAL:Function_call_interrupts
    722080           -16.2%     604781        interrupts.CPU71.LOC:Local_timer_interrupts
      3818           -14.2%       3274 ±  2%  interrupts.CPU72.CAL:Function_call_interrupts
    721916           -16.2%     604918        interrupts.CPU72.LOC:Local_timer_interrupts
     27835 ± 14%     -17.6%      22945 ± 10%  interrupts.CPU72.RES:Rescheduling_interrupts
      3813           -13.2%       3308        interrupts.CPU73.CAL:Function_call_interrupts
    721747           -16.2%     604707        interrupts.CPU73.LOC:Local_timer_interrupts
    721746           -16.2%     604838        interrupts.CPU74.LOC:Local_timer_interrupts
      3832           -14.7%       3269 ±  2%  interrupts.CPU75.CAL:Function_call_interrupts
    721781           -16.2%     604619        interrupts.CPU75.LOC:Local_timer_interrupts
      3779           -12.4%       3310        interrupts.CPU76.CAL:Function_call_interrupts
    720970           -16.1%     604618        interrupts.CPU76.LOC:Local_timer_interrupts
      3809 ±  2%     -15.7%       3211 ±  4%  interrupts.CPU77.CAL:Function_call_interrupts
    722062           -16.3%     604188        interrupts.CPU77.LOC:Local_timer_interrupts
      3843           -14.6%       3284 ±  2%  interrupts.CPU78.CAL:Function_call_interrupts
    721715           -16.2%     604636        interrupts.CPU78.LOC:Local_timer_interrupts
      3840           -13.9%       3306        interrupts.CPU79.CAL:Function_call_interrupts
    721613           -16.2%     604526        interrupts.CPU79.LOC:Local_timer_interrupts
      3763 ±  4%     -11.5%       3331        interrupts.CPU8.CAL:Function_call_interrupts
    721367           -16.1%     605107        interrupts.CPU8.LOC:Local_timer_interrupts
     22471 ± 17%     +38.2%      31048 ±  9%  interrupts.CPU8.RES:Rescheduling_interrupts
      3830           -13.9%       3298        interrupts.CPU80.CAL:Function_call_interrupts
    721678           -16.2%     604714        interrupts.CPU80.LOC:Local_timer_interrupts
      3776 ±  3%     -12.5%       3306        interrupts.CPU81.CAL:Function_call_interrupts
    721263           -16.1%     604803        interrupts.CPU81.LOC:Local_timer_interrupts
      3837           -13.9%       3305        interrupts.CPU82.CAL:Function_call_interrupts
    721961           -16.2%     604781        interrupts.CPU82.LOC:Local_timer_interrupts
      3849           -14.8%       3280        interrupts.CPU83.CAL:Function_call_interrupts
    721888           -16.2%     604619        interrupts.CPU83.LOC:Local_timer_interrupts
      3802           -13.2%       3300        interrupts.CPU84.CAL:Function_call_interrupts
    721937           -16.2%     604653        interrupts.CPU84.LOC:Local_timer_interrupts
      3843           -13.8%       3313        interrupts.CPU85.CAL:Function_call_interrupts
    721834           -16.2%     604711        interrupts.CPU85.LOC:Local_timer_interrupts
      3839           -14.3%       3291        interrupts.CPU86.CAL:Function_call_interrupts
    721871           -16.2%     604809        interrupts.CPU86.LOC:Local_timer_interrupts
      3847           -14.6%       3287        interrupts.CPU87.CAL:Function_call_interrupts
    722149           -16.3%     604789        interrupts.CPU87.LOC:Local_timer_interrupts
      3838           -14.1%       3298        interrupts.CPU9.CAL:Function_call_interrupts
    721253           -16.2%     604595        interrupts.CPU9.LOC:Local_timer_interrupts
     22535 ± 19%     +36.1%      30680 ± 11%  interrupts.CPU9.RES:Rescheduling_interrupts
  63503101           -16.2%   53227032        interrupts.LOC:Local_timer_interrupts
    310.00 ±  3%     +11.0%     344.00 ±  7%  interrupts.TLB:TLB_shootdowns
     20431 ± 15%     -19.7%      16415 ±  4%  softirqs.CPU0.RCU
     34582 ±  2%     +17.5%      40639 ±  8%  softirqs.CPU0.SCHED
    133704           -12.9%     116517 ±  3%  softirqs.CPU0.TIMER
     20017 ± 16%     -18.6%      16300        softirqs.CPU1.RCU
     32010 ±  3%     +17.3%      37561 ±  8%  softirqs.CPU1.SCHED
    132385 ±  2%     -14.8%     112812        softirqs.CPU1.TIMER
     19743 ± 16%     -20.2%      15764 ±  3%  softirqs.CPU10.RCU
     30881 ±  3%     +20.6%      37253 ± 10%  softirqs.CPU10.SCHED
    130801 ±  2%      -8.5%     119711 ±  6%  softirqs.CPU10.TIMER
     30607 ±  2%     +20.4%      36850 ±  8%  softirqs.CPU11.SCHED
    133304 ±  2%     -11.9%     117463 ±  2%  softirqs.CPU11.TIMER
     30848           +20.1%      37052 ±  9%  softirqs.CPU12.SCHED
    131208           -11.5%     116174 ±  3%  softirqs.CPU12.TIMER
     22042 ± 17%     -28.7%      15719 ±  5%  softirqs.CPU13.RCU
     30520 ±  5%     +21.7%      37133 ± 11%  softirqs.CPU13.SCHED
    135598 ±  4%     -15.4%     114708 ±  2%  softirqs.CPU13.TIMER
     31132 ±  4%     +15.4%      35911 ± 10%  softirqs.CPU14.SCHED
    148384 ± 17%     -22.8%     114512        softirqs.CPU14.TIMER
     30303           +20.6%      36560 ± 10%  softirqs.CPU15.SCHED
    133852           -14.1%     115008        softirqs.CPU15.TIMER
     31199 ±  2%     +18.5%      36961 ±  8%  softirqs.CPU16.SCHED
    133767 ±  2%     -13.1%     116191        softirqs.CPU16.TIMER
     19872 ± 17%     -17.2%      16453 ±  2%  softirqs.CPU17.RCU
     30661 ±  2%     +19.2%      36554 ±  9%  softirqs.CPU17.SCHED
    133274 ±  2%     -15.1%     113122 ±  2%  softirqs.CPU17.TIMER
     20088 ± 15%     -17.5%      16582 ±  2%  softirqs.CPU18.RCU
     31180 ±  3%     +15.6%      36055 ±  9%  softirqs.CPU18.SCHED
    134796 ±  4%     -15.7%     113667        softirqs.CPU18.TIMER
     22481 ± 20%     -26.8%      16451 ±  2%  softirqs.CPU19.RCU
     30809 ±  2%     +19.5%      36811 ±  7%  softirqs.CPU19.SCHED
    132271 ±  2%     -12.4%     115843 ±  3%  softirqs.CPU19.TIMER
     19797 ± 16%     -17.5%      16326 ±  2%  softirqs.CPU2.RCU
     30922 ±  3%     +21.6%      37612 ±  8%  softirqs.CPU2.SCHED
     25248 ± 29%     -24.3%      19119 ± 24%  softirqs.CPU20.RCU
     29985 ±  2%     +22.1%      36608 ±  8%  softirqs.CPU20.SCHED
    128772 ±  2%     -10.9%     114692        softirqs.CPU20.TIMER
     19935 ± 17%     -19.2%      16110 ±  3%  softirqs.CPU21.RCU
     31495 ±  3%     +16.4%      36651 ±  7%  softirqs.CPU21.SCHED
    130837 ±  3%     -13.2%     113573 ±  2%  softirqs.CPU21.TIMER
     40257 ±  5%     -13.7%      34739 ±  7%  softirqs.CPU22.SCHED
    133177 ±  2%     -16.6%     111009 ±  3%  softirqs.CPU22.TIMER
     40524 ±  5%     -17.6%      33383 ±  9%  softirqs.CPU23.SCHED
    133547 ±  4%     -18.1%     109369        softirqs.CPU23.TIMER
     39849 ±  3%     -15.3%      33755 ±  9%  softirqs.CPU24.SCHED
    131526 ±  2%     -17.7%     108249 ±  2%  softirqs.CPU24.TIMER
     39996 ±  4%     -13.6%      34576 ±  6%  softirqs.CPU25.SCHED
    131627 ±  3%     -16.1%     110442 ±  3%  softirqs.CPU25.TIMER
     39898 ±  5%     -14.9%      33947 ±  7%  softirqs.CPU26.SCHED
    132681           -16.5%     110841 ±  4%  softirqs.CPU26.TIMER
     40079 ±  7%     -15.6%      33826 ±  6%  softirqs.CPU27.SCHED
    133577           -18.1%     109462 ±  2%  softirqs.CPU27.TIMER
     40228 ±  5%     -15.4%      34036 ±  6%  softirqs.CPU28.SCHED
    131075 ±  3%     -17.9%     107666 ±  2%  softirqs.CPU28.TIMER
     39312 ±  3%     -14.8%      33499 ±  8%  softirqs.CPU29.SCHED
    134423 ±  3%     -18.4%     109702 ±  3%  softirqs.CPU29.TIMER
     19384 ± 17%     -17.8%      15929        softirqs.CPU3.RCU
     30436 ±  3%     +21.2%      36897 ± 11%  softirqs.CPU3.SCHED
    132319 ±  3%     -13.4%     114525 ±  2%  softirqs.CPU3.TIMER
     22908 ± 16%     -22.4%      17781 ±  3%  softirqs.CPU30.RCU
     39762 ±  3%     -15.0%      33803 ±  8%  softirqs.CPU30.SCHED
    134269 ±  2%     -17.7%     110531 ±  2%  softirqs.CPU30.TIMER
     41024 ±  5%     -17.4%      33894 ±  7%  softirqs.CPU31.SCHED
    149024 ± 17%     -24.6%     112375 ±  3%  softirqs.CPU31.TIMER
     39978 ±  4%     -15.5%      33774 ±  7%  softirqs.CPU32.SCHED
    131148           -17.2%     108564 ±  3%  softirqs.CPU32.TIMER
     39979 ±  4%     -13.8%      34476 ±  9%  softirqs.CPU33.SCHED
    134094 ±  4%     -18.1%     109836 ±  2%  softirqs.CPU33.TIMER
     22786 ± 16%     -22.9%      17569 ±  4%  softirqs.CPU34.RCU
     40552 ±  4%     -17.3%      33554 ±  7%  softirqs.CPU34.SCHED
    131088 ±  2%     -17.0%     108798 ±  3%  softirqs.CPU34.TIMER
     39532 ±  3%     -14.1%      33963 ±  7%  softirqs.CPU35.SCHED
    132211 ±  2%     -15.9%     111137 ±  3%  softirqs.CPU35.TIMER
     38671 ±  4%     -13.2%      33557 ±  9%  softirqs.CPU36.SCHED
    147868 ± 17%     -27.0%     107982        softirqs.CPU36.TIMER
     23249 ± 15%     -22.1%      18100 ±  5%  softirqs.CPU37.RCU
     40190 ±  5%     -15.3%      34023 ±  7%  softirqs.CPU37.SCHED
    132884 ±  3%     -15.9%     111703 ±  2%  softirqs.CPU37.TIMER
     22745 ± 16%     -23.2%      17469 ±  4%  softirqs.CPU38.RCU
     40569 ±  5%     -16.3%      33950 ±  9%  softirqs.CPU38.SCHED
    135133           -18.3%     110441 ±  2%  softirqs.CPU38.TIMER
     39935 ±  5%     -15.3%      33825 ±  8%  softirqs.CPU39.SCHED
    133753 ±  2%     -17.5%     110412        softirqs.CPU39.TIMER
     30946 ±  4%     +17.7%      36409 ±  9%  softirqs.CPU4.SCHED
    130762 ±  2%     -13.6%     113024 ±  2%  softirqs.CPU4.TIMER
     40335 ±  3%     -16.4%      33703 ±  9%  softirqs.CPU40.SCHED
    130983 ±  2%     -15.6%     110597 ±  2%  softirqs.CPU40.TIMER
     40423 ±  5%     -17.1%      33525 ±  8%  softirqs.CPU41.SCHED
    132224 ±  4%     -18.0%     108363        softirqs.CPU41.TIMER
     40723 ±  4%     -17.3%      33682 ±  7%  softirqs.CPU42.SCHED
    135049           -17.8%     110952 ±  3%  softirqs.CPU42.TIMER
     39349 ±  3%     -14.8%      33536 ±  8%  softirqs.CPU43.SCHED
    134203 ±  2%     -17.6%     110610 ±  2%  softirqs.CPU43.TIMER
     17084 ± 18%     -18.0%      14000 ±  3%  softirqs.CPU44.RCU
     30946           +22.1%      37787 ±  9%  softirqs.CPU44.SCHED
    130568           -13.3%     113197 ±  3%  softirqs.CPU44.TIMER
     20252 ± 15%     -19.8%      16238 ±  2%  softirqs.CPU45.RCU
     31638 ±  4%     +16.3%      36780 ±  9%  softirqs.CPU45.SCHED
    132331 ±  2%     -14.9%     112550        softirqs.CPU45.TIMER
     24973 ± 13%     -16.0%      20983 ±  2%  softirqs.CPU46.RCU
     30862           +22.1%      37672 ±  6%  softirqs.CPU46.SCHED
    137074 ±  3%     -11.2%     121691 ±  4%  softirqs.CPU46.TIMER
     19750 ± 17%     -18.6%      16079 ±  2%  softirqs.CPU47.RCU
     30289 ±  3%     +21.4%      36762 ±  9%  softirqs.CPU47.SCHED
    130548 ±  3%     -12.7%     113914        softirqs.CPU47.TIMER
     19693 ± 16%     -17.0%      16336 ±  4%  softirqs.CPU48.RCU
     30593 ±  5%     +19.9%      36684 ±  9%  softirqs.CPU48.SCHED
    130499 ±  3%     -13.6%     112753 ±  2%  softirqs.CPU48.TIMER
     30877 ±  2%     +19.9%      37018 ±  9%  softirqs.CPU49.SCHED
    130875 ±  4%     -13.0%     113833        softirqs.CPU49.TIMER
     22365 ± 36%     -27.9%      16131        softirqs.CPU5.RCU
     30822           +20.2%      37048 ±  9%  softirqs.CPU5.SCHED
    130397 ±  3%     -11.8%     115024        softirqs.CPU5.TIMER
     22536 ± 37%     -26.9%      16472 ±  4%  softirqs.CPU50.RCU
     30543           +20.3%      36752 ±  9%  softirqs.CPU50.SCHED
    133918 ±  3%     -13.5%     115860 ±  4%  softirqs.CPU50.TIMER
    131702 ±  2%      -9.6%     118995 ±  6%  softirqs.CPU51.TIMER
     20176 ± 17%     -21.1%      15915 ±  3%  softirqs.CPU52.RCU
     30631 ±  3%     +22.2%      37419 ±  7%  softirqs.CPU52.SCHED
    131629           -13.5%     113828        softirqs.CPU52.TIMER
     31078           +21.4%      37736 ±  9%  softirqs.CPU53.SCHED
    133106 ±  3%     -14.2%     114257 ±  3%  softirqs.CPU53.TIMER
     30982 ±  4%     +19.3%      36962 ±  9%  softirqs.CPU54.SCHED
     25187 ± 31%     -24.8%      18932 ± 27%  softirqs.CPU55.RCU
     30622 ±  3%     +19.6%      36613 ±  9%  softirqs.CPU55.SCHED
     19796 ± 14%     -18.3%      16167 ±  3%  softirqs.CPU56.RCU
     30828           +18.8%      36619 ±  9%  softirqs.CPU56.SCHED
    130194 ±  2%     -12.1%     114503 ±  2%  softirqs.CPU56.TIMER
     30577 ±  5%     +21.1%      37016 ± 10%  softirqs.CPU57.SCHED
    147818 ± 17%     -24.6%     111515 ±  2%  softirqs.CPU57.TIMER
     25343 ± 33%     -36.6%      16078 ±  4%  softirqs.CPU58.RCU
     31181 ±  2%     +16.6%      36349 ± 10%  softirqs.CPU58.SCHED
    139070 ±  7%     -16.4%     116283 ±  2%  softirqs.CPU58.TIMER
     19741 ± 16%     -15.3%      16722 ±  5%  softirqs.CPU59.RCU
     30636 ±  2%     +20.1%      36788 ±  9%  softirqs.CPU59.SCHED
    133696           -14.0%     114933        softirqs.CPU59.TIMER
     30639 ±  2%     +19.3%      36549 ±  9%  softirqs.CPU6.SCHED
     31080           +19.0%      36975 ±  7%  softirqs.CPU60.SCHED
    133580 ±  3%     -13.5%     115606        softirqs.CPU60.TIMER
     19131 ± 16%     -16.9%      15898 ±  2%  softirqs.CPU61.RCU
     30495 ±  3%     +20.2%      36664 ± 10%  softirqs.CPU61.SCHED
    133103           -15.3%     112675        softirqs.CPU61.TIMER
     31019 ±  2%     +18.8%      36849 ±  8%  softirqs.CPU62.SCHED
    134432 ±  4%     -15.8%     113144        softirqs.CPU62.TIMER
     30882 ±  2%     +16.9%      36105 ±  8%  softirqs.CPU63.SCHED
    131772 ±  2%     -12.7%     115005 ±  3%  softirqs.CPU63.TIMER
     19316 ± 16%     -18.8%      15694 ±  4%  softirqs.CPU64.RCU
     30286 ±  2%     +20.5%      36497 ±  8%  softirqs.CPU64.SCHED
    128582 ±  2%     -10.1%     115656 ±  4%  softirqs.CPU64.TIMER
     19223 ± 17%     -18.1%      15749 ±  3%  softirqs.CPU65.RCU
     30985 ±  2%     +18.6%      36751 ±  8%  softirqs.CPU65.SCHED
    130355 ±  3%     -13.0%     113407 ±  2%  softirqs.CPU65.TIMER
     40027 ±  4%     -14.7%      34153 ±  7%  softirqs.CPU66.SCHED
    131990 ±  3%     -16.9%     109630 ±  3%  softirqs.CPU66.TIMER
     40103 ±  5%     -16.4%      33528 ±  7%  softirqs.CPU67.SCHED
    133065 ±  4%     -18.5%     108445        softirqs.CPU67.TIMER
     39282           -14.5%      33576 ±  9%  softirqs.CPU68.SCHED
    131993 ±  2%     -18.9%     107006 ±  2%  softirqs.CPU68.TIMER
    131342 ±  3%     -16.3%     109974 ±  3%  softirqs.CPU69.TIMER
     19684 ± 18%     -16.4%      16446 ±  4%  softirqs.CPU7.RCU
     30804 ±  2%     +19.7%      36877 ± 11%  softirqs.CPU7.SCHED
     39499 ±  4%     -14.1%      33939 ±  7%  softirqs.CPU70.SCHED
    132374           -17.3%     109508 ±  4%  softirqs.CPU70.TIMER
     39816 ±  4%     -13.6%      34387 ±  6%  softirqs.CPU71.SCHED
    133540           -18.0%     109519 ±  2%  softirqs.CPU71.TIMER
     40073 ±  4%     -15.8%      33726 ±  6%  softirqs.CPU72.SCHED
    132172 ±  4%     -18.5%     107744        softirqs.CPU72.TIMER
     39089 ±  3%     -14.1%      33596 ±  7%  softirqs.CPU73.SCHED
    131584           -16.4%     110040 ±  3%  softirqs.CPU73.TIMER
     40315 ±  4%     -16.5%      33655 ±  7%  softirqs.CPU74.SCHED
    133455           -17.6%     109941        softirqs.CPU74.TIMER
     40427 ±  5%     -16.7%      33659 ±  8%  softirqs.CPU75.SCHED
    137065 ±  5%     -18.6%     111601 ±  3%  softirqs.CPU75.TIMER
     39577 ±  3%     -14.0%      34031 ±  7%  softirqs.CPU76.SCHED
    130476           -16.6%     108755 ±  4%  softirqs.CPU76.TIMER
     40386 ±  5%     -14.9%      34356 ±  7%  softirqs.CPU77.SCHED
    134414 ±  4%     -18.8%     109199 ±  3%  softirqs.CPU77.TIMER
     40179 ±  5%     -16.2%      33656 ±  7%  softirqs.CPU78.SCHED
    131087 ±  2%     -17.4%     108250 ±  3%  softirqs.CPU78.TIMER
     39263 ±  3%     -14.2%      33686 ±  7%  softirqs.CPU79.SCHED
    130805 ±  2%     -16.3%     109502 ±  2%  softirqs.CPU79.TIMER
     19896 ± 16%     -19.7%      15987 ±  2%  softirqs.CPU8.RCU
     30563 ±  3%     +24.0%      37906 ±  7%  softirqs.CPU8.SCHED
    131375 ±  2%     -12.8%     114531        softirqs.CPU8.TIMER
     39276 ±  2%     -14.9%      33416 ±  9%  softirqs.CPU80.SCHED
    138042 ±  7%     -21.9%     107876 ±  2%  softirqs.CPU80.TIMER
     21626 ± 17%     -24.1%      16414 ±  4%  softirqs.CPU81.RCU
     40018 ±  4%     -15.6%      33781 ±  7%  softirqs.CPU81.SCHED
    134117 ±  4%     -16.8%     111583 ±  3%  softirqs.CPU81.TIMER
    134747           -18.0%     110540 ±  3%  softirqs.CPU82.TIMER
    133707 ±  2%     -17.6%     110191        softirqs.CPU83.TIMER
     40079 ±  4%     -16.3%      33556 ± 10%  softirqs.CPU84.SCHED
    130536 ±  2%     -15.8%     109959        softirqs.CPU84.TIMER
     40427 ±  5%     -16.9%      33585 ±  7%  softirqs.CPU85.SCHED
    131805 ±  4%     -18.4%     107549        softirqs.CPU85.TIMER
     40785 ±  5%     -17.5%      33639 ±  7%  softirqs.CPU86.SCHED
    134917 ±  2%     -18.1%     110473 ±  3%  softirqs.CPU86.TIMER
     39496 ±  3%     -15.7%      33280 ±  8%  softirqs.CPU87.SCHED
    135851 ±  5%     -19.3%     109698 ±  2%  softirqs.CPU87.TIMER
     30947 ±  2%     +20.1%      37173 ±  9%  softirqs.CPU9.SCHED
    133360 ±  3%     -14.3%     114339 ±  3%  softirqs.CPU9.TIMER
      4299 ±103%     -66.6%       1438 ±  9%  softirqs.NET_RX
   1788927 ± 16%     -15.2%    1516780 ±  4%  softirqs.RCU
  11741892           -15.5%    9927286        softirqs.TIMER





Disclaimer:
Results have been estimated based on internal Intel analysis and are provided
for informational purposes only. Any difference in system hardware or software
design or configuration may affect actual performance.


Thanks,
Rong Chen


--orO6xySwJI16pVnm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-5.0.0-rc4-00004-gcdaa8132"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 5.0.0-rc4 Kernel Configuration
#

#
# Compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
#
CONFIG_CC_IS_GCC=y
CONFIG_GCC_VERSION=70300
CONFIG_CLANG_VERSION=0
CONFIG_CC_HAS_ASM_GOTO=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
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
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_USELIB=y
CONFIG_AUDIT=y
CONFIG_HAVE_ARCH_AUDITSYSCALL=y
CONFIG_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_EFFECTIVE_AFF_MASK=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_MIGRATION=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_SIM=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_MSI_IRQ=y
CONFIG_GENERIC_MSI_IRQ_DOMAIN=y
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
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
# CONFIG_NO_HZ_IDLE is not set
CONFIG_NO_HZ_FULL=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_HAVE_SCHED_AVG_IRQ=y
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y
# CONFIG_PSI is not set
CONFIG_CPU_ISOLATION=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
CONFIG_TREE_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_NEED_SEGCBLIST=y
CONFIG_CONTEXT_TRACKING=y
# CONFIG_CONTEXT_TRACKING_FORCE is not set
CONFIG_RCU_NOCB_CPU=y
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_NUMA_BALANCING=y
CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
CONFIG_MEMCG_SWAP=y
CONFIG_MEMCG_SWAP_ENABLED=y
CONFIG_MEMCG_KMEM=y
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
CONFIG_CGROUP_WRITEBACK=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_RT_GROUP_SCHED=y
CONFIG_CGROUP_PIDS=y
CONFIG_CGROUP_RDMA=y
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_HUGETLB=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
CONFIG_CGROUP_DEVICE=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_BPF=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_SOCK_CGROUP_DATA=y
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_CHECKPOINT_RESTORE=y
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
CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
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
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_FUTEX_PI=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_ADVISE_SYSCALLS=y
CONFIG_MEMBARRIER=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_ABSOLUTE_PERCPU=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_BPF_SYSCALL=y
# CONFIG_BPF_JIT_ALWAYS_ON is not set
CONFIG_USERFAULTFD=y
CONFIG_ARCH_HAS_MEMBARRIER_SYNC_CORE=y
CONFIG_RSEQ=y
# CONFIG_DEBUG_RSEQ is not set
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
# CONFIG_PC104 is not set

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_SLUB_MEMCG_SYSFS_ON is not set
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_SLAB_MERGE_DEFAULT=y
# CONFIG_SLAB_FREELIST_RANDOM is not set
# CONFIG_SLAB_FREELIST_HARDENED is not set
CONFIG_SLUB_CPU_PARTIAL=y
CONFIG_SYSTEM_DATA_VERIFICATION=y
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
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
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
CONFIG_HAVE_INTEL_TXT=y
CONFIG_X86_64_SMP=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_CC_HAS_SANE_STACKPROTECTOR=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_X2APIC=y
CONFIG_X86_MPPARSE=y
# CONFIG_GOLDFISH is not set
CONFIG_RETPOLINE=y
# CONFIG_X86_RESCTRL is not set
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_NUMACHIP is not set
# CONFIG_X86_VSMP is not set
CONFIG_X86_UV=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_MID is not set
CONFIG_X86_INTEL_LPSS=y
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=y
# CONFIG_IOSF_MBI_DEBUG is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
CONFIG_PARAVIRT_XXL=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_PARAVIRT_SPINLOCKS=y
# CONFIG_QUEUED_LOCK_STAT is not set
CONFIG_XEN=y
CONFIG_XEN_PV=y
CONFIG_XEN_PV_SMP=y
CONFIG_XEN_DOM0=y
CONFIG_XEN_PVHVM=y
CONFIG_XEN_PVHVM_SMP=y
CONFIG_XEN_512GB=y
CONFIG_XEN_SAVE_RESTORE=y
# CONFIG_XEN_DEBUG_FS is not set
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
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_HYGON=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
# CONFIG_CALGARY_IOMMU is not set
CONFIG_MAXSMP=y
CONFIG_NR_CPUS_RANGE_BEGIN=8192
CONFIG_NR_CPUS_RANGE_END=8192
CONFIG_NR_CPUS_DEFAULT=8192
CONFIG_NR_CPUS=8192
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
CONFIG_SCHED_MC_PRIO=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
CONFIG_X86_MCELOG_LEGACY=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=m
CONFIG_X86_THERMAL_VECTOR=y

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
CONFIG_PERF_EVENTS_INTEL_RAPL=y
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
# CONFIG_PERF_EVENTS_AMD_POWER is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX64=y
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=m
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
# CONFIG_X86_5LEVEL is not set
CONFIG_X86_DIRECT_GBPAGES=y
# CONFIG_X86_CPA_STATISTICS is not set
CONFIG_ARCH_HAS_MEM_ENCRYPT=y
# CONFIG_AMD_MEM_ENCRYPT is not set
CONFIG_NUMA=y
CONFIG_AMD_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
# CONFIG_NUMA_EMU is not set
CONFIG_NODES_SHIFT=10
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_X86_PMEM_LEGACY_DEVICE=y
CONFIG_X86_PMEM_LEGACY=m
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
CONFIG_X86_INTEL_UMIP=y
CONFIG_X86_INTEL_MPX=y
CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS=y
CONFIG_EFI=y
CONFIG_EFI_STUB=y
# CONFIG_EFI_MIXED is not set
CONFIG_SECCOMP=y
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=y
CONFIG_HZ=1000
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
# CONFIG_KEXEC_FILE is not set
CONFIG_CRASH_DUMP=y
CONFIG_KEXEC_JUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
# CONFIG_RANDOMIZE_BASE is not set
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
CONFIG_BOOTPARAM_HOTPLUG_CPU0=y
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
# CONFIG_COMPAT_VDSO is not set
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_HAVE_LIVEPATCH=y
# CONFIG_LIVEPATCH is not set
CONFIG_ARCH_HAS_ADD_PAGES=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y
CONFIG_ARCH_ENABLE_THP_MIGRATION=y

#
# Power management and ACPI options
#
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_SUSPEND_SKIP_SYNC is not set
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
CONFIG_PM_TEST_SUSPEND=y
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_DPM_WATCHDOG is not set
# CONFIG_PM_TRACE_RTC is not set
CONFIG_PM_CLK=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
# CONFIG_ENERGY_MODEL is not set
CONFIG_ARCH_SUPPORTS_ACPI=y
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SPCR_TABLE=y
CONFIG_ACPI_LPIT=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
CONFIG_ACPI_EC_DEBUGFS=m
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=m
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_TAD is not set
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_CPPC_LIB=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_IPMI=m
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=m
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_DEBUG=y
CONFIG_ACPI_PCI_SLOT=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_MEMORY=y
CONFIG_ACPI_HOTPLUG_IOAPIC=y
CONFIG_ACPI_SBS=m
CONFIG_ACPI_HED=y
CONFIG_ACPI_CUSTOM_METHOD=m
CONFIG_ACPI_BGRT=y
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_ACPI_NFIT=m
# CONFIG_NFIT_SECURITY_DEBUG is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
CONFIG_ACPI_APEI_PCIEAER=y
CONFIG_ACPI_APEI_MEMORY_FAILURE=y
CONFIG_ACPI_APEI_EINJ=m
CONFIG_ACPI_APEI_ERST_DEBUG=y
# CONFIG_DPTF_POWER is not set
CONFIG_ACPI_WATCHDOG=y
CONFIG_ACPI_EXTLOG=m
CONFIG_ACPI_ADXL=y
# CONFIG_PMIC_OPREGION is not set
# CONFIG_ACPI_CONFIGFS is not set
CONFIG_X86_PM_TIMER=y
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_ATTR_SET=y
CONFIG_CPU_FREQ_GOV_COMMON=y
# CONFIG_CPU_FREQ_STAT is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y
# CONFIG_CPU_FREQ_GOV_SCHEDUTIL is not set

#
# CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
CONFIG_X86_PCC_CPUFREQ=m
CONFIG_X86_ACPI_CPUFREQ=m
CONFIG_X86_ACPI_CPUFREQ_CPB=y
CONFIG_X86_POWERNOW_K8=m
CONFIG_X86_AMD_FREQ_SENSITIVITY=m
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
CONFIG_X86_P4_CLOCKMOD=m

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=m

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_GOV_LADDER is not set
CONFIG_CPU_IDLE_GOV_MENU=y
CONFIG_INTEL_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_XEN=y
CONFIG_MMCONF_FAM10H=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_ISA_BUS is not set
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
# CONFIG_X86_SYSFB is not set

#
# Binary Emulations
#
CONFIG_IA32_EMULATION=y
# CONFIG_IA32_AOUT is not set
# CONFIG_X86_X32 is not set
CONFIG_COMPAT_32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_HAVE_GENERIC_GUP=y

#
# Firmware Drivers
#
CONFIG_EDD=m
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DMIID=y
CONFIG_DMI_SYSFS=y
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
CONFIG_ISCSI_IBFT_FIND=y
CONFIG_ISCSI_IBFT=m
# CONFIG_FW_CFG_SYSFS is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# EFI (Extensible Firmware Interface) Support
#
CONFIG_EFI_VARS=y
CONFIG_EFI_ESRT=y
CONFIG_EFI_VARS_PSTORE=y
CONFIG_EFI_VARS_PSTORE_DEFAULT_DISABLE=y
CONFIG_EFI_RUNTIME_MAP=y
# CONFIG_EFI_FAKE_MEMMAP is not set
CONFIG_EFI_RUNTIME_WRAPPERS=y
# CONFIG_EFI_BOOTLOADER_CONTROL is not set
# CONFIG_EFI_CAPSULE_LOADER is not set
# CONFIG_EFI_TEST is not set
# CONFIG_APPLE_PROPERTIES is not set
# CONFIG_RESET_ATTACK_MITIGATION is not set
CONFIG_UEFI_CPER=y
CONFIG_UEFI_CPER_X86=y

#
# Tegra firmware driver
#
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_IRQFD=y
CONFIG_HAVE_KVM_IRQ_ROUTING=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_KVM_VFIO=y
CONFIG_KVM_GENERIC_DIRTYLOG_READ_PROTECT=y
CONFIG_KVM_COMPAT=y
CONFIG_HAVE_KVM_IRQ_BYPASS=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=m
CONFIG_KVM_INTEL=m
CONFIG_KVM_AMD=m
CONFIG_KVM_MMU_AUDIT=y
CONFIG_VHOST_NET=m
# CONFIG_VHOST_SCSI is not set
# CONFIG_VHOST_VSOCK is not set
CONFIG_VHOST=m
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY is not set

#
# General architecture-dependent options
#
CONFIG_CRASH_CORE=y
CONFIG_KEXEC_CORE=y
CONFIG_HOTPLUG_SMT=y
CONFIG_OPROFILE=m
CONFIG_OPROFILE_EVENT_MULTIPLEX=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_KPROBES=y
CONFIG_JUMP_LABEL=y
# CONFIG_STATIC_KEYS_SELFTEST is not set
CONFIG_OPTPROBES=y
CONFIG_KPROBES_ON_FTRACE=y
CONFIG_UPROBES=y
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_KRETPROBES=y
CONFIG_USER_RETURN_NOTIFIER=y
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
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
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
CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS=y
CONFIG_ARCH_MMAP_RND_COMPAT_BITS=8
CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES=y
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
CONFIG_HAVE_RELIABLE_STACKTRACE=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y
CONFIG_COMPAT_32BIT_TIME=y
CONFIG_HAVE_ARCH_VMAP_STACK=y
CONFIG_VMAP_STACK=y
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_STRICT_MODULE_RWX=y
CONFIG_ARCH_HAS_REFCOUNT=y
# CONFIG_REFCOUNT_FULL is not set
CONFIG_HAVE_ARCH_PREL32_RELOCATIONS=y

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
CONFIG_MODULE_FORCE_LOAD=y
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
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
CONFIG_BLK_DEV_THROTTLING=y
# CONFIG_BLK_DEV_THROTTLING_LOW is not set
# CONFIG_BLK_CMDLINE_PARSER is not set
# CONFIG_BLK_WBT is not set
# CONFIG_BLK_CGROUP_IOLATENCY is not set
CONFIG_BLK_DEBUG_FS=y
CONFIG_BLK_DEBUG_FS_ZONED=y
# CONFIG_BLK_SED_OPAL is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_AIX_PARTITION is not set
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
CONFIG_MINIX_SUBPARTITION=y
CONFIG_SOLARIS_X86_PARTITION=y
CONFIG_UNIXWARE_DISKLABEL=y
# CONFIG_LDM_PARTITION is not set
CONFIG_SGI_PARTITION=y
# CONFIG_ULTRIX_PARTITION is not set
CONFIG_SUN_PARTITION=y
CONFIG_KARMA_PARTITION=y
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
# CONFIG_CMDLINE_PARTITION is not set
CONFIG_BLOCK_COMPAT=y
CONFIG_BLK_MQ_PCI=y
CONFIG_BLK_MQ_VIRTIO=y
CONFIG_BLK_PM=y

#
# IO Schedulers
#
CONFIG_MQ_IOSCHED_DEADLINE=y
CONFIG_MQ_IOSCHED_KYBER=y
# CONFIG_IOSCHED_BFQ is not set
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_PADATA=y
CONFIG_ASN1=y
CONFIG_INLINE_SPIN_UNLOCK_IRQ=y
CONFIG_INLINE_READ_UNLOCK=y
CONFIG_INLINE_READ_UNLOCK_IRQ=y
CONFIG_INLINE_WRITE_UNLOCK=y
CONFIG_INLINE_WRITE_UNLOCK_IRQ=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_MUTEX_SPIN_ON_OWNER=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_LOCK_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_QUEUED_RWLOCKS=y
CONFIG_ARCH_HAS_SYNC_CORE_BEFORE_USERMODE=y
CONFIG_ARCH_HAS_SYSCALL_WRAPPER=y
CONFIG_FREEZER=y

#
# Executable file formats
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_BINFMT_MISC=m
CONFIG_COREDUMP=y

#
# Memory Management options
#
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_HAVE_BOOTMEM_INFO_NODE=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE is not set
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_MEMORY_BALLOON=y
CONFIG_BALLOON_COMPACTION=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=m
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_ARCH_WANTS_THP_SWAP=y
CONFIG_THP_SWAP=y
CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
CONFIG_CLEANCACHE=y
CONFIG_FRONTSWAP=y
CONFIG_CMA=y
# CONFIG_CMA_DEBUG is not set
# CONFIG_CMA_DEBUGFS is not set
CONFIG_CMA_AREAS=7
# CONFIG_MEM_SOFT_DIRTY is not set
CONFIG_ZSWAP=y
CONFIG_ZPOOL=y
CONFIG_ZBUD=y
# CONFIG_Z3FOLD is not set
CONFIG_ZSMALLOC=y
# CONFIG_PGTABLE_MAPPING is not set
# CONFIG_ZSMALLOC_STAT is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
# CONFIG_DEFERRED_STRUCT_PAGE_INIT is not set
CONFIG_IDLE_PAGE_TRACKING=y
CONFIG_ARCH_HAS_ZONE_DEVICE=y
CONFIG_ZONE_DEVICE=y
CONFIG_ARCH_HAS_HMM=y
CONFIG_DEV_PAGEMAP_OPS=y
# CONFIG_HMM_MIRROR is not set
# CONFIG_DEVICE_PRIVATE is not set
# CONFIG_DEVICE_PUBLIC is not set
CONFIG_FRAME_VECTOR=y
CONFIG_ARCH_USES_HIGH_VMA_FLAGS=y
CONFIG_ARCH_HAS_PKEYS=y
# CONFIG_PERCPU_STATS is not set
# CONFIG_GUP_BENCHMARK is not set
CONFIG_ARCH_HAS_PTE_SPECIAL=y
CONFIG_NET=y
CONFIG_COMPAT_NETLINK_MESSAGES=y
CONFIG_NET_INGRESS=y
CONFIG_NET_EGRESS=y
CONFIG_SKB_EXTENSIONS=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=m
CONFIG_UNIX=y
CONFIG_UNIX_DIAG=m
# CONFIG_TLS is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
# CONFIG_XFRM_INTERFACE is not set
CONFIG_XFRM_SUB_POLICY=y
CONFIG_XFRM_MIGRATE=y
CONFIG_XFRM_STATISTICS=y
CONFIG_XFRM_IPCOMP=m
CONFIG_NET_KEY=m
CONFIG_NET_KEY_MIGRATE=y
# CONFIG_XDP_SOCKETS is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_IP_FIB_TRIE_STATS=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
CONFIG_NET_IPIP=m
CONFIG_NET_IPGRE_DEMUX=m
CONFIG_NET_IP_TUNNEL=m
CONFIG_NET_IPGRE=m
CONFIG_NET_IPGRE_BROADCAST=y
CONFIG_IP_MROUTE_COMMON=y
CONFIG_IP_MROUTE=y
CONFIG_IP_MROUTE_MULTIPLE_TABLES=y
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
CONFIG_SYN_COOKIES=y
CONFIG_NET_IPVTI=m
CONFIG_NET_UDP_TUNNEL=m
CONFIG_NET_FOU=m
CONFIG_NET_FOU_IP_TUNNELS=y
CONFIG_INET_AH=m
CONFIG_INET_ESP=m
# CONFIG_INET_ESP_OFFLOAD is not set
CONFIG_INET_IPCOMP=m
CONFIG_INET_XFRM_TUNNEL=m
CONFIG_INET_TUNNEL=m
CONFIG_INET_XFRM_MODE_TRANSPORT=m
CONFIG_INET_XFRM_MODE_TUNNEL=m
CONFIG_INET_XFRM_MODE_BEET=m
CONFIG_INET_DIAG=m
CONFIG_INET_TCP_DIAG=m
CONFIG_INET_UDP_DIAG=m
# CONFIG_INET_RAW_DIAG is not set
# CONFIG_INET_DIAG_DESTROY is not set
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=m
CONFIG_TCP_CONG_CUBIC=y
CONFIG_TCP_CONG_WESTWOOD=m
CONFIG_TCP_CONG_HTCP=m
CONFIG_TCP_CONG_HSTCP=m
CONFIG_TCP_CONG_HYBLA=m
CONFIG_TCP_CONG_VEGAS=m
# CONFIG_TCP_CONG_NV is not set
CONFIG_TCP_CONG_SCALABLE=m
CONFIG_TCP_CONG_LP=m
CONFIG_TCP_CONG_VENO=m
CONFIG_TCP_CONG_YEAH=m
CONFIG_TCP_CONG_ILLINOIS=m
# CONFIG_TCP_CONG_DCTCP is not set
# CONFIG_TCP_CONG_CDG is not set
# CONFIG_TCP_CONG_BBR is not set
CONFIG_DEFAULT_CUBIC=y
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_TCP_MD5SIG=y
CONFIG_IPV6=y
CONFIG_IPV6_ROUTER_PREF=y
CONFIG_IPV6_ROUTE_INFO=y
CONFIG_IPV6_OPTIMISTIC_DAD=y
CONFIG_INET6_AH=m
CONFIG_INET6_ESP=m
# CONFIG_INET6_ESP_OFFLOAD is not set
CONFIG_INET6_IPCOMP=m
CONFIG_IPV6_MIP6=m
# CONFIG_IPV6_ILA is not set
CONFIG_INET6_XFRM_TUNNEL=m
CONFIG_INET6_TUNNEL=m
CONFIG_INET6_XFRM_MODE_TRANSPORT=m
CONFIG_INET6_XFRM_MODE_TUNNEL=m
CONFIG_INET6_XFRM_MODE_BEET=m
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=m
CONFIG_IPV6_VTI=m
CONFIG_IPV6_SIT=m
CONFIG_IPV6_SIT_6RD=y
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=m
# CONFIG_IPV6_GRE is not set
CONFIG_IPV6_FOU=m
CONFIG_IPV6_FOU_TUNNEL=m
CONFIG_IPV6_MULTIPLE_TABLES=y
# CONFIG_IPV6_SUBTREES is not set
CONFIG_IPV6_MROUTE=y
CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y
CONFIG_IPV6_PIMSM_V2=y
CONFIG_IPV6_SEG6_LWTUNNEL=y
# CONFIG_IPV6_SEG6_HMAC is not set
CONFIG_IPV6_SEG6_BPF=y
CONFIG_NETLABEL=y
CONFIG_NETWORK_SECMARK=y
CONFIG_NET_PTP_CLASSIFY=y
CONFIG_NETWORK_PHY_TIMESTAMPING=y
CONFIG_NETFILTER=y
CONFIG_NETFILTER_ADVANCED=y
CONFIG_BRIDGE_NETFILTER=m

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_INGRESS=y
CONFIG_NETFILTER_NETLINK=m
CONFIG_NETFILTER_FAMILY_BRIDGE=y
CONFIG_NETFILTER_FAMILY_ARP=y
CONFIG_NETFILTER_NETLINK_ACCT=m
CONFIG_NETFILTER_NETLINK_QUEUE=m
CONFIG_NETFILTER_NETLINK_LOG=m
CONFIG_NETFILTER_NETLINK_OSF=m
CONFIG_NF_CONNTRACK=m
CONFIG_NF_LOG_COMMON=m
# CONFIG_NF_LOG_NETDEV is not set
CONFIG_NETFILTER_CONNCOUNT=m
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CONNTRACK_SECMARK=y
CONFIG_NF_CONNTRACK_ZONES=y
CONFIG_NF_CONNTRACK_PROCFS=y
CONFIG_NF_CONNTRACK_EVENTS=y
# CONFIG_NF_CONNTRACK_TIMEOUT is not set
CONFIG_NF_CONNTRACK_TIMESTAMP=y
CONFIG_NF_CONNTRACK_LABELS=y
CONFIG_NF_CT_PROTO_DCCP=y
CONFIG_NF_CT_PROTO_GRE=m
CONFIG_NF_CT_PROTO_SCTP=y
CONFIG_NF_CT_PROTO_UDPLITE=y
CONFIG_NF_CONNTRACK_AMANDA=m
CONFIG_NF_CONNTRACK_FTP=m
CONFIG_NF_CONNTRACK_H323=m
CONFIG_NF_CONNTRACK_IRC=m
CONFIG_NF_CONNTRACK_BROADCAST=m
CONFIG_NF_CONNTRACK_NETBIOS_NS=m
CONFIG_NF_CONNTRACK_SNMP=m
CONFIG_NF_CONNTRACK_PPTP=m
CONFIG_NF_CONNTRACK_SANE=m
CONFIG_NF_CONNTRACK_SIP=m
CONFIG_NF_CONNTRACK_TFTP=m
CONFIG_NF_CT_NETLINK=m
# CONFIG_NETFILTER_NETLINK_GLUE_CT is not set
CONFIG_NF_NAT=m
CONFIG_NF_NAT_NEEDED=y
CONFIG_NF_NAT_AMANDA=m
CONFIG_NF_NAT_FTP=m
CONFIG_NF_NAT_IRC=m
CONFIG_NF_NAT_SIP=m
CONFIG_NF_NAT_TFTP=m
CONFIG_NF_NAT_REDIRECT=y
CONFIG_NETFILTER_SYNPROXY=m
CONFIG_NF_TABLES=m
# CONFIG_NF_TABLES_SET is not set
# CONFIG_NF_TABLES_INET is not set
# CONFIG_NF_TABLES_NETDEV is not set
# CONFIG_NFT_NUMGEN is not set
CONFIG_NFT_CT=m
CONFIG_NFT_COUNTER=m
# CONFIG_NFT_CONNLIMIT is not set
CONFIG_NFT_LOG=m
CONFIG_NFT_LIMIT=m
# CONFIG_NFT_MASQ is not set
# CONFIG_NFT_REDIR is not set
CONFIG_NFT_NAT=m
# CONFIG_NFT_TUNNEL is not set
# CONFIG_NFT_OBJREF is not set
# CONFIG_NFT_QUEUE is not set
# CONFIG_NFT_QUOTA is not set
# CONFIG_NFT_REJECT is not set
CONFIG_NFT_COMPAT=m
CONFIG_NFT_HASH=m
# CONFIG_NFT_XFRM is not set
# CONFIG_NFT_SOCKET is not set
# CONFIG_NFT_OSF is not set
# CONFIG_NFT_TPROXY is not set
# CONFIG_NF_FLOW_TABLE is not set
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=m
CONFIG_NETFILTER_XT_CONNMARK=m
CONFIG_NETFILTER_XT_SET=m

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_AUDIT=m
CONFIG_NETFILTER_XT_TARGET_CHECKSUM=m
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=m
CONFIG_NETFILTER_XT_TARGET_CONNMARK=m
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=m
CONFIG_NETFILTER_XT_TARGET_CT=m
CONFIG_NETFILTER_XT_TARGET_DSCP=m
CONFIG_NETFILTER_XT_TARGET_HL=m
CONFIG_NETFILTER_XT_TARGET_HMARK=m
CONFIG_NETFILTER_XT_TARGET_IDLETIMER=m
CONFIG_NETFILTER_XT_TARGET_LED=m
CONFIG_NETFILTER_XT_TARGET_LOG=m
CONFIG_NETFILTER_XT_TARGET_MARK=m
CONFIG_NETFILTER_XT_NAT=m
CONFIG_NETFILTER_XT_TARGET_NETMAP=m
CONFIG_NETFILTER_XT_TARGET_NFLOG=m
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
CONFIG_NETFILTER_XT_TARGET_RATEEST=m
CONFIG_NETFILTER_XT_TARGET_REDIRECT=m
CONFIG_NETFILTER_XT_TARGET_TEE=m
CONFIG_NETFILTER_XT_TARGET_TPROXY=m
CONFIG_NETFILTER_XT_TARGET_TRACE=m
CONFIG_NETFILTER_XT_TARGET_SECMARK=m
CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=m
CONFIG_NETFILTER_XT_MATCH_BPF=m
# CONFIG_NETFILTER_XT_MATCH_CGROUP is not set
CONFIG_NETFILTER_XT_MATCH_CLUSTER=m
CONFIG_NETFILTER_XT_MATCH_COMMENT=m
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=m
CONFIG_NETFILTER_XT_MATCH_CONNLABEL=m
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=m
CONFIG_NETFILTER_XT_MATCH_CONNMARK=m
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=m
CONFIG_NETFILTER_XT_MATCH_CPU=m
CONFIG_NETFILTER_XT_MATCH_DCCP=m
CONFIG_NETFILTER_XT_MATCH_DEVGROUP=m
CONFIG_NETFILTER_XT_MATCH_DSCP=m
CONFIG_NETFILTER_XT_MATCH_ECN=m
CONFIG_NETFILTER_XT_MATCH_ESP=m
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=m
CONFIG_NETFILTER_XT_MATCH_HELPER=m
CONFIG_NETFILTER_XT_MATCH_HL=m
# CONFIG_NETFILTER_XT_MATCH_IPCOMP is not set
CONFIG_NETFILTER_XT_MATCH_IPRANGE=m
CONFIG_NETFILTER_XT_MATCH_IPVS=m
CONFIG_NETFILTER_XT_MATCH_L2TP=m
CONFIG_NETFILTER_XT_MATCH_LENGTH=m
CONFIG_NETFILTER_XT_MATCH_LIMIT=m
CONFIG_NETFILTER_XT_MATCH_MAC=m
CONFIG_NETFILTER_XT_MATCH_MARK=m
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=m
CONFIG_NETFILTER_XT_MATCH_NFACCT=m
CONFIG_NETFILTER_XT_MATCH_OSF=m
CONFIG_NETFILTER_XT_MATCH_OWNER=m
CONFIG_NETFILTER_XT_MATCH_POLICY=m
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=m
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=m
CONFIG_NETFILTER_XT_MATCH_QUOTA=m
CONFIG_NETFILTER_XT_MATCH_RATEEST=m
CONFIG_NETFILTER_XT_MATCH_REALM=m
CONFIG_NETFILTER_XT_MATCH_RECENT=m
CONFIG_NETFILTER_XT_MATCH_SCTP=m
# CONFIG_NETFILTER_XT_MATCH_SOCKET is not set
CONFIG_NETFILTER_XT_MATCH_STATE=m
CONFIG_NETFILTER_XT_MATCH_STATISTIC=m
CONFIG_NETFILTER_XT_MATCH_STRING=m
CONFIG_NETFILTER_XT_MATCH_TCPMSS=m
CONFIG_NETFILTER_XT_MATCH_TIME=m
CONFIG_NETFILTER_XT_MATCH_U32=m
CONFIG_IP_SET=m
CONFIG_IP_SET_MAX=256
CONFIG_IP_SET_BITMAP_IP=m
CONFIG_IP_SET_BITMAP_IPMAC=m
CONFIG_IP_SET_BITMAP_PORT=m
CONFIG_IP_SET_HASH_IP=m
# CONFIG_IP_SET_HASH_IPMARK is not set
CONFIG_IP_SET_HASH_IPPORT=m
CONFIG_IP_SET_HASH_IPPORTIP=m
CONFIG_IP_SET_HASH_IPPORTNET=m
# CONFIG_IP_SET_HASH_IPMAC is not set
# CONFIG_IP_SET_HASH_MAC is not set
# CONFIG_IP_SET_HASH_NETPORTNET is not set
CONFIG_IP_SET_HASH_NET=m
# CONFIG_IP_SET_HASH_NETNET is not set
CONFIG_IP_SET_HASH_NETPORT=m
CONFIG_IP_SET_HASH_NETIFACE=m
CONFIG_IP_SET_LIST_SET=m
CONFIG_IP_VS=m
CONFIG_IP_VS_IPV6=y
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y
CONFIG_IP_VS_PROTO_SCTP=y

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=m
CONFIG_IP_VS_WRR=m
CONFIG_IP_VS_LC=m
CONFIG_IP_VS_WLC=m
# CONFIG_IP_VS_FO is not set
# CONFIG_IP_VS_OVF is not set
CONFIG_IP_VS_LBLC=m
CONFIG_IP_VS_LBLCR=m
CONFIG_IP_VS_DH=m
CONFIG_IP_VS_SH=m
# CONFIG_IP_VS_MH is not set
CONFIG_IP_VS_SED=m
CONFIG_IP_VS_NQ=m

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
CONFIG_IP_VS_FTP=m
CONFIG_IP_VS_NFCT=y
CONFIG_IP_VS_PE_SIP=m

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=m
# CONFIG_NF_SOCKET_IPV4 is not set
CONFIG_NF_TPROXY_IPV4=m
# CONFIG_NF_TABLES_IPV4 is not set
# CONFIG_NF_TABLES_ARP is not set
CONFIG_NF_DUP_IPV4=m
# CONFIG_NF_LOG_ARP is not set
CONFIG_NF_LOG_IPV4=m
CONFIG_NF_REJECT_IPV4=m
CONFIG_NF_NAT_IPV4=m
CONFIG_NF_NAT_MASQUERADE_IPV4=y
CONFIG_NF_NAT_SNMP_BASIC=m
CONFIG_NF_NAT_PPTP=m
CONFIG_NF_NAT_H323=m
CONFIG_IP_NF_IPTABLES=m
CONFIG_IP_NF_MATCH_AH=m
CONFIG_IP_NF_MATCH_ECN=m
CONFIG_IP_NF_MATCH_RPFILTER=m
CONFIG_IP_NF_MATCH_TTL=m
CONFIG_IP_NF_FILTER=m
CONFIG_IP_NF_TARGET_REJECT=m
CONFIG_IP_NF_TARGET_SYNPROXY=m
CONFIG_IP_NF_NAT=m
CONFIG_IP_NF_TARGET_MASQUERADE=m
CONFIG_IP_NF_TARGET_NETMAP=m
CONFIG_IP_NF_TARGET_REDIRECT=m
CONFIG_IP_NF_MANGLE=m
CONFIG_IP_NF_TARGET_CLUSTERIP=m
CONFIG_IP_NF_TARGET_ECN=m
CONFIG_IP_NF_TARGET_TTL=m
CONFIG_IP_NF_RAW=m
CONFIG_IP_NF_SECURITY=m
CONFIG_IP_NF_ARPTABLES=m
CONFIG_IP_NF_ARPFILTER=m
CONFIG_IP_NF_ARP_MANGLE=m

#
# IPv6: Netfilter Configuration
#
# CONFIG_NF_SOCKET_IPV6 is not set
CONFIG_NF_TPROXY_IPV6=m
# CONFIG_NF_TABLES_IPV6 is not set
CONFIG_NF_DUP_IPV6=m
CONFIG_NF_REJECT_IPV6=m
CONFIG_NF_LOG_IPV6=m
CONFIG_NF_NAT_IPV6=m
CONFIG_IP6_NF_IPTABLES=m
CONFIG_IP6_NF_MATCH_AH=m
CONFIG_IP6_NF_MATCH_EUI64=m
CONFIG_IP6_NF_MATCH_FRAG=m
CONFIG_IP6_NF_MATCH_OPTS=m
CONFIG_IP6_NF_MATCH_HL=m
CONFIG_IP6_NF_MATCH_IPV6HEADER=m
CONFIG_IP6_NF_MATCH_MH=m
CONFIG_IP6_NF_MATCH_RPFILTER=m
CONFIG_IP6_NF_MATCH_RT=m
# CONFIG_IP6_NF_MATCH_SRH is not set
CONFIG_IP6_NF_TARGET_HL=m
CONFIG_IP6_NF_FILTER=m
CONFIG_IP6_NF_TARGET_REJECT=m
CONFIG_IP6_NF_TARGET_SYNPROXY=m
CONFIG_IP6_NF_MANGLE=m
CONFIG_IP6_NF_RAW=m
CONFIG_IP6_NF_SECURITY=m
# CONFIG_IP6_NF_NAT is not set
CONFIG_NF_DEFRAG_IPV6=m
# CONFIG_NF_TABLES_BRIDGE is not set
CONFIG_BRIDGE_NF_EBTABLES=m
CONFIG_BRIDGE_EBT_BROUTE=m
CONFIG_BRIDGE_EBT_T_FILTER=m
CONFIG_BRIDGE_EBT_T_NAT=m
CONFIG_BRIDGE_EBT_802_3=m
CONFIG_BRIDGE_EBT_AMONG=m
CONFIG_BRIDGE_EBT_ARP=m
CONFIG_BRIDGE_EBT_IP=m
CONFIG_BRIDGE_EBT_IP6=m
CONFIG_BRIDGE_EBT_LIMIT=m
CONFIG_BRIDGE_EBT_MARK=m
CONFIG_BRIDGE_EBT_PKTTYPE=m
CONFIG_BRIDGE_EBT_STP=m
CONFIG_BRIDGE_EBT_VLAN=m
CONFIG_BRIDGE_EBT_ARPREPLY=m
CONFIG_BRIDGE_EBT_DNAT=m
CONFIG_BRIDGE_EBT_MARK_T=m
CONFIG_BRIDGE_EBT_REDIRECT=m
CONFIG_BRIDGE_EBT_SNAT=m
CONFIG_BRIDGE_EBT_LOG=m
CONFIG_BRIDGE_EBT_NFLOG=m
# CONFIG_BPFILTER is not set
CONFIG_IP_DCCP=m
CONFIG_INET_DCCP_DIAG=m

#
# DCCP CCIDs Configuration
#
# CONFIG_IP_DCCP_CCID2_DEBUG is not set
CONFIG_IP_DCCP_CCID3=y
# CONFIG_IP_DCCP_CCID3_DEBUG is not set
CONFIG_IP_DCCP_TFRC_LIB=y

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
CONFIG_IP_SCTP=m
# CONFIG_SCTP_DBG_OBJCNT is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
CONFIG_SCTP_COOKIE_HMAC_MD5=y
CONFIG_SCTP_COOKIE_HMAC_SHA1=y
CONFIG_INET_SCTP_DIAG=m
# CONFIG_RDS is not set
CONFIG_TIPC=m
CONFIG_TIPC_MEDIA_UDP=y
CONFIG_TIPC_DIAG=m
CONFIG_ATM=m
CONFIG_ATM_CLIP=m
# CONFIG_ATM_CLIP_NO_ICMP is not set
CONFIG_ATM_LANE=m
# CONFIG_ATM_MPOA is not set
CONFIG_ATM_BR2684=m
# CONFIG_ATM_BR2684_IPFILTER is not set
CONFIG_L2TP=m
CONFIG_L2TP_DEBUGFS=m
CONFIG_L2TP_V3=y
CONFIG_L2TP_IP=m
CONFIG_L2TP_ETH=m
CONFIG_STP=m
CONFIG_GARP=m
CONFIG_MRP=m
CONFIG_BRIDGE=m
CONFIG_BRIDGE_IGMP_SNOOPING=y
CONFIG_BRIDGE_VLAN_FILTERING=y
CONFIG_HAVE_NET_DSA=y
# CONFIG_NET_DSA is not set
CONFIG_VLAN_8021Q=m
CONFIG_VLAN_8021Q_GVRP=y
CONFIG_VLAN_8021Q_MVRP=y
# CONFIG_DECNET is not set
CONFIG_LLC=m
# CONFIG_LLC2 is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_6LOWPAN is not set
CONFIG_IEEE802154=m
# CONFIG_IEEE802154_NL802154_EXPERIMENTAL is not set
CONFIG_IEEE802154_SOCKET=m
CONFIG_MAC802154=m
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=m
CONFIG_NET_SCH_HTB=m
CONFIG_NET_SCH_HFSC=m
CONFIG_NET_SCH_ATM=m
CONFIG_NET_SCH_PRIO=m
CONFIG_NET_SCH_MULTIQ=m
CONFIG_NET_SCH_RED=m
CONFIG_NET_SCH_SFB=m
CONFIG_NET_SCH_SFQ=m
CONFIG_NET_SCH_TEQL=m
CONFIG_NET_SCH_TBF=m
# CONFIG_NET_SCH_CBS is not set
# CONFIG_NET_SCH_ETF is not set
# CONFIG_NET_SCH_TAPRIO is not set
CONFIG_NET_SCH_GRED=m
CONFIG_NET_SCH_DSMARK=m
CONFIG_NET_SCH_NETEM=m
CONFIG_NET_SCH_DRR=m
CONFIG_NET_SCH_MQPRIO=m
# CONFIG_NET_SCH_SKBPRIO is not set
CONFIG_NET_SCH_CHOKE=m
CONFIG_NET_SCH_QFQ=m
CONFIG_NET_SCH_CODEL=m
CONFIG_NET_SCH_FQ_CODEL=m
# CONFIG_NET_SCH_CAKE is not set
# CONFIG_NET_SCH_FQ is not set
# CONFIG_NET_SCH_HHF is not set
# CONFIG_NET_SCH_PIE is not set
CONFIG_NET_SCH_INGRESS=m
CONFIG_NET_SCH_PLUG=m
# CONFIG_NET_SCH_DEFAULT is not set

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=m
CONFIG_NET_CLS_TCINDEX=m
CONFIG_NET_CLS_ROUTE4=m
CONFIG_NET_CLS_FW=m
CONFIG_NET_CLS_U32=m
CONFIG_CLS_U32_PERF=y
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=m
CONFIG_NET_CLS_RSVP6=m
CONFIG_NET_CLS_FLOW=m
CONFIG_NET_CLS_CGROUP=y
CONFIG_NET_CLS_BPF=m
# CONFIG_NET_CLS_FLOWER is not set
# CONFIG_NET_CLS_MATCHALL is not set
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=m
CONFIG_NET_EMATCH_NBYTE=m
CONFIG_NET_EMATCH_U32=m
CONFIG_NET_EMATCH_META=m
CONFIG_NET_EMATCH_TEXT=m
# CONFIG_NET_EMATCH_CANID is not set
CONFIG_NET_EMATCH_IPSET=m
# CONFIG_NET_EMATCH_IPT is not set
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=m
CONFIG_NET_ACT_GACT=m
CONFIG_GACT_PROB=y
CONFIG_NET_ACT_MIRRED=m
# CONFIG_NET_ACT_SAMPLE is not set
CONFIG_NET_ACT_IPT=m
CONFIG_NET_ACT_NAT=m
CONFIG_NET_ACT_PEDIT=m
CONFIG_NET_ACT_SIMP=m
CONFIG_NET_ACT_SKBEDIT=m
CONFIG_NET_ACT_CSUM=m
# CONFIG_NET_ACT_VLAN is not set
# CONFIG_NET_ACT_BPF is not set
# CONFIG_NET_ACT_CONNMARK is not set
# CONFIG_NET_ACT_SKBMOD is not set
# CONFIG_NET_ACT_IFE is not set
# CONFIG_NET_ACT_TUNNEL_KEY is not set
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=m
# CONFIG_BATMAN_ADV is not set
CONFIG_OPENVSWITCH=m
CONFIG_OPENVSWITCH_GRE=m
CONFIG_OPENVSWITCH_VXLAN=m
CONFIG_VSOCKETS=m
CONFIG_VSOCKETS_DIAG=m
CONFIG_VMWARE_VMCI_VSOCKETS=m
# CONFIG_VIRTIO_VSOCKETS is not set
# CONFIG_HYPERV_VSOCKETS is not set
CONFIG_NETLINK_DIAG=m
CONFIG_MPLS=y
CONFIG_NET_MPLS_GSO=m
# CONFIG_MPLS_ROUTING is not set
CONFIG_NET_NSH=m
# CONFIG_HSR is not set
# CONFIG_NET_SWITCHDEV is not set
CONFIG_NET_L3_MASTER_DEV=y
# CONFIG_NET_NCSI is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_CGROUP_NET_PRIO is not set
CONFIG_CGROUP_NET_CLASSID=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_BPF_JIT=y
CONFIG_BPF_STREAM_PARSER=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
CONFIG_NET_PKTGEN=m
CONFIG_NET_DROP_MONITOR=y
# CONFIG_HAMRADIO is not set
CONFIG_CAN=m
CONFIG_CAN_RAW=m
CONFIG_CAN_BCM=m
CONFIG_CAN_GW=m

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=m
# CONFIG_CAN_VXCAN is not set
# CONFIG_CAN_SLCAN is not set
CONFIG_CAN_DEV=m
CONFIG_CAN_CALC_BITTIMING=y
# CONFIG_CAN_C_CAN is not set
# CONFIG_CAN_CC770 is not set
# CONFIG_CAN_IFI_CANFD is not set
# CONFIG_CAN_M_CAN is not set
# CONFIG_CAN_PEAK_PCIEFD is not set
# CONFIG_CAN_SJA1000 is not set
# CONFIG_CAN_SOFTING is not set

#
# CAN SPI interfaces
#
# CONFIG_CAN_HI311X is not set
# CONFIG_CAN_MCP251X is not set

#
# CAN USB interfaces
#
# CONFIG_CAN_8DEV_USB is not set
# CONFIG_CAN_EMS_USB is not set
# CONFIG_CAN_ESD_USB2 is not set
# CONFIG_CAN_GS_USB is not set
# CONFIG_CAN_KVASER_USB is not set
# CONFIG_CAN_MCBA_USB is not set
# CONFIG_CAN_PEAK_USB is not set
# CONFIG_CAN_UCAN is not set
# CONFIG_CAN_DEBUG_DEVICES is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
# CONFIG_AF_KCM is not set
CONFIG_STREAM_PARSER=y
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_PRIV=y
CONFIG_CFG80211=m
# CONFIG_NL80211_TESTMODE is not set
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
# CONFIG_CFG80211_CERTIFICATION_ONUS is not set
CONFIG_CFG80211_REQUIRE_SIGNED_REGDB=y
CONFIG_CFG80211_USE_KERNEL_REGDB_KEYS=y
CONFIG_CFG80211_DEFAULT_PS=y
# CONFIG_CFG80211_DEBUGFS is not set
CONFIG_CFG80211_CRDA_SUPPORT=y
CONFIG_CFG80211_WEXT=y
CONFIG_LIB80211=m
# CONFIG_LIB80211_DEBUG is not set
CONFIG_MAC80211=m
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
CONFIG_MAC80211_MESH=y
CONFIG_MAC80211_LEDS=y
CONFIG_MAC80211_DEBUGFS=y
# CONFIG_MAC80211_MESSAGE_TRACING is not set
# CONFIG_MAC80211_DEBUG_MENU is not set
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
CONFIG_RFKILL=m
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
# CONFIG_RFKILL_GPIO is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_XEN is not set
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
# CONFIG_CEPH_LIB is not set
# CONFIG_NFC is not set
# CONFIG_PSAMPLE is not set
# CONFIG_NET_IFE is not set
CONFIG_LWTUNNEL=y
CONFIG_LWTUNNEL_BPF=y
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
CONFIG_NET_SOCK_MSG=y
# CONFIG_NET_DEVLINK is not set
CONFIG_MAY_USE_DEVLINK=y
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
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI_PCIE=y
CONFIG_PCIEAER=y
CONFIG_PCIEAER_INJECT=m
CONFIG_PCIE_ECRC=y
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
CONFIG_PCIEASPM_DEFAULT=y
# CONFIG_PCIEASPM_POWERSAVE is not set
# CONFIG_PCIEASPM_POWER_SUPERSAVE is not set
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_PCIE_PME=y
# CONFIG_PCIE_DPC is not set
# CONFIG_PCIE_PTM is not set
CONFIG_PCI_MSI=y
CONFIG_PCI_MSI_IRQ_DOMAIN=y
CONFIG_PCI_QUIRKS=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=y
# CONFIG_PCI_PF_STUB is not set
# CONFIG_XEN_PCIDEV_FRONTEND is not set
CONFIG_PCI_ATS=y
CONFIG_PCI_LOCKLESS_CONFIG=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
# CONFIG_PCI_P2PDMA is not set
CONFIG_PCI_LABEL=y
# CONFIG_PCI_HYPERV is not set
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_ACPI=y
CONFIG_HOTPLUG_PCI_ACPI_IBM=m
# CONFIG_HOTPLUG_PCI_CPCI is not set
# CONFIG_HOTPLUG_PCI_SHPC is not set

#
# PCI controller drivers
#

#
# Cadence PCIe controllers support
#
# CONFIG_VMD is not set

#
# DesignWare PCI Core Support
#
# CONFIG_PCIE_DW_PLAT_HOST is not set
# CONFIG_PCI_MESON is not set

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
CONFIG_YENTA=m
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
# CONFIG_RAPIDIO is not set

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER=y
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y

#
# Firmware loader
#
CONFIG_FW_LOADER=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
CONFIG_ALLOW_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
# CONFIG_TEST_ASYNC_DRIVER_PROBE is not set
CONFIG_SYS_HYPERVISOR=y
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_GENERIC_CPU_VULNERABILITIES=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_DMA_SHARED_BUFFER=y
# CONFIG_DMA_FENCE_TRACE is not set
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=200
CONFIG_CMA_SIZE_SEL_MBYTES=y
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8

#
# Bus devices
#
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
# CONFIG_GNSS is not set
CONFIG_MTD=m
# CONFIG_MTD_TESTS is not set
# CONFIG_MTD_CMDLINE_PARTS is not set
# CONFIG_MTD_AR7_PARTS is not set

#
# Partition parsers
#
# CONFIG_MTD_REDBOOT_PARTS is not set

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=m
CONFIG_MTD_BLOCK=m
# CONFIG_MTD_BLOCK_RO is not set
# CONFIG_FTL is not set
# CONFIG_NFTL is not set
# CONFIG_INFTL is not set
# CONFIG_RFD_FTL is not set
# CONFIG_SSFDC is not set
# CONFIG_SM_FTL is not set
# CONFIG_MTD_OOPS is not set
# CONFIG_MTD_SWAP is not set
# CONFIG_MTD_PARTITIONED_MASTER is not set

#
# RAM/ROM/Flash chip drivers
#
# CONFIG_MTD_CFI is not set
# CONFIG_MTD_JEDECPROBE is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_RAM is not set
# CONFIG_MTD_ROM is not set
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
# CONFIG_MTD_INTEL_VR_NOR is not set
# CONFIG_MTD_PLATRAM is not set

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
# CONFIG_MTD_DATAFLASH is not set
# CONFIG_MTD_MCHP23K256 is not set
# CONFIG_MTD_SST25L is not set
# CONFIG_MTD_SLRAM is not set
# CONFIG_MTD_PHRAM is not set
# CONFIG_MTD_MTDRAM is not set
# CONFIG_MTD_BLOCK2MTD is not set

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
# CONFIG_MTD_ONENAND is not set
# CONFIG_MTD_NAND is not set
# CONFIG_MTD_SPI_NAND is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
# CONFIG_MTD_LPDDR is not set
# CONFIG_MTD_SPI_NOR is not set
CONFIG_MTD_UBI=m
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
# CONFIG_MTD_UBI_GLUEBI is not set
# CONFIG_MTD_UBI_BLOCK is not set
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=m
CONFIG_PARPORT_PC=m
CONFIG_PARPORT_SERIAL=m
# CONFIG_PARPORT_PC_FIFO is not set
# CONFIG_PARPORT_PC_SUPERIO is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_NULL_BLK=m
CONFIG_BLK_DEV_NULL_BLK_FAULT_INJECTION=y
CONFIG_BLK_DEV_FD=m
CONFIG_CDROM=m
# CONFIG_PARIDE is not set
CONFIG_BLK_DEV_PCIESSD_MTIP32XX=m
# CONFIG_ZRAM is not set
# CONFIG_BLK_DEV_UMEM is not set
CONFIG_BLK_DEV_LOOP=m
CONFIG_BLK_DEV_LOOP_MIN_COUNT=0
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
CONFIG_BLK_DEV_NBD=m
# CONFIG_BLK_DEV_SKD is not set
CONFIG_BLK_DEV_SX8=m
CONFIG_BLK_DEV_RAM=m
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=16384
CONFIG_CDROM_PKTCDVD=m
CONFIG_CDROM_PKTCDVD_BUFFERS=8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
CONFIG_ATA_OVER_ETH=m
CONFIG_XEN_BLKDEV_FRONTEND=m
# CONFIG_XEN_BLKDEV_BACKEND is not set
CONFIG_VIRTIO_BLK=y
# CONFIG_VIRTIO_BLK_SCSI is not set
# CONFIG_BLK_DEV_RBD is not set
CONFIG_BLK_DEV_RSXX=m

#
# NVME Support
#
CONFIG_NVME_CORE=m
CONFIG_BLK_DEV_NVME=m
CONFIG_NVME_MULTIPATH=y
CONFIG_NVME_FABRICS=m
# CONFIG_NVME_FC is not set
# CONFIG_NVME_TCP is not set
CONFIG_NVME_TARGET=m
CONFIG_NVME_TARGET_LOOP=m
# CONFIG_NVME_TARGET_FC is not set
# CONFIG_NVME_TARGET_TCP is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=m
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
CONFIG_SGI_IOC4=m
CONFIG_TIFM_CORE=m
CONFIG_TIFM_7XX1=m
# CONFIG_ICS932S401 is not set
CONFIG_ENCLOSURE_SERVICES=m
CONFIG_SGI_XP=m
CONFIG_HP_ILO=m
CONFIG_SGI_GRU=m
# CONFIG_SGI_GRU_DEBUG is not set
CONFIG_APDS9802ALS=m
CONFIG_ISL29003=m
CONFIG_ISL29020=m
CONFIG_SENSORS_TSL2550=m
CONFIG_SENSORS_BH1770=m
CONFIG_SENSORS_APDS990X=m
# CONFIG_HMC6352 is not set
# CONFIG_DS1682 is not set
CONFIG_VMWARE_BALLOON=m
# CONFIG_USB_SWITCH_FSA9480 is not set
# CONFIG_LATTICE_ECP3_CONFIG is not set
# CONFIG_SRAM is not set
# CONFIG_PCI_ENDPOINT_TEST is not set
CONFIG_PVPANIC=y
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=m
# CONFIG_EEPROM_AT25 is not set
CONFIG_EEPROM_LEGACY=m
CONFIG_EEPROM_MAX6875=m
CONFIG_EEPROM_93CX6=m
# CONFIG_EEPROM_93XX46 is not set
# CONFIG_EEPROM_IDT_89HPESX is not set
# CONFIG_EEPROM_EE1004 is not set
CONFIG_CB710_CORE=m
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=m
CONFIG_ALTERA_STAPL=m
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=y
# CONFIG_INTEL_MEI_TXE is not set
CONFIG_VMWARE_VMCI=m

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
# CONFIG_GENWQE is not set
# CONFIG_ECHO is not set
# CONFIG_MISC_ALCOR_PCI is not set
# CONFIG_MISC_RTSX_PCI is not set
# CONFIG_MISC_RTSX_USB is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=m
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=m
CONFIG_CHR_DEV_ST=m
CONFIG_CHR_DEV_OSST=m
CONFIG_BLK_DEV_SR=m
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=m
CONFIG_CHR_DEV_SCH=m
CONFIG_SCSI_ENCLOSURE=m
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=m
CONFIG_SCSI_FC_ATTRS=m
CONFIG_SCSI_ISCSI_ATTRS=m
CONFIG_SCSI_SAS_ATTRS=m
CONFIG_SCSI_SAS_LIBSAS=m
CONFIG_SCSI_SAS_ATA=y
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=m
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=m
CONFIG_ISCSI_BOOT_SYSFS=m
CONFIG_SCSI_CXGB3_ISCSI=m
CONFIG_SCSI_CXGB4_ISCSI=m
CONFIG_SCSI_BNX2_ISCSI=m
CONFIG_SCSI_BNX2X_FCOE=m
CONFIG_BE2ISCSI=m
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
CONFIG_SCSI_HPSA=m
CONFIG_SCSI_3W_9XXX=m
CONFIG_SCSI_3W_SAS=m
# CONFIG_SCSI_ACARD is not set
CONFIG_SCSI_AACRAID=m
# CONFIG_SCSI_AIC7XXX is not set
CONFIG_SCSI_AIC79XX=m
CONFIG_AIC79XX_CMDS_PER_DEVICE=4
CONFIG_AIC79XX_RESET_DELAY_MS=15000
# CONFIG_AIC79XX_DEBUG_ENABLE is not set
CONFIG_AIC79XX_DEBUG_MASK=0
# CONFIG_AIC79XX_REG_PRETTY_PRINT is not set
# CONFIG_SCSI_AIC94XX is not set
CONFIG_SCSI_MVSAS=m
# CONFIG_SCSI_MVSAS_DEBUG is not set
CONFIG_SCSI_MVSAS_TASKLET=y
CONFIG_SCSI_MVUMI=m
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
CONFIG_SCSI_ARCMSR=m
# CONFIG_SCSI_ESAS2R is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
CONFIG_MEGARAID_SAS=m
CONFIG_SCSI_MPT3SAS=m
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
CONFIG_SCSI_MPT3SAS_MAX_SGE=128
CONFIG_SCSI_MPT2SAS=m
# CONFIG_SCSI_SMARTPQI is not set
CONFIG_SCSI_UFSHCD=m
CONFIG_SCSI_UFSHCD_PCI=m
# CONFIG_SCSI_UFS_DWC_TC_PCI is not set
# CONFIG_SCSI_UFSHCD_PLATFORM is not set
# CONFIG_SCSI_UFS_BSG is not set
CONFIG_SCSI_HPTIOP=m
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_SCSI_MYRB is not set
# CONFIG_SCSI_MYRS is not set
CONFIG_VMWARE_PVSCSI=m
# CONFIG_XEN_SCSI_FRONTEND is not set
CONFIG_HYPERV_STORAGE=m
CONFIG_LIBFC=m
CONFIG_LIBFCOE=m
CONFIG_FCOE=m
CONFIG_FCOE_FNIC=m
# CONFIG_SCSI_SNIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_GDTH is not set
CONFIG_SCSI_ISCI=m
# CONFIG_SCSI_IPS is not set
CONFIG_SCSI_INITIO=m
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_PPA is not set
# CONFIG_SCSI_IMM is not set
CONFIG_SCSI_STEX=m
# CONFIG_SCSI_SYM53C8XX_2 is not set
CONFIG_SCSI_IPR=m
CONFIG_SCSI_IPR_TRACE=y
CONFIG_SCSI_IPR_DUMP=y
# CONFIG_SCSI_QLOGIC_1280 is not set
CONFIG_SCSI_QLA_FC=m
# CONFIG_TCM_QLA2XXX is not set
CONFIG_SCSI_QLA_ISCSI=m
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_AM53C974 is not set
# CONFIG_SCSI_WD719X is not set
CONFIG_SCSI_DEBUG=m
CONFIG_SCSI_PMCRAID=m
CONFIG_SCSI_PM8001=m
# CONFIG_SCSI_BFA_FC is not set
CONFIG_SCSI_VIRTIO=m
CONFIG_SCSI_CHELSIO_FCOE=m
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
CONFIG_SCSI_DH_HP_SW=y
CONFIG_SCSI_DH_EMC=y
CONFIG_SCSI_DH_ALUA=y
CONFIG_SCSI_OSD_INITIATOR=m
CONFIG_SCSI_OSD_ULD=m
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
CONFIG_ATA=m
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=m
CONFIG_SATA_MOBILE_LPM_POLICY=0
CONFIG_SATA_AHCI_PLATFORM=m
# CONFIG_SATA_INIC162X is not set
CONFIG_SATA_ACARD_AHCI=m
CONFIG_SATA_SIL24=m
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
CONFIG_PDC_ADMA=m
CONFIG_SATA_QSTOR=m
CONFIG_SATA_SX4=m
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=m
# CONFIG_SATA_DWC is not set
CONFIG_SATA_MV=m
CONFIG_SATA_NV=m
CONFIG_SATA_PROMISE=m
CONFIG_SATA_SIL=m
CONFIG_SATA_SIS=m
CONFIG_SATA_SVW=m
CONFIG_SATA_ULI=m
CONFIG_SATA_VIA=m
CONFIG_SATA_VITESSE=m

#
# PATA SFF controllers with BMDMA
#
CONFIG_PATA_ALI=m
CONFIG_PATA_AMD=m
CONFIG_PATA_ARTOP=m
CONFIG_PATA_ATIIXP=m
CONFIG_PATA_ATP867X=m
CONFIG_PATA_CMD64X=m
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
CONFIG_PATA_HPT366=m
CONFIG_PATA_HPT37X=m
CONFIG_PATA_HPT3X2N=m
CONFIG_PATA_HPT3X3=m
# CONFIG_PATA_HPT3X3_DMA is not set
CONFIG_PATA_IT8213=m
CONFIG_PATA_IT821X=m
CONFIG_PATA_JMICRON=m
CONFIG_PATA_MARVELL=m
CONFIG_PATA_NETCELL=m
CONFIG_PATA_NINJA32=m
# CONFIG_PATA_NS87415 is not set
CONFIG_PATA_OLDPIIX=m
# CONFIG_PATA_OPTIDMA is not set
CONFIG_PATA_PDC2027X=m
CONFIG_PATA_PDC_OLD=m
# CONFIG_PATA_RADISYS is not set
CONFIG_PATA_RDC=m
CONFIG_PATA_SCH=m
CONFIG_PATA_SERVERWORKS=m
CONFIG_PATA_SIL680=m
CONFIG_PATA_SIS=m
CONFIG_PATA_TOSHIBA=m
# CONFIG_PATA_TRIFLEX is not set
CONFIG_PATA_VIA=m
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
CONFIG_PATA_ACPI=m
CONFIG_ATA_GENERIC=m
# CONFIG_PATA_LEGACY is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
CONFIG_MD_LINEAR=m
CONFIG_MD_RAID0=m
CONFIG_MD_RAID1=m
CONFIG_MD_RAID10=m
CONFIG_MD_RAID456=m
CONFIG_MD_MULTIPATH=m
CONFIG_MD_FAULTY=m
# CONFIG_MD_CLUSTER is not set
# CONFIG_BCACHE is not set
CONFIG_BLK_DEV_DM_BUILTIN=y
CONFIG_BLK_DEV_DM=m
CONFIG_DM_DEBUG=y
CONFIG_DM_BUFIO=m
# CONFIG_DM_DEBUG_BLOCK_MANAGER_LOCKING is not set
CONFIG_DM_BIO_PRISON=m
CONFIG_DM_PERSISTENT_DATA=m
# CONFIG_DM_UNSTRIPED is not set
CONFIG_DM_CRYPT=m
CONFIG_DM_SNAPSHOT=m
CONFIG_DM_THIN_PROVISIONING=m
CONFIG_DM_CACHE=m
CONFIG_DM_CACHE_SMQ=m
# CONFIG_DM_WRITECACHE is not set
# CONFIG_DM_ERA is not set
CONFIG_DM_MIRROR=m
CONFIG_DM_LOG_USERSPACE=m
CONFIG_DM_RAID=m
CONFIG_DM_ZERO=m
CONFIG_DM_MULTIPATH=m
CONFIG_DM_MULTIPATH_QL=m
CONFIG_DM_MULTIPATH_ST=m
CONFIG_DM_DELAY=m
CONFIG_DM_UEVENT=y
CONFIG_DM_FLAKEY=m
CONFIG_DM_VERITY=m
# CONFIG_DM_VERITY_FEC is not set
CONFIG_DM_SWITCH=m
CONFIG_DM_LOG_WRITES=m
# CONFIG_DM_INTEGRITY is not set
# CONFIG_DM_ZONED is not set
CONFIG_TARGET_CORE=m
CONFIG_TCM_IBLOCK=m
CONFIG_TCM_FILEIO=m
CONFIG_TCM_PSCSI=m
# CONFIG_TCM_USER2 is not set
CONFIG_LOOPBACK_TARGET=m
CONFIG_TCM_FC=m
CONFIG_ISCSI_TARGET=m
# CONFIG_ISCSI_TARGET_CXGB4 is not set
# CONFIG_SBP_TARGET is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=m
# CONFIG_FUSION_FC is not set
CONFIG_FUSION_SAS=m
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=m
CONFIG_FUSION_LOGGING=y

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=m
CONFIG_FIREWIRE_OHCI=m
CONFIG_FIREWIRE_SBP2=m
CONFIG_FIREWIRE_NET=m
# CONFIG_FIREWIRE_NOSY is not set
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_MAC_EMUMOUSEBTN=y
CONFIG_NETDEVICES=y
CONFIG_MII=y
CONFIG_NET_CORE=y
CONFIG_BONDING=m
CONFIG_DUMMY=m
# CONFIG_EQUALIZER is not set
CONFIG_NET_FC=y
CONFIG_IFB=m
CONFIG_NET_TEAM=m
CONFIG_NET_TEAM_MODE_BROADCAST=m
CONFIG_NET_TEAM_MODE_ROUNDROBIN=m
CONFIG_NET_TEAM_MODE_RANDOM=m
CONFIG_NET_TEAM_MODE_ACTIVEBACKUP=m
CONFIG_NET_TEAM_MODE_LOADBALANCE=m
CONFIG_MACVLAN=m
CONFIG_MACVTAP=m
# CONFIG_IPVLAN is not set
CONFIG_VXLAN=m
# CONFIG_GENEVE is not set
# CONFIG_GTP is not set
CONFIG_MACSEC=y
CONFIG_NETCONSOLE=m
CONFIG_NETCONSOLE_DYNAMIC=y
CONFIG_NETPOLL=y
CONFIG_NET_POLL_CONTROLLER=y
CONFIG_TUN=m
CONFIG_TAP=m
# CONFIG_TUN_VNET_CROSS_LE is not set
CONFIG_VETH=m
CONFIG_VIRTIO_NET=y
CONFIG_NLMON=m
CONFIG_NET_VRF=y
# CONFIG_ARCNET is not set
# CONFIG_ATM_DRIVERS is not set

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
CONFIG_ETHERNET=y
CONFIG_MDIO=y
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_NET_VENDOR_ADAPTEC is not set
CONFIG_NET_VENDOR_AGERE=y
# CONFIG_ET131X is not set
CONFIG_NET_VENDOR_ALACRITECH=y
# CONFIG_SLICOSS is not set
# CONFIG_NET_VENDOR_ALTEON is not set
# CONFIG_ALTERA_TSE is not set
CONFIG_NET_VENDOR_AMAZON=y
# CONFIG_ENA_ETHERNET is not set
# CONFIG_NET_VENDOR_AMD is not set
CONFIG_NET_VENDOR_AQUANTIA=y
# CONFIG_AQTION is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
CONFIG_ATL2=m
CONFIG_ATL1=m
CONFIG_ATL1E=m
CONFIG_ATL1C=m
CONFIG_ALX=m
# CONFIG_NET_VENDOR_AURORA is not set
CONFIG_NET_VENDOR_BROADCOM=y
CONFIG_B44=m
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y
# CONFIG_BCMGENET is not set
CONFIG_BNX2=m
CONFIG_CNIC=m
CONFIG_TIGON3=y
CONFIG_TIGON3_HWMON=y
# CONFIG_BNX2X is not set
# CONFIG_SYSTEMPORT is not set
# CONFIG_BNXT is not set
CONFIG_NET_VENDOR_BROCADE=y
CONFIG_BNA=m
CONFIG_NET_VENDOR_CADENCE=y
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_CAVIUM=y
# CONFIG_THUNDER_NIC_PF is not set
# CONFIG_THUNDER_NIC_VF is not set
# CONFIG_THUNDER_NIC_BGX is not set
# CONFIG_THUNDER_NIC_RGX is not set
CONFIG_CAVIUM_PTP=y
# CONFIG_LIQUIDIO is not set
# CONFIG_LIQUIDIO_VF is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
CONFIG_CHELSIO_T3=m
CONFIG_CHELSIO_T4=m
# CONFIG_CHELSIO_T4_DCB is not set
CONFIG_CHELSIO_T4VF=m
CONFIG_CHELSIO_LIB=m
CONFIG_NET_VENDOR_CISCO=y
CONFIG_ENIC=m
CONFIG_NET_VENDOR_CORTINA=y
# CONFIG_CX_ECAT is not set
CONFIG_DNET=m
CONFIG_NET_VENDOR_DEC=y
CONFIG_NET_TULIP=y
CONFIG_DE2104X=m
CONFIG_DE2104X_DSL=0
CONFIG_TULIP=y
# CONFIG_TULIP_MWI is not set
CONFIG_TULIP_MMIO=y
# CONFIG_TULIP_NAPI is not set
CONFIG_DE4X5=m
CONFIG_WINBOND_840=m
CONFIG_DM9102=m
CONFIG_ULI526X=m
CONFIG_PCMCIA_XIRCOM=m
# CONFIG_NET_VENDOR_DLINK is not set
CONFIG_NET_VENDOR_EMULEX=y
CONFIG_BE2NET=m
CONFIG_BE2NET_HWMON=y
CONFIG_BE2NET_BE2=y
CONFIG_BE2NET_BE3=y
CONFIG_BE2NET_LANCER=y
CONFIG_BE2NET_SKYHAWK=y
CONFIG_NET_VENDOR_EZCHIP=y
# CONFIG_NET_VENDOR_HP is not set
CONFIG_NET_VENDOR_HUAWEI=y
# CONFIG_HINIC is not set
# CONFIG_NET_VENDOR_I825XX is not set
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_E1000E_HWTS=y
CONFIG_IGB=y
CONFIG_IGB_HWMON=y
CONFIG_IGBVF=m
CONFIG_IXGB=m
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
CONFIG_IXGBE_DCB=y
CONFIG_IXGBEVF=m
CONFIG_I40E=m
# CONFIG_I40E_DCB is not set
# CONFIG_I40EVF is not set
# CONFIG_ICE is not set
# CONFIG_FM10K is not set
# CONFIG_IGC is not set
CONFIG_JME=m
CONFIG_NET_VENDOR_MARVELL=y
CONFIG_MVMDIO=m
CONFIG_SKGE=m
CONFIG_SKGE_DEBUG=y
CONFIG_SKGE_GENESIS=y
CONFIG_SKY2=m
CONFIG_SKY2_DEBUG=y
CONFIG_NET_VENDOR_MELLANOX=y
CONFIG_MLX4_EN=m
CONFIG_MLX4_EN_DCB=y
CONFIG_MLX4_CORE=m
CONFIG_MLX4_DEBUG=y
CONFIG_MLX4_CORE_GEN2=y
# CONFIG_MLX5_CORE is not set
# CONFIG_MLXSW_CORE is not set
# CONFIG_MLXFW is not set
# CONFIG_NET_VENDOR_MICREL is not set
CONFIG_NET_VENDOR_MICROCHIP=y
# CONFIG_ENC28J60 is not set
# CONFIG_ENCX24J600 is not set
# CONFIG_LAN743X is not set
CONFIG_NET_VENDOR_MICROSEMI=y
CONFIG_NET_VENDOR_MYRI=y
CONFIG_MYRI10GE=m
# CONFIG_FEALNX is not set
# CONFIG_NET_VENDOR_NATSEMI is not set
CONFIG_NET_VENDOR_NETERION=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
CONFIG_NET_VENDOR_NETRONOME=y
# CONFIG_NFP is not set
CONFIG_NET_VENDOR_NI=y
# CONFIG_NI_XGE_MANAGEMENT_ENET is not set
# CONFIG_NET_VENDOR_NVIDIA is not set
CONFIG_NET_VENDOR_OKI=y
CONFIG_ETHOC=m
CONFIG_NET_VENDOR_PACKET_ENGINES=y
# CONFIG_HAMACHI is not set
CONFIG_YELLOWFIN=m
CONFIG_NET_VENDOR_QLOGIC=y
CONFIG_QLA3XXX=m
CONFIG_QLCNIC=m
CONFIG_QLCNIC_SRIOV=y
CONFIG_QLCNIC_DCB=y
CONFIG_QLCNIC_HWMON=y
CONFIG_QLGE=m
CONFIG_NETXEN_NIC=m
# CONFIG_QED is not set
CONFIG_NET_VENDOR_QUALCOMM=y
# CONFIG_QCOM_EMAC is not set
# CONFIG_RMNET is not set
# CONFIG_NET_VENDOR_RDC is not set
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_ATP is not set
CONFIG_8139CP=y
CONFIG_8139TOO=y
CONFIG_8139TOO_PIO=y
# CONFIG_8139TOO_TUNE_TWISTER is not set
CONFIG_8139TOO_8129=y
# CONFIG_8139_OLD_RX_RESET is not set
CONFIG_R8169=y
CONFIG_NET_VENDOR_RENESAS=y
CONFIG_NET_VENDOR_ROCKER=y
CONFIG_NET_VENDOR_SAMSUNG=y
# CONFIG_SXGBE_ETH is not set
# CONFIG_NET_VENDOR_SEEQ is not set
CONFIG_NET_VENDOR_SOLARFLARE=y
CONFIG_SFC=m
CONFIG_SFC_MTD=y
CONFIG_SFC_MCDI_MON=y
CONFIG_SFC_SRIOV=y
CONFIG_SFC_MCDI_LOGGING=y
# CONFIG_SFC_FALCON is not set
# CONFIG_NET_VENDOR_SILAN is not set
# CONFIG_NET_VENDOR_SIS is not set
CONFIG_NET_VENDOR_SMSC=y
CONFIG_EPIC100=m
# CONFIG_SMSC911X is not set
CONFIG_SMSC9420=m
CONFIG_NET_VENDOR_SOCIONEXT=y
# CONFIG_NET_VENDOR_STMICRO is not set
# CONFIG_NET_VENDOR_SUN is not set
CONFIG_NET_VENDOR_SYNOPSYS=y
# CONFIG_DWC_XLGMAC is not set
# CONFIG_NET_VENDOR_TEHUTI is not set
# CONFIG_NET_VENDOR_TI is not set
# CONFIG_NET_VENDOR_VIA is not set
# CONFIG_NET_VENDOR_WIZNET is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_MDIO_DEVICE=y
CONFIG_MDIO_BUS=y
# CONFIG_MDIO_BCM_UNIMAC is not set
CONFIG_MDIO_BITBANG=m
# CONFIG_MDIO_GPIO is not set
# CONFIG_MDIO_MSCC_MIIM is not set
# CONFIG_MDIO_THUNDER is not set
CONFIG_PHYLIB=y
CONFIG_SWPHY=y
# CONFIG_LED_TRIGGER_PHY is not set

#
# MII PHY device drivers
#
CONFIG_AMD_PHY=m
# CONFIG_AQUANTIA_PHY is not set
# CONFIG_ASIX_PHY is not set
CONFIG_AT803X_PHY=m
# CONFIG_BCM7XXX_PHY is not set
CONFIG_BCM87XX_PHY=m
CONFIG_BCM_NET_PHYLIB=m
CONFIG_BROADCOM_PHY=m
CONFIG_CICADA_PHY=m
# CONFIG_CORTINA_PHY is not set
CONFIG_DAVICOM_PHY=m
# CONFIG_DP83822_PHY is not set
# CONFIG_DP83TC811_PHY is not set
# CONFIG_DP83848_PHY is not set
# CONFIG_DP83867_PHY is not set
CONFIG_FIXED_PHY=y
CONFIG_ICPLUS_PHY=m
# CONFIG_INTEL_XWAY_PHY is not set
CONFIG_LSI_ET1011C_PHY=m
CONFIG_LXT_PHY=m
CONFIG_MARVELL_PHY=m
# CONFIG_MARVELL_10G_PHY is not set
CONFIG_MICREL_PHY=m
# CONFIG_MICROCHIP_PHY is not set
# CONFIG_MICROCHIP_T1_PHY is not set
# CONFIG_MICROSEMI_PHY is not set
CONFIG_NATIONAL_PHY=m
CONFIG_QSEMI_PHY=m
CONFIG_REALTEK_PHY=y
# CONFIG_RENESAS_PHY is not set
# CONFIG_ROCKCHIP_PHY is not set
CONFIG_SMSC_PHY=m
CONFIG_STE10XP=m
# CONFIG_TERANETICS_PHY is not set
CONFIG_VITESSE_PHY=m
# CONFIG_XILINX_GMII2RGMII is not set
# CONFIG_MICREL_KS8995MA is not set
# CONFIG_PLIP is not set
CONFIG_PPP=m
CONFIG_PPP_BSDCOMP=m
CONFIG_PPP_DEFLATE=m
CONFIG_PPP_FILTER=y
CONFIG_PPP_MPPE=m
CONFIG_PPP_MULTILINK=y
CONFIG_PPPOATM=m
CONFIG_PPPOE=m
CONFIG_PPTP=m
CONFIG_PPPOL2TP=m
CONFIG_PPP_ASYNC=m
CONFIG_PPP_SYNC_TTY=m
CONFIG_SLIP=m
CONFIG_SLHC=m
CONFIG_SLIP_COMPRESSED=y
CONFIG_SLIP_SMART=y
# CONFIG_SLIP_MODE_SLIP6 is not set
CONFIG_USB_NET_DRIVERS=y
CONFIG_USB_CATC=y
CONFIG_USB_KAWETH=y
CONFIG_USB_PEGASUS=y
CONFIG_USB_RTL8150=y
CONFIG_USB_RTL8152=m
# CONFIG_USB_LAN78XX is not set
CONFIG_USB_USBNET=y
CONFIG_USB_NET_AX8817X=y
CONFIG_USB_NET_AX88179_178A=m
CONFIG_USB_NET_CDCETHER=y
CONFIG_USB_NET_CDC_EEM=y
CONFIG_USB_NET_CDC_NCM=m
# CONFIG_USB_NET_HUAWEI_CDC_NCM is not set
CONFIG_USB_NET_CDC_MBIM=m
CONFIG_USB_NET_DM9601=y
# CONFIG_USB_NET_SR9700 is not set
# CONFIG_USB_NET_SR9800 is not set
CONFIG_USB_NET_SMSC75XX=y
CONFIG_USB_NET_SMSC95XX=y
CONFIG_USB_NET_GL620A=y
CONFIG_USB_NET_NET1080=y
CONFIG_USB_NET_PLUSB=y
CONFIG_USB_NET_MCS7830=y
CONFIG_USB_NET_RNDIS_HOST=y
CONFIG_USB_NET_CDC_SUBSET_ENABLE=y
CONFIG_USB_NET_CDC_SUBSET=y
CONFIG_USB_ALI_M5632=y
CONFIG_USB_AN2720=y
CONFIG_USB_BELKIN=y
CONFIG_USB_ARMLINUX=y
CONFIG_USB_EPSON2888=y
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=y
CONFIG_USB_NET_CX82310_ETH=m
CONFIG_USB_NET_KALMIA=m
CONFIG_USB_NET_QMI_WWAN=m
CONFIG_USB_HSO=m
CONFIG_USB_NET_INT51X1=y
CONFIG_USB_IPHETH=y
CONFIG_USB_SIERRA_NET=y
CONFIG_USB_VL600=m
# CONFIG_USB_NET_CH9200 is not set
# CONFIG_USB_NET_AQC111 is not set
CONFIG_WLAN=y
# CONFIG_WIRELESS_WDS is not set
CONFIG_WLAN_VENDOR_ADMTEK=y
# CONFIG_ADM8211 is not set
CONFIG_WLAN_VENDOR_ATH=y
# CONFIG_ATH_DEBUG is not set
# CONFIG_ATH5K is not set
# CONFIG_ATH5K_PCI is not set
# CONFIG_ATH9K is not set
# CONFIG_ATH9K_HTC is not set
# CONFIG_CARL9170 is not set
# CONFIG_ATH6KL is not set
# CONFIG_AR5523 is not set
# CONFIG_WIL6210 is not set
# CONFIG_ATH10K is not set
# CONFIG_WCN36XX is not set
CONFIG_WLAN_VENDOR_ATMEL=y
# CONFIG_ATMEL is not set
# CONFIG_AT76C50X_USB is not set
CONFIG_WLAN_VENDOR_BROADCOM=y
# CONFIG_B43 is not set
# CONFIG_B43LEGACY is not set
# CONFIG_BRCMSMAC is not set
# CONFIG_BRCMFMAC is not set
CONFIG_WLAN_VENDOR_CISCO=y
# CONFIG_AIRO is not set
CONFIG_WLAN_VENDOR_INTEL=y
# CONFIG_IPW2100 is not set
# CONFIG_IPW2200 is not set
# CONFIG_IWL4965 is not set
# CONFIG_IWL3945 is not set
# CONFIG_IWLWIFI is not set
CONFIG_WLAN_VENDOR_INTERSIL=y
# CONFIG_HOSTAP is not set
# CONFIG_HERMES is not set
# CONFIG_P54_COMMON is not set
# CONFIG_PRISM54 is not set
CONFIG_WLAN_VENDOR_MARVELL=y
# CONFIG_LIBERTAS is not set
# CONFIG_LIBERTAS_THINFIRM is not set
# CONFIG_MWIFIEX is not set
# CONFIG_MWL8K is not set
CONFIG_WLAN_VENDOR_MEDIATEK=y
# CONFIG_MT7601U is not set
# CONFIG_MT76x0U is not set
# CONFIG_MT76x0E is not set
# CONFIG_MT76x2E is not set
# CONFIG_MT76x2U is not set
CONFIG_WLAN_VENDOR_RALINK=y
# CONFIG_RT2X00 is not set
CONFIG_WLAN_VENDOR_REALTEK=y
# CONFIG_RTL8180 is not set
# CONFIG_RTL8187 is not set
CONFIG_RTL_CARDS=m
# CONFIG_RTL8192CE is not set
# CONFIG_RTL8192SE is not set
# CONFIG_RTL8192DE is not set
# CONFIG_RTL8723AE is not set
# CONFIG_RTL8723BE is not set
# CONFIG_RTL8188EE is not set
# CONFIG_RTL8192EE is not set
# CONFIG_RTL8821AE is not set
# CONFIG_RTL8192CU is not set
# CONFIG_RTL8XXXU is not set
CONFIG_WLAN_VENDOR_RSI=y
# CONFIG_RSI_91X is not set
CONFIG_WLAN_VENDOR_ST=y
# CONFIG_CW1200 is not set
CONFIG_WLAN_VENDOR_TI=y
# CONFIG_WL1251 is not set
# CONFIG_WL12XX is not set
# CONFIG_WL18XX is not set
# CONFIG_WLCORE is not set
CONFIG_WLAN_VENDOR_ZYDAS=y
# CONFIG_USB_ZD1201 is not set
# CONFIG_ZD1211RW is not set
CONFIG_WLAN_VENDOR_QUANTENNA=y
# CONFIG_QTNFMAC_PCIE is not set
CONFIG_MAC80211_HWSIM=m
# CONFIG_USB_NET_RNDIS_WLAN is not set
# CONFIG_VIRT_WIFI is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
CONFIG_WAN=y
# CONFIG_LANMEDIA is not set
CONFIG_HDLC=m
CONFIG_HDLC_RAW=m
# CONFIG_HDLC_RAW_ETH is not set
CONFIG_HDLC_CISCO=m
CONFIG_HDLC_FR=m
CONFIG_HDLC_PPP=m

#
# X.25/LAPB support is disabled
#
# CONFIG_PCI200SYN is not set
# CONFIG_WANXL is not set
# CONFIG_PC300TOO is not set
# CONFIG_FARSYNC is not set
# CONFIG_DSCC4 is not set
CONFIG_DLCI=m
CONFIG_DLCI_MAX=8
# CONFIG_SBNI is not set
CONFIG_IEEE802154_DRIVERS=m
CONFIG_IEEE802154_FAKELB=m
# CONFIG_IEEE802154_AT86RF230 is not set
# CONFIG_IEEE802154_MRF24J40 is not set
# CONFIG_IEEE802154_CC2520 is not set
# CONFIG_IEEE802154_ATUSB is not set
# CONFIG_IEEE802154_ADF7242 is not set
# CONFIG_IEEE802154_CA8210 is not set
# CONFIG_IEEE802154_MCR20A is not set
# CONFIG_IEEE802154_HWSIM is not set
CONFIG_XEN_NETDEV_FRONTEND=m
# CONFIG_XEN_NETDEV_BACKEND is not set
CONFIG_VMXNET3=m
# CONFIG_FUJITSU_ES is not set
CONFIG_HYPERV_NET=m
CONFIG_NETDEVSIM=m
CONFIG_NET_FAILOVER=y
CONFIG_ISDN=y
CONFIG_ISDN_I4L=m
CONFIG_ISDN_PPP=y
CONFIG_ISDN_PPP_VJ=y
CONFIG_ISDN_MPP=y
CONFIG_IPPP_FILTER=y
# CONFIG_ISDN_PPP_BSDCOMP is not set
CONFIG_ISDN_AUDIO=y
CONFIG_ISDN_TTY_FAX=y

#
# ISDN feature submodules
#
CONFIG_ISDN_DIVERSION=m

#
# ISDN4Linux hardware drivers
#

#
# Passive cards
#
# CONFIG_ISDN_DRV_HISAX is not set
CONFIG_ISDN_CAPI=m
# CONFIG_CAPI_TRACE is not set
CONFIG_ISDN_CAPI_CAPI20=m
CONFIG_ISDN_CAPI_MIDDLEWARE=y
CONFIG_ISDN_CAPI_CAPIDRV=m
# CONFIG_ISDN_CAPI_CAPIDRV_VERBOSE is not set

#
# CAPI hardware drivers
#
CONFIG_CAPI_AVM=y
CONFIG_ISDN_DRV_AVMB1_B1PCI=m
CONFIG_ISDN_DRV_AVMB1_B1PCIV4=y
CONFIG_ISDN_DRV_AVMB1_T1PCI=m
CONFIG_ISDN_DRV_AVMB1_C4=m
CONFIG_ISDN_DRV_GIGASET=m
CONFIG_GIGASET_CAPI=y
CONFIG_GIGASET_BASE=m
CONFIG_GIGASET_M105=m
CONFIG_GIGASET_M101=m
# CONFIG_GIGASET_DEBUG is not set
CONFIG_HYSDN=m
CONFIG_HYSDN_CAPI=y
CONFIG_MISDN=m
CONFIG_MISDN_DSP=m
CONFIG_MISDN_L1OIP=m

#
# mISDN hardware drivers
#
CONFIG_MISDN_HFCPCI=m
CONFIG_MISDN_HFCMULTI=m
CONFIG_MISDN_HFCUSB=m
CONFIG_MISDN_AVMFRITZ=m
CONFIG_MISDN_SPEEDFAX=m
CONFIG_MISDN_INFINEON=m
CONFIG_MISDN_W6692=m
CONFIG_MISDN_NETJET=m
CONFIG_MISDN_IPAC=m
CONFIG_MISDN_ISAR=m
CONFIG_ISDN_HDLC=m
# CONFIG_NVM is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=m
CONFIG_INPUT_SPARSEKMAP=m
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
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
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_BYD=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_SYNAPTICS_SMBUS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
CONFIG_MOUSE_PS2_ELANTECH=y
CONFIG_MOUSE_PS2_ELANTECH_SMBUS=y
CONFIG_MOUSE_PS2_SENTELIC=y
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_PS2_FOCALTECH=y
# CONFIG_MOUSE_PS2_VMMOUSE is not set
CONFIG_MOUSE_PS2_SMBUS=y
CONFIG_MOUSE_SERIAL=m
CONFIG_MOUSE_APPLETOUCH=m
CONFIG_MOUSE_BCM5974=m
CONFIG_MOUSE_CYAPA=m
# CONFIG_MOUSE_ELAN_I2C is not set
CONFIG_MOUSE_VSXXXAA=m
# CONFIG_MOUSE_GPIO is not set
CONFIG_MOUSE_SYNAPTICS_I2C=m
CONFIG_MOUSE_SYNAPTICS_USB=m
# CONFIG_INPUT_JOYSTICK is not set
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=m
CONFIG_TABLET_USB_AIPTEK=m
CONFIG_TABLET_USB_GTCO=m
# CONFIG_TABLET_USB_HANWANG is not set
CONFIG_TABLET_USB_KBTAB=m
# CONFIG_TABLET_USB_PEGASUS is not set
# CONFIG_TABLET_SERIAL_WACOM4 is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_PROPERTIES=y
# CONFIG_TOUCHSCREEN_ADS7846 is not set
# CONFIG_TOUCHSCREEN_AD7877 is not set
# CONFIG_TOUCHSCREEN_AD7879 is not set
# CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
# CONFIG_TOUCHSCREEN_AUO_PIXCIR is not set
# CONFIG_TOUCHSCREEN_BU21013 is not set
# CONFIG_TOUCHSCREEN_BU21029 is not set
# CONFIG_TOUCHSCREEN_CHIPONE_ICN8505 is not set
# CONFIG_TOUCHSCREEN_CY8CTMG110 is not set
# CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set
# CONFIG_TOUCHSCREEN_CYTTSP4_CORE is not set
# CONFIG_TOUCHSCREEN_DYNAPRO is not set
# CONFIG_TOUCHSCREEN_HAMPSHIRE is not set
# CONFIG_TOUCHSCREEN_EETI is not set
# CONFIG_TOUCHSCREEN_EGALAX_SERIAL is not set
# CONFIG_TOUCHSCREEN_EXC3000 is not set
# CONFIG_TOUCHSCREEN_FUJITSU is not set
# CONFIG_TOUCHSCREEN_GOODIX is not set
# CONFIG_TOUCHSCREEN_HIDEEP is not set
# CONFIG_TOUCHSCREEN_ILI210X is not set
# CONFIG_TOUCHSCREEN_S6SY761 is not set
# CONFIG_TOUCHSCREEN_GUNZE is not set
# CONFIG_TOUCHSCREEN_EKTF2127 is not set
# CONFIG_TOUCHSCREEN_ELAN is not set
# CONFIG_TOUCHSCREEN_ELO is not set
CONFIG_TOUCHSCREEN_WACOM_W8001=m
CONFIG_TOUCHSCREEN_WACOM_I2C=m
# CONFIG_TOUCHSCREEN_MAX11801 is not set
# CONFIG_TOUCHSCREEN_MCS5000 is not set
# CONFIG_TOUCHSCREEN_MMS114 is not set
# CONFIG_TOUCHSCREEN_MELFAS_MIP4 is not set
# CONFIG_TOUCHSCREEN_MTOUCH is not set
# CONFIG_TOUCHSCREEN_INEXIO is not set
# CONFIG_TOUCHSCREEN_MK712 is not set
# CONFIG_TOUCHSCREEN_PENMOUNT is not set
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
# CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
# CONFIG_TOUCHSCREEN_TOUCHWIN is not set
# CONFIG_TOUCHSCREEN_PIXCIR is not set
# CONFIG_TOUCHSCREEN_WDT87XX_I2C is not set
# CONFIG_TOUCHSCREEN_WM97XX is not set
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
# CONFIG_TOUCHSCREEN_TOUCHIT213 is not set
# CONFIG_TOUCHSCREEN_TSC_SERIO is not set
# CONFIG_TOUCHSCREEN_TSC2004 is not set
# CONFIG_TOUCHSCREEN_TSC2005 is not set
# CONFIG_TOUCHSCREEN_TSC2007 is not set
# CONFIG_TOUCHSCREEN_RM_TS is not set
# CONFIG_TOUCHSCREEN_SILEAD is not set
# CONFIG_TOUCHSCREEN_SIS_I2C is not set
# CONFIG_TOUCHSCREEN_ST1232 is not set
# CONFIG_TOUCHSCREEN_STMFTS is not set
# CONFIG_TOUCHSCREEN_SUR40 is not set
# CONFIG_TOUCHSCREEN_SURFACE3_SPI is not set
# CONFIG_TOUCHSCREEN_SX8654 is not set
# CONFIG_TOUCHSCREEN_TPS6507X is not set
# CONFIG_TOUCHSCREEN_ZET6223 is not set
# CONFIG_TOUCHSCREEN_ZFORCE is not set
# CONFIG_TOUCHSCREEN_ROHM_BU21023 is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_BMA150 is not set
# CONFIG_INPUT_E3X0_BUTTON is not set
CONFIG_INPUT_PCSPKR=m
# CONFIG_INPUT_MMA8450 is not set
CONFIG_INPUT_APANEL=m
# CONFIG_INPUT_GP2A is not set
# CONFIG_INPUT_GPIO_BEEPER is not set
# CONFIG_INPUT_GPIO_DECODER is not set
CONFIG_INPUT_ATLAS_BTNS=m
CONFIG_INPUT_ATI_REMOTE2=m
CONFIG_INPUT_KEYSPAN_REMOTE=m
# CONFIG_INPUT_KXTJ9 is not set
CONFIG_INPUT_POWERMATE=m
CONFIG_INPUT_YEALINK=m
CONFIG_INPUT_CM109=m
CONFIG_INPUT_UINPUT=m
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_PWM_BEEPER is not set
# CONFIG_INPUT_PWM_VIBRA is not set
# CONFIG_INPUT_GPIO_ROTARY_ENCODER is not set
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_IMS_PCU is not set
# CONFIG_INPUT_CMA3000 is not set
CONFIG_INPUT_XEN_KBDDEV_FRONTEND=m
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set
# CONFIG_INPUT_DRV260X_HAPTICS is not set
# CONFIG_INPUT_DRV2665_HAPTICS is not set
# CONFIG_INPUT_DRV2667_HAPTICS is not set
# CONFIG_RMI4_CORE is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=m
CONFIG_SERIO_ALTERA_PS2=m
# CONFIG_SERIO_PS2MULT is not set
CONFIG_SERIO_ARC_PS2=m
# CONFIG_SERIO_OLPC_APSP is not set
CONFIG_HYPERV_KEYBOARD=m
# CONFIG_SERIO_GPIO_PS2 is not set
# CONFIG_USERIO is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_ROCKETPORT is not set
CONFIG_CYCLADES=m
# CONFIG_CYZ_INTR is not set
CONFIG_MOXA_INTELLIO=m
CONFIG_MOXA_SMARTIO=m
CONFIG_SYNCLINK=m
CONFIG_SYNCLINKMP=m
CONFIG_SYNCLINK_GT=m
CONFIG_NOZOMI=m
# CONFIG_ISI is not set
CONFIG_N_HDLC=m
CONFIG_N_GSM=m
# CONFIG_TRACE_SINK is not set
CONFIG_DEVMEM=y
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_EXAR=y
CONFIG_SERIAL_8250_NR_UARTS=32
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
CONFIG_SERIAL_8250_RSA=y
CONFIG_SERIAL_8250_DW=y
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
CONFIG_SERIAL_JSM=m
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_SC16IS7XX is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
CONFIG_SERIAL_ARC=m
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_DEV_BUS is not set
# CONFIG_TTY_PRINTK is not set
CONFIG_PRINTER=m
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=m
CONFIG_HVC_DRIVER=y
CONFIG_HVC_IRQ=y
CONFIG_HVC_XEN=y
CONFIG_HVC_XEN_FRONTEND=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=m
CONFIG_IPMI_DMI_DECODE=y
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=m
CONFIG_IPMI_SI=m
# CONFIG_IPMI_SSIF is not set
CONFIG_IPMI_WATCHDOG=m
CONFIG_IPMI_POWEROFF=m
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=m
CONFIG_HW_RANDOM_INTEL=m
CONFIG_HW_RANDOM_AMD=m
CONFIG_HW_RANDOM_VIA=m
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=8192
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
# CONFIG_HPET_MMAP_DEFAULT is not set
CONFIG_HANGCHECK_TIMER=m
CONFIG_UV_MMTIMER=m
CONFIG_TCG_TPM=y
CONFIG_HW_RANDOM_TPM=y
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
# CONFIG_TCG_TIS_SPI is not set
# CONFIG_TCG_TIS_I2C_ATMEL is not set
# CONFIG_TCG_TIS_I2C_INFINEON is not set
# CONFIG_TCG_TIS_I2C_NUVOTON is not set
CONFIG_TCG_NSC=m
CONFIG_TCG_ATMEL=m
CONFIG_TCG_INFINEON=m
# CONFIG_TCG_XEN is not set
CONFIG_TCG_CRB=y
# CONFIG_TCG_VTPM_PROXY is not set
# CONFIG_TCG_TIS_ST33ZP24_I2C is not set
# CONFIG_TCG_TIS_ST33ZP24_SPI is not set
CONFIG_TELCLOCK=m
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set
# CONFIG_RANDOM_TRUST_CPU is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=m
CONFIG_I2C_MUX=m

#
# Multiplexer I2C Chip support
#
# CONFIG_I2C_MUX_GPIO is not set
# CONFIG_I2C_MUX_LTC4306 is not set
# CONFIG_I2C_MUX_PCA9541 is not set
# CONFIG_I2C_MUX_PCA954x is not set
# CONFIG_I2C_MUX_REG is not set
# CONFIG_I2C_MUX_MLXCPLD is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCA=m

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
CONFIG_I2C_AMD756=m
CONFIG_I2C_AMD756_S4882=m
CONFIG_I2C_AMD8111=m
CONFIG_I2C_I801=y
CONFIG_I2C_ISCH=m
CONFIG_I2C_ISMT=m
CONFIG_I2C_PIIX4=m
CONFIG_I2C_NFORCE2=m
CONFIG_I2C_NFORCE2_S4985=m
# CONFIG_I2C_NVIDIA_GPU is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
CONFIG_I2C_SIS96X=m
CONFIG_I2C_VIA=m
CONFIG_I2C_VIAPRO=m

#
# ACPI drivers
#
CONFIG_I2C_SCMI=m

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_CBUS_GPIO is not set
CONFIG_I2C_DESIGNWARE_CORE=m
CONFIG_I2C_DESIGNWARE_PLATFORM=m
# CONFIG_I2C_DESIGNWARE_SLAVE is not set
CONFIG_I2C_DESIGNWARE_PCI=m
# CONFIG_I2C_DESIGNWARE_BAYTRAIL is not set
# CONFIG_I2C_EMEV2 is not set
# CONFIG_I2C_GPIO is not set
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PCA_PLATFORM=m
CONFIG_I2C_SIMTEC=m
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=m
CONFIG_I2C_PARPORT=m
CONFIG_I2C_PARPORT_LIGHT=m
# CONFIG_I2C_ROBOTFUZZ_OSIF is not set
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=m
CONFIG_I2C_VIPERBOARD=m

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_MLXCPLD is not set
CONFIG_I2C_STUB=m
# CONFIG_I2C_SLAVE is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_I3C is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y
# CONFIG_SPI_MEM is not set

#
# SPI Master Controller Drivers
#
# CONFIG_SPI_ALTERA is not set
# CONFIG_SPI_AXI_SPI_ENGINE is not set
# CONFIG_SPI_BITBANG is not set
# CONFIG_SPI_BUTTERFLY is not set
# CONFIG_SPI_CADENCE is not set
CONFIG_SPI_DESIGNWARE=m
# CONFIG_SPI_DW_PCI is not set
# CONFIG_SPI_DW_MMIO is not set
# CONFIG_SPI_GPIO is not set
# CONFIG_SPI_LM70_LLP is not set
# CONFIG_SPI_OC_TINY is not set
CONFIG_SPI_PXA2XX=m
CONFIG_SPI_PXA2XX_PCI=m
# CONFIG_SPI_ROCKCHIP is not set
# CONFIG_SPI_SC18IS602 is not set
# CONFIG_SPI_MXIC is not set
# CONFIG_SPI_XCOMM is not set
# CONFIG_SPI_XILINX is not set
# CONFIG_SPI_ZYNQMP_GQSPI is not set

#
# SPI Protocol Masters
#
# CONFIG_SPI_SPIDEV is not set
# CONFIG_SPI_LOOPBACK_TEST is not set
# CONFIG_SPI_TLE62X0 is not set
# CONFIG_SPI_SLAVE is not set
# CONFIG_SPMI is not set
# CONFIG_HSI is not set
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
CONFIG_PPS_CLIENT_LDISC=m
CONFIG_PPS_CLIENT_PARPORT=m
CONFIG_PPS_CLIENT_GPIO=m

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y
CONFIG_DP83640_PHY=m
CONFIG_PTP_1588_CLOCK_KVM=y
CONFIG_PINCTRL=y
CONFIG_PINMUX=y
CONFIG_PINCONF=y
CONFIG_GENERIC_PINCONF=y
# CONFIG_DEBUG_PINCTRL is not set
# CONFIG_PINCTRL_AMD is not set
# CONFIG_PINCTRL_MCP23S08 is not set
# CONFIG_PINCTRL_SX150X is not set
CONFIG_PINCTRL_BAYTRAIL=y
# CONFIG_PINCTRL_CHERRYVIEW is not set
# CONFIG_PINCTRL_BROXTON is not set
# CONFIG_PINCTRL_CANNONLAKE is not set
# CONFIG_PINCTRL_CEDARFORK is not set
# CONFIG_PINCTRL_DENVERTON is not set
# CONFIG_PINCTRL_GEMINILAKE is not set
# CONFIG_PINCTRL_ICELAKE is not set
# CONFIG_PINCTRL_LEWISBURG is not set
# CONFIG_PINCTRL_SUNRISEPOINT is not set
CONFIG_GPIOLIB=y
CONFIG_GPIOLIB_FASTPATH_LIMIT=512
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
CONFIG_GPIO_SYSFS=y

#
# Memory mapped GPIO drivers
#
# CONFIG_GPIO_AMDPT is not set
# CONFIG_GPIO_DWAPB is not set
# CONFIG_GPIO_EXAR is not set
# CONFIG_GPIO_GENERIC_PLATFORM is not set
# CONFIG_GPIO_ICH is not set
CONFIG_GPIO_LYNXPOINT=m
# CONFIG_GPIO_MB86S7X is not set
CONFIG_GPIO_MOCKUP=y
# CONFIG_GPIO_VX855 is not set

#
# Port-mapped I/O GPIO drivers
#
# CONFIG_GPIO_F7188X is not set
# CONFIG_GPIO_IT87 is not set
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_SCH311X is not set
# CONFIG_GPIO_WINBOND is not set
# CONFIG_GPIO_WS16C48 is not set

#
# I2C GPIO expanders
#
# CONFIG_GPIO_ADP5588 is not set
# CONFIG_GPIO_MAX7300 is not set
# CONFIG_GPIO_MAX732X is not set
# CONFIG_GPIO_PCA953X is not set
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_TPIC2810 is not set

#
# MFD GPIO expanders
#

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_PCI_IDIO_16 is not set
# CONFIG_GPIO_PCIE_IDIO_24 is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders
#
# CONFIG_GPIO_MAX3191X is not set
# CONFIG_GPIO_MAX7301 is not set
# CONFIG_GPIO_MC33880 is not set
# CONFIG_GPIO_PISOSR is not set
# CONFIG_GPIO_XRA1403 is not set

#
# USB GPIO expanders
#
# CONFIG_GPIO_VIPERBOARD is not set
# CONFIG_W1 is not set
# CONFIG_POWER_AVS is not set
CONFIG_POWER_RESET=y
# CONFIG_POWER_RESET_RESTART is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_CHARGER_ADP5061 is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_CHARGER_SBS is not set
# CONFIG_MANAGER_SBS is not set
# CONFIG_BATTERY_BQ27XXX is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_ISP1704 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_LTC3651 is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_BQ24190 is not set
# CONFIG_CHARGER_BQ24257 is not set
# CONFIG_CHARGER_BQ24735 is not set
# CONFIG_CHARGER_BQ25890 is not set
CONFIG_CHARGER_SMB347=m
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
# CONFIG_CHARGER_RT9455 is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=m
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=m
CONFIG_SENSORS_ABITUGURU3=m
# CONFIG_SENSORS_AD7314 is not set
CONFIG_SENSORS_AD7414=m
CONFIG_SENSORS_AD7418=m
CONFIG_SENSORS_ADM1021=m
CONFIG_SENSORS_ADM1025=m
CONFIG_SENSORS_ADM1026=m
CONFIG_SENSORS_ADM1029=m
CONFIG_SENSORS_ADM1031=m
CONFIG_SENSORS_ADM9240=m
CONFIG_SENSORS_ADT7X10=m
# CONFIG_SENSORS_ADT7310 is not set
CONFIG_SENSORS_ADT7410=m
CONFIG_SENSORS_ADT7411=m
CONFIG_SENSORS_ADT7462=m
CONFIG_SENSORS_ADT7470=m
CONFIG_SENSORS_ADT7475=m
CONFIG_SENSORS_ASC7621=m
CONFIG_SENSORS_K8TEMP=m
CONFIG_SENSORS_K10TEMP=m
CONFIG_SENSORS_FAM15H_POWER=m
CONFIG_SENSORS_APPLESMC=m
CONFIG_SENSORS_ASB100=m
# CONFIG_SENSORS_ASPEED is not set
CONFIG_SENSORS_ATXP1=m
CONFIG_SENSORS_DS620=m
CONFIG_SENSORS_DS1621=m
CONFIG_SENSORS_DELL_SMM=m
CONFIG_SENSORS_I5K_AMB=m
CONFIG_SENSORS_F71805F=m
CONFIG_SENSORS_F71882FG=m
CONFIG_SENSORS_F75375S=m
CONFIG_SENSORS_FSCHMD=m
# CONFIG_SENSORS_FTSTEUTATES is not set
CONFIG_SENSORS_GL518SM=m
CONFIG_SENSORS_GL520SM=m
CONFIG_SENSORS_G760A=m
# CONFIG_SENSORS_G762 is not set
# CONFIG_SENSORS_HIH6130 is not set
CONFIG_SENSORS_IBMAEM=m
CONFIG_SENSORS_IBMPEX=m
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=m
CONFIG_SENSORS_IT87=m
# CONFIG_SENSORS_JC42 is not set
# CONFIG_SENSORS_POWR1220 is not set
CONFIG_SENSORS_LINEAGE=m
# CONFIG_SENSORS_LTC2945 is not set
# CONFIG_SENSORS_LTC2990 is not set
CONFIG_SENSORS_LTC4151=m
CONFIG_SENSORS_LTC4215=m
# CONFIG_SENSORS_LTC4222 is not set
CONFIG_SENSORS_LTC4245=m
# CONFIG_SENSORS_LTC4260 is not set
CONFIG_SENSORS_LTC4261=m
# CONFIG_SENSORS_MAX1111 is not set
CONFIG_SENSORS_MAX16065=m
CONFIG_SENSORS_MAX1619=m
CONFIG_SENSORS_MAX1668=m
CONFIG_SENSORS_MAX197=m
# CONFIG_SENSORS_MAX31722 is not set
# CONFIG_SENSORS_MAX6621 is not set
CONFIG_SENSORS_MAX6639=m
CONFIG_SENSORS_MAX6642=m
CONFIG_SENSORS_MAX6650=m
CONFIG_SENSORS_MAX6697=m
# CONFIG_SENSORS_MAX31790 is not set
CONFIG_SENSORS_MCP3021=m
# CONFIG_SENSORS_TC654 is not set
# CONFIG_SENSORS_ADCXX is not set
CONFIG_SENSORS_LM63=m
# CONFIG_SENSORS_LM70 is not set
CONFIG_SENSORS_LM73=m
CONFIG_SENSORS_LM75=m
CONFIG_SENSORS_LM77=m
CONFIG_SENSORS_LM78=m
CONFIG_SENSORS_LM80=m
CONFIG_SENSORS_LM83=m
CONFIG_SENSORS_LM85=m
CONFIG_SENSORS_LM87=m
CONFIG_SENSORS_LM90=m
CONFIG_SENSORS_LM92=m
CONFIG_SENSORS_LM93=m
CONFIG_SENSORS_LM95234=m
CONFIG_SENSORS_LM95241=m
CONFIG_SENSORS_LM95245=m
CONFIG_SENSORS_PC87360=m
CONFIG_SENSORS_PC87427=m
CONFIG_SENSORS_NTC_THERMISTOR=m
# CONFIG_SENSORS_NCT6683 is not set
CONFIG_SENSORS_NCT6775=m
# CONFIG_SENSORS_NCT7802 is not set
# CONFIG_SENSORS_NCT7904 is not set
# CONFIG_SENSORS_NPCM7XX is not set
# CONFIG_SENSORS_OCC_P8_I2C is not set
CONFIG_SENSORS_PCF8591=m
CONFIG_PMBUS=m
CONFIG_SENSORS_PMBUS=m
CONFIG_SENSORS_ADM1275=m
# CONFIG_SENSORS_IBM_CFFPS is not set
# CONFIG_SENSORS_IR35221 is not set
CONFIG_SENSORS_LM25066=m
CONFIG_SENSORS_LTC2978=m
# CONFIG_SENSORS_LTC3815 is not set
CONFIG_SENSORS_MAX16064=m
# CONFIG_SENSORS_MAX20751 is not set
# CONFIG_SENSORS_MAX31785 is not set
CONFIG_SENSORS_MAX34440=m
CONFIG_SENSORS_MAX8688=m
# CONFIG_SENSORS_TPS40422 is not set
# CONFIG_SENSORS_TPS53679 is not set
CONFIG_SENSORS_UCD9000=m
CONFIG_SENSORS_UCD9200=m
CONFIG_SENSORS_ZL6100=m
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=m
# CONFIG_SENSORS_SHT3x is not set
# CONFIG_SENSORS_SHTC1 is not set
CONFIG_SENSORS_SIS5595=m
CONFIG_SENSORS_DME1737=m
CONFIG_SENSORS_EMC1403=m
# CONFIG_SENSORS_EMC2103 is not set
CONFIG_SENSORS_EMC6W201=m
CONFIG_SENSORS_SMSC47M1=m
CONFIG_SENSORS_SMSC47M192=m
CONFIG_SENSORS_SMSC47B397=m
CONFIG_SENSORS_SCH56XX_COMMON=m
CONFIG_SENSORS_SCH5627=m
CONFIG_SENSORS_SCH5636=m
# CONFIG_SENSORS_STTS751 is not set
# CONFIG_SENSORS_SMM665 is not set
# CONFIG_SENSORS_ADC128D818 is not set
CONFIG_SENSORS_ADS1015=m
CONFIG_SENSORS_ADS7828=m
# CONFIG_SENSORS_ADS7871 is not set
CONFIG_SENSORS_AMC6821=m
CONFIG_SENSORS_INA209=m
CONFIG_SENSORS_INA2XX=m
# CONFIG_SENSORS_INA3221 is not set
# CONFIG_SENSORS_TC74 is not set
CONFIG_SENSORS_THMC50=m
CONFIG_SENSORS_TMP102=m
# CONFIG_SENSORS_TMP103 is not set
# CONFIG_SENSORS_TMP108 is not set
CONFIG_SENSORS_TMP401=m
CONFIG_SENSORS_TMP421=m
CONFIG_SENSORS_VIA_CPUTEMP=m
CONFIG_SENSORS_VIA686A=m
CONFIG_SENSORS_VT1211=m
CONFIG_SENSORS_VT8231=m
# CONFIG_SENSORS_W83773G is not set
CONFIG_SENSORS_W83781D=m
CONFIG_SENSORS_W83791D=m
CONFIG_SENSORS_W83792D=m
CONFIG_SENSORS_W83793=m
CONFIG_SENSORS_W83795=m
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=m
CONFIG_SENSORS_W83L786NG=m
CONFIG_SENSORS_W83627HF=m
CONFIG_SENSORS_W83627EHF=m
# CONFIG_SENSORS_XGENE is not set

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=m
CONFIG_SENSORS_ATK0110=m
CONFIG_THERMAL=y
# CONFIG_THERMAL_STATISTICS is not set
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_WRITABLE_TRIPS=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_BANG_BANG=y
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
# CONFIG_CLOCK_THERMAL is not set
# CONFIG_DEVFREQ_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set

#
# Intel thermal drivers
#
CONFIG_INTEL_POWERCLAMP=m
CONFIG_X86_PKG_TEMP_THERMAL=m
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
CONFIG_INTEL_PCH_THERMAL=m
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set
CONFIG_WATCHDOG_HANDLE_BOOT_ENABLED=y
# CONFIG_WATCHDOG_SYSFS is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=m
CONFIG_WDAT_WDT=m
# CONFIG_XILINX_WATCHDOG is not set
# CONFIG_ZIIRAVE_WATCHDOG is not set
# CONFIG_CADENCE_WATCHDOG is not set
# CONFIG_DW_WATCHDOG is not set
# CONFIG_MAX63XX_WATCHDOG is not set
# CONFIG_ACQUIRE_WDT is not set
# CONFIG_ADVANTECH_WDT is not set
CONFIG_ALIM1535_WDT=m
CONFIG_ALIM7101_WDT=m
# CONFIG_EBC_C384_WDT is not set
CONFIG_F71808E_WDT=m
CONFIG_SP5100_TCO=m
CONFIG_SBC_FITPC2_WATCHDOG=m
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=m
CONFIG_IBMASR=m
# CONFIG_WAFER_WDT is not set
CONFIG_I6300ESB_WDT=y
CONFIG_IE6XX_WDT=m
CONFIG_ITCO_WDT=y
CONFIG_ITCO_VENDOR_SUPPORT=y
CONFIG_IT8712F_WDT=m
CONFIG_IT87_WDT=m
CONFIG_HP_WATCHDOG=m
CONFIG_HPWDT_NMI_DECODING=y
# CONFIG_SC1200_WDT is not set
# CONFIG_PC87413_WDT is not set
CONFIG_NV_TCO=m
# CONFIG_60XX_WDT is not set
# CONFIG_CPU5_WDT is not set
CONFIG_SMSC_SCH311X_WDT=m
# CONFIG_SMSC37B787_WDT is not set
# CONFIG_TQMX86_WDT is not set
CONFIG_VIA_WDT=m
CONFIG_W83627HF_WDT=m
CONFIG_W83877F_WDT=m
CONFIG_W83977F_WDT=m
CONFIG_MACHZ_WDT=m
# CONFIG_SBC_EPX_C3_WATCHDOG is not set
# CONFIG_INTEL_MEI_WDT is not set
# CONFIG_NI903X_WDT is not set
# CONFIG_NIC7018_WDT is not set
# CONFIG_MEN_A21_WDT is not set
CONFIG_XEN_WDT=m

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=m
CONFIG_WDTPCI=m

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=m

#
# Watchdog Pretimeout Governors
#
# CONFIG_WATCHDOG_PRETIMEOUT_GOV is not set
CONFIG_SSB_POSSIBLE=y
CONFIG_SSB=m
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y
CONFIG_BCMA=m
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
# CONFIG_MFD_AS3711 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_AAT2870_CORE is not set
# CONFIG_MFD_BCM590XX is not set
# CONFIG_MFD_BD9571MWV is not set
# CONFIG_MFD_AXP20X_I2C is not set
# CONFIG_MFD_CROS_EC is not set
# CONFIG_MFD_MADERA is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_SPI is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_DA9062 is not set
# CONFIG_MFD_DA9063 is not set
# CONFIG_MFD_DA9150 is not set
# CONFIG_MFD_DLN2 is not set
# CONFIG_MFD_MC13XXX_SPI is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_HTC_I2CPLD is not set
# CONFIG_MFD_INTEL_QUARK_I2C_GPIO is not set
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=m
# CONFIG_INTEL_SOC_PMIC is not set
# CONFIG_INTEL_SOC_PMIC_CHTWC is not set
# CONFIG_INTEL_SOC_PMIC_CHTDC_TI is not set
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
# CONFIG_MFD_INTEL_LPSS_PCI is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_KEMPLD is not set
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX14577 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX77843 is not set
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_MT6397 is not set
# CONFIG_MFD_MENF21BMC is not set
# CONFIG_EZX_PCAP is not set
CONFIG_MFD_VIPERBOARD=m
# CONFIG_MFD_RETU is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_UCB1400_CORE is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RT5033 is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_SI476X_CORE is not set
CONFIG_MFD_SM501=m
# CONFIG_MFD_SM501_GPIO is not set
# CONFIG_MFD_SKY81452 is not set
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_SYSCON is not set
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_MFD_LP3943 is not set
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_TI_LMU is not set
# CONFIG_MFD_PALMAS is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65086 is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS68470 is not set
# CONFIG_MFD_TI_LP873X is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
# CONFIG_MFD_TPS65912_I2C is not set
# CONFIG_MFD_TPS65912_SPI is not set
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_MFD_LM3533 is not set
CONFIG_MFD_VX855=m
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_ARIZONA_SPI is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM831X_SPI is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
# CONFIG_REGULATOR is not set
CONFIG_RC_CORE=m
CONFIG_RC_MAP=m
# CONFIG_LIRC is not set
CONFIG_RC_DECODERS=y
CONFIG_IR_NEC_DECODER=m
CONFIG_IR_RC5_DECODER=m
CONFIG_IR_RC6_DECODER=m
CONFIG_IR_JVC_DECODER=m
CONFIG_IR_SONY_DECODER=m
CONFIG_IR_SANYO_DECODER=m
CONFIG_IR_SHARP_DECODER=m
CONFIG_IR_MCE_KBD_DECODER=m
CONFIG_IR_XMP_DECODER=m
# CONFIG_IR_IMON_DECODER is not set
CONFIG_RC_DEVICES=y
CONFIG_RC_ATI_REMOTE=m
CONFIG_IR_ENE=m
CONFIG_IR_IMON=m
# CONFIG_IR_IMON_RAW is not set
CONFIG_IR_MCEUSB=m
CONFIG_IR_ITE_CIR=m
CONFIG_IR_FINTEK=m
CONFIG_IR_NUVOTON=m
CONFIG_IR_REDRAT3=m
CONFIG_IR_STREAMZAP=m
CONFIG_IR_WINBOND_CIR=m
# CONFIG_IR_IGORPLUGUSB is not set
CONFIG_IR_IGUANA=m
CONFIG_IR_TTUSBIR=m
CONFIG_RC_LOOPBACK=m
# CONFIG_IR_SERIAL is not set
# CONFIG_IR_SIR is not set
# CONFIG_RC_XBOX_DVD is not set
CONFIG_MEDIA_SUPPORT=m

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_SDR_SUPPORT is not set
# CONFIG_MEDIA_CEC_SUPPORT is not set
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=m
CONFIG_VIDEO_V4L2=m
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_VIDEO_TUNER=m
CONFIG_VIDEOBUF_GEN=m
CONFIG_VIDEOBUF_DMA_SG=m
CONFIG_VIDEOBUF_VMALLOC=m
CONFIG_DVB_CORE=m
# CONFIG_DVB_MMAP is not set
CONFIG_DVB_NET=y
CONFIG_TTPCI_EEPROM=m
CONFIG_DVB_MAX_ADAPTERS=8
CONFIG_DVB_DYNAMIC_MINORS=y
# CONFIG_DVB_DEMUX_SECTION_LOSS_LOG is not set
# CONFIG_DVB_ULE_DEBUG is not set

#
# Media drivers
#
CONFIG_MEDIA_USB_SUPPORT=y

#
# Webcam devices
#
CONFIG_USB_VIDEO_CLASS=m
CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV=y
CONFIG_USB_GSPCA=m
CONFIG_USB_M5602=m
CONFIG_USB_STV06XX=m
CONFIG_USB_GL860=m
CONFIG_USB_GSPCA_BENQ=m
CONFIG_USB_GSPCA_CONEX=m
CONFIG_USB_GSPCA_CPIA1=m
# CONFIG_USB_GSPCA_DTCS033 is not set
CONFIG_USB_GSPCA_ETOMS=m
CONFIG_USB_GSPCA_FINEPIX=m
CONFIG_USB_GSPCA_JEILINJ=m
CONFIG_USB_GSPCA_JL2005BCD=m
# CONFIG_USB_GSPCA_KINECT is not set
CONFIG_USB_GSPCA_KONICA=m
CONFIG_USB_GSPCA_MARS=m
CONFIG_USB_GSPCA_MR97310A=m
CONFIG_USB_GSPCA_NW80X=m
CONFIG_USB_GSPCA_OV519=m
CONFIG_USB_GSPCA_OV534=m
CONFIG_USB_GSPCA_OV534_9=m
CONFIG_USB_GSPCA_PAC207=m
CONFIG_USB_GSPCA_PAC7302=m
CONFIG_USB_GSPCA_PAC7311=m
CONFIG_USB_GSPCA_SE401=m
CONFIG_USB_GSPCA_SN9C2028=m
CONFIG_USB_GSPCA_SN9C20X=m
CONFIG_USB_GSPCA_SONIXB=m
CONFIG_USB_GSPCA_SONIXJ=m
CONFIG_USB_GSPCA_SPCA500=m
CONFIG_USB_GSPCA_SPCA501=m
CONFIG_USB_GSPCA_SPCA505=m
CONFIG_USB_GSPCA_SPCA506=m
CONFIG_USB_GSPCA_SPCA508=m
CONFIG_USB_GSPCA_SPCA561=m
CONFIG_USB_GSPCA_SPCA1528=m
CONFIG_USB_GSPCA_SQ905=m
CONFIG_USB_GSPCA_SQ905C=m
CONFIG_USB_GSPCA_SQ930X=m
CONFIG_USB_GSPCA_STK014=m
# CONFIG_USB_GSPCA_STK1135 is not set
CONFIG_USB_GSPCA_STV0680=m
CONFIG_USB_GSPCA_SUNPLUS=m
CONFIG_USB_GSPCA_T613=m
CONFIG_USB_GSPCA_TOPRO=m
# CONFIG_USB_GSPCA_TOUPTEK is not set
CONFIG_USB_GSPCA_TV8532=m
CONFIG_USB_GSPCA_VC032X=m
CONFIG_USB_GSPCA_VICAM=m
CONFIG_USB_GSPCA_XIRLINK_CIT=m
CONFIG_USB_GSPCA_ZC3XX=m
CONFIG_USB_PWC=m
# CONFIG_USB_PWC_DEBUG is not set
CONFIG_USB_PWC_INPUT_EVDEV=y
# CONFIG_VIDEO_CPIA2 is not set
CONFIG_USB_ZR364XX=m
CONFIG_USB_STKWEBCAM=m
CONFIG_USB_S2255=m
# CONFIG_VIDEO_USBTV is not set

#
# Analog TV USB devices
#
CONFIG_VIDEO_PVRUSB2=m
CONFIG_VIDEO_PVRUSB2_SYSFS=y
CONFIG_VIDEO_PVRUSB2_DVB=y
# CONFIG_VIDEO_PVRUSB2_DEBUGIFC is not set
CONFIG_VIDEO_HDPVR=m
CONFIG_VIDEO_USBVISION=m
# CONFIG_VIDEO_STK1160_COMMON is not set
# CONFIG_VIDEO_GO7007 is not set

#
# Analog/digital TV USB devices
#
CONFIG_VIDEO_AU0828=m
CONFIG_VIDEO_AU0828_V4L2=y
# CONFIG_VIDEO_AU0828_RC is not set
CONFIG_VIDEO_CX231XX=m
CONFIG_VIDEO_CX231XX_RC=y
CONFIG_VIDEO_CX231XX_ALSA=m
CONFIG_VIDEO_CX231XX_DVB=m
CONFIG_VIDEO_TM6000=m
CONFIG_VIDEO_TM6000_ALSA=m
CONFIG_VIDEO_TM6000_DVB=m

#
# Digital TV USB devices
#
CONFIG_DVB_USB=m
# CONFIG_DVB_USB_DEBUG is not set
CONFIG_DVB_USB_DIB3000MC=m
CONFIG_DVB_USB_A800=m
CONFIG_DVB_USB_DIBUSB_MB=m
# CONFIG_DVB_USB_DIBUSB_MB_FAULTY is not set
CONFIG_DVB_USB_DIBUSB_MC=m
CONFIG_DVB_USB_DIB0700=m
CONFIG_DVB_USB_UMT_010=m
CONFIG_DVB_USB_CXUSB=m
CONFIG_DVB_USB_M920X=m
CONFIG_DVB_USB_DIGITV=m
CONFIG_DVB_USB_VP7045=m
CONFIG_DVB_USB_VP702X=m
CONFIG_DVB_USB_GP8PSK=m
CONFIG_DVB_USB_NOVA_T_USB2=m
CONFIG_DVB_USB_TTUSB2=m
CONFIG_DVB_USB_DTT200U=m
CONFIG_DVB_USB_OPERA1=m
CONFIG_DVB_USB_AF9005=m
CONFIG_DVB_USB_AF9005_REMOTE=m
CONFIG_DVB_USB_PCTV452E=m
CONFIG_DVB_USB_DW2102=m
CONFIG_DVB_USB_CINERGY_T2=m
CONFIG_DVB_USB_DTV5100=m
CONFIG_DVB_USB_AZ6027=m
CONFIG_DVB_USB_TECHNISAT_USB2=m
CONFIG_DVB_USB_V2=m
CONFIG_DVB_USB_AF9015=m
CONFIG_DVB_USB_AF9035=m
CONFIG_DVB_USB_ANYSEE=m
CONFIG_DVB_USB_AU6610=m
CONFIG_DVB_USB_AZ6007=m
CONFIG_DVB_USB_CE6230=m
CONFIG_DVB_USB_EC168=m
CONFIG_DVB_USB_GL861=m
CONFIG_DVB_USB_LME2510=m
CONFIG_DVB_USB_MXL111SF=m
CONFIG_DVB_USB_RTL28XXU=m
# CONFIG_DVB_USB_DVBSKY is not set
# CONFIG_DVB_USB_ZD1301 is not set
CONFIG_DVB_TTUSB_BUDGET=m
CONFIG_DVB_TTUSB_DEC=m
CONFIG_SMS_USB_DRV=m
CONFIG_DVB_B2C2_FLEXCOP_USB=m
# CONFIG_DVB_B2C2_FLEXCOP_USB_DEBUG is not set
# CONFIG_DVB_AS102 is not set

#
# Webcam, TV (analog/digital) USB devices
#
CONFIG_VIDEO_EM28XX=m
# CONFIG_VIDEO_EM28XX_V4L2 is not set
CONFIG_VIDEO_EM28XX_ALSA=m
CONFIG_VIDEO_EM28XX_DVB=m
CONFIG_VIDEO_EM28XX_RC=m
CONFIG_MEDIA_PCI_SUPPORT=y

#
# Media capture support
#
# CONFIG_VIDEO_MEYE is not set
# CONFIG_VIDEO_SOLO6X10 is not set
# CONFIG_VIDEO_TW5864 is not set
# CONFIG_VIDEO_TW68 is not set
# CONFIG_VIDEO_TW686X is not set

#
# Media capture/analog TV support
#
CONFIG_VIDEO_IVTV=m
# CONFIG_VIDEO_IVTV_DEPRECATED_IOCTLS is not set
# CONFIG_VIDEO_IVTV_ALSA is not set
CONFIG_VIDEO_FB_IVTV=m
# CONFIG_VIDEO_HEXIUM_GEMINI is not set
# CONFIG_VIDEO_HEXIUM_ORION is not set
# CONFIG_VIDEO_MXB is not set
# CONFIG_VIDEO_DT3155 is not set

#
# Media capture/analog/hybrid TV support
#
CONFIG_VIDEO_CX18=m
CONFIG_VIDEO_CX18_ALSA=m
CONFIG_VIDEO_CX23885=m
CONFIG_MEDIA_ALTERA_CI=m
# CONFIG_VIDEO_CX25821 is not set
CONFIG_VIDEO_CX88=m
CONFIG_VIDEO_CX88_ALSA=m
CONFIG_VIDEO_CX88_BLACKBIRD=m
CONFIG_VIDEO_CX88_DVB=m
CONFIG_VIDEO_CX88_ENABLE_VP3054=y
CONFIG_VIDEO_CX88_VP3054=m
CONFIG_VIDEO_CX88_MPEG=m
CONFIG_VIDEO_BT848=m
CONFIG_DVB_BT8XX=m
CONFIG_VIDEO_SAA7134=m
CONFIG_VIDEO_SAA7134_ALSA=m
CONFIG_VIDEO_SAA7134_RC=y
CONFIG_VIDEO_SAA7134_DVB=m
CONFIG_VIDEO_SAA7164=m

#
# Media digital TV PCI Adapters
#
CONFIG_DVB_AV7110_IR=y
CONFIG_DVB_AV7110=m
CONFIG_DVB_AV7110_OSD=y
CONFIG_DVB_BUDGET_CORE=m
CONFIG_DVB_BUDGET=m
CONFIG_DVB_BUDGET_CI=m
CONFIG_DVB_BUDGET_AV=m
CONFIG_DVB_BUDGET_PATCH=m
CONFIG_DVB_B2C2_FLEXCOP_PCI=m
# CONFIG_DVB_B2C2_FLEXCOP_PCI_DEBUG is not set
CONFIG_DVB_PLUTO2=m
CONFIG_DVB_DM1105=m
CONFIG_DVB_PT1=m
# CONFIG_DVB_PT3 is not set
CONFIG_MANTIS_CORE=m
CONFIG_DVB_MANTIS=m
CONFIG_DVB_HOPPER=m
CONFIG_DVB_NGENE=m
CONFIG_DVB_DDBRIDGE=m
# CONFIG_DVB_DDBRIDGE_MSIENABLE is not set
# CONFIG_DVB_SMIPCIE is not set
# CONFIG_DVB_NETUP_UNIDVB is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
# CONFIG_V4L_TEST_DRIVERS is not set
# CONFIG_DVB_PLATFORM_DRIVERS is not set

#
# Supported MMC/SDIO adapters
#
CONFIG_SMS_SDIO_DRV=m
CONFIG_RADIO_ADAPTERS=y
CONFIG_RADIO_TEA575X=m
# CONFIG_RADIO_SI470X is not set
# CONFIG_RADIO_SI4713 is not set
# CONFIG_USB_MR800 is not set
# CONFIG_USB_DSBR is not set
# CONFIG_RADIO_MAXIRADIO is not set
# CONFIG_RADIO_SHARK is not set
# CONFIG_RADIO_SHARK2 is not set
# CONFIG_USB_KEENE is not set
# CONFIG_USB_RAREMONO is not set
# CONFIG_USB_MA901 is not set
# CONFIG_RADIO_TEA5764 is not set
# CONFIG_RADIO_SAA7706H is not set
# CONFIG_RADIO_TEF6862 is not set
# CONFIG_RADIO_WL1273 is not set

#
# Texas Instruments WL128x FM driver (ST based)
#

#
# Supported FireWire (IEEE 1394) Adapters
#
CONFIG_DVB_FIREDTV=m
CONFIG_DVB_FIREDTV_INPUT=y
CONFIG_MEDIA_COMMON_OPTIONS=y

#
# common driver options
#
CONFIG_VIDEO_CX2341X=m
CONFIG_VIDEO_TVEEPROM=m
CONFIG_CYPRESS_FIRMWARE=m
CONFIG_VIDEOBUF2_CORE=m
CONFIG_VIDEOBUF2_V4L2=m
CONFIG_VIDEOBUF2_MEMOPS=m
CONFIG_VIDEOBUF2_VMALLOC=m
CONFIG_VIDEOBUF2_DMA_SG=m
CONFIG_VIDEOBUF2_DVB=m
CONFIG_DVB_B2C2_FLEXCOP=m
CONFIG_VIDEO_SAA7146=m
CONFIG_VIDEO_SAA7146_VV=m
CONFIG_SMS_SIANO_MDTV=m
CONFIG_SMS_SIANO_RC=y
# CONFIG_SMS_SIANO_DEBUGFS is not set

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y
CONFIG_MEDIA_ATTACH=y
CONFIG_VIDEO_IR_I2C=m

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TVAUDIO=m
CONFIG_VIDEO_TDA7432=m
CONFIG_VIDEO_MSP3400=m
CONFIG_VIDEO_CS3308=m
CONFIG_VIDEO_CS5345=m
CONFIG_VIDEO_CS53L32A=m
CONFIG_VIDEO_WM8775=m
CONFIG_VIDEO_WM8739=m
CONFIG_VIDEO_VP27SMPX=m

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=m

#
# Video decoders
#
CONFIG_VIDEO_SAA711X=m

#
# Video and audio decoders
#
CONFIG_VIDEO_SAA717X=m
CONFIG_VIDEO_CX25840=m

#
# Video encoders
#
CONFIG_VIDEO_SAA7127=m

#
# Camera sensor devices
#

#
# Flash devices
#

#
# Video improvement chips
#
CONFIG_VIDEO_UPD64031A=m
CONFIG_VIDEO_UPD64083=m

#
# Audio/Video compression chips
#
CONFIG_VIDEO_SAA6752HS=m

#
# SDR tuner chips
#

#
# Miscellaneous helper chips
#
CONFIG_VIDEO_M52790=m

#
# Sensors used on soc_camera driver
#

#
# Media SPI Adapters
#
# CONFIG_CXD2880_SPI_DRV is not set
CONFIG_MEDIA_TUNER=m
CONFIG_MEDIA_TUNER_SIMPLE=m
CONFIG_MEDIA_TUNER_TDA18250=m
CONFIG_MEDIA_TUNER_TDA8290=m
CONFIG_MEDIA_TUNER_TDA827X=m
CONFIG_MEDIA_TUNER_TDA18271=m
CONFIG_MEDIA_TUNER_TDA9887=m
CONFIG_MEDIA_TUNER_TEA5761=m
CONFIG_MEDIA_TUNER_TEA5767=m
CONFIG_MEDIA_TUNER_MT20XX=m
CONFIG_MEDIA_TUNER_MT2060=m
CONFIG_MEDIA_TUNER_MT2063=m
CONFIG_MEDIA_TUNER_MT2266=m
CONFIG_MEDIA_TUNER_MT2131=m
CONFIG_MEDIA_TUNER_QT1010=m
CONFIG_MEDIA_TUNER_XC2028=m
CONFIG_MEDIA_TUNER_XC5000=m
CONFIG_MEDIA_TUNER_XC4000=m
CONFIG_MEDIA_TUNER_MXL5005S=m
CONFIG_MEDIA_TUNER_MXL5007T=m
CONFIG_MEDIA_TUNER_MC44S803=m
CONFIG_MEDIA_TUNER_MAX2165=m
CONFIG_MEDIA_TUNER_TDA18218=m
CONFIG_MEDIA_TUNER_FC0011=m
CONFIG_MEDIA_TUNER_FC0012=m
CONFIG_MEDIA_TUNER_FC0013=m
CONFIG_MEDIA_TUNER_TDA18212=m
CONFIG_MEDIA_TUNER_E4000=m
CONFIG_MEDIA_TUNER_FC2580=m
CONFIG_MEDIA_TUNER_M88RS6000T=m
CONFIG_MEDIA_TUNER_TUA9001=m
CONFIG_MEDIA_TUNER_SI2157=m
CONFIG_MEDIA_TUNER_IT913X=m
CONFIG_MEDIA_TUNER_R820T=m
CONFIG_MEDIA_TUNER_QM1D1C0042=m
CONFIG_MEDIA_TUNER_QM1D1B0004=m

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STB0899=m
CONFIG_DVB_STB6100=m
CONFIG_DVB_STV090x=m
CONFIG_DVB_STV0910=m
CONFIG_DVB_STV6110x=m
CONFIG_DVB_STV6111=m
CONFIG_DVB_MXL5XX=m
CONFIG_DVB_M88DS3103=m

#
# Multistandard (cable + terrestrial) frontends
#
CONFIG_DVB_DRXK=m
CONFIG_DVB_TDA18271C2DD=m
CONFIG_DVB_SI2165=m
CONFIG_DVB_MN88472=m
CONFIG_DVB_MN88473=m

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24110=m
CONFIG_DVB_CX24123=m
CONFIG_DVB_MT312=m
CONFIG_DVB_ZL10036=m
CONFIG_DVB_ZL10039=m
CONFIG_DVB_S5H1420=m
CONFIG_DVB_STV0288=m
CONFIG_DVB_STB6000=m
CONFIG_DVB_STV0299=m
CONFIG_DVB_STV6110=m
CONFIG_DVB_STV0900=m
CONFIG_DVB_TDA8083=m
CONFIG_DVB_TDA10086=m
CONFIG_DVB_TDA8261=m
CONFIG_DVB_VES1X93=m
CONFIG_DVB_TUNER_ITD1000=m
CONFIG_DVB_TUNER_CX24113=m
CONFIG_DVB_TDA826X=m
CONFIG_DVB_TUA6100=m
CONFIG_DVB_CX24116=m
CONFIG_DVB_CX24117=m
CONFIG_DVB_CX24120=m
CONFIG_DVB_SI21XX=m
CONFIG_DVB_TS2020=m
CONFIG_DVB_DS3000=m
CONFIG_DVB_MB86A16=m
CONFIG_DVB_TDA10071=m

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_SP8870=m
CONFIG_DVB_SP887X=m
CONFIG_DVB_CX22700=m
CONFIG_DVB_CX22702=m
CONFIG_DVB_DRXD=m
CONFIG_DVB_L64781=m
CONFIG_DVB_TDA1004X=m
CONFIG_DVB_NXT6000=m
CONFIG_DVB_MT352=m
CONFIG_DVB_ZL10353=m
CONFIG_DVB_DIB3000MB=m
CONFIG_DVB_DIB3000MC=m
CONFIG_DVB_DIB7000M=m
CONFIG_DVB_DIB7000P=m
CONFIG_DVB_TDA10048=m
CONFIG_DVB_AF9013=m
CONFIG_DVB_EC100=m
CONFIG_DVB_STV0367=m
CONFIG_DVB_CXD2820R=m
CONFIG_DVB_CXD2841ER=m
CONFIG_DVB_RTL2830=m
CONFIG_DVB_RTL2832=m
CONFIG_DVB_SI2168=m
CONFIG_DVB_GP8PSK_FE=m

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=m
CONFIG_DVB_TDA10021=m
CONFIG_DVB_TDA10023=m
CONFIG_DVB_STV0297=m

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=m
CONFIG_DVB_OR51211=m
CONFIG_DVB_OR51132=m
CONFIG_DVB_BCM3510=m
CONFIG_DVB_LGDT330X=m
CONFIG_DVB_LGDT3305=m
CONFIG_DVB_LGDT3306A=m
CONFIG_DVB_LG2160=m
CONFIG_DVB_S5H1409=m
CONFIG_DVB_AU8522=m
CONFIG_DVB_AU8522_DTV=m
CONFIG_DVB_AU8522_V4L=m
CONFIG_DVB_S5H1411=m

#
# ISDB-T (terrestrial) frontends
#
CONFIG_DVB_S921=m
CONFIG_DVB_DIB8000=m
CONFIG_DVB_MB86A20S=m

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#
CONFIG_DVB_TC90522=m

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=m
CONFIG_DVB_TUNER_DIB0070=m
CONFIG_DVB_TUNER_DIB0090=m

#
# SEC control devices for DVB-S
#
CONFIG_DVB_DRX39XYJ=m
CONFIG_DVB_LNBH25=m
CONFIG_DVB_LNBP21=m
CONFIG_DVB_LNBP22=m
CONFIG_DVB_ISL6405=m
CONFIG_DVB_ISL6421=m
CONFIG_DVB_ISL6423=m
CONFIG_DVB_A8293=m
CONFIG_DVB_LGS8GXX=m
CONFIG_DVB_ATBM8830=m
CONFIG_DVB_TDA665x=m
CONFIG_DVB_IX2505V=m
CONFIG_DVB_M88RS2000=m
CONFIG_DVB_AF9033=m

#
# Common Interface (EN50221) controller drivers
#
CONFIG_DVB_CXD2099=m

#
# Tools to develop new frontends
#
CONFIG_DVB_DUMMY_FE=m

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
CONFIG_AGP_INTEL=y
CONFIG_AGP_SIS=y
CONFIG_AGP_VIA=y
CONFIG_INTEL_GTT=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=64
CONFIG_VGA_SWITCHEROO=y
CONFIG_DRM=m
CONFIG_DRM_MIPI_DSI=y
# CONFIG_DRM_DP_AUX_CHARDEV is not set
CONFIG_DRM_DEBUG_SELFTEST=m
CONFIG_DRM_KMS_HELPER=m
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DRM_FBDEV_OVERALLOC=100
# CONFIG_DRM_FBDEV_LEAK_PHYS_SMEM is not set
CONFIG_DRM_LOAD_EDID_FIRMWARE=y
# CONFIG_DRM_DP_CEC is not set
CONFIG_DRM_TTM=m

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=m
CONFIG_DRM_I2C_SIL164=m
CONFIG_DRM_I2C_NXP_TDA998X=m
# CONFIG_DRM_I2C_NXP_TDA9950 is not set
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
# CONFIG_DRM_I915_ALPHA_SUPPORT is not set
CONFIG_DRM_I915_CAPTURE_ERROR=y
CONFIG_DRM_I915_COMPRESS_ERROR=y
CONFIG_DRM_I915_USERPTR=y
# CONFIG_DRM_I915_GVT is not set

#
# drm/i915 Debugging
#
# CONFIG_DRM_I915_WERROR is not set
# CONFIG_DRM_I915_DEBUG is not set
# CONFIG_DRM_I915_SW_FENCE_DEBUG_OBJECTS is not set
# CONFIG_DRM_I915_SW_FENCE_CHECK_DAG is not set
# CONFIG_DRM_I915_DEBUG_GUC is not set
# CONFIG_DRM_I915_SELFTEST is not set
# CONFIG_DRM_I915_LOW_LEVEL_TRACEPOINTS is not set
# CONFIG_DRM_I915_DEBUG_VBLANK_EVADE is not set
# CONFIG_DRM_I915_DEBUG_RUNTIME_PM is not set
CONFIG_DRM_VGEM=m
# CONFIG_DRM_VKMS is not set
CONFIG_DRM_VMWGFX=m
CONFIG_DRM_VMWGFX_FBCON=y
CONFIG_DRM_GMA500=m
CONFIG_DRM_GMA600=y
CONFIG_DRM_GMA3600=y
CONFIG_DRM_UDL=m
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
# CONFIG_DRM_PANEL_RASPBERRYPI_TOUCHSCREEN is not set
CONFIG_DRM_BRIDGE=y
CONFIG_DRM_PANEL_BRIDGE=y

#
# Display Interface Bridges
#
# CONFIG_DRM_ANALOGIX_ANX78XX is not set
# CONFIG_DRM_HISI_HIBMC is not set
# CONFIG_DRM_TINYDRM is not set
# CONFIG_DRM_XEN is not set
# CONFIG_DRM_LEGACY is not set
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
CONFIG_FB_SYS_FILLRECT=m
CONFIG_FB_SYS_COPYAREA=m
CONFIG_FB_SYS_IMAGEBLIT=m
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=m
CONFIG_FB_DEFERRED_IO=y
# CONFIG_FB_MODE_HELPERS is not set
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
CONFIG_FB_VESA=y
CONFIG_FB_EFI=y
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
# CONFIG_FB_OPENCORES is not set
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_INTEL is not set
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
# CONFIG_FB_SMSCUFX is not set
# CONFIG_FB_UDL is not set
# CONFIG_FB_IBM_GXT4500 is not set
# CONFIG_FB_VIRTUAL is not set
# CONFIG_XEN_FBDEV_FRONTEND is not set
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
CONFIG_FB_HYPERV=m
# CONFIG_FB_SIMPLE is not set
# CONFIG_FB_SM712 is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=m
# CONFIG_LCD_L4F00242T03 is not set
# CONFIG_LCD_LMS283GF05 is not set
# CONFIG_LCD_LTV350QV is not set
# CONFIG_LCD_ILI922X is not set
# CONFIG_LCD_ILI9320 is not set
# CONFIG_LCD_TDO24M is not set
# CONFIG_LCD_VGG2432A4 is not set
CONFIG_LCD_PLATFORM=m
# CONFIG_LCD_AMS369FG06 is not set
# CONFIG_LCD_LMS501KF03 is not set
# CONFIG_LCD_HX8357 is not set
# CONFIG_LCD_OTM3225A is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
# CONFIG_BACKLIGHT_PWM is not set
CONFIG_BACKLIGHT_APPLE=m
# CONFIG_BACKLIGHT_PM8941_WLED is not set
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_LM3630A is not set
# CONFIG_BACKLIGHT_LM3639 is not set
# CONFIG_BACKLIGHT_LP855X is not set
# CONFIG_BACKLIGHT_GPIO is not set
# CONFIG_BACKLIGHT_LV5207LP is not set
# CONFIG_BACKLIGHT_BD6107 is not set
# CONFIG_BACKLIGHT_ARCXCNN is not set
CONFIG_HDMI=y

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
# CONFIG_VGACON_SOFT_SCROLLBACK_PERSISTENT_ENABLE_BY_DEFAULT is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_DUMMY_CONSOLE_COLUMNS=80
CONFIG_DUMMY_CONSOLE_ROWS=25
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
# CONFIG_FRAMEBUFFER_CONSOLE_DEFERRED_TAKEOVER is not set
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
# CONFIG_LOGO_LINUX_VGA16 is not set
CONFIG_LOGO_LINUX_CLUT224=y
CONFIG_SOUND=m
CONFIG_SOUND_OSS_CORE=y
CONFIG_SOUND_OSS_CORE_PRECLAIM=y
CONFIG_SND=m
CONFIG_SND_TIMER=m
CONFIG_SND_PCM=m
CONFIG_SND_HWDEP=m
CONFIG_SND_SEQ_DEVICE=m
CONFIG_SND_RAWMIDI=m
CONFIG_SND_JACK=y
CONFIG_SND_JACK_INPUT_DEV=y
CONFIG_SND_OSSEMUL=y
# CONFIG_SND_MIXER_OSS is not set
# CONFIG_SND_PCM_OSS is not set
CONFIG_SND_PCM_TIMER=y
CONFIG_SND_HRTIMER=m
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_MAX_CARDS=32
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_PROC_FS=y
CONFIG_SND_VERBOSE_PROCFS=y
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_SEQUENCER=m
CONFIG_SND_SEQ_DUMMY=m
CONFIG_SND_SEQUENCER_OSS=m
CONFIG_SND_SEQ_HRTIMER_DEFAULT=y
CONFIG_SND_SEQ_MIDI_EVENT=m
CONFIG_SND_SEQ_MIDI=m
CONFIG_SND_SEQ_MIDI_EMUL=m
CONFIG_SND_SEQ_VIRMIDI=m
CONFIG_SND_MPU401_UART=m
CONFIG_SND_OPL3_LIB=m
CONFIG_SND_OPL3_LIB_SEQ=m
CONFIG_SND_VX_LIB=m
CONFIG_SND_AC97_CODEC=m
CONFIG_SND_DRIVERS=y
CONFIG_SND_PCSP=m
CONFIG_SND_DUMMY=m
CONFIG_SND_ALOOP=m
CONFIG_SND_VIRMIDI=m
CONFIG_SND_MTPAV=m
# CONFIG_SND_MTS64 is not set
# CONFIG_SND_SERIAL_U16550 is not set
CONFIG_SND_MPU401=m
# CONFIG_SND_PORTMAN2X4 is not set
CONFIG_SND_AC97_POWER_SAVE=y
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=5
CONFIG_SND_PCI=y
CONFIG_SND_AD1889=m
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALS4000 is not set
CONFIG_SND_ALI5451=m
CONFIG_SND_ASIHPI=m
CONFIG_SND_ATIIXP=m
CONFIG_SND_ATIIXP_MODEM=m
CONFIG_SND_AU8810=m
CONFIG_SND_AU8820=m
CONFIG_SND_AU8830=m
# CONFIG_SND_AW2 is not set
# CONFIG_SND_AZT3328 is not set
CONFIG_SND_BT87X=m
# CONFIG_SND_BT87X_OVERCLOCK is not set
CONFIG_SND_CA0106=m
CONFIG_SND_CMIPCI=m
CONFIG_SND_OXYGEN_LIB=m
CONFIG_SND_OXYGEN=m
# CONFIG_SND_CS4281 is not set
CONFIG_SND_CS46XX=m
CONFIG_SND_CS46XX_NEW_DSP=y
CONFIG_SND_CTXFI=m
CONFIG_SND_DARLA20=m
CONFIG_SND_GINA20=m
CONFIG_SND_LAYLA20=m
CONFIG_SND_DARLA24=m
CONFIG_SND_GINA24=m
CONFIG_SND_LAYLA24=m
CONFIG_SND_MONA=m
CONFIG_SND_MIA=m
CONFIG_SND_ECHO3G=m
CONFIG_SND_INDIGO=m
CONFIG_SND_INDIGOIO=m
CONFIG_SND_INDIGODJ=m
CONFIG_SND_INDIGOIOX=m
CONFIG_SND_INDIGODJX=m
CONFIG_SND_EMU10K1=m
CONFIG_SND_EMU10K1_SEQ=m
CONFIG_SND_EMU10K1X=m
CONFIG_SND_ENS1370=m
CONFIG_SND_ENS1371=m
# CONFIG_SND_ES1938 is not set
CONFIG_SND_ES1968=m
CONFIG_SND_ES1968_INPUT=y
CONFIG_SND_ES1968_RADIO=y
# CONFIG_SND_FM801 is not set
CONFIG_SND_HDSP=m
CONFIG_SND_HDSPM=m
CONFIG_SND_ICE1712=m
CONFIG_SND_ICE1724=m
CONFIG_SND_INTEL8X0=m
CONFIG_SND_INTEL8X0M=m
CONFIG_SND_KORG1212=m
CONFIG_SND_LOLA=m
CONFIG_SND_LX6464ES=m
CONFIG_SND_MAESTRO3=m
CONFIG_SND_MAESTRO3_INPUT=y
CONFIG_SND_MIXART=m
# CONFIG_SND_NM256 is not set
CONFIG_SND_PCXHR=m
# CONFIG_SND_RIPTIDE is not set
CONFIG_SND_RME32=m
CONFIG_SND_RME96=m
CONFIG_SND_RME9652=m
# CONFIG_SND_SONICVIBES is not set
CONFIG_SND_TRIDENT=m
CONFIG_SND_VIA82XX=m
CONFIG_SND_VIA82XX_MODEM=m
CONFIG_SND_VIRTUOSO=m
CONFIG_SND_VX222=m
# CONFIG_SND_YMFPCI is not set

#
# HD-Audio
#
CONFIG_SND_HDA=m
CONFIG_SND_HDA_INTEL=m
CONFIG_SND_HDA_HWDEP=y
# CONFIG_SND_HDA_RECONFIG is not set
CONFIG_SND_HDA_INPUT_BEEP=y
CONFIG_SND_HDA_INPUT_BEEP_MODE=0
# CONFIG_SND_HDA_PATCH_LOADER is not set
CONFIG_SND_HDA_CODEC_REALTEK=m
CONFIG_SND_HDA_CODEC_ANALOG=m
CONFIG_SND_HDA_CODEC_SIGMATEL=m
CONFIG_SND_HDA_CODEC_VIA=m
CONFIG_SND_HDA_CODEC_HDMI=m
CONFIG_SND_HDA_CODEC_CIRRUS=m
CONFIG_SND_HDA_CODEC_CONEXANT=m
CONFIG_SND_HDA_CODEC_CA0110=m
CONFIG_SND_HDA_CODEC_CA0132=m
CONFIG_SND_HDA_CODEC_CA0132_DSP=y
CONFIG_SND_HDA_CODEC_CMEDIA=m
CONFIG_SND_HDA_CODEC_SI3054=m
CONFIG_SND_HDA_GENERIC=m
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
CONFIG_SND_HDA_CORE=m
CONFIG_SND_HDA_DSP_LOADER=y
CONFIG_SND_HDA_COMPONENT=y
CONFIG_SND_HDA_I915=y
CONFIG_SND_HDA_PREALLOC_SIZE=512
CONFIG_SND_SPI=y
CONFIG_SND_USB=y
CONFIG_SND_USB_AUDIO=m
CONFIG_SND_USB_UA101=m
CONFIG_SND_USB_USX2Y=m
CONFIG_SND_USB_CAIAQ=m
CONFIG_SND_USB_CAIAQ_INPUT=y
CONFIG_SND_USB_US122L=m
CONFIG_SND_USB_6FIRE=m
# CONFIG_SND_USB_HIFACE is not set
# CONFIG_SND_BCD2000 is not set
# CONFIG_SND_USB_POD is not set
# CONFIG_SND_USB_PODHD is not set
# CONFIG_SND_USB_TONEPORT is not set
# CONFIG_SND_USB_VARIAX is not set
CONFIG_SND_FIREWIRE=y
CONFIG_SND_FIREWIRE_LIB=m
# CONFIG_SND_DICE is not set
# CONFIG_SND_OXFW is not set
CONFIG_SND_ISIGHT=m
# CONFIG_SND_FIREWORKS is not set
# CONFIG_SND_BEBOB is not set
# CONFIG_SND_FIREWIRE_DIGI00X is not set
# CONFIG_SND_FIREWIRE_TASCAM is not set
# CONFIG_SND_FIREWIRE_MOTU is not set
# CONFIG_SND_FIREFACE is not set
# CONFIG_SND_SOC is not set
CONFIG_SND_X86=y
# CONFIG_HDMI_LPE_AUDIO is not set
CONFIG_SND_SYNTH_EMUX=m
# CONFIG_SND_XEN_FRONTEND is not set
CONFIG_AC97_BUS=m

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
CONFIG_HIDRAW=y
CONFIG_UHID=m
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACCUTOUCH is not set
CONFIG_HID_ACRUX=m
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
CONFIG_HID_APPLEIR=m
# CONFIG_HID_ASUS is not set
CONFIG_HID_AUREAL=m
CONFIG_HID_BELKIN=y
# CONFIG_HID_BETOP_FF is not set
# CONFIG_HID_BIGBEN_FF is not set
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
# CONFIG_HID_CORSAIR is not set
# CONFIG_HID_COUGAR is not set
CONFIG_HID_PRODIKEYS=m
# CONFIG_HID_CMEDIA is not set
# CONFIG_HID_CP2112 is not set
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=m
# CONFIG_DRAGONRISE_FF is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELAN is not set
CONFIG_HID_ELECOM=m
# CONFIG_HID_ELO is not set
CONFIG_HID_EZKEY=y
# CONFIG_HID_GEMBIRD is not set
# CONFIG_HID_GFRM is not set
CONFIG_HID_HOLTEK=m
# CONFIG_HOLTEK_FF is not set
# CONFIG_HID_GT683R is not set
CONFIG_HID_KEYTOUCH=m
CONFIG_HID_KYE=m
CONFIG_HID_UCLOGIC=m
CONFIG_HID_WALTOP=m
CONFIG_HID_GYRATION=m
CONFIG_HID_ICADE=m
# CONFIG_HID_ITE is not set
# CONFIG_HID_JABRA is not set
CONFIG_HID_TWINHAN=m
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=m
CONFIG_HID_LED=m
# CONFIG_HID_LENOVO is not set
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=m
CONFIG_HID_LOGITECH_HIDPP=m
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
# CONFIG_LOGIWHEELS_FF is not set
CONFIG_HID_MAGICMOUSE=y
# CONFIG_HID_MAYFLASH is not set
# CONFIG_HID_REDRAGON is not set
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=m
# CONFIG_HID_NTI is not set
CONFIG_HID_NTRIG=y
CONFIG_HID_ORTEK=m
CONFIG_HID_PANTHERLORD=m
# CONFIG_PANTHERLORD_FF is not set
# CONFIG_HID_PENMOUNT is not set
CONFIG_HID_PETALYNX=m
CONFIG_HID_PICOLCD=m
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LCD=y
CONFIG_HID_PICOLCD_LEDS=y
CONFIG_HID_PICOLCD_CIR=y
CONFIG_HID_PLANTRONICS=y
CONFIG_HID_PRIMAX=m
# CONFIG_HID_RETRODE is not set
CONFIG_HID_ROCCAT=m
CONFIG_HID_SAITEK=m
CONFIG_HID_SAMSUNG=m
CONFIG_HID_SONY=m
# CONFIG_SONY_FF is not set
CONFIG_HID_SPEEDLINK=m
# CONFIG_HID_STEAM is not set
CONFIG_HID_STEELSERIES=m
CONFIG_HID_SUNPLUS=m
# CONFIG_HID_RMI is not set
CONFIG_HID_GREENASIA=m
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_HYPERV_MOUSE=m
CONFIG_HID_SMARTJOYPLUS=m
# CONFIG_SMARTJOYPLUS_FF is not set
CONFIG_HID_TIVO=m
CONFIG_HID_TOPSEED=m
CONFIG_HID_THINGM=m
CONFIG_HID_THRUSTMASTER=m
# CONFIG_THRUSTMASTER_FF is not set
# CONFIG_HID_UDRAW_PS3 is not set
CONFIG_HID_WACOM=m
CONFIG_HID_WIIMOTE=m
# CONFIG_HID_XINMO is not set
CONFIG_HID_ZEROPLUS=m
# CONFIG_ZEROPLUS_FF is not set
CONFIG_HID_ZYDACRON=m
# CONFIG_HID_SENSOR_HUB is not set
# CONFIG_HID_ALPS is not set

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y

#
# I2C HID support
#
CONFIG_I2C_HID=m

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
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_OTG is not set
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
# CONFIG_USB_LEDS_TRIGGER_USBPORT is not set
CONFIG_USB_MON=y
CONFIG_USB_WUSB=m
CONFIG_USB_WUSB_CBAF=m
# CONFIG_USB_WUSB_CBAF_DEBUG is not set

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
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
# CONFIG_USB_EHCI_HCD_PLATFORM is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_FOTG210_HCD is not set
# CONFIG_USB_MAX3421_HCD is not set
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
# CONFIG_USB_OHCI_HCD_PLATFORM is not set
CONFIG_USB_UHCI_HCD=y
# CONFIG_USB_U132_HCD is not set
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_WHCI_HCD is not set
CONFIG_USB_HWA_HCD=m
# CONFIG_USB_HCD_BCMA is not set
# CONFIG_USB_HCD_SSB is not set
# CONFIG_USB_HCD_TEST_MODE is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=m
CONFIG_USB_PRINTER=m
CONFIG_USB_WDM=m
CONFIG_USB_TMC=m

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=m
# CONFIG_USB_STORAGE_DEBUG is not set
CONFIG_USB_STORAGE_REALTEK=m
CONFIG_REALTEK_AUTOPM=y
CONFIG_USB_STORAGE_DATAFAB=m
CONFIG_USB_STORAGE_FREECOM=m
CONFIG_USB_STORAGE_ISD200=m
CONFIG_USB_STORAGE_USBAT=m
CONFIG_USB_STORAGE_SDDR09=m
CONFIG_USB_STORAGE_SDDR55=m
CONFIG_USB_STORAGE_JUMPSHOT=m
CONFIG_USB_STORAGE_ALAUDA=m
CONFIG_USB_STORAGE_ONETOUCH=m
CONFIG_USB_STORAGE_KARMA=m
CONFIG_USB_STORAGE_CYPRESS_ATACB=m
CONFIG_USB_STORAGE_ENE_UB6250=m
CONFIG_USB_UAS=m

#
# USB Imaging devices
#
CONFIG_USB_MDC800=m
CONFIG_USB_MICROTEK=m
# CONFIG_USBIP_CORE is not set
# CONFIG_USB_MUSB_HDRC is not set
CONFIG_USB_DWC3=y
# CONFIG_USB_DWC3_HOST is not set
CONFIG_USB_DWC3_GADGET=y
# CONFIG_USB_DWC3_DUAL_ROLE is not set

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_PCI=y
CONFIG_USB_DWC3_HAPS=y
# CONFIG_USB_DWC2 is not set
# CONFIG_USB_CHIPIDEA is not set
# CONFIG_USB_ISP1760 is not set

#
# USB port drivers
#
CONFIG_USB_USS720=m
CONFIG_USB_SERIAL=y
CONFIG_USB_SERIAL_CONSOLE=y
CONFIG_USB_SERIAL_GENERIC=y
# CONFIG_USB_SERIAL_SIMPLE is not set
CONFIG_USB_SERIAL_AIRCABLE=m
CONFIG_USB_SERIAL_ARK3116=m
CONFIG_USB_SERIAL_BELKIN=m
CONFIG_USB_SERIAL_CH341=m
CONFIG_USB_SERIAL_WHITEHEAT=m
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=m
CONFIG_USB_SERIAL_CP210X=m
CONFIG_USB_SERIAL_CYPRESS_M8=m
CONFIG_USB_SERIAL_EMPEG=m
CONFIG_USB_SERIAL_FTDI_SIO=m
CONFIG_USB_SERIAL_VISOR=m
CONFIG_USB_SERIAL_IPAQ=m
CONFIG_USB_SERIAL_IR=m
CONFIG_USB_SERIAL_EDGEPORT=m
CONFIG_USB_SERIAL_EDGEPORT_TI=m
# CONFIG_USB_SERIAL_F81232 is not set
# CONFIG_USB_SERIAL_F8153X is not set
CONFIG_USB_SERIAL_GARMIN=m
CONFIG_USB_SERIAL_IPW=m
CONFIG_USB_SERIAL_IUU=m
CONFIG_USB_SERIAL_KEYSPAN_PDA=m
CONFIG_USB_SERIAL_KEYSPAN=m
CONFIG_USB_SERIAL_KLSI=m
CONFIG_USB_SERIAL_KOBIL_SCT=m
CONFIG_USB_SERIAL_MCT_U232=m
# CONFIG_USB_SERIAL_METRO is not set
CONFIG_USB_SERIAL_MOS7720=m
CONFIG_USB_SERIAL_MOS7715_PARPORT=y
CONFIG_USB_SERIAL_MOS7840=m
# CONFIG_USB_SERIAL_MXUPORT is not set
CONFIG_USB_SERIAL_NAVMAN=m
CONFIG_USB_SERIAL_PL2303=m
CONFIG_USB_SERIAL_OTI6858=m
CONFIG_USB_SERIAL_QCAUX=m
CONFIG_USB_SERIAL_QUALCOMM=m
CONFIG_USB_SERIAL_SPCP8X5=m
CONFIG_USB_SERIAL_SAFE=m
CONFIG_USB_SERIAL_SAFE_PADDED=y
CONFIG_USB_SERIAL_SIERRAWIRELESS=m
CONFIG_USB_SERIAL_SYMBOL=m
# CONFIG_USB_SERIAL_TI is not set
CONFIG_USB_SERIAL_CYBERJACK=m
CONFIG_USB_SERIAL_XIRCOM=m
CONFIG_USB_SERIAL_WWAN=m
CONFIG_USB_SERIAL_OPTION=m
CONFIG_USB_SERIAL_OMNINET=m
CONFIG_USB_SERIAL_OPTICON=m
CONFIG_USB_SERIAL_XSENS_MT=m
# CONFIG_USB_SERIAL_WISHBONE is not set
CONFIG_USB_SERIAL_SSU100=m
CONFIG_USB_SERIAL_QT2=m
# CONFIG_USB_SERIAL_UPD78F0730 is not set
CONFIG_USB_SERIAL_DEBUG=m

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=m
CONFIG_USB_EMI26=m
CONFIG_USB_ADUTUX=m
CONFIG_USB_SEVSEG=m
# CONFIG_USB_RIO500 is not set
CONFIG_USB_LEGOTOWER=m
CONFIG_USB_LCD=m
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
CONFIG_USB_IDMOUSE=m
CONFIG_USB_FTDI_ELAN=m
CONFIG_USB_APPLEDISPLAY=m
CONFIG_USB_SISUSBVGA=m
CONFIG_USB_SISUSBVGA_CON=y
CONFIG_USB_LD=m
# CONFIG_USB_TRANCEVIBRATOR is not set
CONFIG_USB_IOWARRIOR=m
# CONFIG_USB_TEST is not set
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
CONFIG_USB_ISIGHTFW=m
# CONFIG_USB_YUREX is not set
CONFIG_USB_EZUSB_FX2=m
# CONFIG_USB_HUB_USB251XB is not set
CONFIG_USB_HSIC_USB3503=m
# CONFIG_USB_HSIC_USB4604 is not set
# CONFIG_USB_LINK_LAYER_TEST is not set
# CONFIG_USB_CHAOSKEY is not set
CONFIG_USB_ATM=m
CONFIG_USB_SPEEDTOUCH=m
CONFIG_USB_CXACRU=m
CONFIG_USB_UEAGLEATM=m
CONFIG_USB_XUSBATM=m

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_USB_ISP1301 is not set
CONFIG_USB_GADGET=y
# CONFIG_USB_GADGET_DEBUG is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
# CONFIG_USB_FOTG210_UDC is not set
# CONFIG_USB_GR_UDC is not set
# CONFIG_USB_R8A66597 is not set
# CONFIG_USB_PXA27X is not set
# CONFIG_USB_MV_UDC is not set
# CONFIG_USB_MV_U3D is not set
# CONFIG_USB_M66592 is not set
# CONFIG_USB_BDC_UDC is not set
# CONFIG_USB_AMD5536UDC is not set
# CONFIG_USB_NET2272 is not set
# CONFIG_USB_NET2280 is not set
# CONFIG_USB_GOKU is not set
# CONFIG_USB_EG20T is not set
# CONFIG_USB_DUMMY_HCD is not set
CONFIG_USB_LIBCOMPOSITE=m
CONFIG_USB_F_MASS_STORAGE=m
# CONFIG_USB_CONFIGFS is not set
# CONFIG_USB_ZERO is not set
# CONFIG_USB_AUDIO is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
# CONFIG_USB_GADGETFS is not set
# CONFIG_USB_FUNCTIONFS is not set
CONFIG_USB_MASS_STORAGE=m
# CONFIG_USB_GADGET_TARGET is not set
# CONFIG_USB_G_SERIAL is not set
# CONFIG_USB_MIDI_GADGET is not set
# CONFIG_USB_G_PRINTER is not set
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_ACM_MS is not set
# CONFIG_USB_G_MULTI is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set
# CONFIG_USB_G_WEBCAM is not set
# CONFIG_TYPEC is not set
# CONFIG_USB_ROLE_SWITCH is not set
# CONFIG_USB_LED_TRIG is not set
# CONFIG_USB_ULPI_BUS is not set
CONFIG_UWB=m
CONFIG_UWB_HWA=m
CONFIG_UWB_WHCI=m
CONFIG_UWB_I1480U=m
CONFIG_MMC=m
CONFIG_MMC_BLOCK=m
CONFIG_MMC_BLOCK_MINORS=8
CONFIG_SDIO_UART=m
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_DEBUG is not set
CONFIG_MMC_SDHCI=m
CONFIG_MMC_SDHCI_PCI=m
CONFIG_MMC_RICOH_MMC=y
CONFIG_MMC_SDHCI_ACPI=m
CONFIG_MMC_SDHCI_PLTFM=m
# CONFIG_MMC_SDHCI_F_SDH30 is not set
# CONFIG_MMC_WBSD is not set
CONFIG_MMC_TIFM_SD=m
# CONFIG_MMC_SPI is not set
CONFIG_MMC_CB710=m
CONFIG_MMC_VIA_SDMMC=m
CONFIG_MMC_VUB300=m
CONFIG_MMC_USHC=m
# CONFIG_MMC_USDHI6ROL0 is not set
CONFIG_MMC_CQHCI=m
# CONFIG_MMC_TOSHIBA_PCI is not set
# CONFIG_MMC_MTK is not set
# CONFIG_MMC_SDHCI_XENON is not set
CONFIG_MEMSTICK=m
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=m
# CONFIG_MS_BLOCK is not set

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=m
CONFIG_MEMSTICK_JMICRON_38X=m
CONFIG_MEMSTICK_R592=m
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
# CONFIG_LEDS_CLASS_FLASH is not set
# CONFIG_LEDS_BRIGHTNESS_HW_CHANGED is not set

#
# LED drivers
#
# CONFIG_LEDS_APU is not set
CONFIG_LEDS_LM3530=m
# CONFIG_LEDS_LM3642 is not set
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=m
# CONFIG_LEDS_LP3952 is not set
CONFIG_LEDS_LP55XX_COMMON=m
CONFIG_LEDS_LP5521=m
CONFIG_LEDS_LP5523=m
CONFIG_LEDS_LP5562=m
# CONFIG_LEDS_LP8501 is not set
CONFIG_LEDS_CLEVO_MAIL=m
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_PCA963X is not set
# CONFIG_LEDS_DAC124S085 is not set
# CONFIG_LEDS_PWM is not set
# CONFIG_LEDS_BD2802 is not set
CONFIG_LEDS_INTEL_SS4200=m
# CONFIG_LEDS_LT3593 is not set
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_TLC591XX is not set
# CONFIG_LEDS_LM355x is not set

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=m
# CONFIG_LEDS_MLXCPLD is not set
# CONFIG_LEDS_MLXREG is not set
# CONFIG_LEDS_USER is not set
# CONFIG_LEDS_NIC78BX is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=m
CONFIG_LEDS_TRIGGER_ONESHOT=m
# CONFIG_LEDS_TRIGGER_DISK is not set
# CONFIG_LEDS_TRIGGER_MTD is not set
CONFIG_LEDS_TRIGGER_HEARTBEAT=m
CONFIG_LEDS_TRIGGER_BACKLIGHT=m
# CONFIG_LEDS_TRIGGER_CPU is not set
# CONFIG_LEDS_TRIGGER_ACTIVITY is not set
# CONFIG_LEDS_TRIGGER_GPIO is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=m

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=m
CONFIG_LEDS_TRIGGER_CAMERA=m
# CONFIG_LEDS_TRIGGER_PANIC is not set
# CONFIG_LEDS_TRIGGER_NETDEV is not set
# CONFIG_LEDS_TRIGGER_PATTERN is not set
CONFIG_LEDS_TRIGGER_AUDIO=m
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_DECODE_MCE=m
# CONFIG_EDAC_GHES is not set
CONFIG_EDAC_AMD64=m
# CONFIG_EDAC_AMD64_ERROR_INJECTION is not set
CONFIG_EDAC_E752X=m
CONFIG_EDAC_I82975X=m
CONFIG_EDAC_I3000=m
CONFIG_EDAC_I3200=m
# CONFIG_EDAC_IE31200 is not set
CONFIG_EDAC_X38=m
CONFIG_EDAC_I5400=m
CONFIG_EDAC_I7CORE=m
CONFIG_EDAC_I5000=m
CONFIG_EDAC_I5100=m
CONFIG_EDAC_I7300=m
CONFIG_EDAC_SBRIDGE=m
CONFIG_EDAC_SKX=m
# CONFIG_EDAC_PND2 is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_SYSTOHC is not set
# CONFIG_RTC_DEBUG is not set
CONFIG_RTC_NVMEM=y

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_ABB5ZES3 is not set
# CONFIG_RTC_DRV_ABX80X is not set
CONFIG_RTC_DRV_DS1307=m
# CONFIG_RTC_DRV_DS1307_CENTURY is not set
CONFIG_RTC_DRV_DS1374=m
# CONFIG_RTC_DRV_DS1374_WDT is not set
CONFIG_RTC_DRV_DS1672=m
CONFIG_RTC_DRV_MAX6900=m
CONFIG_RTC_DRV_RS5C372=m
CONFIG_RTC_DRV_ISL1208=m
CONFIG_RTC_DRV_ISL12022=m
CONFIG_RTC_DRV_X1205=m
CONFIG_RTC_DRV_PCF8523=m
# CONFIG_RTC_DRV_PCF85063 is not set
# CONFIG_RTC_DRV_PCF85363 is not set
CONFIG_RTC_DRV_PCF8563=m
CONFIG_RTC_DRV_PCF8583=m
CONFIG_RTC_DRV_M41T80=m
CONFIG_RTC_DRV_M41T80_WDT=y
CONFIG_RTC_DRV_BQ32K=m
# CONFIG_RTC_DRV_S35390A is not set
CONFIG_RTC_DRV_FM3130=m
# CONFIG_RTC_DRV_RX8010 is not set
CONFIG_RTC_DRV_RX8581=m
CONFIG_RTC_DRV_RX8025=m
CONFIG_RTC_DRV_EM3027=m
# CONFIG_RTC_DRV_RV8803 is not set

#
# SPI RTC drivers
#
# CONFIG_RTC_DRV_M41T93 is not set
# CONFIG_RTC_DRV_M41T94 is not set
# CONFIG_RTC_DRV_DS1302 is not set
# CONFIG_RTC_DRV_DS1305 is not set
# CONFIG_RTC_DRV_DS1343 is not set
# CONFIG_RTC_DRV_DS1347 is not set
# CONFIG_RTC_DRV_DS1390 is not set
# CONFIG_RTC_DRV_MAX6916 is not set
# CONFIG_RTC_DRV_R9701 is not set
# CONFIG_RTC_DRV_RX4581 is not set
# CONFIG_RTC_DRV_RX6110 is not set
# CONFIG_RTC_DRV_RS5C348 is not set
# CONFIG_RTC_DRV_MAX6902 is not set
# CONFIG_RTC_DRV_PCF2123 is not set
# CONFIG_RTC_DRV_MCP795 is not set
CONFIG_RTC_I2C_AND_SPI=y

#
# SPI and I2C RTC drivers
#
CONFIG_RTC_DRV_DS3232=m
CONFIG_RTC_DRV_DS3232_HWMON=y
# CONFIG_RTC_DRV_PCF2127 is not set
CONFIG_RTC_DRV_RV3029C2=m
CONFIG_RTC_DRV_RV3029_HWMON=y

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=m
CONFIG_RTC_DRV_DS1511=m
CONFIG_RTC_DRV_DS1553=m
# CONFIG_RTC_DRV_DS1685_FAMILY is not set
CONFIG_RTC_DRV_DS1742=m
CONFIG_RTC_DRV_DS2404=m
CONFIG_RTC_DRV_STK17TA8=m
# CONFIG_RTC_DRV_M48T86 is not set
CONFIG_RTC_DRV_M48T35=m
CONFIG_RTC_DRV_M48T59=m
CONFIG_RTC_DRV_MSM6242=m
CONFIG_RTC_DRV_BQ4802=m
CONFIG_RTC_DRV_RP5C01=m
CONFIG_RTC_DRV_V3020=m

#
# on-CPU RTC drivers
#
# CONFIG_RTC_DRV_FTRTC010 is not set

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
# CONFIG_ALTERA_MSGDMA is not set
# CONFIG_INTEL_IDMA64 is not set
# CONFIG_INTEL_IOATDMA is not set
# CONFIG_QCOM_HIDMA_MGMT is not set
# CONFIG_QCOM_HIDMA is not set
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=m
CONFIG_DW_DMAC_PCI=y
CONFIG_HSU_DMA=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=m
CONFIG_DMA_ENGINE_RAID=y

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
CONFIG_SW_SYNC=y
# CONFIG_UDMABUF is not set
CONFIG_AUXDISPLAY=y
# CONFIG_HD44780 is not set
CONFIG_KS0108=m
CONFIG_KS0108_PORT=0x378
CONFIG_KS0108_DELAY=2
CONFIG_CFAG12864B=m
CONFIG_CFAG12864B_RATE=20
# CONFIG_IMG_ASCII_LCD is not set
# CONFIG_PANEL is not set
CONFIG_UIO=m
CONFIG_UIO_CIF=m
CONFIG_UIO_PDRV_GENIRQ=m
# CONFIG_UIO_DMEM_GENIRQ is not set
CONFIG_UIO_AEC=m
CONFIG_UIO_SERCOS3=m
CONFIG_UIO_PCI_GENERIC=m
# CONFIG_UIO_NETX is not set
# CONFIG_UIO_PRUSS is not set
# CONFIG_UIO_MF624 is not set
# CONFIG_UIO_HV_GENERIC is not set
CONFIG_VFIO_IOMMU_TYPE1=m
CONFIG_VFIO_VIRQFD=m
CONFIG_VFIO=m
# CONFIG_VFIO_NOIOMMU is not set
CONFIG_VFIO_PCI=m
# CONFIG_VFIO_PCI_VGA is not set
CONFIG_VFIO_PCI_MMAP=y
CONFIG_VFIO_PCI_INTX=y
CONFIG_VFIO_PCI_IGD=y
# CONFIG_VFIO_MDEV is not set
CONFIG_IRQ_BYPASS_MANAGER=m
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y
CONFIG_VIRTIO_MENU=y
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_PCI_LEGACY=y
CONFIG_VIRTIO_BALLOON=y
# CONFIG_VIRTIO_INPUT is not set
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
CONFIG_HYPERV=m
CONFIG_HYPERV_TSCPAGE=y
CONFIG_HYPERV_UTILS=m
CONFIG_HYPERV_BALLOON=m

#
# Xen driver support
#
CONFIG_XEN_BALLOON=y
# CONFIG_XEN_SELFBALLOONING is not set
# CONFIG_XEN_BALLOON_MEMORY_HOTPLUG is not set
CONFIG_XEN_SCRUB_PAGES_DEFAULT=y
CONFIG_XEN_DEV_EVTCHN=m
CONFIG_XEN_BACKEND=y
CONFIG_XENFS=m
CONFIG_XEN_COMPAT_XENFS=y
CONFIG_XEN_SYS_HYPERVISOR=y
CONFIG_XEN_XENBUS_FRONTEND=y
# CONFIG_XEN_GNTDEV is not set
# CONFIG_XEN_GRANT_DEV_ALLOC is not set
# CONFIG_XEN_GRANT_DMA_ALLOC is not set
CONFIG_SWIOTLB_XEN=y
CONFIG_XEN_TMEM=m
CONFIG_XEN_PCIDEV_BACKEND=m
# CONFIG_XEN_PVCALLS_FRONTEND is not set
# CONFIG_XEN_PVCALLS_BACKEND is not set
# CONFIG_XEN_SCSI_BACKEND is not set
CONFIG_XEN_PRIVCMD=m
CONFIG_XEN_ACPI_PROCESSOR=m
# CONFIG_XEN_MCE_LOG is not set
CONFIG_XEN_HAVE_PVMMU=y
CONFIG_XEN_EFI=y
CONFIG_XEN_AUTO_XLATE=y
CONFIG_XEN_ACPI=y
CONFIG_XEN_SYMS=y
CONFIG_XEN_HAVE_VPMU=y
CONFIG_STAGING=y
# CONFIG_PRISM2_USB is not set
# CONFIG_COMEDI is not set
# CONFIG_RTL8192U is not set
CONFIG_RTLLIB=m
CONFIG_RTLLIB_CRYPTO_CCMP=m
CONFIG_RTLLIB_CRYPTO_TKIP=m
CONFIG_RTLLIB_CRYPTO_WEP=m
CONFIG_RTL8192E=m
# CONFIG_RTL8723BS is not set
CONFIG_R8712U=m
# CONFIG_R8188EU is not set
# CONFIG_R8822BE is not set
# CONFIG_RTS5208 is not set
# CONFIG_VT6655 is not set
# CONFIG_VT6656 is not set
# CONFIG_FB_SM750 is not set
# CONFIG_FB_XGI is not set

#
# Speakup console speech
#
# CONFIG_SPEAKUP is not set
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
# CONFIG_LTE_GDM724X is not set
CONFIG_FIREWIRE_SERIAL=m
CONFIG_FWTTY_MAX_TOTAL_PORTS=64
CONFIG_FWTTY_MAX_CARD_PORTS=32
# CONFIG_GS_FPGABOOT is not set
# CONFIG_UNISYSSPAR is not set
# CONFIG_FB_TFT is not set
# CONFIG_WILC1000_SDIO is not set
# CONFIG_WILC1000_SPI is not set
# CONFIG_MOST is not set
# CONFIG_KS7010 is not set
# CONFIG_GREYBUS is not set
# CONFIG_DRM_VBOXVIDEO is not set
# CONFIG_PI433 is not set
# CONFIG_MTK_MMC is not set

#
# Gasket devices
#
# CONFIG_STAGING_GASKET_FRAMEWORK is not set
# CONFIG_XIL_AXIS_FIFO is not set
# CONFIG_EROFS_FS is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=m
# CONFIG_ACER_WIRELESS is not set
CONFIG_ACERHDF=m
# CONFIG_ALIENWARE_WMI is not set
CONFIG_ASUS_LAPTOP=m
CONFIG_DCDBAS=m
# CONFIG_DELL_SMBIOS is not set
CONFIG_DELL_WMI_AIO=m
# CONFIG_DELL_WMI_LED is not set
# CONFIG_DELL_SMO8800 is not set
# CONFIG_DELL_RBTN is not set
CONFIG_DELL_RBU=m
CONFIG_FUJITSU_LAPTOP=m
CONFIG_FUJITSU_TABLET=m
CONFIG_AMILO_RFKILL=m
# CONFIG_GPD_POCKET_FAN is not set
CONFIG_HP_ACCEL=m
# CONFIG_HP_WIRELESS is not set
CONFIG_HP_WMI=m
# CONFIG_LG_LAPTOP is not set
CONFIG_MSI_LAPTOP=m
CONFIG_PANASONIC_LAPTOP=m
CONFIG_COMPAL_LAPTOP=m
CONFIG_SONY_LAPTOP=m
CONFIG_SONYPI_COMPAT=y
CONFIG_IDEAPAD_LAPTOP=m
# CONFIG_SURFACE3_WMI is not set
CONFIG_THINKPAD_ACPI=m
CONFIG_THINKPAD_ACPI_ALSA_SUPPORT=y
# CONFIG_THINKPAD_ACPI_DEBUGFACILITIES is not set
# CONFIG_THINKPAD_ACPI_DEBUG is not set
# CONFIG_THINKPAD_ACPI_UNSAFE_LEDS is not set
CONFIG_THINKPAD_ACPI_VIDEO=y
CONFIG_THINKPAD_ACPI_HOTKEY_POLL=y
CONFIG_SENSORS_HDAPS=m
# CONFIG_INTEL_MENLOW is not set
CONFIG_EEEPC_LAPTOP=m
CONFIG_ASUS_WMI=m
CONFIG_ASUS_NB_WMI=m
CONFIG_EEEPC_WMI=m
# CONFIG_ASUS_WIRELESS is not set
CONFIG_ACPI_WMI=m
CONFIG_WMI_BMOF=m
# CONFIG_INTEL_WMI_THUNDERBOLT is not set
CONFIG_MSI_WMI=m
# CONFIG_PEAQ_WMI is not set
CONFIG_TOPSTAR_LAPTOP=m
CONFIG_TOSHIBA_BT_RFKILL=m
# CONFIG_TOSHIBA_HAPS is not set
# CONFIG_TOSHIBA_WMI is not set
CONFIG_ACPI_CMPC=m
# CONFIG_INTEL_INT0002_VGPIO is not set
# CONFIG_INTEL_HID_EVENT is not set
# CONFIG_INTEL_VBTN is not set
CONFIG_INTEL_IPS=m
# CONFIG_INTEL_PMC_CORE is not set
# CONFIG_IBM_RTL is not set
CONFIG_SAMSUNG_LAPTOP=m
CONFIG_MXM_WMI=m
CONFIG_INTEL_OAKTRAIL=m
CONFIG_SAMSUNG_Q10=m
CONFIG_APPLE_GMUX=m
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_INTEL_PMC_IPC is not set
# CONFIG_SURFACE_PRO3_BUTTON is not set
# CONFIG_INTEL_PUNIT_IPC is not set
# CONFIG_MLX_PLATFORM is not set
# CONFIG_INTEL_TURBO_MAX_3 is not set
# CONFIG_I2C_MULTI_INSTANTIATE is not set
# CONFIG_INTEL_ATOMISP2_PM is not set
# CONFIG_HUAWEI_WMI is not set
CONFIG_PMC_ATOM=y
# CONFIG_CHROME_PLATFORMS is not set
# CONFIG_MELLANOX_PLATFORM is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
# CONFIG_COMMON_CLK_MAX9485 is not set
# CONFIG_COMMON_CLK_SI5351 is not set
# CONFIG_COMMON_CLK_SI544 is not set
# CONFIG_COMMON_CLK_CDCE706 is not set
# CONFIG_COMMON_CLK_CS2000_CP is not set
# CONFIG_COMMON_CLK_PWM is not set
# CONFIG_HWSPINLOCK is not set

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
CONFIG_MAILBOX=y
CONFIG_PCC=y
# CONFIG_ALTERA_MBOX is not set
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
# CONFIG_IOMMU_DEBUGFS is not set
# CONFIG_IOMMU_DEFAULT_PASSTHROUGH is not set
CONFIG_IOMMU_IOVA=y
CONFIG_AMD_IOMMU=y
CONFIG_AMD_IOMMU_V2=m
CONFIG_DMAR_TABLE=y
CONFIG_INTEL_IOMMU=y
# CONFIG_INTEL_IOMMU_SVM is not set
# CONFIG_INTEL_IOMMU_DEFAULT_ON is not set
CONFIG_INTEL_IOMMU_FLOPPY_WA=y
CONFIG_IRQ_REMAP=y

#
# Remoteproc drivers
#
# CONFIG_REMOTEPROC is not set

#
# Rpmsg drivers
#
# CONFIG_RPMSG_QCOM_GLINK_RPM is not set
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
# CONFIG_XILINX_VCU is not set
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=m
# CONFIG_DEVFREQ_GOV_PERFORMANCE is not set
# CONFIG_DEVFREQ_GOV_POWERSAVE is not set
# CONFIG_DEVFREQ_GOV_USERSPACE is not set
# CONFIG_DEVFREQ_GOV_PASSIVE is not set

#
# DEVFREQ Drivers
#
# CONFIG_PM_DEVFREQ_EVENT is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
# CONFIG_EXTCON_GPIO is not set
# CONFIG_EXTCON_INTEL_INT3496 is not set
# CONFIG_EXTCON_MAX3355 is not set
# CONFIG_EXTCON_RT8973A is not set
# CONFIG_EXTCON_SM5502 is not set
# CONFIG_EXTCON_USB_GPIO is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
CONFIG_NTB=m
# CONFIG_NTB_AMD is not set
# CONFIG_NTB_IDT is not set
# CONFIG_NTB_INTEL is not set
# CONFIG_NTB_SWITCHTEC is not set
# CONFIG_NTB_PINGPONG is not set
# CONFIG_NTB_TOOL is not set
# CONFIG_NTB_PERF is not set
# CONFIG_NTB_TRANSPORT is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_PWM_LPSS=m
CONFIG_PWM_LPSS_PCI=m
CONFIG_PWM_LPSS_PLATFORM=m
# CONFIG_PWM_PCA9685 is not set

#
# IRQ chip support
#
CONFIG_ARM_GIC_MAX_NR=1
# CONFIG_IPACK_BUS is not set
# CONFIG_RESET_CONTROLLER is not set
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
# CONFIG_BCM_KONA_USB2_PHY is not set
# CONFIG_PHY_PXA_28NM_HSIC is not set
# CONFIG_PHY_PXA_28NM_USB2 is not set
CONFIG_POWERCAP=y
CONFIG_INTEL_RAPL=m
# CONFIG_IDLE_INJECT is not set
# CONFIG_MCB is not set

#
# Performance monitor support
#
CONFIG_RAS=y
# CONFIG_RAS_CEC is not set
# CONFIG_THUNDERBOLT is not set

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_LIBNVDIMM=m
CONFIG_BLK_DEV_PMEM=m
CONFIG_ND_BLK=m
CONFIG_ND_CLAIM=y
CONFIG_ND_BTT=m
CONFIG_BTT=y
CONFIG_ND_PFN=m
CONFIG_NVDIMM_PFN=y
CONFIG_NVDIMM_DAX=y
CONFIG_NVDIMM_KEYS=y
CONFIG_DAX_DRIVER=y
CONFIG_DAX=y
CONFIG_DEV_DAX=m
CONFIG_DEV_DAX_PMEM=m
CONFIG_NVMEM=y

#
# HW tracing support
#
CONFIG_STM=m
# CONFIG_STM_PROTO_BASIC is not set
# CONFIG_STM_PROTO_SYS_T is not set
CONFIG_STM_DUMMY=m
CONFIG_STM_SOURCE_CONSOLE=m
CONFIG_STM_SOURCE_HEARTBEAT=m
CONFIG_STM_SOURCE_FTRACE=m
CONFIG_INTEL_TH=m
CONFIG_INTEL_TH_PCI=m
# CONFIG_INTEL_TH_ACPI is not set
CONFIG_INTEL_TH_GTH=m
CONFIG_INTEL_TH_STH=m
CONFIG_INTEL_TH_MSU=m
CONFIG_INTEL_TH_PTI=m
# CONFIG_INTEL_TH_DEBUG is not set
# CONFIG_FPGA is not set
CONFIG_PM_OPP=y
# CONFIG_UNISYS_VISORBUS is not set
# CONFIG_SIOX is not set
# CONFIG_SLIMBUS is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_IOMAP=y
# CONFIG_EXT2_FS is not set
# CONFIG_EXT3_FS is not set
CONFIG_EXT4_FS=y
CONFIG_EXT4_USE_FOR_EXT2=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
CONFIG_EXT4_ENCRYPTION=y
CONFIG_EXT4_FS_ENCRYPTION=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=m
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
CONFIG_XFS_RT=y
CONFIG_XFS_ONLINE_SCRUB=y
CONFIG_XFS_ONLINE_REPAIR=y
CONFIG_XFS_DEBUG=y
CONFIG_XFS_ASSERT_FATAL=y
CONFIG_GFS2_FS=m
CONFIG_GFS2_FS_LOCKING_DLM=y
CONFIG_OCFS2_FS=m
CONFIG_OCFS2_FS_O2CB=m
CONFIG_OCFS2_FS_USERSPACE_CLUSTER=m
CONFIG_OCFS2_FS_STATS=y
CONFIG_OCFS2_DEBUG_MASKLOG=y
# CONFIG_OCFS2_DEBUG_FS is not set
CONFIG_BTRFS_FS=m
CONFIG_BTRFS_FS_POSIX_ACL=y
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
# CONFIG_BTRFS_DEBUG is not set
# CONFIG_BTRFS_ASSERT is not set
# CONFIG_BTRFS_FS_REF_VERIFY is not set
# CONFIG_NILFS2_FS is not set
CONFIG_F2FS_FS=m
CONFIG_F2FS_STAT_FS=y
CONFIG_F2FS_FS_XATTR=y
CONFIG_F2FS_FS_POSIX_ACL=y
# CONFIG_F2FS_FS_SECURITY is not set
# CONFIG_F2FS_CHECK_FS is not set
CONFIG_F2FS_FS_ENCRYPTION=y
# CONFIG_F2FS_IO_TRACE is not set
# CONFIG_F2FS_FAULT_INJECTION is not set
CONFIG_FS_DAX=y
CONFIG_FS_DAX_PMD=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
# CONFIG_EXPORTFS_BLOCK_OPS is not set
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
CONFIG_FANOTIFY_ACCESS_PERMISSIONS=y
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
# CONFIG_QFMT_V1 is not set
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
CONFIG_AUTOFS_FS=y
CONFIG_FUSE_FS=m
CONFIG_CUSE=m
CONFIG_OVERLAY_FS=m
# CONFIG_OVERLAY_FS_REDIRECT_DIR is not set
CONFIG_OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW=y
# CONFIG_OVERLAY_FS_INDEX is not set
# CONFIG_OVERLAY_FS_XINO_AUTO is not set
# CONFIG_OVERLAY_FS_METACOPY is not set

#
# Caches
#
CONFIG_FSCACHE=m
CONFIG_FSCACHE_STATS=y
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
CONFIG_CACHEFILES=m
# CONFIG_CACHEFILES_DEBUG is not set
# CONFIG_CACHEFILES_HISTOGRAM is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=m
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=m

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=m
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=m
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="ascii"
# CONFIG_FAT_DEFAULT_UTF8 is not set
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
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
CONFIG_EFIVAR_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ORANGEFS_FS is not set
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_ECRYPT_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_JFFS2_FS is not set
# CONFIG_UBIFS_FS is not set
CONFIG_CRAMFS=m
CONFIG_CRAMFS_BLOCKDEV=y
# CONFIG_CRAMFS_MTD is not set
CONFIG_SQUASHFS=m
CONFIG_SQUASHFS_FILE_CACHE=y
# CONFIG_SQUASHFS_FILE_DIRECT is not set
CONFIG_SQUASHFS_DECOMP_SINGLE=y
# CONFIG_SQUASHFS_DECOMP_MULTI is not set
# CONFIG_SQUASHFS_DECOMP_MULTI_PERCPU is not set
CONFIG_SQUASHFS_XATTR=y
CONFIG_SQUASHFS_ZLIB=y
# CONFIG_SQUASHFS_LZ4 is not set
CONFIG_SQUASHFS_LZO=y
CONFIG_SQUASHFS_XZ=y
# CONFIG_SQUASHFS_ZSTD is not set
# CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
# CONFIG_VXFS_FS is not set
CONFIG_MINIX_FS=m
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_QNX6FS_FS is not set
# CONFIG_ROMFS_FS is not set
CONFIG_PSTORE=y
CONFIG_PSTORE_DEFLATE_COMPRESS=y
# CONFIG_PSTORE_LZO_COMPRESS is not set
# CONFIG_PSTORE_LZ4_COMPRESS is not set
# CONFIG_PSTORE_LZ4HC_COMPRESS is not set
# CONFIG_PSTORE_842_COMPRESS is not set
# CONFIG_PSTORE_ZSTD_COMPRESS is not set
CONFIG_PSTORE_COMPRESS=y
CONFIG_PSTORE_DEFLATE_COMPRESS_DEFAULT=y
CONFIG_PSTORE_COMPRESS_DEFAULT="deflate"
CONFIG_PSTORE_CONSOLE=y
CONFIG_PSTORE_PMSG=y
# CONFIG_PSTORE_FTRACE is not set
CONFIG_PSTORE_RAM=m
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
# CONFIG_EXOFS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
# CONFIG_NFS_V2 is not set
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=m
# CONFIG_NFS_SWAP is not set
CONFIG_NFS_V4_1=y
CONFIG_NFS_V4_2=y
CONFIG_PNFS_FILE_LAYOUT=m
CONFIG_PNFS_BLOCK=m
CONFIG_PNFS_FLEXFILE_LAYOUT=m
CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN="kernel.org"
# CONFIG_NFS_V4_1_MIGRATION is not set
CONFIG_NFS_V4_SECURITY_LABEL=y
CONFIG_ROOT_NFS=y
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFS_DEBUG=y
CONFIG_NFSD=m
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
# CONFIG_NFSD_BLOCKLAYOUT is not set
# CONFIG_NFSD_SCSILAYOUT is not set
# CONFIG_NFSD_FLEXFILELAYOUT is not set
CONFIG_NFSD_V4_SECURITY_LABEL=y
# CONFIG_NFSD_FAULT_INJECTION is not set
CONFIG_GRACE_PERIOD=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=m
CONFIG_SUNRPC_BACKCHANNEL=y
CONFIG_RPCSEC_GSS_KRB5=m
CONFIG_SUNRPC_DEBUG=y
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=m
# CONFIG_CIFS_STATS2 is not set
CONFIG_CIFS_ALLOW_INSECURE_LEGACY=y
CONFIG_CIFS_WEAK_PW_HASH=y
CONFIG_CIFS_UPCALL=y
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
CONFIG_CIFS_ACL=y
CONFIG_CIFS_DEBUG=y
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_DEBUG_DUMP_KEYS is not set
CONFIG_CIFS_DFS_UPCALL=y
# CONFIG_CIFS_FSCACHE is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
CONFIG_9P_FS=y
CONFIG_9P_FS_POSIX_ACL=y
# CONFIG_9P_FS_SECURITY is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=m
CONFIG_NLS_CODEPAGE_775=m
CONFIG_NLS_CODEPAGE_850=m
CONFIG_NLS_CODEPAGE_852=m
CONFIG_NLS_CODEPAGE_855=m
CONFIG_NLS_CODEPAGE_857=m
CONFIG_NLS_CODEPAGE_860=m
CONFIG_NLS_CODEPAGE_861=m
CONFIG_NLS_CODEPAGE_862=m
CONFIG_NLS_CODEPAGE_863=m
CONFIG_NLS_CODEPAGE_864=m
CONFIG_NLS_CODEPAGE_865=m
CONFIG_NLS_CODEPAGE_866=m
CONFIG_NLS_CODEPAGE_869=m
CONFIG_NLS_CODEPAGE_936=m
CONFIG_NLS_CODEPAGE_950=m
CONFIG_NLS_CODEPAGE_932=m
CONFIG_NLS_CODEPAGE_949=m
CONFIG_NLS_CODEPAGE_874=m
CONFIG_NLS_ISO8859_8=m
CONFIG_NLS_CODEPAGE_1250=m
CONFIG_NLS_CODEPAGE_1251=m
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=m
CONFIG_NLS_ISO8859_2=m
CONFIG_NLS_ISO8859_3=m
CONFIG_NLS_ISO8859_4=m
CONFIG_NLS_ISO8859_5=m
CONFIG_NLS_ISO8859_6=m
CONFIG_NLS_ISO8859_7=m
CONFIG_NLS_ISO8859_9=m
CONFIG_NLS_ISO8859_13=m
CONFIG_NLS_ISO8859_14=m
CONFIG_NLS_ISO8859_15=m
CONFIG_NLS_KOI8_R=m
CONFIG_NLS_KOI8_U=m
CONFIG_NLS_MAC_ROMAN=m
CONFIG_NLS_MAC_CELTIC=m
CONFIG_NLS_MAC_CENTEURO=m
CONFIG_NLS_MAC_CROATIAN=m
CONFIG_NLS_MAC_CYRILLIC=m
CONFIG_NLS_MAC_GAELIC=m
CONFIG_NLS_MAC_GREEK=m
CONFIG_NLS_MAC_ICELAND=m
CONFIG_NLS_MAC_INUIT=m
CONFIG_NLS_MAC_ROMANIAN=m
CONFIG_NLS_MAC_TURKISH=m
CONFIG_NLS_UTF8=m
CONFIG_DLM=m
CONFIG_DLM_DEBUG=y

#
# Security options
#
CONFIG_KEYS=y
CONFIG_KEYS_COMPAT=y
CONFIG_PERSISTENT_KEYRINGS=y
CONFIG_BIG_KEYS=y
CONFIG_TRUSTED_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEY_DH_OPERATIONS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITY_WRITABLE_HOOKS=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_PAGE_TABLE_ISOLATION=y
CONFIG_SECURITY_NETWORK_XFRM=y
CONFIG_SECURITY_PATH=y
CONFIG_INTEL_TXT=y
CONFIG_LSM_MMAP_MIN_ADDR=65535
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
# CONFIG_HARDENED_USERCOPY is not set
# CONFIG_FORTIFY_SOURCE is not set
# CONFIG_STATIC_USERMODEHELPER is not set
CONFIG_SECURITY_SELINUX=y
CONFIG_SECURITY_SELINUX_BOOTPARAM=y
CONFIG_SECURITY_SELINUX_BOOTPARAM_VALUE=1
CONFIG_SECURITY_SELINUX_DISABLE=y
CONFIG_SECURITY_SELINUX_DEVELOP=y
CONFIG_SECURITY_SELINUX_AVC_STATS=y
CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=1
# CONFIG_SECURITY_SMACK is not set
# CONFIG_SECURITY_TOMOYO is not set
CONFIG_SECURITY_APPARMOR=y
CONFIG_SECURITY_APPARMOR_BOOTPARAM_VALUE=1
CONFIG_SECURITY_APPARMOR_HASH=y
CONFIG_SECURITY_APPARMOR_HASH_DEFAULT=y
# CONFIG_SECURITY_APPARMOR_DEBUG is not set
# CONFIG_SECURITY_LOADPIN is not set
# CONFIG_SECURITY_YAMA is not set
CONFIG_INTEGRITY=y
CONFIG_INTEGRITY_SIGNATURE=y
CONFIG_INTEGRITY_ASYMMETRIC_KEYS=y
CONFIG_INTEGRITY_TRUSTED_KEYRING=y
CONFIG_INTEGRITY_AUDIT=y
CONFIG_IMA=y
CONFIG_IMA_MEASURE_PCR_IDX=10
CONFIG_IMA_LSM_RULES=y
# CONFIG_IMA_TEMPLATE is not set
CONFIG_IMA_NG_TEMPLATE=y
# CONFIG_IMA_SIG_TEMPLATE is not set
CONFIG_IMA_DEFAULT_TEMPLATE="ima-ng"
CONFIG_IMA_DEFAULT_HASH_SHA1=y
# CONFIG_IMA_DEFAULT_HASH_SHA256 is not set
# CONFIG_IMA_DEFAULT_HASH_SHA512 is not set
CONFIG_IMA_DEFAULT_HASH="sha1"
# CONFIG_IMA_WRITE_POLICY is not set
# CONFIG_IMA_READ_POLICY is not set
CONFIG_IMA_APPRAISE=y
# CONFIG_IMA_ARCH_POLICY is not set
# CONFIG_IMA_APPRAISE_BUILD_POLICY is not set
CONFIG_IMA_APPRAISE_BOOTPARAM=y
CONFIG_IMA_TRUSTED_KEYRING=y
# CONFIG_IMA_BLACKLIST_KEYRING is not set
# CONFIG_IMA_LOAD_X509 is not set
CONFIG_EVM=y
CONFIG_EVM_ATTR_FSUUID=y
# CONFIG_EVM_ADD_XATTRS is not set
# CONFIG_EVM_LOAD_X509 is not set
CONFIG_DEFAULT_SECURITY_SELINUX=y
# CONFIG_DEFAULT_SECURITY_APPARMOR is not set
# CONFIG_DEFAULT_SECURITY_DAC is not set
CONFIG_DEFAULT_SECURITY="selinux"
CONFIG_XOR_BLOCKS=m
CONFIG_ASYNC_CORE=m
CONFIG_ASYNC_MEMCPY=m
CONFIG_ASYNC_XOR=m
CONFIG_ASYNC_PQ=m
CONFIG_ASYNC_RAID6_RECOV=m
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
CONFIG_CRYPTO_ACOMP2=y
CONFIG_CRYPTO_RSA=y
# CONFIG_CRYPTO_DH is not set
# CONFIG_CRYPTO_ECDH is not set
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=m
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_PCRYPT=m
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=m
CONFIG_CRYPTO_AUTHENC=m
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_SIMD=m
CONFIG_CRYPTO_GLUE_HELPER_X86=m
CONFIG_CRYPTO_ENGINE=m

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=m
CONFIG_CRYPTO_GCM=y
# CONFIG_CRYPTO_CHACHA20POLY1305 is not set
# CONFIG_CRYPTO_AEGIS128 is not set
# CONFIG_CRYPTO_AEGIS128L is not set
# CONFIG_CRYPTO_AEGIS256 is not set
# CONFIG_CRYPTO_AEGIS128_AESNI_SSE2 is not set
# CONFIG_CRYPTO_AEGIS128L_AESNI_SSE2 is not set
# CONFIG_CRYPTO_AEGIS256_AESNI_SSE2 is not set
# CONFIG_CRYPTO_MORUS640 is not set
# CONFIG_CRYPTO_MORUS640_SSE2 is not set
# CONFIG_CRYPTO_MORUS1280 is not set
# CONFIG_CRYPTO_MORUS1280_SSE2 is not set
# CONFIG_CRYPTO_MORUS1280_AVX2 is not set
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=m

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
# CONFIG_CRYPTO_CFB is not set
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=m
# CONFIG_CRYPTO_OFB is not set
CONFIG_CRYPTO_PCBC=m
CONFIG_CRYPTO_XTS=y
# CONFIG_CRYPTO_KEYWRAP is not set
# CONFIG_CRYPTO_NHPOLY1305_SSE2 is not set
# CONFIG_CRYPTO_NHPOLY1305_AVX2 is not set
# CONFIG_CRYPTO_ADIANTUM is not set

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=m
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=m
CONFIG_CRYPTO_VMAC=m

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=m
CONFIG_CRYPTO_CRC32=m
CONFIG_CRYPTO_CRC32_PCLMUL=m
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=m
CONFIG_CRYPTO_GHASH=y
# CONFIG_CRYPTO_POLY1305 is not set
# CONFIG_CRYPTO_POLY1305_X86_64 is not set
CONFIG_CRYPTO_MD4=m
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=m
CONFIG_CRYPTO_RMD128=m
CONFIG_CRYPTO_RMD160=m
CONFIG_CRYPTO_RMD256=m
CONFIG_CRYPTO_RMD320=m
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=m
CONFIG_CRYPTO_SHA256_SSSE3=m
CONFIG_CRYPTO_SHA512_SSSE3=m
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA3=m
# CONFIG_CRYPTO_SM3 is not set
# CONFIG_CRYPTO_STREEBOG is not set
CONFIG_CRYPTO_TGR192=m
CONFIG_CRYPTO_WP512=m
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=m

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_AES_TI is not set
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=m
CONFIG_CRYPTO_ANUBIS=m
CONFIG_CRYPTO_ARC4=m
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_BLOWFISH_COMMON=m
CONFIG_CRYPTO_BLOWFISH_X86_64=m
CONFIG_CRYPTO_CAMELLIA=m
CONFIG_CRYPTO_CAMELLIA_X86_64=m
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=m
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=m
CONFIG_CRYPTO_CAST_COMMON=m
CONFIG_CRYPTO_CAST5=m
CONFIG_CRYPTO_CAST5_AVX_X86_64=m
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_CAST6_AVX_X86_64=m
CONFIG_CRYPTO_DES=m
# CONFIG_CRYPTO_DES3_EDE_X86_64 is not set
CONFIG_CRYPTO_FCRYPT=m
CONFIG_CRYPTO_KHAZAD=m
CONFIG_CRYPTO_SALSA20=m
# CONFIG_CRYPTO_CHACHA20 is not set
# CONFIG_CRYPTO_CHACHA20_X86_64 is not set
CONFIG_CRYPTO_SEED=m
CONFIG_CRYPTO_SERPENT=m
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=m
CONFIG_CRYPTO_SERPENT_AVX_X86_64=m
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=m
# CONFIG_CRYPTO_SM4 is not set
CONFIG_CRYPTO_TEA=m
CONFIG_CRYPTO_TWOFISH=m
CONFIG_CRYPTO_TWOFISH_COMMON=m
CONFIG_CRYPTO_TWOFISH_X86_64=m
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=m
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=m

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_842 is not set
# CONFIG_CRYPTO_LZ4 is not set
# CONFIG_CRYPTO_LZ4HC is not set
# CONFIG_CRYPTO_ZSTD is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=m
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
# CONFIG_CRYPTO_STATS is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=m
CONFIG_CRYPTO_DEV_PADLOCK_AES=m
CONFIG_CRYPTO_DEV_PADLOCK_SHA=m
# CONFIG_CRYPTO_DEV_CCP is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCC is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXX is not set
# CONFIG_CRYPTO_DEV_QAT_C62X is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCCVF is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXXVF is not set
# CONFIG_CRYPTO_DEV_QAT_C62XVF is not set
# CONFIG_CRYPTO_DEV_NITROX_CNN55XX is not set
# CONFIG_CRYPTO_DEV_CHELSIO is not set
CONFIG_CRYPTO_DEV_VIRTIO=m
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
# CONFIG_ASYMMETRIC_TPM_KEY_SUBTYPE is not set
CONFIG_X509_CERTIFICATE_PARSER=y
# CONFIG_PKCS8_PRIVATE_KEY_PARSER is not set
CONFIG_PKCS7_MESSAGE_PARSER=y
# CONFIG_PKCS7_TEST_KEY is not set
# CONFIG_SIGNED_PE_FILE_VERIFICATION is not set

#
# Certificates for signature checking
#
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_TRUSTED_KEYS=""
# CONFIG_SYSTEM_EXTRA_CERTIFICATE is not set
# CONFIG_SECONDARY_TRUSTED_KEYRING is not set
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
CONFIG_CRC_ITU_T=m
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC64 is not set
# CONFIG_CRC4 is not set
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
CONFIG_CRC8=m
CONFIG_XXHASH=y
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_ZSTD_COMPRESS=m
CONFIG_ZSTD_DECOMPRESS=m
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
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
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=m
CONFIG_TEXTSEARCH_BM=m
CONFIG_TEXTSEARCH_FSM=m
CONFIG_BTREE=y
CONFIG_INTERVAL_TREE=y
CONFIG_XARRAY_MULTI=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_SWIOTLB=y
CONFIG_SGL_ALLOC=y
CONFIG_IOMMU_HELPER=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_GLOB=y
# CONFIG_GLOB_SELFTEST is not set
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=m
# CONFIG_DDR is not set
CONFIG_IRQ_POLL=y
CONFIG_MPILIB=y
CONFIG_SIGNATURE=y
CONFIG_OID_REGISTRY=y
CONFIG_UCS2_STRING=y
CONFIG_FONT_SUPPORT=y
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_UACCESS_FLUSHCACHE=y
CONFIG_ARCH_HAS_UACCESS_MCSAFE=y
CONFIG_SBITMAP=y
CONFIG_PRIME_NUMBERS=m
# CONFIG_STRING_SELFTEST is not set

#
# Kernel hacking
#

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
CONFIG_CONSOLE_LOGLEVEL_QUIET=4
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
CONFIG_BOOT_PRINTK_DELAY=y
CONFIG_DYNAMIC_DEBUG=y

#
# Compile-time checks and compiler options
#
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=y
# CONFIG_DEBUG_INFO_SPLIT is not set
# CONFIG_DEBUG_INFO_DWARF4 is not set
# CONFIG_GDB_SCRIPTS is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CONFIG_STACK_VALIDATION=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_MAGIC_SYSRQ_SERIAL=y
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
# CONFIG_PAGE_EXTENSION is not set
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_PAGE_POISONING is not set
# CONFIG_DEBUG_PAGE_REF is not set
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_VM is not set
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_MEMORY_NOTIFIER_ERROR_INJECT=m
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KASAN=y
CONFIG_CC_HAS_KASAN_GENERIC=y
# CONFIG_KASAN is not set
CONFIG_ARCH_HAS_KCOV=y
CONFIG_CC_HAS_SANCOV_TRACE_PC=y
# CONFIG_KCOV is not set
CONFIG_DEBUG_SHIRQ=y

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
# CONFIG_WQ_WATCHDOG is not set
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHED_INFO=y
CONFIG_SCHEDSTATS=y
# CONFIG_SCHED_STACK_END_CHECK is not set
# CONFIG_DEBUG_TIMEKEEPING is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_LOCK_DEBUGGING_SUPPORT=y
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
# CONFIG_DEBUG_RWSEMS is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_LOCK_TORTURE_TEST=m
CONFIG_WW_MUTEX_SELFTEST=m
CONFIG_STACKTRACE=y
# CONFIG_WARN_ALL_UNSEEDED_RANDOM is not set
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PI_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
CONFIG_TORTURE_TEST=m
CONFIG_RCU_PERF_TEST=m
CONFIG_RCU_TORTURE_TEST=m
CONFIG_RCU_CPU_STALL_TIMEOUT=60
# CONFIG_RCU_TRACE is not set
# CONFIG_RCU_EQS_DEBUG is not set
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_CPU_HOTPLUG_STATE_CONTROL is not set
CONFIG_NOTIFIER_ERROR_INJECTION=m
CONFIG_PM_NOTIFIER_ERROR_INJECT=m
# CONFIG_NETDEV_NOTIFIER_ERROR_INJECT is not set
CONFIG_FUNCTION_ERROR_INJECTION=y
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
# CONFIG_FAIL_PAGE_ALLOC is not set
CONFIG_FAIL_MAKE_REQUEST=y
# CONFIG_FAIL_IO_TIMEOUT is not set
# CONFIG_FAIL_FUTEX is not set
CONFIG_FAULT_INJECTION_DEBUG_FS=y
# CONFIG_FAIL_FUNCTION is not set
# CONFIG_FAIL_MMC_REQUEST is not set
CONFIG_LATENCYTOP=y
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
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
# CONFIG_PREEMPTIRQ_EVENTS is not set
# CONFIG_IRQSOFF_TRACER is not set
CONFIG_SCHED_TRACER=y
# CONFIG_HWLAT_TRACER is not set
CONFIG_FTRACE_SYSCALLS=y
CONFIG_TRACER_SNAPSHOT=y
# CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP is not set
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
CONFIG_STACK_TRACER=y
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_KPROBE_EVENTS=y
# CONFIG_KPROBE_EVENTS_ON_NOTRACE is not set
CONFIG_UPROBE_EVENTS=y
CONFIG_BPF_EVENTS=y
CONFIG_DYNAMIC_EVENTS=y
CONFIG_PROBE_EVENTS=y
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_FUNCTION_PROFILER=y
# CONFIG_BPF_KPROBE_OVERRIDE is not set
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
CONFIG_TRACING_MAP=y
CONFIG_HIST_TRIGGERS=y
# CONFIG_TRACEPOINT_BENCHMARK is not set
CONFIG_RING_BUFFER_BENCHMARK=m
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
# CONFIG_PREEMPTIRQ_DELAY_TEST is not set
# CONFIG_TRACE_EVAL_MAP_FILE is not set
CONFIG_TRACING_EVENTS_GPIO=y
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
# CONFIG_DMA_API_DEBUG is not set
CONFIG_RUNTIME_TESTING_MENU=y
CONFIG_LKDTM=m
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_TEST_SORT is not set
# CONFIG_KPROBES_SANITY_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=m
CONFIG_INTERVAL_TREE_TEST=m
CONFIG_PERCPU_TEST=m
CONFIG_ATOMIC64_SELFTEST=y
CONFIG_ASYNC_RAID6_TEST=m
# CONFIG_TEST_HEXDUMP is not set
# CONFIG_TEST_STRING_HELPERS is not set
CONFIG_TEST_KSTRTOX=m
CONFIG_TEST_PRINTF=m
CONFIG_TEST_BITMAP=m
# CONFIG_TEST_BITFIELD is not set
# CONFIG_TEST_UUID is not set
# CONFIG_TEST_XARRAY is not set
# CONFIG_TEST_OVERFLOW is not set
# CONFIG_TEST_RHASHTABLE is not set
# CONFIG_TEST_HASH is not set
# CONFIG_TEST_IDA is not set
CONFIG_TEST_LKM=m
CONFIG_TEST_USER_COPY=m
CONFIG_TEST_BPF=m
# CONFIG_FIND_BIT_BENCHMARK is not set
CONFIG_TEST_FIRMWARE=m
CONFIG_TEST_SYSCTL=m
CONFIG_TEST_UDELAY=m
CONFIG_TEST_STATIC_KEYS=m
CONFIG_TEST_KMOD=m
# CONFIG_TEST_MEMCAT_P is not set
# CONFIG_MEMTEST is not set
# CONFIG_BUG_ON_DATA_CORRUPTION is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_STRICT_DEVMEM=y
# CONFIG_IO_STRICT_DEVMEM is not set
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_EARLY_PRINTK_USB=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
# CONFIG_EARLY_PRINTK_EFI is not set
# CONFIG_EARLY_PRINTK_USB_XDBC is not set
# CONFIG_X86_PTDUMP is not set
# CONFIG_EFI_PGT_DUMP is not set
# CONFIG_DEBUG_WX is not set
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_DEBUG is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_X86_DECODER_SELFTEST=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_ENTRY is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set
CONFIG_X86_DEBUG_FPU=y
# CONFIG_PUNIT_ATOM_DEBUG is not set
CONFIG_UNWINDER_ORC=y
# CONFIG_UNWINDER_FRAME_POINTER is not set
# CONFIG_UNWINDER_GUESS is not set

--orO6xySwJI16pVnm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=job-script

#!/bin/sh

export_top_env()
{
	export suite='stress-ng'
	export testcase='stress-ng'
	export category='benchmark'
	export nr_threads=44
	export testtime=5
	export job_origin='/lkp/lkp/.src-20190216-121343/allot/cyclic:p1:linux-devel:devel-hourly/lkp-bdw-ep3/stress-ng.yaml'
	export queue_cmdline_keys='branch
commit'
	export queue='validate'
	export testbox='lkp-bdw-ep3'
	export tbox_group='lkp-bdw-ep3'
	export submit_id='5c7705740b9a939fb9169092'
	export job_file='/lkp/jobs/scheduled/lkp-bdw-ep3/stress-ng-memory-performance-1HDD-50%-5s-ucode=0xb00002e-debian-x-20190228-40889-e1pcbi-3.yaml'
	export id='ee7af712a86e6bf7f455ac403f8ee9238ceaf2f5'
	export queuer_version='/lkp/lkp/.src-20190227-234340'
	export need_kconfig='CONFIG_BLK_DEV_SD
CONFIG_SCSI
CONFIG_BLOCK=y
CONFIG_SATA_AHCI
CONFIG_SATA_AHCI_PLATFORM
CONFIG_ATA
CONFIG_PCI=y
CONFIG_SECURITY_APPARMOR=y'
	export commit='cdaa813278ddc616ee201eacda77f63996b5dd2d'
	export kconfig='x86_64-rhel-7.2'
	export compiler='gcc-7'
	export rootfs='debian-x86_64-2018-04-03.cgz'
	export enqueue_time='2019-02-28 05:47:32 +0800'
	export _id='5c7705740b9a939fb9169093'
	export _rt='/result/stress-ng/memory-performance-1HDD-50%-5s-ucode=0xb00002e/lkp-bdw-ep3/debian-x86_64-2018-04-03.cgz/x86_64-rhel-7.2/gcc-7/cdaa813278ddc616ee201eacda77f63996b5dd2d'
	export user='lkp'
	export head_commit='c1cdc5ea6f7e4be9889c6a8998d3bce3c57bb3d7'
	export base_commit='f17b5f06cb92ef2250513a1e154c47b78df07d40'
	export branch='linux-devel/devel-hourly-2019021713'
	export result_root='/result/stress-ng/memory-performance-1HDD-50%-5s-ucode=0xb00002e/lkp-bdw-ep3/debian-x86_64-2018-04-03.cgz/x86_64-rhel-7.2/gcc-7/cdaa813278ddc616ee201eacda77f63996b5dd2d/3'
	export scheduler_version='/lkp/lkp/.src-20190227-234340'
	export LKP_SERVER='inn'
	export max_uptime=1354.9199999999998
	export initrd='/osimage/debian/debian-x86_64-2018-04-03.cgz'
	export bootloader_append='root=/dev/ram0
user=lkp
job=/lkp/jobs/scheduled/lkp-bdw-ep3/stress-ng-memory-performance-1HDD-50%-5s-ucode=0xb00002e-debian-x-20190228-40889-e1pcbi-3.yaml
ARCH=x86_64
kconfig=x86_64-rhel-7.2
branch=linux-devel/devel-hourly-2019021713
commit=cdaa813278ddc616ee201eacda77f63996b5dd2d
BOOT_IMAGE=/pkg/linux/x86_64-rhel-7.2/gcc-7/cdaa813278ddc616ee201eacda77f63996b5dd2d/vmlinuz-5.0.0-rc4-00004-gcdaa8132
max_uptime=1354
RESULT_ROOT=/result/stress-ng/memory-performance-1HDD-50%-5s-ucode=0xb00002e/lkp-bdw-ep3/debian-x86_64-2018-04-03.cgz/x86_64-rhel-7.2/gcc-7/cdaa813278ddc616ee201eacda77f63996b5dd2d/3
LKP_SERVER=inn
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
rw'
	export modules_initrd='/pkg/linux/x86_64-rhel-7.2/gcc-7/cdaa813278ddc616ee201eacda77f63996b5dd2d/modules.cgz'
	export bm_initrd='/osimage/deps/debian-x86_64-2018-04-03.cgz/run-ipconfig_2018-04-03.cgz,/osimage/deps/debian-x86_64-2018-04-03.cgz/lkp_2018-04-03.cgz,/osimage/deps/debian-x86_64-2018-04-03.cgz/rsync-rootfs_2018-04-03.cgz,/osimage/deps/debian-x86_64-2018-04-03.cgz/stress-ng_2018-11-07.cgz,/osimage/deps/debian-x86_64-2018-04-03.cgz/mpstat_2018-06-19.cgz,/osimage/deps/debian-x86_64-2018-04-03.cgz/turbostat_2018-05-17.cgz,/osimage/pkg/debian-x86_64-2018-04-03.cgz/turbostat-x86_64-d5256b2_2018-05-18.cgz,/osimage/deps/debian-x86_64-2018-04-03.cgz/perf_2019-01-01.cgz,/osimage/pkg/debian-x86_64-2018-04-03.cgz/perf-x86_64-e1ef035d272e_2019-01-01.cgz,/osimage/deps/debian-x86_64-2018-04-03.cgz/hw_2016-11-15.cgz'
	export lkp_initrd='/lkp/lkp/lkp-x86_64.cgz'
	export site='inn'
	export LKP_CGI_PORT=80
	export LKP_CIFS_PORT=139
	export repeat_to=4
	export schedule_notify_address=
	export model='Broadwell-EP'
	export nr_cpu=88
	export memory='64G'
	export swap_partitions=
	export rootfs_partition='LABEL=LKP-ROOTFS'
	export hdd_partitions='/dev/disk/by-id/ata-ST250DM000-1BD141_W2ADD5CZ-part1'
	export brand='Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz'
	export ucode='0xb00002e'
	export kernel='/pkg/linux/x86_64-rhel-7.2/gcc-7/cdaa813278ddc616ee201eacda77f63996b5dd2d/vmlinuz-5.0.0-rc4-00004-gcdaa8132'
	export dequeue_time='2019-02-28 05:59:48 +0800'
	export job_initrd='/lkp/jobs/scheduled/lkp-bdw-ep3/stress-ng-memory-performance-1HDD-50%-5s-ucode=0xb00002e-debian-x-20190228-40889-e1pcbi-3.cgz'

	[ -n "$LKP_SRC" ] ||
	export LKP_SRC=/lkp/${user:-lkp}/src
}

run_job()
{
	echo $$ > $TMP/run-job.pid

	. $LKP_SRC/lib/http.sh
	. $LKP_SRC/lib/job.sh
	. $LKP_SRC/lib/env.sh

	export_top_env

	run_setup nr_hdd=1 $LKP_SRC/setup/disk

	run_setup $LKP_SRC/setup/cpufreq_governor 'performance'

	run_monitor $LKP_SRC/monitors/wrapper kmsg
	run_monitor $LKP_SRC/monitors/no-stdout/wrapper boot-time
	run_monitor $LKP_SRC/monitors/wrapper iostat
	run_monitor $LKP_SRC/monitors/wrapper heartbeat
	run_monitor $LKP_SRC/monitors/wrapper vmstat
	run_monitor $LKP_SRC/monitors/wrapper numa-numastat
	run_monitor $LKP_SRC/monitors/wrapper numa-vmstat
	run_monitor $LKP_SRC/monitors/wrapper numa-meminfo
	run_monitor $LKP_SRC/monitors/wrapper proc-vmstat
	run_monitor $LKP_SRC/monitors/wrapper proc-stat
	run_monitor $LKP_SRC/monitors/wrapper meminfo
	run_monitor $LKP_SRC/monitors/wrapper slabinfo
	run_monitor $LKP_SRC/monitors/wrapper interrupts
	run_monitor $LKP_SRC/monitors/wrapper lock_stat
	run_monitor $LKP_SRC/monitors/wrapper latency_stats
	run_monitor $LKP_SRC/monitors/wrapper softirqs
	run_monitor $LKP_SRC/monitors/one-shot/wrapper bdi_dev_mapping
	run_monitor $LKP_SRC/monitors/wrapper diskstats
	run_monitor $LKP_SRC/monitors/wrapper nfsstat
	run_monitor $LKP_SRC/monitors/wrapper cpuidle
	run_monitor $LKP_SRC/monitors/wrapper cpufreq-stats
	run_monitor $LKP_SRC/monitors/wrapper turbostat
	run_monitor $LKP_SRC/monitors/wrapper sched_debug
	run_monitor $LKP_SRC/monitors/wrapper perf-stat
	run_monitor $LKP_SRC/monitors/wrapper mpstat
	run_monitor $LKP_SRC/monitors/no-stdout/wrapper perf-profile
	run_monitor $LKP_SRC/monitors/wrapper oom-killer
	run_monitor $LKP_SRC/monitors/plain/watchdog

	run_test class='memory' $LKP_SRC/tests/wrapper stress-ng
}

extract_stats()
{
	export stats_part_begin=
	export stats_part_end=

	$LKP_SRC/stats/wrapper stress-ng
	$LKP_SRC/stats/wrapper kmsg
	$LKP_SRC/stats/wrapper boot-time
	$LKP_SRC/stats/wrapper iostat
	$LKP_SRC/stats/wrapper vmstat
	$LKP_SRC/stats/wrapper numa-numastat
	$LKP_SRC/stats/wrapper numa-vmstat
	$LKP_SRC/stats/wrapper numa-meminfo
	$LKP_SRC/stats/wrapper proc-vmstat
	$LKP_SRC/stats/wrapper meminfo
	$LKP_SRC/stats/wrapper slabinfo
	$LKP_SRC/stats/wrapper interrupts
	$LKP_SRC/stats/wrapper lock_stat
	$LKP_SRC/stats/wrapper latency_stats
	$LKP_SRC/stats/wrapper softirqs
	$LKP_SRC/stats/wrapper diskstats
	$LKP_SRC/stats/wrapper nfsstat
	$LKP_SRC/stats/wrapper cpuidle
	$LKP_SRC/stats/wrapper turbostat
	$LKP_SRC/stats/wrapper sched_debug
	$LKP_SRC/stats/wrapper perf-stat
	$LKP_SRC/stats/wrapper mpstat
	$LKP_SRC/stats/wrapper perf-profile

	$LKP_SRC/stats/wrapper time stress-ng.time
	$LKP_SRC/stats/wrapper time
	$LKP_SRC/stats/wrapper dmesg
	$LKP_SRC/stats/wrapper kmsg
	$LKP_SRC/stats/wrapper stderr
	$LKP_SRC/stats/wrapper last_state
}

"$@"

--orO6xySwJI16pVnm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="job.yaml"

---

#! jobs/stress-ng.yaml
suite: stress-ng
testcase: stress-ng
category: benchmark
nr_threads: 50%
disk: 1HDD
testtime: 5s
stress-ng:
  class: memory
job_origin: "/lkp/lkp/.src-20190216-121343/allot/cyclic:p1:linux-devel:devel-hourly/lkp-bdw-ep3/stress-ng.yaml"

#! queue options
queue_cmdline_keys:
- branch
- commit
queue: bisect
testbox: lkp-bdw-ep3
tbox_group: lkp-bdw-ep3
submit_id: 5c76ffd10b9a9360569bbeae
job_file: "/lkp/jobs/scheduled/lkp-bdw-ep3/stress-ng-memory-performance-1HDD-50%-5s-ucode=0xb00002e-debian-x86-20190228-24662-hr3zkq-0.yaml"
id: 1b68f328923022d8f3d08cc3c64c6d1d311922de
queuer_version: "/lkp/lkp/.src-20190227-234340"

#! hosts/lkp-bdw-ep3

#! include/category/benchmark
kmsg: 
boot-time: 
iostat: 
heartbeat: 
vmstat: 
numa-numastat: 
numa-vmstat: 
numa-meminfo: 
proc-vmstat: 
proc-stat: 
meminfo: 
slabinfo: 
interrupts: 
lock_stat: 
latency_stats: 
softirqs: 
bdi_dev_mapping: 
diskstats: 
nfsstat: 
cpuidle: 
cpufreq-stats: 
turbostat: 
sched_debug: 
perf-stat: 
mpstat: 
perf-profile: 

#! include/category/ALL
cpufreq_governor: performance

#! include/disk/nr_hdd
need_kconfig:
- CONFIG_BLK_DEV_SD
- CONFIG_SCSI
- CONFIG_BLOCK=y
- CONFIG_SATA_AHCI
- CONFIG_SATA_AHCI_PLATFORM
- CONFIG_ATA
- CONFIG_PCI=y
- CONFIG_SECURITY_APPARMOR=y

#! include/stress-ng

#! include/queue/cyclic
commit: cdaa813278ddc616ee201eacda77f63996b5dd2d

#! default params
kconfig: x86_64-rhel-7.2
compiler: gcc-7
rootfs: debian-x86_64-2018-04-03.cgz
enqueue_time: 2019-02-28 05:23:29.143163671 +08:00
_id: 5c76ffd10b9a9360569bbeae
_rt: "/result/stress-ng/memory-performance-1HDD-50%-5s-ucode=0xb00002e/lkp-bdw-ep3/debian-x86_64-2018-04-03.cgz/x86_64-rhel-7.2/gcc-7/cdaa813278ddc616ee201eacda77f63996b5dd2d"

#! schedule options
user: lkp
head_commit: c1cdc5ea6f7e4be9889c6a8998d3bce3c57bb3d7
base_commit: f17b5f06cb92ef2250513a1e154c47b78df07d40
branch: linux-devel/devel-hourly-2019021713
result_root: "/result/stress-ng/memory-performance-1HDD-50%-5s-ucode=0xb00002e/lkp-bdw-ep3/debian-x86_64-2018-04-03.cgz/x86_64-rhel-7.2/gcc-7/cdaa813278ddc616ee201eacda77f63996b5dd2d/0"
scheduler_version: "/lkp/lkp/.src-20190227-234340"
LKP_SERVER: inn
max_uptime: 1354.9199999999998
initrd: "/osimage/debian/debian-x86_64-2018-04-03.cgz"
bootloader_append:
- root=/dev/ram0
- user=lkp
- job=/lkp/jobs/scheduled/lkp-bdw-ep3/stress-ng-memory-performance-1HDD-50%-5s-ucode=0xb00002e-debian-x86-20190228-24662-hr3zkq-0.yaml
- ARCH=x86_64
- kconfig=x86_64-rhel-7.2
- branch=linux-devel/devel-hourly-2019021713
- commit=cdaa813278ddc616ee201eacda77f63996b5dd2d
- BOOT_IMAGE=/pkg/linux/x86_64-rhel-7.2/gcc-7/cdaa813278ddc616ee201eacda77f63996b5dd2d/vmlinuz-5.0.0-rc4-00004-gcdaa8132
- max_uptime=1354
- RESULT_ROOT=/result/stress-ng/memory-performance-1HDD-50%-5s-ucode=0xb00002e/lkp-bdw-ep3/debian-x86_64-2018-04-03.cgz/x86_64-rhel-7.2/gcc-7/cdaa813278ddc616ee201eacda77f63996b5dd2d/0
- LKP_SERVER=inn
- debug
- apic=debug
- sysrq_always_enabled
- rcupdate.rcu_cpu_stall_timeout=100
- net.ifnames=0
- printk.devkmsg=on
- panic=-1
- softlockup_panic=1
- nmi_watchdog=panic
- oops=panic
- load_ramdisk=2
- prompt_ramdisk=0
- drbd.minor_count=8
- systemd.log_level=err
- ignore_loglevel
- console=tty0
- earlyprintk=ttyS0,115200
- console=ttyS0,115200
- vga=normal
- rw
modules_initrd: "/pkg/linux/x86_64-rhel-7.2/gcc-7/cdaa813278ddc616ee201eacda77f63996b5dd2d/modules.cgz"
bm_initrd: "/osimage/deps/debian-x86_64-2018-04-03.cgz/run-ipconfig_2018-04-03.cgz,/osimage/deps/debian-x86_64-2018-04-03.cgz/lkp_2018-04-03.cgz,/osimage/deps/debian-x86_64-2018-04-03.cgz/rsync-rootfs_2018-04-03.cgz,/osimage/deps/debian-x86_64-2018-04-03.cgz/stress-ng_2018-11-07.cgz,/osimage/deps/debian-x86_64-2018-04-03.cgz/mpstat_2018-06-19.cgz,/osimage/deps/debian-x86_64-2018-04-03.cgz/turbostat_2018-05-17.cgz,/osimage/pkg/debian-x86_64-2018-04-03.cgz/turbostat-x86_64-d5256b2_2018-05-18.cgz,/osimage/deps/debian-x86_64-2018-04-03.cgz/perf_2019-01-01.cgz,/osimage/pkg/debian-x86_64-2018-04-03.cgz/perf-x86_64-e1ef035d272e_2019-01-01.cgz,/osimage/deps/debian-x86_64-2018-04-03.cgz/hw_2016-11-15.cgz"
lkp_initrd: "/lkp/lkp/lkp-x86_64.cgz"
site: inn

#! /lkp/lkp/.src-20190216-121343/include/site/inn
LKP_CGI_PORT: 80
LKP_CIFS_PORT: 139
oom-killer: 
watchdog: 

#! runtime status
repeat_to: 2
schedule_notify_address: 
model: Broadwell-EP
nr_cpu: 88
memory: 64G
swap_partitions: 
rootfs_partition: LABEL=LKP-ROOTFS
hdd_partitions: "/dev/disk/by-id/ata-ST250DM000-1BD141_W2ADD5CZ-part1"
brand: Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz
ucode: '0xb00002e'

#! user overrides
kernel: "/pkg/linux/x86_64-rhel-7.2/gcc-7/cdaa813278ddc616ee201eacda77f63996b5dd2d/vmlinuz-5.0.0-rc4-00004-gcdaa8132"
dequeue_time: 2019-02-28 05:36:17.612602090 +08:00

#! /lkp/lkp/.src-20190227-234340/include/site/inn
job_state: finished
loadavg: 78.03 51.50 20.94 1/699 88000
start_time: '1551303442'
end_time: '1551303651'
version: "/lkp/lkp/.src-20190227-234340"

--orO6xySwJI16pVnm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=reproduce


for cpu_dir in /sys/devices/system/cpu/cpu[0-9]*
do
	online_file="$cpu_dir"/online
	[ -f "$online_file" ] && [ "$(cat "$online_file")" -eq 0 ] && continue

	file="$cpu_dir"/cpufreq/scaling_governor
	[ -f "$file" ] && echo "performance" > "$file"
done


--orO6xySwJI16pVnm--

