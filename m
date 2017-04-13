Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 27D396B03B9
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 08:59:04 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b124so2901276wmf.6
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 05:59:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r2si20724805wra.223.2017.04.13.05.59.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Apr 2017 05:59:02 -0700 (PDT)
Subject: Re: [PATCH 3/9] mm: drop page_initialized check from get_nid_for_pfn
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410110351.12215-4-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1157048b-512d-277b-b005-3703ffec4907@suse.cz>
Date: Thu, 13 Apr 2017 14:59:00 +0200
MIME-Version: 1.0
In-Reply-To: <20170410110351.12215-4-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 04/10/2017 01:03 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> c04fc586c1a4 ("mm: show node to memory section relationship with
> symlinks in sysfs") has added means to export memblock<->node
> association into the sysfs. It has also introduced get_nid_for_pfn
> which is a rather confusing counterpart of pfn_to_nid which checks also
> whether the pfn page is already initialized (page_initialized).  This
> is done by checking page::lru != NULL which doesn't make any sense at
> all. Nothing in this path really relies on the lru list being used or
> initialized. Just remove it because this will become a problem with
> later patches.
> 
> Thanks to Reza Arbab for testing which revealed this to be a problem
> (http://lkml.kernel.org/r/20170403202337.GA12482@dhcp22.suse.cz)
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
