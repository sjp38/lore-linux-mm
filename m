Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B9C476B1C7D
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 16:47:11 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id t26so4664255pgu.18
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:47:11 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z22si6753439pfd.197.2018.11.19.13.47.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 13:47:10 -0800 (PST)
Date: Mon, 19 Nov 2018 22:47:01 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_alloc: fix calculation of pgdat->nr_zones
Message-ID: <20181119214701.GX22247@dhcp22.suse.cz>
References: <20181117022022.9956-1-richard.weiyang@gmail.com>
 <1542622061.3002.6.camel@suse.de>
 <20181119141505.xugul3s5nbzssybm@master>
 <20181119142325.GP22247@dhcp22.suse.cz>
 <20181119214450.i6q7vpnbly4d6d3y@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181119214450.i6q7vpnbly4d6d3y@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: osalvador <osalvador@suse.de>, akpm@linux-foundation.org, dave.hansen@intel.com, linux-mm@kvack.org

On Mon 19-11-18 21:44:50, Wei Yang wrote:
> On Mon, Nov 19, 2018 at 03:23:25PM +0100, Michal Hocko wrote:
> >On Mon 19-11-18 14:15:05, Wei Yang wrote:
> >> On Mon, Nov 19, 2018 at 11:07:41AM +0100, osalvador wrote:
> >> >
> >> >> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> >> >
> >> >Good catch.
> >> >
> >> >One thing I was wondering is that if we also should re-adjust it when a
> >> >zone gets emptied during offlining memory.
> >> >I checked, and whenever we work wirh pgdat->nr_zones we seem to check
> >> >if the zone is populated in order to work with it.
> >> >But still, I wonder if we should re-adjust it.
> >> 
> >> Well, thanks all for comments. I am glad you like it.
> >> 
> >> Actually, I have another proposal or I notice another potential issue.
> >> 
> >> In case user online pages in parallel, we may face a contention and get
> >> a wrong nr_zones.
> >
> >No, this should be protected by the global mem hotplug lock. Anyway a
> >dedicated lock would be much better. I would move it under
> >pgdat_resize_lock.
> 
> This is what I think about.
> 
> Do you like me to send v2 with this change? Or you would like to add it
> by yourself?

This is independent on this patch. So feel free to send a separate
patch.
-- 
Michal Hocko
SUSE Labs
