Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC2006B0292
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:32:40 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id 80so41661042uas.8
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 06:32:40 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id o65si2936738vkc.124.2017.08.14.06.32.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 06:32:39 -0700 (PDT)
Subject: Re: [v6 02/15] x86/mm: setting fields in deferred pages
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-3-git-send-email-pasha.tatashin@oracle.com>
 <20170811090214.GD30811@dhcp22.suse.cz>
 <b0422e38-a6da-081a-71c5-82a36dd2a5bb@oracle.com>
 <20170814114326.GH19063@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <b52f21d3-3abe-69e2-ae17-6e9f892b49d4@oracle.com>
Date: Mon, 14 Aug 2017 09:32:01 -0400
MIME-Version: 1.0
In-Reply-To: <20170814114326.GH19063@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org



On 08/14/2017 07:43 AM, Michal Hocko wrote:
>> register_page_bootmem_info
>>   register_page_bootmem_info_node
>>    get_page_bootmem
>>     .. setting fields here ..
>>     such as: page->freelist = (void *)type;
>>
>> free_all_bootmem()
>>   free_low_memory_core_early()
>>    for_each_reserved_mem_region()
>>     reserve_bootmem_region()
>>      init_reserved_page() <- Only if this is deferred reserved page
>>       __init_single_pfn()
>>        __init_single_page()
>>            memset(0) <-- Loose the set fields here!
> OK, I have missed that part. Please make it explicit in the changelog.
> It is quite easy to get lost in the deep call chains.

Ok, will update comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
