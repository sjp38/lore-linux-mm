Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6DDEE6B038C
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 09:20:45 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v66so13948013wrc.4
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 06:20:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k19si3240874wmi.79.2017.03.17.06.20.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 06:20:44 -0700 (PDT)
Date: Fri, 17 Mar 2017 14:20:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] rework memory hotplug onlining
Message-ID: <20170317132036.GI26298@dhcp22.suse.cz>
References: <20170315091347.GA32626@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170315091347.GA32626@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, Zhang Zhen <zhenzhang.zhang@huawei.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Andi Kleen <ak@linux.intel.com>

On Wed 15-03-17 10:13:47, Michal Hocko wrote:
[...]
> It seems that all this is just started by the semantic introduced by
> 9d99aaa31f59 ("[PATCH] x86_64: Support memory hotadd without sparsemem")
> quite some time ago. When the movable onlinining has been introduced it
> just built on top of this. It seems that the requirement to have
> freshly probed memory associated with the zone normal is no longer
> necessary. HOTPLUG depends on CONFIG_SPARSEMEM these days.
> 
> The following blob [2] simply removes all the zone specific operations
> from __add_pages (aka arch_add_memory) path.  Instead we do page->zone
> association from move_pfn_range which is called from online_pages. The
> criterion for movable/normal zone association is really simple now. We
> just have to guarantee that zone Normal is always lower than zone
> Movable. It would be actually sufficient to guarantee they do not
> overlap and that is indeed trivial to implement now. I didn't do that
> yet for simplicity of this change though.

Does anybody have any comments on this? Any issues I've overlooked
(except for the one pointed by Toshi Kani which is already fixed in my
local branch)?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
