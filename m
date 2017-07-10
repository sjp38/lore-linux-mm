Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 202FE6B04A8
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 14:10:59 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 50so54702121qtz.3
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 11:10:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q7si11590441qtd.274.2017.07.10.11.10.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 11:10:58 -0700 (PDT)
Date: Mon, 10 Jul 2017 14:10:53 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 4/5] mm/memcontrol: allow to uncharge page without using
 page->lru field
Message-ID: <20170710181053.GD4964@redhat.com>
References: <20170703211415.11283-5-jglisse@redhat.com>
 <20170704125113.GC14727@dhcp22.suse.cz>
 <20170705143528.GB3305@redhat.com>
 <20170710082805.GD19185@dhcp22.suse.cz>
 <20170710153222.GA4964@redhat.com>
 <20170710160444.GB7071@dhcp22.suse.cz>
 <20170710162542.GB4964@redhat.com>
 <20170710163651.GD7071@dhcp22.suse.cz>
 <20170710165420.GC4964@redhat.com>
 <20170710174857.GF7071@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170710174857.GF7071@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <bsingharora@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org

On Mon, Jul 10, 2017 at 07:48:58PM +0200, Michal Hocko wrote:
> On Mon 10-07-17 12:54:21, Jerome Glisse wrote:
> > On Mon, Jul 10, 2017 at 06:36:52PM +0200, Michal Hocko wrote:
> > > On Mon 10-07-17 12:25:42, Jerome Glisse wrote:
> > > [...]
> > > > Bottom line is that we can always free and uncharge device memory
> > > > page just like any regular page.
> > > 
> > > OK, this answers my earlier question. Then it should be feasible to
> > > charge this memory. There are still some things to handle. E.g. how do
> > > we consider this memory during oom victim selection (this is not
> > > accounted as an anonymous memory in get_mm_counter, right?), maybe others.
> > > But the primary point is that nobody pins the memory outside of the
> > > mapping.
> > 
> > At this point it is accounted as a regular page would be (anonymous, file
> > or share memory). I wanted mm_counters to reflect memcg but i can untie
> > that.
> 
> I am not sure I understand. If the device memory is accounted to the
> same mm counter as the original page then it is correct. I will try to
> double check the implementation (hopefully soon).

It is accounted like the original page. By same as memcg i mean i made
the same kind of choice for mm counter than i made for memcg. It is
all in the migrate code (migrate.c) ie i don't touch any of the mm
counter when migrating page.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
