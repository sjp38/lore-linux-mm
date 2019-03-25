Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECE8CC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 23:09:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D2DD2083D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 23:09:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D2DD2083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=inria.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A8C16B026B; Mon, 25 Mar 2019 19:09:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 258596B026C; Mon, 25 Mar 2019 19:09:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1499D6B026D; Mon, 25 Mar 2019 19:09:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC73F6B026B
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 19:09:42 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id t20so1339587wmi.1
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 16:09:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=yNY+r7fy0+bWCufAElY20TGf5303skM/4i8KcXtG52c=;
        b=OZd5nCNjGVTOC8CI870+pCsxE7PjWYwxEddCE0IALnP4lhOj0ccXWiNFjU0hBQSwVg
         UMpavgzZ5hClEqTJ8ScxagG1Zbd6Vm8zEimCFlnvtbxTRjaW1Ue3dVfcRwFERcO+O41/
         bO1VDN5pZfHTZu+ZQecGV3U2BucBQVzyBYK+AZ6o5UoIBiSCfCVBej1kd9gbPvRtmtW4
         LQCNv4PfqqTIJQ2E4Nk+w95VMMUvI0ORQOtuZSBq4O/zKzy7Q6PA5nLgMuD9pODVOho8
         wSsG4dPTpuNu7RM2aR8fx9B/CiYSTCHdZQaxyHLPli+Me68R7qTMC9S3hM0RsVsxarwl
         hpAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-Gm-Message-State: APjAAAUFFdcL4Kf2PL2cTX+F733N71iL3m0CtUK0s+AnIgRMTwZo2Q6w
	xuk1PsuS3cQyocBBnkMB6aXby71ejW6Q5t055juaNLE7OPZ+Pr6GVrkGVj7cXK+SS41pGYxhlBk
	W30fXOhEIElNorTagpRVf7s0i/vWG2XePw/V65ZKuo0lfOPbf0/G7t7ng2xKdnTBO0A==
X-Received: by 2002:adf:f088:: with SMTP id n8mr18699835wro.112.1553555382356;
        Mon, 25 Mar 2019 16:09:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUxubOHpBqNPHyqCyOMEnCVKUHwy4Ii0iZo6npR1GGkdA9pU3dZVj+2P0vciV5h99ooEwZ
X-Received: by 2002:adf:f088:: with SMTP id n8mr18699803wro.112.1553555381612;
        Mon, 25 Mar 2019 16:09:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553555381; cv=none;
        d=google.com; s=arc-20160816;
        b=nACL0cNN9kKBOFMiolgwn+APK8+qNEIeQFXWDUoaIiaXLrbdn32iyT6kc+cmqb8apJ
         OQqOcGU1C99KO27IYdAD4Ha/I1rOsGh4dBLiKIIiFWrkqW0x6HSmqvZ9o9Ss8BSmn9pm
         VtTR+ezTFLcbb0beRn+VwCLYPAn32OQl8QGJfXZ4y2++d1UlfWR6d2nmtkaKlFxyXs4f
         e6LxSbwtqC+EBNpKSLcHRP4NfXH7i2s/3OmhcRc+8G8g0d9/ORyj6KUobZfeMr06g4V6
         Yvd9bfpZ6MpWs4g2MqeeTFN+icW/N5d+jcCCFx/neFargPxv7+a0emv5NX2mmK1WoMbz
         nlzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=yNY+r7fy0+bWCufAElY20TGf5303skM/4i8KcXtG52c=;
        b=HHO8RUN0Wx8LKpCXWS+Q1Pec3uGVEmlaMRLZRPCl1YEses65w7P6oX1thlMkGQZ5NC
         ohWc1FlaxyrpSHrG9IId8lQXfJCRpN6JA6KrFAz4msAr+7DG6zILxqB/gM+MdoQxpVeq
         FJw78pDtvYm+qv6OLEY/NzWIxfaGHdv2LFxV+B37SPzM1KKFN0VZikWK58V01OadZMgc
         /osk/wYp8BxZpj6eJlPaxw42qG7bBoMw+Opy2AqT7Weq61fTi5Dhw9oIOMSPe32OtbLL
         HP0sw46StCSOC+Oy4NtFiEglfajWA/P1TcP9krSSPj+JbCwM9c3R4dLn1PMkUa25m+se
         0FMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id x9si11073626wrr.234.2019.03.25.16.09.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 16:09:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) client-ip=192.134.164.83;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-IronPort-AV: E=Sophos;i="5.60,270,1549926000"; 
   d="scan'208";a="375705032"
Received: from 91-160-5-165.subs.proxad.net (HELO [192.168.44.23]) ([91.160.5.165])
  by mail2-relais-roc.national.inria.fr with ESMTP/TLS/AES128-SHA; 26 Mar 2019 00:09:40 +0100
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
To: Dan Williams <dan.j.williams@intel.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Michal Hocko <mhocko@suse.com>,
 Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@surriel.com>,
 Johannes Weiner <hannes@cmpxchg.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Dave Hansen <dave.hansen@intel.com>, Keith Busch <keith.busch@intel.com>,
 Fengguang Wu <fengguang.wu@intel.com>, "Du, Fan" <fan.du@intel.com>,
 "Huang, Ying" <ying.huang@intel.com>, Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <cc6f44e2-48b5-067f-9685-99d8ae470b50@inria.fr>
 <CAPcyv4it1w7SdDVBV24cRCVHtLb3s1pVB5+SDM02Uw4RbahKiA@mail.gmail.com>
 <3df2bf0e-0b1d-d299-3b8e-51c306cdc559@inria.fr>
 <CAPcyv4gNrFOQJhKUV7crZqNfg8LQFZRVO04Z+Fo50kzswVQ=TA@mail.gmail.com>
From: Brice Goglin <Brice.Goglin@inria.fr>
Openpgp: preference=signencrypt
Autocrypt: addr=Brice.Goglin@inria.fr; prefer-encrypt=mutual; keydata=
 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
Message-ID: <ac409eac-d2fa-8e93-6a18-14516b05632f@inria.fr>
Date: Tue, 26 Mar 2019 00:09:40 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4gNrFOQJhKUV7crZqNfg8LQFZRVO04Z+Fo50kzswVQ=TA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Le 25/03/2019 à 20:29, Dan Williams a écrit :
> Perhaps "path" might be a suitable replacement identifier rather than
> type. I.e. memory that originates from an ACPI.NFIT root device is
> likely "pmem".


Could work.

What kind of "path" would we get for other types of memory? (DDR,
non-ACPI-based based PMEM if any, NVMe PMR?)

Thanks

Brice

