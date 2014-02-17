Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3C2F66B003A
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 18:23:19 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id up15so15897311pbc.36
        for <linux-mm@kvack.org>; Mon, 17 Feb 2014 15:23:18 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id n8si16207119pax.247.2014.02.17.15.23.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 17 Feb 2014 15:23:18 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so15872400pab.17
        for <linux-mm@kvack.org>; Mon, 17 Feb 2014 15:23:18 -0800 (PST)
Date: Mon, 17 Feb 2014 15:23:16 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] hugetlb: add hugepages_node= command-line option
In-Reply-To: <20140217085622.39b39cac@redhat.com>
Message-ID: <alpine.DEB.2.02.1402171518080.25724@chino.kir.corp.google.com>
References: <1392339728-13487-1-git-send-email-lcapitulino@redhat.com> <1392339728-13487-5-git-send-email-lcapitulino@redhat.com> <alpine.DEB.2.02.1402141511200.13935@chino.kir.corp.google.com> <20140214225810.57e854cb@redhat.com>
 <alpine.DEB.2.02.1402150159540.28883@chino.kir.corp.google.com> <20140217085622.39b39cac@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mtosatti@redhat.com, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 17 Feb 2014, Luiz Capitulino wrote:

> hugepages= and hugepages_node= are similar, but have different semantics.
> 
> hugepagesz= and hugepages= create a pool of huge pages of the specified size.
> This means that the number of times you specify those options are limited by
> the number of different huge pages sizes an arch supports. For x86_64 for
> example, this limit is two so one would not specify those options more than
> two times. And this doesn't count default_hugepagesz=, which allows you to
> drop one hugepagesz= option.
> 
> hugepages_node= allows you to allocate huge pages per node, so the number of
> times you can specify this option is limited by the number of nodes. Also,
> hugepages_node= create the pools, if necessary (at least one will be). For
> this reason I think it makes a lot of sense to have different options.
> 

I understand you may want to add as much code as you can to the boot code 
so that you can parse all this information in short-form, and it's 
understood that it's possible to specify a different number of varying 
hugepage sizes on individual nodes, but let's come back down to reality 
here.

Lacking from your entire patchset is a specific example of what you want 
to do.  So I think we're all guessing what exactly your usecase is and we 
aren't getting any help.  Are you really suggesting that a customer wants 
to allocate 4 1GB hugepages on node 0, 12 2MB hugepages on node 0, 6 1GB 
hugepages on node 1, 24 2MB hugepages on node 1, 2 1GB hugepages on node 
2, 100 2MB hugepages on node 3, etc?  Please.

If that's actually the usecase then I'll renew my objection to the entire 
patchset and say you want to add the ability to dynamically allocate 1GB 
pages and free them at runtime early in initscripts.  If something is 
going to be added to init code in the kernel then it better be trivial 
since all this can be duplicated in userspace if you really want to be 
fussy about it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
