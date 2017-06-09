Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C2766B0311
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 06:49:52 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a3so5351773wma.12
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 03:49:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t20si776335wra.224.2017.06.09.03.49.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Jun 2017 03:49:51 -0700 (PDT)
Date: Fri, 9 Jun 2017 12:49:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -v4 0/14] mm: make movable onlining suck less
Message-ID: <20170609104947.GD21764@dhcp22.suse.cz>
References: <20170515085827.16474-1-mhocko@kernel.org>
 <CADZGycZvW1pTxt_NifTVmO3u_4694=JHe3k8xbESmhu4aonF-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADZGycZvW1pTxt_NifTVmO3u_4694=JHe3k8xbESmhu4aonF-w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tobias Regnery <tobias.regnery@gmail.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

On Fri 09-06-17 17:51:24, Wei Yang wrote:
> Hi, Michal
> 
> I am not that familiar with hotplug and trying to catch up the issue
>  and your solution.
> 
> One potential issue I found is we don't check the physical boundary
> when add_memory_resource().
> 
> For example, on x86-64, only 64T physical memory is supported currently.
> Looks it is expanded after 5-level pagetable is introduced. While there is
> still some limitations on this. But we don't check the boundary I think.
> 
> During the bootup, this is ensured by the max_pfn which is guaranteed to
> be under MAX_ARCH_PFN. I don't see some limitation on this when doing
>  hotplug.

This might be true and I would have to double check but this rework
doesn't change anything in that regards. Or do I miss something?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
