Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id D53206B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 14:24:00 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id ld10so2844296pab.17
        for <linux-mm@kvack.org>; Thu, 22 May 2014 11:24:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id eb4si686024pbb.113.2014.05.22.11.23.59
        for <linux-mm@kvack.org>;
        Thu, 22 May 2014 11:23:59 -0700 (PDT)
Date: Thu, 22 May 2014 11:23:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 09/19] mm: page_alloc: Use word-based accesses for
 get/set pageblock bitmaps
Message-Id: <20140522112357.4715059bb69273f40c3ec4f2@linux-foundation.org>
In-Reply-To: <537DC247.5020801@suse.cz>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
	<1399974350-11089-10-git-send-email-mgorman@suse.de>
	<537DC247.5020801@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Thu, 22 May 2014 11:24:23 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> > In a test running dd onto tmpfs the overhead of the pageblock-related
> > functions went from 1.27% in profiles to 0.5%.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Hi, I've tested if this closes the race I've been previously trying to fix
> with the series in http://marc.info/?l=linux-mm&m=139359694028925&w=2
> And indeed with this patch I wasn't able to reproduce it in my stress test
> (which adds lots of memory isolation calls) anymore. So thanks to Mel I can
> dump my series in the trashcan :P
> 
> Therefore I believe something like below should be added to the changelog,
> and put to stable as well.

OK, I made it so.

Miraculously, the patch applies OK to 3.14.  And it compiles!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
