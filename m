Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id A7E5E6B0069
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 12:37:10 -0400 (EDT)
Date: Mon, 16 Sep 2013 18:37:02 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 07/50] mm: Account for a THP NUMA hinting update as one
 PTE update
Message-ID: <20130916163702.GG9326@twins.programming.kicks-ass.net>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-8-git-send-email-mgorman@suse.de>
 <20130916123645.GD9326@twins.programming.kicks-ass.net>
 <52370A2F.90006@redhat.com>
 <20130916145438.GT21832@twins.programming.kicks-ass.net>
 <20130916161150.GF22421@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130916161150.GF22421@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Sep 16, 2013 at 05:11:50PM +0100, Mel Gorman wrote:
> > I never said the change didn't make sense as such. Just that we're no
> > longer counting pages in change_*_range().
> 
> well, it's still a THP page. Is it worth renaming?

Dunno, the pedant in me needed to raise the issue :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
