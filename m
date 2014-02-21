Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id B4AE86B0036
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 05:07:14 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id ma3so610128pbc.16
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 02:07:14 -0800 (PST)
Received: from mail-pb0-x231.google.com (mail-pb0-x231.google.com [2607:f8b0:400e:c01::231])
        by mx.google.com with ESMTPS id k7si6678578pbl.11.2014.02.21.02.07.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Feb 2014 02:07:13 -0800 (PST)
Received: by mail-pb0-f49.google.com with SMTP id up15so3230135pbc.22
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 02:07:13 -0800 (PST)
Date: Fri, 21 Feb 2014 02:07:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
In-Reply-To: <20140221022800.GA30230@amt.cnet>
Message-ID: <alpine.DEB.2.02.1402210158400.17851@chino.kir.corp.google.com>
References: <20140214225810.57e854cb@redhat.com> <alpine.DEB.2.02.1402150159540.28883@chino.kir.corp.google.com> <20140217085622.39b39cac@redhat.com> <alpine.DEB.2.02.1402171518080.25724@chino.kir.corp.google.com> <20140218123013.GA20609@amt.cnet>
 <alpine.DEB.2.02.1402181407510.20772@chino.kir.corp.google.com> <20140220022254.GA25898@amt.cnet> <alpine.DEB.2.02.1402191941330.29913@chino.kir.corp.google.com> <20140220213407.GA11048@amt.cnet> <alpine.DEB.2.02.1402201502580.30647@chino.kir.corp.google.com>
 <20140221022800.GA30230@amt.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 20 Feb 2014, Marcelo Tosatti wrote:

> > 1GB is of such granularity that you'd typically either be (a) oom so that 
> > your userspace couldn't even start, or (b) have enough memory such that 
> > userspace would be able to start and allocate them dynamically through an 
> > initscript.
> 
> There are a number of kernel command line parameters which can be
> modified in runtime as well.
> 

We could also make the kernel command line implement a shell scripting 
language of your choice.  There's no technical objection to it, of course 
you can do it, but is it in the interest of the kernel in terms of 
maintainability?

> You are asking what is the use-case.
> 

I'm asking what the use case is because it's still not explained.  You say 
a customer wants 8 1GB hugepages on node 0 on a 32GB machine.  Perfectly 
understandable.  The only thing missing, and is practically begging to be 
answered in this thread, is why must it be done on the command line?  That 
would be the justification for the patchset.  Andrew asked for Luiz to 
elaborate originally and even today the use case is not well described.

If you're asking for a maintenance burden to be accepted forever, it seems 
like as part of your due diligence that you would show why it must be done 
that way.  Being the easiest or "pragmatic" is not it, there is a much 
larger set of people who would be interested in dynamic allocation, myself 
and Google included.

> A particular distribution is irrelevant. What you want is a non default
> distribution of 1GB hugepages.
> 
> Can you agree with that ? (forget about particular values, please).
> 

I agree that your customer wants a non-default distribution of 1GB 
hugepages, yes, that's clear.  The questions that have not been answered: 
why must it be done this way as opposed to runtime?  If 1GB hugepages 
could be dynamically allocated, would your customer be able to use it?  If 
not, why not?  If dynamic allocation resolves all the issues, then is this 
patchset a needless maintenance burden if we had such support today?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
