Return-Path: <SRS0=AfK9=QX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0212BC10F00
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 15:15:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95FD4222E6
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 15:15:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fTsB3uV3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95FD4222E6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F31818E0002; Sat, 16 Feb 2019 10:15:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDE908E0001; Sat, 16 Feb 2019 10:15:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D80078E0002; Sat, 16 Feb 2019 10:15:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 657CD8E0001
	for <linux-mm@kvack.org>; Sat, 16 Feb 2019 10:15:43 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id n25so1341353lfe.15
        for <linux-mm@kvack.org>; Sat, 16 Feb 2019 07:15:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=wdTsZwTAaPhrPSYQ7SDKMQoj7M1FkPvkbIiKXhOxM1o=;
        b=kYmPsOI0+kV6qyj2jYMCeZPG8RgY13GRE2CyKidofaMJiplW4wAEMxIQAdQfiTUZtO
         CF79RN9MHvKHeeyT3WOCDexpO6yYhDL8NVCo/Mtz0tXX9DLCCN6hU7zwFy/fm2n7FqB5
         Dy8s6AMQwrQ8bAizzpsO/7yn78ojt52quqdZq0KZt63pYei7GKstHr3lZTf04kd32dZ2
         jH0rw8lg7XG+RvK5xWauDk5php67qhTiSXmSSMZnrLBtnnNmqZqNVGGZKOnYs4KXzVgt
         h3MFZEthuNuKov+8zH+3VCpZtobKGOUIEgjZxizvUsC19kG8sc1LNArZXc25uxdemxJR
         k3AQ==
X-Gm-Message-State: AHQUAuZBBpfX/aKxepYr6ra6mvrJFPGrwR83etdlX+g8Lh2ww3aiAsKJ
	2wa354rHXNfvnYSm4ZXf49cp2169HJV8xNRR+5cLSHemajICV1zPsylgHyR+eqtrbSNjMdVRi+L
	qNKCQExiTT82GQtuGsXT+c6I08WSnqNAO91I+rZ9NtUA9pAkfZX1IEzfo6d1+2DPwdwPcV0Z8QY
	U5eJcGPWtu440tymik1Ad/1/mLtG5WO2+dbY77HXVvDNkZ3Flle9N9NfQlazW1HRsqPMWcKs8bP
	10u/Kjmg2JpYnZ8oh8q+VDpyWTbKtjZ77eqWiW6xC/dn6NqYeZCSgbM4iMWDVkxBI6qT+eYnYMG
	xe6dCKTmQrTb+FeCL17JjiropexS/UMWc3Yukbj0hqG2h+CRjc2JpLC+V/SF2nvbAZC0KdNIxNF
	c
X-Received: by 2002:a19:1d1:: with SMTP id 200mr8600421lfb.7.1550330142598;
        Sat, 16 Feb 2019 07:15:42 -0800 (PST)
