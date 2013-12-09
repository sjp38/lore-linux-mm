Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id A5E3C6B008A
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 04:08:37 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id z2so3363121wiv.0
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 01:08:37 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id m44si8595472eeo.163.2013.12.09.01.08.36
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 01:08:36 -0800 (PST)
Date: Mon, 9 Dec 2013 09:08:34 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 13/18] mm: numa: Make NUMA-migrate related functions
 static
Message-ID: <20131209090833.GY11295@suse.de>
References: <1386572952-1191-1-git-send-email-mgorman@suse.de>
 <1386572952-1191-14-git-send-email-mgorman@suse.de>
 <20131209072010.GA3716@hacker.(null)>
 <20131209084659.GX11295@suse.de>
 <20131209085720.GA16251@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131209085720.GA16251@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Dec 09, 2013 at 04:57:20PM +0800, Wanpeng Li wrote:
> On Mon, Dec 09, 2013 at 08:46:59AM +0000, Mel Gorman wrote:
> >On Mon, Dec 09, 2013 at 03:20:10PM +0800, Wanpeng Li wrote:
> >> Hi Mel,
> >> On Mon, Dec 09, 2013 at 07:09:07AM +0000, Mel Gorman wrote:
> >> >numamigrate_update_ratelimit and numamigrate_isolate_page only have callers
> >> >in mm/migrate.c. This patch makes them static.
> >> >
> >> 
> >> I have already send out patches to fix this issue yesterday. ;-)
> >> 
> >> http://marc.info/?l=linux-mm&m=138648332222847&w=2
> >> http://marc.info/?l=linux-mm&m=138648332422848&w=2
> >> 
> >
> >I know. I had written the patch some time ago waiting to go out with
> >the TLB flush fix and just didn't bother dropping it in response to your
> >series.
> 
> Ok, could you review my patchset v3? Thanks in advance. ;-)
> 

Glanced through it this morning and saw nothing wrong. I expect it'll
get picked up in due course.

Thanks

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
