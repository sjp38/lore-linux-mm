Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D2BFA6B0062
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 14:03:11 -0500 (EST)
Message-ID: <498893EE.9060107@cs.helsinki.fi>
Date: Tue, 03 Feb 2009 20:58:54 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch] SLQB slab allocator (try 2)
References: <20090123154653.GA14517@wotan.suse.de> <1232959706.21504.7.camel@penberg-laptop> <20090203101205.GF9840@csn.ul.ie>
In-Reply-To: <20090203101205.GF9840@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Mel,

Mel Gorman wrote:
> The OLTP workload results could indicate a downside with using sysbench
> although it could also be hardware. The reports from the Intel guys have been
> pretty clear-cut that SLUB is a loser but sysbench-postgres on these test
> machines at least do not agree. Of course their results are perfectly valid
> but the discrepency needs to be explained or there will be a disconnect
> between developers and the performance people.  Something important is
> missing that means sysbench-postgres *may* not be a reliable indicator of
> TPC-C performance.  It could easily be down to the hardware as their tests
> are on a mega-large machine with oodles of disks and probably NUMA where
> the test machine used for this is a lot less respectable.

Yup. That's more or less what I've been saying for a long time now. The 
OLTP regression is not all obvious and while there has been plenty of 
talk about it (cache line ping-pong due to lack of queues, high order 
pages), I've yet to see a detailed analysis on it.

It would be interesting to know what drivers the Intel setup uses. One 
thing I speculated with Christoph at OLS is that the regression could be 
due to bad interaction with the SCSI subsystem, for example. That would 
explain why the regression doesn't show up in typical setups which have ATA.

Anyway, even if we did end up going forward with SLQB, it would sure as 
hell be less painful if we understood the reasons behind it.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
