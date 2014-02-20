Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2B41A6B00A3
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 18:15:50 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id y10so2443962pdj.40
        for <linux-mm@kvack.org>; Thu, 20 Feb 2014 15:15:49 -0800 (PST)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id n8si3206131pab.145.2014.02.20.15.15.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Feb 2014 15:15:49 -0800 (PST)
Received: by mail-pd0-f180.google.com with SMTP id x10so2440857pdj.25
        for <linux-mm@kvack.org>; Thu, 20 Feb 2014 15:15:48 -0800 (PST)
Date: Thu, 20 Feb 2014 15:15:46 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
In-Reply-To: <20140220213407.GA11048@amt.cnet>
Message-ID: <alpine.DEB.2.02.1402201502580.30647@chino.kir.corp.google.com>
References: <1392339728-13487-5-git-send-email-lcapitulino@redhat.com> <alpine.DEB.2.02.1402141511200.13935@chino.kir.corp.google.com> <20140214225810.57e854cb@redhat.com> <alpine.DEB.2.02.1402150159540.28883@chino.kir.corp.google.com> <20140217085622.39b39cac@redhat.com>
 <alpine.DEB.2.02.1402171518080.25724@chino.kir.corp.google.com> <20140218123013.GA20609@amt.cnet> <alpine.DEB.2.02.1402181407510.20772@chino.kir.corp.google.com> <20140220022254.GA25898@amt.cnet> <alpine.DEB.2.02.1402191941330.29913@chino.kir.corp.google.com>
 <20140220213407.GA11048@amt.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 20 Feb 2014, Marcelo Tosatti wrote:

> Mel has clearly has no objection to the command line. You can also
> allocate 2M pages at runtime, and that is no reason for "hugepages="
> interface to not exist. 
> 

The "hugepages=" interface does exist and for good reason, when 
fragmentation is such that you cannot allocate that number of hugepages at 
runtime easily.  That's lacking from your use case: why can't your 
customer do it from an initscript?  So far, all you've said is that your 
customer wants 8 1GB hugepages on node 0 for a 32GB machine.

> There is a number of parameters that are modifiable via the kernel
> command line, so following your reasoning, they should all be removed,
> because it can be done at runtime.
> 

1GB is of such granularity that you'd typically either be (a) oom so that 
your userspace couldn't even start, or (b) have enough memory such that 
userspace would be able to start and allocate them dynamically through an 
initscript.

> Yes, we'd like to maintain backwards compatibility.
> 

Good, see below.

> > Thus, it seems, the easiest addition would have 
> > been "hugepagesnode=" which I've mentioned several times, there's no 
> > reason to implement yet another command line option purely as a shorthand 
> > which hugepage_node=1:2:1G is and in a very cryptic way.
> 
> Can you state your suggestion clearly (or point to such messages), and
> list the advantages of it versus the proposed patch ?
> 

My suggestion was posted on the same day this patchset was posted: 
http://marc.info/?l=linux-kernel&m=139241967514884 it would be helpful if 
you read the thread before asking for something that has been repeated 
over and over.

There's no need to implement a shorthand that combines a few kernel 
command line options.

That's not the issue, anymore, though, since there's no need for the 
patchset to begin with if you can dynamically allocate 1GB hugepages at 
runtime.  If your customer wanted 4096 2MB hugepages on node 0 instead of 
8 1GB hugepages on node 0, we'd not be having this conversation.

Do I really need to do your work for you and work on 1GB hugepages at 
runtime, which many more people would be interested in?  Or are we just 
seeking the easiest way out here with something that shuts the customer up 
and leaves a kernel command line option that we'll need to maintain to 
avoid breaking backwards compatibility in the future?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
