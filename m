Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 611D444084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 12:36:56 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v88so25741224wrb.1
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 09:36:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m63si6714605wme.38.2017.07.10.09.36.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 09:36:55 -0700 (PDT)
Date: Mon, 10 Jul 2017 18:36:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/5] mm/memcontrol: allow to uncharge page without using
 page->lru field
Message-ID: <20170710163651.GD7071@dhcp22.suse.cz>
References: <20170703211415.11283-1-jglisse@redhat.com>
 <20170703211415.11283-5-jglisse@redhat.com>
 <20170704125113.GC14727@dhcp22.suse.cz>
 <20170705143528.GB3305@redhat.com>
 <20170710082805.GD19185@dhcp22.suse.cz>
 <20170710153222.GA4964@redhat.com>
 <20170710160444.GB7071@dhcp22.suse.cz>
 <20170710162542.GB4964@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170710162542.GB4964@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <bsingharora@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org

On Mon 10-07-17 12:25:42, Jerome Glisse wrote:
[...]
> Bottom line is that we can always free and uncharge device memory
> page just like any regular page.

OK, this answers my earlier question. Then it should be feasible to
charge this memory. There are still some things to handle. E.g. how do
we consider this memory during oom victim selection (this is not
accounted as an anonymous memory in get_mm_counter, right?), maybe others.
But the primary point is that nobody pins the memory outside of the
mapping.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
