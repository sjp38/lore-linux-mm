Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D8D0C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 22:15:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA69B217F9
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 22:15:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA69B217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 695276B0005; Mon, 18 Mar 2019 18:15:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61C396B0006; Mon, 18 Mar 2019 18:15:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E4E36B0007; Mon, 18 Mar 2019 18:15:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 22ADD6B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 18:15:21 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id 35so17968336qtq.5
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 15:15:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=If9+ywFgwagAsClVwdSMCFMgYqQfuFDoWNei9/dszz8=;
        b=q88hVaXffNazxlwo47wM6drlP6FRDTlLVwc4BHw6wLZp5JwTtI3I/QrSr5/8PLw9/a
         tImt1t+1OEqWAtBaX3ibWDwNs5kAzpj9Xef5lfKzkWDxU/YMHEJW/123nQJyfmw8yMn6
         f6MidB9XAjKCf1EJTZISrlFhk+yXscjWMAXFpBWPSTWfRGUTHE/lXPT0xkRiljcpOUoW
         GUIpD0LV20Xur3RfhrlsEbQiFUSczYetoobs6K57zVakp8jNLUf8oX8aPOrVtz/YLPq0
         XSZdv2hJcaN3bHcf9zhusnzkUyd33rz48l2r13otvCKV5gpBS5gEnzti+qq7V+pE7OWm
         Vf7g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWu/eRYENC/y+N4UtfHX5SBnFxYkmg/CXeREUQbtgHyRdxlgsIW
	hCGUZq9SlV4QebJxs9vFXIedia53z7tfuLsvrjCVhiTqJmqgj8QcOBzyOHDaYPTVBXfcojKaPHl
	OFpxslswuebrT+COwtsim66TqjG2qD2R1G9DuyrTeMuRWMiQY6t2FoucBEdx56FULDw==
X-Received: by 2002:a37:642:: with SMTP id 63mr14550891qkg.216.1552947320874;
        Mon, 18 Mar 2019 15:15:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNO0OEwmfEm89hCekBJcJmcGmf9aOm92Er7flIc8ZWIwOz+qcw2hBwrx+ZuirHdgW3ZPiG
X-Received: by 2002:a37:642:: with SMTP id 63mr14550852qkg.216.1552947319879;
        Mon, 18 Mar 2019 15:15:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552947319; cv=none;
        d=google.com; s=arc-20160816;
        b=BxNoC6P30swZGc/RIMJLn/BgjWNNdghjkogFw+jAjI2K5yqbFfJRbcbx1VxgSKHC6d
         TDsCC9yGdci0JKIS5FaUBfNyjiBRKfNwwBb91TtY8p1rmtV1aLRrAXx1eqhihbqXty9v
         94BPldI2piAlNkKOiRvqLUXsudSsE/T0xLX2LpNYgFnCN++NqwZ4C9qdrpKRzUv5z/7o
         hSs8kEtdYZm8hXTu8mxzp6UuzSD+dxGvxmZoOVh9Du7/nyR3gfBqAiYDcOrw8Ro4rCM/
         XE52Fa3X4SXcAftNj+DZ+D4fOXqtQpYTENwQ8Tk9XYPzbjObqgcoO90ZIX6cFN9PvA5Z
         QPlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=If9+ywFgwagAsClVwdSMCFMgYqQfuFDoWNei9/dszz8=;
        b=X8Wi7HHJCsXyC3OUe0o63VtcP31MGCvwOs9+RsS7e/unwnSNChyaU7Hf/v85rlCbXs
         HAwunzZjPzqoH9IHhEHtZjYfQAZUFjC/WgN+oN6c8htbrixjcniNDGMz0R0Rj3VPE0UQ
         0cYDhdwGYLRzzy5tsswfOo6Hv03pzyS4gl1Ed0OmvBP62gW3s6H7vVKeXCTzsgFteQ8G
         yiryog5wHW8sTjk/uXo0om81kyO91DQOaTvWD6Wuu8iNwa7XKPU9dhDYagAdyq3qri2I
         1+6BBOPq9Rwm4XYiMCBcETK84l3ARyjwXYoFJ9FKjmhU3EplSDwLRDWS7Y4mVJRz98jH
         lTig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u4si4339067qvc.102.2019.03.18.15.15.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 15:15:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EC3234E908;
	Mon, 18 Mar 2019 22:15:18 +0000 (UTC)
Received: from redhat.com (ovpn-120-31.rdu2.redhat.com [10.10.120.31])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 12CB660FAB;
	Mon, 18 Mar 2019 22:15:17 +0000 (UTC)
