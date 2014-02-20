Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id DAF286B00A0
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 17:08:52 -0500 (EST)
Received: by mail-ee0-f51.google.com with SMTP id b57so1244284eek.10
        for <linux-mm@kvack.org>; Thu, 20 Feb 2014 14:08:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v5si11768795eel.13.2014.02.20.14.08.50
        for <linux-mm@kvack.org>;
        Thu, 20 Feb 2014 14:08:51 -0800 (PST)
Date: Thu, 20 Feb 2014 18:34:07 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
Message-ID: <20140220213407.GA11048@amt.cnet>
References: <1392339728-13487-5-git-send-email-lcapitulino@redhat.com>
 <alpine.DEB.2.02.1402141511200.13935@chino.kir.corp.google.com>
 <20140214225810.57e854cb@redhat.com>
 <alpine.DEB.2.02.1402150159540.28883@chino.kir.corp.google.com>
 <20140217085622.39b39cac@redhat.com>
 <alpine.DEB.2.02.1402171518080.25724@chino.kir.corp.google.com>
 <20140218123013.GA20609@amt.cnet>
 <alpine.DEB.2.02.1402181407510.20772@chino.kir.corp.google.com>
 <20140220022254.GA25898@amt.cnet>
 <alpine.DEB.2.02.1402191941330.29913@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402191941330.29913@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Feb 19, 2014 at 07:46:41PM -0800, David Rientjes wrote:
> On Wed, 19 Feb 2014, Marcelo Tosatti wrote:
> 
> > We agree that, in the future, we'd like to provide the ability to
> > dynamically allocate and free 1GB pages at runtime.
> > 
> > Extending the kernel command line interface is a first step.
> > 
> > Do you have a concrete objection to that first step ?
> > 
> 
> Yes, my concrete objection is that the command line interface is 
> unnecessary if you can dynamically allocate and free 1GB pages at runtime 
> unless memory will be so fragmented that it cannot be done when userspace 
> is brought up.  That is not your use case, thus this support is not 
> needed.  I think Mel also brought up this point.
>
> There's no "first step" about it, this is unnecessary for your use case if 
> you can do it at runtime.  I'm not sure what's so surprising about this.

Mel has clearly has no objection to the command line. You can also
allocate 2M pages at runtime, and that is no reason for "hugepages="
interface to not exist. 

There is a number of parameters that are modifiable via the kernel
command line, so following your reasoning, they should all be removed,
because it can be done at runtime.

> > > You can't specify an interleave behavior with Luiz's command line 
> > > interface so now we'd have two different interfaces for allocating 
> > > hugepage sizes depending on whether you're specifying a node or not.  
> > > It's "hugepagesz=1G hugepages=16" vs "hugepage_node=1:16:1G" (and I'd have 
> > > to look at previous messages in this thread to see if that means 16 1GB 
> > > pages on node 1 or 1 1GB pages on node 16.)
> > 
> > What syntax do you prefer and why ?
> > 
> 
> I'm not sure it's interesting to talk about since this patchset is 
> unnecessary if you can do it at runtime, but since "hugepagesz=" and 
> "hugepages=" have existed for many kernel releases, we must maintain 
> backwards compatibility. 

Yes, we'd like to maintain backwards compatibility.

> Thus, it seems, the easiest addition would have 
> been "hugepagesnode=" which I've mentioned several times, there's no 
> reason to implement yet another command line option purely as a shorthand 
> which hugepage_node=1:2:1G is and in a very cryptic way.

Can you state your suggestion clearly (or point to such messages), and
list the advantages of it versus the proposed patch ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
