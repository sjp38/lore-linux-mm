Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A617C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 15:33:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD49821951
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 15:33:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD49821951
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 681AB8E0002; Wed, 24 Jul 2019 11:33:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 632686B000E; Wed, 24 Jul 2019 11:33:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FA608E0002; Wed, 24 Jul 2019 11:33:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1DA736B0007
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 11:33:08 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id r4so22666349wrt.13
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 08:33:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=J47c5Xv+H4pUUYAommvtDQM3CfR2VRutFeXq9FWvutY=;
        b=GD65/722rZ45A6QdSmoYTJSRghkSfmv0rTizYrG0U4jAdzsT8UHA4ySu5akhullQVj
         82G9QVC6DR2C0RUVDu8PbANliq3b6JG4C0TRkB9HmUKD07DGskBtHV78V3FH+Rx3SnTi
         z2qSxc1tpec3ibV4H++Mzv8yof9XHqzA+NhOpOHYSmcA/QKlWS8CiPgP7V76TG4ZEEEu
         nXsLkJNiOfl3WCGG8hOQXqjbdfxdgucG+nONFZr/f0qb9r0hoq6EB9QZ8vNne1NtQfl+
         yzZ0iE3TDpCdbKeFXLyJzTgIcQaMJ1hSMZZ+09gh5Bb41mYTYNt2MgxOWZML9iHzNW1r
         IBuA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXe0QC9yaotW8mcgLCCHXwgF9NSYDlx7RzzJZ2Pm97DC8jmqjYN
	NzRpKn79tAqOjaZxnS6pd87W2zhe+Zn+XzsaOXfS5YZQz6rZ4Do9hQD1uBkMhg2SEQUvt5kdGDW
	Cin0pV+zraRFO+SN6xmp3yY0qMHAvemKEyHEYqA6u/d1a/DZJTWWSdyut/3GIW+G2fg==
X-Received: by 2002:a1c:a101:: with SMTP id k1mr76789448wme.98.1563982387706;
        Wed, 24 Jul 2019 08:33:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxeIoxUPhITfm/bgP0Qvalf5mvg1gD8R3S8KmFEXbDdZ24aYqvXPy+qO5Cufm2Ocl/35yv
X-Received: by 2002:a1c:a101:: with SMTP id k1mr76789396wme.98.1563982386874;
        Wed, 24 Jul 2019 08:33:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563982386; cv=none;
        d=google.com; s=arc-20160816;
        b=UMhGvtKEolUtebBdlTye2l6hmH1BxbtirlFjTn/kh5zoo3oRJGVCMR/eTm/0xyHbsr
         5j98AR6SHOxgqEDibULN9fjmBvV6BF8UDdihdBpDl6mXV/+OUMTR3V7ySDtuYlfMhgHv
         fyRJyG1tLfN0/tSw34nejjbt80g9kfEcGOzUnz3rcwEodrfg2NAUQ8GXdkDHQJwLKpey
         sgvpmNL8B/FtCHFWWGKLz22o9MmLSXbWPwWOyJPInbbSu9w87o33h3nB6Xck61Ad4YLe
         RIfw4iHsa1Hiy/onNqS1vQBODSAKo1Mee3fVGxmCzjYyAGFvIl/dWnGm03FFYPMQiIh1
         Sk4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=J47c5Xv+H4pUUYAommvtDQM3CfR2VRutFeXq9FWvutY=;
        b=BIyliqst5iTLIUUTIgdhZcYOkSBcCEu+swEvGkthHda6geReDcJxsYrHLc0mQVf2hx
         9vHC9Ojd0eXWg4WNQCL6szeZIGQ0W7C2Qq5w/a+uvQeE7fdOGJGMq7WChY8A6o2EnTwl
         4RaDW9BGj4tAr4qeAPCv5Y46qiRdN5NObnKa7IVpK3QPUbMPPY+/I3Na55jjXV0UCLMO
         8Mf1XX7HOq+s+ejXuYUYtdSmgfVQsN5/u1KLUGJG64u4eead10rWcg18wgL/i+Dn0WGS
         B9LnkL7oEVo6y7BIJR963UN98gxKJrvTSuaNtddxTxlESdQa29+VQfJfVjMiiKdT3/xY
         7W7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id t9si51400958wra.181.2019.07.24.08.33.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 08:33:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id E22EC68B20; Wed, 24 Jul 2019 17:33:05 +0200 (CEST)
Date: Wed, 24 Jul 2019 17:33:05 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>,
	Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>
Subject: Re: [PATCH] mm/hmm: replace hmm_update with mmu_notifier_range
Message-ID: <20190724153305.GA10681@lst.de>
References: <20190723210506.25127-1-rcampbell@nvidia.com> <20190724070553.GA2523@lst.de> <20190724152858.GB28493@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724152858.GB28493@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 12:28:58PM -0300, Jason Gunthorpe wrote:
> Humm. Actually having looked this some more, I wonder if this is a
> problem:

What a mess.

Question: do we even care for the non-blocking events?  The only place
where mmu_notifier_invalidate_range_start_nonblock is called is the oom
killer, which means the process is about to die and the pagetable will
get torn down ASAP.  Should we just skip them unconditionally?  nouveau
already does so, but amdgpu currently tries to handle the non-blocking
notifications.

