Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB6A96B0038
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 01:37:50 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id e26so6950804pfi.15
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 22:37:50 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id o128si4514221pfo.201.2017.12.14.22.37.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 22:37:49 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -V2] mm, swap: Fix race between swapoff and some swap operations
References: <20171214133832.11266-1-ying.huang@intel.com>
	<20171214151718.GS16951@dhcp22.suse.cz>
	<871sjwn5bk.fsf@yhuang-dev.intel.com>
Date: Fri, 15 Dec 2017 14:37:44 +0800
In-Reply-To: <871sjwn5bk.fsf@yhuang-dev.intel.com> (Ying Huang's message of
	"Fri, 15 Dec 2017 09:33:03 +0800")
Message-ID: <87bmj0lcnb.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

"Huang, Ying" <ying.huang@intel.com> writes:

> Michal Hocko <mhocko@kernel.org> writes:
>
>> Btw. have you considered pcp refcount framework. I would suspect that
>> this would give you close to SRCU performance.
>
> No.  I think pcp refcount doesn't fit here.  You should hold a initial
> refcount for pcp refcount, it isn't the case here.

Sorry, I am wrong here.  We have an initial refcount for swap device.
So pcp refcount could be used here.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
