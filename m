Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1EA776B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 11:35:05 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 37so5262013qto.2
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 08:35:05 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id q196si4079471qke.194.2017.10.03.08.35.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 08:35:04 -0700 (PDT)
Subject: Re: [PATCH v9 12/12] mm: stop zeroing memory during allocation in
 vmemmap
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-13-pasha.tatashin@oracle.com>
 <20171003131952.aqq377pjug5me6go@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <c028f65a-b4a6-e56d-3a50-5d7ad9af50cb@oracle.com>
Date: Tue, 3 Oct 2017 11:34:25 -0400
MIME-Version: 1.0
In-Reply-To: <20171003131952.aqq377pjug5me6go@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On 10/03/2017 09:19 AM, Michal Hocko wrote:
> On Wed 20-09-17 16:17:14, Pavel Tatashin wrote:
>> vmemmap_alloc_block() will no longer zero the block, so zero memory
>> at its call sites for everything except struct pages.  Struct page memory
>> is zero'd by struct page initialization.
>>
>> Replace allocators in sprase-vmemmap to use the non-zeroing version. So,
>> we will get the performance improvement by zeroing the memory in parallel
>> when struct pages are zeroed.
> 
> Is it possible to merge this patch with http://lkml.kernel.org/r/20170920201714.19817-7-pasha.tatashin@oracle.com

Yes, I will do that. It would also require re-arranging
[PATCH v9 07/12] sparc64: optimized struct page zeroing
optimization to come after this patch.

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
