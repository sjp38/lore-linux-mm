Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAEC1C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 17:38:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E66222BE8
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 17:38:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E66222BE8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 212286B0007; Thu, 25 Jul 2019 13:38:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C4696B0008; Thu, 25 Jul 2019 13:38:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B27D8E0002; Thu, 25 Jul 2019 13:38:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C6B2C6B0007
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 13:38:51 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h27so31310342pfq.17
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 10:38:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=woJeegttPhl/BrIdINSAcvtDPD0ZMfAjhY6NEqJcXMA=;
        b=bwgAnQoWWAtd4i4nhQkR+SFtC60//SijEsLXIUT6HwJLxyQyGyZgNKcl82bEAQP54V
         zCFkjChrEt55iElCPi2+SbutLQAHWJEw3nCYU4NeI9kqGW2EyN3T0MOb874ll0F3eoKf
         uBXauHcL76n6nBHt216OspexuUB2oi3INkGipgTV+TxA290CaTAHMevqygq55G93AD7m
         tm9Uj7G+2Gz/ocODdKi3WYct5akKLh+NBO/3XgIh9aDip2xypWDaDFb6bGzAIvSILEYI
         3Ewd3fSOtuizzWoVg/74bhfgZYDJRaJrOUAsPGc5FmNQ1KSyPSOgHvqBDUqcwnFzfpMN
         CkoA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUfe/PkSJpHD8DmqZKOl5jEDSujZ4HoALSwD/YuFfxQIluAyGDC
	4oPNqWT7d9zD2fdIZO1VRprbSh39oQHWG6y6tPx/HMR0u63rVJ8oEENFezmiUbhhKevz+qNhSz9
	ev4cyCgDbiPYT5e+O6VbjspjaWqa63gXCKi8n/r34KaMk0fwgAdYZz1v1j8+uFn6U8g==
X-Received: by 2002:a62:8246:: with SMTP id w67mr18265113pfd.226.1564076331447;
        Thu, 25 Jul 2019 10:38:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/s92RSnX8+jmZ1+bkMkile/Y+5BKN7mDU8BmLFhjC1u5E8RezjzktnJkPlnoTJ+qBmsVr
X-Received: by 2002:a62:8246:: with SMTP id w67mr18265068pfd.226.1564076330730;
        Thu, 25 Jul 2019 10:38:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564076330; cv=none;
        d=google.com; s=arc-20160816;
        b=Sofraf6AOjU0Y9C1nDb/woMi1F6jLF1D8+f0t0Z1Xqtc74KtFVgtuLG2KnNFBJ6kBN
         oLvX3Hhbd3gBA+134+R4bOY3pqJGQEtqa5XwtH5xsoeGmDCKwELQ+EpkSb7GMc9yo7nG
         8zOOoObHRi1wKG/dEuh8OemMcCQwC+M3P4Qlm/G/dg/X000yVBIpj2jmWOyCVCCW3Pm8
         ZJ8lTce2oInO2Kz5L1Lu0b/2jIcADEmZWt38Mi6oTZw3oaT41qmxylDwKfiRp+IIAgQv
         gAJaSVEpdGHrOnduyTcNB3YhnOBVLh+dHWS0H5o8Oa1T0VHmf0xuS6dwuf7esNfKrW2J
         v1OA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=woJeegttPhl/BrIdINSAcvtDPD0ZMfAjhY6NEqJcXMA=;
        b=Z6KW7LTa2KTmZNxilp4QASH9msN9nQh7hRSYlGE/GJ0dpgHJ8laUKy5eOifjGqWTXV
         u+gb7h90HJMdZIDfXn2rwFgptOnhhVc7qkeP3RfPPpvp+A9qhZrxaksDdGPUbOH43oeX
         /lyqG9d7fKFeN9zbSjaI24Vd1RmVYcw6P+7/glmg3UEBwMjYRXRLdV+CuxfsZzTaYYBb
         vor03zmezGfBCgNPgVCxHOiuZlm2SXcomfsWvXnveao/cs9Gr97YpisTaDJ96dLY+gb+
         5BInx9vtXDm77ONd5K6N5UhXHy75CJ7Hl0sS2H7XQ73450mwSi0osMcad2T79rcCAJWe
         A/oQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id v13si18847650pgb.554.2019.07.25.10.38.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 10:38:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jul 2019 10:38:50 -0700
