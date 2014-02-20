Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6166B004D
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 23:51:59 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id up15so1382007pbc.22
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 20:51:59 -0800 (PST)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id po10si1889820pab.15.2014.02.19.20.51.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 20:51:57 -0800 (PST)
Received: by mail-pd0-f177.google.com with SMTP id x10so1311451pdj.36
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 20:51:57 -0800 (PST)
Date: Wed, 19 Feb 2014 20:51:55 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
In-Reply-To: <20140219234232.07dc1eab@redhat.com>
Message-ID: <alpine.DEB.2.02.1402192048240.2568@chino.kir.corp.google.com>
References: <1392339728-13487-1-git-send-email-lcapitulino@redhat.com> <1392339728-13487-5-git-send-email-lcapitulino@redhat.com> <alpine.DEB.2.02.1402141511200.13935@chino.kir.corp.google.com> <20140214225810.57e854cb@redhat.com>
 <alpine.DEB.2.02.1402150159540.28883@chino.kir.corp.google.com> <20140217085622.39b39cac@redhat.com> <alpine.DEB.2.02.1402171518080.25724@chino.kir.corp.google.com> <20140218123013.GA20609@amt.cnet> <alpine.DEB.2.02.1402181407510.20772@chino.kir.corp.google.com>
 <20140220022254.GA25898@amt.cnet> <alpine.DEB.2.02.1402191941330.29913@chino.kir.corp.google.com> <20140219234232.07dc1eab@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 19 Feb 2014, Luiz Capitulino wrote:

> > Yes, my concrete objection is that the command line interface is 
> > unnecessary if you can dynamically allocate and free 1GB pages at runtime 
> > unless memory will be so fragmented that it cannot be done when userspace 
> > is brought up.  That is not your use case, thus this support is not 
> 
> Yes it is. The early boot is the most reliable moment to allocate huge pages
> and we want to take advantage from that.
> 

Your use case is 8GB of hugepages on a 32GB machine.  It shouldn't be 
necessary to do that at boot.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
