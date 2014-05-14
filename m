Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0126B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 02:32:15 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d49so973244eek.1
        for <linux-mm@kvack.org>; Tue, 13 May 2014 23:32:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w2si830241eel.356.2014.05.13.23.32.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 23:32:13 -0700 (PDT)
Date: Wed, 14 May 2014 07:32:07 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 05/19] mm: page_alloc: Calculate classzone_idx once from
 the zonelist ref
Message-ID: <20140514063207.GX23991@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-6-git-send-email-mgorman@suse.de>
 <20140513152556.d14e3eaff8949a7010c02686@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140513152556.d14e3eaff8949a7010c02686@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Tue, May 13, 2014 at 03:25:56PM -0700, Andrew Morton wrote:
> On Tue, 13 May 2014 10:45:36 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > There is no need to calculate zone_idx(preferred_zone) multiple times
> > or use the pgdat to figure it out.
> > 
> 
> This one falls afoul of pending mm/next changes in non-trivial ways.

No problem, I can rework this patch on top of mmotm. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
