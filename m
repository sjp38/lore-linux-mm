Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13F06C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 16:16:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9080208CA
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 16:16:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9080208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B5EE8E0002; Thu, 13 Jun 2019 12:16:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 565D18E0001; Thu, 13 Jun 2019 12:16:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 454E58E0002; Thu, 13 Jun 2019 12:16:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id EC7168E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:16:06 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o13so6607736edt.4
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 09:16:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=z2PlpbYUAUgabvXSn4QjrWbHGEeXJXjoa6RlgSEKseQ=;
        b=B9ATVxGVQMJ+YsOHnS7+9JoA/3i5mhKTtreXRrUGVajVSqZ4wFDv5N9NGCrCeMgqZ8
         AuJogwEOoQitfEKPRDiKDLL6NMJdk4vUYuIJVWubS+pn9xepJGYlKK3ytASksGcnoWKU
         KiQhYN6M81Z9PQxRuyOJdD4Qf7OrcvphDX2EvS3Ize2vXCMN3aZz1on+vflCF3QCA7YQ
         Wfxe90oRNbXFPK2Ca8LOb0Hl6lOcvgIOgs4WgyNcdZs/7hZUyMNCZShn5igvKItnWbv7
         ADp+pwXGO5JSA2+heW2QmQtAUjYaOh92OV25i0aPm/YF56UDlLK8dPRnW6RprDtpbwXg
         nkzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAW4UzdXBcZNZwYc2JzI7CmRKKdBk+vxk9jZSLMPrs/FJA8LLA3L
	rbJsDPYRV0PdxhqBupfvMVBF0X4vl7uKEmtroDtZ6/0whKe7SBqTSCgKHnMo3MaweFctAOztDz3
	vLJA74uYVUDXoXrXNiQVBX1L+SRbtNidiAAICIQzwcLJeO+2QsoqLjVFEQrKe9yyfgQ==
X-Received: by 2002:a50:b839:: with SMTP id j54mr63434165ede.155.1560442566519;
        Thu, 13 Jun 2019 09:16:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlWTYV+LneQ1Nz2aAR9i66bwJ2rc6Vv3JelxgYwF0h+940phLuyD0eSSYiwSfTirE1iC+C
X-Received: by 2002:a50:b839:: with SMTP id j54mr63434011ede.155.1560442565067;
        Thu, 13 Jun 2019 09:16:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560442565; cv=none;
        d=google.com; s=arc-20160816;
        b=QBjycVGkVUH/D//RiCVaGW/zxC9ohw3BGcNRVPGjY/Fjtiwb3Wp/dYZn3COykjz5Gx
         PKex5/fvPS4pbvkpC/GEgx82Ht7hjhc9t4JXXKhPZjPLufaVRJMT261jlov983iXy8ka
         D4mH4+zdTY3YickTCoqhA0uJbdlC7Ah1dDLPfbdlOQlF+5wpXVSpj7gQuVQ0M094BU+m
         RXbq0CRXkEocAR0t+zC8wZ7/cIXarWZ4wbN0KYfWlEyzw72GqzyeNxR6JUbFEnx7rPin
         iiOopOD08io8J7Ac3sv/Rz+0rZbL0WzRvE27iytUWT64e6+3EA6JGPfMHqKipFw8H3fw
         MFgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=z2PlpbYUAUgabvXSn4QjrWbHGEeXJXjoa6RlgSEKseQ=;
        b=UOujxWBY3icefVE/iQDw9JpqbeP4kh619viJ9n2+1iKpl2bVGujK9B6RD3ICE8KL4x
         zfrD9zjk4W7Eo243M7qAuI3SiOpvQ+lXBm1U81AhzLe+8z+zi2fFln1eEU4WAA/etHph
         FKtBu5FDLhNyySoJGg/j+29GVeZB4MxyeEyHuYhGSvNxgZrV+RbS1TGm5P7DkAOpb4EG
         dfrkKpsUZMx5u73EDruy3wpVOAgTZyPdenSR6zdE4psaeXsbC+uBH5hWaxxTFYHKy2W8
         Bs9nc6o8Eu6xXmCmAjkwzprDVfIhwjDM20c/+3d8zJtyrHF+fxWSnGfUCWakbUSN2xcb
         xcPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id c22si32452eda.76.2019.06.13.09.16.04
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 09:16:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 12AAE367;
	Thu, 13 Jun 2019 09:16:04 -0700 (PDT)
