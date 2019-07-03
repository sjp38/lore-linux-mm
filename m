Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD1BBC06513
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 12:59:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 545D2218A3
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 12:59:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HGdp+1HC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 545D2218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=roeck-us.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90F278E0001; Wed,  3 Jul 2019 08:59:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BF166B0005; Wed,  3 Jul 2019 08:59:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AD408E0001; Wed,  3 Jul 2019 08:59:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 47F816B0003
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 08:59:06 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id u1so601824pgr.13
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 05:59:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:subject:to:cc:references
         :from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ouWnXLxg4ztxXDt/TZujciYyAwrslehJzaThxzlNGEc=;
        b=S76SUN8Szt+FFdrLuNLFRZeXNBY/H9EVUgujgSUf2Qv0sDn8XEC+flGD0sykLMG6+p
         hW+mBFVtnDFdFgMqazz0um8MrKVd0rg70hdwWm8ewdtIS/MU9kG9IXmL8M3mxwcDLDH4
         vg53yJ6cwVDr30cVm7/5uS0DTQYQWD4N7yjUnTxn5NVxNuLZP9fQmAGGn1MFc6a3IETb
         juJ2H0UJnaPeBghulrWyUUD+Aenb/8ab6YvKGA6p/lFMNwejyzdu3xDYkwuDn7QycU5Y
         J3hr5KEELzeMWa81qN+0tbQR23R59tlkARDbaqQloQ3qkDyyHQ9BtowRMHvEnq+JM3Tw
         ghtg==
X-Gm-Message-State: APjAAAXv1YHYkKpsGy0maQnzdrZkyofLu3bzKvitn3nfA/djsBppeAKV
	3CDJmScgz9uIA+zGH5vC7B24+JRtQufL3OGvN+bwnU43i1DwrRQ18iMLUEZWnr/IlUQeeJfl8LO
	GsfQGjkXcn8xQeUfWKfYUO55egkcJBMWdnVhMFOQH6bn8RHJ+NproTORDYEz1rvQ=
X-Received: by 2002:a17:90a:17ab:: with SMTP id q40mr1364332pja.106.1562158745795;
        Wed, 03 Jul 2019 05:59:05 -0700 (PDT)
X-Received: by 2002:a17:90a:17ab:: with SMTP id q40mr1364264pja.106.1562158745023;
        Wed, 03 Jul 2019 05:59:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562158745; cv=none;
        d=google.com; s=arc-20160816;
        b=gMVCfmCeht8yACTZzuIFgl7uAV79yxs7X2WqVyRYK2gkjPFBfRtTGQYXJ24mmdNjKv
         9JU4SPoLE65L81qOU9u6iAIgeUAK18AFoocjPDmz1Q5VEb4JD4TKShWIeGHTRM5h5UBf
         8S/hjjcLcjP3NPkQNZF6LJLvZ0jz2ZuvhpA4zvf8njozxX1nbVxnEtqndyydjRadtber
         iYiXMDgArNxmH03goaFuvF3JTlbgZKsnfn2bQofg/XZ2HFBzxUYaEX3G1tsOST4iqzZN
         ptOMKf6i3LA9RpRfDYJm+LnWUi55tvsv1oBz0GxFFYi6deGg8VAebCyAZi2bWxrY03ks
         rv2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject:sender
         :dkim-signature;
        bh=ouWnXLxg4ztxXDt/TZujciYyAwrslehJzaThxzlNGEc=;
        b=pIMx03eFHS7gcd96Kn82ySY8mevWFljFtoz437Hm7JGzwtMcA8GzaRFWrBbEELgYFo
         WNtQKcMJLnLLt6qIWcGAm20yXGjaLw1Zo7UH/6KXEnyXfm593W4qxakmmqUZdbZMofgK
         0v6W4/d8HTVlOds4QXkj2jislCDp9x7rpOg+J1Z+yilPT8QLcd+mCN6w9lTwEO6YIuPa
         HUUtinRF2JycKZDgFtmsX4xE5JqybqfcVHeoQ7lhxjqdU9REurc9seKCZ+/fQbiKAHPP
         J3YjfHzs7yNXQAyMfcvMzuA3SPjfcSt/3ADK8cw/0jf1U7NXs47SblNrEOdAC8X/T4Ya
         mj1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HGdp+1HC;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ck8sor2505564pjb.22.2019.07.03.05.59.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jul 2019 05:59:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HGdp+1HC;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=ouWnXLxg4ztxXDt/TZujciYyAwrslehJzaThxzlNGEc=;
        b=HGdp+1HCA6NLpYs1SV4MGO79EIiZsu2RxQpweguODv+FXyPE610/hIXbBrjYbhUpaa
         x8cSkuvCPLc5FMRap0UqSVSd8QTlrYvuAmYmNHFzazFt830f1bztjpvxWMa9lCV+SiLB
         FouMvabY6r1nYWSSJ8LDrv9/uZcWZk1Go0iSwjOCTZSo+nyPw3dsgakWDt+UDPDn+lDt
         tIszfU/UB97eOYB+s2UqZjvRHvjnvlCiWz+N6+rxuyY+5cmIz4H5l0l3JNTC4pL8M0Hw
         f7PfxA6BoLuhaVUoS6/ZUCVvTY6F2IdFjzGyEnViDCrfXplSlEy0US/iHuv8zHQhYJBd
         VnWQ==
