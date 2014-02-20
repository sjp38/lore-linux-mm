Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5ADAB6B00A5
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 18:17:58 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so2571796pad.36
        for <linux-mm@kvack.org>; Thu, 20 Feb 2014 15:17:57 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id yf8si5179470pab.265.2014.02.20.15.17.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Feb 2014 15:17:57 -0800 (PST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so2614054pad.28
        for <linux-mm@kvack.org>; Thu, 20 Feb 2014 15:17:57 -0800 (PST)
Date: Thu, 20 Feb 2014 15:17:55 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
In-Reply-To: <20140220213854.GB11486@amt.cnet>
Message-ID: <alpine.DEB.2.02.1402201516140.30647@chino.kir.corp.google.com>
References: <1392339728-13487-5-git-send-email-lcapitulino@redhat.com> <alpine.DEB.2.02.1402141511200.13935@chino.kir.corp.google.com> <20140214225810.57e854cb@redhat.com> <alpine.DEB.2.02.1402150159540.28883@chino.kir.corp.google.com> <20140217085622.39b39cac@redhat.com>
 <alpine.DEB.2.02.1402171518080.25724@chino.kir.corp.google.com> <20140218123013.GA20609@amt.cnet> <alpine.DEB.2.02.1402181407510.20772@chino.kir.corp.google.com> <20140220022254.GA25898@amt.cnet> <alpine.DEB.2.02.1402191941330.29913@chino.kir.corp.google.com>
 <20140220213854.GB11486@amt.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 20 Feb 2014, Marcelo Tosatti wrote:

> > I'm not sure it's interesting to talk about since this patchset is 
> > unnecessary if you can do it at runtime, but since "hugepagesz=" and 
> > "hugepages=" have existed for many kernel releases, we must maintain 
> > backwards compatibility.  Thus, it seems, the easiest addition would have 
> > been "hugepagesnode=" which I've mentioned several times, there's no 
> > reason to implement yet another command line option purely as a shorthand 
> > which hugepage_node=1:2:1G is and in a very cryptic way.
> 
> There is one point from Davidlohr Bueso in favour of the proposed
> command line interface. Did you consider that aspect?
> 

I did before he posted it, in 
http://marc.info/?l=linux-kernel&m=139267940609315.  I don't think "large 
machines" open up the use case for 4 1GB hugepages on node 0, 12 2MB 
hugepages on node 0, 6 1GB hugepages on node 1, 24 2MB hugepages on node 
1, 2 1GB hugepages on node 2, 100 2MB hugepages on node 3, etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
