Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 192906B0292
	for <linux-mm@kvack.org>; Mon, 29 May 2017 08:08:09 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b84so13088187wmh.0
        for <linux-mm@kvack.org>; Mon, 29 May 2017 05:08:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j14si8692478ede.2.2017.05.29.05.08.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 May 2017 05:08:07 -0700 (PDT)
Subject: Re: [PATCH 2/3] mm, memory_hotplug: drop CONFIG_MOVABLE_NODE
References: <20170529114141.536-1-mhocko@kernel.org>
 <20170529114141.536-3-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <519c2906-d2f5-4069-2d6a-d7c199e5980b@suse.cz>
Date: Mon, 29 May 2017 14:08:02 +0200
MIME-Version: 1.0
In-Reply-To: <20170529114141.536-3-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 05/29/2017 01:41 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> 20b2f52b73fe ("numa: add CONFIG_MOVABLE_NODE for movable-dedicated
> node") has introduced CONFIG_MOVABLE_NODE without a good explanation on
> why it is actually useful. It makes a lot of sense to make movable node
> semantic opt in but we already have that because the feature has to be
> explicitly enabled on the kernel command line. A config option on top
> only makes the configuration space larger without a good reason. It also
> adds an additional ifdefery that pollutes the code. Just drop the config
> option and make it de-facto always enabled. This shouldn't introduce any
> change to the semantic.
> 
> Acked-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