X-Google-Smtp-Source: APXvYqxFTji1JG+3QVruvwDkAscN+e2dBfknvjPHa8Ff9O+QoFcmuk4Wi3S9TrXVvQpsIpUNdM8ZKg==
X-Received: by 2002:a17:90a:3463:: with SMTP id o90mr12935683pjb.15.1562158744663;
        Wed, 03 Jul 2019 05:59:04 -0700 (PDT)
Received: from server.roeck-us.net ([2600:1700:e321:62f0:329c:23ff:fee3:9d7c])
        by smtp.gmail.com with ESMTPSA id u65sm9916014pjb.1.2019.07.03.05.59.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 05:59:03 -0700 (PDT)
Subject: Re: [DRAFT] mm/kprobes: Add generic kprobe_fault_handler() fallback
 definition
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org
References: <78863cd0-8cb5-c4fd-ed06-b1136bdbb6ef@arm.com>
 <1561973757-5445-1-git-send-email-anshuman.khandual@arm.com>
 <8c6b9525-5dc5-7d17-cee1-b75d5a5121d6@roeck-us.net>
 <fc68afaa-32e1-a265-aae2-e4a9440f4c95@arm.com>
From: Guenter Roeck <linux@roeck-us.net>
Message-ID: <8a5eb5d5-32f0-01cd-b2fe-890ebb98395b@roeck-us.net>
Date: Wed, 3 Jul 2019 05:59:01 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <fc68afaa-32e1-a265-aae2-e4a9440f4c95@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/2/19 10:35 PM, Anshuman Khandual wrote:
> 
> 
> On 07/01/2019 06:58 PM, Guenter Roeck wrote:
>> On 7/1/19 2:35 AM, Anshuman Khandual wrote:
>>> Architectures like parisc enable CONFIG_KROBES without having a definition
>>> for kprobe_fault_handler() which results in a build failure. Arch needs to
>>> provide kprobe_fault_handler() as it is platform specific and cannot have
>>> a generic working alternative. But in the event when platform lacks such a
>>> definition there needs to be a fallback.
>>>
>>> This adds a stub kprobe_fault_handler() definition which not only prevents
>>> a build failure but also makes sure that kprobe_page_fault() if called will
>>> always return negative in absence of a sane platform specific alternative.
>>>
>>> While here wrap kprobe_page_fault() in CONFIG_KPROBES. This enables stud
>>> definitions for generic kporbe_fault_handler() and kprobes_built_in() can
>>> just be dropped. Only on x86 it needs to be added back locally as it gets
>>> used in a !CONFIG_KPROBES function do_general_protection().
>>>
>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>>> ---
>>> I am planning to go with approach unless we just want to implement a stub
>>> definition for parisc to get around the build problem for now.
>>>
>>> Hello Guenter,
>>>
>>> Could you please test this in your parisc setup. Thank you.
>>>
>>
>> With this patch applied on top of next-20190628, parisc:allmodconfig builds
>> correctly. I scheduled a full build for tonight for all architectures.
> 
> How did that come along ? Did this pass all build tests ?
> 

Let's say it didn't find any failures related to this patch. I built on top of
next-20190701 which was quite badly broken for other reasons. Unfortunately,
next-20190702 is much worse, so retesting would not add any value at this time.
I'd say go for it.

Guenter

