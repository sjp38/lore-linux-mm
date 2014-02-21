Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f45.google.com (mail-bk0-f45.google.com [209.85.214.45])
	by kanga.kvack.org (Postfix) with ESMTP id C00696B00E0
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 17:36:18 -0500 (EST)
Received: by mail-bk0-f45.google.com with SMTP id mz13so1233885bkb.4
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 14:36:18 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id xx2si3882052bkb.121.2014.02.21.14.36.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 21 Feb 2014 14:36:17 -0800 (PST)
Date: Fri, 21 Feb 2014 23:36:16 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
Message-ID: <20140221223616.GG22728@two.firstfloor.org>
References: <20140218123013.GA20609@amt.cnet>
 <alpine.DEB.2.02.1402181407510.20772@chino.kir.corp.google.com>
 <20140220022254.GA25898@amt.cnet>
 <alpine.DEB.2.02.1402191941330.29913@chino.kir.corp.google.com>
 <20140220213407.GA11048@amt.cnet>
 <alpine.DEB.2.02.1402201502580.30647@chino.kir.corp.google.com>
 <20140221022800.GA30230@amt.cnet>
 <alpine.DEB.2.02.1402210158400.17851@chino.kir.corp.google.com>
 <20140221191055.GD19955@amt.cnet>
 <alpine.DEB.2.02.1402211358030.4682@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402211358030.4682@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> > 2) it improves the kernel command line interface from incomplete
> > (lacking the ability to specify node<->page correlation), to 
> > a complete interface.
> > 
> 
> If GB hugepages can be allocated dynamically, I really think we should be 
> able to remove hugepagesz= entirely for x86 after a few years of 
> supporting it for backwards compatibility, even though Linus has insisted 

That doesn't make any sense. Why break a perfectly fine interface?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
