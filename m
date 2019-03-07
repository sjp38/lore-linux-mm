Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD6F8C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 21:15:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52EF720675
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 21:15:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FdtsdR24"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52EF720675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA49C8E0003; Thu,  7 Mar 2019 16:15:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2C8C8E0002; Thu,  7 Mar 2019 16:15:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCCB68E0003; Thu,  7 Mar 2019 16:15:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 93D468E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 16:15:05 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id 68so13783158iov.7
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 13:15:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4kwQTfJDf2GGq+4EPc/xPnv60WmjD15BGPGOMXGyJQo=;
        b=Cm9NdM/tA1FEZ2gP2Np2tTAdUJSI0ZMTjCmZjDEjEGxF9udCzRJ4KtpYHsJYH8wb0W
         iv79Csvu53A0UU2Km0tP7D13+MWmVJBq7LUFAhr38DUxz50ZsTJP6KiwUy4y9bEJqRlq
         yGtteU55qOpyUE5+5mFxaUMJBexQIi0kTV5FvUBuZc9gtlAb2dJPR2YVrFz/B9G3S8zV
         +q4iiXBEMuaCinw1uFifIFPcK4jFzqD1kLHcYbp8D6kobg9FA3O14tlZ4M3sspx4bdKd
         M4Pa/BknkaKuyHTlGP2cpbKX/Se31A8qK/d4o3Yu9T9DmkJoiAgPAOSd4yLR/ToDqMBR
         Th6A==
X-Gm-Message-State: APjAAAXaFg0dmI6oSCPXAoqoZsRqdhGQcNx69Sr9jLUypCVhBtqPlYph
	QhPaHABKPVPzDV4IxCGjFRFTpw4M1wItTNXyhSBpHWh/LRXSLS6Nq/0gMzdOrLcZC8Q7AU6PsE5
	z/60Bj5qDDHMgK8pQ8/N2u6doApR3bTovLuZku69QJ4YlO8JtZfaI49G7CxPNN5rjpmGw7lA6Rx
	+DjVGdcUlIwrRzA/nMnoVnuTa5G/5yp1loz+WGU+xPWL9kBGOMcfrDPSBwT4+pi9nyXuB7lVdlZ
	Z7tVOeGa8SJMOOVeXPG7BNPS7FE2SVPU0abgRVZA3DdJ5rkH1zIrVhW+h3t9+zdsWa8jLvOtndN
	Dxp73Qy0A2dwWDoiKct/Te24Xefp31KXU3KRtSqZikyT0Guq8FWrsq0CWsoOpZr16uNoJrL0m/q
	j
X-Received: by 2002:a24:54c5:: with SMTP id t188mr6488783ita.58.1551993305351;
        Thu, 07 Mar 2019 13:15:05 -0800 (PST)
X-Received: by 2002:a24:54c5:: with SMTP id t188mr6488732ita.58.1551993304163;
        Thu, 07 Mar 2019 13:15:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551993304; cv=none;
        d=google.com; s=arc-20160816;
        b=McLI/Egwt7ggag3a5GxzRu/firXF5vtTl4r3nUCd6g51Q1Vr1qj0HHmTjuNjX+Pbl5
         nY4tcgBlOS2ivncoUzsn6IhaniPaEi+VA8eXLv4PYbdeJZmkIJYOhqvt8oSSKVSBHHNh
         KQ47Es7O5hCgTDKBva/RyAOAQLEoiJZT7m4sefszYWK4H/KGOVjjtqrMc9rNnASIAdFr
         d4/GWthTu7EqqYw7mle4jE9AjkZkCuSjg19hvhztueqb8TyddctLtmrYindgO3HE30xJ
         KMTcU0CwPKm9L8Hj9wg8gMD+jqn4s5dEwEHT84jqjLKsXodMetaKkpVKX0od7P9tpVUX
         oflw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4kwQTfJDf2GGq+4EPc/xPnv60WmjD15BGPGOMXGyJQo=;
        b=ck92PNngs2C/H5p96jjW3BR7aQ6F386e+IwQKlH91szp42xmrfScO9FpKKs7yclzuW
         lUXsXISIbUcj3HCBDTqDNUzFUl7pdQR/GbyV8dc7lp1dYEYLm+Qd+XOGutF9Y5Er7dBf
         VA9neayMtHfuWDxqRE/+oLljw68gBx3kmgnm3+ckLT0Quq8VZ4PyAMN0FtPclZOOAzOl
         QBgh1mkaWbmB/sS51Q8iEdj7HOdonDQ9TLZGvcX1Jly5/keJesKYpAeWmtXxezUX/nT8
         wR2l1yTL8LXfT8EoGtH7PlhZq7bx22VTUW7nE9KThzHYbWZH/jFQn/72H8ADE7wHLA91
         Be3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FdtsdR24;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c26sor2593830ioa.5.2019.03.07.13.15.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 13:15:04 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FdtsdR24;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4kwQTfJDf2GGq+4EPc/xPnv60WmjD15BGPGOMXGyJQo=;
        b=FdtsdR24Sk28iB9JIojUoGU2XQWH1ZSrJg7xlAwvOdI0fL8oePoAM9Y0fIfFXKKlYb
         RkgKU8a56dm6ii2OoTqBirOKFGGuVz6+gm5AmR6HubhyUs64AkEx79Jw8L+bTWm8hGRC
         41Am4csx1DEnDPOqOExJ8CzdVHVLWzCbdcXx3miUNrcMyEYYw8gOhVf4PpwNWT0rC+tc
         c7Crsj8THobz0SUXoQOOobDnkQrbSe5PeBgxn9ki6B9IdjMZ6TfvNo5fDPIa/yIaWDpz
         k1IgWREt7px4JptQeQGTcwZspt6IJU4z0lQ2mtrvIqBEJvVkqA54LbN86X3K7g8+5erT
         SI8A==
