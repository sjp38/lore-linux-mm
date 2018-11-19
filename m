Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id F1AC06B1A3D
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 09:23:28 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id r65-v6so21368812pfa.8
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 06:23:28 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c24si12673855pgk.269.2018.11.19.06.23.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 06:23:28 -0800 (PST)
Date: Mon, 19 Nov 2018 15:23:25 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_alloc: fix calculation of pgdat->nr_zones
Message-ID: <20181119142325.GP22247@dhcp22.suse.cz>
References: <20181117022022.9956-1-richard.weiyang@gmail.com>
 <1542622061.3002.6.camel@suse.de>
 <20181119141505.xugul3s5nbzssybm@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181119141505.xugul3s5nbzssybm@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: osalvador <osalvador@suse.de>, akpm@linux-foundation.org, dave.hansen@intel.com, linux-mm@kvack.org

On Mon 19-11-18 14:15:05, Wei Yang wrote:
> On Mon, Nov 19, 2018 at 11:07:41AM +0100, osalvador wrote:
> >
> >> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> >
> >Good catch.
> >
> >One thing I was wondering is that if we also should re-adjust it when a
> >zone gets emptied during offlining memory.
> >I checked, and whenever we work wirh pgdat->nr_zones we seem to check
> >if the zone is populated in order to work with it.
> >But still, I wonder if we should re-adjust it.
> 
> Well, thanks all for comments. I am glad you like it.
> 
> Actually, I have another proposal or I notice another potential issue.
> 
> In case user online pages in parallel, we may face a contention and get
> a wrong nr_zones.

No, this should be protected by the global mem hotplug lock. Anyway a
dedicated lock would be much better. I would move it under
pgdat_resize_lock.
-- 
Michal Hocko
SUSE Labs
