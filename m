Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 76C156B02B4
	for <linux-mm@kvack.org>; Mon, 29 May 2017 08:08:25 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 139so13089340wmf.5
        for <linux-mm@kvack.org>; Mon, 29 May 2017 05:08:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u19si9875101edi.214.2017.05.29.05.08.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 May 2017 05:08:24 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm, memory_hotplug: move movable_node to the hotplug
 proper
References: <20170529114141.536-1-mhocko@kernel.org>
 <20170529114141.536-4-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <da3523bc-02cb-9cbd-4ad4-7dacdbc43fee@suse.cz>
Date: Mon, 29 May 2017 14:08:19 +0200
MIME-Version: 1.0
In-Reply-To: <20170529114141.536-4-mhocko@kernel.org>
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
> movable_node_is_enabled is defined in memblock proper while it
> is initialized from the memory hotplug proper. This is quite messy
> and it makes a dependency between the two so move movable_node along
> with the helper functions to memory_hotplug.
> 
> To make it more entertaining the kernel parameter is ignored unless
> CONFIG_HAVE_MEMBLOCK_NODE_MAP=y because we do not have the node
> information for each memblock otherwise. So let's warn when the option
> is disabled.
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
