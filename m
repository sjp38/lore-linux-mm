Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 1CBA66B006C
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 17:36:11 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so1729260eaa.14
        for <linux-mm@kvack.org>; Mon, 19 Nov 2012 14:36:09 -0800 (PST)
Date: Mon, 19 Nov 2012 23:36:04 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
Message-ID: <20121119223604.GA13470@gmail.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de>
 <20121119191339.GA11701@gmail.com>
 <20121119211804.GM8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121119211804.GM8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


* Mel Gorman <mgorman@suse.de> wrote:

> Ok.
> 
> In response to one of your later questions, I found that I had 
> in fact disabled THP without properly reporting it. [...]

Hugepages is a must for most forms of NUMA/HPC. This alone 
questions the relevance of most of your prior numa/core testing 
results. I now have to strongly dispute your other conclusions 
as well.

Just a look at 'perf top' output should have told you the story.

Yet time and time again you readily reported bad 'schednuma' 
results for a slow 4K memory model that neither we nor other 
NUMA testers I talked to actually used, without stopping to look 
why that was so...

[ I suspect that if such terabytes-of-data workloads are forced 
  through such a slow 4K pages model then there's a bug or 
  mis-tuning in our code that explains the level of additional 
  slowdown you saw - we'll fix that.

  But you should know that behavior under the slow 4K model 
  tells very little about the true scheduling and placement 
  quality of the patches... ]

Please report proper THP-enabled numbers before continuing.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
