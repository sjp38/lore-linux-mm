Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EFBBC43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 02:24:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1524120675
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 02:24:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1524120675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BF928E0003; Thu,  7 Mar 2019 21:24:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86D6E8E0002; Thu,  7 Mar 2019 21:24:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75DD78E0003; Thu,  7 Mar 2019 21:24:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 484A58E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 21:24:07 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id b6so14956546qkg.4
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 18:24:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=HFB1/hmklm0Jy3Ks9RMvEc3DUyAnT1Dy4tSZTF9cz4o=;
        b=jaAu2mvEGfcuh7ZzW00x/v77z3uUJMMtO7piYzmM5BTRPoag8ciMLOVnWPkSfH/ScG
         BYsjq3MiomlzDKHypeSHkbx3krvSWLhSr+BVfHNgbteuBNeQetyTOjO17Tnef8o2ehEp
         xMsoxs0gsZqqt3FbxupumtmxdZ6SxbvEAgId6m/cXjEjWXTWkHAVpaYI6y2pTaAVhF2S
         O0dL1c5Gx1Y2NgDHTmE9FH/w7pM4Z+GyRMfUm3chPNUaxh7uvg5G8qqFQIfPo1YWWHdb
         DS8D9U8Ndnbpba8awiL5SdZT3v19RV7JIEy48RXmpUPzFYlS/OrFA9GQqeXnBeEM2RRq
         /fLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXs8Bsh1BGjI4QYFpMgTKwAf3DGltGKED8b0wUKsk61ZRaCRzJT
	KCBffORBK+8pOvAEMkhVY/zSF3hdZJmbp8co1/pt+ItrNXhZuXTb5SSScLC9qJnFpgbiHHCT/rj
	IAfT2zAWrebO9Jh2NsVzOFBfJvvCkGKBoD/rx8IcY2E5/dNt38a6UkWHqqPfqkfcKLCIJw+gIFR
	2GxDJgVUvbmNk0ythrueLLgLzpaXJp5NQ2kl/yPnJoG+e/UUCUdNmDlNTf0uZqxujrKnPOnLps5
	O0uWOyAr0tpGXQZo7mQtayn9Mo36b68icxjfhVr7sPakiPdt2mLV8T18k5TtSFHWqwNHgaUIDsS
	GMCZ0YXoJ4zE+HbD1Ohpcx2dxPEwhogkxrN8QHOvm6kK/B7zhDICDEjUnBM+FBYDdeR0+anddHq
	Z
X-Received: by 2002:ae9:ed0c:: with SMTP id c12mr11955771qkg.306.1552011847045;
        Thu, 07 Mar 2019 18:24:07 -0800 (PST)
X-Received: by 2002:ae9:ed0c:: with SMTP id c12mr11955733qkg.306.1552011846146;
        Thu, 07 Mar 2019 18:24:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552011846; cv=none;
        d=google.com; s=arc-20160816;
        b=OnonUxvB/MZTwfITwRttRCSevyzVwNRELWb0kjIuldKC9u8U7yrIJWNpu1uBqsY8Qn
         6VnVFAxM3gpK99vbN3sds+TqvXNrmWBNlmvBDXT5jNGmfljl8BctnKYf5Z+rHxey1AGl
         RPJAaWQroH+1GQ1XmNQEsytWmlay5redy0dum5jS/HSEb2Quw1am5J+D91KCuqpJtlJk
         CcXCpRq27hsotGRI6oHsRgccKyK7pZSsGABwa/+Daxi/Z1QhOiBddREBoHJ89KVgaGlR
         RW3P/SDxND+rJKbPD529UsSvMpBZ5UU6e9no8PXkUxnOlew3RZl7x6xOfKTVpTD9gxM+
         Hjqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=HFB1/hmklm0Jy3Ks9RMvEc3DUyAnT1Dy4tSZTF9cz4o=;
        b=m1ippZm7UUXYkTyLR2PAaP+5lshIzvbwlz9ADzqynKnvQtKLpgJSxMcRwCUTXZVJrm
         37Zby+X4oO2lrANpMtY8OsKNSwp/R+02314CCY9LFvMLP2qrd9Q5cMkY88Reuz+jD/oh
         06VJyWAJFph12yZPjSYTr3QS17LTYNkLZ5NVC9u63g4thuPfcMyw3jgPFk/mqDWEIRnp
         vZbKTQPcSYCxjMN52woMh/oXMW5pzj0m9mNOYKGsVi9NS13Si+o0Gd/zuCoAHY5+jFgU
         JTIEG2yBu6FWD4c/TiUGvZsOSfXSv0oAz3bzvA8aOE0hXaTJQAW4/p2FZ+1VUXHEPAk6
         0G6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y15sor8002527qtk.69.2019.03.07.18.24.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 18:24:06 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxyR5VSZJ10NMp5R3OZz2CZl0aMWXR/whNO6r58qmBONItF91Ol3Hiusgm23h08v4UTO1SLzA==
