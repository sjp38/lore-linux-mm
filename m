Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 904ACC10F0C
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 08:32:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DCB620674
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 08:32:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DCB620674
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E24C26B0007; Thu,  4 Apr 2019 04:32:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAE2F6B0008; Thu,  4 Apr 2019 04:32:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C74D46B000A; Thu,  4 Apr 2019 04:32:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 75B696B0007
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 04:32:22 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id j3so981725edb.14
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 01:32:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=hg06P5bXTSweUvOus1HTTIHK8f9/CRd7rl0Mi8Q3BHM=;
        b=YR+cIC+JB/6q0E0KpiFYklzf5pTjLZKdGZ6Xww+/mlGOLgpq05EqVNk2OrOFCCbdW2
         NQh+/YhSMPIKJccKaQE7bWVRYIM6B8IqtMzyIrNuvvXV1gOT2bok/Rq7HlZsTlbI4yUc
         1uhKRz8oSiF/GzoactROhRPz2r+mVQFRqOJU74UPAA95WKmvbbJRDFMXR3magDnMaBgh
         hq7aZfizybdoHBX5TgATagpWHmK+nY9nErIFU0m/5vd0JoN0cm9tT8p2PmCFgUDMnDoR
         7oh+f7XMKm5O7bFFUFZT9iX+vRx0ir6R4dT+JbmE+8JDRxJ7s8TWHkjOLx/3NatL+bjQ
         KVNw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUVnt01A2TEBZs12ZPNab4O/+8DZNw1Qo2X1Mpsi1oIwWF3X87+
	sCwGB6cdecOrdth3sOixzU5P3emkpjDYa8kVht/4Y53veHuNRbF4oYlhLl6WiDkUv6fqQeKoeU2
	hCvf+7LnsO6XPg6ZS0Z7lzcHfbn9r4i//eStNKwADu3IlUOZDGNb8bnsgOyM8Oi7E9Q==
X-Received: by 2002:aa7:c0c7:: with SMTP id j7mr2969951edp.38.1554366742019;
        Thu, 04 Apr 2019 01:32:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYHGidusthvMJyOVglccTCSKsYeoi1RHb1n1m/zqMP8Y5B1OpeFFhdvbqgUfY4I8p1wQuU
X-Received: by 2002:aa7:c0c7:: with SMTP id j7mr2969896edp.38.1554366741129;
        Thu, 04 Apr 2019 01:32:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554366741; cv=none;
        d=google.com; s=arc-20160816;
        b=oWDWp4W+YuV+zhcZSf6DRlN0QkSTljgun/6N3TC8OJlxSJff9iFHIENFBsDrvVsk1+
         fJhCp9TBQZugJl8pdVB8Vs828kDuZ2F7+oHIjUKdGY1+CfaZX9wgjYKsqg8ezqpA4/lq
         bs0yr3lxwM5a9ij305pB7mHuD9u91cXFfZ2YC0PLWWdm1yVnGn1AGdA32gFo9H3+WlSH
         bF6PxcsWkLPM35HuiCC05ET1V/RaUA+r7Uw0HA1qXPFhFV/4n7QsVSAnd3iFfBgqxT31
         PE4qea/JMiT39dXjXBsdkJu12vWBkR3fhp2f8jSOEy1bWguK1f2KnYpY18uf6O5sr8OA
         a2xA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=hg06P5bXTSweUvOus1HTTIHK8f9/CRd7rl0Mi8Q3BHM=;
        b=OkfKYRy5z0I47gFhQ2BhsyUJbxm95T3k7g4Za3BjX1i1+2Fr5aVduZn8iO6VzC8JrY
         RTGhKvkHCIr/eENlY8kSvT4e62cQTLNPoL/eu408xrTQMLsuk4+/m7RZ47YKsn6cibIy
         k6UX7irb8dAc/o38lWiwKsqFHakxeytQpjaLEPqkT3H4e2ZL5Ml4W3zfW5fpHU7jvscj
         WSg2ExrGrZdCpI/rD4xP7gVKNwffxr3WIEsY6Q0UanwqdthGKH+AqIpuB1jgTnoIyTvG
         oj49hRBHldc83JXE/AJO0q+uBKnq8KdELdEIqMHKen0tcu0JUOK9scKlmuLhp8OFu4ms
         nR8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k3si3168865edd.275.2019.04.04.01.32.20
        for <linux-mm@kvack.org>;
        Thu, 04 Apr 2019 01:32:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E526280D;
	Thu,  4 Apr 2019 01:32:19 -0700 (PDT)
Received: from [10.162.40.100] (p8cg001049571a15.blr.arm.com [10.162.40.100])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3C9293F557;
	Thu,  4 Apr 2019 01:32:12 -0700 (PDT)
Subject: Re: [PATCH 4/6] mm/hotplug: Reorder arch_remove_memory() call in
 __remove_memory()
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
 catalin.marinas@arm.com, mgorman@techsingularity.net, james.morse@arm.com,
 mark.rutland@arm.com, robin.murphy@arm.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com, osalvador@suse.de,
 logang@deltatee.com, pasha.tatashin@oracle.com, david@redhat.com, cai@lca.pw
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-5-git-send-email-anshuman.khandual@arm.com>
 <20190403091755.GG15605@dhcp22.suse.cz>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <5211234d-0bee-f415-2873-2280e944d95d@arm.com>
