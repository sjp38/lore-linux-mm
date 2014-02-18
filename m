Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id C10176B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 07:30:58 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id q59so11360984wes.23
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 04:30:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id lr14si11952436wic.0.2014.02.18.04.30.56
        for <linux-mm@kvack.org>;
        Tue, 18 Feb 2014 04:30:57 -0800 (PST)
Date: Tue, 18 Feb 2014 09:30:13 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
Message-ID: <20140218123013.GA20609@amt.cnet>
References: <1392339728-13487-1-git-send-email-lcapitulino@redhat.com>
 <1392339728-13487-5-git-send-email-lcapitulino@redhat.com>
 <alpine.DEB.2.02.1402141511200.13935@chino.kir.corp.google.com>
 <20140214225810.57e854cb@redhat.com>
 <alpine.DEB.2.02.1402150159540.28883@chino.kir.corp.google.com>
 <20140217085622.39b39cac@redhat.com>
 <alpine.DEB.2.02.1402171518080.25724@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402171518080.25724@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Feb 17, 2014 at 03:23:16PM -0800, David Rientjes wrote:
> On Mon, 17 Feb 2014, Luiz Capitulino wrote:
> 
> > hugepages= and hugepages_node= are similar, but have different semantics.
> > 
> > hugepagesz= and hugepages= create a pool of huge pages of the specified size.
> > This means that the number of times you specify those options are limited by
> > the number of different huge pages sizes an arch supports. For x86_64 for
> > example, this limit is two so one would not specify those options more than
> > two times. And this doesn't count default_hugepagesz=, which allows you to
> > drop one hugepagesz= option.
> > 
> > hugepages_node= allows you to allocate huge pages per node, so the number of
> > times you can specify this option is limited by the number of nodes. Also,
> > hugepages_node= create the pools, if necessary (at least one will be). For
> > this reason I think it makes a lot of sense to have different options.
> > 
> 
> I understand you may want to add as much code as you can to the boot code 
> so that you can parse all this information in short-form, and it's 
> understood that it's possible to specify a different number of varying 
> hugepage sizes on individual nodes, but let's come back down to reality 
> here.
> 
> Lacking from your entire patchset is a specific example of what you want 
> to do.  So I think we're all guessing what exactly your usecase is and we 
> aren't getting any help.  Are you really suggesting that a customer wants 
> to allocate 4 1GB hugepages on node 0, 12 2MB hugepages on node 0, 6 1GB 
> hugepages on node 1, 24 2MB hugepages on node 1, 2 1GB hugepages on node 
> 2, 100 2MB hugepages on node 3, etc?  Please.

Customer has 32GB machine. He wants 8 1GB pages for his performance
critical application on node0 (KVM guest), and other guests and
pagecache etc. using the remaining 26GB of memory.

> If that's actually the usecase then I'll renew my objection to the entire 
> patchset and say you want to add the ability to dynamically allocate 1GB 
> pages and free them at runtime early in initscripts.  If something is 
> going to be added to init code in the kernel then it better be trivial 
> since all this can be duplicated in userspace if you really want to be 
> fussy about it.

Not sure what is the point here. The command line interface addition
being proposed is simple, is it not?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
