Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 856822806D2
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 04:29:54 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b124so2436318wmf.6
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 01:29:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y18si2476352wry.7.2017.04.20.01.29.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Apr 2017 01:29:53 -0700 (PDT)
Subject: Re: [PATCH 7/9] mm, memory_hotplug: replace for_device by
 want_memblock in arch_add_memory
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410110351.12215-8-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <13134523-80c2-92bc-ec4c-11d9e34f94a3@suse.cz>
Date: Thu, 20 Apr 2017 10:29:51 +0200
MIME-Version: 1.0
In-Reply-To: <20170410110351.12215-8-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@gmail.com>

On 04/10/2017 01:03 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> arch_add_memory gets for_device argument which then controls whether we
> want to create memblocks for created memory sections. Simplify the logic
> by telling whether we want memblocks directly rather than going through
> pointless negation. This also makes the api easier to understand because
> it is clear what we want rather than nothing telling for_device which
> can mean anything.
> 
> This shouldn't introduce any functional change.
> 
> Cc: Dan Williams <dan.j.williams@gmail.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
