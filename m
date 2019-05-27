Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C152C04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 14:30:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C76B72182B
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 14:30:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="sZ+nULcN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C76B72182B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B63F6B0003; Mon, 27 May 2019 10:30:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 540676B0005; Mon, 27 May 2019 10:30:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4081D6B0007; Mon, 27 May 2019 10:30:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE5F66B0003
	for <linux-mm@kvack.org>; Mon, 27 May 2019 10:30:34 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id m4so3208881lji.5
        for <linux-mm@kvack.org>; Mon, 27 May 2019 07:30:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=7qLRUcrPwsW5zqic4YMh4GiJeUahg2HnH6OlPeS5QxU=;
        b=FdO7Z5JaR5Sq1sPBSrkJBO31DFzhfnF6Vwynv3/mHa1WU7iOWb6U3isiSSbqwwivHb
         G54j5AqnEVXJXUU1e0Xtz1UwS9u54mCZ/GwuSqeWFAI3asPZSKC4tefxgZTr8UHIAgEY
         q+q9J8z856dLZwLPYWysrCfy6c7dqzdijfjNwJDT897zbke5mHqDfQbWwD6u8x01XbBI
         1DZmFTT7NCqBsx81OIGoenCnyst+xImPdkLyY1lgIJBjIMvzVVkWPZCb9nT9r92dEtIw
         mUoKn0lNu4Zo5iGeltJCUiohDTN7h2aaw30tHN0hxz4XNnp6SDy7v7qSQevqJWFXEm1w
         MLwA==
X-Gm-Message-State: APjAAAXlpT2Cqd7+WmCajcpWDSwPe7emvM0QOa+iRoV8VqitYwoWxOrq
	W0VMA569q+1X/FlcVGc80YnqLnS8h8i88oOSXqwJpWd86wiI6CLDv/lbOb8LM7BjbjH6GHC3TM+
	AQ5gPyNETikNLjUakyuDsGtrqNd6N2fIDJUn5pCaeycFyZZgSFOV1SWmLcDWvfKxmzg==
X-Received: by 2002:ac2:53a5:: with SMTP id j5mr4680444lfh.172.1558967434174;
        Mon, 27 May 2019 07:30:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2GS/KopnyHHrFfW1JqhACKRG7hcq1xSmMfC2o2nYKgIZY2+edVT98bWn4VRJP6X6QN6Cq
X-Received: by 2002:ac2:53a5:: with SMTP id j5mr4680395lfh.172.1558967433382;
        Mon, 27 May 2019 07:30:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558967433; cv=none;
        d=google.com; s=arc-20160816;
        b=pf93UTe349FCWqnHSOWj7dXzTPwq8IlaUBOkrTbjTkQSAvpQ28FM88fUM7sBiqQaCp
         L3h94I/6ngVIugZzINDfcsMKky0SdYHUfr5kLvqlQKnuRIdBR9uKiMj7JTAYMbcM3jqf
         r/RDG4aeKZcm1hLbAG2AFrkSCbjbE80Xwf4kPMkiHiU0wXgIIGk0l0us2IY3hIs3hYGY
         hcdsLirFl2FqQgaevrf6uf5V5kFG9pP5nIN9O7AjnYHmZvdBbAv/nov2tSJgjE4v91za
         5C2lWjiKQ98rEKmy4RTtcICpo37eL1nLd6M+LiB9KBPJPxEEn/MHBjd7nKRCNgirkZUD
         1q7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=7qLRUcrPwsW5zqic4YMh4GiJeUahg2HnH6OlPeS5QxU=;
        b=PhJEbsNrov6XyfN9Ql4REfPG/d22uFib0haqP2BtLNvb9n0qHxM19u1VIbh3K1LQa4
         ASPSEkXISWmIU1r+e4Eg2UJV/kovpfF96/ys3ybLl06TUCgSrVD27+d2QUXcC9KdzlJE
         AiXVA7g4/pu/sY3B6EGz5KjzTZw5HywaGEDucNDNharBjQCZqV632gCkedNZHOjw8whj
         gMMeV4CfvEepXzpi3eOuYUrxRVltZJvIiFuu8ootu9ApTOKtq3vU0hr/zH3UiYjotwFJ
         S3A+SgZhjJxpO/FRYtW1Jo5gsk6OzdWMb1GMgII87SGYBtx6QPChfNnBYbBkg7N15PuY
         XcUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=sZ+nULcN;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [95.108.205.193])
        by mx.google.com with ESMTPS id s22si11796277ljh.180.2019.05.27.07.30.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 07:30:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) client-ip=95.108.205.193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=sZ+nULcN;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id BBD552E0443;
	Mon, 27 May 2019 17:30:32 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id e8Wsdjfvxe-UV5ivtGg;
	Mon, 27 May 2019 17:30:32 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1558967432; bh=7qLRUcrPwsW5zqic4YMh4GiJeUahg2HnH6OlPeS5QxU=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=sZ+nULcNfpXw4488ph8T3fFpY67ss5VqhjNQj6mGo6huQCGDB8dRvy6foEzHo4b76
	 MJwIK5XNb5758igtdz2KoVwMsyi8QgIOH4swDHzKDl/9rL2JcDSLSd/L2nBp1hO+M2
	 LL5GB6yQRSYSm3bnHraLoeqW2e/3FIRnQxb4CG2w=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:d877:17c:81de:6e43])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id I2Oi11RdUk-UV8COmwf;
	Mon, 27 May 2019 17:30:31 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH RFC] mm/madvise: implement MADV_STOCKPILE (kswapd from
 user space)
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Vladimir Davydov <vdavydov.dev@gmail.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>, Roman Gushchin <guro@fb.com>,
 linux-api@vger.kernel.org
References: <155895155861.2824.318013775811596173.stgit@buzz>
 <20190527141223.GD1658@dhcp22.suse.cz> <20190527142156.GE1658@dhcp22.suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <e17e1370-9e88-e50c-94e3-736c122c1baf@yandex-team.ru>
Date: Mon, 27 May 2019 17:30:31 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190527142156.GE1658@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 27.05.2019 17:21, Michal Hocko wrote:
> On Mon 27-05-19 16:12:23, Michal Hocko wrote:
>> [Cc linux-api. Please always cc this list when proposing a new user
>>   visible api. Keeping the rest of the email intact for reference]
>>
>> On Mon 27-05-19 13:05:58, Konstantin Khlebnikov wrote:
> [...]
>>> This implements manual kswapd-style memory reclaim initiated by userspace.
>>> It reclaims both physical memory and cgroup pages. It works in context of
>>> task who calls syscall madvise thus cpu time is accounted correctly.
> 
> I do not follow. Does this mean that the madvise always reclaims from
> the memcg the process is member of?
> 

First it reclaims in its own memcg while limit - usage < requested.
Then repeats this in parent memcg and so on. And at least pokes global
direct reclaimer while system wide free memory is less than requested.

So, if machine is divided into containers without overcommit global
reclaim will never happens - memcg will free enough memory.

