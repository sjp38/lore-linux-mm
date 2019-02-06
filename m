Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E89B1C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:07:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD642218D2
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:07:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD642218D2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A4C78E00F4; Wed,  6 Feb 2019 15:07:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2534A8E00F3; Wed,  6 Feb 2019 15:07:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 145968E00F4; Wed,  6 Feb 2019 15:07:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B12358E00F3
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 15:07:43 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id b3so3359436edi.0
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 12:07:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=rYR+gofUPivLrJOJnOLoY7ZOD4ika98cSXfVGyjeRTA=;
        b=Lo2B9dNyk0YYdXHsZ8bsa2Vq8oNYgwSJ/QvpBeTvtz6G5l16CTu2QlwfFj7N78QVdz
         MRrDYVb4m7R35b5/FM+dAq8wB+dLKUD8sSMzc/Z2hca5gY/NrU+7l90GiYnzjhgUN2UF
         mTYfryFaTs7V0bu56b7QZA+grads4OKzh/JAT83VRoWZC0pW3SYjcKY3Sa/GHf48nmsa
         0UqbWY2nGHG+MdCeE/cnWvHhbeKeOtRcAP+lDFgMnJ9yLrsSfdWSm1UPSzjwUgidKHoO
         4YMEclVNZ9pZd0dTz8YjfF/7fPb4aSgzNvIBbymFDlREscwfHnA+jVI/A4ijLxbgmF1r
         J5Fw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: AHQUAuZid0NEdfS3X9QNs7Ci2VIkT/2d5xO8j/JpmJ0+Ggnq2u+MWxNy
	s8jyXrNKWyCSUCSTJP82/IGDnRS8c02MVuqMAsHhwBB1OdJEbZp8AB6D3Xg2Ve8mRTy9C0x/rf4
	egFtBCP0j4XNfnDGhrjlnymxy+YvuI+YkxutN3xhU0yyIQuGASBYSIyKY0Ylm9D9RnQ==
X-Received: by 2002:aa7:dc4b:: with SMTP id g11mr7986545edu.140.1549483663244;
        Wed, 06 Feb 2019 12:07:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbNOR4t8VAbKt3CCU5/5cUi5j0U8LvS1jMYFx8mUAuN/QDxvuTVVuVr3BrMYq54Jvr1hUZx
X-Received: by 2002:aa7:dc4b:: with SMTP id g11mr7986519edu.140.1549483662438;
        Wed, 06 Feb 2019 12:07:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549483662; cv=none;
        d=google.com; s=arc-20160816;
        b=RJrGmCCHcNDre4fqewHlC5cYD2I0y/9Ua4QBuLVUKgWUar1bdURcbpNGU1BlMUyiuR
         qidyVZswW3XpOyPMXPC1i1g7Sc2VcymJ1sbXozgmFRjfEnhFETStxH+yr1na45mbms0z
         I31yXaCE+MZY1akHQkCYwXdDtq9BGOT7MXkbQ5z53+ey0/2n5lSTWNfEQ7KsJyUaQSlP
         y7aphtTfxKCzT88bCpaIXGfPEC75UNK3UoPRSnJbkaWFt26XnzHH3+Q8kTfSFtEPi9XF
         cNWHFN/9ujtQn+RV7M2UujZI3am9MX4bEJadjU48yoQC/rL3/mhjAe/z97xPDujZfCqF
         0KfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=rYR+gofUPivLrJOJnOLoY7ZOD4ika98cSXfVGyjeRTA=;
        b=SqtDPMBCjMloxf+fVfjWobotX9kQIA8JUd2WWG2HhZFGVyjc3hZ7Mj/+7GWvV0j92E
         a4CJSQgp9H5DwwqBfMeyuduhMUnziIcaB2DuAzKb0/OtJ8c//bufayEbvEWIAw55SscH
         KaQ199vT5u7350LUGtQ1oV7XiOnKsElqTqoe9tk/P+QE3mPc0NR0eiIsERLZ6KXRL8F+
         d5cRLehQxoVG60ybQkL6QkFSctf5QGQ8vA9snvg8xXNiTHAgUuZjBV1QIMnPpRXH2nPp
         TDSEO1/w9W/8Z65gM3GBwFQLtVvkPgvF9xcvUFaNWkajoaHyRnBVCDINhYaxDo87xzK3
         tGwA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c12si2977842ede.4.2019.02.06.12.07.41
        for <linux-mm@kvack.org>;
        Wed, 06 Feb 2019 12:07:42 -0800 (PST)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1EFAF80D;
	Wed,  6 Feb 2019 12:07:41 -0800 (PST)
Received: from [192.168.1.123] (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 87B063F719;
	Wed,  6 Feb 2019 12:07:39 -0800 (PST)
Subject: Re: [PATCH] mm/memory-hotplug: Add sysfs hot-remove trigger
To: Greg KH <gregkh@linuxfoundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rafael@kernel.org,
 mhocko@kernel.org, akpm@linux-foundation.org
References: <29ed519902512319bcc62e071d52b712fa97e306.1549469965.git.robin.murphy@arm.com>
 <20190206184544.GA12326@kroah.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <e73cf364-2034-2312-8ef9-c24d341f8f71@arm.com>
Date: Wed, 6 Feb 2019 20:07:28 +0000
User-Agent: Mozilla/5.0 (Windows NT 10.0; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190206184544.GA12326@kroah.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-02-06 6:45 pm, Greg KH wrote:
> On Wed, Feb 06, 2019 at 05:03:53PM +0000, Robin Murphy wrote:
>> ARCH_MEMORY_PROBE is a useful thing for testing and debugging hotplug,
>> but being able to exercise the (arguably trickier) hot-remove path would
>> be even more useful. Extend the feature to allow removal of offline
>> sections to be triggered manually to aid development.
>>
>> Signed-off-by: Robin Murphy <robin.murphy@arm.com>
>> ---
>>
>> This is inspired by a previous proposal[1], but in coming up with a
>> more robust interface I ended up rewriting the whole thing from
>> scratch. The lack of documentation is semi-deliberate, since I don't
>> like the idea of anyone actually relying on this interface as ABI, but
>> as a handy tool it felt useful enough to be worth sharing :)
>>
>> Robin.
>>
>> [1] https://lore.kernel.org/lkml/22d34fe30df0fbacbfceeb47e20cb1184af73585.1511433386.git.ar@linux.vnet.ibm.com/
>>
>>   drivers/base/memory.c | 42 +++++++++++++++++++++++++++++++++++++++++-
>>   1 file changed, 41 insertions(+), 1 deletion(-)
> 
> You have to add new Documentation/ABI entries for each new sysfs file
> you add :(

Ah, the documentation provided is adapted from the documentation for the 
existing "probe" attribute it builds upon ;)

But yeah, perhaps I should have tagged this post as an RFC. Much as I 
dislike it being anywhere near an ABI, if everyone thinks the feature is 
merge-worthy I'll go ahead and write up some proper doc entries too.

Robin.

