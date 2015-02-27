Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id D2E016B006E
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 17:31:47 -0500 (EST)
Received: by igal13 with SMTP id l13so4262973iga.5
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 14:31:47 -0800 (PST)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com. [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id d6si2780737igz.60.2015.02.27.14.31.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Feb 2015 14:31:47 -0800 (PST)
Received: by iecrl12 with SMTP id rl12so34680068iec.2
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 14:31:47 -0800 (PST)
Date: Fri, 27 Feb 2015 14:31:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm: remove GFP_THISNODE
In-Reply-To: <54F0ED7E.6010900@suse.cz>
Message-ID: <alpine.DEB.2.10.1502271428320.7225@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <54EED9A7.5010505@suse.cz> <alpine.DEB.2.10.1502261902580.24302@chino.kir.corp.google.com> <54F01E02.1090007@suse.cz> <alpine.DEB.2.10.1502271335520.4718@chino.kir.corp.google.com>
 <54F0ED7E.6010900@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>, Jarno Rajahalme <jrajahalme@nicira.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, dev@openvswitch.org

On Fri, 27 Feb 2015, Vlastimil Babka wrote:

> > Do you see any issues with either patch 1/2 or patch 2/2 besides the 
> > s/GFP_TRANSHUGE/GFP_THISNODE/ that is necessary on the changelog?
> 
> Well, my point is, what if the node we are explicitly trying to allocate
> hugepage on, is in fact not allowed by our cpuset? This could happen in the page
> fault case, no? Although in a weird configuration when process can (and really
> gets scheduled to run) on a node where it is not allowed to allocate from...
> 

If the process is running a node that is not allowed by the cpuset, then 
alloc_hugepage_vma() now fails with VM_FAULT_FALLBACK.  That was the 
intended policy change of commit 077fcf116c8c ("mm/thp: allocate 
transparent hugepages on local node").

 [ alloc_hugepage_vma() should probably be using numa_mem_id() instead for 
   memoryless node platforms. ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
