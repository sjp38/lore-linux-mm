Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id E9A8A6B0036
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 13:28:04 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id d1so3510454wiv.9
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 10:28:04 -0700 (PDT)
Received: from mail-wg0-x22d.google.com (mail-wg0-x22d.google.com [2a00:1450:400c:c00::22d])
        by mx.google.com with ESMTPS id wp3si11861852wjb.130.2014.09.22.10.28.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 22 Sep 2014 10:28:03 -0700 (PDT)
Received: by mail-wg0-f45.google.com with SMTP id x13so2554618wgg.4
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 10:28:03 -0700 (PDT)
Date: Mon, 22 Sep 2014 19:28:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm: memcontrol: lockless page counters
Message-ID: <20140922172800.GA4343@dhcp22.suse.cz>
References: <1411132928-16143-1-git-send-email-hannes@cmpxchg.org>
 <20140922144436.GG336@dhcp22.suse.cz>
 <20140922155049.GA6630@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140922155049.GA6630@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 22-09-14 11:50:49, Johannes Weiner wrote:
> On Mon, Sep 22, 2014 at 04:44:36PM +0200, Michal Hocko wrote:
> > On Fri 19-09-14 09:22:08, Johannes Weiner wrote:
[...]
> > Nevertheless I think that the counter should live outside of memcg (it
> > is ugly and bad in general to make HUGETLB controller depend on MEMCG
> > just to have a counter). If you made kernel/page_counter.c and led both
> > containers select CONFIG_PAGE_COUNTER then you do not need a dependency
> > on MEMCG and I would find it cleaner in general.
> 
> The reason I did it this way is because the hugetlb controller simply
> accounts and limits a certain type of memory and in the future I would
> like to make it a memcg extension, just like kmem and swap.

I am not sure this is the right way to go. Hugetlb has always been
"special" and I do not see any advantage to pull its specialness into
memcg proper. It would just make the code more complicated. I can also
imagine users who simply do not want to pay memcg overhead and use only
hugetlb controller.

Besides that it is not like a separate page_counter with a clear
interface would cause more maintenance overhead so I really do not see
any reason to pull it into memcg.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
