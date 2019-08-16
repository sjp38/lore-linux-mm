Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36366C3A59E
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 08:27:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0BDB2077C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 08:27:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0BDB2077C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C0516B0007; Fri, 16 Aug 2019 04:27:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9705F6B0008; Fri, 16 Aug 2019 04:27:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 886846B000A; Fri, 16 Aug 2019 04:27:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0221.hostedemail.com [216.40.44.221])
	by kanga.kvack.org (Postfix) with ESMTP id 676266B0007
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 04:27:42 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 15339181AC9AE
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:27:42 +0000 (UTC)
X-FDA: 75827612364.30.jail62_8fbf45631f1d
X-HE-Tag: jail62_8fbf45631f1d
X-Filterd-Recvd-Size: 3214
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:27:41 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E376FAFC3;
	Fri, 16 Aug 2019 08:27:39 +0000 (UTC)
Date: Fri, 16 Aug 2019 10:27:38 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Feng Tang <feng.tang@intel.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Kees Cook <keescook@chromium.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Linux MM <linux-mm@kvack.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Rientjes <rientjes@google.com>, Wei Wang <wvw@google.com>,
	Daniel Vetter <daniel.vetter@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>
Subject: Re: [Intel-gfx] [PATCH 2/5] kernel.h: Add non_block_start/end()
Message-ID: <20190816082738.GC27790@dhcp22.suse.cz>
References: <20190815132127.GI9477@dhcp22.suse.cz>
 <20190815141219.GF21596@ziepe.ca>
 <20190815155950.GN9477@dhcp22.suse.cz>
 <20190815165631.GK21596@ziepe.ca>
 <20190815174207.GR9477@dhcp22.suse.cz>
 <20190815182448.GP21596@ziepe.ca>
 <20190815190525.GS9477@dhcp22.suse.cz>
 <20190815191810.GR21596@ziepe.ca>
 <20190815193526.GT9477@dhcp22.suse.cz>
 <CAKMK7uH42EgdxL18yce-7yay=x=Gb21nBs3nY7RA92Nsd-HCNA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKMK7uH42EgdxL18yce-7yay=x=Gb21nBs3nY7RA92Nsd-HCNA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 15-08-19 22:16:43, Daniel Vetter wrote:
> On Thu, Aug 15, 2019 at 9:35 PM Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > > The last detail is I'm still unclear what a GFP flags a blockable
> > > invalidate_range_start() should use. Is GFP_KERNEL OK?
> >
> > I hope I will not make this muddy again ;)
> > invalidate_range_start in the blockable mode can use/depend on any sleepable
> > allocation allowed in the context it is called from. So in other words
> > it is no different from any other function in the kernel that calls into
> > allocator. As the API is missing gfp context then I hope it is not
> > called from any restricted contexts (except from the oom which we have
> > !blockable for).
> 
> Hm, that's new to me. I thought mmu notifiers very much can be called
> from direct reclaim paths, so you have to be extremely careful with
> getting back into that one.

Correct, I should have added that notifier callbacks ideally do not
allocate any memory. They can block and even that is quite a pain to be
honest.
-- 
Michal Hocko
SUSE Labs

