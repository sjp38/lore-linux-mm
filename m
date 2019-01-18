Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C646F8E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 02:47:13 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id v2so7691031plg.6
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 23:47:13 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id c13si3775416pgi.531.2019.01.17.23.47.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 23:47:12 -0800 (PST)
Subject: Re: [PATCH 4/4] dax: "Hotplug" persistent memory for use like normal
 RAM
References: <20190116181859.D1504459@viggo.jf.intel.com>
 <20190116181905.12E102B4@viggo.jf.intel.com>
 <5ef5d5e9-9d35-fb84-b69e-7456dcf4c241@linux.intel.com>
 <1e9377c6-11a0-3bbd-763d-d9347bd556cf@intel.com>
From: Yanmin Zhang <yanmin_zhang@linux.intel.com>
Message-ID: <74c01a55-1a47-d649-a32a-ea597c24ab4a@linux.intel.com>
Date: Fri, 18 Jan 2019 15:47:32 +0800
MIME-Version: 1.0
In-Reply-To: <1e9377c6-11a0-3bbd-763d-d9347bd556cf@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, dave@sr71.net
Cc: dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com, baiyaowei@cmss.chinamobile.com, tiwai@suse.de

On 2019/1/17 下午11:17, Dave Hansen wrote:
> On 1/17/19 12:19 AM, Yanmin Zhang wrote:
>>>
>> I didn't try pmem and I am wondering it's slower than DRAM.
>> Should a flag, such like _GFP_PMEM, be added to distinguish it from
>> DRAM?
> 
> Absolutely not. :)
Agree.

> 
> We already have performance-differentiated memory, and lots of ways to
> enumerate and select it in the kernel (all of our NUMA infrastructure).
Kernel does manage memory like what you say.
My question is: with your patch, PMEM becomes normal RAM, then there is
a chance for kernel to allocate PMEM as DMA buffer.
Some super speed devices like 10Giga NIC, USB (SSIC connecting modem), 
might not work well if DMA buffer is in PMEM as it's slower than DRAM.

Should your patchset consider it?



> 
> PMEM is also just the first of many "kinds" of memory that folks want to
> build in systems and use a "RAM".  We literally don't have space to put
> a flag in for each type.
> 
> 