Received: from [10.1.196.72] (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CB5643F694;
	Thu, 13 Jun 2019 09:15:58 -0700 (PDT)
Subject: Re: [PATCH v17 03/15] arm64: Introduce prctl() options to control the
 tagged user addresses ABI
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Dave Martin <Dave.Martin@arm.com>,
 Andrey Konovalov <andreyknvl@google.com>,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
 dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
 linux-media@vger.kernel.org, kvm@vger.kernel.org,
 linux-kselftest@vger.kernel.org, Mark Rutland <mark.rutland@arm.com>,
 Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Will Deacon <will.deacon@arm.com>,
 Kostya Serebryany <kcc@google.com>, Khalid Aziz <khalid.aziz@oracle.com>,
 Felix Kuehling <Felix.Kuehling@amd.com>,
 Jacob Bramley <Jacob.Bramley@arm.com>, Leon Romanovsky <leon@kernel.org>,
 Christoph Hellwig <hch@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>,
 Evgeniy Stepanov <eugenis@google.com>, Kevin Brodsky
 <kevin.brodsky@arm.com>, Kees Cook <keescook@chromium.org>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Alex Williamson <alex.williamson@redhat.com>,
 Mauro Carvalho Chehab <mchehab@kernel.org>,
 Dmitry Vyukov <dvyukov@google.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Yishai Hadas <yishaih@mellanox.com>,
 Jens Wiklander <jens.wiklander@linaro.org>, Lee Smith <Lee.Smith@arm.com>,
 Alexander Deucher <Alexander.Deucher@amd.com>,
 Andrew Morton <akpm@linux-foundation.org>, enh <enh@google.com>,
 Robin Murphy <robin.murphy@arm.com>,
 Christian Koenig <Christian.Koenig@amd.com>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
References: <cover.1560339705.git.andreyknvl@google.com>
 <a7a2933bea5fe57e504891b7eec7e9432e5e1c1a.1560339705.git.andreyknvl@google.com>
 <20190613111659.GX28398@e103592.cambridge.arm.com>
 <20190613153505.GU28951@C02TF0J2HF1T.local>
 <99cc257d-5e99-922a-fbe7-3bbaf3621e38@arm.com>
 <20190613155754.GX28951@C02TF0J2HF1T.local>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <e481dbf9-880e-c77e-5200-1dbc35be7a48@arm.com>
Date: Thu, 13 Jun 2019 17:15:57 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190613155754.GX28951@C02TF0J2HF1T.local>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 13/06/2019 16:57, Catalin Marinas wrote:
> On Thu, Jun 13, 2019 at 04:45:54PM +0100, Vincenzo Frascino wrote:
>> On 13/06/2019 16:35, Catalin Marinas wrote:
>>> On Thu, Jun 13, 2019 at 12:16:59PM +0100, Dave P Martin wrote:
>>>> On Wed, Jun 12, 2019 at 01:43:20PM +0200, Andrey Konovalov wrote:
>>>>> +
>>>>> +/*
>>>>> + * Control the relaxed ABI allowing tagged user addresses into the kernel.
>>>>> + */
>>>>> +static unsigned int tagged_addr_prctl_allowed = 1;
>>>>> +
>>>>> +long set_tagged_addr_ctrl(unsigned long arg)
>>>>> +{
>>>>> +	if (!tagged_addr_prctl_allowed)
>>>>> +		return -EINVAL;
>>>>
>>>> So, tagging can actually be locked on by having a process enable it and
>>>> then some possibly unrelated process clearing tagged_addr_prctl_allowed.
>>>> That feels a bit weird.
>>>
>>> The problem is that if you disable the ABI globally, lots of
>>> applications would crash. This sysctl is meant as a way to disable the
>>> opt-in to the TBI ABI. Another option would be a kernel command line
>>> option (I'm not keen on a Kconfig option).
>>
>> Why you are not keen on a Kconfig option?
> 
> Because I don't want to rebuild the kernel/reboot just to be able to
> test how user space handles the ABI opt-in. I'm ok with a Kconfig option
> to disable this globally in addition to a run-time option (if actually
> needed, I'm not sure).
> 
There might be scenarios (i.e. embedded) in which this is not needed, hence
having a config option (maybe Y by default) that removes from the kernel the
whole feature would be good, obviously in conjunction with the run-time option.

Based on my previous review, if we move out the code from process.c in its own
independent file when the Kconfig option is turned off we could remove the
entire object from the kernel (this would remove the sysctl and let still the
prctl return -EINVAL).

These changes though could be done successively with a separate patch set, if
the Kconfig is meant to be Y by default.

-- 
Regards,
Vincenzo

