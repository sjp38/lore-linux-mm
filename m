Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1A86B005C
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 17:04:01 -0400 (EDT)
Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id n83L3wrX003137
	for <linux-mm@kvack.org>; Thu, 3 Sep 2009 14:03:58 -0700
Received: from pxi7 (pxi7.prod.google.com [10.243.27.7])
	by zps78.corp.google.com with ESMTP id n83L3soI021041
	for <linux-mm@kvack.org>; Thu, 3 Sep 2009 14:03:56 -0700
Received: by pxi7 with SMTP id 7so186516pxi.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2009 14:03:56 -0700 (PDT)
Date: Thu, 3 Sep 2009 14:03:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/6] hugetlb:  introduce alloc_nodemask_of_node
In-Reply-To: <1252010988.6029.194.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.DEB.1.00.0909031402340.30662@chino.kir.corp.google.com>
References: <20090828160314.11080.18541.sendpatchset@localhost.localdomain> <20090828160338.11080.51282.sendpatchset@localhost.localdomain> <20090901144932.GB7548@csn.ul.ie> <1251823334.4164.2.camel@useless.americas.hpqcorp.net>
 <alpine.DEB.1.00.0909031122590.9055@chino.kir.corp.google.com> <1252010988.6029.194.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 3 Sep 2009, Lee Schermerhorn wrote:

> > I've seen the issue about the signed-off-by/reviewed-by/acked-by order 
> > come up before.  I've always put my signed-off-by line last whenever 
> > proposing patches because it shows a clear order in who gathered those 
> > lines when submitting to -mm, for example.  If I write
> > 
> > 	Cc: Mel Gorman <mel@csn.ul.ie>
> > 	Signed-off-by: David Rientjes <rientjes@google.com>
> > 
> > it is clear that I cc'd Mel on the initial proposal.  If it is the other 
> > way around, for example,
> > 
> > 	Signed-off-by: David Rientjes <rientjes@google.com>
> > 	Cc: Mel Gorman <mel@csn.ul.ie>
> > 	Signed-off-by: Andrew Morton...
> > 
> > then it indicates Andrew added the cc when merging into -mm.  That's more 
> > relevant when such a line is acked-by or reviewed-by since it is now 
> > possible to determine who received such acknowledgement from the 
> > individual and is responsible for correctly relaying it in the patch 
> > submission.
> > 
> > If it's done this way, it indicates that whoever is signing off the patch 
> > is responsible for everything above it.  The type of line (signed-off-by, 
> > reviewed-by, acked-by) is enough of an indication about the development 
> > history of the patch, I believe, and it doesn't require specific ordering 
> > to communicate (and the first line having to be a signed-off-by line isn't 
> > really important, it doesn't replace the From: line).
> > 
> > It also appears to be how both Linus merges his own patches with Cc's.
> 
> ???
> 

Not sure what's confusing about this, sorry.  You order your 
acked-by/reviewed-by/signed-off-by lines just like I have for years and I 
don't think it needs to be changed.  It shows a clear history of who did 
what in the path from original developer -> maintainer -> Linus.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
