Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 4F5376B0044
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 04:38:07 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so4850623eek.14
        for <linux-mm@kvack.org>; Wed, 21 Nov 2012 01:38:05 -0800 (PST)
Date: Wed, 21 Nov 2012 10:38:00 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: numa/core regressions fixed - more testers wanted
Message-ID: <20121121093800.GA26148@gmail.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de>
 <20121119191339.GA11701@gmail.com>
 <20121119211804.GM8218@suse.de>
 <20121119223604.GA13470@gmail.com>
 <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
 <20121120071704.GA14199@gmail.com>
 <20121120152933.GA17996@gmail.com>
 <20121120175647.GA23532@gmail.com>
 <alpine.DEB.2.00.1211201913410.6458@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211201913410.6458@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


* David Rientjes <rientjes@google.com> wrote:

> I started profiling on a new machine that is an exact 
> duplicate of the 16-way, 4 node, 32GB machine I was profiling 
> with earlier to rule out any machine-specific problems.  I 
> pulled master and ran new comparisons with THP enabled at 
> c418de93e398 ("Merge branch 'x86/mm'"):
> 
>   CONFIG_NUMA_BALANCING disabled	136521.55 SPECjbb2005 bops
>   CONFIG_NUMA_BALANCING enabled		132476.07 SPECjbb2005 bops (-3.0%)
> 
> Aside: neither 4739578c3ab3 ("x86/mm: Don't flush the TLB on 
> #WP pmd fixups") nor 01e9c2441eee ("x86/vsyscall: Add Kconfig 
> option to use native vsyscalls and switch to it") 
> significantly improved upon the throughput on this system.

Could you please send an updated profile done with latest -tip? 
The last profile I got from you still had the vsyscall emulation 
page faults in it.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
