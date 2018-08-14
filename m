Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8FF716B0007
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 06:06:47 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id k15-v6so15318610wrq.1
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 03:06:47 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s3-v6sor7077965wrm.1.2018.08.14.03.06.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Aug 2018 03:06:46 -0700 (PDT)
Date: Tue, 14 Aug 2018 12:06:44 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v2 2/3] mm/memory_hotplug: Drop mem_blk check from
 unregister_mem_sect_under_nodes
Message-ID: <20180814100644.GB6979@techadventures.net>
References: <20180813154639.19454-1-osalvador@techadventures.net>
 <20180813154639.19454-3-osalvador@techadventures.net>
 <82148bc6-672d-6610-757f-d910a17d23c6@redhat.com>
 <20180814093652.GA6878@techadventures.net>
 <39454952-f8c9-4ded-acb5-02192e889de0@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39454952-f8c9-4ded-acb5-02192e889de0@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, jglisse@redhat.com, rafael@kernel.org, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, Jonathan.Cameron@huawei.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Tue, Aug 14, 2018 at 11:44:50AM +0200, David Hildenbrand wrote:
> 
> Yes I know, as I said, if it would be local to a file I would not care.
> Making this functions never return an error is nice, though (and as you
> noted, the return value is never checked).
> 
> I am a friend of stating which conditions a function expects to hold if
> a function can be called from other parts of the system. Usually I
> prefer to use BUG_ONs for that (whoever decides to call it can directly
> see what he as to check before calling) or comments. But comments tend
> to become obsolete.

Uhm, I think a BUG_ON is too much here.
We could replace the check with a WARN_ON, just in case
a new function decides to call unregister_mem_sect_under_nodes() in the future.

Something like:

WARN_ON(!mem_blk)
	return;

In that case, we should get a nice splat in the logs that should tell us
who is calling it with an invalid mem_blk.

-- 
Oscar Salvador
SUSE L3
