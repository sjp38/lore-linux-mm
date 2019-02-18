Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6451FC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:32:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E57D2184E
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:32:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E57D2184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC1CD8E0002; Mon, 18 Feb 2019 03:31:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6FD08E0001; Mon, 18 Feb 2019 03:31:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A85CE8E0002; Mon, 18 Feb 2019 03:31:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6098E0001
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 03:31:59 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id i22so1029125eds.20
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 00:31:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=SDm5g6qjNf5AAQ6OoMTeoE75N2feERwz0YQEw5ykHM8=;
        b=smIwQbmNUODqLzNMV4dxZT/8Gab7II6594fC8vgGKhUCgk6LaB1Dh55TUblUjwy5it
         +TUcod5jyIafo1oR5QGL+SYq5KKwfns1fFUXLWHj31ZityoKexlKJMeC8J0HYJvRSUdD
         4JgmhQH0UHHFnDsRER8fnS6GpNm0l+5HFPh4IXWS+67uy9lx+AmTdNq55DTDshRghAZi
         ICV35erEbVLjnTiMJygV5gMmKWa1AI/ISQswI5hCWr28GnD4Xih58yhxrH0JRJyayBC7
         GbkmKMqB76oyn3O6/1Z+UwjpO2ArP+x9rsOSKEhLzDhPCu377PsP3Fy3AO8A3yMmPasL
         HbLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuZjqlqyk6rh0k+pc6PK2bHaBT1WFwyPcdKOYzNfVUdUJCgyOP7p
	qh+3zoF++0CmtMpAt5a+pKDRvFoP8gU3gMsvu4d6/5gDWQO2zT+OWS1Z6hjntlxLh+d3Reyu+Zy
	c1rbYYZZQRmnN7uFatV3nQQ7LgiF63OZ60bYoRQnxAgKHbojU4TIVFI2fi8C3MsBmmw==
X-Received: by 2002:a17:906:b742:: with SMTP id fx2mr10055546ejb.199.1550478718750;
        Mon, 18 Feb 2019 00:31:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZHvI1RNtFvGcFb85BWAMV5C4MZzGiW1AJAGPNwPyWmPpaA7+/Fl79NR5th0/dDWCHY3rRL
X-Received: by 2002:a17:906:b742:: with SMTP id fx2mr10055502ejb.199.1550478717614;
        Mon, 18 Feb 2019 00:31:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550478717; cv=none;
        d=google.com; s=arc-20160816;
        b=BEZVBRnN5qEdn036vswZoqEt3Hu43a+2HYNqLX4h/TwDg+cACFG27hdWCZs3CCXpcj
         ZaypWA53vURlq2KLYMABijvFDC/8P2+j27srfQYJP0O9r8IkXhT4iYZTQ8GK2/063LWW
         tFuMm0PI7jGU6MbWtuXo0xENAK09l7O6KIx+czHN7yiWib9TY3xOmzCaErcQ2GF0foqn
         OtCWMeRrKv28rNZCdF1SMnxBL2GGhxeUw3IBwETp0J1r7vwbq7kR8UKnXXbMU2eFb1rj
         oZ8czUURj0/h+f5cYYDD5wNO1cZ/Mk1+WXfmBN7XjWG1AfloxKdv9k3+woYI5YcUUiFZ
         xj+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=SDm5g6qjNf5AAQ6OoMTeoE75N2feERwz0YQEw5ykHM8=;
        b=FmTRLVm2/JEriezs+wOexHbkLVmERpfptVAGbJkYeDtzolrqaJJec0961A86TJ9afx
         +x8cnvqnl/Dvg2TNiAIauMzPNyqw9bty/KGjcFrpK3P1pfzt/sMYMMXA9fMqZJKzg6Mt
         +VbYayES0+DWSiAcJMJohEjQ2eim/n5Rz0sfBw6gcDLSHdnBLeYA7eT1EpwYzysr0S9Z
         FM0jLvKCiIhUUcCZQV5SXStq8oitTuIOOd2djaJX6vIqXX2KtzAAOQzCeDgLrdwTKLlV
         x1udupgTxx31pvuj3wHePHV03peFr7pVDnUui2S1IyMz6ahE0xkxvkXpwWvB3wR6wELI
         v2pg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i62si555091edi.50.2019.02.18.00.31.57
        for <linux-mm@kvack.org>;
        Mon, 18 Feb 2019 00:31:57 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EEA29A78;
	Mon, 18 Feb 2019 00:31:55 -0800 (PST)
Received: from [10.162.40.135] (p8cg001049571a15.blr.arm.com [10.162.40.135])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 460DA3F589;
	Mon, 18 Feb 2019 00:31:53 -0800 (PST)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [RFC 0/4] mm: Introduce lazy exec permission setting on a page
