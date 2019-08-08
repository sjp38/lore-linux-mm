Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32710C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:30:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAEDD2086A
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:30:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="RQ1Ei+ek"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAEDD2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E6106B0003; Thu,  8 Aug 2019 19:30:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76EF76B0006; Thu,  8 Aug 2019 19:30:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E85E6B0007; Thu,  8 Aug 2019 19:30:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 269C06B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 19:30:51 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id c9so2296067pgm.18
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 16:30:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:references:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=JeEiCmZ1kkXlkjEvqYy9HdWxc7E1WmBQImLZC4SmHb4=;
        b=RgdbJae1sbecK4a5SMq+n217HkVF+LPD8EI8paF0O6V03/e7g9zEgoIAgyQT32Q+uc
         Nmxzxq89QD3HOqSL7C3MD/Q08UxtDV6VGLIb+LdOhYErwb4BCyQ8+G/uvdG85U0UmlCJ
         ULQWsZ342c3nVN5t88q1rVTkOLweym2IfDevog4Px6kLthPs7ec3uCRcl5wO9ISmo/zL
         EZFpaMEG8V3Em+js32BMju+n3UKVZLm2zRDevyKeVu8QdKd3bHrYzrldLEPwpT0WCS/l
         v2nJm2W4C20XQDB8Kt0FuZWf+TOs89IYk3gluYYDGuW8eycz3AS5xDL9ij1IJhpEqE5U
         XGQQ==
X-Gm-Message-State: APjAAAXojxdGN+jWoc7se1HTCEqaONDD4QM/52HP0UxW2RjfaNg0TgGd
	34j69+JIi4us1Jc8UOUQkZYx6qZC4BDD4r6wJ3sduLnZWPWhSrN9N5sYY93ag6tkg/v4cJdvmP6
	KaB6e8WkZOdcUrsa6E1mosuiDFN4MpXQeZ6dIWVUbBThnotp1lFDn+jGzROr19EBhEQ==
X-Received: by 2002:a63:3fc9:: with SMTP id m192mr15130778pga.429.1565307050756;
        Thu, 08 Aug 2019 16:30:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcax+ESVJ7SymClawq91dLzQsO0K5dx9ZwMSaLrIBcfWDSL4o29cR92f5YqHbdmnhuJvUY
X-Received: by 2002:a63:3fc9:: with SMTP id m192mr15130722pga.429.1565307049926;
        Thu, 08 Aug 2019 16:30:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565307049; cv=none;
        d=google.com; s=arc-20160816;
        b=PiBUDzm9EGDP/iEu7rS4Z/AaBFLknRmysqE+clCGLhEhuaYUFGnjtvlNcM/2CuC84s
         k3pIpe8XqSMQjbT6uNE/C6Kuzba6jUz/oq3w7l1+LtowhyKmPGy65D0vHGHOyzG3pTWN
         Xn4oZc/gPkeKIv898606XrcHLOJj8NYGgJR5aLM6xLABpQ6KP0x/IaGF7YEYXz0X5djP
         zPIDA6Z9cPbokKJUX3j807VG4SDtTowiXRijqSpCp6IGYjQMqXgTyo2b2Gz5o0lX6FaN
         0+3fprQYldiWWqok/JH3Zcj2v3k7nRG1WDeNfM4FAHt1dP6Ggcy8ukSpKHLjmViWkmeu
         6vVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:references:cc
         :to:from:subject;
        bh=JeEiCmZ1kkXlkjEvqYy9HdWxc7E1WmBQImLZC4SmHb4=;
        b=JTqXf2lfhAQ+I/XR0BMdfR9W4ORBGYoPtJAipuZa5dA4HicYCOkVIcjiN5ETlMRtbD
         dAQZLXHoxK5g11sgnCu4f+TWk3WXrHvWSNpWZjcbg2WT16sZEUtPI0C6hbdI7vHajM15
         xpr3LHhPVu1LrEEcDitifVyZ2+nEgrgDJ9WozuSvMaS7XCOs/p5Fq2UShH+d9O6UdmUr
         BCxLRe4aE/Wvqpjk4ZCOz/0/+Pr3G0x7MFE82eko5Waj8KzHp+7Ou34HAMjpvqatLILa
         o5qKtp7DIR5FESKEKVb/G5cpccsrbbmFUcpjFZ2KQQnlswVdllR/A7+av3AVNk+XTnKu
         s0wQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=RQ1Ei+ek;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id w9si2987547pjv.67.2019.08.08.16.30.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 16:30:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=RQ1Ei+ek;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d4cb0aa0000>; Thu, 08 Aug 2019 16:30:50 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 08 Aug 2019 16:30:49 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 08 Aug 2019 16:30:49 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 8 Aug
 2019 23:30:48 +0000
