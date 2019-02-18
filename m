Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BE47C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 14:25:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BAD5B20851
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 14:25:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BAD5B20851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=inria.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 583018E0004; Mon, 18 Feb 2019 09:25:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 532BD8E0002; Mon, 18 Feb 2019 09:25:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44A548E0004; Mon, 18 Feb 2019 09:25:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id E72918E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 09:25:33 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id e18so4162716wrw.10
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 06:25:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=cGy7PaQEUQZO7eztuSfrXKDBsfs90Mp6a06NSnYmuuI=;
        b=OdULAJPjh5gkuut6Rq+iuOTic82EQtPSNbDoEl3ZnFURu00dcBi8qS4svflPF2U1GJ
         UgLqw0EkKigTwDCMa1aUF2AUVhlf19Nu+uBpeRMk2qZsCqAh3Za6kZEvVtZGv2zs2NAA
         BN3KmV5ahIjt60AzHPXm3fnH2AHDPV+Sm6FlJ2bSd9aevJ8eL71l8M7TjJugyxC2BfDh
         Sfco5+3d71dPRd2XCbOKe5P9t2pwAYdK/CL9HvF1wAGaEDqQ5UEHzQJKKhUUers0G0zp
         nX1vDKjNI9tQVLvWkFsAHBlChp03yrZzRb0hg7euLmZmrFgBaGZ5Z/WYaI7rMg3JN6xI
         wUoA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-Gm-Message-State: AHQUAuaUzsddYSnNMn+N1bXWFzSIDU0f6XEN+PFKfj8W0m7LTsu4b3jS
	MULpGpqJ06vM7Vn5cF83k6iTmdyevEOGNiyIvg129bVvA1Q/kPXy3QoKLdu2SHwSCfD/4H8uiZq
	jleIn/YxcFWw4Um5ODCO7mTUdc7VsF1H0+c7gf6k4biIsjIU8Fq2OlhdVSxAb6TW/jg==
X-Received: by 2002:a1c:230e:: with SMTP id j14mr3167970wmj.9.1550499933462;
        Mon, 18 Feb 2019 06:25:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY7/YAFDbTd9L1DXbLjVOR0YRp/GLv4Ei4s607rZ+S8orLiIwAbT6p+5Mkd79cYp+vU6C1Y
X-Received: by 2002:a1c:230e:: with SMTP id j14mr3167927wmj.9.1550499932557;
        Mon, 18 Feb 2019 06:25:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550499932; cv=none;
        d=google.com; s=arc-20160816;
        b=cCCDj3wPrFpQwdDuZaTNAX+N/+vZszOUeeE311mCw1q0K0f6fAKXkxgKd6tYqVJddT
         RPPDlaBMmi3j7sBZZ/wtS5W3JnfJ95boK3oBDsfU7gce6InLnI9nNlti64J/u66lJIhG
         tdwZIPI14oHusqkRplHO0qddU4AC0SYTce3Ri9QVrzWdcrmG0FyzFW7LgnwhS5lxIZ22
         kVQSNBQ2qdh5hXq7wI9E1ghPwEgwhCwLXnUYmAeO+kX1EMWWihFBSJ6GfophYjz1xEJY
         HcVrhPBI8aoczXpSR2E2Pn8tqQkCwGzXuSkrvXOcMUBT5JGQnldXlUr1h6qbG57lcmSA
         YOtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=cGy7PaQEUQZO7eztuSfrXKDBsfs90Mp6a06NSnYmuuI=;
        b=jJ+p9evQS/qRtNWa1CscmfHRzEz5GNvc7hDX4B0qDTuYrBSgbqlXR729pMrE9Ceilw
         GReMbnOEDIj29o6dvOIZ52JmBg7S6yPrIlmYYXfpip9RaT4/GBpQEOhn5lq+3dje0FvP
         YNNP8U7p8mTOYIFpocki1sSQm5w1u1j+l03/xPCQLHSugkaFLYVaZ3ZP5+TKdQ9mG2ZC
         L6wSJyaVEZ+yP+wN+wVA+oR0XZW0DhK+YHMtDbD4tPG+s3hbKaEgWNeiVWxXmJeaKuSD
         7NCDMBFcZjJbotPKhFqNgHOMx8yxg96pwpFLV2ywGCno9BOuPUu+/0rYK7OeQGYv1dHP
         DReQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
