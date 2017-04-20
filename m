Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 06E212806D2
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 04:39:02 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k14so4863146wrc.16
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 01:39:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v14si8487650wmv.82.2017.04.20.01.39.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Apr 2017 01:39:00 -0700 (PDT)
Subject: Re: [PATCH 9/9] mm, memory_hotplug: remove unused cruft after memory
 hotplug rework
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410110351.12215-10-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3fa78766-071b-832b-dd12-2e33fd0c2ade@suse.cz>
Date: Thu, 20 Apr 2017 10:38:59 +0200
MIME-Version: 1.0
In-Reply-To: <20170410110351.12215-10-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 04/10/2017 01:03 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> zone_for_memory doesn't have any user anymore as well as the whole zone
> shifting infrastructure so drop them all.
> 
> This shouldn't introduce any functional changes.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
