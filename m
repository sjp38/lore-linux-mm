Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 686E16B0074
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 13:00:17 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <habanero@linux.vnet.ibm.com>;
	Wed, 21 Nov 2012 13:00:16 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 3417638C8065
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 12:59:34 -0500 (EST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qALHxLS451970262
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 12:59:22 -0500
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qALHxJDl017390
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 10:59:20 -0700
Subject: Re: numa/core regressions fixed - more testers wanted
From: Andrew Theurer <habanero@linux.vnet.ibm.com>
Reply-To: habanero@linux.vnet.ibm.com
In-Reply-To: <alpine.LNX.2.00.1211201947510.985@eggly.anvils>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
	 <20121119162909.GL8218@suse.de> <20121119191339.GA11701@gmail.com>
	 <20121119211804.GM8218@suse.de> <20121119223604.GA13470@gmail.com>
	 <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
	 <20121120071704.GA14199@gmail.com> <20121120152933.GA17996@gmail.com>
	 <20121120175647.GA23532@gmail.com>
	 <1353462853.31820.93.camel@oc6622382223.ibm.com>
	 <50AC4912.7040503@redhat.com>
	 <alpine.LNX.2.00.1211201947510.985@eggly.anvils>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 21 Nov 2012 11:59:16 -0600
Message-ID: <1353520756.31820.99.camel@oc6622382223.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, 2012-11-20 at 20:10 -0800, Hugh Dickins wrote:
> On Tue, 20 Nov 2012, Rik van Riel wrote:
> > On 11/20/2012 08:54 PM, Andrew Theurer wrote:
> > 
> > > I can confirm single JVM JBB is working well for me.  I see a 30%
> > > improvement over autoNUMA.  What I can't make sense of is some perf
> > > stats (taken at 80 warehouses on 4 x WST-EX, 512GB memory):
> > 
> > AutoNUMA does not have native THP migration, that may explain some
> > of the difference.
> 
> When I made some fixes to the sched/numa native THP migration,
> I did also try porting that (with Hannes's memcg fixes) to AutoNUMA.
> 
> Here's the patch below: it appeared to be working just fine, but
> you might find that it doesn't quite apply to whatever tree you're
> using.  I started from 3.6 autonuma28fast in aa.git, but had folded
> in some of the equally applicable TLB flush optimizations too.
> 
> There's also a little "Hack, remove after THP native migration"
> retuning in mm/huge_memory.c which should probably be removed too.

Thanks, this worked for me.  The autoNUMA SPECjbb result is now much
closer, just 4% lower than the numa/core result.  The number of anon and
anon-huge pages are now nearly the same.

-Andrew Theurer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
