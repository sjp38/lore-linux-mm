Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 795386B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 16:10:50 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p44KAU6Y032062
	for <linux-mm@kvack.org>; Wed, 4 May 2011 13:10:30 -0700
Received: from pxi9 (pxi9.prod.google.com [10.243.27.9])
	by hpaq3.eem.corp.google.com with ESMTP id p44K9MEF001250
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 4 May 2011 13:10:23 -0700
Received: by pxi9 with SMTP id 9so1520895pxi.28
        for <linux-mm@kvack.org>; Wed, 04 May 2011 13:10:23 -0700 (PDT)
Date: Wed, 4 May 2011 13:10:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Allocate memory cgroup structures in local nodes
In-Reply-To: <4DC1B151.7010300@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1105041309001.24395@chino.kir.corp.google.com>
References: <1304533058-18228-1-git-send-email-andi@firstfloor.org> <alpine.DEB.2.00.1105041213310.22426@chino.kir.corp.google.com> <4DC1B151.7010300@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Balbir Singh <balbir@in.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, 4 May 2011, Andi Kleen wrote:

> >  The vmalloc_node() calls ensure that the nid is actually set in
> > N_HIGH_MEMORY and fails otherwise (we don't fallback to using vmalloc()),
> > so it looks like the failures for alloc_pages_exact_node() and
> > vmalloc_node() would be different?  Why do we want to fallback for one and
> > not the other?
> 
> The right order would be to try everything (alloc_pages + vmalloc)
> to get it node local, before trying everything else. Right now that's
> not how it's done.
> 

Completely agreed, I think that's how it should be patched instead of only 
touching the alloc_pages() allocation; we care much more about local node 
than whether we're using vmalloc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
