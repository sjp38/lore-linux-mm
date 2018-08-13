Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 930496B0005
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 04:55:37 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id d10-v6so12391046wrw.6
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 01:55:37 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m193-v6sor1732164wma.79.2018.08.13.01.55.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 Aug 2018 01:55:36 -0700 (PDT)
Date: Mon, 13 Aug 2018 10:55:34 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH 3/3] mm/memory_hotplug: Cleanup
 unregister_mem_sect_under_nodes
Message-ID: <20180813085534.GA1783@techadventures.net>
References: <20180810152931.23004-1-osalvador@techadventures.net>
 <20180810152931.23004-4-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180810152931.23004-4-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, dan.j.williams@intel.com, yasu.isimatu@gmail.com, jonathan.cameron@huawei.com, david@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Fri, Aug 10, 2018 at 05:29:31PM +0200, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> With the assumption that the relationship between
> memory_block <-> node is 1:1, we can refactor this function a bit.
> 
> This assumption is being taken from register_mem_sect_under_node()
> code.

Doh, this assumption is wrong for boot case when a mem_blk can have
multiple sections.

Nevertheless, I think that unregister_mem_sect_under_nodes can be polished a bit.
I am working on that

-- 
Oscar Salvador
SUSE L3
