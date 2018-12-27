Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 74EF08E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 23:11:37 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id a2so16618495pgt.11
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 20:11:37 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id e34si34286107pgb.80.2018.12.26.20.11.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 20:11:36 -0800 (PST)
Date: Thu, 27 Dec 2018 12:11:32 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH v2 01/21] e820: cheat PMEM as DRAM
Message-ID: <20181227041132.xxdnwtdajtm7ny4q@wfg-t540p.sh.intel.com>
References: <20181226131446.330864849@intel.com>
 <20181226133351.106676005@intel.com>
 <20181227034141.GD20878@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20181227034141.GD20878@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Fan Du <fan.du@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, Dec 26, 2018 at 07:41:41PM -0800, Matthew Wilcox wrote:
>On Wed, Dec 26, 2018 at 09:14:47PM +0800, Fengguang Wu wrote:
>> From: Fan Du <fan.du@intel.com>
>>
>> This is a hack to enumerate PMEM as NUMA nodes.
>> It's necessary for current BIOS that don't yet fill ACPI HMAT table.
>>
>> WARNING: take care to backup. It is mutual exclusive with libnvdimm
>> subsystem and can destroy ndctl managed namespaces.
>
>Why depend on firmware to present this "correctly"?  It seems to me like
>less effort all around to have ndctl label some namespaces as being for
>this kind of use.

Dave Hansen may be more suitable to answer your question. He posted
patches to make PMEM NUMA node coexist with libnvdimm and ndctl:

[PATCH 0/9] Allow persistent memory to be used like normal RAM
https://lkml.org/lkml/2018/10/23/9

That depends on future BIOS. So we did this quick hack to test out
PMEM NUMA node for the existing BIOS.

Thanks,
Fengguang
