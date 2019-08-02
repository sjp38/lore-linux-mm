Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67030C32753
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 19:34:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14FC520880
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 19:34:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="pA8Qugcw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14FC520880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BCB06B0007; Fri,  2 Aug 2019 15:34:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66DEB6B0008; Fri,  2 Aug 2019 15:34:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50E6A6B000A; Fri,  2 Aug 2019 15:34:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4456B0007
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 15:34:53 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y66so48883673pfb.21
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 12:34:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=+4YFr8hVqt3rnBZzpE/CDXaE3u2NtyGgeA2+CHyqUUg=;
        b=SxDLJ5MmZNsrXrcGeD4t4WCoGrStps76ynYH6DQKlnkuLKW0zAL8kOKncqGsFVkJ6m
         XyBXyxN8omtblZnm0KrCRrmpfjaLrLl2Psr6OofIbhLCmValtthYj4Z/eAYQixf2f/yv
         XLDMCQkw6BTutJwSN/DVUMA8KQIunLLomX4AJ4vwpt4Ln3F2ta+3H+7kjQkTetKqP6qC
         o1+VAf3dj3PEDzik/0S/EYKnre/ukaVInJUgrAHDIT+TFtOVr88yklbTMmfio4ZyM0FH
         MPzrwYbrYF+IvBFye3++qF364aTaUKoNhSm2EQvtrpumJnI4knrV0A06Fiy+sYDk+Aal
         iOew==
X-Gm-Message-State: APjAAAVtilmL03CpbMODTvmzX4KkVMxd/NHXtckYBQbZ6WU/tPw6SHo0
	mOplyoqYyBdzf3iGrMBpwYbC2KJA2wzET1X8m7laBwmvkd77GbJvwE3sxlIDmKfZ6Il98TlWlsH
	vSFf2ef5XJJdAXr7ncXnCThz9AN3bt7J2KRNhfJaVHYvd3sn/pVBkc9T0+d3Rz/WjdQ==
X-Received: by 2002:a17:902:848b:: with SMTP id c11mr132227819plo.217.1564774492677;
        Fri, 02 Aug 2019 12:34:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzeA19GNtOfM8kwt4btwhZQrDGkdwAI8lKdThFD50UyeyxSptBVZpZgLR2w5SXQy5UyvxXi
X-Received: by 2002:a17:902:848b:: with SMTP id c11mr132227788plo.217.1564774492065;
        Fri, 02 Aug 2019 12:34:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564774492; cv=none;
        d=google.com; s=arc-20160816;
        b=YuPWUV4QLoQxOZBb/yc3YInwSvE04MTgCjQGl9iU11XaF/3kj+qIyk8X//SwLm1XWy
         zuIFTB4/jDCpd/gFbSVZSyLm4TdvKon43cOup2j/TAiNiB6pK0ate6wXJMwV+VKJfN1K
         tPQbhxl/DgT4N/DB4E4J16ibu9QlNQzpv/eoQfq0y6da3xjrzBpWOYw/ahRwes6GWNZI
         ZCNVQFRZfOy30apdy5LnN8qJMv3pUHGfefQkF7uBnm2e4ov8LvrgOpvEXU0KUNfuTC6K
         NjtCxtHkg3EzW14eVWs9BIyxib8XEl6I0bBEucFeIEjofraPyddXaCaFM6Kva3HuAYD2
         VX2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=+4YFr8hVqt3rnBZzpE/CDXaE3u2NtyGgeA2+CHyqUUg=;
        b=z6vr8z+kAtOu0xntL+nAEZtMfmo5s1Hf/1H9aEw+w7ZwI+NCBerikpF7NC+O5JXTko
         kpXv8f4kQWJeJFP05yjpO7+cbZcVFRvgX0ugCYRDZ1F89QKw7Ccx16oVyc7SF+gb8bdv
         o5NUodxxuE2cXAJgZtPQaVECG39J8pGl7YPL+kdlW8s7LoAmjwmuc29m0fK0kJ6mylc6
         mrikSXASinmrDwCmJtcD/h7M1zxvfJTn1axwSp0zRlP0z5pPPvNIgitfHJ6gUl4NtJKy
         qvNrDhsFqdNx7hlJwNsXpNdL7UUrwmaFDheoR8bHua05p2Yeh+O/l7kBFSYdgKWpG3F/
         lDsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=pA8Qugcw;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id l186si39292228pgd.455.2019.08.02.12.34.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 12:34:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=pA8Qugcw;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d44905c0000>; Fri, 02 Aug 2019 12:34:52 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 02 Aug 2019 12:34:51 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 02 Aug 2019 12:34:51 -0700
