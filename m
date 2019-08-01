Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EF1FC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 12:38:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0085C20644
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 12:38:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0085C20644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D2778E0011; Thu,  1 Aug 2019 08:38:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85CF88E0001; Thu,  1 Aug 2019 08:38:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FE108E0011; Thu,  1 Aug 2019 08:38:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 209EB8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 08:38:15 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y3so44717369edm.21
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 05:38:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=FGqFsvMxdwHLi/i98DdZLnfv4f3Ll3j2BcnZJ8sgLAM=;
        b=ujSWd7dm3M+67+AdGuCae1YRFFF1q16jzq1a1rHGgqY4wK7ocCsoE8dYbYN9+2j1N9
         oIYyvrRzqOHVx2lFa08VZeR2bxxCrq88BqDTynfVps7gqIez6M2raoczsL/Sc7Y4UFt1
         HjOqqrwb7BckDr2j6ri29+7KzZuBPcUP/YGtjgyLrmEpR2LhtqlvFQvcaxJjUIYRl6ht
         U4Gw7zNsreXZdjCazCC/DZ6HlO7FkTgB/TNu7YL17/Mh1K3KKMkclByYjV2LykYiryCi
         rMkR57uhGqbT5kAEKMrnL1B6Rc3y0GX/S44VeQgwHrXMVt9AoNk2QzdvfjmVxMhMSIex
         wnQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
X-Gm-Message-State: APjAAAW5+sP8ZJ4cCkoRw35E9fc+wSylnjaxM9jMDxJBJCvsXTd+/DRT
	K1C61ZmIhGAen6cXf8uc0SC/NNqxK2bHOfa+Ed2YA0kJAJVXCYd/5s+GSauk2fN3t6n4xESxQLQ
	0r3ato+sWqnWoe+RbTg1UvOAIbb5InMd3EFWVo0AC3lc/HfHpTyj/noTq9/WUag1WEA==
X-Received: by 2002:a50:b635:: with SMTP id b50mr112380667ede.293.1564663094710;
        Thu, 01 Aug 2019 05:38:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgGG6719610bXb97lzQh1JZkpfyJiaY0GzyGldX140fX/f8VNLsQ+YJhN82cTThyg/NruA
X-Received: by 2002:a50:b635:: with SMTP id b50mr112380612ede.293.1564663094053;
        Thu, 01 Aug 2019 05:38:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564663094; cv=none;
        d=google.com; s=arc-20160816;
        b=qw3fPNr2crymTDQMM1yhrg3wy3GcjMLPd+seUESRYI3mub0sYIHn6x6yLp3dgXRISC
         yYUn/mtqFbIOrFAbQ3weQqLhin9F6VMuE1DEO8lEh/I1+gvLGklklYF22av0m/Dll0PJ
         FZ2fvbmc144wjibRAUN7d7aavN82EWTWFW0ObB/sKiLocO/XHda80pzUeWS3IbGghUfP
         5O7lasMbjwn39oar/qWFCUee7dxYQ+z7ACBdZ+ORWcP8Hx9pJmuWpuquX8N7UEBMZNMA
         i0xqpgGLUBCUTH30xJNGrpI61MeU1Fj5N7dYxhtRGrb1K4VQLWwjPgsJB4OzL7KHw8Iq
         DynA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=FGqFsvMxdwHLi/i98DdZLnfv4f3Ll3j2BcnZJ8sgLAM=;
        b=EwKW/Emo/TRc9OJwsqvb4KF4T+aI7db3QGBHH6dGcksYgSnMqB3x4xMnIhbJEvuG49
         kOZo0qzyIq6PZqUvoK+ah+wGD5u+VS6szZAjB7N+YRULogg047gkb5C8QET0pA293PrJ
         F2OuxI0MtjlVQcl2dBYpsebf6oKo4HWkbcsVM6ICYG+Q3iDH+unO3VRM1RKxISUNeTG2
         /M7BL1yEjHxYjEtpX9TOlYNL/CgY3lfmPYNR1mbLWmKqucWvrHqBbw8cDXb6TblrhTav
         Y3BtHgsgp/n/VN4YD08x8NALJPpL50WUgt0snyEEVQ3qhaeENAq8V12bZki8AgW89vxi
         lPhw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id e17si23289780ede.425.2019.08.01.05.38.13
        for <linux-mm@kvack.org>;
        Thu, 01 Aug 2019 05:38:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EA8AC1570;
	Thu,  1 Aug 2019 05:38:12 -0700 (PDT)
