Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id A18656B0006
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 08:52:46 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id b2so3903716plm.23
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 05:52:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l4-v6si1909014pln.121.2018.02.23.05.52.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Feb 2018 05:52:45 -0800 (PST)
Date: Fri, 23 Feb 2018 14:52:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm, compaction: correct the bounds of
 __fragmentation_index()
Message-ID: <20180223135239.GV30681@dhcp22.suse.cz>
References: <1518972475-11340-1-git-send-email-robert.m.harris@oracle.com>
 <1518972475-11340-2-git-send-email-robert.m.harris@oracle.com>
 <20180219082649.GD21134@dhcp22.suse.cz>
 <E718672A-91A0-4A5A-91B5-A6CF1E9BD544@oracle.com>
 <20180219123932.GF21134@dhcp22.suse.cz>
 <90E01411-7511-4E6C-BDDF-74E0334E24FC@oracle.com>
 <20180223091020.GS30681@dhcp22.suse.cz>
 <2958E989-B084-4DA3-8350-CD20AD04392B@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2958E989-B084-4DA3-8350-CD20AD04392B@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Harris <robert.m.harris@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Yafang Shao <laoar.shao@gmail.com>, Kangmin Park <l4stpr0gr4m@gmail.com>, Mel Gorman <mgorman@suse.de>, Yisheng Xie <xieyisheng1@huawei.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Huang Ying <ying.huang@intel.com>, Vinayak Menon <vinmenon@codeaurora.org>

On Fri 23-02-18 13:40:09, Robert Harris wrote:
> If you are asking me to prove whether modifying the tuneable in the
> manner above, thereby preferring compaction for more fragmented systems,
> is successful then I can't answer now.  I assume that the onus would
> have been on Mel to show this at the time of the original commit.
> However, I interpret his last comment on this patch as a request to
> verify that changing the preference yields sane results.

Yes, this is exactly were I was aiming... This might have been useful
during the initial compaction implementation but I am not aware of any
real users and I am also quite skeptical it is very much useful. I do
realize that this is hand waving because I do not have any numbers at
hands. The bottom line is that the users should care, really. The
compaction should be as automatic as possible. We can argue about
tuning for certain allocation orders and make the compaction more
pro-active to provide lower latencies for those requests but deciding
whether to reclaim or compact sounds like a too low level decision for
admin to make and kind of unstable interface for different kernels as
the implementation of the compaction changes over time.

So I would really prefer to kill the tuning than try to "fix" it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
