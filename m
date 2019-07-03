Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D832C0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 09:43:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7283218A5
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 09:43:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7283218A5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 478666B0003; Wed,  3 Jul 2019 05:43:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4296C8E0003; Wed,  3 Jul 2019 05:43:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CA998E0001; Wed,  3 Jul 2019 05:43:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D199B6B0003
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 05:43:29 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k22so1305258ede.0
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 02:43:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+hRXxhcJTTiyGu9B5kxy5ar4joTmkrg6c3xgxmdnWL8=;
        b=Dv2/bvzLCDs5c4cgklm16xYulB2M69PO+utf1tXuuMgwvDZhcdRTPKOTiOPUDYmPWs
         Uy1prm5z/Ir0Jpa53BJp135j1LVywNkx74ZwdG3xZvfyttirH6T0PWvpDO82hTgpyFyl
         sV6yUsmAOv7YZpDG8BfkjBzHcrv2lzbJLZ5kAGHE6cDs3d/15+VL5p3U+WbM1/IcPEzw
         OJlWMOyMt1v15/kXSv4y2vpy1aZgfPG9fUQ2rBkgS9vvCqpycI2otDwSkENVoVwZB13S
         vmeN9CZVsPUPceGQcabIww16wGL83WcgmODoNU9srPhIfHskhLU4IuH6t2ip+28hCYqJ
         sQbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.192 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAVwxcM7I7HgWQjR3lZ47Lqpl/X8EVx2f9zYrXLxo9dHs1LZla8F
	B5L37n1Y2bny0Opqj8MAM5t91YEQtsRgIIpY5zK7i5vUe/LaRd0cy9KrWrJNSsKBEvKx+OFPldA
	xMdw0p9w4Z9ZCVYnTdBRHw2IIUhVqLS81iA/NcCebhcou7Gr1kquPn/jMblJFaAjaPA==
X-Received: by 2002:a50:89a6:: with SMTP id g35mr42659697edg.145.1562147009298;
        Wed, 03 Jul 2019 02:43:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1AxWBq++ZVAH00uSEu/vr0XFK6Fg0hRusrHrW25FmoZfGO0AywX7KcTlgmvdWIsCtc7Bj
X-Received: by 2002:a50:89a6:: with SMTP id g35mr42659627edg.145.1562147008391;
        Wed, 03 Jul 2019 02:43:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562147008; cv=none;
        d=google.com; s=arc-20160816;
        b=p6Nkwam6dWoanTsB3Myttozsg6PO1AtsarIjfY6diqq79yHAmBl7QJg7Ub4xx8VQSe
         Ho9Dc2w8xDNWdkEMYLCiH+XUyJgKi8g49QgXzIy1KrYV9YIhPmqrR6RAWdlj7euOLf5t
         MBfDeMstJS0FM4Qj1VPS4NiW0YHNuLDr6wtCGb8nPisybcPuCPFtxGWfTfekUjiv8K/n
         YOv2mzBUVjVDIl7qSrS+SnN7Cq7GewINCTzuNnb87UCPco4oWclFbK51ubDAtETW5zfe
         gmfovPwUb3Wakua6oMeRIH9q5YakLCPzSClKIeQU01HwXqXsApQHpUEINuH/W00+QcNm
         ++2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+hRXxhcJTTiyGu9B5kxy5ar4joTmkrg6c3xgxmdnWL8=;
        b=yckB32D91/Cyd6gMB1pYlM0onh60wIAnRjxN8E6AMOX3gkKmiFNNa2XH3WxAUM7iE4
         ymUcIN2PGs1saNPnr41w7gTE7lxL1+zn+H+GfBg4xqmPiQqM5rXy6OHQLJJweWMPBA6h
         26s5lLvIOIU9V4+4ksdz/IwitQhdhMpCiGG4vMfucXLrAOgY03lby+F0ySyNgGda6AgR
         hf0vsJU1AqUwvcMnopTEB4s+VzRIdQBhxT2mZtsf8VTulwuXCAiQXbTraR646AwIQ5dM
         Yr5KAtEBAzowOwFaT/sa0LC83xn3NMNpdfll5hwYkDBm9KjAdt2MzLqtHgBv7xtisNV2
         hrsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.192 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp24.blacknight.com (outbound-smtp24.blacknight.com. [81.17.249.192])
        by mx.google.com with ESMTPS id c18si1265112ejf.196.2019.07.03.02.43.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 02:43:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.192 as permitted sender) client-ip=81.17.249.192;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.192 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp24.blacknight.com (Postfix) with ESMTPS id F1AADB8F52
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 10:43:27 +0100 (IST)
Received: (qmail 16561 invoked from network); 3 Jul 2019 09:43:27 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.21.36])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 3 Jul 2019 09:43:27 -0000
Date: Wed, 3 Jul 2019 10:43:25 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Question] Should direct reclaim time be bounded?
Message-ID: <20190703094325.GB2737@techsingularity.net>
References: <d38a095e-dc39-7e82-bb76-2c9247929f07@oracle.com>
 <20190423071953.GC25106@dhcp22.suse.cz>
 <eac582cf-2f76-4da1-1127-6bb5c8c959e4@oracle.com>
 <04329fea-cd34-4107-d1d4-b2098ebab0ec@suse.cz>
 <dede2f84-90bf-347a-2a17-fb6b521bf573@oracle.com>
 <20190701085920.GB2812@suse.de>
 <80036eed-993d-1d24-7ab6-e495f01b1caa@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <80036eed-993d-1d24-7ab6-e495f01b1caa@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 01, 2019 at 08:15:50PM -0700, Mike Kravetz wrote:
