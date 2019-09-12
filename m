Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D02CECDE2A
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 07:16:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD34021479
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 07:16:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD34021479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28EC06B0003; Thu, 12 Sep 2019 03:16:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 218206B0005; Thu, 12 Sep 2019 03:16:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DFB06B0006; Thu, 12 Sep 2019 03:16:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0201.hostedemail.com [216.40.44.201])
	by kanga.kvack.org (Postfix) with ESMTP id DA9996B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 03:16:37 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 77317181AC9BF
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 07:16:37 +0000 (UTC)
X-FDA: 75925410834.11.trade66_56de84b6be159
X-HE-Tag: trade66_56de84b6be159
X-Filterd-Recvd-Size: 4160
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 07:16:36 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DA634AE35;
	Thu, 12 Sep 2019 07:16:34 +0000 (UTC)
Date: Thu, 12 Sep 2019 09:16:33 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	virtio-dev@lists.oasis-open.org, kvm list <kvm@vger.kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
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
Message-ID: <20190912071633.GL4023@dhcp22.suse.cz>
References: <20190911113619.GP4023@dhcp22.suse.cz>
 <20190911080804-mutt-send-email-mst@kernel.org>
 <20190911121941.GU4023@dhcp22.suse.cz>
 <20190911122526.GV4023@dhcp22.suse.cz>
 <4748a572-57b3-31da-0dde-30138e550c3a@redhat.com>
 <20190911125413.GY4023@dhcp22.suse.cz>
 <736594d6-b9ae-ddb9-2b96-85648728ef33@redhat.com>
 <20190911132002.GA4023@dhcp22.suse.cz>
 <20190911135100.GC4023@dhcp22.suse.cz>
 <abea20a0-463c-68c0-e810-2e341d971b30@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <abea20a0-463c-68c0-e810-2e341d971b30@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 11-09-19 18:09:18, David Hildenbrand wrote:
> On 11.09.19 15:51, Michal Hocko wrote:
> > On Wed 11-09-19 15:20:02, Michal Hocko wrote:
> > [...]
> >>> 4. Continuously report, not the "one time report everything" approach.
> >>
> >> So you mean the allocator reporting this rather than an external code to
> >> poll right? I do not know, how much this is nice to have than must have?
> > 
> > Another idea that I haven't really thought through so it might turned
> > out to be completely bogus but let's try anyway. Your "report everything"
> > just made me look and realize that free_pages_prepare already performs
> > stuff that actually does something similar yet unrelated.
> > 
> > We do report to special page poisoning, zeroying or
> > CONFIG_DEBUG_PAGEALLOC to unmap the address from the kernel address
> > space. This sounds like something fitting your model no?
> > 
> 
> AFAIKS, the poisoning/unmapping is done whenever a page is freed. I
> don't quite see yet how that would help to remember if a page was
> already reported.

Do you still have to differ that state when each page is reported?

> After reporting the page we would have to switch some
> state (Nitesh: bitmap bit, Alexander: page flag) to identify that.

Yes, you can either store the state somewhere.

> Of course, we could map the page and treat that as "the state" when we
> reported it, but I am not sure that's such a good idea :)
> 
> As always, I might be very wrong ...

I still do not fully understand the usecase so I might be equally wrong.
My thinking is along these lines. Why should you scan free pages when
you can effectively capture each freed page? If you go one step further
then post_alloc_hook would be the counterpart to know that your page has
been allocated.
-- 
Michal Hocko
SUSE Labs

