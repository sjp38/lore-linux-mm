Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52A2EC3A59E
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 12:12:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C37021655
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 12:12:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="K074sQzn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C37021655
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87B3B6B0007; Fri, 16 Aug 2019 08:12:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82B9E6B0008; Fri, 16 Aug 2019 08:12:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 719D16B000A; Fri, 16 Aug 2019 08:12:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0107.hostedemail.com [216.40.44.107])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6216B0007
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:12:46 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id E314183FD
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:12:45 +0000 (UTC)
X-FDA: 75828179490.30.bun52_5246e91cf1812
X-HE-Tag: bun52_5246e91cf1812
X-Filterd-Recvd-Size: 6529
Received: from mail-qk1-f195.google.com (mail-qk1-f195.google.com [209.85.222.195])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:12:45 +0000 (UTC)
Received: by mail-qk1-f195.google.com with SMTP id g17so4470195qkk.8
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 05:12:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=f8owW6EpsmwqtLp0wnKoaaaHq0YX1Y+Qi9vsJyda86Q=;
        b=K074sQzn3mritfVn1vyEO1cFfN4Z/ArjoqUauJv0wy+G786US9n9P1vD6X+hiV1Vue
         L0iagywjGWWTZJw6Cr1uKClGUTmJNRFC0EnNA4S2RzUw1XQITq5bgXlU8QfF9Q1zWEpN
         E/SpAFJNq+LhHWZ6WCWF9IBawfG7nYtybEgTo75npLEVQ4H8CyhvMH07dKg73copwI/H
         49E1Y6LZ7PzsHJQmnVyw6vril9S6p1AoL+AptSIhY//od14+Os1BKic/sqw8uQRF2Ok5
         LUzGaTuogV45oW5ff012FxSlHjSnKsqN0UJflMgirTuKBXN0Mi0YoWcPVVjNtE7iJrIx
         7Esw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=f8owW6EpsmwqtLp0wnKoaaaHq0YX1Y+Qi9vsJyda86Q=;
        b=iL01hv8BvEntyf6495CKMAmVupdW+mRypwmQ8cBdazk6mcsisJ4c8MtH0nX5WGIN1c
         UuFDja0cLzMVZ+6OcZOJW9IBnw2qjsbHoYCvx3nlR5ZVVxr75nDNYVuakYK4rk+tA1Y+
         3MEcg1h232csXaQQxZFGCkW4EA4CoekRDDly3JpxHhjaKyiI8a8iCrNufbq70xMzNtAi
         1Zt2jAQPQQ7keoZulRaalxBUs/MxKojnNuRbeckTxtt8L4W2b9I7OzsX30weIhvKWbKv
         pc0PFI630s4KDhaXjLNvtqmMulTwXxLYCQU3lB2biv6cJAbopL5eXZQZgpxfKOWQsjrE
         uk4Q==
X-Gm-Message-State: APjAAAXqJapa1pHZdvWS3bAHS0LQ7g+X/BOnNsxp/jvv8+Yhk/zNzc0/
	W4Ka/38JWua0v3TpZDVDd0K2yQ==
X-Google-Smtp-Source: APXvYqyMUeYBXW9fbIGoraU2yLXj1zbNq04/jEsVRBfsR3GdBF63NEaqNn9Gsb89FRfUafPCrlPTew==
X-Received: by 2002:a05:620a:15eb:: with SMTP id p11mr7740939qkm.23.1565957564536;
        Fri, 16 Aug 2019 05:12:44 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id r4sm3294200qta.93.2019.08.16.05.12.43
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 16 Aug 2019 05:12:43 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hyb63-0001mf-6H; Fri, 16 Aug 2019 09:12:43 -0300
Date: Fri, 16 Aug 2019 09:12:43 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: Michal Hocko <mhocko@kernel.org>, Feng Tang <feng.tang@intel.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Kees Cook <keescook@chromium.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Linux MM <linux-mm@kvack.org>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Rientjes <rientjes@google.com>, Wei Wang <wvw@google.com>,
	Daniel Vetter <daniel.vetter@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>
Subject: Re: [Intel-gfx] [PATCH 2/5] kernel.h: Add non_block_start/end()
Message-ID: <20190816121243.GB5398@ziepe.ca>
References: <20190815174207.GR9477@dhcp22.suse.cz>
 <20190815182448.GP21596@ziepe.ca>
 <20190815190525.GS9477@dhcp22.suse.cz>
 <20190815191810.GR21596@ziepe.ca>
 <20190815193526.GT9477@dhcp22.suse.cz>
 <CAKMK7uH42EgdxL18yce-7yay=x=Gb21nBs3nY7RA92Nsd-HCNA@mail.gmail.com>
 <20190815202721.GV21596@ziepe.ca>
 <CAKMK7uER0u1TqeJBXarKakphnyZTHOmedOfXXqLGVDE2mE-mAQ@mail.gmail.com>
 <20190816010036.GA9915@ziepe.ca>
 <CAKMK7uH0oa10LoCiEbj1NqAfWitbdOa-jQm9hM=iNL-=8gH9nw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKMK7uH0oa10LoCiEbj1NqAfWitbdOa-jQm9hM=iNL-=8gH9nw@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 08:20:55AM +0200, Daniel Vetter wrote:
> On Fri, Aug 16, 2019 at 3:00 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > On Thu, Aug 15, 2019 at 10:49:31PM +0200, Daniel Vetter wrote:
> > > On Thu, Aug 15, 2019 at 10:27 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > > > On Thu, Aug 15, 2019 at 10:16:43PM +0200, Daniel Vetter wrote:
> > > > > So if someone can explain to me how that works with lockdep I can of
> > > > > course implement it. But afaics that doesn't exist (I tried to explain
> > > > > that somewhere else already), and I'm no really looking forward to
> > > > > hacking also on lockdep for this little series.
> > > >
> > > > Hmm, kind of looks like it is done by calling preempt_disable()
> > >
> > > Yup. That was v1, then came the suggestion that disabling preemption
> > > is maybe not the best thing (the oom reaper could still run for a long
> > > time comparatively, if it's cleaning out gigabytes of process memory
> > > or what not, hence this dedicated debug infrastructure).
> >
> > Oh, I'm coming in late, sorry
> >
> > Anyhow, I was thinking since we agreed this can trigger on some
> > CONFIG_DEBUG flag, something like
> >
> >     /* This is a sleepable region, but use preempt_disable to get debugging
> >      * for calls that are not allowed to block for OOM [.. insert
> >      * Michal's explanation.. ] */
> >     if (IS_ENABLED(CONFIG_DEBUG_ATOMIC_SLEEP) && !mmu_notifier_range_blockable(range))
> >         preempt_disable();
> >     ops->invalidate_range_start();
> 
> I think we also discussed that, and some expressed concerns it would
> change behaviour/timing too much for testing. Since this does does
> disable preemption for real, not just for might_sleep.

I don't follow, this is a debug kernel, it will have widly different
timing. 

Further the point of this debugging on atomic_sleep is to be as
timing-independent as possible since functions with rare sleeps should
be guarded by might_sleep() in their common paths.

I guess I don't get the push to have some low overhead debugging for
this? Is there something special you are looking for?

Jason

