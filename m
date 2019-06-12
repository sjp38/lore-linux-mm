Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22D54C31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 12:20:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E326721734
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 12:20:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E326721734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vmwopensource.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5BEF6B0269; Wed, 12 Jun 2019 08:20:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A00966B026D; Wed, 12 Jun 2019 08:20:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EE586B026E; Wed, 12 Jun 2019 08:20:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2875F6B0269
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 08:20:28 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id l10so2502721ljj.10
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 05:20:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=gPZ2OTJlcxRx/9elhuFx8X5f5MbNH4kT8T99tBfgsnQ=;
        b=TrL90HgPwbv0tVhHD/i4aj1b1sxAZMtnvhTGMkb+BuG2mM+G9ULN5Pnlc6ERh3KvQ1
         vUPFyNSYwyBNfrCRslJuHcAZ1Wkg2+LT4earG6eJXtf1C1JNZfd/dcZWTvtUbeycUpCc
         pgyEVUCgMYLcxgO2lQGw8yyrhv7wCKKuItOJBFv5F3EzKdQpkLvNT/YmXS9RmniBFet6
         S4WyIAy6jsYdbtlxgDbpsWiW3TUftFsRRWgD69tXJCHxiCC3aWWEwYENjS18JjQnhhGL
         MqFO6aPOaD0q3EIQDr+9ZTilOfRFCwXCBudZEMXlB7GGUgibJnHB773GY3skRHmL5xuE
         n8/w==
X-Gm-Message-State: APjAAAX9voc6luVNk4KY15ON0ZOIklBnAgHhSC1Q+aSCF3EcgaOjgp81
	b4hjH3eLehgIEJFJRfzAoVh7N5zTTej//CCJ/SJMjyzkNJkJpVou+/1jRCGSD755lO8WVYxnFre
	zEzO97N2f0l9KV3STMTmX1/McJAIw+LDi/CPAFmCaV5R66Z+v2xoBTv6l6tDgN++1Pw==
X-Received: by 2002:a2e:8e90:: with SMTP id z16mr6071121ljk.4.1560342026817;
        Wed, 12 Jun 2019 05:20:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhd2IweZKcf2THGo6jq+6v3ixQ8XfR3pd2h4IpPyUa9UJDbcaj3kPZ0zYkKJFEuedWOoPD
X-Received: by 2002:a2e:8e90:: with SMTP id z16mr6071075ljk.4.1560342026053;
        Wed, 12 Jun 2019 05:20:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560342026; cv=none;
        d=google.com; s=arc-20160816;
        b=pvgKzA/BaaneyNxcVx9Q8VKYKF+7nIQ2oZ1iiHKfVf/DKfulAdmSmsJ4P5z9jtlfo2
         l1J0q50h4shwAer9M814NTPROBoui3MDUwj+vj8oNbY4FgtHIWsIpM5ySc2u4/wG0Tp/
         h6ujuEPBfDoD2JpxVGIcg61/b57k5snHTeStuypikfPDP4TCEnU0vc/3x9xWBr6wkd37
         2RkKal1j1JX7XUkU0fBA7p0IB0YM7Fv8vF63LLyj3Z6kFjbcsntYSG/EwBzyYuOiRrNx
         bQfMdrFVOskMn9JMdc+ySyepXslId+u81NRzDhxeMW8HXxzpu9/sxHKCbzoZ4avbb2/d
         c6WA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=gPZ2OTJlcxRx/9elhuFx8X5f5MbNH4kT8T99tBfgsnQ=;
        b=vTRPXeApR/V0Nr8MXrXOfSMclNpZWxSbLcFP+d2ZzQ73ecW5LlXMiTqudY+p1Qe1LR
         U9inR67QZY6YOXGsyRNrqRjOWvnmJgogoWj9tk+C8o2a9cchHIkv/bgLTCWAHdQZTDEI
         08OZdnwOI9iAGYhfZ7hMdMks1pDyWY2+jkHJ1USfuwg+pWf1FcDtvvea3b55fTVSgyzd
         YORxMDsYdHM2IQKNfbzANq6D/gnEdVPjRTIuWUKqZ3lHzFOip0LQG8T7nKEBfQamvVwM
         rfSg2rlYYD1P4kmCKJDtvXELbhNd/w9wj3ALJMB60++CPXV48rL0PDgqdQde9NfezbJB
         0m/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=g9JQd7iX;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.71 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from ste-pvt-msa2.bahnhof.se (ste-pvt-msa2.bahnhof.se. [213.80.101.71])
        by mx.google.com with ESMTPS id o8si13695469ljh.127.2019.06.12.05.20.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 05:20:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.71 as permitted sender) client-ip=213.80.101.71;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=g9JQd7iX;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.71 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from localhost (localhost [127.0.0.1])
	by ste-pvt-msa2.bahnhof.se (Postfix) with ESMTP id B32C43F792;
	Wed, 12 Jun 2019 14:20:15 +0200 (CEST)
