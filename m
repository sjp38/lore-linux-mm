Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 19DC56B005D
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 12:57:00 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so3017764bkc.14
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 09:56:58 -0800 (PST)
Date: Tue, 20 Nov 2012 18:56:47 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: numa/core regressions fixed - more testers wanted
Message-ID: <20121120175647.GA23532@gmail.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de>
 <20121119191339.GA11701@gmail.com>
 <20121119211804.GM8218@suse.de>
 <20121119223604.GA13470@gmail.com>
 <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
 <20121120071704.GA14199@gmail.com>
 <20121120152933.GA17996@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121120152933.GA17996@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


* Ingo Molnar <mingo@kernel.org> wrote:

> ( The 4x JVM regression is still an open bug I think - I'll
>   re-check and fix that one next, no need to re-report it,
>   I'm on it. )

So I tested this on !THP too and the combined numbers are now:

                                          |
  [ SPECjbb multi-4x8 ]                   |
  [ tx/sec            ]  v3.7             |  numa/core-v16
  [ higher is better  ] -----             |  -------------
                                          |
              +THP:      639k             |       655k            +2.5%
              -THP:      510k             |       517k            +1.3%

So it's not a regression anymore, regardless of whether THP is 
enabled or disabled.

The current updated table of performance results is:

-------------------------------------------------------------------------
  [ seconds         ]    v3.7  AutoNUMA   |  numa/core-v16    [ vs. v3.7]
  [ lower is better ]   -----  --------   |  -------------    -----------
                                          |
  numa01                340.3    192.3    |      139.4          +144.1%
  numa01_THREAD_ALLOC   425.1    135.1    |	 121.1          +251.0%
  numa02                 56.1     25.3    |       17.5          +220.5%
                                          |
  [ SPECjbb transactions/sec ]            |
  [ higher is better         ]            |
                                          |
  SPECjbb 1x32 +THP      524k     507k    |	  638k           +21.7%
  SPECjbb 1x32 !THP      395k             |       512k           +29.6%
                                          |
-----------------------------------------------------------------------
                                          |
  [ SPECjbb multi-4x8 ]                   |
  [ tx/sec            ]  v3.7             |  numa/core-v16
  [ higher is better  ] -----             |  -------------
                                          |
              +THP:      639k             |       655k            +2.5%
              -THP:      510k             |       517k            +1.3%

So I think I've addressed all regressions reported so far - if 
anyone can still see something odd, please let me know so I can 
reproduce and fix it ASAP.

Next I'll work on making multi-JVM more of an improvement, and 
I'll also address any incoming regression reports.

Those of you who would like to test all the latest patches are 
welcome to pick up latest bits at tip:master:

   git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git master

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
