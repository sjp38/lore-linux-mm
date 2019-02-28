Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0895CC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 19:00:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B817320854
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 19:00:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B817320854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5435A8E0003; Thu, 28 Feb 2019 14:00:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F1698E0001; Thu, 28 Feb 2019 14:00:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36AEE8E0003; Thu, 28 Feb 2019 14:00:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E4E518E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 14:00:20 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id e4so16763518pfh.14
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:00:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=+wZstu3IXkKxZCe/HXgT9o1rswofVdYHm664llwEyuE=;
        b=O1XIfFRL0fc8SjVTTaQsup9Y0zsoR2rLIiJtvDhDu3IWUp66Rlx+LFRf6fAlwFXebb
         E0TPJe5CydoaIm4BsP3l3WdmcVzkZcHndknL/MeHAM3d74l6tUDzKa0G5i9wpAf9GA4B
         tWhfVorYeQtDvMAf3OLEIOHtp2CxxvAMBdSf7jWl2r2TT7P8Dg6I3g+WO/jm6c5vFB+R
         6PxvZ+3JdikmBCW79is/QV21NQk+8ehiMHzqA7hk0i5BNRGua7xD3hO2Z/6MeOHNRLX5
         Wk1dotscIugLGN0iydPLbljbEzo3IbfXdK160YSUqWd/Lww2nRU7T6gilwb+FNomj8ix
         +U3g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXhpGRHFn/syJTxRrF8/KLlWKKAH/9wQya+OmseBeHAghatj9GB
	r6KWFnNcFhPq3kvwWWWcRNcNIIwRLN19G1XlyPgKSa0iyhve9QQDreDdDarqBJEJkk7KXJLPnP+
	Bp94UwVqDrNoV2tqGrWybBoGcvIyxAp0dR42y3j5PR6RJ2c3ljDLaGF0JO6sq+g//vQ==
X-Received: by 2002:a65:6298:: with SMTP id f24mr618023pgv.183.1551380420551;
        Thu, 28 Feb 2019 11:00:20 -0800 (PST)
X-Google-Smtp-Source: APXvYqwDpiHoGYi8/SqtY6VIw0KWs9FigCETofYlpWnWJB+uZCjHaM+sXWNDQT0Hwc2OwKDFqtFb
X-Received: by 2002:a65:6298:: with SMTP id f24mr617948pgv.183.1551380419544;
        Thu, 28 Feb 2019 11:00:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551380419; cv=none;
        d=google.com; s=arc-20160816;
        b=xfWECE9JI2XHDAfq7d6MOYhbJNf+5mV/GuJrX/oR0Svr/eLIzAbQetRLt9MAXLGrH3
         8BSnqyItMfepBozxe9QgmLUzDA6g+UkjULh7vhwP0/JcotcZ25tY505hmHmUi3aF5KRf
         JMPSJSBVd+JTghOLrCOUop3OLYOusqWm0i4y1cdPCavUitO10l/jMUD4r3tO3QxADV0B
         At5m4EPil5eNzRfbv15Z07IwAvdgv44yt9pEZ2fhR1fc2Iee6yHcU4Z03mJf4sGqRas2
         M2b9clHmAFeUVUeRrpt1fXHi07qOrXDAUpmJzBG1DE/QvWzVZr7SZIjfdJPI/oM9bTjt
         HzVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=+wZstu3IXkKxZCe/HXgT9o1rswofVdYHm664llwEyuE=;
        b=VE2bpttcpUPDacZOne5DmlIECHWFQ628SWRZX6GT7UE0R82Z+PZFe8FZ/kRF1H5HAf
         tXHTcqTNQaETeXQ4iVwu64M/eOcXJUE2oBgm1gF654C0PFZfSCxJR5wT7aKKI6+47eKU
         Z2ni3GpmTWjhwBvkCgxKBR26zwkTsgVrfXqNi9LBQWUoK1C0wTAJPkzZxUFrRUs0pMam
         GceSknJeu+OlnE1VLQBG0PLuWPM3ElK7cnr7nkubg9GggggDbOvitUwajH4TezAcysqn
         Fqfuatt89e/7fKpn6EodzrHshJObPeQI7fBnAXycEf/ynPqaSh+AbDzCgfh8dU4BHrO8
         9X8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id m24si7721879pfj.218.2019.02.28.11.00.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 11:00:19 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Feb 2019 11:00:17 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,424,1544515200"; 
   d="scan'208";a="278664974"
Received: from unknown (HELO [10.7.201.133]) ([10.7.201.133])
  by orsmga004.jf.intel.com with ESMTP; 28 Feb 2019 11:00:16 -0800
Subject: Re: [PATCH v3 27/34] mm: pagewalk: Add 'depth' parameter to pte_hole
To: Steven Price <steven.price@arm.com>, linux-mm@kvack.org
Cc: Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-28-steven.price@arm.com>
 <aece3046-6040-e2ec-fcd7-204113d40eb7@intel.com>
 <02b9ec67-75c5-4a36-9110-cc4ba6ee4f94@arm.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <5f354bf5-4ac8-d0e2-048c-0857c91a21e6@intel.com>
Date: Thu, 28 Feb 2019 11:00:17 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <02b9ec67-75c5-4a36-9110-cc4ba6ee4f94@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/28/19 3:28 AM, Steven Price wrote:
> static int get_level(unsigned long addr, unsigned long end)
> {
> 	/* Add 1 to account for ~0ULL */
> 	unsigned long size = (end - addr) + 1;
> 	if (size < PMD_SIZE)
> 		return 4;
> 	else if (size < PUD_SIZE)
> 		return 3;
> 	else if (size < P4D_SIZE)
> 		return 2;
> 	else if (size < PGD_SIZE)
> 		return 1;
> 	return 0;
> }
> 
> There are two immediate problems with that:
> 
>  * The "+1" to deal with ~0ULL is fragile
> 
>  * PGD_SIZE isn't what you might expect, it's not defined for most
> architectures and arm64/x86 use it as the size of the PGD table.
> Although that's easy enough to fix up.
> 
> Do you think a function like above would be preferable?

The question still stands of why we *need* the depth/level in the first
place.  As I said, we obviously need it for printing out the "name" of
the level.  Is that it?

> The other option would of course be to just drop the information from
> the debugfs file about at which level the holes are. But it can be
> useful information to see whether there are empty levels in the page
> table structure. Although this is an area where x86 and arm64 differ
> currently (x86 explicitly shows the gaps, arm64 doesn't), so if x86
> doesn't mind losing that functionality that would certainly simplify things!

I think I'd actually be OK with the holes just not showing up.  I
actually find it kinda hard to read sometimes with the holes in there.
I'd be curious what others think though.

