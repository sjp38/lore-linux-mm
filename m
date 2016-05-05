Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9FDAA6B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 11:57:57 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b203so175035916pfb.1
        for <linux-mm@kvack.org>; Thu, 05 May 2016 08:57:57 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id vz3si12076416pab.93.2016.05.05.08.57.56
        for <linux-mm@kvack.org>;
        Thu, 05 May 2016 08:57:56 -0700 (PDT)
Message-ID: <1462463770.22178.4.camel@linux.intel.com>
Subject: Re: [PATCH 0/7] mm: Improve swap path scalability with batched
 operations
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Thu, 05 May 2016 08:56:10 -0700
In-Reply-To: <20160505074922.GB4386@dhcp22.suse.cz>
References: <cover.1462306228.git.tim.c.chen@linux.intel.com>
	 <1462309239.21143.6.camel@linux.intel.com>
	 <20160504124535.GJ29978@dhcp22.suse.cz>
	 <1462381986.30611.28.camel@linux.intel.com>
	 <20160504194901.GG21490@dhcp22.suse.cz> <20160504212506.GA1364@cmpxchg.org>
	 <20160505074922.GB4386@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Thu, 2016-05-05 at 09:49 +0200, Michal Hocko wrote:
> On Wed 04-05-16 17:25:06, Johannes Weiner wrote:
> > 
> >A 
> 
> > 
> > > 
> > > > 
> > > > I understand that the patch set is a little large. Any better
> > > > ideas for achieving similar ends will be appreciated. A I put
> > > > out these patches in the hope that it will spur solutions
> > > > to improve swap.
> > > > 
> > > > Perhaps the first two patches to make shrink_page_list into
> > > > smaller components can be considered first, as a first stepA 
> > > > to make any changes to the reclaim code easier.
> > It makes sense that we need to batch swap allocation and swap cache
> > operations. Unfortunately, the patches as they stand turn
> > shrink_page_list() into an unreadable mess. This would need better
> > refactoring before considering them for upstream merging. The swap
> > allocation batching should not obfuscate the main sequence of
> > events
> > that is happening for both file-backed and anonymous pages.
> That was my first impression as well but to be fair I only skimmed
> through the patch so I might be just biased by the size.
> 
> > 
> > It'd also be great if the remove_mapping() batching could be done
> > universally for all pages, given that in many cases file pages from
> > the same inode also cluster together on the LRU.
> 

Agree. A I didn't try to do something on file mapped pages yet as
the changes in this patch set is already quite substantial.
But once we have some agreement on the batching on the anonymous
pages, the file backed pages could be grouped similarly.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
