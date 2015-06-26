Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 27EA26B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 06:16:06 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so41173128wiw.0
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 03:16:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pg3si2075105wic.30.2015.06.26.03.16.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 03:16:05 -0700 (PDT)
Date: Fri, 26 Jun 2015 11:16:00 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: meminit: Finish initialisation of struct pages
 before basic setup
Message-ID: <20150626101600.GG26927@suse.de>
References: <20150513163157.GR2462@suse.de>
 <1431597783.26797.1@cpanel21.proisp.no>
 <20150624225028.GA97166@asylum.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150624225028.GA97166@asylum.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: Daniel J Blueman <daniel@numascale.com>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steffen Persvold <sp@numascale.com>

On Wed, Jun 24, 2015 at 05:50:28PM -0500, Nathan Zimmer wrote:
> From e18aa6158a60c2134b4eef93c856f3b5b250b122 Mon Sep 17 00:00:00 2001
> From: Nathan Zimmer <nzimmer@sgi.com>
> Date: Thu, 11 Jun 2015 10:47:39 -0500
> Subject: [RFC] Avoid the contention in set_cpus_allowed
> 
> Noticing some scaling issues at larger box sizes (64 nodes+) I found that in some
> cases we are spending significant amounts of time in set_cpus_allowed_ptr.
> 
> My assumption is that it is getting stuck on migration.
> So if we create the thread on the target node and restrict cpus before we start
> the thread then we don't have to suffer migration.
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Waiman Long <waiman.long@hp.com
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Scott Norton <scott.norton@hp.com>
> Cc: Daniel J Blueman <daniel@numascale.com>
> Signed-off-by: Nathan Zimmer <nzimmer@sgi.com>
> 

I asked yesterday if set_cpus_allowed_ptr() was required and I made a
mistake because it is. The node parameter for kthread_create_on_node()
controls where it gets created but not how it is scheduled after that.
Sorry for the noise. The patch makes sense to me now, lets see if it
helps Daniel.


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
