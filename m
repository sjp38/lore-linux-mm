Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 210138E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 04:57:59 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id g12so31371280pll.22
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 01:57:59 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 89si13446706pfr.242.2019.01.07.01.57.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 01:57:58 -0800 (PST)
Date: Mon, 7 Jan 2019 17:57:53 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH v2 10/21] mm: build separate zonelist for PMEM and
 DRAM node
Message-ID: <20190107095753.7feee5fxjja5lt75@wfg-t540p.sh.intel.com>
References: <20181226131446.330864849@intel.com>
 <20181226133351.644607371@intel.com>
 <87sgyc7n9a.fsf@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <87sgyc7n9a.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Fan Du <fan.du@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Tue, Jan 01, 2019 at 02:44:41PM +0530, Aneesh Kumar K.V wrote:
>Fengguang Wu <fengguang.wu@intel.com> writes:
>
>> From: Fan Du <fan.du@intel.com>
>>
>> When allocate page, DRAM and PMEM node should better not fall back to
>> each other. This allows migration code to explicitly control which type
>> of node to allocate pages from.
>>
>> With this patch, PMEM NUMA node can only be used in 2 ways:
>> - migrate in and out
>> - numactl
>
>Can we achieve this using nodemask? That way we don't tag nodes with
>different properties such as DRAM/PMEM. We can then give the
>flexibilility to the device init code to add the new memory nodes to
>the right nodemask

Aneesh, in patch 2 we did create nodemask numa_nodes_pmem and
numa_nodes_dram. What's your supposed way of "using nodemask"?

Thanks,
Fengguang
