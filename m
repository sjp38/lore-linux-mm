Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 8DE7A6B0074
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 02:48:56 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so4049126eek.14
        for <linux-mm@kvack.org>; Mon, 19 Nov 2012 23:48:55 -0800 (PST)
Date: Tue, 20 Nov 2012 08:48:50 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
Message-ID: <20121120074850.GA14566@gmail.com>
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

> This is in comparison to my earlier perftop results which were with thp 
> enabled.  Keep in mind that this system has a NUMA configuration of
> 
> $ cat /sys/devices/system/node/node*/distance 
> 10 20 20 30
> 20 10 20 20
> 20 20 10 20
> 30 20 20 10

You could check whether the basic topology is scheduled right by 
running Andrea's autonumabench:

  git://gitorious.org/autonuma-benchmark/autonuma-benchmark.git

and do a "start.sh -A" and send the mainline versus numa/core 
results.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
