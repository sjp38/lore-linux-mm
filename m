Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94431C49ED6
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 12:08:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 626CD2089F
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 12:08:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 626CD2089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E78BD6B0007; Wed, 11 Sep 2019 08:08:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E286F6B0008; Wed, 11 Sep 2019 08:08:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D18016B000A; Wed, 11 Sep 2019 08:08:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0228.hostedemail.com [216.40.44.228])
	by kanga.kvack.org (Postfix) with ESMTP id AF9976B0007
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 08:08:51 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 109D08243770
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 12:08:51 +0000 (UTC)
X-FDA: 75922518462.12.oil46_6a40ec9f31302
X-HE-Tag: oil46_6a40ec9f31302
X-Filterd-Recvd-Size: 5714
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 12:08:50 +0000 (UTC)
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 037D8C049D7C
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 12:08:49 +0000 (UTC)
Received: by mail-qt1-f198.google.com with SMTP id o1so23550772qtp.3
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 05:08:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to;
        bh=enh0zIvHZGYnRPPPLW+6aSKLca0Arx8DkKfrIqKoLus=;
        b=p2rFuKNRZQ1xYPvjFcnpayUxpJuy5P9he+L+HDSP9cjn8dpcIiEhik9uuRGB+vkBCC
         3Wb1VEaLo+cli0fovYUcnfGFet/Yo65xHryd/nKSGCBclF5ThEsGSDaT2qlEhaSaqTTR
         ur36LtYlRScB+WcxNY3HgIifAt93gzmexJ2sEYtdx9OzV+I8ttoGTS+vGGDbwJiBZBPW
         0H9tWlXLjiIF7xcCTkYMw/jLt2nhz4v+ppFlBbxuiWO58o+Ew8yQv5FQb3OV+aQJ1non
         IY5OkUYqXTiX+/XYomgLKiip68PcDfcdsDAZSlFPbSe2GNRCeOhf/K/jbadtGAPzAD5B
         hwIg==
X-Gm-Message-State: APjAAAV/5wegp7cOyU1Sr5OUv/ZFMge7RpwZmpPkd4VNxYAsONH42G8N
	31oENx0fVyuQ3OS4ZfelbJGkullc3zprG4l7TBkMVsSqMzD0IGZCxu2J2KgMO/845C+5urAoq3w
	0b4aHzy4xZaA=
X-Received: by 2002:ac8:3564:: with SMTP id z33mr18649578qtb.291.1568203728298;
        Wed, 11 Sep 2019 05:08:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzeft2UuPFTSdxyb4bOFOk8mjCIC7+wIdafGuW+Aj+RlGHxCc75dN/Ohnmz48toLx7v9uY0nw==
X-Received: by 2002:ac8:3564:: with SMTP id z33mr18649552qtb.291.1568203728135;
        Wed, 11 Sep 2019 05:08:48 -0700 (PDT)
Received: from redhat.com ([80.74.107.118])
        by smtp.gmail.com with ESMTPSA id x12sm8228721qtb.32.2019.09.11.05.08.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 11 Sep 2019 05:08:47 -0700 (PDT)
Date: Wed, 11 Sep 2019 08:08:38 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	virtio-dev@lists.oasis-open.org, kvm list <kvm@vger.kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	David Hildenbrand <david@redhat.com>,
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
Message-ID: <20190911080804-mutt-send-email-mst@kernel.org>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
 <20190910124209.GY2063@dhcp22.suse.cz>
 <CAKgT0Udr6nYQFTRzxLbXk41SiJ-pcT_bmN1j1YR4deCwdTOaUQ@mail.gmail.com>
 <20190910144713.GF2063@dhcp22.suse.cz>
 <CAKgT0UdB4qp3vFGrYEs=FwSXKpBEQ7zo7DV55nJRO2C-KCEOrw@mail.gmail.com>
 <20190910175213.GD4023@dhcp22.suse.cz>
 <1d7de9f9f4074f67c567dbb4cc1497503d739e30.camel@linux.intel.com>
 <20190911113619.GP4023@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190911113619.GP4023@dhcp22.suse.cz>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 11, 2019 at 01:36:19PM +0200, Michal Hocko wrote:
> On Tue 10-09-19 14:23:40, Alexander Duyck wrote:
> [...]
> > We don't put any limitations on the allocator other then that it needs to
> > clean up the metadata on allocation, and that it cannot allocate a page
> > that is in the process of being reported since we pulled it from the
> > free_list. If the page is a "Reported" page then it decrements the
> > reported_pages count for the free_area and makes sure the page doesn't
> > exist in the "Boundary" array pointer value, if it does it moves the
> > "Boundary" since it is pulling the page.
> 
> This is still a non-trivial limitation on the page allocation from an
> external code IMHO. I cannot give any explicit reason why an ordering on
> the free list might matter (well except for page shuffling which uses it
> to make physical memory pattern allocation more random) but the
> architecture seems hacky and dubious to be honest. It shoulds like the
> whole interface has been developed around a very particular and single
> purpose optimization.
> 
> I remember that there was an attempt to report free memory that provided
> a callback mechanism [1], which was much less intrusive to the internals
> of the allocator yet it should provide a similar functionality. Did you
> see that approach? How does this compares to it? Or am I completely off
> when comparing them?
> 
> [1] mostly likely not the latest version of the patchset
> http://lkml.kernel.org/r/1502940416-42944-5-git-send-email-wei.w.wang@intel.com
> 
> -- 
> Michal Hocko
> SUSE Labs

Linus nacked that one. He thinks invoking callbacks with lots of
internal mm locks is too fragile.