X-Google-Smtp-Source: APXvYqz02VverKWnZ4mSUuKRqA24qCdg7ndh+nOVzx3JlPIXPRUnrXkmqzh/ZBO3E46Ggx3HeEo1VHde+44BqMELJG0=
X-Received: by 2002:a6b:e219:: with SMTP id z25mr7425326ioc.116.1551993303724;
 Thu, 07 Mar 2019 13:15:03 -0800 (PST)
MIME-Version: 1.0
References: <20190306155048.12868-1-nitesh@redhat.com> <CAKgT0Ud35pmmfAabYJijWo8qpucUWS8-OzBW=gsotfxZFuS9PQ@mail.gmail.com>
 <1d5e27dc-aade-1be7-2076-b7710fa513b6@redhat.com> <CAKgT0UdNPADF+8NMxnWuiB_+_M6_0jTt5NfoOvFN9qbPjGWNtw@mail.gmail.com>
 <2269c59c-968c-bbff-34c4-1041a2b1898a@redhat.com> <CAKgT0UdHkDB1vFMp7T9_pdoiuDW4qvgxhqsNztPQXrRCAmYNng@mail.gmail.com>
 <20190307134744-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190307134744-mutt-send-email-mst@kernel.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 7 Mar 2019 13:14:52 -0800
Message-ID: <CAKgT0Ue=Y-6-mzqzZ+tJYvfOd4ZeK59okeZKjfJ7LHwhbdpY_w@mail.gmail.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, pagupta@redhat.com, 
	wei.w.wang@intel.com, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Rik van Riel <riel@surriel.com>, David Hildenbrand <david@redhat.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 7, 2019 at 10:53 AM Michael S. Tsirkin <mst@redhat.com> wrote:
>
> On Thu, Mar 07, 2019 at 10:45:58AM -0800, Alexander Duyck wrote:
> > To that end what I think w may want to do is instead just walk the LRU
> > list for a given zone/order in reverse order so that we can try to
> > identify the pages that are most likely to be cold and unused and
> > those are the first ones we want to be hinting on rather than the ones
> > that were just freed. If we can look at doing something like adding a
> > jiffies value to the page indicating when it was last freed we could
> > even have a good point for determining when we should stop processing
> > pages in a given zone/order list.
> >
> > In reality the approach wouldn't be too different from what you are
> > doing now, the only real difference would be that we would just want
> > to walk the LRU list for the given zone/order rather then pulling
> > hints on what to free from the calls to free_one_page. In addition we
> > would need to add a couple bits to indicate if the page has been
> > hinted on, is in the middle of getting hinted on, and something such
> > as the jiffies value I mentioned which we could use to determine how
> > old the page is.
>
> Do we really need bits in the page?
> Would it be bad to just have a separate hint list?

The issue is lists are expensive to search. If we have a single bit in
the page we can check it as soon as we have the page.

> If you run out of free memory you can check the hint
> list, if you find stuff there you can spin
> or kick the hypervisor to hurry up.

This implies you are keeping a separate list of pages for what has
been hinted on. If we are pulling pages out of the LRU list for that
it will require the zone lock to move the pages back and forth and for
higher core counts that isn't going to scale very well, and if you are
trying to pull out a page that is currently being hinted on you will
run into the same issue of having to wait for the hint to be completed
before proceeding.

> Core mm/ changes, so nothing's easy, I know.

We might be able to reuse some existing page flags. For example, there
is the PG_young and PG_idle flags that would actually be a pretty good
fit in terms of what we are looking for in behavior. We could set
PG_young when the page is initially freed, then clear it when we start
to perform the hint, and set PG_idle once the hint has been completed.

The check for if we could use a page would be pretty fast as a result
as well since if PG_young or PG_idle are set it means the page is free
to use so the check in arch_alloc_page would be pretty cheap since we
could probably test for both bits in one read.

