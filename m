Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0DE506B03B5
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 08:46:18 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z62so6230537wrc.0
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 05:46:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e43si33905281wre.126.2017.04.13.05.46.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Apr 2017 05:46:16 -0700 (PDT)
Subject: Re: [PATCH 2/9] mm, memory_hotplug: use node instead of zone in
 can_online_high_movable
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410110351.12215-3-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <cb9c1efd-8855-6bea-6c0f-15fa96cd9e8f@suse.cz>
Date: Thu, 13 Apr 2017 14:46:14 +0200
MIME-Version: 1.0
In-Reply-To: <20170410110351.12215-3-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 04/10/2017 01:03 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> the primary purpose of this helper is to query the node state so use
> the node id directly. This is a preparatory patch for later changes.
> 
> This shouldn't introduce any functional change
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
