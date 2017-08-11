Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id B0E176B02B4
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 11:59:28 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id g129so63637363ywh.11
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 08:59:28 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id p204si330956ywc.445.2017.08.11.08.59.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 08:59:27 -0700 (PDT)
Subject: Re: [v6 07/15] mm: defining memblock_virt_alloc_try_nid_raw
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-8-git-send-email-pasha.tatashin@oracle.com>
 <20170811123953.GI30811@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <545b7230-2c09-d2f9-f26a-05ef395c36d4@oracle.com>
Date: Fri, 11 Aug 2017 11:58:46 -0400
MIME-Version: 1.0
In-Reply-To: <20170811123953.GI30811@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

On 08/11/2017 08:39 AM, Michal Hocko wrote:
> On Mon 07-08-17 16:38:41, Pavel Tatashin wrote:
>> A new variant of memblock_virt_alloc_* allocations:
>> memblock_virt_alloc_try_nid_raw()
>>      - Does not zero the allocated memory
>>      - Does not panic if request cannot be satisfied
> 
> OK, this looks good but I would not introduce memblock_virt_alloc_raw
> here because we do not have any users. Please move that to "mm: optimize
> early system hash allocations" which actually uses the API. It would be
> easier to review it that way.
> 
>> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
>> Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
>> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
>> Reviewed-by: Bob Picco <bob.picco@oracle.com>
> 
> other than that
> Acked-by: Michal Hocko <mhocko@suse.com>

Sure, I could do this, but as I understood from earlier Dave Miller's 
comments, we should do one logical change at a time. Hence, introduce 
API in one patch use it in another. So, this is how I tried to organize 
this patch set. Is this assumption incorrect?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
