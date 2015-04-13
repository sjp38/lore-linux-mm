Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id C3D396B006C
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 06:29:30 -0400 (EDT)
Received: by wgsk9 with SMTP id k9so75697630wgs.3
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 03:29:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n6si13291001wie.48.2015.04.13.03.29.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Apr 2015 03:29:29 -0700 (PDT)
Date: Mon, 13 Apr 2015 11:29:24 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/14] Parallel memory initialisation
Message-ID: <20150413102924.GC14842@suse.de>
References: <1428920226-18147-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1428920226-18147-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, Apr 13, 2015 at 11:16:52AM +0100, Mel Gorman wrote:
> Memory initialisation had been identified as one of the reasons why large
> machines take a long time to boot. Patches were posted a long time ago
> that attempted to move deferred initialisation into the page allocator
> paths. This was rejected on the grounds it should not be necessary to hurt
> the fast paths to parallelise initialisation. This series reuses much of
> the work from that time but defers the initialisation of memory to kswapd
> so that one thread per node initialises memory local to that node. The
> issue is that on the machines I tested with, memory initialisation was not
> a major contributor to boot times. I'm posting the RFC to both review the
> series and see if it actually helps users of very large machines.
> 

Robin Holt's address now bounces so remove the address from any replies.
If anyone has an updated address for him that he wants to use then let
me know. Otherwise, I'll leave the From's and Signed-offs from him as
the old address as it was accurate at the time.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
