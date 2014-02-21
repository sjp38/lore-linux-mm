Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 47F546B00DC
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 17:04:07 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id jt11so4033459pbb.11
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 14:04:06 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id xn1si8452200pbc.158.2014.02.21.14.04.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Feb 2014 14:04:06 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so4058234pab.33
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 14:04:05 -0800 (PST)
Date: Fri, 21 Feb 2014 14:04:03 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
In-Reply-To: <20140221191055.GD19955@amt.cnet>
Message-ID: <alpine.DEB.2.02.1402211358030.4682@chino.kir.corp.google.com>
References: <20140217085622.39b39cac@redhat.com> <alpine.DEB.2.02.1402171518080.25724@chino.kir.corp.google.com> <20140218123013.GA20609@amt.cnet> <alpine.DEB.2.02.1402181407510.20772@chino.kir.corp.google.com> <20140220022254.GA25898@amt.cnet>
 <alpine.DEB.2.02.1402191941330.29913@chino.kir.corp.google.com> <20140220213407.GA11048@amt.cnet> <alpine.DEB.2.02.1402201502580.30647@chino.kir.corp.google.com> <20140221022800.GA30230@amt.cnet> <alpine.DEB.2.02.1402210158400.17851@chino.kir.corp.google.com>
 <20140221191055.GD19955@amt.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 21 Feb 2014, Marcelo Tosatti wrote:

> > I agree that your customer wants a non-default distribution of 1GB 
> > hugepages, yes, that's clear.  The questions that have not been answered: 
> > why must it be done this way as opposed to runtime?  If 1GB hugepages 
> > could be dynamically allocated, would your customer be able to use it?  If 
> > not, why not?  If dynamic allocation resolves all the issues, then is this 
> > patchset a needless maintenance burden if we had such support today?
> 
> It must be done this way because:
> 
> 1) its the only interface which is easily backportable.
> 

There's no pending patchset that adds dynamic allocation of GB hugepages 
so you can't comment on what is easily backportable and which isn't.

> 2) it improves the kernel command line interface from incomplete
> (lacking the ability to specify node<->page correlation), to 
> a complete interface.
> 

If GB hugepages can be allocated dynamically, I really think we should be 
able to remove hugepagesz= entirely for x86 after a few years of 
supporting it for backwards compatibility, even though Linus has insisted 
that we never break userspace in the past (which should discourage us 
from adding additional command line interfaces which are obsoleted in the 
future, such as in this case).

Still waiting on an answer to whether your customer would be able to 
dynamically allocate 1GB hugepages at runtime if we had such support and, 
if not, please show why not?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
