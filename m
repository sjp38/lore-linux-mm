Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id CFBE16B0070
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 03:11:09 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so4317815pad.14
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 00:11:09 -0800 (PST)
Date: Tue, 20 Nov 2012 00:11:06 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
In-Reply-To: <20121120080110.GA14785@gmail.com>
Message-ID: <alpine.DEB.2.00.1211200007360.16449@chino.kir.corp.google.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org> <20121119162909.GL8218@suse.de> <20121119191339.GA11701@gmail.com> <20121119211804.GM8218@suse.de> <20121119223604.GA13470@gmail.com> <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
 <20121120071704.GA14199@gmail.com> <alpine.DEB.2.00.1211192329090.14460@chino.kir.corp.google.com> <20121120080110.GA14785@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Tue, 20 Nov 2012, Ingo Molnar wrote:

> > I confirm that numa/core regresses significantly more without 
> > thp than the 6.3% regression I reported with thp in terms of 
> > throughput on the same system.  numa/core at 01aa90068b12 
> > ("sched: Use the best-buddy 'ideal cpu' in balancing 
> > decisions") had 99389.49 SPECjbb2005 bops whereas ec05a2311c35 
> > ("Merge branch 'sched/urgent' into sched/core") had 122246.90 
> > SPECjbb2005 bops, a 23.0% regression.
> 
> What is the base performance figure with THP disabled? Your 
> baseline was:
> 
>    sched/core at ec05a2311c35:    136918.34 SPECjbb2005 
> 
> Would be interesting to see how that kernel reacts to THP off.
> 

In summary, the benchmarks that I've collected thus far are:

THP enabled:

   numa/core at ec05a2311c35:	136918.34 SPECjbb2005 bops
   numa/core at 01aa90068b12:	128315.19 SPECjbb2005 bops (-6.3%)

THP disabled:

   numa/core at ec05a2311c35:	122246.90 SPECjbb2005 bops
   numa/core at 01aa90068b12:	 99389.49 SPECjbb2005 bops (-23.0%)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
