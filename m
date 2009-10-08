Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F0E4A6B004D
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 16:17:32 -0400 (EDT)
Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id n98KHQrT020272
	for <linux-mm@kvack.org>; Thu, 8 Oct 2009 21:17:27 +0100
Received: from pzk11 (pzk11.prod.google.com [10.243.19.139])
	by spaceape23.eur.corp.google.com with ESMTP id n98KGnMS017172
	for <linux-mm@kvack.org>; Thu, 8 Oct 2009 13:17:23 -0700
Received: by pzk11 with SMTP id 11so4553632pzk.14
        for <linux-mm@kvack.org>; Thu, 08 Oct 2009 13:17:23 -0700 (PDT)
Date: Thu, 8 Oct 2009 13:17:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/12] nodemask:  make NODEMASK_ALLOC more general
In-Reply-To: <20091008162501.23192.66287.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.1.00.0910081315150.6998@chino.kir.corp.google.com>
References: <20091008162454.23192.91832.sendpatchset@localhost.localdomain> <20091008162501.23192.66287.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Andi Kleen <andi@firstfloor.org>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 8 Oct 2009, Lee Schermerhorn wrote:

> From: David Rientjes <rientjes@google.com>
> 
> [PATCH 1/12] nodemask:  make NODEMASK_ALLOC more general
> 
> NODEMASK_ALLOC(x, m) assumes x is a type of struct, which is unnecessary.
> It's perfectly reasonable to use this macro to allocate a nodemask_t,
> which is anonymous, either dynamically or on the stack depending on
> NODES_SHIFT.
> 

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>

The former is from http://marc.info/?l=linux-mm&m=125453157828809

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
