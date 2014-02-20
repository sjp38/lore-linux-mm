Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 873AF6B003B
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 22:46:44 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id jt11so1322043pbb.15
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 19:46:44 -0800 (PST)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id f1si2152165pbn.106.2014.02.19.19.46.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 19:46:43 -0800 (PST)
Received: by mail-pd0-f173.google.com with SMTP id y10so1252882pdj.18
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 19:46:43 -0800 (PST)
Date: Wed, 19 Feb 2014 19:46:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
In-Reply-To: <20140220022254.GA25898@amt.cnet>
Message-ID: <alpine.DEB.2.02.1402191941330.29913@chino.kir.corp.google.com>
References: <1392339728-13487-1-git-send-email-lcapitulino@redhat.com> <1392339728-13487-5-git-send-email-lcapitulino@redhat.com> <alpine.DEB.2.02.1402141511200.13935@chino.kir.corp.google.com> <20140214225810.57e854cb@redhat.com>
 <alpine.DEB.2.02.1402150159540.28883@chino.kir.corp.google.com> <20140217085622.39b39cac@redhat.com> <alpine.DEB.2.02.1402171518080.25724@chino.kir.corp.google.com> <20140218123013.GA20609@amt.cnet> <alpine.DEB.2.02.1402181407510.20772@chino.kir.corp.google.com>
 <20140220022254.GA25898@amt.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 19 Feb 2014, Marcelo Tosatti wrote:

> We agree that, in the future, we'd like to provide the ability to
> dynamically allocate and free 1GB pages at runtime.
> 
> Extending the kernel command line interface is a first step.
> 
> Do you have a concrete objection to that first step ?
> 

Yes, my concrete objection is that the command line interface is 
unnecessary if you can dynamically allocate and free 1GB pages at runtime 
unless memory will be so fragmented that it cannot be done when userspace 
is brought up.  That is not your use case, thus this support is not 
needed.  I think Mel also brought up this point.

There's no "first step" about it, this is unnecessary for your use case if 
you can do it at runtime.  I'm not sure what's so surprising about this.

> > You can't specify an interleave behavior with Luiz's command line 
> > interface so now we'd have two different interfaces for allocating 
> > hugepage sizes depending on whether you're specifying a node or not.  
> > It's "hugepagesz=1G hugepages=16" vs "hugepage_node=1:16:1G" (and I'd have 
> > to look at previous messages in this thread to see if that means 16 1GB 
> > pages on node 1 or 1 1GB pages on node 16.)
> 
> What syntax do you prefer and why ?
> 

I'm not sure it's interesting to talk about since this patchset is 
unnecessary if you can do it at runtime, but since "hugepagesz=" and 
"hugepages=" have existed for many kernel releases, we must maintain 
backwards compatibility.  Thus, it seems, the easiest addition would have 
been "hugepagesnode=" which I've mentioned several times, there's no 
reason to implement yet another command line option purely as a shorthand 
which hugepage_node=1:2:1G is and in a very cryptic way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
