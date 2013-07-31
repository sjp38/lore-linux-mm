Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id B76106B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 05:13:34 -0400 (EDT)
Date: Wed, 31 Jul 2013 10:13:30 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 13/18] mm: numa: Scan pages with elevated page_mapcount
Message-ID: <20130731091330.GK2296@suse.de>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-14-git-send-email-mgorman@suse.de>
 <51E62A0E.1070102@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <51E62A0E.1070102@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Ben <sam.bennn@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 17, 2013 at 01:22:22PM +0800, Sam Ben wrote:
> On 07/15/2013 11:20 PM, Mel Gorman wrote:
> >Currently automatic NUMA balancing is unable to distinguish between false
> >shared versus private pages except by ignoring pages with an elevated
> 
> What's the meaning of false shared?
> 

Two tasks may be operating on a shared buffer that is not aligned. It is
expected that will at least cache align to avoid CPU cache line bouncing
but the buffers are not necessarily page aligned. A page is the minimum
granularity we can track NUMA hinting faults so two tasks sharing
such a page will appear to be sharing data when in fact they are not.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