Received: from mail3-relais-sop.national.inria.fr (mail3-relais-sop.national.inria.fr. [192.134.164.104])
        by mx.google.com with ESMTPS id c24si9120367wmb.197.2019.02.18.06.25.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 06:25:32 -0800 (PST)
Received-SPF: pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) client-ip=192.134.164.104;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-IronPort-AV: E=Sophos;i="5.58,385,1544482800"; 
   d="scan'208";a="296544740"
Received: from unknown (HELO [193.50.110.220]) ([193.50.110.220])
  by mail3-relais-sop.national.inria.fr with ESMTP/TLS/AES128-SHA; 18 Feb 2019 15:25:31 +0100
Subject: Re: [PATCHv6 00/10] Heterogenous memory node attributes
To: Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org,
 linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
 Dan Williams <dan.j.williams@intel.com>
References: <20190214171017.9362-1-keith.busch@intel.com>
From: Brice Goglin <Brice.Goglin@inria.fr>
Openpgp: preference=signencrypt
Autocrypt: addr=Brice.Goglin@inria.fr; prefer-encrypt=mutual; keydata=
 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
Message-ID: <f2add663-a9e1-86df-0afd-22ef03d3d943@inria.fr>
Date: Mon, 18 Feb 2019 15:25:31 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190214171017.9362-1-keith.busch@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Le 14/02/2019 à 18:10, Keith Busch a écrit :
> == Changes since v5 ==
>
>   Updated HMAT parsing to account for the recently released ACPI 6.3
>   changes.
>
>   HMAT attribute calculation overflow checks.
>
>   Fixed memory leak if HMAT parse fails.
>
>   Minor change to the patch order. All the base node attributes occur
>   before HMAT usage for these new node attributes to resolve a
>   dependency on a new struct.
>
>   Reporting failures to parse HMAT or allocate structures are elevated
>   to a NOTICE level from DEBUG. Any failure will result in just one
>   print so that it is obvious something may need to be investigated
>   rather than silently fail, but also not to be too alarming either.
>
>   Determining the cpu and memory node local relationships is quite
>   different this time (PATCH 7/10). The local relationship to a memory
>   target will be either *only* the node from the Initiator Proximity
>   Domain if provided, or if it is not provided, all the nodes that have
>   the same highest performance. Latency was chosen to take prioirty over
>   bandwidth when ranking performance.


Hello Keith

I am trying to understand what this last paragraph means.

Let's say I have a machine with DDR and NVDIMM both attached to the same
socket, and I use Dave Hansen's kmem patchs to make the NVDIMM appear as
"normal memory" in an additional NUMA node. Let's call node0 the DDR and
node1 the NVDIMM kmem node.

Now user-space wants to find out which CPUs are actually close to the
NVDIMMs. My understanding is that SRAT says that CPUs are local to the
DDR only. Hence /sys/devices/system/node/node1/cpumap says there are no
CPU local to the NVDIMM. And HMAT won't change this, right?

Will node1 contain access0/initiators/node0 to clarify that CPUs local
to the NVDIMM are those of node0? Even if latency from node0 to node1
latency is higher than node0 to node0?

Another way to ask this: Is the latency/performance only used for
distinguishing the local initiator CPUs among multiple CPU nodes
accesing the same memory node? Or is it also used to distinguish the
local memory target among multiple memories access by a single CPU node?

The Intel machine I am currently testing patches on doesn't have a HMAT
in 1-level-memory unfortunately.

Thanks

Brice


