Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D5226B0069
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 11:16:38 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id h13so6587002qke.10
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 08:16:38 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id t74si660238qki.482.2017.10.03.08.16.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 08:16:37 -0700 (PDT)
Subject: Re: [PATCH v9 03/12] mm: deferred_init_memmap improvements
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-4-pasha.tatashin@oracle.com>
 <20171003125754.2kuqzkstywg7axhd@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <fc4ef789-d9a8-5dab-6508-f0fe8751b462@oracle.com>
Date: Tue, 3 Oct 2017 11:15:54 -0400
MIME-Version: 1.0
In-Reply-To: <20171003125754.2kuqzkstywg7axhd@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Michal,

> 
> Please be explicit that this is possible only because we discard
> memblock data later after 3010f876500f ("mm: discard memblock data
> later"). Also be more explicit how the new code works.

OK

> 
> I like how the resulting code is more compact and smaller.

That was the goal :)

> for_each_free_mem_range also looks more appropriate but I really detest
> the DEFERRED_FREE thingy. Maybe we can handle all that in a single goto
> section. I know this is not an art but manipulating variables from
> macros is more error prone and much more ugly IMHO.

Sure, I can re-arrange to have a goto place. Function won't be as small, 
and if compiler is not smart enough we might end up with having more 
branches than what my current code has.

> 
> please do not use macros. Btw. this deserves its own fix. I suspect that
> no CONFIG_HOLES_IN_ZONE arch enables DEFERRED_STRUCT_PAGE_INIT but
> purely from the review point of view it should be its own patch.

Sure, I will submit this patch separately from the rest of the project. 
In my opinion DEFERRED_STRUCT_PAGE_INIT is the way of the future, so we 
should make sure it is working with as many configs as possible.

Thank you,
Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