Received: from [10.2.171.217] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 2 Aug
 2019 19:34:50 +0000
Subject: Re: [PATCH 00/34] put_user_pages(): miscellaneous call sites
To: Peter Zijlstra <peterz@infradead.org>, <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
	<hch@infradead.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner
	<david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ira Weiny
	<ira.weiny@intel.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, LKML
	<linux-kernel@vger.kernel.org>, <amd-gfx@lists.freedesktop.org>,
	<ceph-devel@vger.kernel.org>, <devel@driverdev.osuosl.org>,
	<devel@lists.orangefs.org>, <dri-devel@lists.freedesktop.org>,
	<intel-gfx@lists.freedesktop.org>, <kvm@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-block@vger.kernel.org>,
	<linux-crypto@vger.kernel.org>, <linux-fbdev@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <linux-media@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <linux-rpi-kernel@lists.infradead.org>,
	<linux-xfs@vger.kernel.org>, <netdev@vger.kernel.org>,
	<rds-devel@oss.oracle.com>, <sparclinux@vger.kernel.org>, <x86@kernel.org>,
	<xen-devel@lists.xenproject.org>
References: <20190802021653.4882-1-jhubbard@nvidia.com>
 <20190802080554.GD2332@hirez.programming.kicks-ass.net>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <8968c928-5712-03a9-68df-051f5b58fdbc@nvidia.com>
Date: Fri, 2 Aug 2019 12:33:13 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190802080554.GD2332@hirez.programming.kicks-ass.net>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564774492; bh=+4YFr8hVqt3rnBZzpE/CDXaE3u2NtyGgeA2+CHyqUUg=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=pA8QugcwnL1HNNctuTXTMAa7CrBYZtv2cc2QzVDHg2S/Xz0x5cf9O8eGtP0C46aN6
	 a197cn16D9E9xYsYwbovYwvjP0hTnTIrSK10+fiYfbToCUN0I9g4iXpjbE6kGTwrAp
	 ncKdQLJTA/SOQtWLtiZt5vxeEAtfkDytTOFqyC79V99rQnUwNH1zBFEyzb+BV4yCcg
	 0Lb+HCJur/Jv3WTiflqOcCteevFh1AJi/C8c1Ka1hIgLd+uE9NAbY1wcjbuQJmv03/
	 F2ke8dbjLXpL5/tEd8euZ6kSYJfMWxVRqMIbW34EAHrZytttzmbzNNCLzf8Qy6VEOi
	 6Ny99XF1JiDWQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/2/19 1:05 AM, Peter Zijlstra wrote:
> On Thu, Aug 01, 2019 at 07:16:19PM -0700, john.hubbard@gmail.com wrote:
> 
>> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
>> ("mm: introduce put_user_page*(), placeholder versions"). That commit
>> has an extensive description of the problem and the planned steps to
>> solve it, but the highlites are:
> 
> That is one horridly mangled Changelog there :-/ It looks like it's
> partially duplicated.

Yeah. It took so long to merge that I think I was no longer able to
actually see the commit description, after N readings. sigh

> 
> Anyway; no objections to any of that, but I just wanted to mention that
> there are other problems with long term pinning that haven't been
> mentioned, notably they inhibit compaction.
> 
> A long time ago I proposed an interface to mark pages as pinned, such
> that we could run compaction before we actually did the pinning.
> 

This is all heading toward marking pages as pinned, so we should finally
get there.  I'll post the RFC for tracking pinned pages shortly.


thanks,
-- 
John Hubbard
NVIDIA

