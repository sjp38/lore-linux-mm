Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 0D5C36B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 05:19:10 -0400 (EDT)
Date: Wed, 31 Jul 2013 10:19:07 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 15/18] fix compilation with !CONFIG_NUMA_BALANCING
Message-ID: <20130731091907.GL2296@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-16-git-send-email-mgorman@suse.de>
 <20130717215353.57333a69@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130717215353.57333a69@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 17, 2013 at 09:53:53PM -0400, Rik van Riel wrote:
> On Mon, 15 Jul 2013 16:20:17 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > Ideally it would be possible to distinguish between NUMA hinting faults that
> > are private to a task and those that are shared. If treated identically
> > there is a risk that shared pages bounce between nodes depending on
> 
> Your patch 15 breaks the compile with !CONFIG_NUMA_BALANCING.
> 
> This little patch fixes it:
> 

Sloppy of me. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
