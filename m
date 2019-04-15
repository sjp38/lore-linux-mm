Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EFADC10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 11:43:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26A5C2073F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 11:43:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26A5C2073F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=metux.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B96496B0003; Mon, 15 Apr 2019 07:43:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B42E16B0006; Mon, 15 Apr 2019 07:43:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A326A6B0007; Mon, 15 Apr 2019 07:43:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 557E86B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 07:43:43 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id n11so15193266wmh.2
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 04:43:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=L7yi2R9TQXxSOt8ZiWitJ3bKRqpTogL9kUDVHocioAs=;
        b=OxO2kYa/3+b1iW+w5b1MJH1fTMu/kL2X03Op+Ngrp2SIche4tp6nmVTGbeT3rN6VZF
         DkboOCwvSg1s0AjJDzbmUv6mKNNquiXjTrjCjKBEwtght8COri1saVg2y9dlALELZqEm
         hiCn0JTIpo1anBJiplIyzhl+r9SAc8FoBYQR5V6dHXwAG50khfJkb9Wey9OCsaZuOxky
         YM8U/LB/0nBU5C/tmJ9bBkkp3pTgCwPBuLe+j/EgMPn2uskXS3wLjquU4fS2vtqq9BoK
         BWcfYIH351FLaAJO7m5j/bTCGJ7xKhJQsWaQMy3XMvslmvJ62hm6qFTPvggAVWmzhrAJ
         8jmA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 212.227.126.187 is neither permitted nor denied by best guess record for domain of lkml@metux.net) smtp.mailfrom=lkml@metux.net
X-Gm-Message-State: APjAAAXKY+z0JtvyS0lqEwUQWv7rlmytOJSBkiNkaaAvtzp1B8d5CY4w
	kS+mu5LJF+XukYXIhRr7+LAJG66dJbRPVdiMGnGRfTVwyduaBEDe1tlwUVu2jwPnfc9V/a5QPvS
	4IhwaVOzL/gI1kcbco61cuO6Ek0/eILWmuE/yPpFUiI/IOzsRRP+HmTejWQevqfY=
X-Received: by 2002:a1c:6889:: with SMTP id d131mr22818305wmc.114.1555328622922;
        Mon, 15 Apr 2019 04:43:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytNXQYHkrsD5wKnes6/I9XMnUtOHOw4xZQ+l7SOq+NG/Z/TKtpPTtEHbWrhsYmKN0PkBXs
X-Received: by 2002:a1c:6889:: with SMTP id d131mr22818252wmc.114.1555328622117;
        Mon, 15 Apr 2019 04:43:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555328622; cv=none;
        d=google.com; s=arc-20160816;
        b=kOrkaxifPzrWUPVdU64BcsW0dgfe4KBMsCb0TyazR4nvC/HpbZYbDXR5hHgD6jPOaP
         RCaO27WA2VmK4PWSMmJ3Qsbw1j73gp+tyEYAFbAIrQPtwLL7tQpsu9UV1jdZfpVkSkrJ
         y50+orJ3UXDQ4Ycu+eeSsSKHIcYNC71E4K52GSZOwGBJCtSM7qTCTLorbguAVW76MsFi
         Jbqv8Op7WUW+soFGFKCqLi42/vnqkDJib7nMkN5yVr3wwwBy//8o6SvD0ozFqbtlNS1X
         VSUg1tn1fv1LqFh7f+b5WA6gop+aTKnyDUXNatwgs4s2/s8nFJI9poOfbKx/v6IvXkY9
         Ereg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=L7yi2R9TQXxSOt8ZiWitJ3bKRqpTogL9kUDVHocioAs=;
        b=JWUEKo3pOwCEWUeoO45T6tgBhZrD85TWwzyehXcqemn08rvGu1Ya4LhWuxGb1Bki+V
         7cjsKCTknegi1l4D2VhkPikYILtdT9dNJbdHXACXJRLo981wZpGAWSonHT9ox2rV7zzb
         k8Z895vuZBD6TYoZycKoMM0unRjs3LB66bcEss52Fl7tPxu2SOhy18I1kAT05ig8Pubz
         3VLhR9b7BuNJ/Bjzm3TeCp/OSfoBk7xLwc3sSLLHR4ScRNmoWd5vhyb440iR28o+CrUG
         1j528F1wiBX28c82XIMNRiuG1lKTDGfkpgtAu2yRYwPMWLOO9RH6ya//rKxQs1pR1h3G
         OC3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 212.227.126.187 is neither permitted nor denied by best guess record for domain of lkml@metux.net) smtp.mailfrom=lkml@metux.net
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.187])
        by mx.google.com with ESMTPS id q11si10715898wmq.182.2019.04.15.04.43.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 04:43:42 -0700 (PDT)
