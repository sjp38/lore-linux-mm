Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7AF2C6B003D
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 10:26:53 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id d49so773034eek.27
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 07:26:51 -0700 (PDT)
Received: from moutng.kundenserver.de (moutng.kundenserver.de. [212.227.17.10])
        by mx.google.com with ESMTPS id 43si2981755eei.325.2014.04.08.07.26.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Apr 2014 07:26:50 -0700 (PDT)
Date: Tue, 8 Apr 2014 16:26:42 +0200
From: Andres Freund <andres@2ndquadrant.com>
Subject: Re: [PATCH 0/2] Disable zone_reclaim_mode by default
Message-ID: <20140408142642.GU4161@awork2.anarazel.de>
References: <1396910068-11637-1-git-send-email-mgorman@suse.de>
 <5343A494.9070707@suse.cz>
 <alpine.DEB.2.10.1404080914280.8782@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1404080914280.8782@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Robert Haas <robertmhaas@gmail.com>, Josh Berkus <josh@agliodbs.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, sivanich@sgi.com

On 2014-04-08 09:17:04 -0500, Christoph Lameter wrote:
> On Tue, 8 Apr 2014, Vlastimil Babka wrote:
> 
> > On 04/08/2014 12:34 AM, Mel Gorman wrote:
> > > When it was introduced, zone_reclaim_mode made sense as NUMA distances
> > > punished and workloads were generally partitioned to fit into a NUMA
> > > node. NUMA machines are now common but few of the workloads are NUMA-aware
> > > and it's routine to see major performance due to zone_reclaim_mode being
> > > disabled but relatively few can identify the problem.
> >     ^ I think you meant "enabled" here?
> >
> > Just in case the cover letter goes to the changelog...
> 
> Correct.
> 
> Another solution here would be to increase the threshhold so that
> 4 socket machines do not enable zone reclaim by default. The larger the
> NUMA system is the more memory is off node from the perspective of a
> processor and the larger the hit from remote memory.

FWIW, I've the problem hit majorly on 8 socket machines. Those are the
largest I have seen so far in postgres scenarios. Everything larger is
far less likely to be used as single node database server, so that's
possibly a sensible cutoff.
But then, I'd think that special many-socket machines are setup by
specialists, that'd know to enable if it makes sense...

Greetings,

Andres Freund

-- 
 Andres Freund	                   http://www.2ndQuadrant.com/
 PostgreSQL Development, 24x7 Support, Training & Services

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
