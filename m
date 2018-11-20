Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1BE6B2071
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 10:00:38 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id y35so1409265edb.5
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 07:00:38 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r18-v6si14019895ejh.206.2018.11.20.07.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 07:00:37 -0800 (PST)
Date: Tue, 20 Nov 2018 16:00:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/3] mm, memory_hotplug: try to migrate full section
 worth of pages
Message-ID: <20181120150035.GP22247@dhcp22.suse.cz>
References: <20181120134323.13007-1-mhocko@kernel.org>
 <20181120134323.13007-2-mhocko@kernel.org>
 <1542725492.6817.3.camel@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542725492.6817.3.camel@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador <osalvador@suse.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Hildenbrand <david@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Tatashin <pasha.tatashin@soleen.com>

On Tue 20-11-18 15:51:32, Oscar Salvador wrote:
> On Tue, 2018-11-20 at 14:43 +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > do_migrate_range has been limiting the number of pages to migrate to
> > 256
> > for some reason which is not documented. 
> 
> When looking back at old memory-hotplug commits one feels pretty sad
> about the brevity of the changelogs.

Well, things evolve and we've become much more careful about changelogs
over time. It still gets quite a lot of time to push back on changelogs
even these days though. People still keep forgetting that "what" is not
as important as "why" because the former is usually quite easy to
understand from reading the diff. The intention behind is usually what
gets forgotten after years. I guess people realize this much more after
few excavation git blame tours.

> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Reviewed-by: Oscar Salvador <osalvador@suse.de>

Thanks!
-- 
Michal Hocko
SUSE Labs
