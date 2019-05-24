Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D2D8C282E3
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 10:43:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DCA2217F9
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 10:43:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DCA2217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB7C06B0005; Fri, 24 May 2019 06:43:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B685E6B0007; Fri, 24 May 2019 06:43:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A55C16B000A; Fri, 24 May 2019 06:43:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 540D16B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 06:43:00 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x16so13516351edm.16
        for <linux-mm@kvack.org>; Fri, 24 May 2019 03:43:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=+jVfA2CCya8e7TQrZKJhRiJKDbB4ooZugW7xIpPmfpA=;
        b=U5dsUr02DvlVty56X2xGMPTIgeve2XyJ21kF6Dew1xUL68G1/SOykcy6OVHPSnfSpr
         gMmLFU9xl1IqaN8JfXIGc8cETXZXoUYAF+7G/OGXXIoJL2lij8m7ZhM7IpbQ5KeMmjjF
         GEnciGCxcZJxNFAWDHe/vEfCFVPjTf7EB0/T/iUPsnwFRHt3WoXLsnYbi31xDaXZNUzn
         XFE7CoD9ooKm7GXQtu+98jHoZ6PTRV1Gl2CE5xLEnLQx88p7QvLzF70BmC+0HF5e0rj3
         H1a5AKyj4RSMrzG/V65gqiA91ENW8SJ8n7q2kfhbs/FE1KS7XfQ4zAL+kniXFegkIbTn
         U8qA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of suzuki.poulose@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=suzuki.poulose@arm.com
X-Gm-Message-State: APjAAAUPqiR1efT1mJeyn/pZu3IBrmywVFeOKTi2jI4mPy0zmQrl144w
	CZYhXy8YRJS5R8Cv81mR+FP0KEgkGfFoYXQDtC9jbliv07Z4I1s1NhF5cF2r04QVdtFI1qd0izj
	TEArLewdyJB8M19qK2fbOSKv1TeXXLgWlzUl4hCm06giXwccib9MLzp54tBdzsjF3Jw==
X-Received: by 2002:a50:974d:: with SMTP id d13mr104839642edb.209.1558694579902;
        Fri, 24 May 2019 03:42:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaIdLdvyOE8Ajt2ClV0Z/r3jD8lLqKUAqa1IKDiyLG3TJThjebcuvi38vjFGTnmbglAkW5
X-Received: by 2002:a50:974d:: with SMTP id d13mr104839566edb.209.1558694579080;
        Fri, 24 May 2019 03:42:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558694579; cv=none;
        d=google.com; s=arc-20160816;
        b=sNqMEsZOpgCxBSOkFm+dttaICn+Iz65SQQm7LJdW2LYlLlcCpXQN2kxcpHDiUlI7OL
         t8HYSkCRtaws52e6XHlaE5dEuwmSzoS4r5Ozk9Va44p8SqgTspmhPj70IFlmpHpxm9w+
         tNCV3F9MqLvDIywinSTsQhD7GwI0MNYzOrhqrBfJnhAgkYWBk95kbv78QyWtKHwveUYg
         MfrTGHCTucTMnD9eBIFU1w82bl7/Xh9bKmCHRYZHbqnvUK4/TxrjPkNmORv9hKm+umSW
         Areq8hf6j60/sa61AcHxKRHPXRjgAwVJ9rhKk/kp9h1JcQuWHZTn+1kL2aw4QQAKMxzv
         f5nA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=+jVfA2CCya8e7TQrZKJhRiJKDbB4ooZugW7xIpPmfpA=;
        b=IlBFXl/8oUGE1h86psDFDE1+0ki9nxKq00exJYQDq00a/Wj9KaZWRb3gq46fbsU85d
         tQnAlL50PUOEWWRSAE04vEWeT8RZd6QxqH9oGXdpphdQXnFIHXf2Yc4O2pbfJJtbEfJb
         GU9iQDqsd1KQaMYilpG0JCtXkvsztOxnBMznO3xx2KvME4+vfsle+rGB3GlwGtOUk4/W
         nD4ledFxgyI4+0JE7XViqaL5eI9vr29SNpYFOQhn3mQyWc30mAq0XjeBP6LUPPhCe3on
         CvKLmNauzN2fEkPPxQvkVmAK0AI+PXezpj5q8sVJs35igxcfna5AgYWb/2ehIvalDli0
         DGRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of suzuki.poulose@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=suzuki.poulose@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w50si1601138edc.110.2019.05.24.03.42.58
        for <linux-mm@kvack.org>;
        Fri, 24 May 2019 03:42:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of suzuki.poulose@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of suzuki.poulose@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=suzuki.poulose@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D473B374;
	Fri, 24 May 2019 03:42:57 -0700 (PDT)