Date: Mon, 18 Mar 2019 18:15:16 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-mm <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 07/10] mm/hmm: add an helper function that fault pages
 and map them to a device
Message-ID: <20190318221515.GA6664@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190129165428.3931-8-jglisse@redhat.com>
 <CAA9_cmcN+8B_tyrxRy5MMr-AybcaDEEWB4J8dstY6h0cmFxi3g@mail.gmail.com>
 <20190318204134.GD6786@redhat.com>
 <CAPcyv4he6v5JQMucezZV4J3i+Ea-i7AsaGpCOnc4f-stCrhGag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4he6v5JQMucezZV4J3i+Ea-i7AsaGpCOnc4f-stCrhGag@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Mon, 18 Mar 2019 22:15:19 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 18, 2019 at 02:30:15PM -0700, Dan Williams wrote:
> On Mon, Mar 18, 2019 at 1:41 PM Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > On Mon, Mar 18, 2019 at 01:21:00PM -0700, Dan Williams wrote:
> > > On Tue, Jan 29, 2019 at 8:55 AM <jglisse@redhat.com> wrote:
> > > >
> > > > From: Jérôme Glisse <jglisse@redhat.com>
> > > >
> > > > This is a all in one helper that fault pages in a range and map them to
> > > > a device so that every single device driver do not have to re-implement
> > > > this common pattern.
> > >
> > > Ok, correct me if I am wrong but these seem effectively be the typical
> > > "get_user_pages() + dma_map_page()" pattern that non-HMM drivers would
> > > follow. Could we just teach get_user_pages() to take an HMM shortcut
> > > based on the range?
> > >
> > > I'm interested in being able to share code across drivers and not have
> > > to worry about the HMM special case at the api level.
> > >
> > > And to be clear this isn't an anti-HMM critique this is a "yes, let's
> > > do this, but how about a more fundamental change".
> >
> > It is a yes and no, HMM have the synchronization with mmu notifier
> > which is not common to all device driver ie you have device driver
> > that do not synchronize with mmu notifier and use GUP. For instance
> > see the range->valid test in below code this is HMM specific and it
> > would not apply to GUP user.
> >
> > Nonetheless i want to remove more HMM code and grow GUP to do some
> > of this too so that HMM and non HMM driver can share the common part
> > (under GUP). But right now updating GUP is a too big endeavor.
> 
> I'm open to that argument, but that statement then seems to indicate
> that these apis are indeed temporary. If the end game is common api
> between HMM and non-HMM drivers then I think these should at least
> come with /* TODO: */ comments about what might change in the future,
> and then should be EXPORT_SYMBOL_GPL since they're already planning to
> be deprecated. They are a point in time export for a work-in-progress
> interface.

The API is not temporary it will stay the same ie the device driver
using HMM would not need further modification. Only the inner working
of HMM would be ported over to use improved common GUP. But GUP has
few shortcoming today that would be a regression for HMM:
    - huge page handling (ie dma mapping huge page not 4k chunk of
      huge page)
    - not incrementing page refcount for HMM (other user like user-
      faultd also want a GUP without FOLL_GET because they abide by
      mmu notifier)
    - support for device memory without leaking it ie restrict such
      memory to caller that can handle it properly and are fully
      aware of the gotcha that comes with it
    ...

So before converting HMM to use common GUP code under-neath those GUP
shortcoming (from HMM POV) need to be addressed and at the same time
the common dma map pattern can be added as an extra GUP helper.

The issue is that some of the above changes need to be done carefully
to not impact existing GUP users. So i rather clear some of my plate
before starting chewing on this carefully.

Also doing this patch first and then the GUP thing solve the first user
problem you have been asking for. With that code in first the first user
of the GUP convertion will be all the devices that use those two HMM
functions. In turn the first user of that code is the ODP RDMA patch
i already posted. Second will be nouveau once i tackle out some nouveau
changes. I expect amdgpu to come close third as a user and other device
driver who are working on HMM integration to come shortly after.



> > I need
> > to make progress on more driver with HMM before thinking of messing
> > with GUP code. Making that code HMM only for now will make the GUP
> > factorization easier and smaller down the road (should only need to
> > update HMM helper and not each individual driver which use HMM).
> >
> > FYI here is my todo list:
> >     - this patchset
> >     - HMM ODP
> >     - mmu notifier changes for optimization and device range binding
> >     - device range binding (amdgpu/nouveau/...)
> >     - factor out some nouveau deep inner-layer code to outer-layer for
> >       more code sharing
> >     - page->mapping endeavor for generic page protection for instance
> >       KSM with file back page
> >     - grow GUP to remove HMM code and consolidate with GUP code
> 
> Sounds workable as a plan.