Authentication-Results: ste-pvt-msa2.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=vmwopensource.org header.i=@vmwopensource.org header.b=g9JQd7iX;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Authentication-Results: ste-ftg-msa2.bahnhof.se (amavisd-new);
	dkim=pass (1024-bit key) header.d=vmwopensource.org
Received: from ste-pvt-msa2.bahnhof.se ([127.0.0.1])
	by localhost (ste-ftg-msa2.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id YFDHihGaaJKs; Wed, 12 Jun 2019 14:20:05 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by ste-pvt-msa2.bahnhof.se (Postfix) with ESMTPA id D94A63F771;
	Wed, 12 Jun 2019 14:20:03 +0200 (CEST)
Received: from localhost.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id 6C3313619A3;
	Wed, 12 Jun 2019 14:20:03 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=vmwopensource.org;
	s=mail; t=1560342003;
	bh=6NfMWfvQeoRy9SPu4DRek4214/12osldJKiSUF/Om8o=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=g9JQd7iXbBFiJ9k/DFvRCemp/a055P3v1B/2XGHSPrmLckFXXamHhLxVJb7ZMt9f5
	 jYLGqeoMp1N46VhXUk47+FPdynyWNASQeTHzpZ9jHQ6CUrTYeWqqkzDzRovkQI4o8Z
	 Sf04V6HvJKonDRhebjhwGvZ/BTi//2F1blpTwSKE=
Subject: Re: [PATCH v5 3/9] mm: Add write-protect and clean utilities for
 address space ranges
To: Christoph Hellwig <hch@infradead.org>
Cc: dri-devel@lists.freedesktop.org, linux-graphics-maintainer@vmware.com,
 pv-drivers@vmware.com, linux-kernel@vger.kernel.org, nadav.amit@gmail.com,
 Thomas Hellstrom <thellstrom@vmware.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Matthew Wilcox <willy@infradead.org>, Will Deacon <will.deacon@arm.com>,
 Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@surriel.com>,
 Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>,
 Huang Ying <ying.huang@intel.com>, Souptick Joarder <jrdr.linux@gmail.com>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-mm@kvack.org,
 Ralph Campbell <rcampbell@nvidia.com>
References: <20190612064243.55340-1-thellstrom@vmwopensource.org>
 <20190612064243.55340-4-thellstrom@vmwopensource.org>
 <20190612112349.GA20226@infradead.org>
From: =?UTF-8?Q?Thomas_Hellstr=c3=b6m_=28VMware=29?=
 <thellstrom@vmwopensource.org>
Organization: VMware Inc.
Message-ID: <a004e1a5-bdc5-6508-039e-8d97a9d3cb68@vmwopensource.org>
Date: Wed, 12 Jun 2019 14:20:03 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190612112349.GA20226@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/12/19 1:23 PM, Christoph Hellwig wrote:
> On Wed, Jun 12, 2019 at 08:42:37AM +0200, Thomas Hellström (VMware) wrote:
>> From: Thomas Hellstrom <thellstrom@vmware.com>
>>
>> Add two utilities to a) write-protect and b) clean all ptes pointing into
>> a range of an address space.
>> The utilities are intended to aid in tracking dirty pages (either
>> driver-allocated system memory or pci device memory).
>> The write-protect utility should be used in conjunction with
>> page_mkwrite() and pfn_mkwrite() to trigger write page-faults on page
>> accesses. Typically one would want to use this on sparse accesses into
>> large memory regions. The clean utility should be used to utilize
>> hardware dirtying functionality and avoid the overhead of page-faults,
>> typically on large accesses into small memory regions.
> Please use EXPORT_SYMBOL_GPL, just like for apply_to_page_range and
> friends.

Sounds reasonable if this uses already EXPORT_SYMBOL_GPL'd 
functionality. I'll respin.

>    Also in general new core functionality like this should go
> along with the actual user, we don't need to repeat the hmm disaster.

I see in your later message that you noticed the other patches. There's 
also user-space functionality in mesa that excercises this.

/Thomas


