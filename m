Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5035BC10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 14:03:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08DC32084F
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 14:03:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08DC32084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66B506B000E; Tue,  9 Apr 2019 10:03:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61C246B0010; Tue,  9 Apr 2019 10:03:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E3236B0266; Tue,  9 Apr 2019 10:03:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5B76B000E
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 10:03:36 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id q21so15816018qtf.10
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 07:03:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=n26vjmHJGZ0EQn/mtrk4R3AZxBm3F/1GBg0P+TlV7oI=;
        b=ndTH03bweodMnJPzJDvQP/BDu2pFRwH74NeUm8dLm93wc5ArBK6hG8X5G66532NZHP
         BIq747PVst6E/O6i2orSLaOhDvHkgSI9c001DmXSWLuwyn4LsCmJ8Xn0h8Mzo/NA/YG0
         cjIOXP9Re3DQ6e+OejbnmvLMY9zZJKrJ5hYZub3EVzDa42viCQbM0e1yJ7AuhtJ3ObGG
         FahKKx1Usya3i/177ltUEr0+B2iRxt3hrqvN+7LU+c21zLxHgT5Yk+7s29vPJ4cNe4kg
         xtBLoe9O7jatrYTnITo7BnvznOe4swvhQMgB65jWJLIQbMp8T//2+anTX2IOuKnFFU51
         Onrg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWb7qwuDP4NWnYUaTFyLENJ17xsGQuax0VXH5KKcoYQoXKhqkqC
	/JbEB0V0s/wXFXXydb7iibyurPidUVt8PB1KGSK0RNqAt1eNzrRfg0OSYQxwsGHgTvqp0rlZod0
	WKD0DZJtfs/a3oxnR7V8Gw4k+YhO0jTJeZNsKBYjP9EoR0fpfBI7bVXQctk58QbpjvA==
X-Received: by 2002:a37:9103:: with SMTP id t3mr27822064qkd.78.1554818615857;
        Tue, 09 Apr 2019 07:03:35 -0700 (PDT)
X-Received: by 2002:a37:9103:: with SMTP id t3mr27821994qkd.78.1554818615021;
        Tue, 09 Apr 2019 07:03:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554818615; cv=none;
        d=google.com; s=arc-20160816;
        b=jLQsXDPeeqkjQ1qbicvuD6nHnUcGydbsc4dKiKHzT4DWo3ngzGzSnr+zcpXc7Sg86E
         SWRyi8A654cQh3Zhgvdo5l7fLvyyjcH5f5f5oJt2WW3+M1IBb4fuTDMgl15Yy2CcnslS
         flneYiT0pfRCx87HWnLfAwQv3Q3Ayb4Zd5r8x1fBB7Sgxf6BSTHgIQpmEU4GahYCbSU4
         L4zveC8/K5UzCPuXhUqkIbXReS4WL03aGa+hoN5qzWM3l2V0AygvKC/ok+fqZdRLm2fH
         DyX39MeyQhXw2HfgSlWKSzBbdsfaNp+zMJ0b61m568C0x9eb/wfqLCZZTv4jeLDOOs1B
         lArQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=n26vjmHJGZ0EQn/mtrk4R3AZxBm3F/1GBg0P+TlV7oI=;
        b=t5xRZw/YPwmgHYXAE69KN7E5Fm/nJDyKRqJHNyHmfhqwUBkhQXLiSc40U1w0PQyyBC
         IOt7rRPrDD2puGTGHVxSY3/fVmtfoMPZb7r8fwctu0keYP1dFJZVScqp47LMSO4DyBF0
         s6WYfNeYGdrrJqSjx1oD/G9/SfZnE8vEvgN/IftJYOzUq3gSddqjy3p3M/AdP24mfmUH
         JX72Zr2RGa8LGZdfo8LkOnuWBirJzMEPzQEBRT+enTQSCpPhTzxTfWcbD6Aw+QzxoVV0
         XE8mDEXM4umJzBK2kHh8CRkjKTT8aoTLPN/ZapkMja6KCCSDbb+eOjnIv4q6EWDWqljp
         5FeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y1sor25716911qto.21.2019.04.09.07.03.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Apr 2019 07:03:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzc4JnkNzTNbpoLwYMEr8kUgiCAkWLAYuEbgd/jcCtrBJaBybfVSx4eANHPWt/JSh5F1czjjw==
X-Received: by 2002:ac8:21bc:: with SMTP id 57mr28557365qty.51.1554818614779;
        Tue, 09 Apr 2019 07:03:34 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id v129sm18139200qka.77.2019.04.09.07.03.32
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Apr 2019 07:03:33 -0700 (PDT)
Date: Tue, 9 Apr 2019 10:03:29 -0400
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
Subject: Re: Thoughts on simple scanner approach for free page hinting
Message-ID: <20190409100258-mutt-send-email-mst@kernel.org>
References: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
 <d2413648-8943-4414-708a-9442ab4b9e65@redhat.com>
 <20190409092625-mutt-send-email-mst@kernel.org>
 <43aa1bd2-4aac-5ac4-3bd4-fe1e4a342c79@redhat.com>
 <20190409093642-mutt-send-email-mst@kernel.org>
 <f25504a0-9763-5184-7b7e-ba618c99f4a2@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f25504a0-9763-5184-7b7e-ba618c99f4a2@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 09, 2019 at 03:43:58PM +0200, David Hildenbrand wrote:
> On 09.04.19 15:37, Michael S. Tsirkin wrote:
> > On Tue, Apr 09, 2019 at 03:36:08PM +0200, David Hildenbrand wrote:
> >> On 09.04.19 15:31, Michael S. Tsirkin wrote:
> >>> On Tue, Apr 09, 2019 at 11:20:36AM +0200, David Hildenbrand wrote:
> >>>> BTW I like the idea of allocating pages that have already been hinted as
> >>>> last "choice", allocating pages that have not been hinted yet first.
> >>>
> >>> OK I guess but note this is just a small window during which
> >>> not all pages have been hinted.
> >>
> >> Yes, good point. It might sound desirable but might be completely
> >> irrelevant in practice.
> >>
> >>>
> >>> So if we actually think this has value then we need
> >>> to design something that will desist and not drop pages
> >>> in steady state too.
> >>
> >> By dropping, you mean dropping hints of e.g. MAX_ORDER - 1 or e.g. not
> >> reporting MAX_ORDER - 3?
> > 
> > I mean the issue is host unmaps the pages from guest right?  That is
> > what makes hinted pages slower than non-hinted ones.  If we do not want
> > that to happen for some pages, then either host can defer acting on the
> > hint, or we can defer hinting.
> 
> Ah right, I think what Alex mentioned is that pages processed in the
> hypervisor via MADVISE_FREE will be set RO, so the kernel can detect if
> they will actually be used again, resulting int
> 
> 1. A pagefault if written and the page(s) have not been reused by the host
> 2. A pagefault if read/written if the page(s) have been reused by the host
> 
> Now, assuming hinting is fast,  most pages will be hinted right away and
> therefore result in pagefaults. I think this is what you meant.
> 
> Deferring processing in the hypervisor cannot be done after a request
> has been marked as processed and handed back to the guest. (otherwise
> pages might already get reused)
> 
> So pages would have to "age" in the guest instead before they might be
> worth hinting. Marking pages as "Offline" alone won't help. Agreed.

Right. I don't see this as a blocker though. We can think about
strategies for addressing this after we have basic hinting
in place.

> -- 
> 
> Thanks,
> 
> David / dhildenb

