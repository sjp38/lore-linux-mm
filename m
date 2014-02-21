Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC2E6B00D0
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 14:11:37 -0500 (EST)
Received: by mail-we0-f170.google.com with SMTP id w62so2897483wes.29
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 11:11:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id cy3si3689730wib.39.2014.02.21.11.11.34
        for <linux-mm@kvack.org>;
        Fri, 21 Feb 2014 11:11:35 -0800 (PST)
Date: Fri, 21 Feb 2014 16:10:55 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
Message-ID: <20140221191055.GD19955@amt.cnet>
References: <20140217085622.39b39cac@redhat.com>
 <alpine.DEB.2.02.1402171518080.25724@chino.kir.corp.google.com>
 <20140218123013.GA20609@amt.cnet>
 <alpine.DEB.2.02.1402181407510.20772@chino.kir.corp.google.com>
 <20140220022254.GA25898@amt.cnet>
 <alpine.DEB.2.02.1402191941330.29913@chino.kir.corp.google.com>
 <20140220213407.GA11048@amt.cnet>
 <alpine.DEB.2.02.1402201502580.30647@chino.kir.corp.google.com>
 <20140221022800.GA30230@amt.cnet>
 <alpine.DEB.2.02.1402210158400.17851@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402210158400.17851@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Feb 21, 2014 at 02:07:08AM -0800, David Rientjes wrote:
> On Thu, 20 Feb 2014, Marcelo Tosatti wrote:
> 
> > > 1GB is of such granularity that you'd typically either be (a) oom so that 
> > > your userspace couldn't even start, or (b) have enough memory such that 
> > > userspace would be able to start and allocate them dynamically through an 
> > > initscript.
> > 
> > There are a number of kernel command line parameters which can be
> > modified in runtime as well.
> > 
> 
> We could also make the kernel command line implement a shell scripting 
> language of your choice.  There's no technical objection to it, of course 
> you can do it, but is it in the interest of the kernel in terms of 
> maintainability?
> 
> > You are asking what is the use-case.
> > 
> 
> I'm asking what the use case is because it's still not explained.  You say 
> a customer wants 8 1GB hugepages on node 0 on a 32GB machine.  Perfectly 
> understandable.  The only thing missing, and is practically begging to be 
> answered in this thread, is why must it be done on the command line?  That 
> would be the justification for the patchset.  Andrew asked for Luiz to 
> elaborate originally and even today the use case is not well described.

It is explained. You deleted it while replying (feel free to ask for
more information there and it will be provided).

> If you're asking for a maintenance burden to be accepted forever, it seems 
> like as part of your due diligence that you would show why it must be done 
> that way.  

It does not have to be maintained forever. See 
27be457000211a6903968dfce06d5f73f051a217 for one or git log for many
commands which have been removed.

If it becomes a maintenance burden, it can be removed.

> Being the easiest or "pragmatic" is not it, there is a much 
> larger set of people who would be interested in dynamic allocation, myself 
> and Google included.

OK.

> > A particular distribution is irrelevant. What you want is a non default
> > distribution of 1GB hugepages.
> > 
> > Can you agree with that ? (forget about particular values, please).
> > 
> 
> I agree that your customer wants a non-default distribution of 1GB 
> hugepages, yes, that's clear.  The questions that have not been answered: 
> why must it be done this way as opposed to runtime?  If 1GB hugepages 
> could be dynamically allocated, would your customer be able to use it?  If 
> not, why not?  If dynamic allocation resolves all the issues, then is this 
> patchset a needless maintenance burden if we had such support today?

It must be done this way because:

1) its the only interface which is easily backportable.

2) it improves the kernel command line interface from incomplete
(lacking the ability to specify node<->page correlation), to 
a complete interface.

And also, the existance of the command line interface does not interfere in
any way with the dynamic allocation in userspace (just as you can
allocate 2M pages via kernel command line _and_ allocate during
runtime).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
