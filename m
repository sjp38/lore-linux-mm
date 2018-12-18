Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 241B68E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 02:36:59 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id i55so11629331ede.14
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 23:36:59 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y15si409756edc.192.2018.12.17.23.36.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 23:36:57 -0800 (PST)
Date: Tue, 18 Dec 2018 08:36:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm, page_alloc: Fix has_unmovable_pages for HugePages
Message-ID: <20181218073655.GB30879@dhcp22.suse.cz>
References: <20181217225113.17864-1-osalvador@suse.de>
 <20181217150726.6eea4942005516d565dae488@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181217150726.6eea4942005516d565dae488@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>, vbabka@suse.cz, pavel.tatashin@microsoft.com, rppt@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 17-12-18 15:07:26, Andrew Morton wrote:
> On Mon, 17 Dec 2018 23:51:13 +0100 Oscar Salvador <osalvador@suse.de> wrote:
> 
> > v1 -> v2:
> > 	- Fix the logic for skipping pages by Michal
> > 
> > ---
> 
> Please be careful with the "^---$".  It signifies end-of-changelog, so
> I ended up without a changelog!
> 
> > >From e346b151037d3c37feb10a981a4d2a25018acf81 Mon Sep 17 00:00:00 2001
> > From: Oscar Salvador <osalvador@suse.de>
> > Date: Mon, 17 Dec 2018 14:53:35 +0100
> > Subject: [PATCH] mm, page_alloc: Fix has_unmovable_pages for HugePages
> > 
> > While playing with gigantic hugepages and memory_hotplug, I triggered
> > the following #PF when "cat memoryX/removable":
> > 
> > ...
> >
> > Also, since gigantic pages span several pageblocks, re-adjust the logic
> > for skipping pages.
> > 
> > Signed-off-by: Oscar Salvador <osalvador@suse.de>

Acked-by: Michal Hocko <mhocko@suse.com>

> cc:stable?

See http://lkml.kernel.org/r/20181217152936.GR30879@dhcp22.suse.cz. I
believe nobody is simply using gigantic pages and hotplug at the same
time and those pages do not seem to cross cma regions as well. At least
not since hugepage_migration_supported stops reporting giga pages as
migrateable.

That being said, I do not think we really need it in stable but it
should be relatively easy to backport so no objection from me to put it
there.

-- 
Michal Hocko
SUSE Labs
