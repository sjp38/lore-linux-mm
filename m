Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0006C6B000A
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 05:36:54 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id z16-v6so14860164wrs.22
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 02:36:54 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p6-v6sor2443260wmh.17.2018.08.14.02.36.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Aug 2018 02:36:53 -0700 (PDT)
Date: Tue, 14 Aug 2018 11:36:52 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v2 2/3] mm/memory_hotplug: Drop mem_blk check from
 unregister_mem_sect_under_nodes
Message-ID: <20180814093652.GA6878@techadventures.net>
References: <20180813154639.19454-1-osalvador@techadventures.net>
 <20180813154639.19454-3-osalvador@techadventures.net>
 <82148bc6-672d-6610-757f-d910a17d23c6@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <82148bc6-672d-6610-757f-d910a17d23c6@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, jglisse@redhat.com, rafael@kernel.org, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, Jonathan.Cameron@huawei.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Tue, Aug 14, 2018 at 11:30:51AM +0200, David Hildenbrand wrote:

> 
> While it is correct in current code, I wonder if this sanity check
> should stay. I would completely agree if it would be a static function.

Hi David,

Well, unregister_mem_sect_under_nodes() __only__ gets called from remove_memory_section().
But remove_memory_section() only calls unregister_mem_sect_under_nodes() IFF mem_blk
is not NULL:

static int remove_memory_section
{
	...
	mem = find_memory_block(section);
	if (!mem)
		goto out_unlock;

	unregister_mem_sect_under_nodes(mem, __section_nr(section));
	...
}

So, to me keeping the check is redundant, as we already check for it before calling in.

Thanks
-- 
Oscar Salvador
SUSE L3
