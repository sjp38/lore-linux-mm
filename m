Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 54E696B00AE
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 10:17:08 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so1068855pdj.27
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 07:17:07 -0700 (PDT)
Received: from qmta14.emeryville.ca.mail.comcast.net (qmta14.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:212])
        by mx.google.com with ESMTP id m9si1091628pab.372.2014.04.08.07.17.07
        for <linux-mm@kvack.org>;
        Tue, 08 Apr 2014 07:17:07 -0700 (PDT)
Date: Tue, 8 Apr 2014 09:17:04 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/2] Disable zone_reclaim_mode by default
In-Reply-To: <5343A494.9070707@suse.cz>
Message-ID: <alpine.DEB.2.10.1404080914280.8782@nuc>
References: <1396910068-11637-1-git-send-email-mgorman@suse.de> <5343A494.9070707@suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Robert Haas <robertmhaas@gmail.com>, Josh Berkus <josh@agliodbs.com>, Andres Freund <andres@2ndquadrant.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, sivanich@sgi.com

On Tue, 8 Apr 2014, Vlastimil Babka wrote:

> On 04/08/2014 12:34 AM, Mel Gorman wrote:
> > When it was introduced, zone_reclaim_mode made sense as NUMA distances
> > punished and workloads were generally partitioned to fit into a NUMA
> > node. NUMA machines are now common but few of the workloads are NUMA-aware
> > and it's routine to see major performance due to zone_reclaim_mode being
> > disabled but relatively few can identify the problem.
>     ^ I think you meant "enabled" here?
>
> Just in case the cover letter goes to the changelog...

Correct.

Another solution here would be to increase the threshhold so that
4 socket machines do not enable zone reclaim by default. The larger the
NUMA system is the more memory is off node from the perspective of a
processor and the larger the hit from remote memory.

On the other hand: The more expensive we make reclaim the less it
makes sense to allow zone reclaim to occur.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
