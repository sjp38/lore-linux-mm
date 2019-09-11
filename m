Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07B21C5ACAE
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 11:36:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1B7C20CC7
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 11:36:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1B7C20CC7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 121406B0005; Wed, 11 Sep 2019 07:36:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D22C6B0006; Wed, 11 Sep 2019 07:36:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F03B86B0007; Wed, 11 Sep 2019 07:36:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0099.hostedemail.com [216.40.44.99])
	by kanga.kvack.org (Postfix) with ESMTP id CFC696B0005
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:36:23 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 2EDDF824376E
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 11:36:23 +0000 (UTC)
X-FDA: 75922436646.02.shirt35_71e9e5566003b
X-HE-Tag: shirt35_71e9e5566003b
X-Filterd-Recvd-Size: 3762
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 11:36:22 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 038DEAD08;
	Wed, 11 Sep 2019 11:36:20 +0000 (UTC)
Date: Wed, 11 Sep 2019 13:36:19 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
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
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v9 0/8] stg mail -e --version=v9 \
Message-ID: <20190911113619.GP4023@dhcp22.suse.cz>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
 <20190910124209.GY2063@dhcp22.suse.cz>
 <CAKgT0Udr6nYQFTRzxLbXk41SiJ-pcT_bmN1j1YR4deCwdTOaUQ@mail.gmail.com>
 <20190910144713.GF2063@dhcp22.suse.cz>
 <CAKgT0UdB4qp3vFGrYEs=FwSXKpBEQ7zo7DV55nJRO2C-KCEOrw@mail.gmail.com>
 <20190910175213.GD4023@dhcp22.suse.cz>
 <1d7de9f9f4074f67c567dbb4cc1497503d739e30.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1d7de9f9f4074f67c567dbb4cc1497503d739e30.camel@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 10-09-19 14:23:40, Alexander Duyck wrote:
[...]
> We don't put any limitations on the allocator other then that it needs to
> clean up the metadata on allocation, and that it cannot allocate a page
> that is in the process of being reported since we pulled it from the
> free_list. If the page is a "Reported" page then it decrements the
> reported_pages count for the free_area and makes sure the page doesn't
> exist in the "Boundary" array pointer value, if it does it moves the
> "Boundary" since it is pulling the page.

This is still a non-trivial limitation on the page allocation from an
external code IMHO. I cannot give any explicit reason why an ordering on
the free list might matter (well except for page shuffling which uses it
to make physical memory pattern allocation more random) but the
architecture seems hacky and dubious to be honest. It shoulds like the
whole interface has been developed around a very particular and single
purpose optimization.

I remember that there was an attempt to report free memory that provided
a callback mechanism [1], which was much less intrusive to the internals
of the allocator yet it should provide a similar functionality. Did you
see that approach? How does this compares to it? Or am I completely off
when comparing them?

[1] mostly likely not the latest version of the patchset
http://lkml.kernel.org/r/1502940416-42944-5-git-send-email-wei.w.wang@intel.com

-- 
Michal Hocko
SUSE Labs

