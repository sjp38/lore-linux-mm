Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A922C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 06:19:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE77E218E2
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 06:19:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE77E218E2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91D5F6B0003; Fri, 22 Mar 2019 02:19:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CD9D6B0006; Fri, 22 Mar 2019 02:19:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BDAC6B0007; Fri, 22 Mar 2019 02:19:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D11A6B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 02:19:40 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m31so512459edm.4
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 23:19:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=nzUayCiHTng5ZPSnBKJwG7fEt0eCkrquiFs8YB9Jh34=;
        b=P8b3ibvUKczZP6k//o4LY7jjABMcqoefBx1NOOMeLMVdJ0BG0iAgZWluuUSiUUUCsR
         ty/ezWKsvmKPruMEoP8fZXa7YyL0v72BaMZgBx//P3RBlDtRKM50II2MG+0eDrSr8VrS
         wRe+sH0ltiidOTXUDQpKSjt5i4WuHRWvRp23TKptqToaej+g4la2qmDKNUQfCS0QFYv3
         R9QQBgAc/3ARk6aTUmEO4fCXW0NIN4oHf/enjvCnNOAVGujMKwZBQ1bT7SfvRLey+kbs
         ShYsWSDMLb06ZWtujKyKk9Atm2HgpXYPqRYio9PZ6O/7xuhFzpePB0/38l4QCF5Pga3D
         ASpg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVNvkIwfyUCqlpNzDF0PGYFOI+pFlQDCrk5OI5aRY0f0rsAH341
	V0yASdAIvNSu+DxtFlXwh3SqZLsFACaSZ8wUkh2TYne+h/AOMjJZ7YjpPKHupETpS6DzvEsXKZ7
	oAfEH1tQFqHCnlo+arVB11mCXFmQHYytj58G6WTrcqqjXF5xerZsf8q6FkJQyF4lh/w==
X-Received: by 2002:a50:93a6:: with SMTP id o35mr5028594eda.245.1553235579646;
        Thu, 21 Mar 2019 23:19:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTI3qqRtnWHbrW7QhfvsJ2oOzHp5PdDmnnwdz4wha33XTG64eUf+oi2Vf0LwWcKkCeaaaB
X-Received: by 2002:a50:93a6:: with SMTP id o35mr5028544eda.245.1553235578623;
        Thu, 21 Mar 2019 23:19:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553235578; cv=none;
        d=google.com; s=arc-20160816;
        b=0/c++QOZHaY4MzKPZiWTXgnjr7imG5wamCNfKQTgK8Iqn4remaui5dZx6I13L5+Ye4
         YeLBwL//1tZfi3kvHLxwfCVhgtH8NEFCucNxtiU6zGDH2tdl16Qit6/wrZI73rijtZU6
         9EL8qLP4kBxSfsaLFQiy1CucxQUpq/EJ0JU6DVTA7bxr6ZdieysW5JF9vETgoCcShOIi
         bVJn29nmYRH3JMD9Lra53tS+bpA+WNZKVrLYXz6v/lXaEm6kOeVfBdsMIT15BtJOhqWZ
         1gS6hd5ye/40vBGxFyE6Yaff+oL9xH9/yG3itdO9MsgGtD1XQ6D9O4OeK1lr5vTHIz+L
         s21w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=nzUayCiHTng5ZPSnBKJwG7fEt0eCkrquiFs8YB9Jh34=;
        b=hp5cEUfSNE5H0dNEKOQfK9YUddNPWzHCi1aA7EqIeDLuK58TZze0qQATKSmhDth1I1
         GHAr4F95SQFQBWz8xzfZ6DYnX72Dp9jB2xyX9M6139lIWV2gdXatpSv5IE1ODtph0e4G
         oaejTx2FvrN7jaJD6NxO/W8C7GshNSlPKUIfSVrIciXusxSTJ3rkmfXtLSqieG9Xvz6X
         QuyyKLBvLww01PJWv1ryhbUeW4qFcNzhYy9RQaKT4l1boGFQ2VN+f0CypHZL1f8MdcWg
         iifwctRZ2I128XTJTch93NUQU+G1HcHohvlA6oJylNzmBKOLE+S3YxDvpIT9RVw13ytJ
         spFg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i14si277897ejy.50.2019.03.21.23.19.38
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 23:19:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 40000374;
	Thu, 21 Mar 2019 23:19:37 -0700 (PDT)
