Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f43.google.com (mail-bk0-f43.google.com [209.85.214.43])
	by kanga.kvack.org (Postfix) with ESMTP id E6E6B6B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 05:50:17 -0500 (EST)
Received: by mail-bk0-f43.google.com with SMTP id mx11so2747830bkb.30
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 02:50:17 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id qk2si3687058bkb.312.2014.01.27.02.50.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jan 2014 02:50:16 -0800 (PST)
Date: Mon, 27 Jan 2014 11:50:11 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch for-3.14] mm, mempolicy: fix mempolicy printing in
 numa_maps
Message-ID: <20140127105011.GB11314@laptop.programming.kicks-ass.net>
References: <alpine.DEB.2.02.1401251902180.3140@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401251902180.3140@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Jan 25, 2014 at 07:12:35PM -0800, David Rientjes wrote:
> As a result of commit 5606e3877ad8 ("mm: numa: Migrate on reference 
> policy"), /proc/<pid>/numa_maps prints the mempolicy for any <pid> as 
> "prefer:N" for the local node, N, of the process reading the file.
> 
> This should only be printed when the mempolicy of <pid> is MPOL_PREFERRED 
> for node N.
> 
> If the process is actually only using the default mempolicy for local node 
> allocation, make sure "default" is printed as expected.

Should we also consider printing the MOF and MORON states so we get a
better view of what the actual policy is?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