Received: from [10.1.194.48] (e123572-lin.cambridge.arm.com [10.1.194.48])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E84103F575;
	Thu,  1 Aug 2019 05:38:07 -0700 (PDT)
Subject: Re: [PATCH v19 02/15] arm64: Introduce prctl() options to control the
 tagged user addresses ABI
To: Dave Hansen <dave.hansen@intel.com>,
 Andrey Konovalov <andreyknvl@google.com>,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
 dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
 linux-media@vger.kernel.org, kvm@vger.kernel.org,
 linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>,
 Vincenzo Frascino <vincenzo.frascino@arm.com>,
 Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>,
 Felix Kuehling <Felix.Kuehling@amd.com>,
 Alexander Deucher <Alexander.Deucher@amd.com>,
 Christian Koenig <Christian.Koenig@amd.com>,
 Mauro Carvalho Chehab <mchehab@kernel.org>,
 Jens Wiklander <jens.wiklander@linaro.org>,
 Alex Williamson <alex.williamson@redhat.com>,
 Leon Romanovsky <leon@kernel.org>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
 Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>,
 enh <enh@google.com>, Jason Gunthorpe <jgg@ziepe.ca>,
 Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>,
 Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>,
 Lee Smith <Lee.Smith@arm.com>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Jacob Bramley <Jacob.Bramley@arm.com>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Robin Murphy <robin.murphy@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
References: <cover.1563904656.git.andreyknvl@google.com>
 <1c05651c53f90d07e98ee4973c2786ccf315db12.1563904656.git.andreyknvl@google.com>
 <7a34470c-73f0-26ac-e63d-161191d4b1e4@intel.com>
From: Kevin Brodsky <kevin.brodsky@arm.com>
Message-ID: <2b274c6f-6023-8eb8-5a86-507e6000e13d@arm.com>
Date: Thu, 1 Aug 2019 13:38:06 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <7a34470c-73f0-26ac-e63d-161191d4b1e4@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 31/07/2019 18:05, Dave Hansen wrote:
> On 7/23/19 10:58 AM, Andrey Konovalov wrote:
>> +long set_tagged_addr_ctrl(unsigned long arg)
>> +{
>> +	if (!tagged_addr_prctl_allowed)
>> +		return -EINVAL;
>> +	if (is_compat_task())
>> +		return -EINVAL;
>> +	if (arg & ~PR_TAGGED_ADDR_ENABLE)
>> +		return -EINVAL;
>> +
>> +	update_thread_flag(TIF_TAGGED_ADDR, arg & PR_TAGGED_ADDR_ENABLE);
>> +
>> +	return 0;
>> +}
> Instead of a plain enable/disable, a more flexible ABI would be to have
> the tag mask be passed in.  That way, an implementation that has a
> flexible tag size can select it.  It also ensures that userspace
> actually knows what the tag size is and isn't surprised if a hardware
> implementation changes the tag size or position.
>
> Also, this whole set deals with tagging/untagging, but there's an
> effective loss of address space when you do this.  Is that dealt with
> anywhere?  How do we ensure that allocations don't get placed at a
> tagged address before this gets turned on?  Where's that checking?

This patch series only changes what is allowed or not at the syscall interface. It 
does not change the address space size. On arm64, TBI (Top Byte Ignore) has always 
been enabled for userspace, so it has never been possible to use the upper 8 bits of 
user pointers for addressing.

If other architectures were to support a similar functionality, then I agree that a 
common and more generic interface (if needed) would be helpful, but as it stands this 
is an arm64-specific prctl, and on arm64 the address tag is defined by the 
architecture as bits [63:56].

Kevin