Date: Thu, 4 Apr 2019 14:02:14 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190403091755.GG15605@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/03/2019 02:47 PM, Michal Hocko wrote:
> On Wed 03-04-19 10:00:04, Anshuman Khandual wrote:
>> Memory hot remove uses get_nid_for_pfn() while tearing down linked sysfs
>> entries between memory block and node. It first checks pfn validity with
>> pfn_valid_within() before fetching nid. With CONFIG_HOLES_IN_ZONE config
>> (arm64 has this enabled) pfn_valid_within() calls pfn_valid().
>>
>> pfn_valid() is an arch implementation on arm64 (CONFIG_HAVE_ARCH_PFN_VALID)
>> which scans all mapped memblock regions with memblock_is_map_memory(). This
>> creates a problem in memory hot remove path which has already removed given
>> memory range from memory block with memblock_[remove|free] before arriving
>> at unregister_mem_sect_under_nodes(). Hence get_nid_for_pfn() returns -1
>> skipping subsequent sysfs_remove_link() calls leaving node <-> memory block
>> sysfs entries as is. Subsequent memory add operation hits BUG_ON() because
>> of existing sysfs entries.
>>
>> [   62.007176] NUMA: Unknown node for memory at 0x680000000, assuming node 0
>> [   62.052517] ------------[ cut here ]------------
>> [   62.053211] kernel BUG at mm/memory_hotplug.c:1143!
>> [   62.053868] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
>> [   62.054589] Modules linked in:
>> [   62.054999] CPU: 19 PID: 3275 Comm: bash Not tainted 5.1.0-rc2-00004-g28cea40b2683 #41
>> [   62.056274] Hardware name: linux,dummy-virt (DT)
>> [   62.057166] pstate: 40400005 (nZcv daif +PAN -UAO)
>> [   62.058083] pc : add_memory_resource+0x1cc/0x1d8
>> [   62.058961] lr : add_memory_resource+0x10c/0x1d8
>> [   62.059842] sp : ffff0000168b3ce0
>> [   62.060477] x29: ffff0000168b3ce0 x28: ffff8005db546c00
>> [   62.061501] x27: 0000000000000000 x26: 0000000000000000
>> [   62.062509] x25: ffff0000111ef000 x24: ffff0000111ef5d0
>> [   62.063520] x23: 0000000000000000 x22: 00000006bfffffff
>> [   62.064540] x21: 00000000ffffffef x20: 00000000006c0000
>> [   62.065558] x19: 0000000000680000 x18: 0000000000000024
>> [   62.066566] x17: 0000000000000000 x16: 0000000000000000
>> [   62.067579] x15: ffffffffffffffff x14: ffff8005e412e890
>> [   62.068588] x13: ffff8005d6b105d8 x12: 0000000000000000
>> [   62.069610] x11: ffff8005d6b10490 x10: 0000000000000040
>> [   62.070615] x9 : ffff8005e412e898 x8 : ffff8005e412e890
>> [   62.071631] x7 : ffff8005d6b105d8 x6 : ffff8005db546c00
>> [   62.072640] x5 : 0000000000000001 x4 : 0000000000000002
>> [   62.073654] x3 : ffff8005d7049480 x2 : 0000000000000002
>> [   62.074666] x1 : 0000000000000003 x0 : 00000000ffffffef
>> [   62.075685] Process bash (pid: 3275, stack limit = 0x00000000d754280f)
>> [   62.076930] Call trace:
>> [   62.077411]  add_memory_resource+0x1cc/0x1d8
>> [   62.078227]  __add_memory+0x70/0xa8
>> [   62.078901]  probe_store+0xa4/0xc8
>> [   62.079561]  dev_attr_store+0x18/0x28
>> [   62.080270]  sysfs_kf_write+0x40/0x58
>> [   62.080992]  kernfs_fop_write+0xcc/0x1d8
>> [   62.081744]  __vfs_write+0x18/0x40
>> [   62.082400]  vfs_write+0xa4/0x1b0
>> [   62.083037]  ksys_write+0x5c/0xc0
>> [   62.083681]  __arm64_sys_write+0x18/0x20
>> [   62.084432]  el0_svc_handler+0x88/0x100
>> [   62.085177]  el0_svc+0x8/0xc
>>
>> Re-ordering arch_remove_memory() with memblock_[free|remove] solves the
>> problem on arm64 as pfn_valid() behaves correctly and returns positive
>> as memblock for the address range still exists. arch_remove_memory()
>> removes applicable memory sections from zone with __remove_pages() and
>> tears down kernel linear mapping. Removing memblock regions afterwards
>> is consistent.
> 
> consistent with what? Anyway, I believe you wanted to mention that this
> is safe because there is no other memblock (bootmem) allocator user that

Yes I did intend but did not express that very well here.

> late. So nobody is going to allocate from the removed range just to blow
> up later. Also nobody should be using the bootmem allocated range else
> we wouldn't allow to remove it. So reordering is indeed safe.

Looks better.

>  
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> 
> With a changelog updated to explain why this is safe

Sure will change it. Thanks for the commit message suggestion.

