Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id E6E8C6B740B
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 06:20:56 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id b18so12199457oii.1
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 03:20:56 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j66si8492324oif.159.2018.12.05.03.20.55
        for <linux-mm@kvack.org>;
        Wed, 05 Dec 2018 03:20:55 -0800 (PST)
Subject: Re: [LKP] [mm] 19717e78a0: stderr.if(target_node==NUMA_NO_NODE){
References: <20181205050057.GB23332@shao2-debian>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <d75d097f-78a5-865e-a80a-b1e6faeff337@arm.com>
Date: Wed, 5 Dec 2018 16:50:57 +0530
MIME-Version: 1.0
In-Reply-To: <20181205050057.GB23332@shao2-debian>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <rong.a.chen@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-media@vger.kernel.org, iommu@lists.linux-foundation.org, linux-rdma@vger.kernel.org, dmaengine@vger.kernel.org, linux-block@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org, akpm@linux-foundation.org, jiangqi903@gmail.com, hverkuil@xs4all.nl, vkoul@kernel.org, lkp@01.org

On 12/05/2018 10:30 AM, kernel test robot wrote:
> FYI, we noticed the following commit (built with gcc-7):
> 
> commit: 19717e78a04d51512cf0e7b9b09c61f06b2af071 ("[PATCH V2] mm: Replace all open encodings for NUMA_NO_NODE")
> url: https://github.com/0day-ci/linux/commits/Anshuman-Khandual/mm-Replace-all-open-encodings-for-NUMA_NO_NODE/20181126-203831
> 
> 
> in testcase: perf-sanity-tests
> with following parameters:
> 
> 	perf_compiler: gcc
> 	ucode: 0x7000013
> 
> 
> 
> on test machine: 16 threads Intel(R) Xeon(R) CPU D-1541 @ 2.10GHz with 8G memory
> 
> caused below changes (please refer to attached dmesg/kmsg for entire log/backtrace):

The fix (in Andrew's staging tree) from Stephen Rothwell which adds <linux/numa.h>
definitions to <tools/include/linux/numa.h> should fix this.
