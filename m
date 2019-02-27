Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00985C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:33:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE42C20C01
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:33:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE42C20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=daenzer.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 574988E0014; Wed, 27 Feb 2019 12:33:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5246A8E0001; Wed, 27 Feb 2019 12:33:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3ED088E0014; Wed, 27 Feb 2019 12:33:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id D76578E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:33:25 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id f202so1836305wme.2
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:33:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=1bPUAk66HTQWuqjTpWM1Tn89VgGQ4ACqSLLpN1uU1aM=;
        b=ALaLyhCvkLdxO9BQJ6FLG+DNSyZp/Z1Z/yAZbl+Y1W7/cvhEch4AagNeW9VU4dRycN
         Vuof0V5P7JnMD59RDGwKrGAFjkf55a+BRT8w3Oe73nee6aayaFJfjMrgsVHfhl2OxyHx
         8qtl6Vr9ZKZ4S5Jpxqtssd/1m4tvYhG6HE3d4EZ08ITBbdRtQGgwmf3eEwmWivyPbTqy
         pxF0Au1wNscCpLcJ4r6HAq+uDA22FcEfj/KjMbXmVqChyrZA4dOzov43kZtLae7Rv/JP
         kF6//7fTwTjb5JTJ/EgZ8FoUD6g1faCnAEydgIh4OCIVMyXajWc1usXv3NS9i/Ro8Y8X
         LCTg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) smtp.mailfrom=michel@daenzer.net
X-Gm-Message-State: APjAAAXVbl2ba/F7IxeyW1O1xKUyS6Fqz2yvuPdpNF0g0YKyzd+ZjcGt
	jCAuoXK4RB4B3kltvYw8g+N69o5jYwEds9R+K5dHUhByvT0fShCuOjo5Ro+tq3o7TduG3kPNm9s
	wKSsdZJRZa7piWEGo+opsZMxHWr7DnPMKNGYnGhboryerBBV/L5WQK+OrKQC19gM=
X-Received: by 2002:a5d:6346:: with SMTP id b6mr3326230wrw.118.1551288805426;
        Wed, 27 Feb 2019 09:33:25 -0800 (PST)
X-Google-Smtp-Source: APXvYqzgOnXBhIwY+hj+yV/OusEQ07ueraEvKSMPDTTtDcjOmK8aiFl4tG3MmLjRQoh+R98mIaIO
X-Received: by 2002:a5d:6346:: with SMTP id b6mr3326176wrw.118.1551288804509;
        Wed, 27 Feb 2019 09:33:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551288804; cv=none;
        d=google.com; s=arc-20160816;
        b=dSLjUBrM+YRJSqbeMSP5Hm7wHxBaZc8jqJ5x2I+JEfiq3hNFIfL3igTdktTxo4qfQm
         Uw3ptYkb2daBUb5A1kFPr5gs7G0LGPmGJ27f2xXYUkR+IF5zm6K81EbP9m6QntLibkAR
         mnR1lCg1UmRWTq13Dm1WkXQgHVAuGEkUX0FIXMYA1YZQaxxbAWnuDPQmyZ+o31ZbXmeG
         o4dGiidGuf9PLEtB3zz+OYIYN8lPR41GHDl/ROz40yTSnbO6IEZo8eeHen2YFcdUcTiq
         BJMpg1RnS1eUteJzHGldSZeGUZ3FGKHPQ7K1ZivYAU9nBWwOIEzsYLdBnsZ5xkU28cXf
         3ryA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=1bPUAk66HTQWuqjTpWM1Tn89VgGQ4ACqSLLpN1uU1aM=;
        b=f57ky6gD5gFYfOx4xGxx7B11ZM5DiLzNMBPQiUUzr4DZEz769PNB7ew6KMpoW8KZ94
         NWb3JTV4dfREraLd0j4RA56PtxDbEboZ3MFQZtZIIXVf9i2zW+qeYWDypDppR5rlN/4t
         ovzqnCBnPHdw4dE5hEOLfIajENt/Ddn+uRS+x/soCQCXgqhHIBx63oKiUHHGDE/hdc9G
         R0RC/iMTs8uRGD0TQQAAoFDi0N6jyTXGcqxfYxGrVbjnPhxbUs2poozpPrOJ9tH+QRTv
         OAaiJyWXQ81/SZiSBScwnezzJfAmuZPsiGkc3W2/HEaQJQdzVnB8BMX/K56+TqfVv/WN
         gc3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) smtp.mailfrom=michel@daenzer.net
Received: from netline-mail3.netline.ch (mail.netline.ch. [148.251.143.178])
        by mx.google.com with ESMTP id 1si11216784wro.275.2019.02.27.09.33.24
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:33:24 -0800 (PST)
Received-SPF: neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) client-ip=148.251.143.178;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) smtp.mailfrom=michel@daenzer.net
Received: from localhost (localhost [127.0.0.1])
	by netline-mail3.netline.ch (Postfix) with ESMTP id 0DEC62A6059;
	Wed, 27 Feb 2019 18:33:24 +0100 (CET)
