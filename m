Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 14BEB6B025E
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 07:56:21 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id xr1so98458967wjb.7
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 04:56:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 67si58502313wmt.21.2016.12.30.04.56.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Dec 2016 04:56:19 -0800 (PST)
Date: Fri, 30 Dec 2016 13:56:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
Message-ID: <20161230125615.GH13301@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com>
 <20161222100009.GA6055@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com>
 <20161230123620.jcuquzof3bpxomdn@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161230123620.jcuquzof3bpxomdn@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 30-12-16 12:36:20, Mel Gorman wrote:
[...]
> I'll neither ack nor nak this patch. However, I would much prefer an
> additional option be added to sysfs called defer-fault that would avoid
> all fault-based stalls but still potentially stall for MADV_HUGEPAGE.

Would you consider changing the semantic of defer=madvise to invoke
KSWAPD for !madvised vmas as acceptable. It would be a change in
semantic but I am wondering what would be a risk and potential
regression space.

Also I am planning to send a pro-active compaction based on a
"watermark" as an LSF/MM topic proposal. I suspect that no additional
thp specific tunable will be needed if we have a proper compaction
watermark tunable.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
