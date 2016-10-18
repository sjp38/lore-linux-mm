Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6EE0F6B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 09:05:07 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id d185so423197785oig.1
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 06:05:07 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v12si3335399pag.62.2016.10.18.06.05.06
        for <linux-mm@kvack.org>;
        Tue, 18 Oct 2016 06:05:06 -0700 (PDT)
Date: Tue, 18 Oct 2016 14:04:35 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] mm: pagealloc: fix continued prints in show_free_areas
Message-ID: <20161018130435.GD15639@leverpostej>
References: <1476790457-7776-1-git-send-email-mark.rutland@arm.com>
 <d92624ee-76f2-5e42-8318-94ddf0f22bbf@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d92624ee-76f2-5e42-8318-94ddf0f22bbf@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, Joe Perches <joe@perches.com>, Michal Hocko <mhocko@kernel.org>

On Tue, Oct 18, 2016 at 03:00:40PM +0200, Vlastimil Babka wrote:
> On 10/18/2016 01:34 PM, Mark Rutland wrote:
> >In show_free_areas, we miss KERN_CONT in a few cases, and as a result
> >prints are unexpectedly split over a number of lines, making them
> >difficult to read (in v4.9-rc1).
> >
> >This patch uses pr_cont (with uits implicit KERN_CONT) to mark all
> >continued prints that occur withing a show_free_areas() call. Note that
> >show_migration_types() is only called by show_free_areas().
> >Depending on CONFIG_NUMA a printk after show_node() may or may not be a
> >continuation, but follows an explicit newline if not (and thus marking
> >it as a continuation should not be harmful).
> 
> I think this was already fixed:
> 
> http://marc.info/?l=linux-mm&m=147623910031630&w=2

So it was; thanks for the pointer!

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