X-Received: by 2002:a19:1d1:: with SMTP id 200mr8600386lfb.7.1550330141499;
        Sat, 16 Feb 2019 07:15:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550330141; cv=none;
        d=google.com; s=arc-20160816;
        b=ayOo9IEqsPFw7dAPCVJ3uB6SYg/3Hos4oJgXSvD0fWbMuyfvr1132QWZXrL+/LYE2x
         C1Q29hBj2FkPIZxe0XUI2lLb44Tr2CAnqICXQqEpAcI6AAJ+WmPJBHZVRHKxkq1wSmwV
         WtBxyEePQqnJg4SHLbseclc1fxzi8b548Zjv5YKpdg572Y6NMWMMOHBjxcHs3ts6jUt0
         hH/BsPO2LFIpX/W5LP78n9XpsjB/eQP6Q1xk3l8Vkn0WBQvJHzCDRjrkfLuX3K4Ru76A
         lwI13xiENT1AX4c8FdAfN2JB4E5JAbHHZ4pnz+w2N5FFC7W7pQ+tUbQW6ogoaCSHGY4I
         kspA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=wdTsZwTAaPhrPSYQ7SDKMQoj7M1FkPvkbIiKXhOxM1o=;
        b=r4gzDOpTHwR7FHirsFT3ad3bhRvxED5SnzgkP15CRDeyZal4rg+i/ZhErrNYvcX8Pt
         NkV4V0fDDZZcibu3wtY+2UFamDp0Xp2GkZvBypNtKYk4CVLAJf3kWcRaPDkECRoIzF25
         5kbebNTKD0qGtMSQv4rlmsNNNatSDsGykvATx5OIzQszcAQayywUaFChbnrRgEJQrGND
         SOVeibxIwg+0TgTywSRYAEV/kGiyl2Xkg3dFxzS52aCfCuDFZ+CtKAfINs1FpjMi/7kF
         oQPvbNMYkWQmfvudMW3TJqRSmrlux08edyUZz43M4GWkaBgVMud3ldJ/e0aqxtSgokBg
         QqCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fTsB3uV3;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s2sor4835714ljg.14.2019.02.16.07.15.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 16 Feb 2019 07:15:41 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fTsB3uV3;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=wdTsZwTAaPhrPSYQ7SDKMQoj7M1FkPvkbIiKXhOxM1o=;
        b=fTsB3uV3xHqZz9A3cBt/r5vwxdxs4oXujXCiC23mQ4ZTp9ZkQOEHUN7rO0o6ancVh9
         dBeq279h+6PLlQ3/TBnSvhdh84GNxMsZUSDQYsfAJ6PpA6WSbhNbQpRg9v2OLssyaZFV
         FAPykvIJwxRyqb6TuMk0XLnZoAFpVccdmQF3ITvdR8ju+dWk1FBLly2vgeFxk/Rh0zQ5
         ZZtWhKfMgowQpmsmByI6Wsgy0Ji2MqkJzoK2+mIxxDeSXAaMAAcHYJG+Lk5EaYX9o8iU
         VGbe6mF3IXi9bwzxEZXE06N03BdJKzGZc8iIYAHswC8mCrdoe9TJiTCOFXmtvF7z3Bgp
         EhWA==
X-Google-Smtp-Source: AHgI3IY7YpKG/T9n2PPQdafMl8YMC1f7twBEfDyXT15eGXEM7uukiZTWpEIvigeNDNaYa54ZwZC8UA==
X-Received: by 2002:a2e:4942:: with SMTP id b2-v6mr8241086ljd.168.1550330140849;
        Sat, 16 Feb 2019 07:15:40 -0800 (PST)
Received: from [192.168.10.160] (91-159-62-191.elisa-laajakaista.fi. [91.159.62.191])
        by smtp.gmail.com with ESMTPSA id p14sm2306998lfk.16.2019.02.16.07.15.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Feb 2019 07:15:39 -0800 (PST)
Subject: Re: [RFC PATCH v5 03/12] __wr_after_init: Core and default arch
To: Peter Zijlstra <peterz@infradead.org>
Cc: Igor Stoppa <igor.stoppa@huawei.com>,
 Andy Lutomirski <luto@amacapital.net>, Nadav Amit <nadav.amit@gmail.com>,
 Matthew Wilcox <willy@infradead.org>, Kees Cook <keescook@chromium.org>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Mimi Zohar <zohar@linux.vnet.ibm.com>,
 Thiago Jung Bauermann <bauerman@linux.ibm.com>,
 Ahmed Soliman <ahmedsoliman@mena.vt.edu>, linux-integrity@vger.kernel.org,
 kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <cover.1550097697.git.igor.stoppa@huawei.com>
 <b99f0de701e299b9d25ce8cfffa3387b9687f5fc.1550097697.git.igor.stoppa@huawei.com>
 <20190214112849.GM32494@hirez.programming.kicks-ass.net>
 <6e9ec71c-ee75-9b1e-9ff8-a3210030e85d@gmail.com>
 <20190215085736.GO32494@hirez.programming.kicks-ass.net>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <7cfb5d06-96a6-41a0-9f57-d9df1204f45e@gmail.com>
Date: Sat, 16 Feb 2019 17:15:38 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190215085736.GO32494@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 15/02/2019 10:57, Peter Zijlstra wrote:

> Where are the comments and Changelog notes ? How is an arch maintainer
> to be aware of this requirement when adding support for his/her arch?

Yes, it will be fixed in the next revision. I've added comment to the 
core wr_assign function and also to the changelogs for the patches 
enabling it on x86_64 and arm64, respectively.

Should I add mention of it also in the documentation?

--
igor

