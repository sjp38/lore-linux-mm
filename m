Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6513E6B00D6
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 11:14:39 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id w62so9862503wes.13
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 08:14:39 -0800 (PST)
Received: from mail-wg0-x22b.google.com (mail-wg0-x22b.google.com. [2a00:1450:400c:c00::22b])
        by mx.google.com with ESMTPS id op9si51595676wjc.165.2015.01.06.08.14.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 08:14:38 -0800 (PST)
Received: by mail-wg0-f43.google.com with SMTP id k14so11887096wgh.16
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 08:14:38 -0800 (PST)
Date: Tue, 6 Jan 2015 17:14:35 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [LSF/MM TOPIC ATTEND]
Message-ID: <20150106161435.GF20860@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

Hi,
I would like to attend this year (2015) LSF/MM conference. I am
particularly interested in the MM track. I would like to discuss (among
other topics already suggested) the following topics:
General MM topics:
- THP success rate has become one of the metric for reclaim/compaction
  changes which I feel is missing one important aspect and that is
  cost/benefit analysis. It might be better to have more THP pages in
  some loads but the whole advantage might easily go away when the
  initial cost is higher than all aggregated saves. When it comes to
  benchmarks and numbers we are usually missing the later.
  This becomes even more an issue with memcg when close to the limit.
  Does it make sense to do a heavy reclaim (with THP size target) to
  fulfill THP allocations? If not memcg acts against the global MM and
  ruins the effort, on the other hand reclaiming 512 pages can take
  quite some time.
  The memcg part could be worked around by either precharging THP pages
  or reclaiming only clean page cache pages which would handle most
  usecases IMO but it would be better to think about a !memcg solution. Do
  we really want to allocate THP pages unconditionally or rather build
  them up if it seems worthwhile?

- As it turned out recently GFP_KERNEL mimicing GFP_NOFAIL for !costly
  allocation is sometimes kicking us back because we are basically
  creating an invisible lock dependencies which might livelock the whole
  system under OOM conditions.
  That leads to attempts to add more hacks into the OOM killer
  which is tricky enough as is. Changing the current state is
  quite risky because we do not really know how many places in the
  kernel silently depend on this behavior. As per Johannes attempt
  (http://marc.info/?l=linux-mm&m=141932770811346) it is clear that
  we are not yet there! I do not have very good ideas how to deal with
  this unfortunatelly...

And as a memcg co-maintainer I would like to also discuss the following
topics.
- We should finally settle down with a set of core knobs exported with
  the new unified hierarchy cgroups API. I have proposed this already
  http://marc.info/?l=linux-mm&m=140552160325228&w=2 but there is no
  clear consensus and the discussion has died later on. I feel it would
  be more productive to sit together and come up with a reasonable
  compromise between - let's start from the begining and keep useful and
  reasonable features.
  
- kmem accounting is seeing a lot of activity mainly thanks to Vladimir.
  He is basically the only active developer in this area. I would be
  happy if he can attend as well and discuss his future plans in the
  area. The work overlaps with slab allocators and slab shrinkers so
  having people familiar with these areas would be more than welcome
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
