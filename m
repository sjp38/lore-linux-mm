Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE4FFC282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 23:04:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78A7F21773
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 23:04:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78A7F21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC3366B0003; Tue, 16 Apr 2019 19:04:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D71C16B0006; Tue, 16 Apr 2019 19:04:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5FCC6B0007; Tue, 16 Apr 2019 19:04:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B96D6B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 19:04:25 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 18so13430768pgx.11
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 16:04:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=8FDCDkCjva7pNJDDrdpdNArdSohBZ7QwgiZQT5euQ+s=;
        b=ij5K7z3TPGl3ZzKs0umXEk4ZT4EZ5af2Po0roKnK01angRXOmUYFrG00puIY5pwYfe
         FVYEVYK/uaFjuXPA5LhX21ekd2WJNDs2ulvHRTSvU3551rfRTPrR6ssaEexyP32uIKo1
         oyhHxIPVdNIHUmo6FxzVmjLFj6jL2n1GwTOMPbU1EtKBCnpEpPsroTMuw7pBMuUeqOvv
         t0cpNRXZNAAoHuGeP/qViKrABwmpcQfExBRNg+d3dhLyfPLpuN9DroNJD+np/r2pGSiN
         kKEgqILAej+xC9sXf7CtjmeqdggbYg1Q1e7Sg4etEb/RXa+m/8xacBimwMzH8W8an66Z
         SgDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUbe9pMULYuOLU0xdGtU3g5pmC7iDvle8Lv47R3jNqztigEsO9u
	DRfjCUGMp4i8b9oX0B8ug1k60CvmVmoFFS/SrBy4rwKAK6DrUu6Kl/7rtgrNjweofYbHn47uwLr
	DJ88WuwG/QChxTmpqD2kUwbDVg1qU2QdwNymnQJGLMFdAUTFkkbxbE6FmZ0JuvNCWCw==
X-Received: by 2002:a62:1385:: with SMTP id 5mr85939427pft.221.1555455865193;
        Tue, 16 Apr 2019 16:04:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYQOds4ej7bHoG8Kh8vINHpyFEl1X5QOzdyrTmxiABpWrHrNlGtb3E2UzqbNyN1uuMw1O3
X-Received: by 2002:a62:1385:: with SMTP id 5mr85939331pft.221.1555455864107;
        Tue, 16 Apr 2019 16:04:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555455864; cv=none;
        d=google.com; s=arc-20160816;
        b=L+uwUQ7yy0nDj2/ofMlqrOc1/9MckhWrxrp9fY9Qj4dDfw29yRgJ4f0Z70zHrXLfbK
         uDZdBBpCphK9Uugv0XxIvKnDcTTe1seJaNZ5dXeNfd+JcPTv93fSGZeQkXQu+biaIfaW
         p6OQMW4ZJfJGT3eYp2KkQK3HrgSPmDgbQn04lo84sYO6j5sRUY2s5LvcIMpAfr0zqxrg
         J3zaI9iew5QvL6dQe4ZD11ztjyEfe7GFaFddcR3SGaeGd4sxP8MH9L+mn7MGMHiAQkNd
         KTRbcrEAyyFqRXPhsieRGMq9ZMsXp8dn2e4JzHjsd7k6SNKChLbOsd7A8IMKXBZWyxrQ
         LYZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=8FDCDkCjva7pNJDDrdpdNArdSohBZ7QwgiZQT5euQ+s=;
        b=e4vzmGByu1E1fO+O21k9hMmPoKsjKvSdeFYt55fLgADlZN5IbqIV2sFPC1ro8b+Lm0
         vxGgc71TN2nABSy9A25sRLTkQanwjN/E6hj9JORpwURy3hf2Onc3tyoukdMvOo2EQQ9T
         QQX9KXUa/FHlsZYKmAJMHvva0qiI4xHQn/ohxULSFgbDDXedyzZeckPUECGMOhKI8Fxm
         ut5vYZi9X0HJ3l6fpZVO1fziO/D3PVIKZS6iod1y+ai6PWYKo0mgSoJoaLRZnxJtjiOm
         hgcAfJAoClDgxvFm+HtaECTWc6hoXRXTEp+SsIX1SdNJ73VavXXtInyHXYAK8sLlINDu
         7DjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 7si46803458pgn.419.2019.04.16.16.04.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 16:04:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 16 Apr 2019 16:04:23 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,359,1549958400"; 
   d="scan'208";a="316569144"
Received: from ray.jf.intel.com (HELO [10.7.201.126]) ([10.7.201.126])
  by orsmga005.jf.intel.com with ESMTP; 16 Apr 2019 16:04:23 -0700
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
To: Yang Shi <yang.shi@linux.alibaba.com>, Michal Hocko <mhocko@kernel.org>
Cc: mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
 akpm@linux-foundation.org, keith.busch@intel.com, dan.j.williams@intel.com,
 fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
 ziy@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
 <a0bf6b61-1ec2-6209-5760-80c5f205d52e@intel.com>
 <99320338-d9d3-74ca-5b07-6c3ca718800f@linux.alibaba.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <1556283f-de69-ce65-abf8-22f6f8d7d358@intel.com>
Date: Tue, 16 Apr 2019 16:04:23 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <99320338-d9d3-74ca-5b07-6c3ca718800f@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/16/19 2:59 PM, Yang Shi wrote:
> On 4/16/19 2:22 PM, Dave Hansen wrote:
>> Keith Busch had a set of patches to let you specify the demotion order
>> via sysfs for fun.  The rules we came up with were:
>> 1. Pages keep no history of where they have been
>> 2. Each node can only demote to one other node
> 
> Does this mean any remote node? Or just DRAM to PMEM, but remote PMEM
> might be ok?

In Keith's code, I don't think we differentiated.  We let any node
demote to any other node you want, as long as it follows the cycle rule.

