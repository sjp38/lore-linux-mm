Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4B6BC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 08:11:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96E63218FF
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 08:11:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96E63218FF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CBB48E0002; Fri, 15 Feb 2019 03:11:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AC2B8E0001; Fri, 15 Feb 2019 03:11:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 192C78E0002; Fri, 15 Feb 2019 03:11:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B47668E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:11:21 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id m25so3559709edp.22
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 00:11:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=ZmjmF2pp64kgZvcLy1UzWdAn5K3MvkS5Ruj/r8/274I=;
        b=SqH3IuVIlEH1EuydgcQrBwThRjKcU/5YDjjzRM9NFz5TppLDNsi4z66dZ/Xa/HEi8j
         NcVL7He4te1Qbskzo3aOyR5iJZ9euGXEhTYHftxVhIOdQDSTxGqAHnte1QW7VWkulDzx
         HbsT4lb9+1wpHwWgmkYipZQZpG49/C43JOJsSAegoDh28GtwJiFR8naPL5nBR8SPBe+X
         3y4iE1pi6dFWDC5ihFSkSaiPkiN1iEZoF+hlq2b85U6kLds/7krZDTfWwzCBoWPN+gdS
         nl9SWZ35kSF3r/4N+WlYWHffn3pnL+lwu4jrL00R02ynaYt9L6Eqv29lGptVbnWbXMl+
         GvGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuaNzDmehktUIB946h0dCTXpAz6Aeb78vVZ5vkRnNlXH1qhk7ypz
	XEz6cXGF6dPxiT24ymVKLKNEeC8p0xfClPAoYjrJnGP/9T9RhHRzcxKRTUTtHAtx2AuVOppfae+
	+4W0+uZaZMmZtO0yOapisyunFO+PRoiEki2M7jOcAU+92Zrdv37vDBeuLu48la8c/lQ==
X-Received: by 2002:a05:6402:13cd:: with SMTP id a13mr6674825edx.152.1550218281294;
        Fri, 15 Feb 2019 00:11:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZKA87e8XC4v0ROS7dEbBLi3qC3xvHRcg/KEYkBD0BUQLZOBpQRyiF7pAXmTGRGizSJLAFb
X-Received: by 2002:a05:6402:13cd:: with SMTP id a13mr6674771edx.152.1550218280402;
        Fri, 15 Feb 2019 00:11:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550218280; cv=none;
        d=google.com; s=arc-20160816;
        b=vY7YZa3S+OA6/CgjKkYidndB+pT9lL0VFGUi8AS3FPfYd95dKrXxQesAtkiWOas2HN
         6R77rEY8sHfRC53liLiD0qYtqoARfIJC7pcBO32kHtPOB4W72gYbz0sJ2s1DKcJVU/Z5
         mL7hx914fpEJHyI+QJexwsFYrCC+3QaPuNiJF/cSRQe+HWQ97CuxWLVVdk1lD1zSF+NX
         rijLHd17NhKXP+ibYXOkOwHVEOmKBDicJefH8WKAOwEP9AuNkXBzTshsfpKf3BUEfFOm
         R0TP4KC2hX2Kv4FcoV7BInQENokN6SrK8/m4vPve52/6WsKTrJUXB7wyvLhnMrGXexB2
         xQWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=ZmjmF2pp64kgZvcLy1UzWdAn5K3MvkS5Ruj/r8/274I=;
        b=DXoX3hT7kPEbi1bpBn0yu46aOT+aWIdQrHIwLiRvOgdX1uDFruCSiU5AqXqFzKnbsT
         r03hSl8GG/tKAXW6wvo2yVnF0LWA/yshpQCs+CYXhPUb7V6ERn3la5zQQVk4RP4/8NRX
         L+Olwt5MMpNF4MoPLvEizXEzYOWXlmZSFPD3QhUtApVYwE/ghBp3cEKEOrnC0O3VcRK6
         4MzDT7LSKrsf9EQF1ujwO6rBKH9Hm8rtlHSKIRuldFzpVVmo2UROZELkB0v3F3OiUvo1
         2A8nlQtK0OhwBG4ElPPfS/FOMLZ3B/DrAA59xxW4xJu+xnKoRqPMkIYb2koCh51yoUWQ
         5ATw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w21si2244976eds.29.2019.02.15.00.11.20
        for <linux-mm@kvack.org>;
        Fri, 15 Feb 2019 00:11:20 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id DD745A78;
	Fri, 15 Feb 2019 00:11:18 -0800 (PST)
Received: from [10.162.43.140] (p8cg001049571a15.blr.arm.com [10.162.43.140])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A10BA3F557;
	Fri, 15 Feb 2019 00:11:15 -0800 (PST)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [RFC 1/4] mm: Introduce lazy exec permission setting on a page
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
 akpm@linux-foundation.org, mhocko@kernel.org, kirill@shutemov.name,
 kirill.shutemov@linux.intel.com, vbabka@suse.cz, will.deacon@arm.com,
 catalin.marinas@arm.com, dave.hansen@intel.com
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
 <1550045191-27483-2-git-send-email-anshuman.khandual@arm.com>
 <20190213131710.GR12668@bombadil.infradead.org>
 <19b85484-e76b-3ef0-b013-49efa87917ae@arm.com>
 <20190214090628.GB9063@rapoport-lnx>
Message-ID: <8dfa8273-b21d-5f6c-eb3e-7992c6863a07@arm.com>
Date: Fri, 15 Feb 2019 13:41:16 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190214090628.GB9063@rapoport-lnx>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/14/2019 02:36 PM, Mike Rapoport wrote:
> On Wed, Feb 13, 2019 at 07:23:18PM +0530, Anshuman Khandual wrote:
>>
>>
>> On 02/13/2019 06:47 PM, Matthew Wilcox wrote:
>>> On Wed, Feb 13, 2019 at 01:36:28PM +0530, Anshuman Khandual wrote:
>>>> +#ifdef CONFIG_ARCH_SUPPORTS_LAZY_EXEC
>>>> +static inline pte_t maybe_mkexec(pte_t entry, struct vm_area_struct *vma)
>>>> +{
>>>> +	if (unlikely(vma->vm_flags & VM_EXEC))
>>>> +		return pte_mkexec(entry);
>>>> +	return entry;
>>>> +}
>>>> +#else
>>>> +static inline pte_t maybe_mkexec(pte_t entry, struct vm_area_struct *vma)
>>>> +{
>>>> +	return entry;
>>>> +}
>>>> +#endif
>>>
>>>> +++ b/mm/memory.c
>>>> @@ -2218,6 +2218,8 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
>>>>  	flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
>>>>  	entry = pte_mkyoung(vmf->orig_pte);
>>>>  	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
>>>> +	if (vmf->flags & FAULT_FLAG_INSTRUCTION)
>>>> +		entry = maybe_mkexec(entry, vma);
>>>
>>> I don't understand this bit.  We have a fault based on an instruction
>>> fetch.  But we're only going to _maybe_ set the exec bit?  Why not call
>>> pte_mkexec() unconditionally?
>>
>> Because the arch might not have subscribed to this in which case the fall
>> back function does nothing and return the same entry. But in case this is
>> enabled it also checks for VMA exec flag (VM_EXEC) before calling into
>> pte_mkexec() something similar to existing maybe_mkwrite().
> 
> Than why not pass vmf->flags to maybe_mkexec() so that only arches
> subscribed to this will have the check for 'flags & FAULT_FLAG_INSTRUCTION' ?

Right it can help remove couple of instructions from un-subscribing archs. 

