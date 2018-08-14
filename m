Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 14AEB6B0003
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 05:55:03 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id j6-v6so15236630wrr.15
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 02:55:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t23-v6sor2599786wmh.29.2018.08.14.02.55.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Aug 2018 02:55:01 -0700 (PDT)
Date: Tue, 14 Aug 2018 11:55:00 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v2 3/3] mm/memory_hotplug: Refactor
 unregister_mem_sect_under_nodes
Message-ID: <20180814095500.GA6979@techadventures.net>
References: <20180813154639.19454-1-osalvador@techadventures.net>
 <20180813154639.19454-4-osalvador@techadventures.net>
 <24b69c72-0ebd-476d-1c47-9c64c24b831f@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <24b69c72-0ebd-476d-1c47-9c64c24b831f@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, jglisse@redhat.com, rafael@kernel.org, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, Jonathan.Cameron@huawei.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Tue, Aug 14, 2018 at 11:39:34AM +0200, David Hildenbrand wrote:
> On 13.08.2018 17:46, osalvador@techadventures.net wrote:
> > From: Oscar Salvador <osalvador@suse.de>
> > While at it, we can also drop the node_online() check, as a node can only be
> > offline if all the memory/cpus associated with it have been removed.
> 
> I would prefer splitting this change out into a separate patch.

Yes, I guess it is better as it is not really related to the changes in this patch.
I will wait for more feedback and I will split it up in v3.

> > +
> > +	if (unlinked_nodes)
> > +		NODEMASK_FREE(unlinked_nodes);
> 
> NODEMASK_FEEE/kfree can deal with NULL pointers.

Good point, I missed that.
I will fix it up in v3.

Thanks for reviewing.
-- 
Oscar Salvador
SUSE L3
