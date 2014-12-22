Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id A5D346B006E
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 17:21:38 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id hn15so4671582igb.1
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 14:21:38 -0800 (PST)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id q80si13442200ioe.0.2014.12.22.14.21.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 22 Dec 2014 14:21:37 -0800 (PST)
Received: by mail-ig0-f170.google.com with SMTP id r2so5957737igi.5
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 14:21:36 -0800 (PST)
Date: Mon, 22 Dec 2014 14:21:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] proc: task_mmu: show page size in
 /proc/<pid>/numa_maps
In-Reply-To: <54985C08.8080608@linux.intel.com>
Message-ID: <alpine.DEB.2.10.1412221420170.11431@chino.kir.corp.google.com>
References: <c97f30472ec5fe79cb8fa8be66cc3d8509777990.1419079617.git.aquini@redhat.com> <20141220183613.GA19229@phnom.home.cmpxchg.org> <20141220194457.GA3166@x61.redhat.com> <54970B49.3070104@linux.intel.com> <20141221222850.GA2038@x61.redhat.com>
 <5498508A.4080108@linux.intel.com> <20141222172459.GA11396@t510.redhat.com> <54985C08.8080608@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Rafael Aquini <aquini@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, oleg@redhat.com, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Mon, 22 Dec 2014, Dave Hansen wrote:

> > Remaining question here is: should we print out 'pagesize' deliberately 
> > or conditionally, only to disambiguate cases where page_size != PAGE_SIZE?
> 
> I say print it unconditionally.  Not to completely overdesign this, but
> I do think we should try to at least mirror the terminology that smaps uses:
> 
> 	KernelPageSize:        4 kB
> 	MMUPageSize:           4 kB
> 
> So definitely call this kernelpagesize.
> 

Feel free to add my acked-by if this patch prints it unconditionally and 
renames this to kernelpagesize per Dave.  I agree we need to leave "huge" 
for existing dependencies even though we have multiple possible hugepage 
sizes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
