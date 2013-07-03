Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 78D176B0037
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 12:19:19 -0400 (EDT)
Date: Wed, 3 Jul 2013 17:19:15 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/13] Basic scheduler support for automatic NUMA
 balancing V2
Message-ID: <20130703161915.GJ1875@suse.de>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1372861300-9973-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 03, 2013 at 03:21:27PM +0100, Mel Gorman wrote:
> o 3.9.0-vanilla		vanilla kernel with automatic numa balancing enabled
> o 3.9.0-morefaults	Patches 1-9
> o 3.9.0-scalescan	Patches 1-10
> o 3.9.0-scanshared	Patches 1-12
> o 3.9.0-accountpreferred Patches 1-13
> 

I screwed up the testing as 3.9.0-morefaults is not patches 1-9 at all and
I only noticed when examining an anomaly. It's a unreleased series that
I screwed up the patch generation for. The conclusions about patches 1-9
are invalid. I'll redo the testing.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
