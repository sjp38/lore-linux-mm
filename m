Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 638B2C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 02:12:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BD2321855
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 02:12:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BD2321855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C38D66B0008; Thu, 28 Mar 2019 22:12:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE92A6B000C; Thu, 28 Mar 2019 22:12:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB21A6B000D; Thu, 28 Mar 2019 22:12:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 894166B0008
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 22:12:30 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id 75so536603qki.13
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 19:12:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=ajLWmYIXQpHFAeGbg2FFXCppAyS6yuMa/dNJQ9dB4Ls=;
        b=TCXXdKv9kR33x+1EU3nmIlNq0mmjN9amtxMngmg6huVrnxTJtEaDe2nCJJSM0E0TS7
         ZmAUF41whXzwnw/Qzy9uHDB26qPk2dZ01nmYL2ALpYSqbo4TAY2BMR1I3W5YY1gz/6b5
         0m0X0pSj4D42d9sQF7NDICCxkLNOFUAZgDlDhtn3mASq14DfUl9/LlJKivjfkGE/iSEw
         q5JxcL0TA1XreNZo+hAUPxBEiSwn55JeUzd1SOjsw4aQp0mX1dCqbH09FaTqg/YUjOzD
         LaMaVl7GzkmUiniin3pLJSvs1xVT31ToCBzOaZFI/4LDb/bSeTb4Czk5N1fiW5jPivEN
         L9zw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWTPYji2DYTa5Q6087E61078NYUBMiRvHEV84J3ZHwaJrLne1aI
	etPkSSypWbGoaFEIKB47pZc9dMMjL6ha9SZQTxek81G+sfFo7qmexzBcDOfhTNPHoznjueB7rrJ
	RmbXRDsnm8jZx3/rJC6k5RanP0P1/ra2q2me48wpWULXlX/OOzMHLawrhB1CcYNcadA==
X-Received: by 2002:ae9:c219:: with SMTP id j25mr20251822qkg.82.1553825550350;
        Thu, 28 Mar 2019 19:12:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx41L1otyxDNplsFJ1WeX2kJ81s1H21pTgmUyPxaYNm+vF52ImgrLT0pKa49RjoYXpMJhBB
X-Received: by 2002:ae9:c219:: with SMTP id j25mr20251804qkg.82.1553825549822;
        Thu, 28 Mar 2019 19:12:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553825549; cv=none;
        d=google.com; s=arc-20160816;
        b=VLrZIaY0zSWWPILy7I+T29OTSWrzMyvIZdu57AusgtOIqXTYmzdl+tV2hfwCCEmk2w
         lgdVopeg+IDeVFLxBDMpx27UKKwsi3hwR7jbs6mjCC9wSWTZKCJfhDGlZmajbyBSGFQc
         pNDeaNUmWZU8CFc3SQj9h6WrCuxeTyO4iJvcIL+9dJeW+fOAHJZurOTbp6LY53VBLQgp
         PbejC6znctSa3gVkr4Jm4UXFd70pwNjqnyld2/M/4VGw/+oyZCSi0v5gzGclUAQDiHG0
         ZgNF3daDFRyypVdnU7oUe3Jw55a2ZlWfhwtOIA8BobKU3GDrqbnHPTtisap4pBGeEd3T
         jeSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=ajLWmYIXQpHFAeGbg2FFXCppAyS6yuMa/dNJQ9dB4Ls=;
        b=DV8ZBMSP4Uwvbgm3lYhyEdF0WTF7M4H/RN2sTGSWb05jZgoC5LDe74aP7mb2ayw8Kh
         k96qRRz0Wkr5Lxl8ppzbCLZRRroeToVKPo9koTeqbNlFq5UPOQj/U0D8tIazlQxC+VRl
         onSXfOTxwul2O7DJ64x0Uwp7ny518HfC8KEnWYlv6qdGEtLlIPf8Xe2SD2ekx3MYTfOo
         nkzg0JHBo2oBzWtCoVqBpdDejpkZG7xpIUUbxQl6m5NYugYN2bgMwAIYQlk/RCftOPTv
         PZSWECTTDcva3EV04BO6z8iFiuaoI+R/YB0G2aGDJ4ZbQ43XuwIbCSdbUZcaxCZLLWBb
         OIHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 9si345724qkg.122.2019.03.28.19.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 19:12:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0A6963082B67;
	Fri, 29 Mar 2019 02:12:29 +0000 (UTC)
