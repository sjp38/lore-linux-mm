Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id F0BB98E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 13:15:42 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d10-v6so1296105pll.22
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 10:15:42 -0700 (PDT)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id v5-v6si1496747plz.140.2018.09.12.10.15.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 10:15:41 -0700 (PDT)
Subject: Re: [RFC v9 PATCH 2/4] mm: mmap: zap pages with read mmap_sem in
 munmap
References: <1536699493-69195-1-git-send-email-yang.shi@linux.alibaba.com>
 <1536699493-69195-3-git-send-email-yang.shi@linux.alibaba.com>
 <20180911211645.GA12159@bombadil.infradead.org>
 <b69d3f7d-e9ba-b95c-45cd-44489950751b@linux.alibaba.com>
 <20180912022921.GA20056@bombadil.infradead.org>
 <20180912091105.GB10951@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <26cf9c0e-51dd-5fcf-e2c9-0b12df1e2061@linux.alibaba.com>
Date: Wed, 12 Sep 2018 10:15:20 -0700
MIME-Version: 1.0
In-Reply-To: <20180912091105.GB10951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>
Cc: ldufour@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/12/18 2:11 AM, Michal Hocko wrote:
> On Tue 11-09-18 19:29:21, Matthew Wilcox wrote:
>> On Tue, Sep 11, 2018 at 04:35:03PM -0700, Yang Shi wrote:
> [...]
>
> I didn't get to read the patch yet.

If you guys think this is the better way I could convert my patches to 
go this way. It is simple to do the conversion.

Thanks,
Yang

>
>>> And, Michal prefers have VM_HUGETLB and VM_PFNMAP handled separately for
>>> safe and bisectable sake, which needs call the regular do_munmap().
>> That can be introduced and then taken out ... indeed, you can split this into
>> many patches, starting with this:
>>
>> +		if (tmp->vm_file)
>> +			downgrade = false;
>>
>> to only allow this optimisation for anonymous mappings at first.
> or add a helper function to check for special cases and make the
> downgrade behavior conditional on it.
