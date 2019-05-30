Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6171C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 04:23:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8D832537E
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 04:23:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8D832537E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 535686B0270; Thu, 30 May 2019 00:23:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BF546B0271; Thu, 30 May 2019 00:23:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35FF96B0272; Thu, 30 May 2019 00:23:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D8B6E6B0270
	for <linux-mm@kvack.org>; Thu, 30 May 2019 00:23:39 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n52so6733457edd.2
        for <linux-mm@kvack.org>; Wed, 29 May 2019 21:23:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=w94dX3uateX8Jj+8Sn693d7xlVOHXWw5YQlAzlQoliU=;
        b=o9Sy90PMgqwx6uNzPJyAZfC/2/grhEl4zMWTJb8K8TH/Iao57f/m0ZqXqcGujLTBS8
         nUASAL5IW9Rt/5BD/GcwG5siAvBVZoxungnfk0CLR3OyjcGNhMtd9yZgzKTo9ky6do4g
         zg7ATpOWTMNhK4RLoJEkItL2+ekQ3KLHEQlQQo609JbpgRg/oOm3tDkI/yAAf1wZyfMI
         aeIaXmtmPCpcvoKedkgJ6XUwPoTcWSsJcQrH5dhkAR0bsvEDQkv2i2ZouOdzsKbDJ72v
         7vJxcYa97frp8z2jF3ftib2Au45dEwdGZmGXBJsoqNIh1CESdddFIUvAVQ0duNrQOhrh
         XYKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAW6HJf2zAETyuNTE1wVc4RQ+7fmwfKJ6D8+SlWtVELMuW0OfKWh
	zjcNDUKJZLacArnr0uGGvm1yLNY+jdNbA/ASV51lj60LETgU+YalieX4htdHSqbMgTyzAu+5ycl
	akcBYT5n+RI9qz2PU7+40vgY30Epgr7jRpcsmit7D0aKn4frts2Ye9ffGKsd8HIJfSg==
X-Received: by 2002:a17:906:5ad4:: with SMTP id x20mr1449012ejs.225.1559190219357;
        Wed, 29 May 2019 21:23:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwbOmbjkolnt3TDQvvvAWSM/Ews6CxUakcRkovXFKn3+DN4KjJRVN6VJnOMa2tpvJLxCrwd
X-Received: by 2002:a17:906:5ad4:: with SMTP id x20mr1448978ejs.225.1559190218358;
        Wed, 29 May 2019 21:23:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559190218; cv=none;
        d=google.com; s=arc-20160816;
        b=IjZOjNP08bG9lvuKC0j4aQoQcfr0YUhdqoGry4urSeVN4a3ny0Fpxdqchnjq1qooHf
         WP573z2qI/O6iMGyV+dNCd6KPKJwlyCZXEquCLUw8SSiupDg3a+efzizrAfFgC5yvkkK
         +0vII6qong1uO3Jd+yT/5MdRElQW3HV2eGlFRHS2EsO+cMEpiQy9v/9hYnp2pohZ1sx0
         oXJ/0f1nQnH0gThOnClCo/fW40DvBSCqkoAx5rqe06m9aURe+A/pZV5gXCjs13umTLLJ
         7+FU2zkC9fnI2rBPxn19QTYg0m4zVLOhUvJ7irwYP+VeWnuDcz+FSKJ+RppFjZSWjdv1
         Jl8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=w94dX3uateX8Jj+8Sn693d7xlVOHXWw5YQlAzlQoliU=;
        b=njY6/WUzbFHPNxjHLtqSxA23m+h4taOcu3qlLc5xrkWQx9wMe5rdsF40T7QMovltEd
         vSV0zhFAIK/Ln0g/zynY2VO8AM7qa3qPIC1ys6XtXWki+HE5/UAcXlnngD/V/uQ7IEoz
         MXyXFrM+ejSpeLuqsnVs6MaeH/UMmNFwpN5gyIk5D/++SKsDvivboTE4B/vDuokFp/8W
         Fa60C9cL7vwfA1n47yT+tuVcQIEMjayfI5qtjfSvHs849PljJ4gbCzmF2wtLuJ+c+BmA
         H9wrfGDJOvNoDeSo8FuwogRwLFAWbD2T7kRrDM63oWJBQeXW0lB1mNrR+R11lFAc0h9I
         LHQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t49si1078694edd.121.2019.05.29.21.23.37
        for <linux-mm@kvack.org>;
        Wed, 29 May 2019 21:23:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 105F1374;
	Wed, 29 May 2019 21:23:37 -0700 (PDT)
Received: from [10.162.40.143] (p8cg001049571a15.blr.arm.com [10.162.40.143])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id ED62B3F5AF;
	Wed, 29 May 2019 21:23:30 -0700 (PDT)
Subject: Re: [PATCH V5 0/3] arm64/mm: Enable memory hot remove
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com,
 will.deacon@arm.com, mark.rutland@arm.com, mhocko@suse.com,
 ira.weiny@intel.com, david@redhat.com, cai@lca.pw, logang@deltatee.com,
 james.morse@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
 dan.j.williams@intel.com, mgorman@techsingularity.net, osalvador@suse.de,
 ard.biesheuvel@arm.com
References: <1559121387-674-1-git-send-email-anshuman.khandual@arm.com>
 <20190529150611.fc27dee202b4fd1646210361@linux-foundation.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <c6e3af6e-27f4-ec3e-5ced-af4f62a9cdff@arm.com>
Date: Thu, 30 May 2019 09:53:43 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190529150611.fc27dee202b4fd1646210361@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/30/2019 03:36 AM, Andrew Morton wrote:
> On Wed, 29 May 2019 14:46:24 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:
> 
>> This series enables memory hot remove on arm64 after fixing a memblock
>> removal ordering problem in generic __remove_memory() and one possible
>> arm64 platform specific kernel page table race condition. This series
>> is based on latest v5.2-rc2 tag.
> 
> Unfortunately this series clashes syntactically and semantically with
> David Hildenbrand's series "mm/memory_hotplug: Factor out memory block
> devicehandling".  Could you and David please figure out what we should
> do here?
> 

Hello Andrew,

I was able to apply the above mentioned V3 series [1] from David with some changes
listed below which tests positively on arm64. These changes assume that the arm64
hot-remove series (current V5) gets applied first.

Changes to David's series

A) Please drop (https://patchwork.kernel.org/patch/10962565/) [v3,04/11]

	- arch_remove_memory() is already being added through hot-remove series

B) Rebase (https://patchwork.kernel.org/patch/10962575/) [v3, 06/11]

	- arm64 hot-remove series adds CONFIG_MEMORY_HOTREMOVE wrapper around
	  arch_remove_memory() which can be dropped in the rebased patch

C) Rebase (https://patchwork.kernel.org/patch/10962589/) [v3, 09/11]

	- hot-remove series moves arch_remove_memory() before memblock_[free|remove]()
	- So remove_memory_block_devices() should be moved before arch_remove_memory()
	  in it's new position

David,

Please do let me know if the plan sounds good or you have some other suggestions.

- Anshuman

[1] https://patchwork.kernel.org/project/linux-mm/list/?series=123133 

