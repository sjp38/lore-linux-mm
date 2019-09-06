Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 483BCC00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 17:33:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E620D206A1
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 17:33:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="B5lMPpGH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E620D206A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E6426B0005; Fri,  6 Sep 2019 13:33:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7982B6B0006; Fri,  6 Sep 2019 13:33:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 685376B0007; Fri,  6 Sep 2019 13:33:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0056.hostedemail.com [216.40.44.56])
	by kanga.kvack.org (Postfix) with ESMTP id 4857E6B0005
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 13:33:56 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D4330824CA3B
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 17:33:55 +0000 (UTC)
X-FDA: 75905193630.21.range10_223049ba24b25
X-HE-Tag: range10_223049ba24b25
X-Filterd-Recvd-Size: 4106
Received: from mail-oi1-f193.google.com (mail-oi1-f193.google.com [209.85.167.193])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 17:33:54 +0000 (UTC)
Received: by mail-oi1-f193.google.com with SMTP id h4so5587583oih.8
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 10:33:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qpDnR/GYJ/XrBLmzSIYUWPDpRlqXVwU8hq/PPEapHXQ=;
        b=B5lMPpGHxIofgZL10Pn92uDG8MnE3nHQtXDzubuDNUxCRt56k31Zr5/4pBbkv4ywfp
         k2B9yLhvs+CQZolGYvrtvi/f3xzxDtXhUuaaFUh5Dvv21CfjE/LNyLRZb+x7i5PmiS1D
         ZIUPTbM+K/3hH0G5jF0Ehvp/Yz/ZSAz34z7I9miMnRsfe9zcMJiYCJBadW8maOBNVufF
         LcFtXZOm1s1HhJLXNF5PKER+f1vQe8CZv1SdFAlPsTrPBHjyL4m5sSnEEtuWzr+dME/d
         yPglC9Vp78a/MAqamkHBU5HxSM1bZk6G1BF35zRlxhELkYuQGhMHkWrK/kqOJOKhXYXT
         WCAQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=qpDnR/GYJ/XrBLmzSIYUWPDpRlqXVwU8hq/PPEapHXQ=;
        b=ArhvuVbRTI4EElWho6dhn37QfgrmrL4plGjl4O4bnLDVrJ1KXxDoTwRhyqnZmi6k1v
         shIgGKx8S09QDqMH1bM3XLIRNV1aG4dn1q4QYYjU6X/A3aOrMBrT+PwBMman13klhUtb
         GDSJMJ5X8zi10XflMRebowX79+77wlvSUjlj7JSA7zw91Z5yAfYJYmRR3f2S31PzuryC
         VL/uOWO4aXgbFgYCbxJn5fOv/sgHMlNUo8V/upNjn8ka3mq+ZWhwe3o/i0I7EF+4MrXX
         /1mSxM3Jjtxb74ic0k4f6m4E1fqwg/8uShc19lK1JE3Qmd/y4cdwp2IkCei+IdXWqi1d
         NV9Q==
X-Gm-Message-State: APjAAAVQqPtwsevotwm/2cYkN+/oe6Rdth3D43PpR+EpaCVtKHSNaNxB
	zPl8tOkkFs1iY8mJE1jzl+xCKOkdfzdKhRNhOH9psA==
X-Google-Smtp-Source: APXvYqxs26WaI4nMH81FCrmErnLZVB0v+f8/lt+3MTncxWG87yVQW0BSOxASyAFc+69JKSrfI3WlFVqe6CUueDct1rs=
X-Received: by 2002:aca:5dc3:: with SMTP id r186mr7672240oib.73.1567791233988;
 Fri, 06 Sep 2019 10:33:53 -0700 (PDT)
MIME-Version: 1.0
References: <20190906145213.32552.30160.stgit@localhost.localdomain> <20190906145327.32552.39455.stgit@localhost.localdomain>
In-Reply-To: <20190906145327.32552.39455.stgit@localhost.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 6 Sep 2019 10:33:42 -0700
Message-ID: <CAPcyv4i_LPrYvenhzcM_Ji6nviZWHqTDWQDDusv5pCXv0Bi7QA@mail.gmail.com>
Subject: Re: [PATCH v8 1/7] mm: Add per-cpu logic to page shuffling
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: nitesh@redhat.com, KVM list <kvm@vger.kernel.org>, 
	"Michael S. Tsirkin" <mst@redhat.com>, David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, virtio-dev@lists.oasis-open.org, 
	Oscar Salvador <osalvador@suse.de>, yang.zhang.wz@gmail.com, 
	Pankaj Gupta <pagupta@redhat.com>, Rik van Riel <riel@surriel.com>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com, 
	"Wang, Wei W" <wei.w.wang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 6, 2019 at 7:53 AM Alexander Duyck
<alexander.duyck@gmail.com> wrote:
>
> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>
> Change the logic used to generate randomness in the suffle path so that we
> can avoid cache line bouncing. The previous logic was sharing the offset
> and entropy word between all CPUs. As such this can result in cache line
> bouncing and will ultimately hurt performance when enabled.
>
> To resolve this I have moved to a per-cpu logic for maintaining a unsigned
> long containing some amount of bits, and an offset value for which bit we
> can use for entropy with each call.
>

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

