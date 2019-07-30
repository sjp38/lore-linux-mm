Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 227D2C32750
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 22:40:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6C932089E
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 22:40:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6C932089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E2C58E0003; Tue, 30 Jul 2019 18:40:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7447B8E0001; Tue, 30 Jul 2019 18:40:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BEFC8E0003; Tue, 30 Jul 2019 18:40:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 24F028E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 18:40:07 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id t18so31521659pgu.20
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 15:40:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:reply-to
         :subject:to:cc:references:from:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=AQje2eslb6+1bPKbEKc3pMWY+XwJfBV5xteV3OLGnHE=;
        b=soqif80Y1APaRwOJsWXG3QyHw1RxQXJ8QE91BhrnUoiI3Hy4c4BGKtMsmO90MYD2PY
         LMBOHd9Wt7WW5o7J1x3QKiOd9WM4ScR8V7MdSefUUi9/kzKfVVBhbPdd1RcP1kPqBIl1
         2Gzk3V+KL1e+eskwZxRp3bYdtRYkeZMlEAVUjgJcmNfX0Tjc/PgyGeWFYAsKTiohO8Lp
         gHZRWNskiXr5qg9k9oEYagnztIuePFrmSgMPgKPRUgdTXFuy5E1kG1iBEQXHGJe0IZzt
         Au6M2/bgRPrT/4gJileIcYGdf1/XPkUS8k+E8iFTIkLBkXjsaThAiWr34jxjVONkRdjz
         wrlw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of sathyanarayanan.kuppuswamy@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=sathyanarayanan.kuppuswamy@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVS2UgkJdAJQxR9zJta8WTAB0qnvqPyOJAeDatMWjUbwpXzd2sd
	8n/4PBkBvnfyjwhIPutWTeLfyt0pC/kK6cB94HuZc+C6/UgzrOIbk9lkWXt88fXOS98pA8gFooD
	NNnSyQv8MhxtLeH8cgZSOH9qESulPm4LJIhW2jKovmOHaD1k+QuZW6EQ2oa5GI2OOiw==
X-Received: by 2002:a62:3883:: with SMTP id f125mr44450847pfa.258.1564526406782;
        Tue, 30 Jul 2019 15:40:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwR23EMR/XkgY9d7AYHiCfi+by6iYHWkr8s5gHBTwdp4OqmSGZCg4/42KqdE9hzmapuPWlo
X-Received: by 2002:a62:3883:: with SMTP id f125mr44450811pfa.258.1564526406216;
        Tue, 30 Jul 2019 15:40:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564526406; cv=none;
        d=google.com; s=arc-20160816;
        b=bULneG3rWgNE2djVhJozGLKUleVcyAamGhla6/ahBJllaAfz1d3PjMAAqmZ/5M3XEv
         KhrqbohtDE19d9ayja/sh2FsDxbdD3UA+ONKmdSSzKDRZ8wRz/U5IRj23lz6sbfuT2Pe
         Cn1Yop2IM2ix6G3Y105/CrRakJYopZRgLArasKpwGQ32LaLjKlBG/ixFrCsqK1ayHEfC
         m1/CEyFKmcBXPouu6f+ovDUvC+pwAmDETAMP4ZGUnZP8bpwjjgmycPhZa1bPKPJtAvoN
         dms8XkHmKbMvV0vZtmyxsG4weFTYBbRI1QQN9GyROTWE3k4InS6uAROulnN4gO2M/zcf
         J47A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:reply-to;
        bh=AQje2eslb6+1bPKbEKc3pMWY+XwJfBV5xteV3OLGnHE=;
        b=b6hWpR4ZnM/RAt2InvhvPZ+VZ09aeMw+gjljtwoCgJ9uREkhf4fI6LQOBOTzw2mwmP
         zLsJJlKbQ33bUHwmZqNQ1hrDohtcQWT68e6pQU2an6gLg3KUh0cUS7WkpyZSw+IWF49P
         gQ+FnmqnLOK5KEgpKLm7zPlZd/DREGs7qRZ5tq6EDYLhyl1Il6V3YoZaHbA4mW8B9MPW
         ugpb2kcOaRDZeLQpoBeHxyQcnISXUi/NUxh8ao554AbM9uI6w3hnWJvPXEku3cUN6qjA
         HPRBfnxG/NPlVojFpoCoyLWWLC72jD/IzsMYp5gAvo2KwT9rAHlxMayLyJ7CJTXXneod
         1cNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of sathyanarayanan.kuppuswamy@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=sathyanarayanan.kuppuswamy@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id p16si30717583pgh.410.2019.07.30.15.40.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 15:40:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of sathyanarayanan.kuppuswamy@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of sathyanarayanan.kuppuswamy@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=sathyanarayanan.kuppuswamy@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 Jul 2019 15:40:05 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,327,1559545200"; 
   d="scan'208";a="162868018"
Received: from linux.intel.com ([10.54.29.200])
  by orsmga007.jf.intel.com with ESMTP; 30 Jul 2019 15:40:05 -0700
Received: from [10.54.74.33] (skuppusw-desk.jf.intel.com [10.54.74.33])
	by linux.intel.com (Postfix) with ESMTP id 52A6E58060A;
	Tue, 30 Jul 2019 15:40:05 -0700 (PDT)
Reply-To: sathyanarayanan.kuppuswamy@linux.intel.com
Subject: Re: [PATCH v1 1/1] mm/vmalloc.c: Fix percpu free VM area search
 criteria
To: Uladzislau Rezki <urezki@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>, akpm@linux-foundation.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190729232139.91131-1-sathyanarayanan.kuppuswamy@linux.intel.com>
 <20190730204643.tsxgc3n4adb63rlc@pc636>
 <d121eb22-01fd-c549-a6e8-9459c54d7ead@intel.com>
 <9fdd44c2-a10e-23f0-a71c-bf8f3e6fc384@linux.intel.com>
 <20190730223400.hzsyjrxng2s5gk4u@pc636>
From: sathyanarayanan kuppuswamy <sathyanarayanan.kuppuswamy@linux.intel.com>
Organization: Intel
Message-ID: <63e48375-afa4-4ab6-240d-1633d7cc9ea4@linux.intel.com>
Date: Tue, 30 Jul 2019 15:37:33 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190730223400.hzsyjrxng2s5gk4u@pc636>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/30/19 3:34 PM, Uladzislau Rezki wrote:
> Hello, Sathyanarayanan.
>
>> I agree with Dave. I don't think this issue is related to NUMA. The problem
>> here is about the logic we use to find appropriate vm_area that satisfies
>> the offset and size requirements of pcpu memory allocator.
>>
>> In my test case, I can reproduce this issue if we make request with offset
>> (ffff000000) and size (600000).
>>
> Just to clarify, does it mean that on your setup you have only one area with the
> 600000 size and 0xffff000000 offset?
No, its 2 areas. with offset (0, ffff000000) and size (a00000, 600000).
>
> Thank you.
>
> --
> Vlad Rezki
>
-- 
Sathyanarayanan Kuppuswamy
Linux kernel developer

