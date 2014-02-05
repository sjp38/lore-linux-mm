Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 731466B0037
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 19:14:10 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id z10so8865995pdj.19
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 16:14:10 -0800 (PST)
Received: from mail-pb0-x230.google.com (mail-pb0-x230.google.com [2607:f8b0:400e:c01::230])
        by mx.google.com with ESMTPS id va10si26554917pbc.338.2014.02.04.16.14.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 16:14:09 -0800 (PST)
Received: by mail-pb0-f48.google.com with SMTP id rr13so9189551pbb.35
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 16:14:09 -0800 (PST)
Date: Tue, 4 Feb 2014 16:14:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, page_alloc: make first_page visible before
 PageTail
In-Reply-To: <20140204160641.8f5d369eeb2d0318618d6d5f@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1402041613450.14962@chino.kir.corp.google.com>
References: <alpine.LRH.2.02.1401312037340.6630@diagnostix.dwd.de> <20140203122052.GC2495@dhcp22.suse.cz> <alpine.LRH.2.02.1402031426510.13382@diagnostix.dwd.de> <20140203162036.GJ2495@dhcp22.suse.cz> <52EFC93D.3030106@suse.cz>
 <alpine.DEB.2.02.1402031602060.10778@chino.kir.corp.google.com> <alpine.LRH.2.02.1402040713220.13901@diagnostix.dwd.de> <alpine.DEB.2.02.1402041557380.10140@chino.kir.corp.google.com> <20140204160641.8f5d369eeb2d0318618d6d5f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Holger Kiehl <Holger.Kiehl@dwd.de>, Christoph Lameter <cl@linux.com>, Rafael Aquini <aquini@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 4 Feb 2014, Andrew Morton wrote:

> > Commit bf6bddf1924e ("mm: introduce compaction and migration for ballooned 
> > pages") introduces page_count(page) into memory compaction which 
> > dereferences page->first_page if PageTail(page).
> > 
> > Introduce a store memory barrier to ensure page->first_page is properly 
> > initialized so that code that does page_count(page) on pages off the lru 
> > always have a valid p->first_page.
> 
> Could we have a code comment please?  Even checkpatch knows this rule!
> 

Ok.

> > Reported-by: Holger Kiehl <Holger.Kiehl@dwd.de>
> 
> What did Holger report?
> 

A once-in-five-years NULL pointer dereference on the aforementioned 
page_count(page).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
