Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A0F5C282E3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:56:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7CDE208E4
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:56:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7CDE208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9965C6B000A; Thu, 25 Apr 2019 03:56:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 945666B000C; Thu, 25 Apr 2019 03:56:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 835606B000D; Thu, 25 Apr 2019 03:56:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3196B000A
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 03:56:03 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id gn10so14083329plb.23
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 00:56:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=TN7oRj4nRYIYKkEZRNBCFfFIzuSanM04afuxAr6OuWE=;
        b=jLB5/VwN5Eyk37waTsWI10mCghyxGgi7emxaETg2EtWp0DU84fsrWk8kE23fDSZMp/
         BZvM08OU4mdv9iLTxykR56c1hrqicKyFMF8qX93Tv7IKtiZrXPRyqLSwQuzQoIdubQaX
         bbANZW1lmoDy+0FCze3qrTfL5zQ+Q0ZaT/5H3DNrAJu6BBvMoqF8xJDF+jOiaXAYzPTQ
         X/T/tJzc9PqEINXgOLbHcv10k8jRXIkKFri4oXUCRHj3vZuM9R10DInl5D48qcHOkCoa
         tSvJptMZBZKQukmlz4U1YKpkJrj01rGFINf1caTJ/lKrlVoe/WjGmszQgwdIz8aP+s0/
         J4DA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWV+1b7lsj4HpHNkPkj5+XR9DRYzDfuC/JoyVzG0o820GKgJLNp
	/YcBMe7DVKb8VqnTBFz9ZUteclCC2jEV4Yl28/7CY6Rkr4gKvHgT3H8/cQE7xQtju0ZORAoWzIo
	08W/ow0+1tlpmbvO8pDKHITCmabgJonDAoR0B1yBIMqVQnWqUGOCTxhjUAB7IGkfJgA==
X-Received: by 2002:a17:902:b481:: with SMTP id y1mr37971354plr.161.1556178962890;
        Thu, 25 Apr 2019 00:56:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzj4mA+9fNJYd+v7NP94FheOn1UrR3ZCOoKxwvSpIrLy2qBPwDYMv56sqdbzrC6SUQ8S6xC
X-Received: by 2002:a17:902:b481:: with SMTP id y1mr37971297plr.161.1556178962176;
        Thu, 25 Apr 2019 00:56:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556178962; cv=none;
        d=google.com; s=arc-20160816;
        b=qfjumoBsaE/shzBKHXHCCxA3s0maZRa5bFR76CQEHfCcMVMJZYjt3Lg2hFyCQyW2+p
         5P5a5cS4DO+9wlpCkXMYcCyXGWgy0hiagUoQYzStzCJXRWRbMxseINO6MFzSzRhFTY/p
         uZjAznus9gDU0jjJQ7cPlKwezFrfiOuQT7vl1ThDJqWnGdDHxOqqLeqyUogTvW1Cs7k+
         U7OSWViT8JrT2LDfO2p+ckH/t9HHpwVO/SM7jvXnnMgHOzc/2GGN3aMEqJExFT68cmKI
         MvI7sS5XSh1IyvgZ/7eH2ki5VPQrCbdJz/+lMbHOMTLwPiUBm9ccv1NbJkbW9uv9TL18
         KKjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=TN7oRj4nRYIYKkEZRNBCFfFIzuSanM04afuxAr6OuWE=;
        b=zOIeeQsX20sWsHPsjyP27QTCxTS6RIx8yBXrOVcDxLMqxehWMwAFkQGHCx/79bPTcn
         YudS3hNnAXt7rnHwq6C8AlmoGMaoGD884sDxqFTx6e/EGp1puVH75kfgNUg8yJWRDNOB
         z1IG4H0TKC5fnJvF0S18GtEKJiUPCCsJFWIJfE1DMxUDWqEUiuyBP6PZNxD2erDqEDkp
         TLeSEeMNLCx1UaA5HQKNaRPhprROHaccZz89HhG2KJs8u3XFBGr1xrOWD6FwQZUq+xYk
         UMAfMaVDvaCTEhMk83xCohMJ51OK9xHbGj5H35YOjvSm0InSWB6X7XUv60hU6OJH/qVp
         ML+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id e24si15535989pge.459.2019.04.25.00.56.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 00:56:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Apr 2019 00:56:01 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,393,1549958400"; 
   d="scan'208";a="164917971"
Received: from fmsmsx106.amr.corp.intel.com ([10.18.124.204])
  by fmsmga004.fm.intel.com with ESMTP; 25 Apr 2019 00:56:01 -0700
Received: from fmsmsx153.amr.corp.intel.com (10.18.125.6) by
 FMSMSX106.amr.corp.intel.com (10.18.124.204) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 25 Apr 2019 00:56:01 -0700
Received: from shsmsx154.ccr.corp.intel.com (10.239.6.54) by
 FMSMSX153.amr.corp.intel.com (10.18.125.6) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 25 Apr 2019 00:56:01 -0700
Received: from shsmsx104.ccr.corp.intel.com ([169.254.5.92]) by
 SHSMSX154.ccr.corp.intel.com ([169.254.7.149]) with mapi id 14.03.0415.000;
 Thu, 25 Apr 2019 15:55:59 +0800