Received: from [10.1.196.93] (en101.cambridge.arm.com [10.1.196.93])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5690D3F703;
	Fri, 24 May 2019 03:42:56 -0700 (PDT)
Subject: Re: mm/compaction: BUG: NULL pointer dereference
To: mgorman@techsingularity.net
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.com,
 cai@lca.pw, linux-kernel@vger.kernel.org, marc.zyngier@arm.com,
 kvmarm@lists.cs.columbia.edu, kvm@vger.kernel.org
References: <1558689619-16891-1-git-send-email-suzuki.poulose@arm.com>
 <20190524103924.GN18914@techsingularity.net>
From: Suzuki K Poulose <suzuki.poulose@arm.com>
Message-ID: <98b93f38-64a7-dcd1-c027-6d1195f3380f@arm.com>
Date: Fri, 24 May 2019 11:42:54 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190524103924.GN18914@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Mel,

Thanks for your quick response.

On 24/05/2019 11:39, Mel Gorman wrote:
> On Fri, May 24, 2019 at 10:20:19AM +0100, Suzuki K Poulose wrote:
>> Hi,
>>
>> We are hitting NULL pointer dereferences while running stress tests with KVM.
>> See splat [0]. The test is to spawn 100 VMs all doing standard debian
>> installation (Thanks to Marc's automated scripts, available here [1] ).
>> The problem has been reproduced with a better rate of success from 5.1-rc6
>> onwards.
>>
>> The issue is only reproducible with swapping enabled and the entire
>> memory is used up, when swapping heavily. Also this issue is only reproducible
>> on only one server with 128GB, which has the following memory layout:
>>
>> [32GB@4GB, hole , 96GB@544GB]
>>
>> Here is my non-expert analysis of the issue so far.
>>
>> Under extreme memory pressure, the kswapd could trigger reset_isolation_suitable()
>> to figure out the cached values for migrate/free pfn for a zone, by scanning through
>> the entire zone. On our server it does so in the range of [ 0x10_0000, 0xa00_0000 ],
>> with the following area of holes : [ 0x20_0000, 0x880_0000 ].
>> In the failing case, we end up setting the cached migrate pfn as : 0x508_0000, which
>> is right in the center of the zone pfn range. i.e ( 0x10_0000 + 0xa00_0000 ) / 2,
>> with reset_migrate = 0x88_4e00, reset_free = 0x10_0000.
>>
>> Now these cached values are used by the fast_isolate_freepages() to find a pfn. However,
>> since we cant find anything during the search we fall back to using the page belonging
>> to the min_pfn (which is the migrate_pfn), without proper checks to see if that is valid
>> PFN or not. This is then passed on to fast_isolate_around() which tries to do :
>> set_pageblock_skip(page) on the page which blows up due to an NULL mem_section pointer.
>>
>> The following patch seems to fix the issue for me, but I am not quite convinced that
>> it is the right fix. Thoughts ?
>>
> 
> I think the patch is valid and the alternatives would be unnecessarily
> complicated. During a normal scan for free pages to isolate, there
> is a check for pageblock_pfn_to_page() which uses a pfn_valid check
> for non-contiguous zones in __pageblock_pfn_to_page. Now, while the

I had the initial version with the pageblock_pfn_to_page(), but as you said,
it is a complicated way of perform the same check as pfn_valid().

> non-contiguous check could be made in the area you highlight, it would be a
> relatively small optimisation that would be unmeasurable overall. However,
> it is definitely the case that if the PFN you highlight is invalid that
> badness happens. If you want to express this as a signed-off patch with
> an adjusted changelog then I'd be happy to add

Sure, will send it right away.

> 
> Reviewed-by: Mel Gorman <mgorman@techsingularity.net>
> 

Thanks.

Suzuki

