Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9256B00E3
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 17:44:08 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id y10so648427pdj.1
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 14:44:08 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id xe9si8542224pab.257.2014.02.21.14.44.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Feb 2014 14:44:07 -0800 (PST)
Received: by mail-pa0-f48.google.com with SMTP id kx10so4060265pab.21
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 14:44:07 -0800 (PST)
Date: Fri, 21 Feb 2014 14:44:05 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
In-Reply-To: <20140221223616.GG22728@two.firstfloor.org>
Message-ID: <alpine.DEB.2.02.1402211440120.20113@chino.kir.corp.google.com>
References: <20140218123013.GA20609@amt.cnet> <alpine.DEB.2.02.1402181407510.20772@chino.kir.corp.google.com> <20140220022254.GA25898@amt.cnet> <alpine.DEB.2.02.1402191941330.29913@chino.kir.corp.google.com> <20140220213407.GA11048@amt.cnet>
 <alpine.DEB.2.02.1402201502580.30647@chino.kir.corp.google.com> <20140221022800.GA30230@amt.cnet> <alpine.DEB.2.02.1402210158400.17851@chino.kir.corp.google.com> <20140221191055.GD19955@amt.cnet> <alpine.DEB.2.02.1402211358030.4682@chino.kir.corp.google.com>
 <20140221223616.GG22728@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 21 Feb 2014, Andi Kleen wrote:

> > > 2) it improves the kernel command line interface from incomplete
> > > (lacking the ability to specify node<->page correlation), to 
> > > a complete interface.
> > > 
> > 
> > If GB hugepages can be allocated dynamically, I really think we should be 
> > able to remove hugepagesz= entirely for x86 after a few years of 
> > supporting it for backwards compatibility, even though Linus has insisted 
> 
> That doesn't make any sense. Why break a perfectly fine interface?
> 

I think doing hugepagesz= and not default_hugepagesz= is more of a hack 
just because we lack support for dynamically allocating some class of 
hugepage sizes and this is the only way to currently do it; if we had 
support for doing it at runtime then that hack probably isn't needed.  You 
would still be able to do default_hugepagesz=1G and allocate a ton of them 
when fragmentation is a concern and it can only truly be done at boot.  
Even then, with such a large size it doesn't seem absolutely necessary 
since you'd either be (a) oom as a result of all those hugepages or (b) 
there would be enough memory for initscripts to do this at runtime, this 
isn't the case with 2MB.

But, like I said, I'm not sure we'd ever be able to totally remove it 
because of backwards compatibility, but the point is that nobody would 
have to use it anymore as a hack for 1GB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
