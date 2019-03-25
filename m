Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99E56C10F03
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 10:14:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6246320863
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 10:14:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6246320863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02BB36B0007; Mon, 25 Mar 2019 06:14:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F1C1E6B0008; Mon, 25 Mar 2019 06:14:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E347C6B000A; Mon, 25 Mar 2019 06:14:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id ACEC76B0007
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 06:14:22 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id j3so530769edb.14
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 03:14:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=uO/rTWLHK4lOv0h2P5/bIXfXDua2Sy/Ef3aDZeQRc9A=;
        b=fVhepCBEfDzjorJWzLmRUdoZyzu7G2SvT3uIUcT8nNDCkI/LiFWxSCcfd6IjGXvMYd
         AxWar4jM/V6LOaiEwfOlpFoLTjvReMIvQsA8Tz/lPs/u3fiTEKRy495LCFWzuyAkBugc
         syUJIf0J8/NYG1CQBDcbJ+Lnl0RaQUtLXK8IgnZwGAMpc9z4SlYCNzgN8i/ABMTXWvUa
         vHKkDl6RIEVLg+iGs188wH3o6ZA1PkhBAij9RExrvgrCK0Aj1WdMub3IGa8//8wgSW/X
         Lz1LeGhNRcvW7pu3gDtuFTWYoL1IDGUZrLSGzKTkocKip3Dbk9kDKY4C6W1tVJHN4byl
         htjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUszA0U+X+M21GHSzWF722bytz1JkEZ+iPl4m97HYKpdCBv2O2D
	TkUgbfmXzphbQu2cXuvPw++p2wDi26Jv2Kuf9LiStyuSFPqUp9+0A4hojglZotZ+L6m/x8/oUT7
	9Qb+W174w0LwdUkpNicD9Cjrx1h5Se/8EtuCL/9KjTDj1ZdQU8TIcFpDpqY5M5deoSA==
X-Received: by 2002:a50:8818:: with SMTP id b24mr15927161edb.86.1553508862295;
        Mon, 25 Mar 2019 03:14:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz20Y3IF1RyHx0nuUnjRdsm4auA3P6BwJq7w95RQczKqsNduzgkydpeid4Dym3eOtfhF8Xf
X-Received: by 2002:a50:8818:: with SMTP id b24mr15927116edb.86.1553508861248;
        Mon, 25 Mar 2019 03:14:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553508861; cv=none;
        d=google.com; s=arc-20160816;
        b=YlH5OcmQmt9VWhQGDkxQN+CVpWremm3ycGKbvJVomQRBKkkEZN0dgcWgf7+qn8pqwd
         dwOqhqMJ8J4+RkJKmgO02f/8asMKB9/KEqoPt1gjr01k9bLQauX1CO5GgLgjgPdXNn38
         QFBRT72TN7tTZTh9S5IXzRFBBz8vVQ8FDu7S7CMstZO6Fov0yh6TupVvBuW441fm7kS1
         EWR+B4eZeD6c/j7BygpAvpIgvxMYNTRCNo5rpriwyBs2Udc4kXVMNgLeVmUu39Toy7bt
         XLVW6fY2GHSqZ+XP22OZ8/bJ3mVqBno0Ibk8N4wuLWKK22chM8BW7J8pYWsreENEoxQh
         YDcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=uO/rTWLHK4lOv0h2P5/bIXfXDua2Sy/Ef3aDZeQRc9A=;
        b=uVDIUPnOSFLu7NRx8zR1hrIQYLkvftil0v+1QWYteM2p9f5N/X+i2Pyii4hQS7vzPV
         RMMbOm6oPiEU+8X+erWfw+esWW9koi39WWZ43jcLX4QzAqjFX40HIX0hVEXzrC59/Mds
         ewEg9wDHeUslyKuEPQMtpp0k0Pw+NLfgcgsI0AApaC8YPUxhayZAHEXnWvl+6S1Fu2Wq
         slZbD6l8mRERN9NIMBx0aZIag0+UIlYIGPfDIgSj3ebzMcnBUlTII9ksuADSwo0EcQhh
         iyGhaVDfEoMo6Vjp+NXjrep9GNfzFaOdln/7n6gT29nn38njKrfOvnsW5y/hG1u53N/b
         W+Lw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id jp19si705247ejb.116.2019.03.25.03.14.20
        for <linux-mm@kvack.org>;
        Mon, 25 Mar 2019 03:14:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1A1051596;
	Mon, 25 Mar 2019 03:14:20 -0700 (PDT)
Received: from [10.162.41.136] (p8cg001049571a15.blr.arm.com [10.162.41.136])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 964043F575;
	Mon, 25 Mar 2019 03:14:16 -0700 (PDT)
Subject: Re: [PATCH] mm/cma: Fix crash on CMA allocation if bitmap allocation
 fails
To: Yue Hu <zbestahu@gmail.com>, akpm@linux-foundation.org,
 iamjoonsoo.kim@lge.com, labbott@redhat.com, rppt@linux.vnet.ibm.com,
 rdunlap@infradead.org
Cc: linux-mm@kvack.org, huyue2@yulong.com
References: <20190325081309.6004-1-zbestahu@gmail.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <ae607b46-05a4-f442-e9f6-346d2647044d@arm.com>
Date: Mon, 25 Mar 2019 15:44:13 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190325081309.6004-1-zbestahu@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 03/25/2019 01:43 PM, Yue Hu wrote:
> From: Yue Hu <huyue2@yulong.com>
> 
> A previous commit f022d8cb7ec7 ("mm: cma: Don't crash on allocation
> if CMA area can't be activated") fixes the crash issue when activation
> fails via setting cma->count as 0, same logic exists if bitmap
> allocation fails.
> 
> Signed-off-by: Yue Hu <huyue2@yulong.com>

Looks good to me. Just wondering if cma->count =  0 should be wrapped around in
a helper which explicitly states that this cma cannot be used for allocation.

Nonetheless.

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>

