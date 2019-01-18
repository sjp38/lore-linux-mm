Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C1C558E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 06:48:52 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 89so8009733ple.19
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 03:48:52 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id p32si4057225pgm.413.2019.01.18.03.48.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 03:48:51 -0800 (PST)
Date: Fri, 18 Jan 2019 19:48:46 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/4] Allow persistent memory to be used like normal RAM
Message-ID: <20190118114846.hmmcagscyjeycyfy@wfg-t540p.sh.intel.com>
References: <20190116181859.D1504459@viggo.jf.intel.com>
 <x49sgxr9rjd.fsf@segfault.boston.devel.redhat.com>
 <20190117164736.GC31543@localhost.localdomain>
 <x49pnsv8am1.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <x49pnsv8am1.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Keith Busch <keith.busch@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, thomas.lendacky@amd.com, dave@sr71.net, linux-nvdimm@lists.01.org, tiwai@suse.de, zwisler@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, baiyaowei@cmss.chinamobile.com, ying.huang@intel.com, bhelgaas@google.com, akpm@linux-foundation.org, bp@suse.de

>With this patch set, an unmodified application would either use:
>
>1) whatever memory it happened to get
>2) only the faster dram (via numactl --membind=)
>3) only the slower pmem (again, via numactl --membind1)
>4) preferentially one or the other (numactl --preferred=)

Yet another option:

MemoryOptimizer -- hot page accounting and migration daemon
https://github.com/intel/memory-optimizer

Once PMEM NUMA nodes are available, we may run a user space daemon to
walk page tables of virtual machines (EPT) or processes, collect the
"accessed" bits to find out hot pages, and finally migrate hot pages
to DRAM and cold pages to PMEM.

In that scenario, only kernel and the migrate daemon need to be aware
of the PMEM nodes. Unmodified virtual machines and processes can enjoy
the added memory space w/o knowing whether it's using DRAM or PMEM.

Thanks,
Fengguang
