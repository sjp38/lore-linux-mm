Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id A51686B0069
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 03:47:03 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id f15so1394066eak.11
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 00:47:03 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id h45si8492488eeo.235.2013.12.09.00.47.02
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 00:47:02 -0800 (PST)
Date: Mon, 9 Dec 2013 08:46:59 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 13/18] mm: numa: Make NUMA-migrate related functions
 static
Message-ID: <20131209084659.GX11295@suse.de>
References: <1386572952-1191-1-git-send-email-mgorman@suse.de>
 <1386572952-1191-14-git-send-email-mgorman@suse.de>
 <20131209072010.GA3716@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131209072010.GA3716@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Dec 09, 2013 at 03:20:10PM +0800, Wanpeng Li wrote:
> Hi Mel,
> On Mon, Dec 09, 2013 at 07:09:07AM +0000, Mel Gorman wrote:
> >numamigrate_update_ratelimit and numamigrate_isolate_page only have callers
> >in mm/migrate.c. This patch makes them static.
> >
> 
> I have already send out patches to fix this issue yesterday. ;-)
> 
> http://marc.info/?l=linux-mm&m=138648332222847&w=2
> http://marc.info/?l=linux-mm&m=138648332422848&w=2
> 

I know. I had written the patch some time ago waiting to go out with
the TLB flush fix and just didn't bother dropping it in response to your
series.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
