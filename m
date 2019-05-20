Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C6BFC072A4
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:37:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09D7C2081C
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:37:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09D7C2081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86BF76B0005; Mon, 20 May 2019 01:37:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81C656B0006; Mon, 20 May 2019 01:37:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70B8E6B0007; Mon, 20 May 2019 01:37:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 21DFD6B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 01:37:29 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g36so23408647edg.8
        for <linux-mm@kvack.org>; Sun, 19 May 2019 22:37:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=LPCWNZfHJ1TBRaQtT7r2vBNATMbXaJLaTNvqzCOtn3E=;
        b=I0456xvKOYWHVLgXZSvNFiff13uodoGtroA6YAztA0ftNg7OYhnneY/LfAarR8ex7K
         U5TRXozUX77NmMfNpdUCh/GT8pPCsOjFoIQI0TpswgQf68kwelEfGDYQDPGyUxQU3P8p
         YntWQoYJMCBfyV8JO/6nbqCz7Ek/3OFVV5nygfudA4WxZNQuzjVRWGkz4K8XDW2mCMCV
         XYpTSmg0yds/qmGoF1VfV9aHlB2rMv93iNu5OXm0uik6Fj9ZLfnQ3afAPNvmL6GG2B9z
         wVXFjZzsWo954LPRX3QW1an5+ugnFKVW7VzMtJNYLhJwPo1vbo3MqUmssjD6ncC9w4FA
         WvzA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXuULNoTmYgydJ9oaqVHi9QTnVKkm0QcYwUONrhzzyu041SOs3h
	wKRKOX/6RCJ9frxnt0v3Kyst/79KSYJyu6SxEj8p0jWEtrAQNQU7Gnrf33iseFDuCXBtT1VwfIk
	15a+2xJDxk3viMht9q5LibA0uofW/q9vx3ZtnYoVrHlr6RikEzore8S3XMVnmgtINaQ==
X-Received: by 2002:a17:906:e282:: with SMTP id gg2mr1960321ejb.38.1558330648587;
        Sun, 19 May 2019 22:37:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzE7Ivq2uqC9M39vMy2kq/bL3Y604Mnpy43BSz22bR8uNbzS7vsm8/mHVMtZxs2LptMnT/i
X-Received: by 2002:a17:906:e282:: with SMTP id gg2mr1960288ejb.38.1558330647848;
        Sun, 19 May 2019 22:37:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558330647; cv=none;
        d=google.com; s=arc-20160816;
        b=kWHDUPpFk+/1xwQM9GJreENVpibM+OAy4LlWrp0vbY5EbHF4lev8KrQFOnstQQFZlS
         tTaIZkwpzt5W98mtPox+61T/QwC9Qyv0tZZMRna10ZzaBQR+91CQQA/WwFDELp1V/y3a
         F4QE3eBR61k4kTLBEXX4mVrfdr8/3WI3Lb/wl84SCtsiwQLDQaCfnwdLx8rMO9AaFMXB
         FOL8c/rxovOhaChBn6lsjXCt8n3xq3jEPV1fWcuHmcxpAX3rGaFZV/EcuHnQvDh5j8uk
         c+cvTgYND+y3Nd6xXA5S5HmDTJB8oNOgNRQKVgIOrBf6L0KqRNTLFXerNOwQ+K99gsww
         viPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=LPCWNZfHJ1TBRaQtT7r2vBNATMbXaJLaTNvqzCOtn3E=;
        b=FENoKbU25qnlzGLZBjEKfkpAMm3ymuDwTa4LBw0Wp4cbBHb3+QYzwcpN4FFAAJ/f6L
         JaFD2F7lw0RD0spzbAgboyo53GXghT/1PM+HM/joNyysIo6A/i1UwbjKNVJhdAQ4sHvl
         2mJPjBRCx2DcDUFgtsXjMsWRk1IZ3Vp1LVrW29TdDWJF/VJxQ24raweg95ltEgNGyCIZ
         moSJ8CW26X/qdjwBRfhlAcz5BZE28ZTLVQfBiPOd1KhBhrdat1FBtvFBjBlD/b7xBq8Z
         G36aChMbmoruY2ohYpKREJz1rL4ZN4RxZ5Erzubx/kctyjQNUM4jG9l+EyDJZ8tW1olu
         fotQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d41si5093329ede.19.2019.05.19.22.37.27
        for <linux-mm@kvack.org>;
        Sun, 19 May 2019 22:37:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9293180D;
	Sun, 19 May 2019 22:37:26 -0700 (PDT)
Received: from [10.162.41.132] (p8cg001049571a15.blr.arm.com [10.162.41.132])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BA61F3F5AF;
	Sun, 19 May 2019 22:37:24 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH] mm/dev_pfn: Exclude MEMORY_DEVICE_PRIVATE while computing
 virtual address
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 dan.j.williams@intel.com, jglisse@redhat.com, ldufour@linux.vnet.ibm.com
References: <1558089514-25067-1-git-send-email-anshuman.khandual@arm.com>
 <20190517145050.2b6b0afdaab5c3c69a4b153e@linux-foundation.org>
Message-ID: <cb8cbd57-9220-aba9-7579-dbcf35f02672@arm.com>
Date: Mon, 20 May 2019 11:07:38 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190517145050.2b6b0afdaab5c3c69a4b153e@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05/18/2019 03:20 AM, Andrew Morton wrote:
> On Fri, 17 May 2019 16:08:34 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:
> 
>> The presence of struct page does not guarantee linear mapping for the pfn
>> physical range. Device private memory which is non-coherent is excluded
>> from linear mapping during devm_memremap_pages() though they will still
>> have struct page coverage. Just check for device private memory before
>> giving out virtual address for a given pfn.
> 
> I was going to give my standard "what are the user-visible runtime
> effects of this change?", but...
> 
>> All these helper functions are all pfn_t related but could not figure out
>> another way of determining a private pfn without looking into it's struct
>> page. pfn_t_to_virt() is not getting used any where in mainline kernel.Is
>> it used by out of tree drivers ? Should we then drop it completely ?
> 
> Yeah, let's kill it.
> 
> But first, let's fix it so that if someone brings it back, they bring
> back a non-buggy version.

Makes sense.

> 
> So...  what (would be) the user-visible runtime effects of this change?

I am not very well aware about the user interaction with the drivers which
hotplug and manage ZONE_DEVICE memory in general. Hence will not be able to
comment on it's user visible runtime impact. I just figured this out from
code audit while testing ZONE_DEVICE on arm64 platform. But the fix makes
the function bit more expensive as it now involve some additional memory
references.

