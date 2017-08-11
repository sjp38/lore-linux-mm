Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id C76146B0387
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 12:19:06 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id x24so15355939uah.7
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 09:19:06 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 16si677962uae.13.2017.08.11.09.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 09:19:05 -0700 (PDT)
Subject: Re: [v6 15/15] mm: debug for raw alloctor
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-16-git-send-email-pasha.tatashin@oracle.com>
 <20170811130831.GN30811@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <87d84cad-f03a-88f0-7828-6d3bf7ac473c@oracle.com>
Date: Fri, 11 Aug 2017 12:18:24 -0400
MIME-Version: 1.0
In-Reply-To: <20170811130831.GN30811@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

>> When CONFIG_DEBUG_VM is enabled, this patch sets all the memory that is
>> returned by memblock_virt_alloc_try_nid_raw() to ones to ensure that no
>> places excpect zeroed memory.
> 
> Please fold this into the patch which introduces
> memblock_virt_alloc_try_nid_raw.

OK

  I am not sure CONFIG_DEBUG_VM is the
> best config because that tends to be enabled quite often. Maybe
> CONFIG_MEMBLOCK_DEBUG? Or even make it kernel command line parameter?
> 

Initially, I did not want to make it CONFIG_MEMBLOCK_DEBUG because we 
really benefit from this debugging code when VM debug is enabled, and 
especially struct page debugging asserts which also depend on 
CONFIG_DEBUG_VM.

However, now thinking about it, I will change it to 
CONFIG_MEMBLOCK_DEBUG, and let users decide what other debugging configs 
need to be enabled, as this is also OK.

Thank you,
Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
