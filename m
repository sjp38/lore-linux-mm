Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f52.google.com (mail-bk0-f52.google.com [209.85.214.52])
	by kanga.kvack.org (Postfix) with ESMTP id AC37C6B00F6
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 23:04:16 -0500 (EST)
Received: by mail-bk0-f52.google.com with SMTP id e11so1295162bkh.11
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 20:04:15 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id ea6si4039293bkb.52.2014.02.21.20.03.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 21 Feb 2014 20:04:14 -0800 (PST)
Date: Sat, 22 Feb 2014 05:03:50 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
Message-ID: <20140222040350.GI22728@two.firstfloor.org>
References: <1392339728-13487-1-git-send-email-lcapitulino@redhat.com>
 <1392339728-13487-5-git-send-email-lcapitulino@redhat.com>
 <alpine.DEB.2.02.1402141511200.13935@chino.kir.corp.google.com>
 <20140214225810.57e854cb@redhat.com>
 <alpine.DEB.2.02.1402150159540.28883@chino.kir.corp.google.com>
 <1392702456.2468.4.camel@buesod1.americas.hpqcorp.net>
 <20140221155423.6c6689e27fa10ed394f01843@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140221155423.6c6689e27fa10ed394f01843@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Davidlohr Bueso <davidlohr@hp.com>, David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>, mtosatti@redhat.com, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> But I think it would be better if it made hugepages= and hugepagesz=
> obsolete, so we can emit a printk if people use those, telling them
> to migrate because the old options are going away.

Not sure why everyone wants to break existing systems. These options
have existed for many years, you cannot not just remove them.

Also the old options are totally fine and work adequately for the
vast majority of users who do not need to control node assignment
fine grained.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
