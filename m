Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F5EEC5ACAE
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 10:31:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1273D222C1
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 10:31:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1273D222C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DE5D6B0005; Wed, 11 Sep 2019 06:31:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9901C6B0006; Wed, 11 Sep 2019 06:31:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 87C836B0007; Wed, 11 Sep 2019 06:31:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0199.hostedemail.com [216.40.44.199])
	by kanga.kvack.org (Postfix) with ESMTP id 61C1E6B0005
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 06:31:55 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 0B85183FA
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 10:31:55 +0000 (UTC)
X-FDA: 75922274190.01.curve41_8511431f19819
X-HE-Tag: curve41_8511431f19819
X-Filterd-Recvd-Size: 7784
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 10:31:54 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6664518C429A;
	Wed, 11 Sep 2019 10:31:53 +0000 (UTC)
Received: from [10.36.117.155] (ovpn-117-155.ams2.redhat.com [10.36.117.155])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BA1F25D6A5;
	Wed, 11 Sep 2019 10:31:48 +0000 (UTC)
Subject: Re: [PATCH V7 3/3] arm64/mm: Enable memory hot remove
To: Catalin Marinas <catalin.marinas@arm.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
 will@kernel.org, mark.rutland@arm.com, mhocko@suse.com, ira.weiny@intel.com,
 cai@lca.pw, logang@deltatee.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com,
 mgorman@techsingularity.net, osalvador@suse.de, ard.biesheuvel@arm.com,
 steve.capper@arm.com, broonie@kernel.org, valentin.schneider@arm.com,
 Robin.Murphy@arm.com, steven.price@arm.com, suzuki.poulose@arm.com
References: <1567503958-25831-1-git-send-email-anshuman.khandual@arm.com>
 <1567503958-25831-4-git-send-email-anshuman.khandual@arm.com>
 <20190910161759.GI14442@C02TF0J2HF1T.local>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <eede2498-b2fa-9905-9020-31337045b00d@redhat.com>
Date: Wed, 11 Sep 2019 12:31:47 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190910161759.GI14442@C02TF0J2HF1T.local>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.62]); Wed, 11 Sep 2019 10:31:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 10.09.19 18:17, Catalin Marinas wrote:
> On Tue, Sep 03, 2019 at 03:15:58PM +0530, Anshuman Khandual wrote:
>> @@ -770,6 +1022,28 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
>>  void vmemmap_free(unsigned long start, unsigned long end,
>>  		struct vmem_altmap *altmap)
>>  {
>> +#ifdef CONFIG_MEMORY_HOTPLUG
>> +	/*
>> +	 * FIXME: We should have called remove_pagetable(start, end, true).
>> +	 * vmemmap and vmalloc virtual range might share intermediate kernel
>> +	 * page table entries. Removing vmemmap range page table pages here
>> +	 * can potentially conflict with a concurrent vmalloc() allocation.
>> +	 *
>> +	 * This is primarily because vmalloc() does not take init_mm ptl for
>> +	 * the entire page table walk and it's modification. Instead it just
>> +	 * takes the lock while allocating and installing page table pages
>> +	 * via [p4d|pud|pmd|pte]_alloc(). A concurrently vanishing page table
>> +	 * entry via memory hot remove can cause vmalloc() kernel page table
>> +	 * walk pointers to be invalid on the fly which can cause corruption
>> +	 * or worst, a crash.
>> +	 *
>> +	 * So free_empty_tables() gets called where vmalloc and vmemmap range
>> +	 * do not overlap at any intermediate level kernel page table entry.
>> +	 */
>> +	unmap_hotplug_range(start, end, true);
>> +	if (!vmalloc_vmemmap_overlap)
>> +		free_empty_tables(start, end);
>> +#endif
>>  }
>>  #endif	/* CONFIG_SPARSEMEM_VMEMMAP */
> 
> I wonder whether we could simply ignore the vmemmap freeing altogether,
> just leave it around and not unmap it. This way, we could call
> unmap_kernel_range() for removing the linear map and we save some code.
> 
> For the linear map, I think we use just above 2MB of tables for 1GB of
> memory mapped (worst case with 4KB pages we need 512 pte pages). For
> vmemmap we'd use slightly above 2MB for a 64GB hotplugged memory. Do we
> expect such memory to be re-plugged again in the same range? If we do,
> then I shouldn't even bother with removing the vmmemmap.
> 

FWIW, I think we should do it cleanly.

> I don't fully understand the use-case for memory hotremove, so any
> additional info would be useful to make a decision here.
> 

Especially in virtual environment, hotremove will be relevant. For
physical environments - I have no idea how important that is for ARM.

-- 

Thanks,

David / dhildenb

