Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF9E8C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 04:12:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95D712229F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 04:12:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95D712229F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D8708E0002; Wed, 13 Feb 2019 23:12:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2858A8E0001; Wed, 13 Feb 2019 23:12:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 175238E0002; Wed, 13 Feb 2019 23:12:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B23188E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 23:12:33 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id d8so1868380edi.6
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 20:12:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=DULjUY1z1qcqnfsmJAWZ+E7CtEJCvdJqZuTn6TtJsxE=;
        b=N/1ARkoEiY3EnH9HbBMr+q7q9HT/qRqh+gfmiezcvpjvFxsB/h20HnhAtqIUq9hAuz
         ppzU4gpGT1um/vhzFqcziEaq2c0F0hc+ReGJIvyGCpDPuhwz6MCQ7TAMzGQ80ibrDOPb
         3c8fD4+t0F3WiGhhSoKy+dnQ+PJfdMHRwQm1YbQJmTRdJBrPtLdeb0RgT+YWa1zUDqW1
         9r/nfhywwxmFfSnqKUKs2a6S15XVQ/6gXrQQC+2ZojJEu++jvuPnr9Z/+939LnztphN7
         7UO0h1OMPKwmoIkjYyikkliuNdq6qF0c0a5xJAdmnAHKeGvQSScPjwwb71qy/+VnrM+h
         I0Lg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuaqTFRF6F87zgdbbumiLo4IADmN10mgoUwe+mpsj9Njc185k7wR
	hiSigeHYSNl52IHvNLLrWI99CbkjPU2dH13PM9FIpccmbZ3aOQyBmsclpnMenFNd0NLGeZBOj6V
	OvlkLBRpcabkwGvRQjnmxjYO0Uzwx+Hped0eOh9eOSIlgsp8/8T65969V4QAv2kVb6w==
X-Received: by 2002:a05:6402:1495:: with SMTP id e21mr1328383edv.52.1550117553253;
        Wed, 13 Feb 2019 20:12:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYXqfD+0tVCmF6eGA1Kq5d26FY0pXRw0/FsHhcL/LgrX0vuG5qxlUSaODX7kL407tW7TthY
X-Received: by 2002:a05:6402:1495:: with SMTP id e21mr1328331edv.52.1550117552322;
        Wed, 13 Feb 2019 20:12:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550117552; cv=none;
        d=google.com; s=arc-20160816;
        b=noRzbUGdYifZ+vY1kPkBcvz/X7n3y6kzzpuVqb6w4KiypGM/r4O5EtRz1vzYtCC0BJ
         rGquEXZIIMwCR7RnFH5vU8Fd4pjmcwzJGdS9odwTgBZXEx5ZMyW/HLa2tZ5IuFtrjFQ0
         tCOGiDFFDUJJIaH+rGNU+MUFzeuu/6c/0Ja+N6wXTaLrWM+UIX3vxiDJphqyBI7k7AWF
         DgyrwrnQ4JXUGFW2oH2aS1Tuds7Dv1wAuD640COE4XSmFR1uANH4FfviL+4y85CVA2hB
         4qPGsIq+6iiM4H+ZwvStlAFMI5OgQk52VyGkkExt5K1f43miLYpkIY5M04MhbvnfEYJU
         990w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=DULjUY1z1qcqnfsmJAWZ+E7CtEJCvdJqZuTn6TtJsxE=;
        b=RhpTb1AZyf0jmq+rvGzGe5etLO82QyzUnaWazkcYqv7n79QB4/STIRnwTcj8eizYeo
         GWONHkUinjaL7BOwLMppbF9v6bYT86+gtfbbgM7zistTM4ibXHZQq/e6LvZWKw7gPl8M
         kPlVyw0z3CI7s8g1CUwnNEHupCVTa/SvkbjjQfMEpNgfHGTsa2O+Tjuust3mJaPLv78F
         0lb9E8UwOVoRPNXfYGzP7ckU9vlIyhd2SBQ5NGFIayFbMRTxaOZjTc253dz6gwvssXo/
         Gelld8DYNAmunlokv8CaWiESsGuAkJPA9sjynORGhAyAZDl7G96iqABU1MWAoNyZ64Ht
         fB+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r30si344861edd.123.2019.02.13.20.12.31
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 20:12:32 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0D42280D;
	Wed, 13 Feb 2019 20:12:31 -0800 (PST)
Received: from [10.162.42.113] (p8cg001049571a15.blr.arm.com [10.162.42.113])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 76EB43F589;
	Wed, 13 Feb 2019 20:12:28 -0800 (PST)
Subject: Re: [RFC 0/4] mm: Introduce lazy exec permission setting on a page
To: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: mhocko@kernel.org, kirill@shutemov.name, kirill.shutemov@linux.intel.com,
 vbabka@suse.cz, will.deacon@arm.com, catalin.marinas@arm.com
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
 <7f25d3f4-68a1-58de-1a78-1bd942e3ba2f@intel.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <413d74d1-7d74-435c-70c0-91b8a642bf99@arm.com>
Date: Thu, 14 Feb 2019 09:42:28 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <7f25d3f4-68a1-58de-1a78-1bd942e3ba2f@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/13/2019 09:14 PM, Dave Hansen wrote:
> On 2/13/19 12:06 AM, Anshuman Khandual wrote:
>> Setting an exec permission on a page normally triggers I-cache invalidation
>> which might be expensive. I-cache invalidation is not mandatory on a given
>> page if there is no immediate exec access on it. Non-fault modification of
>> user page table from generic memory paths like migration can be improved if
>> setting of the exec permission on the page can be deferred till actual use.
>> There was a performance report [1] which highlighted the problem.
> 
> How does this happen?  If the page was not executed, then it'll
> (presumably) be non-present which won't require icache invalidation.
> So, this would only be for pages that have been executed (and won't
> again before the next migration), *or* for pages that were mapped
> executable but never executed.
I-cache invalidation happens while migrating a 'mapped and executable' page
irrespective whether that page was really executed for being mapped there
in the first place.

> 
> Any idea which one it is?
> 

I am not sure about this particular reported case. But was able to reproduce
the problem through a test case where a buffer was mapped with R|W|X, get it
faulted/mapped through write, migrate and then execute from it.

> If it's pages that got mapped in but were never executed, how did that
> happen?  Was it fault-around?  If so, maybe it would just be simpler to
> not do fault-around for executable pages on these platforms.
Page can get mapped through a different access (write) without being executed.
Even if it got mapped through execution and subsequent invalidation, the
invalidation does not have to be repeated again after migration without first
getting an exec access subsequently. This series just tries to hold off the
invalidation after migration till subsequent exec access.

