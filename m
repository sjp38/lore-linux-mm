Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0087E6B0069
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 16:33:52 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c4so568702230pfb.7
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 13:33:51 -0800 (PST)
Received: from mail-pg0-x22c.google.com (mail-pg0-x22c.google.com. [2607:f8b0:400e:c05::22c])
        by mx.google.com with ESMTPS id m17si51222914pli.290.2016.12.28.13.33.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Dec 2016 13:33:50 -0800 (PST)
Received: by mail-pg0-x22c.google.com with SMTP id g1so120149991pgn.0
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 13:33:50 -0800 (PST)
Date: Wed, 28 Dec 2016 13:33:49 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
In-Reply-To: <20161228084823.GB11470@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1612281332320.13632@chino.kir.corp.google.com>
References: <20161222100009.GA6055@dhcp22.suse.cz> <alpine.DEB.2.10.1612221259100.29036@chino.kir.corp.google.com> <20161223085150.GA23109@dhcp22.suse.cz> <alpine.DEB.2.10.1612230154450.88514@chino.kir.corp.google.com> <20161223111817.GC23109@dhcp22.suse.cz>
 <alpine.DEB.2.10.1612231428030.88276@chino.kir.corp.google.com> <20161226090211.GA11455@dhcp22.suse.cz> <alpine.DEB.2.10.1612261639550.99744@chino.kir.corp.google.com> <20161227094008.GC1308@dhcp22.suse.cz> <alpine.DEB.2.10.1612271324300.67790@chino.kir.corp.google.com>
 <20161228084823.GB11470@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 28 Dec 2016, Michal Hocko wrote:

> I do care more about _users_ and their _experience_ than what
> application _writers_ think is the best. This is the whole point
> of giving the defrag tunable. madvise(MADV_HUGEPAGE) is just a hint to
> the system that using transparent hugepages is _preferable_, not
> mandatory. We have an option to allow stalls for those vmas to increase
> the allocation success rate. We also have tunable to completely ignore
> it. And we should also have an option to not stall.
> 

The application developer who uses madvise(MADV_HUGEPAGE) is doing so for 
a reason.

We lack the ability to defragment in the background for all users who 
don't want to block while allowing madvise(MADV_HUGEPAGE) users to block, 
as the changelog for this patch clearly indicates.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
