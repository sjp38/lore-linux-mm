Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1472E6B1F26
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 03:48:11 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e29so903745ede.19
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 00:48:11 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 93-v6si3706005edl.31.2018.11.20.00.48.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 00:48:09 -0800 (PST)
Date: Tue, 20 Nov 2018 09:48:08 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, hotplug: protect nr_zones with pgdat_resize_lock()
Message-ID: <20181120084808.GC22247@dhcp22.suse.cz>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181120073141.GY22247@dhcp22.suse.cz>
 <3ba8d8c524d86af52e4c1fddc2d45734@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3ba8d8c524d86af52e4c1fddc2d45734@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@suse.de
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org

On Tue 20-11-18 08:58:11, osalvador@suse.de wrote:
> > On the other hand I would like to see the global lock to go away because
> > it causes scalability issues and I would like to change it to a range
> > lock. This would make this race possible.
> > 
> > That being said this is more of a preparatory work than a fix. One could
> > argue that pgdat resize lock is abused here but I am not convinced a
> > dedicated lock is much better. We do take this lock already and spanning
> > its scope seems reasonable. An update to the documentation is due.
> 
> Would not make more sense to move it within the pgdat lock
> in move_pfn_range_to_zone?

yes, that was what I meant originally and I haven't really looked closer
to the diff itself because I've stopped right at the description.

> The call from free_area_init_core is safe as we are single-thread there.
> 
> And if we want to move towards a range locking, I even think it would be
> more
> consistent if we move it within the zone's span lock (which is already
> wrapped with a pgdat lock).

Agreed!
-- 
Michal Hocko
SUSE Labs
