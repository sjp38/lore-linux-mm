Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6843A8E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 10:20:47 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id b24so8314385pls.11
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 07:20:47 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id w75si4970168pfd.55.2019.01.18.07.20.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 07:20:46 -0800 (PST)
Subject: Re: [PATCH 4/4] dax: "Hotplug" persistent memory for use like normal
 RAM
References: <20190116181859.D1504459@viggo.jf.intel.com>
 <20190116181905.12E102B4@viggo.jf.intel.com>
 <5ef5d5e9-9d35-fb84-b69e-7456dcf4c241@linux.intel.com>
 <1e9377c6-11a0-3bbd-763d-d9347bd556cf@intel.com>
 <74c01a55-1a47-d649-a32a-ea597c24ab4a@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <49681805-b521-71c9-23c0-9bb35d25ba58@intel.com>
Date: Fri, 18 Jan 2019 07:20:43 -0800
MIME-Version: 1.0
In-Reply-To: <74c01a55-1a47-d649-a32a-ea597c24ab4a@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yanmin Zhang <yanmin_zhang@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, dave@sr71.net
Cc: dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com, baiyaowei@cmss.chinamobile.com, tiwai@suse.de

On 1/17/19 11:47 PM, Yanmin Zhang wrote:
> a chance for kernel to allocate PMEM as DMA buffer.
> Some super speed devices like 10Giga NIC, USB (SSIC connecting modem),
> might not work well if DMA buffer is in PMEM as it's slower than DRAM.
> 
> Should your patchset consider it?

No, I don't think so.

They can DMA to persistent memory whether this patch set exists or not.
 So, if the hardware falls over, that's a separate problem.

If an app wants memory that performs in a particular way, then I would
suggest those app find the NUMA nodes on the system that match their
needs with these patches:

> http://lkml.kernel.org/r/20190116175804.30196-1-keith.busch@intel.com

and use the existing NUMA APIs to select that memory.
