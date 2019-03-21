Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98829C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 05:33:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64552218B0
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 05:33:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64552218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F26306B0003; Thu, 21 Mar 2019 01:33:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED5626B0006; Thu, 21 Mar 2019 01:33:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC3CB6B0007; Thu, 21 Mar 2019 01:33:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A32FA6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 01:33:27 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h27so1758871eda.8
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 22:33:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=HM1IuHNwQPwl3iqKHLvBwfnR/vWdK6wyJec2I42cGOY=;
        b=mqusRy+gWb+/QEjOcGCl10XjchYdlPYA45ZHPibJeJKgauvKwyA4ZzmldLI9NJhHms
         Nx/9RnQHeuqMv8fUy9ZSfzfoLLB4+hfdob+rC6CimY821NpWJiet4/MsWNCSSpW5sBE9
         GTEP5FwKjwnY/Rc7c+UdsNu4uVCJHqrIT5lqmV8516yetmftGHXjhHERoj0hL2Lzd1G1
         sG1+X5Ne4RaV2VJ2x9SirLtbDWNRY0C6Y5ZWdQsw1od+UIYSuRtczg2HYbWmxHy7mXLM
         eg2sB952JOhottyEOk0NtGHst/ulg96WzEH8DU+VsMB5apfZA5xKuZoMp1APzXUeokKI
         oWow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXof9WozbzIjWKSws/6ODjkSmjYNFELtBLNlyvNPlGNbrayk8At
	VvWr0Mc6cqPvqzgL+cNtAG6PrKDf75uaK+cfd0gD+JWEFnRlBcmrjOKqsDjxiEQB/63vHB/mJaA
	XXgn39luqRyK3BLGlFx8g/csz8sV3zBYbA86DRUDC2ypnhkKLwrVKxdey2miT8CmLHg==
X-Received: by 2002:a17:906:22c9:: with SMTP id q9mr1145193eja.137.1553146407244;
        Wed, 20 Mar 2019 22:33:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSLr3hWBpHp6fSGd+vw9gthE5wQeWislJbk9T9LKyFIgRj4BO6CfitzI1AZQVCOuRdQJSc
X-Received: by 2002:a17:906:22c9:: with SMTP id q9mr1145112eja.137.1553146405196;
        Wed, 20 Mar 2019 22:33:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553146405; cv=none;
        d=google.com; s=arc-20160816;
        b=Ps20aPvEukzYpd0P8QUao85xNFQqkvDY2xPcDl4aEm+2Xn10hpcbtPcb5rpiSRMGEd
         PdsddvTWF27iQlD9GI1rRnmcK0DFcOUfA89mO3JnBwOeG6zTxLdLFieFRkKJkhvTb5so
         bdSM4bRNV7t/0anrd21eGGceBuEdeAUpYFYprLTIscW/0fQ5YspgUPEj0d5z4nvVBDoA
         RG1YaArsFtCTtZwHuXuoQZl4LFvf9ogZV8dd6I7HgYQXDKgQNwm4EzwCVZbgPo2iVTx0
         3KIoK8Mihb1MeogCRGEQ18cJcn1dwNYLfAOgIWmXNGlfxDoRV8jqgO+0dnD4iPVZkRe2
         xtWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=HM1IuHNwQPwl3iqKHLvBwfnR/vWdK6wyJec2I42cGOY=;
        b=0Rm07Dus23f9Ctu4wSOV3M8VsFfxfmTl43IaNqi9MzE4Ci9SQq2Q8jQrTF4Jg21TQG
         CM9qn+k2NEXrMHIpPjiByzx5Mv2biv2h1KUGGQQA5VPbdxhqJxy8BjOSGr4FNodHx/aW
         QLmrPMuQS23/LEeLzj+BqU6YxUBfmbCmwIHLJJE5t4/DwofC44unThDoL9t3w/6Br5zZ
         Fe294Qz1uX7wOQnDLLedVUkOnjiogBIoLLf2ExScCO3lgyeul3IZ9EIb2TH50tSI45JR
         UQVsub4SUtV7kcaQTlTtcMOleEgeIVxcTq2qgoZvDhZpnYHDbuy7YUgqCbpAgIzbLr6f
         gjNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p4si184447ejb.153.2019.03.20.22.33.24
        for <linux-mm@kvack.org>;
        Wed, 20 Mar 2019 22:33:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id ECE44A78;
	Wed, 20 Mar 2019 22:33:23 -0700 (PDT)
Received: from [10.162.42.102] (p8cg001049571a15.blr.arm.com [10.162.42.102])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 89A143F71A;
	Wed, 20 Mar 2019 22:33:21 -0700 (PDT)
Subject: Re: [PATCH] mm/isolation: Remove redundant pfn_valid_within() in
 __first_valid_page()
To: Zi Yan <ziy@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 mike.kravetz@oracle.com, osalvador@suse.de, mhocko@suse.com,
 akpm@linux-foundation.org
References: <1553141595-26907-1-git-send-email-anshuman.khandual@arm.com>
 <8AB57711-48C0-4D95-BC5F-26B266DC3AE8@nvidia.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <cda4f247-4eea-decf-3f4a-3dc09364de27@arm.com>
Date: Thu, 21 Mar 2019 11:03:18 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <8AB57711-48C0-4D95-BC5F-26B266DC3AE8@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 03/21/2019 10:31 AM, Zi Yan wrote:
> On 20 Mar 2019, at 21:13, Anshuman Khandual wrote:
> 
>> pfn_valid_within() calls pfn_valid() when CONFIG_HOLES_IN_ZONE making it
>> redundant for both definitions (w/wo CONFIG_MEMORY_HOTPLUG) of the helper
>> pfn_to_online_page() which either calls pfn_valid() or pfn_valid_within().
>> pfn_valid_within() being 1 when !CONFIG_HOLES_IN_ZONE is irrelevant either
>> way. This does not change functionality.
>>
>> Fixes: 2ce13640b3f4 ("mm: __first_valid_page skip over offline pages")
> 
> I would not say this patch fixes the commit 2ce13640b3f4 from 2017,
> because the pfn_valid_within() in pfn_to_online_page() was introduced by
> a recent commit b13bc35193d9e last month. :)

Right, will update the tag with this commit.

