Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 730336B0081
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 03:01:19 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so4055835eek.14
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 00:01:17 -0800 (PST)
Date: Tue, 20 Nov 2012 09:01:10 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
Message-ID: <20121120080110.GA14785@gmail.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de>
 <20121119191339.GA11701@gmail.com>
 <20121119211804.GM8218@suse.de>
 <20121119223604.GA13470@gmail.com>
 <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
 <20121120071704.GA14199@gmail.com>
 <alpine.DEB.2.00.1211192329090.14460@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211192329090.14460@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


* David Rientjes <rientjes@google.com> wrote:

> I confirm that numa/core regresses significantly more without 
> thp than the 6.3% regression I reported with thp in terms of 
> throughput on the same system.  numa/core at 01aa90068b12 
> ("sched: Use the best-buddy 'ideal cpu' in balancing 
> decisions") had 99389.49 SPECjbb2005 bops whereas ec05a2311c35 
> ("Merge branch 'sched/urgent' into sched/core") had 122246.90 
> SPECjbb2005 bops, a 23.0% regression.

What is the base performance figure with THP disabled? Your 
baseline was:

   sched/core at ec05a2311c35:    136918.34 SPECjbb2005 

Would be interesting to see how that kernel reacts to THP off.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
