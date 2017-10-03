Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2EAA26B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 11:30:10 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id p15so4567016qtp.4
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 08:30:10 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id o40si1807149qtj.529.2017.10.03.08.30.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 08:30:09 -0700 (PDT)
Subject: Re: [PATCH v9 08/12] mm: zero reserved and unavailable struct pages
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-9-pasha.tatashin@oracle.com>
 <20171003131817.omzbam3js67edp3s@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <691dba28-718c-e9a9-d006-88505eb5cd7e@oracle.com>
Date: Tue, 3 Oct 2017 11:29:16 -0400
MIME-Version: 1.0
In-Reply-To: <20171003131817.omzbam3js67edp3s@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On 10/03/2017 09:18 AM, Michal Hocko wrote:
> On Wed 20-09-17 16:17:10, Pavel Tatashin wrote:
>> Some memory is reserved but unavailable: not present in memblock.memory
>> (because not backed by physical pages), but present in memblock.reserved.
>> Such memory has backing struct pages, but they are not initialized by going
>> through __init_single_page().
> 
> Could you be more specific where is such a memory reserved?
> 

I know of one example: trim_low_memory_range() unconditionally reserves 
from pfn 0, but e820__memblock_setup() might provide the exiting memory 
from pfn 1 (i.e. KVM).

But, there could be more based on this comment from linux/page-flags.h:

  19  * PG_reserved is set for special pages, which can never be swapped 
out. Some
  20  * of them might not even exist (eg empty_bad_page)...

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
