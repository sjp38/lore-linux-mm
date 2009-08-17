Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6B0406B004D
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 06:07:59 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id n7HA7tIS027784
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 11:07:56 +0100
Received: from pzk9 (pzk9.prod.google.com [10.243.19.137])
	by wpaz24.hot.corp.google.com with ESMTP id n7HA7qw4003498
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 03:07:53 -0700
Received: by pzk9 with SMTP id 9so1952019pzk.21
        for <linux-mm@kvack.org>; Mon, 17 Aug 2009 03:07:52 -0700 (PDT)
Date: Mon, 17 Aug 2009 03:07:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] hugetlb: add per node hstate attributes
In-Reply-To: <1250471441.4472.108.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.DEB.2.00.0908170259590.6824@chino.kir.corp.google.com>
References: <20090729181139.23716.85986.sendpatchset@localhost.localdomain> <20090729181205.23716.25002.sendpatchset@localhost.localdomain> <9ec263480907301239i4f6a6973m494f4b44770660dc@mail.gmail.com> <20090731103632.GB28766@csn.ul.ie>
 <1249067452.4674.235.camel@useless.americas.hpqcorp.net> <alpine.DEB.2.00.0908141532510.23204@chino.kir.corp.google.com> <20090814160830.e301d68a.akpm@linux-foundation.org> <alpine.DEB.2.00.0908141649500.26836@chino.kir.corp.google.com>
 <1250471441.4472.108.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>, nacc@us.ibm.com, Andi Kleen <andi@firstfloor.org>, agl@us.ibm.com, apw@canonical.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Sun, 16 Aug 2009, Lee Schermerhorn wrote:

> Yes.  I had planned to ping you and Mel, as I hadn't heard back from you
> about the combined interfaces.  I think they mesh fairly well, and the
> per node attributes have the, perhaps desirable, property of ignoring
> any current task mempolicy.  But, I know that some folks don't like a
> proliferation of ways to do something.

I agree as a matter of general principle, but I don't think this would be 
a good example of it.

I'm struggling to understand exactly how clean the mempolicy-based 
approach would be if an application such as a job scheduler wanted to free 
hugepages only on specific nodes.  Presumably this would require the 
application to create a MPOL_BIND mempolicy to those nodes and write to 
/proc/sys/vm/nr_hugepages, but that may break existing implementations if 
there are no hugepages allocated on the mempolicy's nodes.

> I'll package up the series [I
> need to update the Documentation for the per node attributes] and send
> it out as soon as I can get to it.  This week, I'm pretty sure.
> 

That's good news, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
