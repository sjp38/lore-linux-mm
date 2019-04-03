Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA9D1C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:33:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68F9C206DF
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:33:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68F9C206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04D976B0008; Wed,  3 Apr 2019 13:33:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3EBC6B000E; Wed,  3 Apr 2019 13:33:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2CF96B0010; Wed,  3 Apr 2019 13:33:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id BCE256B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:33:24 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id 186so14310587iox.15
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:33:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=C61leQheCCANdK0fQ8NQE9eg8Q22YSKfu9jKcW4wZrA=;
        b=HDlFIWZXIOCI6lCLHicF+BK0r8Z/McQ2GW/EYATlJdBMce0ojVepvti24nWKuVteFH
         coDScw5vCYSr2672HTofxM0vQGQsHSJjwjj/yRStqCkVBSS69jdKuQ4o+BKXeh5VBQRp
         AZu4KKlSYpIsqrwglrLs7FC+DxY8mVeXcu16QeAOwzNNNFu3J+o6tEAivusLCQ66vnG/
         1hpeEdPFn6SpMxOTgMOT3hpzfeV1ZDqDTuBBqK6OPlCmtxZNPxasbpn/FnRChca+iX84
         X58++rqGQ8MvVpBY8qCrl985jaxbVpN5GmkfhYWmwkthKul38sJjKOj5PeJfpaDrxMcp
         uIKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: APjAAAUR7kVuOoFzwQP4t6tqNxa8OKLIVA6+uRbVa9GyhJ3Z+yWgpu5u
	5U5glbZW/RiW1gBa31PixSyyngwnrQzWMLr80VOn1UMaGYCAk7BDYx89HLVQyKMox/Fw5HdfMU1
	hKVk0ONLk5i5bzNKsqtYWMqk3/6TxW3IdBoLoCvzLlfi6zP7fecCmxisJbNr4NFpl7Q==
X-Received: by 2002:a6b:4910:: with SMTP id u16mr990255iob.150.1554312804556;
        Wed, 03 Apr 2019 10:33:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwH1e8isq+RG7IuVGTqA4EBhWBhaWSxeVNpRl10zhjBRS8vw+BetMjWL2cAcdaEtveKASdl
X-Received: by 2002:a6b:4910:: with SMTP id u16mr990202iob.150.1554312803833;
        Wed, 03 Apr 2019 10:33:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554312803; cv=none;
        d=google.com; s=arc-20160816;
        b=Nb/NjJNAkuiuDhgyHMjw27yvk1ZklWcS9SJZKXs/jpwPPqE5W0ocgwEvtauShsd2pW
         +QTsDqLOxoUI6zD+iRkxbXwtzfZ8gHO+yTiSgH3hb6ohQ9arZtMPa1/Yb+h6E/7tjVsr
         /ZvlVSoCMiOJjt+46av7+nga9zdTZTJ4Ny3B0t3Qp9P0IK4kv845HMJTTt4f124Twifd
         GAnNxk2Rn+XAWPm2A3KVXljhJgnt6QcsL1Zyy5E3MvDCp+9ENrUTzraUrjEWAcqtnseC
         jLliO4bRQtZ1Zet0m5FUF8aY3paoL/u0vrBYn8Rt1ZSxEZkB0dDbIoy1wYiiW7HA88Ua
         MVJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=C61leQheCCANdK0fQ8NQE9eg8Q22YSKfu9jKcW4wZrA=;
        b=pu7C3v6LiqtkG8+9IQAkYx+P3+Zxya8JzG27sgAQGWHIG7zaLb37WK/EI3MYjcGhPc
         sMb3DvgmR9hi3cjy5R6KHGQvfF5iR218DmuE/mXKfzszUljPd1wsjceG+aG32yvLnAdP
         wJ7icVtg8RsK+CcTD5GzvmKYF91rgAMXnFSd1Kpi7duHdS/Mfh2dwqOs+o+VWK96Lqz8
         TTGPqMOc+uy6heqZydf/vTLB6BI6j0aqrAcWR812HZ1as1NWGCVhgA7rLNKcAdQN3Zh2
         R8DWqONkd0k+AreRccBcd1vttLa9txC4Pcb26j9glheeWXGL/6Om2PEh8vswmoRYhZeu
         vrdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id m2si8179253ioj.9.2019.04.03.10.33.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 10:33:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from s01061831bf6ec98c.cg.shawcable.net ([68.147.80.180] helo=[192.168.6.206])
	by ale.deltatee.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1hBjky-0003uq-Cx; Wed, 03 Apr 2019 11:33:01 -0600
To: Anshuman Khandual <anshuman.khandual@arm.com>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
 catalin.marinas@arm.com
Cc: mhocko@suse.com, mgorman@techsingularity.net, james.morse@arm.com,
 mark.rutland@arm.com, robin.murphy@arm.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com, osalvador@suse.de,
 pasha.tatashin@oracle.com, david@redhat.com, cai@lca.pw,
 Stephen Bates <sbates@raithlin.com>
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-3-git-send-email-anshuman.khandual@arm.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <f2ea761c-49b2-88f6-14fa-5aaec57952cb@deltatee.com>
Date: Wed, 3 Apr 2019 11:32:51 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1554265806-11501-3-git-send-email-anshuman.khandual@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 68.147.80.180
X-SA-Exim-Rcpt-To: sbates@raithlin.com, cai@lca.pw, david@redhat.com, pasha.tatashin@oracle.com, osalvador@suse.de, dan.j.williams@intel.com, arunks@codeaurora.org, cpandya@codeaurora.org, robin.murphy@arm.com, mark.rutland@arm.com, james.morse@arm.com, mgorman@techsingularity.net, mhocko@suse.com, catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, anshuman.khandual@arm.com
X-SA-Exim-Mail-From: logang@deltatee.com
Subject: Re: [PATCH 2/6] arm64/mm: Enable memory hot remove
X-SA-Exim-Version: 4.2.1 (built Tue, 02 Aug 2016 21:08:31 +0000)
X-SA-Exim-Scanned: Yes (on ale.deltatee.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019-04-02 10:30 p.m., Anshuman Khandual wrote:
> Memory removal from an arch perspective involves tearing down two different
> kernel based mappings i.e vmemmap and linear while releasing related page
> table pages allocated for the physical memory range to be removed.
> 
> Define a common kernel page table tear down helper remove_pagetable() which
> can be used to unmap given kernel virtual address range. In effect it can
> tear down both vmemap or kernel linear mappings. This new helper is called
> from both vmemamp_free() and ___remove_pgd_mapping() during memory removal.
> The argument 'direct' here identifies kernel linear mappings.
> 
> Vmemmap mappings page table pages are allocated through sparse mem helper
> functions like vmemmap_alloc_block() which does not cycle the pages through
> pgtable_page_ctor() constructs. Hence while removing it skips corresponding
> destructor construct pgtable_page_dtor().
> 
> While here update arch_add_mempory() to handle __add_pages() failures by
> just unmapping recently added kernel linear mapping. Now enable memory hot
> remove on arm64 platforms by default with ARCH_ENABLE_MEMORY_HOTREMOVE.
> 
> This implementation is overall inspired from kernel page table tear down
> procedure on X86 architecture.

I've been working on very similar things for RISC-V. In fact, I'm
currently in progress on a very similar stripped down version of
remove_pagetable(). (Though I'm fairly certain I've done a bunch of
stuff wrong.)

Would it be possible to move this work into common code that can be used
by all arches? Seems like, to start, we should be able to support both
arm64 and RISC-V... and maybe even x86 too.

I'd be happy to help integrate and test such functions in RISC-V.

Thanks,

Logan


