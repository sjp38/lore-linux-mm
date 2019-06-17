Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E04C1C31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 07:38:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 776652064A
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 07:38:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b="lU0A/K51"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 776652064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=amazon.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D166D8E0003; Mon, 17 Jun 2019 03:38:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC4DE8E0001; Mon, 17 Jun 2019 03:38:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB5CA8E0003; Mon, 17 Jun 2019 03:38:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9DAFE8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 03:38:13 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id j128so8400893qkd.23
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:38:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language:precedence;
        bh=8xZP6BRYVHqRBD1v3aCylovGhFA01FEft+IhJzUopnA=;
        b=fYpwZxfMmpkVXMV+hKL9lnGYhy1zf/Fh8osL+9zemf/nyF0tC1SGzwVVDP0AleUi+Q
         iae7Q6m+xTyZoH/4MKg0xRhkGZGlvAeiUD4K5We7FiOiPXIHaa8NLlczTrfYY+F7oQsa
         V0cIsADqOwElB+alAxA4B8MS4TDgJQsBU7smTFDiJkuQbroTpugduKN5dZA/MYuTisBO
         SNFuM7PM/YpvCYAX60fBT+xo61ZB+LXpKocZl1ehloCYGw5ThuxfEuyNWpbtkWRtsvp/
         gNW2bCBkfWMsMAEi4UcGaNIpVKWyQi8pNGX6DJfCmjwf0KYU28hFDmn/6/AkP7WFalY+
         uhmg==
X-Gm-Message-State: APjAAAW9dBDjt221ngmwQJL2O6+gKGDguu731ePmp9Pj3DSjkeonccpq
	jvvRR4HGrhTso677EczjicdFTXn8AJZr9jqB5kEKC8LirYJia2w/QN6yXDjkGSU55ZxgwHATYuw
	J2wdSTnb0gPas9I9xnqFDUDJlo0hlXKouo3MyFn1IQ/zMxwnzA8/KGHWiz4zWnWy7dA==
X-Received: by 2002:a0c:9305:: with SMTP id d5mr20292722qvd.83.1560757093346;
        Mon, 17 Jun 2019 00:38:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPRX8IDQ1MUY48oz95xqGVm9wRvL1X0I8MXEvoA4iTXfmv57nZdKTnCuduAjhG/Ttewrav
X-Received: by 2002:a0c:9305:: with SMTP id d5mr20292695qvd.83.1560757092791;
        Mon, 17 Jun 2019 00:38:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560757092; cv=none;
        d=google.com; s=arc-20160816;
        b=jBqxwP697+aMPMZCKOIp0VbzYTe9WXBuE9Vp/Fw4QnCqk7P4gkM8xOTpf2L6tah4iD
         0s825ECB0NNkfzGYczg3VRvdSiTyP8PfmtYXxn/XJmrnUq6g9FVuUGL6+uet9Mun8i8r
         flVpLElaAwmptMXbmRLPNnQm4CmkwkvyYpgAdqgVxy8xpuBY2WzcvJH4nZLuRRaRjxxh
         b/gXyGxbN9UVUJE1bn48y1Isc/5Sqb4UIhpoX2yu5llD4nFWlVG5fJ6jbX5we4CvBNbR
         DKbIdKXNdaT9KqHs8irY3ZEnjJXqCf6d49ArtxEyT9ViSQxHZfrx1YHJNh9ovzyercyl
         C9Sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=precedence:content-language:content-transfer-encoding:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to
         :subject:dkim-signature;
        bh=8xZP6BRYVHqRBD1v3aCylovGhFA01FEft+IhJzUopnA=;
        b=zZ9WwSV41E+Np0+DfGNL5ZUSJs+H7ybBFtutt0hZGHoIdiVRRLqDsBlbAtFWGgY9b1
         k9LXoGq7JcrjcgInMLPiHPThVi/RnPDzz4hrjcqD+3dWPGDTDw4JmOFWzqh/F3mhrx/M
         3B29LyeooBVvoIfCOaI6hGMa8QfWD6na/NRUAD/Ef+r7PxJ6KfxrenQABA8lkOSf/Glv
         RwnBELuKU+gNdsf/PSp1/Etev9c8IKPUafeH0qcE0sAqYdTobSi5VdeTRlaSfh0XpxSO
         fxjhmYQqqpCfzP9pcQ5zua+zE8sQbQsD5Fun6AwNh4xD1UeAJhjaHPm/N8+hZsCrQ71c
         nY6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazon.com header.s=amazon201209 header.b="lU0A/K51";
       spf=pass (google.com: domain of prvs=06401eb55=graf@amazon.com designates 72.21.196.25 as permitted sender) smtp.mailfrom="prvs=06401eb55=graf@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.com
