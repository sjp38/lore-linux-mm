Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E302C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 13:57:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFE6E2183F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 13:57:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFE6E2183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 541DA8E0018; Wed, 20 Feb 2019 08:57:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F0138E0002; Wed, 20 Feb 2019 08:57:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DF2D8E0018; Wed, 20 Feb 2019 08:57:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D9F948E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 08:57:04 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f2so5086748edm.18
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 05:57:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=B37FiqXGXeIJE2pVGB5cKjlrAip8k10+Ff50K8Po8jI=;
        b=rIpT6KLd6I0YSibNeTbnb+7aE6+F9PhiRH9V2aFbSekLjOdSPLrcviyA476ndpyQ9c
         CaV3dBGnthHMTYfEtu8MOhcee7ziBcrt+1sZfA2DwwzFgopAniAKblRb3DCpM2m3rRuw
         LWw0F5P/o3PX4i9rGeWfHOiMLlUinIcEAMKOph10w3kz+O4j7GBo+QcnPwY2sk2n6jVD
         UvVvkkB3nFtC/dah8SQnVhYfYmuKBDGcUsisPzmsbfZ3cV9SRjDwUDKHMocvr0P8H8Z5
         FlrmgpMeMz4Yn0w3GyukiX6xMH3dGq+wju//ccEbYkK7+C42oVh9vkO/VbSEuqKNt1N5
         /auQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAub5xuPAOzalXCUPBSAC2fj/NXB8YruCnIy5a1gFyPUEPb0n7uqd
	dYMjsdm3E49RaGwMQRpZJr2yFYsO9UvbmRa8z3lwrFlX6UU7JA5xsabf22CsODPbtiJNk9vOp/O
	QMjlcbm9Y+Y0FfK0YuzHRUTh5pds7C5DoktmYzrhTyQbayw0ZBTd0Bmu9FLflgfUVkQ==
X-Received: by 2002:a17:906:4988:: with SMTP id p8mr24131811eju.75.1550671024418;
        Wed, 20 Feb 2019 05:57:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbhWkLt7sH126gvjdxR4iynVHd9WWUkfV1wB6H9B5pL72D+ihtK6HonzgWksA6Sl7K+l2bz
X-Received: by 2002:a17:906:4988:: with SMTP id p8mr24131772eju.75.1550671023400;
        Wed, 20 Feb 2019 05:57:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550671023; cv=none;
        d=google.com; s=arc-20160816;
        b=J2z/EdQWBXkQvYmkDVe+ykerOQ3CcsJeUNkYrmg6wbyKKwH/T6ZAhgjmVvucHCTwgX
         1hCoXRsSBJWfJs35gyfI9sCvu741N61aGZAaN0lFnH1vSN/u22loOlCCnpyhAyPsVgcM
         YY7SCirp/D6QbbUiaunwe+uHNayJRhm/SuyTtWTalr8wi6U7D/7Rk1HNwfZzTDk6Btwu
         hmjH+MyS0qRRpfosvjg2GgOT8YbMj+o9VLsoNhHqGE8vzjoTBfFXCHaSW+m2avYxjZzd
         lCPtmynMM7ai0E7JBlOYz+zL6zQYbOApJCtX1skPxuAUhyFn0waqWRx1k8cuVJu8kPKW
         MYJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=B37FiqXGXeIJE2pVGB5cKjlrAip8k10+Ff50K8Po8jI=;
        b=S1JKEKLMNWjMU0j2GkK4EjthnG9xti7pWSjc7rudv8Rxyp21YA2jM8FsGvPzOiX404
         OESVUvvul6yC+4Q9Hm82w+SD2iUGvjH/6McR6WlRA6NinQzOzezY2kozr0X22THT1W6C
         FB+BGGcAOCxbFgiemti76xvxa26c9Kf6+Ok8EpMXTB++19rh9ZqOWJkhSAxzDzYv1rla
         lVfUxwIX3N91w7LQv3T8FwNdl6OQn5C+/YXoU7HQBPpUgrF2JUk2lWqXIGH0OpcpKuLC
         o7Xchf81L7iW8nO7ToRJArJtjUglS8bMpJ3mHSkDNaV/asEsuk45uhcWErZsgX0I3uPY
         IMLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z3si1679025edc.221.2019.02.20.05.57.03
        for <linux-mm@kvack.org>;
        Wed, 20 Feb 2019 05:57:03 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4327DEBD;
	Wed, 20 Feb 2019 05:57:02 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 42E883F690;
	Wed, 20 Feb 2019 05:56:59 -0800 (PST)
Subject: Re: [PATCH 03/13] mm: Add generic p?d_large() macros
To: "Liang, Kan" <kan.liang@linux.intel.com>,
 Peter Zijlstra <peterz@infradead.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
 James Morse <james.morse@arm.com>, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org,
 Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 kirill@shutemov.name, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-4-steven.price@arm.com>
 <20190218113134.GU32477@hirez.programming.kicks-ass.net>
 <aad21496-a86b-ca91-70b7-0c23ea6fefd3@arm.com>
 <8a74c111-b099-8d18-5fb0-422909a1367a@linux.intel.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <f8bdd4b9-e078-c1fc-9b15-1ed7a844e673@arm.com>
Date: Wed, 20 Feb 2019 13:56:57 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <8a74c111-b099-8d18-5fb0-422909a1367a@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 19/02/2019 03:44, Liang, Kan wrote:
> 
> 
> On 2/18/2019 9:19 AM, Steven Price wrote:
>> On 18/02/2019 11:31, Peter Zijlstra wrote:
>>> On Fri, Feb 15, 2019 at 05:02:24PM +0000, Steven Price wrote:
>>>> From: James Morse <james.morse@arm.com>
>>>>
>>>> Exposing the pud/pgd levels of the page tables to walk_page_range()
>>>> means
>>>> we may come across the exotic large mappings that come with large areas
>>>> of contiguous memory (such as the kernel's linear map).
>>>>
>>>> For architectures that don't provide p?d_large() macros, provided a
>>>> does nothing default.
>>>
>>> Kan was going to fix that for all archs I think..
>>
> 
> Yes, I'm still working on a generic function to retrieve page size.
> The generic p?d_large() issue has been fixed. However, I found that the
> pgd_page() is not generic either. I'm still working on it.
> I will update you on the other thread when all issues are fixed.
> 
> 
> 
>> The latest series I can find from Kan is still x86 specific. I'm happy
>> to rebase onto something else if Kan has an implementation already
>> (please point me in the right direction). Otherwise Kan is obviously
>> free to base on these changes.
>>
> 
> My implementation is similar as yours. I'm happy to re-base on your
> changes.
> 
> Could you please also add a generic p4d_large()?

Sure, I'll include that in the next posting.

Thanks,

Steve

