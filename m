Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3D46B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 08:09:19 -0500 (EST)
Received: by mail-we0-f173.google.com with SMTP id t60so5168660wes.18
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 05:09:18 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ux10si5305427wjc.81.2014.01.27.05.09.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Jan 2014 05:09:18 -0800 (PST)
Date: Mon, 27 Jan 2014 13:09:15 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch for-3.14] mm, mempolicy: fix mempolicy printing in
 numa_maps
Message-ID: <20140127130914.GI4963@suse.de>
References: <alpine.DEB.2.02.1401251902180.3140@chino.kir.corp.google.com>
 <20140127105011.GB11314@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140127105011.GB11314@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jan 27, 2014 at 11:50:11AM +0100, Peter Zijlstra wrote:
> On Sat, Jan 25, 2014 at 07:12:35PM -0800, David Rientjes wrote:
> > As a result of commit 5606e3877ad8 ("mm: numa: Migrate on reference 
> > policy"), /proc/<pid>/numa_maps prints the mempolicy for any <pid> as 
> > "prefer:N" for the local node, N, of the process reading the file.
> > 
> > This should only be printed when the mempolicy of <pid> is MPOL_PREFERRED 
> > for node N.
> > 
> > If the process is actually only using the default mempolicy for local node 
> > allocation, make sure "default" is printed as expected.
> 
> Should we also consider printing the MOF and MORON states so we get a
> better view of what the actual policy is?
> 

MOF and MORON are separate issues because MOF is exposed to the userspace
API but not the policies that make up MORON. For MORON, I concluded that
we should not expose that via numa_maps unless it can be controlled from
userspace.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
