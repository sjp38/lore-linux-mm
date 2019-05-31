Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99718C28CC0
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 01:43:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46A5A2620C
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 01:43:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46A5A2620C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B40E6B0278; Thu, 30 May 2019 21:43:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 992A46B027E; Thu, 30 May 2019 21:43:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A04A6B0280; Thu, 30 May 2019 21:43:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 529DE6B0278
	for <linux-mm@kvack.org>; Thu, 30 May 2019 21:43:18 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 61so5126872plr.21
        for <linux-mm@kvack.org>; Thu, 30 May 2019 18:43:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=4jl8k4FSkj5AWns/HCl6F5eYA5z3VPidnI5BEhRgHwY=;
        b=UsbfLOwPWVg0Ur2IveMqk5fJWepBUbBIofldakAkHBOVXcGI7FVXaC3Pi2vQPeuSSV
         ZzF9erCCSfcLVFZoDm1liWEztc7Gq39ADm4pUn9d4lP089NY+WrSZnL+1qy8YGkl9/Bw
         0BoR0MtGUEiDZgzRq8jjJnc2kVe9gakaUf5V3E078lQPrJpDq8VE3SMIxgod+kiuTewn
         ans7eX1GgZ1tAM2FTy5p5EqLXZ+hlS3aaAZielE3UoLW2VMIYKvyVxRrnj9F96vIwyJR
         OmGWxkPebuXVwNCvqwlvh6sPlHbFGZzmvP68rOnC23bgFq11yozrOMXZpzJhiVejyl0J
         3rxQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVW+jgQ5aebFxq08FET61Gr0qDRMMhsTOE/9n4fXM+gm4Q3RDXv
	V3CFiWTC3vzG0LbAyHNoWFGSkRgMPh2xOKtotlPxE+BAB+3WLVMpPlR1NpUcRsDaq7y7ePGtQza
	NM7LGzHKU9QCFuF9hTYGp2dyfi2Lkn/sncE6D4EqPEz2Csmpbz9W8L5qfr02xBbBmDQ==
X-Received: by 2002:a62:e718:: with SMTP id s24mr6702562pfh.247.1559266997886;
        Thu, 30 May 2019 18:43:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgDXUBhrrf79DpxcruYQ/CylFWYwAUY9nktoIq6AE4TLng8UGqlPs/wx3eguLHMzMySYlc
X-Received: by 2002:a62:e718:: with SMTP id s24mr6702506pfh.247.1559266996833;
        Thu, 30 May 2019 18:43:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559266996; cv=none;
        d=google.com; s=arc-20160816;
        b=flFZqyz/6Y8LELyVHJKoZYruTvy7r/tbSrvUZ4lLfyqkFyFM3YM4pVPp93s4Ntxjr5
         SFZEjrb/70+urYe10Rv2sZ+VmsjO6/7QlNxnE9EjglsXO6KxQC54MaksnxAP5ur/kgRp
         ZJjZlOLhRuzm/39LPZIZBRVYFCcaV1/7lmcLJRkodTPy0QgX30R0EU6KB2o80adhna6q
         xVzp/X5n3dDrxsDd9m5mdi4Ym9Uz4g7Hf4W0HKVySHfH6YPCzA4Ki07ZenLRp7FiPtcj
         /tmnIMwh5YAAmv4eVlo7lOpQb8st0OIFFvRYelOvkIpfo+9+gUs2JO1NQZREyrD5t/r3
         1/4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=4jl8k4FSkj5AWns/HCl6F5eYA5z3VPidnI5BEhRgHwY=;
        b=EiIpqpoSNuffiRhLKbMZLKDK6BqWsNT5RSdLQ6aBGzSNA3DCNlo7Wl2RtpFL8xtPHW
         NByuz84oZjWzRe+bwDuKihsK1IUI1XXos0QK1p0PRoJk1qCn6n5qRvfpR4GSyTB9/y6l
         Do1LhNTPd6C5xjKDIZi1KCHzK1NItC0dDMlU6vvvsQ6mtWt+UaPpAqOKY8RHFD8JNbVj
         lXJ/SFnWjtkVvBbkpsnmeJ7f2KTu3uEmGNiV9E0vpzW+0EKKsjFsv8bbLMDB+uTtcVrO
         6S3WGB5DYhmm8CaftUORImT1ejj2/gs3Tluma6f142IC52eb65cP7elWdDE5YMWUm1Br
         PHWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id s201si4557870pgs.522.2019.05.30.18.43.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 18:43:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 May 2019 18:43:15 -0700
X-ExtLoop1: 1
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by fmsmga001.fm.intel.com with ESMTP; 30 May 2019 18:43:14 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: <akpm@linux-foundation.org>,  <broonie@kernel.org>,  <linux-fsdevel@vger.kernel.org>,  <linux-kernel@vger.kernel.org>,  <linux-mm@kvack.org>,  <linux-next@vger.kernel.org>,  <mhocko@suse.cz>,  <mm-commits@vger.kernel.org>,  <sfr@canb.auug.org.au>
Subject: Re: mmotm 2019-05-29-20-52 uploaded
References: <20190530035339.hJr4GziBa%akpm@linux-foundation.org>
	<fac5f029-ef20-282e-b0d2-2357589839e8@oracle.com>
Date: Fri, 31 May 2019 09:43:13 +0800
In-Reply-To: <fac5f029-ef20-282e-b0d2-2357589839e8@oracle.com> (Mike Kravetz's
	message of "Thu, 30 May 2019 13:54:07 -0700")
Message-ID: <87lfyn5rgu.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Mike,

Mike Kravetz <mike.kravetz@oracle.com> writes:

> On 5/29/19 8:53 PM, akpm@linux-foundation.org wrote:
>> The mm-of-the-moment snapshot 2019-05-29-20-52 has been uploaded to
>> 
>>    http://www.ozlabs.org/~akpm/mmotm/
>> 
>
> With this kernel, I seem to get many messages such as:
>
> get_swap_device: Bad swap file entry 1400000000000001
>
> It would seem to be related to commit 3e2c19f9bef7e
>> * mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch

Hi, Mike,

Thanks for reporting!  I find an issue in my patch and I can reproduce
your problem now.  The reason is total_swapcache_pages() will call
get_swap_device() for invalid swap device.  So we need to find a way to
silence the warning.  I will post a fix ASAP.

Best Regards,
Huang, Ying

