Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0798CC4CEC5
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 16:35:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD146206A5
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 16:35:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD146206A5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A6AE6B0007; Thu, 12 Sep 2019 12:35:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5304D6B0008; Thu, 12 Sep 2019 12:35:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F73F6B000A; Thu, 12 Sep 2019 12:35:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0060.hostedemail.com [216.40.44.60])
	by kanga.kvack.org (Postfix) with ESMTP id 18B716B0007
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 12:35:30 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id A43BF1F204
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 16:35:29 +0000 (UTC)
X-FDA: 75926819178.09.land13_12bdb8cd42343
X-HE-Tag: land13_12bdb8cd42343
X-Filterd-Recvd-Size: 8112
Received: from outbound-smtp27.blacknight.com (outbound-smtp27.blacknight.com [81.17.249.195])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 16:35:28 +0000 (UTC)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp27.blacknight.com (Postfix) with ESMTPS id E6853B8B6F
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 17:35:26 +0100 (IST)
Received: (qmail 8291 invoked from network); 12 Sep 2019 16:35:26 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.19.210])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 12 Sep 2019 16:35:26 -0000
Date: Thu, 12 Sep 2019 17:35:25 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	virtio-dev@lists.oasis-open.org, kvm list <kvm@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	David Hildenbrand <david@redhat.com>,
	Dave Hansen <dave.hansen@intel.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Matthew Wilcox <willy@infradead.org>, linux-mm <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>, will@kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Oscar Salvador <osalvador@suse.de>,
	Yang Zhang <yang.zhang.wz@gmail.com>,
	Pankaj Gupta <pagupta@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Nitesh Narayan Lal <nitesh@redhat.com>,
	Rik van Riel <riel@surriel.com>, lcapitulino@redhat.com,
	"Wang, Wei W" <wei.w.wang@intel.com>,
	Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com,
	Paolo Bonzini <pbonzini@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH v9 0/8] stg mail -e --version=v9 \
Message-ID: <20190912163525.GV2739@techsingularity.net>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
 <20190910124209.GY2063@dhcp22.suse.cz>
 <CAKgT0Udr6nYQFTRzxLbXk41SiJ-pcT_bmN1j1YR4deCwdTOaUQ@mail.gmail.com>
 <20190910144713.GF2063@dhcp22.suse.cz>
 <CAKgT0UdB4qp3vFGrYEs=FwSXKpBEQ7zo7DV55nJRO2C-KCEOrw@mail.gmail.com>
 <20190910175213.GD4023@dhcp22.suse.cz>
 <1d7de9f9f4074f67c567dbb4cc1497503d739e30.camel@linux.intel.com>
 <20190911113619.GP4023@dhcp22.suse.cz>
 <CAKgT0UfOp1c+ov=3pBD72EkSB9Vm7mG5G6zJj4=j=UH7zCgg2Q@mail.gmail.com>
 <20190912091925.GM4023@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190912091925.GM4023@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 12, 2019 at 11:19:25AM +0200, Michal Hocko wrote:
> On Wed 11-09-19 08:12:03, Alexander Duyck wrote:
> > On Wed, Sep 11, 2019 at 4:36 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Tue 10-09-19 14:23:40, Alexander Duyck wrote:
> > > [...]
> > > > We don't put any limitations on the allocator other then that it needs to
> > > > clean up the metadata on allocation, and that it cannot allocate a page
> > > > that is in the process of being reported since we pulled it from the
> > > > free_list. If the page is a "Reported" page then it decrements the
> > > > reported_pages count for the free_area and makes sure the page doesn't
> > > > exist in the "Boundary" array pointer value, if it does it moves the
> > > > "Boundary" since it is pulling the page.
> > >
> > > This is still a non-trivial limitation on the page allocation from an
> > > external code IMHO. I cannot give any explicit reason why an ordering on
> > > the free list might matter (well except for page shuffling which uses it
> > > to make physical memory pattern allocation more random) but the
> > > architecture seems hacky and dubious to be honest. It shoulds like the
> > > whole interface has been developed around a very particular and single
> > > purpose optimization.
> > 
> > How is this any different then the code that moves a page that will
> > likely be merged to the tail though?
> 
> I guess you are referring to the page shuffling. If that is the case
> then this is an integral part of the allocator for a reason and it is
> very well obvious in the code including the consequences. I do not
> really like an idea of hiding similar constrains behind a generic
> looking feature which is completely detached from the allocator and so
> any future change of the allocator might subtly break it.
> 

It's not just that, compaction pokes into the free_area information as
well and directly takes pages from the free list without going through
the page allocator itself. It assumes that a free page is a free page
and only takes the zone and migratetype into account.

> > In our case the "Reported" page is likely going to be much more
> > expensive to allocate and use then a standard page because it will be
> > faulted back in. In such a case wouldn't it make sense for us to want
> > to keep the pages that don't require faults ahead of those pages in
> > the free_list so that they are more likely to be allocated?
> 
> OK, I was suspecting this would pop out. And this is exactly why I
> didn't like an idea of an external code imposing a non obvious constrains
> to the allocator. You simply cannot count with any ordering with the
> page allocator.

Indeed not. It can be arbitrary and compaction can interfere with the
ordering as well. While in theory that could be addressed by always
going through an interface maintained by the page allocator, it would be
tricky to test the virtio case in particular.

> We used to distinguish cache hot/cold pages in the past
> and pushed pages to the specific end of the free list but that has been
> removed.

That was always best effort too, not a hard guarantee. It was eventually
removed as the cost of figuring out the ordering exceeded the benefit.

> There are other potential changes like that possible. Shuffling
> is a good recent example.
> 
> Anyway I am not a maintainer of this code. I would really like to hear
> opinions from Mel and Vlastimil here (now CCed - the thread starts
> http://lkml.kernel.org/r/20190907172225.10910.34302.stgit@localhost.localdomain.

I worry that poking too much into the internal state of the allocator
will be fragile long-term. There is the arch alloc/free hooks but they
are typically about protections only and does not interfere with the
internal state of the allocator. Compaction pokes in as well but once
the page is off the free list, the page allocator no longer cares so
again there is on interference with the internal state. If the state is
interefered with externally, it becomes unclear what happens if things
like page merging is deferred in a way the allocator cannot control as
high-order allocation requests may fail for example. For THP, it would
not matter but failed allocation reports when pages are on the freelist,
but unsuitable for allocation because of the reported state, would be
hard to debug. Similarly, latency issues due to a reported page being
picked for allocation but requiring communication with the hypervisor
will be difficult to debug and atomic allocations may fail entirely.
Finally, if merging was broken for reported/unreported pages, it could
be a long time before such bugs were fixed.

That's a lot of caveats to optimise communication about unused free
pages to the allocator. I didn't read the patches particularly carefully
but it was not clear why a best effort was not made to track free pages
and if the metadata maintenance for that fills then do exhaustive
searches for remaining pages. It might be difficult to stabilise that as
the metadata may overflow again while the exhaustive search takes place.
Much would depend on the frequency that pages are entering/leaving
reported state.

-- 
Mel Gorman
SUSE Labs