X-IronPort-AV: E=Sophos;i="5.64,307,1559545200"; 
   d="scan'208";a="164251652"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga008-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jul 2019 10:38:49 -0700
Message-ID: <b3568a5422d0f6b88f7c5cb46577db1a43057c04.camel@linux.intel.com>
Subject: Re: [PATCH v2 4/5] mm: Introduce Hinted pages
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: David Hildenbrand <david@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
 "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew
 Morton <akpm@linux-foundation.org>, Yang Zhang <yang.zhang.wz@gmail.com>, 
 pagupta@redhat.com, Rik van Riel <riel@surriel.com>, Konrad Rzeszutek Wilk
 <konrad.wilk@oracle.com>, lcapitulino@redhat.com, wei.w.wang@intel.com,
 Andrea Arcangeli <aarcange@redhat.com>, Paolo Bonzini
 <pbonzini@redhat.com>, dan.j.williams@intel.com,  Matthew Wilcox
 <willy@infradead.org>
Date: Thu, 25 Jul 2019 10:38:49 -0700
In-Reply-To: <f0ac7747-0e18-5039-d341-5dfda8d5780e@redhat.com>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
	 <20190724170259.6685.18028.stgit@localhost.localdomain>
	 <a9f52894-52df-cd0c-86ac-eea9fbe96e34@redhat.com>
	 <CAKgT0Ud-UNk0Mbef92hDLpWb2ppVHsmd24R9gEm2N8dujb4iLw@mail.gmail.com>
	 <f0ac7747-0e18-5039-d341-5dfda8d5780e@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-07-25 at 18:48 +0200, David Hildenbrand wrote:
> On 25.07.19 17:59, Alexander Duyck wrote:
> > On Thu, Jul 25, 2019 at 1:53 AM David Hildenbrand <david@redhat.com> wrote:
> > > On 24.07.19 19:03, Alexander Duyck wrote:
> > > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 

<snip>

> > > Can't we reuse one of the traditional page flags for that, not used
> > > along with buddy pages? E.g., PG_dirty: Pages that were not hinted yet
> > > are dirty.
> > 
> > Reusing something like the dirty bit would just be confusing in my
> > opinion. In addition it looks like Xen has also re-purposed PG_dirty
> > already for another purpose.
> 
> You brought up waste page management. A dirty bit for unprocessed pages
> fits perfectly in this context. Regarding XEN, as long as it's not used
> along with buddy pages, no issue.

I would rather not have to dirty all pages that aren't hinted. That starts
to get too invasive. Ideally we only modify pages if we are hinting on
them. That is why I said I didn't like the use of a dirty bit. What we
want is more of a "guaranteed clean" bit.

> FWIW, I don't even thing PG_offline matches to what you are using it
> here for. The pages are not logically offline. They were simply buddy
> pages that were hinted. (I'd even prefer a separate page type for that
> instead - if we cannot simply reuse one of the other flags)
> 
> "Offline pages" that are not actually offline in the context of the
> buddy is way more confusing.

Right now offline and hinted are essentially the same thing since the
effect is identical.

There may be cases in the future where that is not the case, but with the
current patch set they both result in the pages being evicted from the
guest.

> > If anything I could probably look at seeing if the PG_private flags
> > are available when a page is in the buddy allocator which I suspect
> > they probably are since the only users I currently see appear to be
> > SLOB and compound pages. Either that or maybe something like PG_head
> > might make sense since once we start allocating them we are popping
> > the head off of the boundary list.
> 
> Would also be fine with me.

Actually I may have found an even better bit if we are going with the
"reporting" name. I could probably use "PG_uptodate" since it looks like
most of its uses are related to filesystems. I will wait till I hear from
Matthew on what bits would be available for use before I update things.

