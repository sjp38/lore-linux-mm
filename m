Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 154386B038C
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 01:33:16 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b2so72651385pgc.6
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 22:33:16 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id b7si4176707pll.139.2017.03.15.22.33.14
        for <linux-mm@kvack.org>;
        Wed, 15 Mar 2017 22:33:15 -0700 (PDT)
Date: Thu, 16 Mar 2017 14:33:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 10/10] mm: remove SWAP_[SUCCESS|AGAIN|FAIL]
Message-ID: <20170316053313.GA19241@bbox>
References: <1489555493-14659-1-git-send-email-minchan@kernel.org>
 <1489555493-14659-11-git-send-email-minchan@kernel.org>
 <20170316044023.GA2597@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170316044023.GA2597@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

Hey, Sergey,

On Thu, Mar 16, 2017 at 01:40:23PM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> 
> On (03/15/17 14:24), Minchan Kim wrote:
> > There is no user for it. Remove it.
> > 
> 
> there is one.
> 
> mm/rmap.c
> 
> try_to_unmap_one()
> ...
> 	if (unlikely(PageSwapBacked(page) != PageSwapCache(page))) {
> 		WARN_ON_ONCE(1);
> 		ret = SWAP_FAIL;
> 		page_vma_mapped_walk_done(&pvmw);
> 		break;
> 	}

"There is no user for it"

I was liar so need to be a honest guy.
Thanks, Sergey!

Andrew, Please make me honest. Sorry about that.
