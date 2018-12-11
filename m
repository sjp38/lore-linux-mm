Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0498E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 05:20:17 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b7so6729715eda.10
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 02:20:17 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 24si2068478edu.308.2018.12.11.02.20.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 02:20:16 -0800 (PST)
Date: Tue, 11 Dec 2018 11:20:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, memory_hotplug: Don't bail out in do_migrate_range
 prematurely
Message-ID: <20181211102014.GF1286@dhcp22.suse.cz>
References: <20181211085042.2696-1-osalvador@suse.de>
 <5e3e33e3-bea8-249c-2b05-665f40d70df4@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5e3e33e3-bea8-249c-2b05-665f40d70df4@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org, pasha.tatashin@soleen.com, dan.j.williams@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 11-12-18 10:35:53, David Hildenbrand wrote:
> So somehow remember if we had issues with one page and instead of
> reporting 0, report e.g. -EAGAIN?

There is no consumer of the return value right now and it is not really
clear whether we need one. I would just make do_migrate_range return void.
-- 
Michal Hocko
SUSE Labs
