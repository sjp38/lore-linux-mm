Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id B39676B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 15:39:59 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id n7so13877261qcx.2
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 12:39:59 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id a3si13369942qam.186.2014.02.11.12.39.57
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 12:39:57 -0800 (PST)
Date: Tue, 11 Feb 2014 18:15:57 -0200
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH 0/4] hugetlb: add hugepagesnid= command-line option
Message-ID: <20140211201557.GA16281@amt.cnet>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
 <alpine.DEB.2.02.1402101851190.3447@chino.kir.corp.google.com>
 <20140211092514.GH6732@suse.de>
 <20140211152629.GA28210@amt.cnet>
 <20140211171035.GN6732@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140211171035.GN6732@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>

On Tue, Feb 11, 2014 at 05:10:35PM +0000, Mel Gorman wrote:
> On Tue, Feb 11, 2014 at 01:26:29PM -0200, Marcelo Tosatti wrote:
> > > Or take a stab at allocating 1G pages at runtime. It would require
> > > finding properly aligned 1Gs worth of contiguous MAX_ORDER_NR_PAGES at
> > > runtime. I would expect it would only work very early in the lifetime of
> > > the system but if the user is willing to use kernel parameters to
> > > allocate them then it should not be an issue.
> > 
> > Can be an improvement on top of the current patchset? Certain use-cases
> > require allocation guarantees (even if that requires kernel parameters).
> > 
> 
> Sure, they're not mutually exclusive. It would just avoid the need to
> create a new kernel parameter and use the existing interfaces.

Yes, the problem is there is no guarantee is there?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