Received-SPF: neutral (google.com: 212.227.126.187 is neither permitted nor denied by best guess record for domain of lkml@metux.net) client-ip=212.227.126.187;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 212.227.126.187 is neither permitted nor denied by best guess record for domain of lkml@metux.net) smtp.mailfrom=lkml@metux.net
Received: from [192.168.1.110] ([95.115.91.41]) by mrelayeu.kundenserver.de
 (mreue012 [212.227.15.167]) with ESMTPSA (Nemesis) id
 1MLAZe-1hY4q10n22-00IFgj; Mon, 15 Apr 2019 13:43:39 +0200
Subject: Re: [RFC PATCH 1/5] efi: Detect UEFI 2.8 Special Purpose Memory
To: Dan Williams <dan.j.williams@intel.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
 Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>,
 Vishal L Verma <vishal.l.verma@intel.com>,
 the arch/x86 maintainers <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>,
 Keith Busch <keith.busch@intel.com>, linux-nvdimm <linux-nvdimm@lists.01.org>
References: <155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155440491334.3190322.44013027330479237.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAKv+Gu8ocQGxTAapfjb5WufhL=Qj54LythHcPHsyy+wUnVBnfA@mail.gmail.com>
 <CAPcyv4gUL8j+EaAZ556_NKXLgva++HgPBOeeAUNHN+DAWaewaQ@mail.gmail.com>
From: "Enrico Weigelt, metux IT consult" <lkml@metux.net>
Organization: metux IT consult
Message-ID: <766281c0-e770-2a0f-e885-0921e599740f@metux.net>
Date: Mon, 15 Apr 2019 13:43:35 +0200
User-Agent: Mozilla/5.0 (X11; Linux i686 on x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4gUL8j+EaAZ556_NKXLgva++HgPBOeeAUNHN+DAWaewaQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Provags-ID: V03:K1:NJ9bcWM7yqVwBf1LcyXAdmYG8vFaS080HOQiIrzAqQ2l0P8+xiK
 YHi6epj0RyIlsPo+9vhCXVypMA9NI8N6znSt43KjG6fJZNVLIcWMAk/xqlKSKirJS7LBegS
 HZD2Re5tdTf+bInVvfP7vdiI9NklOQsbu6BKL958fq6Ka1kJCX6VdBz/wf1fencXTzYdHLG
 Q44u55PW30p62rg1gwSxg==
X-UI-Out-Filterresults: notjunk:1;V03:K0:5T+WGcN6N7c=:1snJlLAJ6sSqyTgFTssxqs
 OxoIDpBRG0z6TOs75ab9uMrxzT4w7mCp7jwFyyRNLMJYCl5TgiRbcxM8Y/RTL4xfoo2UZ2Fxi
 W/hc9Ow3qE8qxC5/dUgLOf9dqkfHorvhqwQyqMQFXCor1u1tHSOZW7+O2Vg3K8bSHkMqI/pDd
 Wxs7PvxTwf01pIQFU93jl6us5S6ZVDtDLgs9JgjxwU9HQ+il5Ztalb0pyZ4XSlvYrkifWXBT2
 y3CcxcOMzL4PlSdHH40hJ8InFF7RlOU1vXndFC240zOr6Cxz21H9KM6l6XzZDLgIaTxayQo5m
 AJ+Hz2XjXBdRShBYLTXlmso7y+CpffXGMV8GRPamBlk/scFN4kd6ERgFRyFTmqOPl/uwhMIvp
 uaLgBkA10QqgksdJfX/Vg82X7qVcmcquK0e9MbO5XoR0rFCaidzicD42qAPLgV/hZ/tbMBaK7
 6nuJpuKtoFnFBgGrSUZAdG1ogQNx96NNJLldd1VYbFLkD4yCVyrecne1dBeZ5/Af9AFV1yNgn
 MzOtD4e3FB7VqNmN9h4ORCzBh3CcHrNv8n1Hfkh46FRip0tB2a3XG4H0bUxyi3q6VYH5G7GiA
 Qd8Xldk6yHGKuyTnMBRcPzp4y31VvjLesY74W6Zs3aJ8Ys+Mg332ELC3oxUf8+TtzBHv5qMLb
 WBfHGdSDyep/EzVRB25HU2rg6I+sWfBnBxyKXJvCBM9ucBFMKqOSf97zjXevVycNGuJPpgMzW
 6iiKpAe65dYxSz3J3E3MVDpMFyxE5nnQsvfO5eWigzXm3/fucU9I5VTMWkk=
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09.04.19 18:43, Dan Williams wrote:

>>> UEFI 2.8 defines an EFI_MEMORY_SP attribute bit to augment the
>>> interpretation of the EFI Memory Types as "reserved for a special
>>> purpose".

What exactly is that suppose to mean ?
Little pacmans might come around and eat the bits ? :o
Who writes specs like that ? What drugs do did take ?


I vote for calling this the lore-ipsum-area ;-)


--mtx

-- 
Enrico Weigelt, metux IT consult
Free software and Linux embedded engineering
info@metux.net -- +49-151-27565287

