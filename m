Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08C2BC76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 04:13:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA37521019
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 04:13:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA37521019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11C546B0005; Thu, 18 Jul 2019 00:13:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CDAE6B0007; Thu, 18 Jul 2019 00:13:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED7938E0001; Thu, 18 Jul 2019 00:13:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D03FA6B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 00:13:31 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id x11so18832952qto.23
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 21:13:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=SV4rxSTVGz8T4IUkWIYI1+Xgg0JTmyIUsV7ZBNQwoIo=;
        b=rqu6bTgAI4z9IOhfmYQxfS+euGDXdvsY9cjYT9CYXAW81pZzPUKYuD/Ym2jojbXSNY
         vCOHaKpwi99brZ4+/8y7olyYb5ncLz4tKqCYqvFHhc1Kn26537WgE0IyZpt9MUBUnTSR
         lSjQC/6G5VuGyzvOc0biXA3xRRUZLsg61VXLrd0hNwT52vPqiKnPrb4Y/9G4dpl5O6gN
         R85V15FwAx49+hEiQ2vTl053NMRQPVoBP0r1yBddh/Yn3/J5++BJkJglBGKoXl0xl2tL
         hIixUFG6mt3AmVdhqjlKz6FyDQWnxcPQF7RLJ3mB+EmoM4YJoX97Fsvh2BwEESRYq0bQ
         ht8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW4s44s9Vt+4fhgo/qj0rkgkGAlLqTddvZ/7q1fLB0Yqx64VJxp
	OZlzSDg+iWblJ9R9oHnmImGNj17mxtZijquE2dj6VuYsTVcCapkxYyiVfLElB5VdDZaPoVOOuye
	RU+G0vPCtab6Hv5MxkaA69Qmfhuv9Hz/qbMRbC9Jx+jDGEffZbXJ3m0eKFkRRaNlovg==
X-Received: by 2002:ac8:24e3:: with SMTP id t32mr30543084qtt.104.1563423211565;
        Wed, 17 Jul 2019 21:13:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5L7a91GqjiKB5LyNPmktRAINRFUKZKQ+iGhcTZPu1JpMBeVR+FBQJwlUswFEvRS4NIsMb
X-Received: by 2002:ac8:24e3:: with SMTP id t32mr30543057qtt.104.1563423210803;
        Wed, 17 Jul 2019 21:13:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563423210; cv=none;
        d=google.com; s=arc-20160816;
        b=cRzbztov7cpjkY2aq2NiDLT1uT/cVxY4QiSQ7LVBuIKcMwGAbZOZgXb5WHJa4ushdk
         5gDmsFXgXvHNQN9CjGHZpkSMDARpf6KHU7SlqFo26RpwDDCYpNuhUmswAD0cz9e1URRI
         lTKpYqfDlUT/fSxOtPCog1xHkHhzed+uiNdWYtiJGwSFnhYf6+retIalMR5tpDMnt80k
         tNSSBBO5ltG6L0UoYNU1NG1K/gRM8CefVyFFmeZaoIW+SvGox2PLrro4UA4iFqDlAV3s
         9aSHYJJkm0yOMyLix4VLx7u8ADN75zGWb+CYsLKCWh10MvFEXQiDodE4dVTGkAwr8pTZ
         /g9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=SV4rxSTVGz8T4IUkWIYI1+Xgg0JTmyIUsV7ZBNQwoIo=;
        b=onMRzp8PNJgKHtLEOrLRjAmqpZMAkaxpI0YWeXuCSA4X2mKEo81bJm+CX5gErL04oZ
         5m9rUFWakPMkYufIHaw7kpQqKiiMvR0GB9gJSBnYmJp7o20se6tar5aJanP/1DRHGk9l
         WJyxrXrmU0e6xgQc6EtpybFvogMa6lkTXRID3ihtoupnR8znkyXkxCSE+7p03qT7eNYv
         xuZnBKEWH/FRC2VpM0ATURX+H3nRDd+n+NRlbx86Dqye22+3MM0PkBUgCC1RseX5/MG0
         t20KWaVwHGf5Y6QumnepbEP8rQ8D1/bfGMD6NCt3H4S0rHepVqQ+vrE7EFdDXlTNxzFw
         Vibg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v65si16421003qki.214.2019.07.17.21.13.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 21:13:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9E1FFC053B34;
	Thu, 18 Jul 2019 04:13:29 +0000 (UTC)
Received: from redhat.com (ovpn-120-147.rdu2.redhat.com [10.10.120.147])
	by smtp.corp.redhat.com (Postfix) with SMTP id 1D7AC600D1;
	Thu, 18 Jul 2019 04:13:16 +0000 (UTC)
Date: Thu, 18 Jul 2019 00:13:15 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: "Wang, Wei W" <wei.w.wang@intel.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Nitesh Narayan Lal <nitesh@redhat.com>,
	kvm list <kvm@vger.kernel.org>,
	David Hildenbrand <david@redhat.com>,
	"Hansen, Dave" <dave.hansen@intel.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Yang Zhang <yang.zhang.wz@gmail.com>,
	"pagupta@redhat.com" <pagupta@redhat.com>,
	Rik van Riel <riel@surriel.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"lcapitulino@redhat.com" <lcapitulino@redhat.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Subject: Re: use of shrinker in virtio balloon free page hinting
Message-ID: <20190718000434-mutt-send-email-mst@kernel.org>
References: <20190717071332-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F73E16D4B2@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <286AC319A985734F985F78AFA26841F73E16D4B2@shsmsx102.ccr.corp.intel.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 18 Jul 2019 04:13:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 03:46:57PM +0000, Wang, Wei W wrote:
> On Wednesday, July 17, 2019 7:21 PM, Michael S. Tsirkin wrote:
> > 
> > Wei, others,
> > 
> > ATM virtio_balloon_shrinker_scan will only get registered when deflate on
> > oom feature bit is set.
> > 
> > Not sure whether that's intentional. 
> 
> Yes, we wanted to follow the old oom behavior, which allows the oom notifier
> to deflate pages only when this feature bit has been negotiated.

It makes sense for pages in the balloon (requested by hypervisor).
However free page hinting can freeze up lots of memory for its own
internal reasons. It does not make sense to ask hypervisor
to set flags in order to fix internal guest issues.

> > Assuming it is:
> > 
> > virtio_balloon_shrinker_scan will try to locate and free pages that are
> > processed by host.
> > The above seems broken in several ways:
> > - count ignores the free page list completely
> 
> Do you mean virtio_balloon_shrinker_count()? It just reports to
> do_shrink_slab the amount of freeable memory that balloon has.
> (vb->num_pages and vb->num_free_page_blocks are all included )

Right. But that does not include the pages in the hint vq,
which could be a significant amount of memory.


> > - if free pages are being reported, pages freed
> >   by shrinker will just get re-allocated again
> 
> fill_balloon will re-try the allocation after sleeping 200ms once allocation fails.

Even if ballon was never inflated, if shrinker frees some memory while
we are hinting, hint vq will keep going and allocate it back without
sleeping.

>  
> > I was unable to make this part of code behave in any reasonable way - was
> > shrinker usage tested? What's a good way to test that?
> 
> Please see the example that I tested before : https://lkml.org/lkml/2018/8/6/29
> (just the first one: *1. V3 patches)
> 
> What problem did you see?
> I just tried the latest code, and find ballooning reports a #GP (seems caused by
> 418a3ab1e). 
> I'll take a look at the details in the office tomorrow.
> 
> Best,
> Wei

I saw that VM hangs. Could be the above problem, let me know how it
goes.

