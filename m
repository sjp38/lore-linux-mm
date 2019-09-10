Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67E80C49ED7
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 17:45:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 364012089F
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 17:45:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 364012089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAC606B0006; Tue, 10 Sep 2019 13:45:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A35A66B0007; Tue, 10 Sep 2019 13:45:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 923826B0008; Tue, 10 Sep 2019 13:45:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0036.hostedemail.com [216.40.44.36])
	by kanga.kvack.org (Postfix) with ESMTP id 6B07B6B0006
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 13:45:57 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 199478243762
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 17:45:57 +0000 (UTC)
X-FDA: 75919739154.18.leaf61_50fffa879f947
X-HE-Tag: leaf61_50fffa879f947
X-Filterd-Recvd-Size: 4125
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 17:45:56 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E89D9AD17;
	Tue, 10 Sep 2019 17:45:54 +0000 (UTC)
Date: Tue, 10 Sep 2019 19:45:53 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: virtio-dev@lists.oasis-open.org, kvm list <kvm@vger.kernel.org>,
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
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v9 3/8] mm: Move set/get_pcppage_migratetype to mmzone.h
Message-ID: <20190910174553.GC4023@dhcp22.suse.cz>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
 <20190907172528.10910.37051.stgit@localhost.localdomain>
 <20190910122313.GW2063@dhcp22.suse.cz>
 <CAKgT0Ud1xqhEy_LL4AfMgreP0uXrkF-fSDn=6uDXfn7Pvj5AAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0Ud1xqhEy_LL4AfMgreP0uXrkF-fSDn=6uDXfn7Pvj5AAw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 10-09-19 07:46:50, Alexander Duyck wrote:
> On Tue, Sep 10, 2019 at 5:23 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Sat 07-09-19 10:25:28, Alexander Duyck wrote:
> > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > >
> > > In order to support page reporting it will be necessary to store and
> > > retrieve the migratetype of a page. To enable that I am moving the set and
> > > get operations for pcppage_migratetype into the mm/internal.h header so
> > > that they can be used outside of the page_alloc.c file.
> >
> > Please describe who is the user and why does it needs this interface.
> > This is really important because migratetype is an MM internal thing and
> > external users shouldn't really care about it at all. We really do not
> > want a random code to call those, especially the set_pcppage_migratetype.
> 
> I was using it to store the migratetype of the page so that I could
> find the boundary list that contained the reported page as the array
> is indexed based on page order and migratetype. However on further
> discussion I am thinking I may just use page->index directly to index
> into the boundary array. Doing that I should be able to get a very
> slight improvement in lookup time since I am not having to pull order
> and migratetype and then compute the index based on that. In addition
> it becomes much more clear as to what is going on, and if needed I
> could add debug checks to verify the page is "Reported" and that the
> "Buddy" page type is set.

Be careful though. A free page belongs to the page allocator and it is
free to reuse any fields for its purpose so using any of them nilly
willy is no go. If you need to stuff something like that then there
better be an api the allocator is aware of. My main objection is the
abuse migrate type. There might be other ways to express what you need.
Please make sure you clearly define that though.

-- 
Michal Hocko
SUSE Labs

