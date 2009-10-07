Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AD8686B005A
	for <linux-mm@kvack.org>; Wed,  7 Oct 2009 15:53:49 -0400 (EDT)
Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id n97JrWXC025410
	for <linux-mm@kvack.org>; Wed, 7 Oct 2009 12:53:32 -0700
Received: from pzk26 (pzk26.prod.google.com [10.243.19.154])
	by zps18.corp.google.com with ESMTP id n97JrTgR026426
	for <linux-mm@kvack.org>; Wed, 7 Oct 2009 12:53:30 -0700
Received: by pzk26 with SMTP id 26so4747729pzk.4
        for <linux-mm@kvack.org>; Wed, 07 Oct 2009 12:53:29 -0700 (PDT)
Date: Wed, 7 Oct 2009 12:53:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: clear node in N_HIGH_MEMORY and stop kswapd when
 all memory is offlined
In-Reply-To: <1254934087.4483.227.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.DEB.1.00.0910071251080.1928@chino.kir.corp.google.com>
References: <20091006031739.22576.5248.sendpatchset@localhost.localdomain> <20091006031924.22576.35018.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0910070043140.16136@chino.kir.corp.google.com>
 <1254934087.4483.227.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, Christoph Lameter <cl@linux-foundation.org>, eric.whitney@hp.com, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Oct 2009, Lee Schermerhorn wrote:

> What shall we do with this for the huge pages controls series?  
> 
> Options:
> 
> 1) leave series as is, and note that it depends on this patch?
> 
> 2) Include this patch [or the subset that clears the N_HIGH_MEMORY node
> state--maybe leave the kswapd handling separate?] in the series?
> 

Probably do the same thing as my "nodemask: make NODEMASK_ALLOC more 
general" patch: add it to your series as a predecessor to v9's patch 11 in 
v10 with

	From: David Rientjes <rientjes@google.com>

as the very first line and pick up my sign-off.  Please cc the same people 
that I did on this patch and add a couple more for the kswapd review that 
Christoph requested:

	Cc: Rafael J. Wysocki <rjw@sisk.pl>
	Cc: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