X-Received: by 2002:aed:21cc:: with SMTP id m12mr12868000qtc.203.1552011845911;
        Thu, 07 Mar 2019 18:24:05 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id c73sm4923114qka.37.2019.03.07.18.24.04
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 18:24:05 -0800 (PST)
Date: Thu, 7 Mar 2019 21:24:02 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Nitesh Narayan Lal <nitesh@redhat.com>,
	kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
	lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
	Yang Zhang <yang.zhang.wz@gmail.com>,
	Rik van Riel <riel@surriel.com>, dodgen@google.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
Message-ID: <20190307212253-mutt-send-email-mst@kernel.org>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <CAKgT0Ud35pmmfAabYJijWo8qpucUWS8-OzBW=gsotfxZFuS9PQ@mail.gmail.com>
 <1d5e27dc-aade-1be7-2076-b7710fa513b6@redhat.com>
 <CAKgT0UdNPADF+8NMxnWuiB_+_M6_0jTt5NfoOvFN9qbPjGWNtw@mail.gmail.com>
 <2269c59c-968c-bbff-34c4-1041a2b1898a@redhat.com>
 <CAKgT0UdHkDB1vFMp7T9_pdoiuDW4qvgxhqsNztPQXrRCAmYNng@mail.gmail.com>
 <20190307134744-mutt-send-email-mst@kernel.org>
 <ebca2674-ac15-f1a9-87a4-2ee17a257e4c@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ebca2674-ac15-f1a9-87a4-2ee17a257e4c@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 08:27:32PM +0100, David Hildenbrand wrote:
> On 07.03.19 19:53, Michael S. Tsirkin wrote:
> > On Thu, Mar 07, 2019 at 10:45:58AM -0800, Alexander Duyck wrote:
> >> To that end what I think w may want to do is instead just walk the LRU
> >> list for a given zone/order in reverse order so that we can try to
> >> identify the pages that are most likely to be cold and unused and
> >> those are the first ones we want to be hinting on rather than the ones
> >> that were just freed. If we can look at doing something like adding a
> >> jiffies value to the page indicating when it was last freed we could
> >> even have a good point for determining when we should stop processing
> >> pages in a given zone/order list.
> >>
> >> In reality the approach wouldn't be too different from what you are
> >> doing now, the only real difference would be that we would just want
> >> to walk the LRU list for the given zone/order rather then pulling
> >> hints on what to free from the calls to free_one_page. In addition we
> >> would need to add a couple bits to indicate if the page has been
> >> hinted on, is in the middle of getting hinted on, and something such
> >> as the jiffies value I mentioned which we could use to determine how
> >> old the page is.
> > 
> > Do we really need bits in the page?
> > Would it be bad to just have a separate hint list?
> > 
> > If you run out of free memory you can check the hint
> > list, if you find stuff there you can spin
> > or kick the hypervisor to hurry up.
> > 
> > Core mm/ changes, so nothing's easy, I know.
> 
> We evaluated the idea of busy spinning on some bit/list entry a while
> ago. While it sounds interesting, it is usually not what we want and has
> other negative performance impacts.
> 
> Talking about "marking" pages, what we actually would want is to rework
> the buddy to skip over these "marked" pages and only really spin in case
> there are no other pages left. Allocation paths should only ever be
> blocked if OOM, not if just some hinting activity is going on on another
> VCPU.
> 
> However as you correctly say: "core mm changes". New page flag?
> Basically impossible.

Well not exactly. page bits are at a premium but only for
*allocated* pages. pages in the buddy are free and there are
some unused bits for these.

> Reuse another one? Can easily get horrbily
> confusing and can easily get rejected upstream. What about the buddy
> wanting to merge pages that are marked (assuming we also want something
> < MAX_ORDER - 1)? This smells like possibly heavy core mm changes.
> 
> Lesson learned: Avoid such heavy changes. Especially in the first shot.
> 
> The interesting thing about Nitesh's aproach right now is that we can
> easily rework these details later on. The host->guest interface will
> stay the same. Instead of temporarily taking pages out of the buddy, we
> could e.g. mark them and make the buddy or other users skip over them.
> 
> -- 
> 
> Thanks,
> 
> David / dhildenb

