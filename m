Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE618C5B57A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 03:44:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B24F214AF
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 03:44:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B24F214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D47626B0003; Thu, 27 Jun 2019 23:44:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD1758E0003; Thu, 27 Jun 2019 23:44:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBFAF8E0002; Thu, 27 Jun 2019 23:44:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A48E6B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 23:44:27 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k15so7486651eda.6
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 20:44:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=rPd/a1hxAx0pDuqaGJdZpy8wumLFkZlHwpe3baOpt3g=;
        b=RtO5j+8EoLnZ+vYelRg28JgQns0srSO/Bo5pAZzmDzJJ/+H/guinNoVvDhKx5/RJbe
         6ggtU3Hb7s5Wz7TOZoXwjLnSrdyD0vlsKr26ht8y9F6bM+ZymQPLckaPL4AkRc8VxOxA
         cECrIUBm1rPsotKzxMceQpxdQUszXFDOfjUz9jF1ygFAHHevGn0JcJgQ4g83Am5utwDD
         D7j3kA+pkgjN5RZLlsGqXcjWQ5nfhvrYc0a42tEQCsRvtPqWFsXfayrL8SBoYfvivWgG
         1uErcCKoRLd7jr76ugMgSFPRUnqGvw1kZrsOA6x1P+zCagiv3WyRiZmLMB8FSnRit+uK
         1U8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAW8DF7XTSd9TI+aRG2EA8Ipz7lw6AoevLiCJmxh8dlfxwoJsgdo
	vNvkYJIEV+PlvzgWDyPbJ0VfW/e4mCQj9t0qcU8AtaqfJAEj2tCltjMCIV5mvXqbZARpc3dng2u
	CGGdfn3nG0hBH8k3ZQpzybZt4mwC21xQ6Pk3yzJgb5Q3cwQRUYf9yWHMZzWwjBQ5rrg==
X-Received: by 2002:a50:9832:: with SMTP id g47mr8363604edb.282.1561693467017;
        Thu, 27 Jun 2019 20:44:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx6ERwEIXl/ha//T+T8e+HPEOydWSHnkc0B2o23mImXylLg8/B6XBRCP2GqUBLdBWJ0CXpg
X-Received: by 2002:a50:9832:: with SMTP id g47mr8363562edb.282.1561693466285;
        Thu, 27 Jun 2019 20:44:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561693466; cv=none;
        d=google.com; s=arc-20160816;
        b=Coqkpk5CbMfMf3kaxs5dKZ5x2fWE/bbVIX1g8+2b0MdTs1U+H4EgrJeKlGF8QxKL8E
         dfZ+eyWs9K1kI662MEeqvyflGjwqSNXAE3X1XHq3VSsrTiiQd+cfcR9XAW3a7hoPCasL
         OR7DVUSoXcFWV6Zy9SdOT7DmQa0zsA1uZjRgpYk5ST62gCqEiT6dSyE02ZqC5inq/seb
         DsaZ/4T1EbXadYqPVn6MoNlexUL/YKbrVm7nE9NYVrMbG42JnbcUWiH53Ngmc4RE/q6S
         nlx967hrXfeWWqwIuoRuh7tsSile3fIEazFpNP5J8svHKEygnzsIkfY4rB8QD0b1eImh
         8qRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=rPd/a1hxAx0pDuqaGJdZpy8wumLFkZlHwpe3baOpt3g=;
        b=Gp1nlzIvOoygOsRvI2ic2mxy3/JwFBvVa3yGwn5Gi6qfkkNR2xucw1D7p0TQdGTD/i
         iryODRIX9/NeKnmZ3vSrtj55EfekAN9DjQZ8vz9FWhBUl1kJQKBEMByXbE6lEgsGp8cP
         3RKu3iDH6hr+Zdp7hWh2XwqnWm8H9Aen44t9nFhMRiCZiPCjYgfNKhU2sDrvvleCY6Bo
         b2weP4GiP7zOVCroIR1j6pZ50IgANLrIsAm1U/Kc+u+Jyso6DOU+hWmaBJ9JnXoX9ods
         Jkkq6u2sFg/CdI93bkQb47sST/1JMDZoJa2nHSPxIepMowz5ghOKjys77cyk2QZLdbyK
         OjkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id v1si576879ejd.397.2019.06.27.20.44.25
        for <linux-mm@kvack.org>;
        Thu, 27 Jun 2019 20:44:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BC1A92B;
	Thu, 27 Jun 2019 20:44:24 -0700 (PDT)
Received: from [10.162.40.144] (p8cg001049571a15.blr.arm.com [10.162.40.144])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2BE923F706;
	Thu, 27 Jun 2019 20:44:20 -0700 (PDT)
Subject: Re: [PATCH] powerpc/64s/radix: Define arch_ioremap_p4d_supported()
To: Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Nicholas Piggin <npiggin@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Stephen Rothwell <sfr@canb.auug.org.au>, linuxppc-dev@lists.ozlabs.org,
 linux-kernel@vger.kernel.org, linux-next@vger.kernel.org
References: <1561555260-17335-1-git-send-email-anshuman.khandual@arm.com>
 <87d0iztz0f.fsf@concordia.ellerman.id.au>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <6d201cb8-4c39-b7ea-84e6-f84607cc8b4f@arm.com>
Date: Fri, 28 Jun 2019 09:14:46 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <87d0iztz0f.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/27/2019 10:18 AM, Michael Ellerman wrote:
> Anshuman Khandual <anshuman.khandual@arm.com> writes:
>> Recent core ioremap changes require HAVE_ARCH_HUGE_VMAP subscribing archs
>> provide arch_ioremap_p4d_supported() failing which will result in a build
>> failure like the following.
>>
>> ld: lib/ioremap.o: in function `.ioremap_huge_init':
>> ioremap.c:(.init.text+0x3c): undefined reference to
>> `.arch_ioremap_p4d_supported'
>>
>> This defines a stub implementation for arch_ioremap_p4d_supported() keeping
>> it disabled for now to fix the build problem.
> 
> The easiest option is for this to be folded into your patch that creates
> the requirement for arch_ioremap_p4d_supported().
> 
> Andrew might do that for you, or you could send a v2.
> 
> This looks fine from a powerpc POV:
> 
> Acked-by: Michael Ellerman <mpe@ellerman.id.au>
> 
> cheers

Hello Stephen/Michael/Andrew,

On linux-next (next-20190627) this change has already been applied though a
merge commit 153083a99fe431 ("Merge branch 'akpm-current/current'"). So we
are good on this ? Or shall I send out a V2 for the original patch. Please
suggest. Thank you.

- Anshuman

