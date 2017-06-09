Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7BBFC6B0279
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 18:35:29 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id f185so30632354pgc.10
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 15:35:29 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g3sor1267395pfb.22.2017.06.09.15.35.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Jun 2017 15:35:28 -0700 (PDT)
Date: Fri, 9 Jun 2017 15:35:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] mm, hugetlb: schedule when potentially allocating
 many hugepages
In-Reply-To: <52ee0233-c3cd-d33a-a33b-50d49e050d5c@oracle.com>
Message-ID: <alpine.DEB.2.10.1706091534580.66176@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1706072102560.29060@chino.kir.corp.google.com> <52ee0233-c3cd-d33a-a33b-50d49e050d5c@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 7 Jun 2017, Mike Kravetz wrote:

> > @@ -2364,6 +2366,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
> >  			ret = alloc_fresh_gigantic_page(h, nodes_allowed);
> >  		else
> >  			ret = alloc_fresh_huge_page(h, nodes_allowed);
> > +		cond_resched();
> 
> Are not the following lines immediately before the above huge page allocation
> in set_max_huge_pages, or am I looking at an incorrect version of the file?
> 
> 		/* yield cpu to avoid soft lockup */
> 		cond_resched();

Ahh, we don't have this in our tree, thanks for catching it.  The other 
two cond_resched()'s are needed because we have reproduced them, so I'll 
send a v2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