Received: from redhat.com (ovpn-121-118.rdu2.redhat.com [10.10.121.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id EBE835D71A;
	Fri, 29 Mar 2019 02:12:27 +0000 (UTC)
Date: Thu, 28 Mar 2019 22:12:25 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Ben Skeggs <bskeggs@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 07/11] mm/hmm: add default fault flags to avoid the
 need to pre-fill pfns arrays.
Message-ID: <20190329021225.GG16680@redhat.com>
References: <20190328223153.GG13560@redhat.com>
 <768f56f5-8019-06df-2c5a-b4187deaac59@nvidia.com>
 <20190328232125.GJ13560@redhat.com>
 <d2008b88-962f-b7b4-8351-9e1df95ea2cc@nvidia.com>
 <20190328164231.GF31324@iweiny-DESK2.sc.intel.com>
 <20190329011727.GC16680@redhat.com>
 <f053e75e-25b5-d95a-bb3c-73411ba49e3e@nvidia.com>
 <20190329014259.GD16680@redhat.com>
 <20190329015919.GF16680@redhat.com>
 <f7710f64-c17e-feef-f453-e01340461e7e@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <f7710f64-c17e-feef-f453-e01340461e7e@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Fri, 29 Mar 2019 02:12:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 07:05:21PM -0700, John Hubbard wrote:
> On 3/28/19 6:59 PM, Jerome Glisse wrote:
> >>>>>> [...]
> >>>>> Indeed I did not realize there is an hmm "pfn" until I saw this function:
> >>>>>
> >>>>> /*
> >>>>>  * hmm_pfn_from_pfn() - create a valid HMM pfn value from pfn
> >>>>>  * @range: range use to encode HMM pfn value
> >>>>>  * @pfn: pfn value for which to create the HMM pfn
> >>>>>  * Returns: valid HMM pfn for the pfn
> >>>>>  */
> >>>>> static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
> >>>>>                                         unsigned long pfn)
> >>>>>
> >>>>> So should this patch contain some sort of helper like this... maybe?
> >>>>>
> >>>>> I'm assuming the "hmm_pfn" being returned above is the device pfn being
> >>>>> discussed here?
> >>>>>
> >>>>> I'm also thinking calling it pfn is confusing.  I'm not advocating a new type
> >>>>> but calling the "device pfn's" "hmm_pfn" or "device_pfn" seems like it would
> >>>>> have shortened the discussion here.
> >>>>>
> >>>>
> >>>> That helper is also use today by nouveau so changing that name is not that
> >>>> easy it does require the multi-release dance. So i am not sure how much
> >>>> value there is in a name change.
> >>>>
> >>>
> >>> Once the dust settles, I would expect that a name change for this could go
> >>> via Andrew's tree, right? It seems incredible to claim that we've built something
> >>> that effectively does not allow any minor changes!
> >>>
> >>> I do think it's worth some *minor* trouble to improve the name, assuming that we
> >>> can do it in a simple patch, rather than some huge maintainer-level effort.
> >>
> >> Change to nouveau have to go through nouveau tree so changing name means:
> 
> Yes, I understand the guideline, but is that always how it must be done? Ben (+cc)?

Yes, it is not only about nouveau, it will be about every single
upstream driver using HMM. It is the easiest solution all other
solution involve coordination and/or risk of people that handle
the conflict to do something that break things.

Cheers,
Jérôme

