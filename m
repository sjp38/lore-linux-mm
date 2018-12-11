Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id ADD8C8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 07:52:36 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d41so6742947eda.12
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 04:52:36 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s34si2188665edb.417.2018.12.11.04.52.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 04:52:35 -0800 (PST)
Date: Tue, 11 Dec 2018 13:52:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, memory_hotplug: Don't bail out in do_migrate_range
 prematurely
Message-ID: <20181211125234.GI1286@dhcp22.suse.cz>
References: <20181211085042.2696-1-osalvador@suse.de>
 <20181211101818.GE1286@dhcp22.suse.cz>
 <6009dea8a638aaa5b88088a117297edf@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6009dea8a638aaa5b88088a117297edf@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@suse.de
Cc: akpm@linux-foundation.org, david@redhat.com, pasha.tatashin@soleen.com, dan.j.williams@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 11-12-18 13:22:27, osalvador@suse.de wrote:
> On 2018-12-11 11:18, Michal Hocko wrote:
[...]
> > The main question here is. Do we want to migrate as much as possible or
> > do we want to be conservative and bail out early. The later could be an
> > advantage if the next attempt could fail the whole operation because the
> > impact of the failed operation would be somehow reduced. The former
> > should be better for throughput because easily done stuff is done first.
> > 
> > I would go with the throuput because our failure mode is to bail out
> > much earlier - even before we try to migrate. Even though the detection
> > is not perfect it works reasonably well for most usecases.
> 
> I agree here.
> I think it is better to do as much work as possible at once.

This would be great to mention in the changelog. Because that is the
real justification for the change IMHO.

-- 
Michal Hocko
SUSE Labs