Subject: Re: [Linux-kernel-mentees][PATCH v4 1/1] sgi-gru: Remove *pte_lookup
 functions
From: John Hubbard <jhubbard@nvidia.com>
To: Bharath Vedartham <linux.bhar@gmail.com>, <arnd@arndb.de>,
	<gregkh@linuxfoundation.org>, <sivanich@sgi.com>
CC: <ira.weiny@intel.com>, <jglisse@redhat.com>,
	<william.kucharski@oracle.com>, <hch@lst.de>, <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-kernel-mentees@lists.linuxfoundation.org>
References: <1565290555-14126-1-git-send-email-linux.bhar@gmail.com>
 <1565290555-14126-2-git-send-email-linux.bhar@gmail.com>
 <b659042a-f2c3-df3c-4182-bb7dd5156bc1@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <97a93739-783a-cf26-8384-a87c7d8bf75e@nvidia.com>
Date: Thu, 8 Aug 2019 16:30:48 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <b659042a-f2c3-df3c-4182-bb7dd5156bc1@nvidia.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565307050; bh=JeEiCmZ1kkXlkjEvqYy9HdWxc7E1WmBQImLZC4SmHb4=;
	h=X-PGP-Universal:Subject:From:To:CC:References:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=RQ1Ei+ek/l7TS5OiIRwTFYtcyxSN9T9crP6QSv5UHXXIJAPAZC2aV4vTOVLtBo5Zs
	 qH5R49FfIpBhuswLdJebx07f2s9YccCc3QuXdwYABh7ET1oOCDgc7ZXu5mwLTTstWb
	 xOa02KE+GAVOGWGvFD0sVWCXxdmoLBJRwh+lJO60ITyZqc1MvDyNtE66gHpSkK1QWo
	 YaJjFaXROyuyM1LFk09qlkvDpTRbR1gDXP8t/M4NtvKuJ9IIev7m9TTs+69QegZFTX
	 52aYem6gWNo5FLgl6tSn7PXKLxcmYPTs5T34l56Pd9kudaY4yi6ni7k3DDa89tFCnx
	 oXzCq5m5h4P9w==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/8/19 4:21 PM, John Hubbard wrote:
> On 8/8/19 11:55 AM, Bharath Vedartham wrote:
> ...
>>  	if (is_gru_paddr(paddr))
>>  		goto inval;
>> -	paddr = paddr & ~((1UL << ps) - 1);
>> +	paddr = paddr & ~((1UL << *pageshift) - 1);
>>  	*gpa = uv_soc_phys_ram_to_gpa(paddr);
>> -	*pageshift = ps;
> 
> Why are you no longer setting *pageshift? There are a couple of callers
> that both use this variable.
> 
> 

...and once that's figured out, I can fix it up here and send it up with 
the next misc callsites series. I'm also inclined to make the commit
log read more like this:

sgi-gru: Remove *pte_lookup functions, convert to put_user_page*()

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

As part of this conversion, the *pte_lookup functions can be removed and
be easily replaced with get_user_pages_fast() functions. In the case of
atomic lookup, __get_user_pages_fast() is used, because it does not fall
back to the slow path: get_user_pages(). get_user_pages_fast(), on the other
hand, first calls __get_user_pages_fast(), but then falls back to the
slow path if __get_user_pages_fast() fails.

Also: remove unnecessary CONFIG_HUGETLB ifdefs.


thanks,
-- 
John Hubbard
NVIDIA