Received: from [10.162.42.161] (p8cg001049571a15.blr.arm.com [10.162.42.161])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B01F93F59C;
	Thu, 21 Mar 2019 23:19:33 -0700 (PDT)
Subject: Re: [RFC] mm/hotplug: Make get_nid_for_pfn() work with
 HAVE_ARCH_PFN_VALID
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, logang@deltatee.com,
 osalvador@suse.de, hannes@cmpxchg.org, akpm@linux-foundation.org,
 richard.weiyang@gmail.com, rientjes@google.com, zi.yan@cs.rutgers.edu
References: <1553155700-3414-1-git-send-email-anshuman.khandual@arm.com>
 <20190321083639.GJ8696@dhcp22.suse.cz>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <621cc94c-210d-6fd4-a2e1-b7cfce733cf3@arm.com>
Date: Fri, 22 Mar 2019 11:49:30 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190321083639.GJ8696@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 03/21/2019 02:06 PM, Michal Hocko wrote:
> On Thu 21-03-19 13:38:20, Anshuman Khandual wrote:
>> Memory hot remove uses get_nid_for_pfn() while tearing down linked sysfs
>> entries between memory block and node. It first checks pfn validity with
>> pfn_valid_within() before fetching nid. With CONFIG_HOLES_IN_ZONE config
>> (arm64 has this enabled) pfn_valid_within() calls pfn_valid().
>>
>> pfn_valid() is an arch implementation on arm64 (CONFIG_HAVE_ARCH_PFN_VALID)
>> which scans all mapped memblock regions with memblock_is_map_memory(). This
>> creates a problem in memory hot remove path which has already removed given
>> memory range from memory block with memblock_[remove|free] before arriving
>> at unregister_mem_sect_under_nodes().
> 
> Could you be more specific on what is the actual problem please? It
> would be also helpful to mention when is the memblock[remove|free]
> called actually.

The problem is in unregister_mem_sect_under_nodes() as it skips calling into both
instances of sysfs_remove_link() which removes node-memory block sysfs symlinks.
The node enumeration of the memory block still remains in sysfs even if the memory
block itself has been removed.

This happens because get_nid_for_pfn() returns -1 for a given pfn even if it has
a valid associated struct page to fetch the node ID from.

On arm64 (with CONFIG_HOLES_IN_ZONE)

get_nid_for_pfn() -> pfn_valid_within() -> pfn_valid -> memblock_is_map_memory()

At this point memblock for the range has been removed.

__remove_memory()
	memblock_free()
	memblock_remove()	--------> memblock has already been removed
	arch_remove_memory()
		__remove_pages()
			__remove_section()
				unregister_memory_section()
 					remove_memory_section()
						unregister_mem_sect_under_nodes()

There is a dependency on memblock (after it has been removed) through pfn_valid().
  			
> 
>> During runtime memory hot remove get_nid_for_pfn() needs to validate that
>> given pfn has a struct page mapping so that it can fetch required nid. This
>> can be achieved just by looking into it's section mapping information. This
>> adds a new helper pfn_section_valid() for this purpose. Its same as generic
>> pfn_valid().
> 
> I have to say I do not like this. Having pfn_section_valid != pfn_valid_within
> is just confusing as hell. pfn_valid_within should return true whenever
> a struct page exists and it is sensible (same like pfn_valid). So it
> seems that this is something to be solved on that arch specific side of
> pfn_valid.

At present arm64's pfn_valid() implementation validates the pfn inside sparse
memory section mapping as well memblock. The memblock search excludes memory
with MEMBLOCK_NOMAP attribute. But in this particular instance during hotplug
only section mapping validation for the pfn is good enough.

IIUC the current arm64 pfn_valid() already extends the definition beyond the
availability of a valid struct page to operate on.

