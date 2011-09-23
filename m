Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1CBDB9000BD
	for <linux-mm@kvack.org>; Fri, 23 Sep 2011 16:04:24 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p8NK4LAK025587
	for <linux-mm@kvack.org>; Fri, 23 Sep 2011 13:04:21 -0700
Received: from gwm11 (gwm11.prod.google.com [10.200.13.11])
	by hpaq5.eem.corp.google.com with ESMTP id p8NK2v5t019591
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 23 Sep 2011 13:04:19 -0700
Received: by gwm11 with SMTP id 11so3019328gwm.16
        for <linux-mm@kvack.org>; Fri, 23 Sep 2011 13:04:14 -0700 (PDT)
Date: Fri, 23 Sep 2011 13:04:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH] show page size in /proc/$pid/numa_maps
In-Reply-To: <1316793268.16137.481.camel@nimitz>
Message-ID: <alpine.DEB.2.00.1109231256540.11347@chino.kir.corp.google.com>
References: <20110921221329.5B7EE5C5@kernel> <alpine.DEB.2.00.1109221339520.31548@chino.kir.corp.google.com> <1316793268.16137.481.camel@nimitz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 23 Sep 2011, Dave Hansen wrote:

> > Why not just add a pagesize={4K,2M,1G,...} field for every output? 
> 
> I think it's a bit misleading.  With THP at least we have 2M pages in
> the MMU, but we're reporting in 4k units.
> 
> I certainly considered doing just what you're suggesting, though.  It's
> definitely not a bad idea.  Certainly much more clear.
> 

Een though the code is in task_mmu.c, I think that /proc/pid/numa_maps 
should be more representative of the state of vmas where any 
pagesize={4K,2M,1G,...} would be true rather than whether or not the mmu 
sees tham as large or small pages.  I actually don't see much difference 
between anon=50 pagemult=512 and anon=50 pagesize=2M, but I'd definitely 
recommend printing the field for every vma.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
