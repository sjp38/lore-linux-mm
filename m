Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 41F226B039F
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 03:31:01 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y77so27189333wrb.22
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 00:31:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l2si23277476wre.212.2017.04.04.00.30.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 00:31:00 -0700 (PDT)
Date: Tue, 4 Apr 2017 09:30:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/6] mm: remove return value from
 init_currently_empty_zone
Message-ID: <20170404073056.GB15132@dhcp22.suse.cz>
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170330115454.32154-4-mhocko@kernel.org>
 <20170403212232.s3zynq2hh6hpnefr@arbab-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170403212232.s3zynq2hh6hpnefr@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Mon 03-04-17 16:22:32, Reza Arbab wrote:
> On Thu, Mar 30, 2017 at 01:54:51PM +0200, Michal Hocko wrote:
> >init_currently_empty_zone doesn't have any error to return yet it is
> >still an int and callers try to be defensive and try to handle potential
> >error. Remove this nonsense and simplify all callers.
> 
> Semi-related; arch_remove_memory() returns int, but callers ignore it.
> 
> Is that worth cleaning up? If so, should the implementations be simplified,
> or should we maybe do a pr_error() or something with it?

No, pr_error is not really helpful. Either that path can fail and we
should handle it properly - which will be hard because remove_memory
cannot handle that or we should just make arch_remove_memory
non-failing. I have a suspicion that this path doesn't really fail
in fact. This requires a deeper inspection though. I've put that on my
todo list.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
