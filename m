Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D891C41514
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 13:28:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F05220657
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 13:28:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F05220657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EFCBD6B0006; Mon,  5 Aug 2019 09:28:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EAE2C6B0007; Mon,  5 Aug 2019 09:28:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9C5C6B0008; Mon,  5 Aug 2019 09:28:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0796B0006
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 09:28:52 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l14so51594028edw.20
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 06:28:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=M4AtJfFHttnOVm+krUA6Mxn07hZxWA0wVW7Vv89+ro4=;
        b=FZfQSEPfKv91pXqE/PqkgPJlE/Y5v2T1q4/3XFDjooMdHGhSsuIRUFhIr5XRCQeUw+
         ZFV5AiffLkXI6sgaRHujmVriWRIcRF4YbNR97e1KnBSUtEaaIqLbWW01wse1XoDCOne3
         /pyJaNbWS5a0nBwqRWFcRuhRNxrVnOWQME+a2KkfYCtDr7pmpeURd43sezfhuKEcC/D8
         AbxgmzjLRJ64kXQgQoF94/+4fV++YAtiXpi5FkRRjk5RZBFf8f8LeG0lDLADFj2SDvWG
         xzd0LApS/loYG03vncRggfA//qlk8rdfD72ayt8pKZsYhV6l2WJqzReagokr7hPWyxRC
         cWFQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAWErLI0T0rKN5HyIhnhfZp2II8aR3dJ4SuzFsfMZOII1u88IAOp
	/fDzdpl6AFDjZSQUTZcDImAN/gJ0++mC80ErSiETd+GUwi7z9Brmc7V8l+hRTMQbSoT2Mj1wYgK
	uBFPcUKWxxajll5tVND0BWvnB8RQragGyTfGL1Ue52LuAggvFLmMwgUvV/2JTbX5TUw==
X-Received: by 2002:a17:906:5409:: with SMTP id q9mr120619742ejo.209.1565011732140;
        Mon, 05 Aug 2019 06:28:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4MJLuRN3Id9JsFRK7Bv0lIuU7lBG1eDpkM/42jK5GLV6w890c5YZsE9bgk//mUCCrZ20x
X-Received: by 2002:a17:906:5409:: with SMTP id q9mr120619663ejo.209.1565011731261;
        Mon, 05 Aug 2019 06:28:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565011731; cv=none;
        d=google.com; s=arc-20160816;
        b=CkrVpXx4Z7GbRE8HnRjkOOpCRLcvoXz/Y07EwXF090LUkCUeOnXMr2nvTNxqzbMBf4
         B0gRv95OMOiz/qodhlvpBm1JbDllfWqbUnqgq+Jz+jv5n/cQ9AuH195bkUXdag+9sfDM
         eRvCFBcBFLi6KZ610xX90iQ79rWKi7ien2lx6WnNm2tz9o6nFDQX6iqrtvwpCCW726MR
         FdqaH+WpJbR5xgpu2kv+jjBNHc92yr3pAXYZbzZ/gwkfyr8XIXRAgWVHHwwkAn4MY7hz
         Wq2A7gO2Da5zxu3AhgeQHylgwglYpnVckT6qW842Qmeenw6h5qx1Sj5DfUouuBma8HRg
         Z/pA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=M4AtJfFHttnOVm+krUA6Mxn07hZxWA0wVW7Vv89+ro4=;
        b=ie3et09zLu7wvdNJjaUK0tWp85tGrk0Q0QXNumaRqjhFCepB9Su/nJgYG9BlL/P8iL
         0ivJTvOmiHWB6LBmgqJLulBZernq2MlyzbSap+lRKSdHF4soxZCFD3jkVEIVtM3NE6GA
         9y+fx6WbtbwGersSzbuujGBLjikpeWNqzLJWg4xbZB9BARzO7/dmaMEKhLcMVAKVXOk3
         hJcWY8dp6qy3o86tbCNHoBvLcI2sUGslJkyyttaYvfONk8B//2Z9l4rRGRL2UacjYagf
         niLM1uDuxFSPeB37vOaeYha56V6KwkltSBeqCkAq1jP03pRowHAqJXL0Pf2Zz3ah8rE3
         8tTg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c14si27929307ejb.99.2019.08.05.06.28.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 06:28:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 804CCACB4;
	Mon,  5 Aug 2019 13:28:50 +0000 (UTC)
Subject: Re: [PATCH] fork: Improve error message for corrupted page tables
To: "Prakhya, Sai Praneeth" <sai.praneeth.prakhya@intel.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "Hansen, Dave" <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>,
 Peter Zijlstra <peterz@infradead.org>
References: <20190730221820.7738-1-sai.praneeth.prakhya@intel.com>
 <20190731152753.b17d9c4418f4bf6815a27ad8@linux-foundation.org>
 <a05920e5994fb74af480255471a6c3f090f29b27.camel@intel.com>
 <20190731212052.5c262ad084cbd6cf475df005@linux-foundation.org>
 <FFF73D592F13FD46B8700F0A279B802F4F9D61B5@ORSMSX114.amr.corp.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <4236c0c5-9671-b9fe-b5eb-7d1908767905@suse.cz>
Date: Mon, 5 Aug 2019 15:28:50 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <FFF73D592F13FD46B8700F0A279B802F4F9D61B5@ORSMSX114.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/2/19 8:46 AM, Prakhya, Sai Praneeth wrote:
>>>>> +static const char * const resident_page_types[NR_MM_COUNTERS] = {
>>>>> +	"MM_FILEPAGES",
>>>>> +	"MM_ANONPAGES",
>>>>> +	"MM_SWAPENTS",
>>>>> +	"MM_SHMEMPAGES",
>>>>> +};
>>>>
>>>> But please let's not put this in a header file.  We're asking the
>>>> compiler to put a copy of all of this into every compilation unit
>>>> which includes the header.  Presumably the compiler is smart enough
>>>> not to do that, but it's not good practice.
>>>
>>> Thanks for the explanation. Makes sense to me.
>>>
>>> Just wanted to check before sending V2, Is it OK if I add this to
>>> kernel/fork.c? or do you have something else in mind?
>>
>> I was thinking somewhere like mm/util.c so the array could be used by other
>> code.  But it seems there is no such code.  Perhaps it's best to just leave fork.c as
>> it is now.
> 
> Ok, so does that mean have the struct in header file itself?

If the struct definition (including the string values) was in mm/util.c,
there would have to be a declaration in a header. If it's in fork.c with
the only users, there doesn't need to be separate declaration in a header.

> Sorry! for too many questions. I wanted to check with you before changing 
> because it's *the* fork.c file (I presume random changes will not be encouraged here)
> 
> I am not yet clear on what's the right thing to do here :(
> So, could you please help me in deciding.

fork.c should be fine, IMHO

> Regards,
> Sai
> 

