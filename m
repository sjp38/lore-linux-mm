Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C02CC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:10:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F32D2222D7
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:10:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F32D2222D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=youngman.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F4D18E0002; Thu, 14 Feb 2019 12:10:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A0B18E0001; Thu, 14 Feb 2019 12:10:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78F828E0002; Thu, 14 Feb 2019 12:10:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 21DF08E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:10:33 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id m7so2499326wrn.15
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:10:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=+6DJnYolsx5XAGeJ434LHaErbIYhZTLMmVWBHtfDpIY=;
        b=aCzP4zNChkkz2HZoEG9aeSUkAqQ9JNWzEFLVNNw3mzeOCivYFmWbSymMhKoxpcaDYH
         gTgyeieF2nCBlRUQb/QTqShI2iQz6ejHIg36qwyardhvOoSu1IUC0VQbjXY15/ATZ4QO
         wW0tm0gS4g8mCdTYGp6Nq7LxUxA88fDL1+Kv5++PPkZNWj8ChvVZYd1WQkn9Zopv/A8Y
         nxBSZhY84X4fLUcVJ9rWcWh4Ow4aI0sgJH+mJZ+sG2uQGS6xdZ1r5IwyVqdgdyB6KNVq
         9HKSvXDZ2zKMvPtk0skWdIVPBtfGWlZRhAruHfa5aKXceFbZLwmA61Qvs3Efi9EL3vjq
         zcMQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of antlists@youngman.org.uk designates 85.233.160.19 as permitted sender) smtp.mailfrom=antlists@youngman.org.uk
X-Gm-Message-State: AHQUAubnU7d64d9CnVOqHLc5c+mivGeibU68a569K3Vy/dhwq7U1F7gX
	ZO9IZUMJpUm2eNWp600PbHgwgw+VB35XgQacHJ0tgUpv+g/R8o9dfDgj6BXXH/K/l9xEqW7bcS0
	YBnEOcWTnWa3LmvYjCeLdZQlUB7zLq381t7A8lZx6bFhG47y0Mu+yi3z1lzhnR8ShbA==
X-Received: by 2002:adf:f58b:: with SMTP id f11mr3429802wro.266.1550164232715;
        Thu, 14 Feb 2019 09:10:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iagxqk/qpdYZ99ZA+35cqWJLDxUDq5yEKzv5Vlyf7mbpyen2qKYCKtHBkJwxUtUz3i5ODo4
X-Received: by 2002:adf:f58b:: with SMTP id f11mr3429753wro.266.1550164231863;
        Thu, 14 Feb 2019 09:10:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550164231; cv=none;
        d=google.com; s=arc-20160816;
        b=P7OIDTueD/HMGhSas/vpZ1oQd2qTQdw/GOjjgEEbdCBRq5XAFHHsAQhxEedHkf5XKR
         bwXgBd2X+smhwWwmVT1GE8NPB9Uqk02QWHb4GL7WMZLM9e/ZlBnsa1BEE6zni8crirxP
         PZertUQRfOGJWeX8/nnu8TMS2HBMuB1Fge45AVonIKZ5rWLELA2nMUlYxoblyvG9CQIa
         CWZvwS1dxdw5TpQNgWWdYJLA0L2B90bSVV8k3KsNkwEI5v6i19bYcdvnKiYX81BUWtx2
         x/cIuP97wkWvevSc49uaiTGVOs/vYOGHGMHCF64+JEvigO6Lb2Gl34NVmLjU8DdknMGr
         koQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=+6DJnYolsx5XAGeJ434LHaErbIYhZTLMmVWBHtfDpIY=;
        b=AqWmljpqKcwLfHcISs3iya6VZ5J9n0G9SJeqj45k+rqEyPont2FCPdk8jJ4MHJUiGa
         rhw9Ef3zlcKfQpQliGdOyMd+UzWbts+UwncR0aBo9FgnGqPD0AVrj43fVcEDzWRmCSqF
         TMtTGUmkzs9z/ZrD+rWOON06xfncpY5kHEW9EozVGzg4PxQ+HL0wwoPz+FXuyy+/8YoR
         qfrT0y7sq2hwLZNitZzIrq7NOOWmokZR4BFIioW8ehN6ZIt+e6yjFxAJ8iDW1M09tBtw
         aSCAiuKes+/jA5cBpx5x7zf6cHWJIfGvZEAW/SEOURG3MGmE/doN5XsySG8eU3tUaxxp
         Oong==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of antlists@youngman.org.uk designates 85.233.160.19 as permitted sender) smtp.mailfrom=antlists@youngman.org.uk
Received: from smtp.hosts.co.uk (smtp.hosts.co.uk. [85.233.160.19])
        by mx.google.com with ESMTPS id j185si1991823wma.127.2019.02.14.09.10.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 09:10:31 -0800 (PST)
Received-SPF: pass (google.com: domain of antlists@youngman.org.uk designates 85.233.160.19 as permitted sender) client-ip=85.233.160.19;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of antlists@youngman.org.uk designates 85.233.160.19 as permitted sender) smtp.mailfrom=antlists@youngman.org.uk
Received: from [81.153.42.125] (helo=[192.168.1.82])
	by smtp.hosts.co.uk with esmtpa (Exim)
	(envelope-from <antlists@youngman.org.uk>)
	id 1guKWt-0006cL-3j; Thu, 14 Feb 2019 17:10:31 +0000
Subject: Re: [LSF/MM TOPIC] (again) THP for file systems
To: Song Liu <songliubraving@fb.com>, Matthew Wilcox <willy@infradead.org>
References: <77A00946-D70D-469D-963D-4C4EA20AE4FA@fb.com>
 <20190213235959.GX12668@bombadil.infradead.org>
 <843818E0-C7E8-451E-A5B1-DAF0F120BD5A@fb.com>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 linux-kernel <linux-kernel@vger.kernel.org>,
 linux-raid <linux-raid@vger.kernel.org>,
 "bpf@vger.kernel.org" <bpf@vger.kernel.org>,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 "Kirill A. Shutemov" <kirill@shutemov.name>
From: Wols Lists <antlists@youngman.org.uk>
X-Enigmail-Draft-Status: N1110
Message-ID: <5C65A101.4010909@youngman.org.uk>
Date: Thu, 14 Feb 2019 17:10:25 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:38.0) Gecko/20100101
 Thunderbird/38.7.0
MIME-Version: 1.0
In-Reply-To: <843818E0-C7E8-451E-A5B1-DAF0F120BD5A@fb.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 14/02/19 01:59, Song Liu wrote:
>> I believe the direction is clear.  It needs people to do the work.
>> > We're critically short of reviewers.  I got precious little review of
>> > the original XArray work, which made Andrew nervous and delayed its
>> > integration.  Now I'm getting little review of the followup patches
>> > to lay the groundwork for filesystems to support larger page sizes.
>> > I have very little patience for this situation.

> I don't feel I am a qualified reviewer for MM patches, yet. But I will 
> try my best to catch up. 

Then just dive in!

Ask questions - "what does this do?", "please explain this, I don't
understand", "I'm new here, please teach me".

Okay, some people are too busy to help much, but I've found looking
after the raid wiki that people are happy to help, *especially* if they
know that their time is going to be rewarded. If I ask for help it
usually results in an update to the wiki.

If they know you are reading through the patch asking them to explain it
helps two ways - you are another set of eyes to spot something wrong,
and your questions will make them look at their code in a new light.
Even if you don't understand what you're looking at, you can still spot
stuff that looks weird, and if you ask them to explain then it will mean
that code gets an extra check. Anything that slips through that is
probably fine.

Cheers,
Wol

