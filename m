Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A11B0C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 14:19:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C89A20B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 14:19:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C89A20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 066686B026C; Thu, 13 Jun 2019 10:19:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 016AB6B026D; Thu, 13 Jun 2019 10:19:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF9646B0271; Thu, 13 Jun 2019 10:19:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A62916B026C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:19:06 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 5so14552049pff.11
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 07:19:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=3NRfY4+RCw5r8+MRbYiPdea1Ru4mYlcz4Bt+vnw5PzI=;
        b=sTBZ2wmDId/ZaiT0fV6jrRP3tz2KAJ8mCIx16tPpOZzodh9eaRlsvv9LXpXAIv7Fj5
         q/aH4Jx/jm0ItVwu0AvJHofJhosBBdfz47qbOXLJKOfFBkjo5bNpq2t5dTZJIjyqqrZM
         3CYhF95u+TRFVrstAqN3Z0olU8LVL1EFm0rNmOzWIvYoQVLr2Q7CjLRa73/f4vF8pUk+
         yiMSZW/PwONGjZpJQFbXzpVDD4uYN3GBOBBCCQ6MvXBo4DI/WWoTuhI+R04XvnQ9u6mO
         PLTCFsXUXEPXr+qIR1eexigCJZ2G5hB3wb59cLNtDFBvY+haZD4DEMjYUR3rsmdskX1a
         iiCA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXZ7okbiS1aXbKtBNDw4onivHrGB0F/l7/Jh+7qmWNvalYVLAwl
	l4vTkKhcrIM6q1sbEa8Ohz5Zg74kAl4Wie+AnwUaPMiAPyu6PNJgHQ3HoggH4l/pUmZyRlUbVrr
	UD+rGoiUpUt9FRh3w2lWY2OsG/yfqXGnKGPTIq3kHwOWkexL1IqH3mS3FhgMO0aeZSw==
X-Received: by 2002:a63:1d5c:: with SMTP id d28mr30604159pgm.10.1560435546280;
        Thu, 13 Jun 2019 07:19:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4YiUVFajZ93ZO54HHc9Dxg9gsFn57sJ/8P+hRyth9IRGiyZt+H1HOpjRQ3O1lK6KFI7Y/
X-Received: by 2002:a63:1d5c:: with SMTP id d28mr30604114pgm.10.1560435545543;
        Thu, 13 Jun 2019 07:19:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560435545; cv=none;
        d=google.com; s=arc-20160816;
        b=AjrBJQ/Gry8KXN3CEJYl8gnnTH43xbTMm3bYwFXc4ZBjmy2Q9rrJWqio+jzWDTjPIs
         uX1neLG0KXE0yi7x7mSqZ86zTASelNEkMqAvib8VGL5Dn40L0Y6QBLNw+px3BWYYFYBb
         GbLOU2QjjA70cM7IU7gn97scISFkmUV+rqyYfJVr6049zsDkmEDSwXTLB8S6of2waV5J
         zsDCQAlPJDhgzQxU+SGtXJkcyfvdwZ8kBRiVNlBG7zeh4awLut9qJs6+CNmKElIUlCqh
         03pzDTKQZ14Rt5gjvXdDKwZvgCADUMeN57gRo9AveCTn5QT1yAKxc6UGLccPjgMvAWYK
         LsOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=3NRfY4+RCw5r8+MRbYiPdea1Ru4mYlcz4Bt+vnw5PzI=;
        b=Lr/B+ouYXPLW5t8DqQ6ZV31yaYcBlz+jli5ZiZjf8peDv0OrzWJwDF32hCQbQQfsHI
         pgp52fdX77mkoOpu3bWT2dEgUssWjRl4Is5ASUF4FD5ePrtuwRBLF4PCcIAubDs/XZUk
         9uZ4xyMVeYDDselHHxHnMu7EvOCybElf5y1rhj5foJBzNV1h6TzLMw6hV2Y1wKGmeW+5
         JS0xAJ4Oxo+zNjrOUeH/07bpChQYxR7q5ijPIx1K/zY3QFXI96NoFQ775bZJMQN5ZHNs
         qnXvbdgPtwB2xylKUsmV6t6KO/Ke3vRMf+szoCrSBEn8fihZmIxVhWiVEmST9yz+Zn8e
         JpmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id q2si1948860plh.56.2019.06.13.07.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 07:19:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Jun 2019 07:19:04 -0700
X-ExtLoop1: 1
Received: from enagarix-mobl.amr.corp.intel.com (HELO [10.251.15.213]) ([10.251.15.213])
  by orsmga004.jf.intel.com with ESMTP; 13 Jun 2019 07:19:02 -0700
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM
 secrets
To: Alexander Graf <graf@amazon.com>, Marius Hillenbrand
 <mhillenb@amazon.de>, kvm@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com,
 linux-mm@kvack.org, Alexander Graf <graf@amazon.de>,
 David Woodhouse <dwmw@amazon.co.uk>,
 the arch/x86 maintainers <x86@kernel.org>, Andy Lutomirski
 <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>
References: <20190612170834.14855-1-mhillenb@amazon.de>
 <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
 <54a4d14c-b19b-339e-5a15-adb10297cb30@amazon.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <7b17ff38-b505-74c6-d773-8ab5e000be10@intel.com>
Date: Thu, 13 Jun 2019 07:19:02 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <54a4d14c-b19b-339e-5a15-adb10297cb30@amazon.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/13/19 12:27 AM, Alexander Graf wrote:
>> Where's the context-switching code?  Did I just miss it?
> 
> I'm not sure I understand the question. With this mechanism, the global
> linear map pages are just not present anymore, so there is no context
> switching needed. For the process local memory, the page table is
> already mm local, so we don't need to do anything special during context
> switch, no?

Thanks for explaining, I was just confused.

Andy reminded me when comparing it to the LDT area: since this area is
per-mm/pgd and we context switch that *obviously* there's no extra work
to do at context switch time, as long as the area is marked non-Global.