Received: from smtp-fw-2101.amazon.com (smtp-fw-2101.amazon.com. [72.21.196.25])
        by mx.google.com with ESMTPS id s25si6213012qtn.20.2019.06.17.00.38.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 00:38:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=06401eb55=graf@amazon.com designates 72.21.196.25 as permitted sender) client-ip=72.21.196.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazon.com header.s=amazon201209 header.b="lU0A/K51";
       spf=pass (google.com: domain of prvs=06401eb55=graf@amazon.com designates 72.21.196.25 as permitted sender) smtp.mailfrom="prvs=06401eb55=graf@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
  t=1560757091; x=1592293091;
  h=subject:to:cc:references:from:message-id:date:
   mime-version:in-reply-to:content-transfer-encoding;
  bh=8xZP6BRYVHqRBD1v3aCylovGhFA01FEft+IhJzUopnA=;
  b=lU0A/K514EP44LlSbe7+gAvDPtiOstqo0LpUj+nsacdnconLiACx9kTw
   eEJWABrBVCs6WKnRLtbqL40F8UG7SZxepHUItn1WHzLolesXSb+0g7L7t
   TLozrtFQNGmrF+R8mNqUmlOaEDLmQ+H2hD2CseAUNBRXNguRMYNfyoZ+A
   U=;
X-IronPort-AV: E=Sophos;i="5.62,384,1554768000"; 
   d="scan'208";a="737725018"
Received: from iad6-co-svc-p1-lb1-vlan2.amazon.com (HELO email-inbound-relay-1a-67b371d8.us-east-1.amazon.com) ([10.124.125.2])
  by smtp-border-fw-out-2101.iad2.amazon.com with ESMTP; 17 Jun 2019 07:38:09 +0000
Received: from EX13MTAUWC001.ant.amazon.com (iad55-ws-svc-p15-lb9-vlan3.iad.amazon.com [10.40.159.166])
	by email-inbound-relay-1a-67b371d8.us-east-1.amazon.com (Postfix) with ESMTPS id 11569A2B0B;
	Mon, 17 Jun 2019 07:38:07 +0000 (UTC)
Received: from EX13D20UWC001.ant.amazon.com (10.43.162.244) by
 EX13MTAUWC001.ant.amazon.com (10.43.162.135) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Mon, 17 Jun 2019 07:38:07 +0000
Received: from 38f9d3867b82.ant.amazon.com (10.43.160.69) by
 EX13D20UWC001.ant.amazon.com (10.43.162.244) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Mon, 17 Jun 2019 07:38:04 +0000
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM
 secrets
To: Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski
	<luto@amacapital.net>
CC: Dave Hansen <dave.hansen@intel.com>, Marius Hillenbrand
	<mhillenb@amazon.de>, <kvm@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-hardening@lists.openwall.com>, <linux-mm@kvack.org>, Alexander Graf
	<graf@amazon.de>, David Woodhouse <dwmw@amazon.co.uk>, "the arch/x86
 maintainers" <x86@kernel.org>, Andy Lutomirski <luto@kernel.org>, "Peter
 Zijlstra" <peterz@infradead.org>
References: <20190612170834.14855-1-mhillenb@amazon.de>
 <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
 <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net>
 <alpine.DEB.2.21.1906141618000.1722@nanos.tec.linutronix.de>
From: Alexander Graf <graf@amazon.com>
Message-ID: <58788f05-04c3-e71c-12c3-0123be55012c@amazon.com>
Date: Mon, 17 Jun 2019 09:38:00 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1906141618000.1722@nanos.tec.linutronix.de>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Originating-IP: [10.43.160.69]
X-ClientProxiedBy: EX13D20UWC004.ant.amazon.com (10.43.162.41) To
 EX13D20UWC001.ant.amazon.com (10.43.162.244)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 14.06.19 16:21, Thomas Gleixner wrote:
> On Wed, 12 Jun 2019, Andy Lutomirski wrote:
>>> On Jun 12, 2019, at 12:55 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>>>
>>>> On 6/12/19 10:08 AM, Marius Hillenbrand wrote:
>>>> This patch series proposes to introduce a region for what we call
>>>> process-local memory into the kernel's virtual address space.
>>> It might be fun to cc some x86 folks on this series.  They might have
>>> some relevant opinions. ;)
>>>
>>> A few high-level questions:
>>>
>>> Why go to all this trouble to hide guest state like registers if all the
>>> guest data itself is still mapped?
>>>
>>> Where's the context-switching code?  Did I just miss it?
>>>
>>> We've discussed having per-cpu page tables where a given PGD is only in
>>> use from one CPU at a time.  I *think* this scheme still works in such a
>>> case, it just adds one more PGD entry that would have to context-switched.
>> Fair warning: Linus is on record as absolutely hating this idea. He might
>> change his mind, but it’s an uphill battle.
> Yes I know, but as a benefit we could get rid of all the GSBASE horrors in
> the entry code as we could just put the percpu space into the local PGD.


Would that mean that with Meltdown affected CPUs we open speculation 
attacks against the mmlocal memory from KVM user space?


Alex

