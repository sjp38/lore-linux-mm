Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1CF4A6B00AA
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 10:14:10 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id kl14so1090922pab.18
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 07:14:09 -0700 (PDT)
Received: from qmta08.emeryville.ca.mail.comcast.net (qmta08.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:80])
        by mx.google.com with ESMTP id ep2si1078020pbb.160.2014.04.08.07.14.08
        for <linux-mm@kvack.org>;
        Tue, 08 Apr 2014 07:14:09 -0700 (PDT)
Date: Tue, 8 Apr 2014 09:14:05 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm: Disable zone_reclaim_mode by default
In-Reply-To: <1396910068-11637-2-git-send-email-mgorman@suse.de>
Message-ID: <alpine.DEB.2.10.1404080910040.8782@nuc>
References: <1396910068-11637-1-git-send-email-mgorman@suse.de> <1396910068-11637-2-git-send-email-mgorman@suse.de>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sivanich@sgi.com
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Robert Haas <robertmhaas@gmail.com>, Josh Berkus <josh@agliodbs.com>, Andres Freund <andres@2ndquadrant.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 7 Apr 2014, Mel Gorman wrote:

> zone_reclaim_mode causes processes to prefer reclaiming memory from local
> node instead of spilling over to other nodes. This made sense initially when
> NUMA machines were almost exclusively HPC and the workload was partitioned
> into nodes. The NUMA penalties were sufficiently high to justify reclaiming
> the memory. On current machines and workloads it is often the case that
> zone_reclaim_mode destroys performance but not all users know how to detect
> this. Favour the common case and disable it by default. Users that are
> sophisticated enough to know they need zone_reclaim_mode will detect it.

Ok that is going to require SGI machines to deal with zone_reclaim
configurations on bootup. Dimitri? Any comments?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
