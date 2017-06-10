Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 98E086B0292
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 22:20:22 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w127so1686788oiw.11
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 19:20:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q139sor855196oic.18.2017.06.09.19.20.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Jun 2017 19:20:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170609104947.GD21764@dhcp22.suse.cz>
References: <20170515085827.16474-1-mhocko@kernel.org> <CADZGycZvW1pTxt_NifTVmO3u_4694=JHe3k8xbESmhu4aonF-w@mail.gmail.com>
 <20170609104947.GD21764@dhcp22.suse.cz>
From: Wei Yang <richard.weiyang@gmail.com>
Date: Sat, 10 Jun 2017 10:20:00 +0800
Message-ID: <CADZGycYTBJ8QoecdLJspO2S113B03mwAGvTa9cpuf0YBb2C3Sg@mail.gmail.com>
Subject: Re: [PATCH -v4 0/14] mm: make movable onlining suck less
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tobias Regnery <tobias.regnery@gmail.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

On Fri, Jun 9, 2017 at 6:49 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 09-06-17 17:51:24, Wei Yang wrote:
>> Hi, Michal
>>
>> I am not that familiar with hotplug and trying to catch up the issue
>>  and your solution.
>>
>> One potential issue I found is we don't check the physical boundary
>> when add_memory_resource().
>>
>> For example, on x86-64, only 64T physical memory is supported currently.
>> Looks it is expanded after 5-level pagetable is introduced. While there is
>> still some limitations on this. But we don't check the boundary I think.
>>
>> During the bootup, this is ensured by the max_pfn which is guaranteed to
>> be under MAX_ARCH_PFN. I don't see some limitation on this when doing
>>  hotplug.
>
> This might be true and I would have to double check but this rework
> doesn't change anything in that regards. Or do I miss something?

Ah, yes, I believe your patch set don't touch this area.

This is just related to hotplug.

> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