From: "Du, Fan" <fan.du@intel.com>
To: Michal Hocko <mhocko@kernel.org>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Wu, Fengguang"
	<fengguang.wu@intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>,
	"Hansen, Dave" <dave.hansen@intel.com>, "xishi.qiuxishi@alibaba-inc.com"
	<xishi.qiuxishi@alibaba-inc.com>, "Huang, Ying" <ying.huang@intel.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "Du, Fan" <fan.du@intel.com>
Subject: RE: [RFC PATCH 5/5] mm, page_alloc: Introduce
 ZONELIST_FALLBACK_SAME_TYPE fallback list
Thread-Topic: [RFC PATCH 5/5] mm, page_alloc: Introduce
 ZONELIST_FALLBACK_SAME_TYPE fallback list
Thread-Index: AQHU+wg4wWYFBheblUa8IPBSvnCJwqZL5rWAgACUV7D//39ggIAAhyuw
Date: Thu, 25 Apr 2019 07:55:58 +0000
Message-ID: <5A90DA2E42F8AE43BC4A093BF067884825785F50@SHSMSX104.ccr.corp.intel.com>
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
 <1556155295-77723-6-git-send-email-fan.du@intel.com>
 <20190425063807.GK12751@dhcp22.suse.cz>
 <5A90DA2E42F8AE43BC4A093BF067884825785F04@SHSMSX104.ccr.corp.intel.com>
 <20190425074841.GN12751@dhcp22.suse.cz>
In-Reply-To: <20190425074841.GN12751@dhcp22.suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiNGMzZGYyNWMtN2QxZi00Yjc4LTgzMzYtZjIzZWNhM2YyNzE0IiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoid1d2NmNCdTJDVUl5THJXMHROcGtHNlJROWlSY0RZc1NlYzJsMmRuckdSb2RFU0xkd2Ewam1TSGVLYXljazlWTSJ9
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.600.7
dlp-reaction: no-action
x-originating-ip: [10.239.127.40]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



>-----Original Message-----
>From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
>Behalf Of Michal Hocko
>Sent: Thursday, April 25, 2019 3:49 PM
>To: Du, Fan <fan.du@intel.com>
>Cc: akpm@linux-foundation.org; Wu, Fengguang <fengguang.wu@intel.com>;
>Williams, Dan J <dan.j.williams@intel.com>; Hansen, Dave
><dave.hansen@intel.com>; xishi.qiuxishi@alibaba-inc.com; Huang, Ying
><ying.huang@intel.com>; linux-mm@kvack.org; linux-kernel@vger.kernel.org
>Subject: Re: [RFC PATCH 5/5] mm, page_alloc: Introduce
>ZONELIST_FALLBACK_SAME_TYPE fallback list
>
>On Thu 25-04-19 07:43:09, Du, Fan wrote:
>>
>>
>> >-----Original Message-----
>> >From: Michal Hocko [mailto:mhocko@kernel.org]
>> >Sent: Thursday, April 25, 2019 2:38 PM
>> >To: Du, Fan <fan.du@intel.com>
>> >Cc: akpm@linux-foundation.org; Wu, Fengguang
><fengguang.wu@intel.com>;
>> >Williams, Dan J <dan.j.williams@intel.com>; Hansen, Dave
>> ><dave.hansen@intel.com>; xishi.qiuxishi@alibaba-inc.com; Huang, Ying
>> ><ying.huang@intel.com>; linux-mm@kvack.org;
>linux-kernel@vger.kernel.org
>> >Subject: Re: [RFC PATCH 5/5] mm, page_alloc: Introduce
>> >ZONELIST_FALLBACK_SAME_TYPE fallback list
>> >
>> >On Thu 25-04-19 09:21:35, Fan Du wrote:
>> >> On system with heterogeneous memory, reasonable fall back lists woul
>be:
>> >> a. No fall back, stick to current running node.
>> >> b. Fall back to other nodes of the same type or different type
>> >>    e.g. DRAM node 0 -> DRAM node 1 -> PMEM node 2 -> PMEM node
>3
>> >> c. Fall back to other nodes of the same type only.
>> >>    e.g. DRAM node 0 -> DRAM node 1
>> >>
>> >> a. is already in place, previous patch implement b. providing way to
>> >> satisfy memory request as best effort by default. And this patch of
>> >> writing build c. to fallback to the same node type when user specify
>> >> GFP_SAME_NODE_TYPE only.
>> >
>> >So an immediate question which should be answered by this changelog.
>Who
>> >is going to use the new gfp flag? Why cannot all allocations without an
>> >explicit numa policy fallback to all existing nodes?
>>
>> PMEM is good for frequently read accessed page, e.g. page cache(implicit
>page
>> request), or user space data base (explicit page request)
>> For now this patch create GFP_SAME_NODE_TYPE for such cases, additional
>> Implementation will be followed up.
>
>Then simply configure that NUMA node as movable and you get these
>allocations for any movable allocation. I am not really convinced a new
>gfp flag is really justified.

Case 1: frequently write and/or read accessed page deserved to DRAM
Case 2: frequently read accessed page deserved to PMEM

We need something like a new gfp flag to sort above two cases out
From each other.

>--
>Michal Hocko
>SUSE Labs

