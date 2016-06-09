Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2656B007E
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 08:21:44 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c82so21121807wme.2
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 05:21:44 -0700 (PDT)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id lb8si7560219wjc.158.2016.06.09.05.21.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 05:21:43 -0700 (PDT)
Received: by mail-wm0-f41.google.com with SMTP id m124so57823019wme.1
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 05:21:43 -0700 (PDT)
Date: Thu, 9 Jun 2016 14:21:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm/swap.c: flush lru_add pvecs on compound page
 arrival
Message-ID: <20160609122140.GE24777@dhcp22.suse.cz>
References: <1465396537-17277-1-git-send-email-lukasz.odzioba@intel.com>
 <57583A49.30809@intel.com>
 <20160608160653.GB21838@dhcp22.suse.cz>
 <575848F9.2060501@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <575848F9.2060501@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Lukasz Odzioba <lukasz.odzioba@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, vdavydov@parallels.com, mingli199x@qq.com, minchan@kernel.org, lukasz.anaczkowski@intel.com, "Shutemov, Kirill" <kirill.shutemov@intel.com>

On Wed 08-06-16 09:34:01, Dave Hansen wrote:
> On 06/08/2016 09:06 AM, Michal Hocko wrote:
> >> > Do we have any statistics that tell us how many pages are sitting the
> >> > lru pvecs?  Although this helps the problem overall, don't we still have
> >> > a problem with memory being held in such an opaque place?
> > Is it really worth bothering when we are talking about 56kB per CPU
> > (after this patch)?
> 
> That was the logic why we didn't have it up until now: we didn't
> *expect* it to get large.  A code change blew it up by 512x, and we had
> no instrumentation to tell us where all the memory went.
> 
> I guess we don't have any other ways to group pages than compound pages,
> and _that_ one is covered now...

exactly and that is why I am not sure it is needed. I do not expect we
would ever change the pagevec size or have a different way of grouping
pages on the LRU list.

That being said I am not objecting to the counter, I am just not sure it
is worth it.

> for one of the 5 classes of pvecs.
> 
> Is there a good reason we don't have to touch the other 4 pagevecs, btw?

I agree it would be better to do the same for others as well. Even if
this is not an immediate problem for those.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
