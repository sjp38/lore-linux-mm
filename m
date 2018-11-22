Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 324196B2B0F
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 05:16:00 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id l45so4341248edb.1
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 02:16:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s4sor10241805edx.12.2018.11.22.02.15.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Nov 2018 02:15:59 -0800 (PST)
Date: Thu, 22 Nov 2018 10:15:57 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v2] mm, hotplug: move init_currently_empty_zone() under
 zone_span_lock protection
Message-ID: <20181122101557.pzq6ggiymn52gfqk@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181122101241.7965-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181122101241.7965-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: mhocko@suse.com, osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu, Nov 22, 2018 at 06:12:41PM +0800, Wei Yang wrote:
>During online_pages phase, pgdat->nr_zones will be updated in case this
>zone is empty.
>
>Currently the online_pages phase is protected by the global lock
>mem_hotplug_begin(), which ensures there is no contention during the
>update of nr_zones. But this global lock introduces scalability issues.
>
>This patch is a preparation for removing the global lock during
>online_pages phase. Also this patch changes the documentation of
>node_size_lock to include the protectioin of nr_zones.
>
>Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

Missed this, if I am correct. :-)

Acked-by: Michal Hocko <mhocko@suse.com>

-- 
Wei Yang
Help you, Help me
