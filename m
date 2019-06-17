Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC246C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 20:54:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8435E2080A
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 20:54:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8435E2080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 148E98E0002; Mon, 17 Jun 2019 16:54:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FA9F8E0001; Mon, 17 Jun 2019 16:54:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F046A8E0002; Mon, 17 Jun 2019 16:54:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BA2698E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 16:54:18 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id g9so8451003pgd.17
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 13:54:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=izRfm8ibobPos+RPmnAQqEOrxLS4qi5y4zRDZImlm/k=;
        b=s3yDpYmH7upwzRpanidoG5zfFNOfAYSWNB39//NRtcR36lQMsOHOdta29+sFomCOCU
         y+N8BYkoHOJv/AhrAdnjojX9j6fua5tJhO8zNj1tuxJ8spR4vN99fBnSMKtPUS7UEx3E
         Pb+ta90vhreQaavuttOzvvJKgJehm0sPcfCs6uGHmzH/PeUojMaFeErg77x/JSJuudAr
         RlCANjuwBlKr+Y6dOll4QwBmdZHP2/GjArhDYEnv4zJrqlkd81d4Kzoy2hQ0T24tOJ35
         TBQeRNnuYuVBS1qElH8fH2Toxcstp4+C0l75jD1lB+a3gvWcuEAQeQKcHx/Kw12XFLvC
         mUIw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUdAEZRmNvfo2eif11yKMxfLnHQycjtWvSKckFP75WnWjHWAIHg
	FWnd3BJV5U/gu7UQ1ABbvYjmVmlz52DUSrEnqdtmE+wg+4FSHWysSKP0jFa8thjF36HyMj2elOn
	IKw1OM6lsCSOIsVQomvPyYgMOz6CO41DBAL41SFaBl7+RTjVKPQtwqhDVh/sJT0Uy4A==
X-Received: by 2002:aa7:8dd1:: with SMTP id j17mr258819pfr.52.1560804858352;
        Mon, 17 Jun 2019 13:54:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+DuXe4dYFMm27l08KrtX2F06JJCSSe3GOperNz6HSZ2hFkx2LGC3JAYggQ5Lk01BfwSsL
X-Received: by 2002:aa7:8dd1:: with SMTP id j17mr25128674pfr.52.1560797418772;
        Mon, 17 Jun 2019 11:50:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560797417; cv=none;
        d=google.com; s=arc-20160816;
        b=gdvMXW1QY8YhQQG3m53+MSV/42HoMK6z9RAB0y3q4EdYc/lrdoGmT0RNgcOwWRd64n
         skVDscmwT71ffTG7VLsr/baR35vTAX7yThVPwcFSn40qCI7LfdoVyqAi4tcaYQ7avWUm
         k+MRXU+ztE2mMPq0IN9XETKYt7ZKMo1AW2+yyw6SgviVrb8rejxJjyME9uPA9CcwY+MT
         uz+S7gWsHjP+giVpw9tRXL9rVwW4aSWyXtsTeIBfuXa5EZMo1wbWKW+u2jytF0ReZpTB
         YwVgt8jCJMZvipFzRW2tylOvenHNO+6S8VugBqIFADYyYmqCCeS3Hw4pQZvhKSvstz5w
         Wxmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=izRfm8ibobPos+RPmnAQqEOrxLS4qi5y4zRDZImlm/k=;
        b=JcDPb0rLRWV8SE0M3REhBYW5asOVJcTZPJLat5s3/rqXf3LarQNCTb/dsz2F05cSBO
         8ogqtcDmSiz0R6JLQQImGP2EtuciECB4Q7y86DWSvPz0Jt/OWBjVIYRHGHdSa1prbToz
         i91eAbjmFFbX28v5dHN0SJErQ3MP21q52Ac0nTtEOikNV0TXwMpLMYVpDAbEorKrzy1Y
         YON9HvlTbOVE58fEsvLz12hdF0t4i7XqTGkyvlWbqFHF+mtA5sSoKOT9gsM5vBBQgQ0Z
         f5U1cQe/eoHCvQFm20hfpTM+TwMGf/Yv6XFD5XAk8Z9qKS36G6xAld0K+o51M9Qnt208
         +RFw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id l7si1455066plb.8.2019.06.17.11.50.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 11:50:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jun 2019 11:49:53 -0700
X-ExtLoop1: 1
Received: from ray.jf.intel.com (HELO [10.7.201.126]) ([10.7.201.126])
  by orsmga002.jf.intel.com with ESMTP; 17 Jun 2019 11:49:53 -0700
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM
 secrets
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>,
 Alexander Graf <graf@amazon.com>, Thomas Gleixner <tglx@linutronix.de>,
 Marius Hillenbrand <mhillenb@amazon.de>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux-MM <linux-mm@kvack.org>, Alexander Graf <graf@amazon.de>,
 David Woodhouse <dwmw@amazon.co.uk>,
 the arch/x86 maintainers <x86@kernel.org>,
 Peter Zijlstra <peterz@infradead.org>
References: <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
 <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net>
 <alpine.DEB.2.21.1906141618000.1722@nanos.tec.linutronix.de>
 <58788f05-04c3-e71c-12c3-0123be55012c@amazon.com>
 <63b1b249-6bc7-ffd9-99db-d36dd3f1a962@intel.com>
 <CALCETrXph3Zg907kWTn6gAsZVsPbCB3A2XuNf0hy5Ez2jm2aNQ@mail.gmail.com>
 <698ca264-123d-46ae-c165-ed62ea149896@intel.com>
 <CALCETrVt=X+FB2cM5hMN9okvbcROFfT4_KMwaKaN2YVvc7UQTw@mail.gmail.com>
 <5AA8BF10-8987-4FCB-870C-667A5228D97B@gmail.com>
 <f6f352ed-750e-d735-a1c9-7ff133ca8aea@intel.com>
 <20190617184536.GB11017@char.us.oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <a1d1d375-53e4-58ba-7753-d01e7b3fa10f@intel.com>
Date: Mon, 17 Jun 2019 11:49:53 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190617184536.GB11017@char.us.oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/17/19 11:45 AM, Konrad Rzeszutek Wilk wrote:
>> The idea is that you have a per-cpu address space.  Certain kernel
>> virtual addresses would map to different physical address based on where
>> you are running.  Each of the physical addresses would be "owned" by a
>> single CPU and would, by convention, never use a PGD that mapped an
>> address unless that CPU that "owned" it.
>>
>> In that case, you never really invalidate those addresses.
> But you would need to invalidate if the process moved to another CPU, correct?

If you have a per-cpu PGD, the rule is that you never use the PGD on
more than one CPU.  In that model, processes "take over" an existing PGD
to run on the CPU rather than having the CPU use an existing PGD that
came with the process.

But we've really hijacked the original thread at this point, which is
probably causing a ton of confusion.

