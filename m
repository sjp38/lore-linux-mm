Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 068C08E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 11:54:24 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id e68so19186862ybb.4
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 08:54:24 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id m186si31670762ywe.349.2019.01.02.08.54.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 08:54:23 -0800 (PST)
Subject: Re: [LKP] [hugetlbfs] 9c83282117: vm-scalability.throughput -4.3%
 regression
References: <20181228142608.GA17624@shao2-debian>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <21117eab-862e-562b-0c86-ec2ccc1f68e4@oracle.com>
Date: Wed, 2 Jan 2019 08:54:07 -0800
MIME-Version: 1.0
In-Reply-To: <20181228142608.GA17624@shao2-debian>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <rong.a.chen@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, lkp@01.org

On 12/28/18 6:26 AM, kernel test robot wrote:
> Greeting,
> 
> FYI, we noticed a -4.3% regression of vm-scalability.throughput due to commit:
> 
> 
> commit: 9c83282117778856d647ffc461c4aede2abb6742 ("[PATCH v3 1/2] hugetlbfs: use i_mmap_rwsem for more pmd sharing synchronization")
> url: https://github.com/0day-ci/linux/commits/Mike-Kravetz/hugetlbfs-use-i_mmap_rwsem-for-better-synchronization/20181223-095226
> 
> 
> in testcase: vm-scalability
> on test machine: 104 threads Intel(R) Xeon(R) Platinum 8170 CPU @ 2.10GHz with 64G memory
> with following parameters:
> 
> 	runtime: 300s
> 	size: 8T
> 	test: anon-cow-seq-hugetlb
> 	cpufreq_governor: performance
> 	ucode: 0x200004d

I'll take a closer look.

The patch does introduce longer i_mmap_rwsem hold times for the sake of
correctness.  Need to more fully understand the test and results to determine
if this is expected.

-- 
Mike Kravetz
