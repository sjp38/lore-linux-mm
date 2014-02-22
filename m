Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7FE6B00F8
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 23:31:20 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id y13so882909pdi.31
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 20:31:19 -0800 (PST)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id gk3si9407741pac.31.2014.02.21.20.31.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 21 Feb 2014 20:31:19 -0800 (PST)
Message-ID: <1393043471.2473.0.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Fri, 21 Feb 2014 20:31:11 -0800
In-Reply-To: <20140222040350.GI22728@two.firstfloor.org>
References: <1392339728-13487-1-git-send-email-lcapitulino@redhat.com>
	 <1392339728-13487-5-git-send-email-lcapitulino@redhat.com>
	 <alpine.DEB.2.02.1402141511200.13935@chino.kir.corp.google.com>
	 <20140214225810.57e854cb@redhat.com>
	 <alpine.DEB.2.02.1402150159540.28883@chino.kir.corp.google.com>
	 <1392702456.2468.4.camel@buesod1.americas.hpqcorp.net>
	 <20140221155423.6c6689e27fa10ed394f01843@linux-foundation.org>
	 <20140222040350.GI22728@two.firstfloor.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>, mtosatti@redhat.com, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 2014-02-22 at 05:03 +0100, Andi Kleen wrote:
> > But I think it would be better if it made hugepages= and hugepagesz=
> > obsolete, so we can emit a printk if people use those, telling them
> > to migrate because the old options are going away.
> 
> Not sure why everyone wants to break existing systems. These options
> have existed for many years, you cannot not just remove them.
> 
> Also the old options are totally fine and work adequately for the
> vast majority of users who do not need to control node assignment
> fine grained.

Yes, please, why can't both options just coexist.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
