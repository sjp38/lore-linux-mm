Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id B40576B0387
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 12:13:51 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id 9so15430795vkd.4
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 09:13:51 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id y62si581159vkc.31.2017.08.11.09.13.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 09:13:50 -0700 (PDT)
Subject: Re: [v6 14/15] mm: optimize early system hash allocations
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-15-git-send-email-pasha.tatashin@oracle.com>
 <20170811130541.GM30811@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <8da9321c-769c-3319-8c02-3c91d86b221e@oracle.com>
Date: Fri, 11 Aug 2017 12:13:13 -0400
MIME-Version: 1.0
In-Reply-To: <20170811130541.GM30811@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

>> Clients can call alloc_large_system_hash() with flag: HASH_ZERO to specify
>> that memory that was allocated for system hash needs to be zeroed,
>> otherwise the memory does not need to be zeroed, and client will initialize
>> it.
>>
>> If memory does not need to be zero'd, call the new
>> memblock_virt_alloc_raw() interface, and thus improve the boot performance.
>>
>> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
>> Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
>> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
>> Reviewed-by: Bob Picco <bob.picco@oracle.com>
> 
> OK, but as mentioned in the previous patch add memblock_virt_alloc_raw
> in this patch.
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Ok I will merge them.

Thank you,
Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
