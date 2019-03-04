Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC282C10F03
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 12:01:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A56EC20645
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 12:01:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A56EC20645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A62D8E0004; Mon,  4 Mar 2019 07:01:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37E858E0001; Mon,  4 Mar 2019 07:01:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26CC48E0004; Mon,  4 Mar 2019 07:01:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C6D188E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 07:01:45 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id a21so2589789eda.3
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 04:01:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Znf0DnHGX7qcHNgMOFUs4bIDbQazikbc4EZbjGrPUaA=;
        b=U46000CrPqgEa0YcRZSwyV9wiwMwmKVN9+jwzICJkqsEtfvDIB59bOTOxH5xRKZ1LV
         WwRz2LPS0DwMUnXmJvt2QmgLoRId7M5BC2VwiUVwXqhX1mkvtgJ4cZss1QCyhaEo+6zP
         NPx3hKdspKcK+QGR0Yy6oM4rkl7I3bjSWHAjR1tYujWeUoAYdLRT0Z+mCoGRg3ytgDFZ
         E2CaniZG7CVsp6kPpUZ1eqhAmgMiZn1IFYcoOVMCG83iHxa52zyMD2PSyjvviD4OIB7w
         r+Vs0L9h2ySt/QbBcc/taOXgB74iGaqjDLQ8B9GYPC9+ndNf0RXnJuYm3M535Q9GvEci
         RGqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXvAv0eWnMRwj+bVDwRmxC+GwXtnIfxWmGMY9idYMlM/pDaI1D+
	NzbOBdJlRV6pNRuu7FkACWRQXvNzK0Hr/JZdbY8I+f20P06CUDJJOH8rXkCPQytgwgyVsqR6RIg
	2pHntaGLJCAxiRo/QYgGnarvbrxO/dN/2spzLXBXOhW3MVmYb5KZI0uMrhj4N7YRBVg==
X-Received: by 2002:a17:906:5781:: with SMTP id k1mr12725055ejq.34.1551700905376;
        Mon, 04 Mar 2019 04:01:45 -0800 (PST)
X-Google-Smtp-Source: APXvYqyhKlf5M81Y47tF9l6XgUiSKC8wMIQeWkkvwKNhm9A1aVo2aU+V1TXIeznlm0ncKE/j6lUS
X-Received: by 2002:a17:906:5781:: with SMTP id k1mr12725013ejq.34.1551700904530;
        Mon, 04 Mar 2019 04:01:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551700904; cv=none;
        d=google.com; s=arc-20160816;
        b=beUx0STn30mLqqbLcJU+qQqTyX0B+ulpSTlcCiBGoZOXIEaUkfBbRlYws1e32th4XR
         fMy9fW+Vw2RrA7rsuw79EOrhzWUE5hqu7fOlRg3lzuaEtA3NN2Bt5YlQBEyk1Lfy8v3b
         U5vF6aRO3BKCAGdWprhQQaYjMgE9gztKrgBdKCIAoaDcb8tP25Yh4906r98xkl1mVeRC
         VMS9oImduWKXmi40OVfVM7RHvPTda5ejSBLkOsS7jSlN5gAQ+wFnM2/1BDo6e9rYmDmF
         vNMhVysalmLJuWvHqo0onPDB8FBWYkdPa9fR/U3bPeZzWblRzQWMKibffpg3RfUsdkti
         3RfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Znf0DnHGX7qcHNgMOFUs4bIDbQazikbc4EZbjGrPUaA=;
        b=ikYnlGjD3NanJO24os48+FHXWumEfT8CpMF+xj4DeBG7c4mdWelJWdZGTF8wX7cCQx
         zbulrX1WkTq5lU/+wSIyA+IZGeRCGM4KMyVnmtrA6EZbiOn3/8ClagOkqlBrBEH2ej+6
         TM5pr/pcBCyK29zmzwpCHfGwhNGJSkKGHIadjvWQrgudIWD3FzsoPSFzEwK2R2D/uiVM
         RHFL+5DmJrvIETHF9gkJ43i1MFzW1mwvyfDRC35H7iNkbwm/0JKiTNi2nTLn/MoPwvSJ
         GAf0t7IOCnCUTrbFOW5Tt+MxUeuDpEmH/URQRTy7gCCNnOvGww32GTCUKYbaJ067C/GN
         mhQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z6si537523ejq.49.2019.03.04.04.01.44
        for <linux-mm@kvack.org>;
        Mon, 04 Mar 2019 04:01:44 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 73ED6A78;
	Mon,  4 Mar 2019 04:01:43 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A32AD3F703;
	Mon,  4 Mar 2019 04:01:39 -0800 (PST)
Subject: Re: [PATCH v3 05/34] c6x: mm: Add p?d_large() definitions
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mark Rutland <Mark.Rutland@arm.com>, Peter Zijlstra
 <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>,
 "Liang, Kan" <kan.liang@linux.intel.com>, linux-c6x-dev@linux-c6x.org,
 x86@kernel.org, Ingo Molnar <mingo@redhat.com>,
 Mark Salter <msalter@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
 Aurelien Jacquiot <jacquiot.aurelien@gmail.com>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>,
 Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-kernel@vger.kernel.org,
 James Morse <james.morse@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-6-steven.price@arm.com>
 <20190301214851.ucems2icwt64iabx@kshutemo-mobl1>
From: Steven Price <steven.price@arm.com>
Message-ID: <f840db0e-bbb3-db7e-d883-79b5a630767c@arm.com>
Date: Mon, 4 Mar 2019 12:01:37 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190301214851.ucems2icwt64iabx@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01/03/2019 21:48, Kirill A. Shutemov wrote:
> On Wed, Feb 27, 2019 at 05:05:39PM +0000, Steven Price wrote:
>> walk_page_range() is going to be allowed to walk page tables other than
>> those of user space. For this it needs to know when it has reached a
>> 'leaf' entry in the page tables. This information is provided by the
>> p?d_large() functions/macros.
>>
>> For c6x there's no MMU so there's never a large page, so just add stubs.
> 
> Other option would be to provide the stubs via generic headers form !MMU.
> 

I agree that could be done, but equally the definitions of
p?d_present/p?d_none/p?d_bad etc could be provided by a generic header
for !MMU but currently are not. It makes sense to keep the p?d_large
definitions next to the others.

I'd prefer to stick with a (relatively) small change here - it's already
quite a long series! But this is certainly something that could be
tidied up for !MMU archs.

Steve

