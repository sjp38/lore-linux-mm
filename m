Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C1E768E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 16:51:27 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id z10so14016027edz.15
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 13:51:27 -0800 (PST)
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id w26si515808edt.407.2018.12.18.13.51.26
        for <linux-mm@kvack.org>;
        Tue, 18 Dec 2018 13:51:26 -0800 (PST)
Date: Tue, 18 Dec 2018 22:51:25 +0100
From: Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v2] mm, page_alloc: Fix has_unmovable_pages for HugePages
Message-ID: <20181218215118.smplwk4qhptsoyer@d104.suse.de>
References: <20181217225113.17864-1-osalvador@suse.de>
 <20181217150726.6eea4942005516d565dae488@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181217150726.6eea4942005516d565dae488@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@suse.com, vbabka@suse.cz, pavel.tatashin@microsoft.com, rppt@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 17, 2018 at 03:07:26PM -0800, Andrew Morton wrote:
> On Mon, 17 Dec 2018 23:51:13 +0100 Oscar Salvador <osalvador@suse.de> wrote:
> 
> > v1 -> v2:
> > 	- Fix the logic for skipping pages by Michal
> > 
> > ---
> 
> Please be careful with the "^---$".  It signifies end-of-changelog, so
> I ended up without a changelog!

Sorry Andrew, somehow I screwed it up!
I will be more careful next time.

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
> 
> cc:stable?
> 

-- 
Oscar Salvador
SUSE L3