X-Virus-Scanned: Debian amavisd-new at netline-mail3.netline.ch
Received: from netline-mail3.netline.ch ([127.0.0.1])
	by localhost (netline-mail3.netline.ch [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id gYyJmhOYGSDL; Wed, 27 Feb 2019 18:33:23 +0100 (CET)
Received: from thor (116.245.63.188.dynamic.wline.res.cust.swisscom.ch [188.63.245.116])
	by netline-mail3.netline.ch (Postfix) with ESMTPSA id A2B532A6058;
	Wed, 27 Feb 2019 18:33:23 +0100 (CET)
Received: from [::1]
	by thor with esmtp (Exim 4.92-RC6)
	(envelope-from <michel@daenzer.net>)
	id 1gz359-0006sp-7l; Wed, 27 Feb 2019 18:33:23 +0100
Subject: Re: KASAN caught amdgpu / HMM use-after-free
To: "Yang, Philip" <Philip.Yang@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>
References: <e8466985-a66b-468b-5fff-6e743180da67@daenzer.net>
 <83fde7eb-abab-e770-efd5-89bc9c39fdff@amd.com>
From: =?UTF-8?Q?Michel_D=c3=a4nzer?= <michel@daenzer.net>
Openpgp: preference=signencrypt
Autocrypt: addr=michel@daenzer.net; prefer-encrypt=mutual; keydata=
 mQGiBDsehS8RBACbsIQEX31aYSIuEKxEnEX82ezMR8z3LG8ktv1KjyNErUX9Pt7AUC7W3W0b
 LUhu8Le8S2va6hi7GfSAifl0ih3k6Bv1Itzgnd+7ZmSrvCN8yGJaHNQfAevAuEboIb+MaVHo
 9EMJj4ikOcRZCmQWw7evu/D9uQdtkCnRY9iJiAGxbwCguBHtpoGMxDOINCr5UU6qt+m4O+UD
 /355ohBBzzyh49lTj0kTFKr0Ozd20G2FbcqHgfFL1dc1MPyigej2gLga2osu2QY0ObvAGkOu
 WBi3LTY8Zs8uqFGDC4ZAwMPoFy3yzu3ne6T7d/68rJil0QcdQjzzHi6ekqHuhst4a+/+D23h
 Za8MJBEcdOhRhsaDVGAJSFEQB1qLBACOs0xN+XblejO35gsDSVVk8s+FUUw3TSWJBfZa3Imp
 V2U2tBO4qck+wqbHNfdnU/crrsHahjzBjvk8Up7VoY8oT+z03sal2vXEonS279xN2B92Tttr
 AgwosujguFO/7tvzymWC76rDEwue8TsADE11ErjwaBTs8ZXfnN/uAANgPLQjTWljaGVsIERh
 ZW56ZXIgPG1pY2hlbEBkYWVuemVyLm5ldD6IXgQTEQIAHgUCQFXxJgIbAwYLCQgHAwIDFQID
 AxYCAQIeAQIXgAAKCRBaga+OatuyAIrPAJ9ykonXI3oQcX83N2qzCEStLNW47gCeLWm/QiPY
 jqtGUnnSbyuTQfIySkK5AQ0EOx6FRRAEAJZkcvklPwJCgNiw37p0GShKmFGGqf/a3xZZEpjI
 qNxzshFRFneZze4f5LhzbX1/vIm5+ZXsEWympJfZzyCmYPw86QcFxyZflkAxHx9LeD+89Elx
 bw6wT0CcLvSv8ROfU1m8YhGbV6g2zWyLD0/naQGVb8e4FhVKGNY2EEbHgFBrAAMGA/0VktFO
 CxFBdzLQ17RCTwCJ3xpyP4qsLJH0yCoA26rH2zE2RzByhrTFTYZzbFEid3ddGiHOBEL+bO+2
 GNtfiYKmbTkj1tMZJ8L6huKONaVrASFzLvZa2dlc2zja9ZSksKmge5BOTKWgbyepEc5qxSju
 YsYrX5xfLgTZC5abhhztpYhGBBgRAgAGBQI7HoVFAAoJEFqBr45q27IAlscAn2Ufk2d6/3p4
 Cuyz/NX7KpL2dQ8WAJ9UD5JEakhfofed8PSqOM7jOO3LCA==
Message-ID: <c26fa310-38d1-acba-cf82-bc6dc2f782c0@daenzer.net>
Date: Wed, 27 Feb 2019 18:33:23 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <83fde7eb-abab-e770-efd5-89bc9c39fdff@amd.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-02-27 6:14 p.m., Yang, Philip wrote:
> Hi Michel,
> 
> Yes, I found the same issue and the bug has been fixed by Jerome:
> 
> 876b462120aa mm/hmm: use reference counting for HMM struct
> 
> The fix is on hmm-for-5.1 branch, I cherry-pick it into my local branch 
> to workaround the issue.

Please push it to amd-staging-drm-next, so that others don't run into
the issue as well.


-- 
Earthling Michel Dänzer               |              https://www.amd.com
Libre software enthusiast             |             Mesa and X developer

