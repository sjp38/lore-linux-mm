Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A9F9C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:53:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFE892075D
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:53:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFE892075D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46D7F8E0002; Wed, 13 Feb 2019 08:53:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41CE58E0001; Wed, 13 Feb 2019 08:53:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30BF98E0002; Wed, 13 Feb 2019 08:53:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF4138E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:53:24 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id m11so1061238edq.3
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:53:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=bOV8Wv1vRtPgqZoML7SL6Zwu6Kwh1cX89Ql2n1q9jDU=;
        b=OPoYig/ctoYOoar+6Wqt6IGVLdF7H4QAQiABshfLA8GX7osjC9oETBwMIGr2n3BcVD
         vKHOo+RU0dvy/j3kJy/ZIl4Ly4VvNqZaztPDHOwkEyGkkCtCu99u9WVrjvbKGMzcqByc
         bLg0/W7ekLUcemleZeryJajrl5nERWsBbsZ8vzsWZ8iVWKDU4Gb7ZqFhMVqnsnGsFm2I
         lP0h8/6mj/tWpaV+3A4xm/vNxHLu0QQxtt6BhNZ9+JAMcC+GgvdCmiulfBv1l0qq+51q
         7UVdCGjsMMDYACE3vNpnd5+uaIajgwq+7OhLQzgJHfktjIroHOmdbob+00R4q7j1t4m+
         eY8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAubVuY2wYAI+4nCi7sS4fcLWcl38VojhEyb19H2coysWWnIJxLgf
	uExFaBucnpKmex7FP6RBh/9Ltm/EdkbPqpqgSrE2YFDj6MEFm9w9W1WIskdJKGuGhG+5q/Fyesv
	n5MZQTF5kWu2vygOPr5T4n/OAQzizETgWqqbVNoax/X2ILhE8jctp0szyfmKSpm1xzA==
X-Received: by 2002:a50:9a01:: with SMTP id o1mr527336edb.82.1550066004383;
        Wed, 13 Feb 2019 05:53:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYH/sXEcSfA23+NYo2zLQ5IyxmK4mhIVzGa5vxPSCfMZrdMzP6OZS7XMv7fV+fQyo1BRh+I
X-Received: by 2002:a50:9a01:: with SMTP id o1mr527269edb.82.1550066003423;
        Wed, 13 Feb 2019 05:53:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550066003; cv=none;
        d=google.com; s=arc-20160816;
        b=QO9nMlipwzp0tRWa4PKiz4rV1DBCAbnocl4sJT7LLGAS9JqtOHGC1uU50sO0y076gF
         8Boid4rw8SEa/Mg9Q3Qmon5vDtJpSPiRT4riF+z+8HBEF3AsxG317A+DLtDEyfOe38yR
         aQKAoHrWrIgUK69dGWLZDMyzRqvVVmSeb5yTwui2n9xcVX+2n47W1RB6pnkDbPtXkAQ/
         qdNdlJ2v/vJOfMqm/xzZXnkVtJSnKpbqftiB1a7bdUSBQUklCDYCa5vF5ign9dYDVzzC
         QBLciHZuMd/sKzXDCHi2KzfRgJ0EAZa3A4Oh9u6aDRjE2id1rUTF0Dop2+wjBQNwk1WF
         33BA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=bOV8Wv1vRtPgqZoML7SL6Zwu6Kwh1cX89Ql2n1q9jDU=;
        b=mMYX6WBFpAJ9Z7gNSciUrhueR8so/zexYIKDIIfciFrcmlg1eIqi16U2A2Kw9zQdkD
         y+nvMN22y8z2xVRZO5c1YtdzrnPWHO6wyyLWFqD05vl5VDSEPJOVWkVLMJGpfPe7bsdK
         zj/C/58jU78olFOZ0JOAGY4s3TF4R/UkX5xtI1iCfuE6rzen+EuvISHdaIMRa3nU1p0r
         sywUuIq4zZEuU6Fk7sfwfVTSyt5cQa8/Sdv1NNuR7dDpd1qOQaQufi1G/SQw/aQkZROd
         8q2kVc9UIcE8vyGOP85BDLUlHj4z9lcT68G9BMpc0AloPA92acqKpMJmLU/dpscjyYMw
         ikrg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m88si4371703ede.157.2019.02.13.05.53.23
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 05:53:23 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 320B080D;
	Wed, 13 Feb 2019 05:53:22 -0800 (PST)
Received: from [10.162.43.147] (p8cg001049571a15.blr.arm.com [10.162.43.147])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C93C03F557;
	Wed, 13 Feb 2019 05:53:18 -0800 (PST)
Subject: Re: [RFC 1/4] mm: Introduce lazy exec permission setting on a page
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@kernel.org,
 kirill@shutemov.name, kirill.shutemov@linux.intel.com, vbabka@suse.cz,
 will.deacon@arm.com, catalin.marinas@arm.com, dave.hansen@intel.com
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
 <1550045191-27483-2-git-send-email-anshuman.khandual@arm.com>
 <20190213131710.GR12668@bombadil.infradead.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <19b85484-e76b-3ef0-b013-49efa87917ae@arm.com>
Date: Wed, 13 Feb 2019 19:23:18 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190213131710.GR12668@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/13/2019 06:47 PM, Matthew Wilcox wrote:
> On Wed, Feb 13, 2019 at 01:36:28PM +0530, Anshuman Khandual wrote:
>> +#ifdef CONFIG_ARCH_SUPPORTS_LAZY_EXEC
>> +static inline pte_t maybe_mkexec(pte_t entry, struct vm_area_struct *vma)
>> +{
>> +	if (unlikely(vma->vm_flags & VM_EXEC))
>> +		return pte_mkexec(entry);
>> +	return entry;
>> +}
>> +#else
>> +static inline pte_t maybe_mkexec(pte_t entry, struct vm_area_struct *vma)
>> +{
>> +	return entry;
>> +}
>> +#endif
> 
>> +++ b/mm/memory.c
>> @@ -2218,6 +2218,8 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
>>  	flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
>>  	entry = pte_mkyoung(vmf->orig_pte);
>>  	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
>> +	if (vmf->flags & FAULT_FLAG_INSTRUCTION)
>> +		entry = maybe_mkexec(entry, vma);
> 
> I don't understand this bit.  We have a fault based on an instruction
> fetch.  But we're only going to _maybe_ set the exec bit?  Why not call
> pte_mkexec() unconditionally?

Because the arch might not have subscribed to this in which case the fall
back function does nothing and return the same entry. But in case this is
enabled it also checks for VMA exec flag (VM_EXEC) before calling into
pte_mkexec() something similar to existing maybe_mkwrite().

