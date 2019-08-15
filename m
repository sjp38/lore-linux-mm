Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E05A3C41514
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:35:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A76242083B
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:35:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A76242083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FE3B6B027A; Thu, 15 Aug 2019 15:35:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 487176B0281; Thu, 15 Aug 2019 15:35:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3501F6B0284; Thu, 15 Aug 2019 15:35:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0221.hostedemail.com [216.40.44.221])
	by kanga.kvack.org (Postfix) with ESMTP id 0F06B6B027A
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 15:35:31 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id BDC14180AD7C1
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:35:30 +0000 (UTC)
X-FDA: 75825666420.25.point04_6a48289e7c54d
X-HE-Tag: point04_6a48289e7c54d
X-Filterd-Recvd-Size: 3807
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:35:30 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8682CABBE;
	Thu, 15 Aug 2019 19:35:28 +0000 (UTC)
Date: Thu, 15 Aug 2019 21:35:26 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 2/5] kernel.h: Add non_block_start/end()
Message-ID: <20190815193526.GT9477@dhcp22.suse.cz>
References: <20190815065829.GA7444@phenom.ffwll.local>
 <20190815122344.GA21596@ziepe.ca>
 <20190815132127.GI9477@dhcp22.suse.cz>
 <20190815141219.GF21596@ziepe.ca>
 <20190815155950.GN9477@dhcp22.suse.cz>
 <20190815165631.GK21596@ziepe.ca>
 <20190815174207.GR9477@dhcp22.suse.cz>
 <20190815182448.GP21596@ziepe.ca>
 <20190815190525.GS9477@dhcp22.suse.cz>
 <20190815191810.GR21596@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815191810.GR21596@ziepe.ca>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 15-08-19 16:18:10, Jason Gunthorpe wrote:
> On Thu, Aug 15, 2019 at 09:05:25PM +0200, Michal Hocko wrote:
> 
> > This is what you claim and I am saying that fs_reclaim is about a
> > restricted reclaim context and it is an ugly hack. It has proven to
> > report false positives. Maybe it can be extended to a generic reclaim.
> > I haven't tried that. Do not aim to try it.
> 
> Okay, great, I think this has been very helpful, at least for me,
> thanks. I did not know fs_reclaim was so problematic, or the special
> cases about OOM 'reclaim'. 

I am happy that this is more clear now.

> On this patch, I have no general objection to enforcing drivers to be
> non-blocking, I'd just like to see it done with the existing lockdep
> can't sleep detection rather than inventing some new debugging for it.
> 
> I understand this means the debugging requires lockdep enabled and
> will not run in production, but I'm of the view that is OK and in line
> with general kernel practice.

Yes and I do agree with this in general.

> The last detail is I'm still unclear what a GFP flags a blockable
> invalidate_range_start() should use. Is GFP_KERNEL OK?

I hope I will not make this muddy again ;)
invalidate_range_start in the blockable mode can use/depend on any sleepable
allocation allowed in the context it is called from. So in other words
it is no different from any other function in the kernel that calls into
allocator. As the API is missing gfp context then I hope it is not
called from any restricted contexts (except from the oom which we have
!blockable for).

> Lockdep has
> complained on that in past due to fs_reclaim - how do you know if it
> is a false positive?

I would have to see the specific lockdep splat.
-- 
Michal Hocko
SUSE Labs