To: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: mhocko@kernel.org, kirill@shutemov.name, kirill.shutemov@linux.intel.com,
 vbabka@suse.cz, will.deacon@arm.com, catalin.marinas@arm.com
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
 <7f25d3f4-68a1-58de-1a78-1bd942e3ba2f@intel.com>
 <413d74d1-7d74-435c-70c0-91b8a642bf99@arm.com>
 <35b14038-379f-12fb-d943-5a083a2a7056@intel.com>
Message-ID: <3da12849-bc56-cb9b-f13f-e15d42416223@arm.com>
Date: Mon, 18 Feb 2019 14:01:55 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <35b14038-379f-12fb-d943-5a083a2a7056@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/14/2019 10:25 PM, Dave Hansen wrote:
> On 2/13/19 8:12 PM, Anshuman Khandual wrote:
>> On 02/13/2019 09:14 PM, Dave Hansen wrote:
>>> On 2/13/19 12:06 AM, Anshuman Khandual wrote:
>>>> Setting an exec permission on a page normally triggers I-cache invalidation
>>>> which might be expensive. I-cache invalidation is not mandatory on a given
>>>> page if there is no immediate exec access on it. Non-fault modification of
>>>> user page table from generic memory paths like migration can be improved if
>>>> setting of the exec permission on the page can be deferred till actual use.
>>>> There was a performance report [1] which highlighted the problem.
>>>
>>> How does this happen?  If the page was not executed, then it'll
>>> (presumably) be non-present which won't require icache invalidation.
>>> So, this would only be for pages that have been executed (and won't
>>> again before the next migration), *or* for pages that were mapped
>>> executable but never executed.
>> I-cache invalidation happens while migrating a 'mapped and executable' page
>> irrespective whether that page was really executed for being mapped there
>> in the first place.
> 
> Ahh, got it.  I also assume that the Accessed bit on these platforms is
> also managed similar to how we do it on x86 such that it can't be used
> to drive invalidation decisions?

Drive I-cache invalidation ? Could you please elaborate on this. Is not that
the access bit mechanism is to identify dirty pages after write faults when
it is SW updated or write accesses when HW updated. In SW updated method, given
PTE goes through pte_young() during page fault. Then how to differentiate exec
fault/access from an write fault/access and decide to invalidate the I-cache.
Just being curious.

> 
>>> Any idea which one it is?
>>
>> I am not sure about this particular reported case. But was able to reproduce
>> the problem through a test case where a buffer was mapped with R|W|X, get it
>> faulted/mapped through write, migrate and then execute from it.
> 
> Could you make sure, please?

The test in the report [1] does not create any explicit PROT_EXEC maps and just
attempts to migrate all pages of the process (which has 10 child processes)
including the exec pages. So the only exec mappings would be the primary text
segment and the mapped shared glibc segment. Looks like the shared libraries
have some mapped pages.

$cat /proc/[PID]/numa_maps  | grep libc

ffffaa4c9000 default file=/lib/aarch64-linux-gnu/libc-2.28.so mapped=150 mapmax=57 N0=150 kernelpagesize_kB=4
ffffaa621000 default file=/lib/aarch64-linux-gnu/libc-2.28.so
ffffaa630000 default file=/lib/aarch64-linux-gnu/libc-2.28.so anon=4 dirty=4 mapmax=11 N0=4 kernelpagesize_kB=4
ffffaa634000 default file=/lib/aarch64-linux-gnu/libc-2.28.so anon=2 dirty=2 mapmax=11 N0=2 kernelpagesize_kB=4

Will keep looking into this.

> 
> Write and Execute at the same time are generally a "bad idea".  Given

But wont this be the case for all run-time generate code which gets written to a
buffer before being executed from there.

> the hardware, I'm not surprised that this problem pops up, but it would
> be great to find out if this is a real application, or a "doctor it
> hurts when I do this."

Is not that a problem though :)

> 
>>> If it's pages that got mapped in but were never executed, how did that
>>> happen?  Was it fault-around?  If so, maybe it would just be simpler to
>>> not do fault-around for executable pages on these platforms.
>> Page can get mapped through a different access (write) without being executed.
>> Even if it got mapped through execution and subsequent invalidation, the
>> invalidation does not have to be repeated again after migration without first
>> getting an exec access subsequently. This series just tries to hold off the
>> invalidation after migration till subsequent exec access.
> 
> This set generally seems to be assuming an environment with "lots of
> migration, and not much execution".  That seems like a kinda odd
> situation to me.

Irrespective of the reported problem which is user driven, there are many kernel
triggered migrations which can accumulate I-cache invalidation cost over time on
a memory heavy system with high number of exec enabled user pages. Will that be
such a rare situation !

[1] http://lists.infradead.org/pipermail/linux-arm-kernel/2018-December/620357.html

