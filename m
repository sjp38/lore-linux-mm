Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 23A306B000D
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 08:36:13 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p3-v6so8172402wmc.7
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 05:36:13 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w16-v6sor7128913wrs.84.2018.08.14.05.36.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Aug 2018 05:36:11 -0700 (PDT)
Date: Tue, 14 Aug 2018 14:36:10 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v2 2/3] mm/memory_hotplug: Drop mem_blk check from
 unregister_mem_sect_under_nodes
Message-ID: <20180814123610.GA7437@techadventures.net>
References: <20180813154639.19454-1-osalvador@techadventures.net>
 <20180813154639.19454-3-osalvador@techadventures.net>
 <82148bc6-672d-6610-757f-d910a17d23c6@redhat.com>
 <20180814093652.GA6878@techadventures.net>
 <39454952-f8c9-4ded-acb5-02192e889de0@redhat.com>
 <20180814100644.GB6979@techadventures.net>
 <292e9b31-b043-d140-77da-03082025fa1b@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <292e9b31-b043-d140-77da-03082025fa1b@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, jglisse@redhat.com, rafael@kernel.org, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, Jonathan.Cameron@huawei.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Tue, Aug 14, 2018 at 12:09:14PM +0200, David Hildenbrand wrote:
> 
> Whatever you think is best. I have no idea what the general rules in MM
> code are. Maybe dropping this check is totally fine.

Well, if you ask me, callers should care for validating mem_blk before calling in.
But a WARN_ON is not harmful either.

Let us just wait to hear more from others.
 
Thanks
-- 
Oscar Salvador
SUSE L3
