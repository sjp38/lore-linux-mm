Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2006B0281
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 07:35:49 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id w1so11386743pgq.21
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 04:35:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q3si7895053pgp.97.2017.12.04.04.35.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 04:35:48 -0800 (PST)
Date: Mon, 4 Dec 2017 13:35:46 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [patch 13/15] mm/page_owner: align with pageblock_nr pages
Message-ID: <20171204123546.lhhcbpulihz3upm6@dhcp22.suse.cz>
References: <5a208318./AHclpWAWggUsQYT%akpm@linux-foundation.org>
 <8c2af1ab-e64f-21da-f295-ea1ead343206@suse.cz>
 <20171201171517.lyqukuvuh4cswnla@dhcp22.suse.cz>
 <5A2536B0.5060804@huawei.com>
 <20171204120114.iezicg6pmyj2z6lq@dhcp22.suse.cz>
 <5A253E55.7040706@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A253E55.7040706@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, linux-mm@kvack.org

On Mon 04-12-17 20:23:49, zhong jiang wrote:
> On 2017/12/4 20:01, Michal Hocko wrote:
> > On Mon 04-12-17 19:51:12, zhong jiang wrote:
> >> On 2017/12/2 1:15, Michal Hocko wrote:
> >>> On Fri 01-12-17 17:58:28, Vlastimil Babka wrote:
> >>>> On 11/30/2017 11:15 PM, akpm@linux-foundation.org wrote:
> >>>>> From: zhong jiang <zhongjiang@huawei.com>
> >>>>> Subject: mm/page_owner: align with pageblock_nr pages
> >>>>>
> >>>>> When pfn_valid(pfn) returns false, pfn should be aligned with
> >>>>> pageblock_nr_pages other than MAX_ORDER_NR_PAGES in init_pages_in_zone,
> >>>>> because the skipped 2M may be valid pfn, as a result, early allocated
> >>>>> count will not be accurate.
> >>>>>
> >>>>> Link: http://lkml.kernel.org/r/1468938136-24228-1-git-send-email-zhongjiang@huawei.com
> >>>>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> >>>>> Cc: Michal Hocko <mhocko@kernel.org>
> >>>>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> >>>> The author never responded and Michal Hocko basically NAKed it in
> >>>> https://lkml.kernel.org/r/<20160812130727.GI3639@dhcp22.suse.cz>
> >>>> I think we should drop it.
> >>> Or extend the changelog to actually describe what kind of problem it
> >>> fixes and do an additional step to unigy
> >>> MAX_ORDER_NR_PAGES/pageblock_nr_pages
> >>>  
> >>   Hi, Michal
> >>    
> >>         IIRC,  I had explained the reason for patch.  if it not. I am so sorry for that.
> >>     
> >>         when we select MAX_ORDER_NR_PAGES,   the second 2M will be skiped.
> >>        it maybe result in normal pages leak.
> >>
> >>         meanwhile.  as you had said.  it make the code consistent.  why do not we do it.
> >>    
> >>         I think it is reasonable to upstream the patch.  maybe I should rewrite the changelog
> >>        and repost it.
> >>
> >>     Michal,  Do you think ?
> > Yes, rewrite the patch changelog and make it _clear_ what it fixes and
> > under _what_ conditions. There are also other places using
> > MAX_ORDER_NR_PAGES rathern than pageblock_nr_pages. Do they need to be
> > updated as well?
>  in the lastest kernel.  according to correspond context,   I  can not find the candidate. :-)

git grep says some in page_ext.c, memory_hotplug.c and few in the arch
code. I belive we really want to describe and document the distinction
between the two constants and explain when to use which one.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