> On 7/1/19 1:59 AM, Mel Gorman wrote:
> > On Fri, Jun 28, 2019 at 11:20:42AM -0700, Mike Kravetz wrote:
> >> On 4/24/19 7:35 AM, Vlastimil Babka wrote:
> >>> On 4/23/19 6:39 PM, Mike Kravetz wrote:
> >>>>> That being said, I do not think __GFP_RETRY_MAYFAIL is wrong here. It
> >>>>> looks like there is something wrong in the reclaim going on.
> >>>>
> >>>> Ok, I will start digging into that.  Just wanted to make sure before I got
> >>>> into it too deep.
> >>>>
> >>>> BTW - This is very easy to reproduce.  Just try to allocate more huge pages
> >>>> than will fit into memory.  I see this 'reclaim taking forever' behavior on
> >>>> v5.1-rc5-mmotm-2019-04-19-14-53.  Looks like it was there in v5.0 as well.
> >>>
> >>> I'd suspect this in should_continue_reclaim():
> >>>
> >>>         /* Consider stopping depending on scan and reclaim activity */
> >>>         if (sc->gfp_mask & __GFP_RETRY_MAYFAIL) {
> >>>                 /*
> >>>                  * For __GFP_RETRY_MAYFAIL allocations, stop reclaiming if the
> >>>                  * full LRU list has been scanned and we are still failing
> >>>                  * to reclaim pages. This full LRU scan is potentially
> >>>                  * expensive but a __GFP_RETRY_MAYFAIL caller really wants to succeed
> >>>                  */
> >>>                 if (!nr_reclaimed && !nr_scanned)
> >>>                         return false;
> >>>
> >>> And that for some reason, nr_scanned never becomes zero. But it's hard
> >>> to figure out through all the layers of functions :/
> >>
> >> I got back to looking into the direct reclaim/compaction stalls when
> >> trying to allocate huge pages.  As previously mentioned, the code is
> >> looping for a long time in shrink_node().  The routine
> >> should_continue_reclaim() returns true perhaps more often than it should.
> >>
> >> As Vlastmil guessed, my debug code output below shows nr_scanned is remaining
> >> non-zero for quite a while.  This was on v5.2-rc6.
> >>
> > 
> > I think it would be reasonable to have should_continue_reclaim allow an
> > exit if scanning at higher priority than DEF_PRIORITY - 2, nr_scanned is
> > less than SWAP_CLUSTER_MAX and no pages are being reclaimed.
> 
> Thanks Mel,
> 
> I added such a check to should_continue_reclaim.  However, it does not
> address the issue I am seeing.  In that do-while loop in shrink_node,
> the scan priority is not raised (priority--).  We can enter the loop
> with priority == DEF_PRIORITY and continue to loop for minutes as seen
> in my previous debug output.
> 

Indeed. I'm getting knocked offline shortly so I didn't give this the
time it deserves but it appears that part of this problem is
hugetlb-specific when one node is full and can enter into this continual
loop due to __GFP_RETRY_MAYFAIL requiring both nr_reclaimed and
nr_scanned to be zero.

Have you considered one of the following as an option?

1. Always use the on-stack nodes_allowed in __nr_hugepages_store_common
   and copy nodes_states if necessary. Add a bool parameter to
   alloc_pool_huge_page that is true when called from set_max_huge_pages.
   If an allocation from alloc_fresh_huge_page, clear the failing node
   from the mask so it's not retried, bail if the mask is empty. The
   consequences are that round-robin allocation of huge pages will be
   different if a node failed to allocate for transient reasons.

2. Alter the condition in should_continue_reclaim for
   __GFP_RETRY_MAYFAIL to consider if nr_scanned < SWAP_CLUSTER_MAX.
   Either raise priority (will interfere with kswapd though) or
   bail entirely.  Consequences may be that other __GFP_RETRY_MAYFAIL
   allocations do not want this behaviour. There are a lot of users.

3. Move where __GFP_RETRY_MAYFAIL is set in a gfp_mask in mm/hugetlb.c.
   Strip the flag if an allocation fails on a node. Consequences are
   that setting the required number of huge pages is more likely to
   return without all the huge pages set.

-- 
Mel Gorman
SUSE Labs

