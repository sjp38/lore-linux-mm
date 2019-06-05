Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECAD2C28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 21:22:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EE5920652
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 21:22:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eLDsRwOh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EE5920652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C3276B026D; Wed,  5 Jun 2019 17:22:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 373C86B026E; Wed,  5 Jun 2019 17:22:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28ABD6B026F; Wed,  5 Jun 2019 17:22:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D24176B026D
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 17:22:51 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d13so364058edo.5
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 14:22:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XYR0qJWfd1D1ufm9G1S7XwxRI+/pUaRAjNUa1IxBLC8=;
        b=tkBUTqKWDf8yC72iKC7w9sTD1RJB9Bp1vCZ8ODnJ8qPJNtdh2Iq2bUzUCNqfF4eUWM
         p62xTjHaW6jNhu3Xx1QNai82CF5ZacLC2b0VrvnTOcG7xJ+CtgGnDdr8JgWAjEZbc+75
         bF7v04qcfqP37tqsCOtX3sKXEuRdtIwE7vtt4vfLxxlBRtsJ7hS09mEWzfrBSpGLXEpR
         qvWQif3KhNIdKxjMiin2hT94wO7CBD0P1GUAC7d9ibKecZB2iWWN2ziZSs9Wac/9E3+S
         DexArJryGlGEDq9jqhTZtgXTnmGsO5VwUsteo1aSV3ZwGv+xavXl2z6bNRzC9xgsiuNS
         7p7w==
X-Gm-Message-State: APjAAAVHJE8Usl7LpaB5wT/LZS0CQas1VZUVZaXN1V1sXw8ld4AMM/vg
	kTrhkjK/cypmB8V6WmNYaxZz8Q4tiYABH26P8UNiC+Lv7tR4CoYI1yjsRyzAzWhfsdytMVe4OPW
	ZtRR3s+e/Nf/XMJ3t2c5pRu/nbhznMxiTkW5zONWwfaAVrO3UkE3QzBJCSyJnL43b3g==
X-Received: by 2002:a50:8be8:: with SMTP id n37mr24342498edn.216.1559769771432;
        Wed, 05 Jun 2019 14:22:51 -0700 (PDT)
X-Received: by 2002:a50:8be8:: with SMTP id n37mr24342461edn.216.1559769770801;
        Wed, 05 Jun 2019 14:22:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559769770; cv=none;
        d=google.com; s=arc-20160816;
        b=0mif+gYutvOBGTlfee1ErNE9srCAtIY9n6BhJTuGNQ9JnkNFAeciXTE+/UqXaGQ8ui
         1WTbpgi/Y8NvAtLpwd4Ge3LkDOH1rq6uVAXqD6o3A9itnJA8GlagvMF/ajkvUuyRCc4t
         cFtPWY7rDGoOwnxBjguasX31hTleebuwJeKYdql3SVFYoPF3tuwLGGnfXvdRjnNwLMlW
         /t7aXE2XLDCu0axQnAOSXOzerOCfYBmIooR3g/iuhM7282E5BvVKSJf8/UvoCaG3n9Fl
         RNz0+wwgpLY8hX1zqhXr6tP/4BzmEyqSmZW+wzwrzw+oBARaF34oa6wtcsSySQOuy36Y
         TDdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=XYR0qJWfd1D1ufm9G1S7XwxRI+/pUaRAjNUa1IxBLC8=;
        b=oAF4MYWbO49QgY08KnCUkJX5XafLyLZfgJKXdfsQCVg0ykFaLp9aRCTK0U4ujzzmNL
         Db76m3Jb9Wn2GebdXD8rDdq7iRUcxb7D32zgyLkANZQn5CtdwxygX4DFbXO2RTlXDYy1
         lVmj+NoUekPjed2qJyQZaS5V5CEAyAD3qc5nsizWw34g1/Mr+lnqeTuJ2R5ag0XfkH2Z
         WyVGfOdlE6TrcswVjMcmejeRM3iyWMJsRD9/6fbiCDM7oXjmHtwj+SVdtWVI5dCt+B3F
         YD46pzWVycV62GjPt8H5MBYspa8Ml1FW6PepjicPUzIPsmFmTVItXWFocXHcgMxzs8qM
         QRSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eLDsRwOh;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b51sor1444132eda.2.2019.06.05.14.22.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 14:22:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eLDsRwOh;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=XYR0qJWfd1D1ufm9G1S7XwxRI+/pUaRAjNUa1IxBLC8=;
        b=eLDsRwOhaZ0avYP5JbU/qyfKGB5DOL//jHeF0QIsj1xnkLpW3HfER5+1gHsFmyizdC
         TuPwJNXIJpeJwU2upcFzFr2gEM64wh1+94uumBqpRcHFkWQutwdt26Yv9sREHRvruvlk
         znKdHE2O7dSxq57NCvmgeA8foqkPAvf6tdKk+a+LkY6ICiZeCziK45J+jM2lAsYvL8tU
         +Q8RJK0GedIjFeQ+8FmqES5ccIjWGHSdcUNJ5Cq529NwrtvIRUY0YNg79G4IDKPEHmSd
         H8/CXuU0qTWRFEgsEUaYHo7abpCchUSLqryQVVOJdl4FKhHRIozaUGG29SyMvtoYQjn2
         iqLQ==
X-Google-Smtp-Source: APXvYqzyKS0phZCywdwPXToHaq30FkGf9zmLn9+DGARhqy7Cp0rjLbRZrzlUzgkPZspLLdcqpnQe5Q==
X-Received: by 2002:a50:927d:: with SMTP id j58mr11330969eda.230.1559769770516;
        Wed, 05 Jun 2019 14:22:50 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id c7sm3853751ejz.71.2019.06.05.14.22.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Jun 2019 14:22:49 -0700 (PDT)
Date: Wed, 5 Jun 2019 21:22:49 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: David Hildenbrand <david@redhat.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Ingo Molnar <mingo@kernel.org>,
	Andrew Banman <andrew.banman@hpe.com>,
	Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: Re: [PATCH v3 07/11] mm/memory_hotplug: Create memory block devices
 after arch_add_memory()
Message-ID: <20190605212249.s7knac6vimealdmx@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-8-david@redhat.com>
 <20190604214234.ltwtkcdoju2gxisx@master>
 <f6523d67-cac9-1189-884a-67b6829320ba@redhat.com>
 <9a1d282f-8dd9-a48b-cc96-f9afaa435c62@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9a1d282f-8dd9-a48b-cc96-f9afaa435c62@redhat.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 12:58:46PM +0200, David Hildenbrand wrote:
>On 05.06.19 10:58, David Hildenbrand wrote:
>>>> /*
>>>>  * For now, we have a linear search to go find the appropriate
>>>>  * memory_block corresponding to a particular phys_index. If
>>>> @@ -658,6 +670,11 @@ static int init_memory_block(struct memory_block **memory, int block_id,
>>>> 	unsigned long start_pfn;
>>>> 	int ret = 0;
>>>>
>>>> +	mem = find_memory_block_by_id(block_id, NULL);
>>>> +	if (mem) {
>>>> +		put_device(&mem->dev);
>>>> +		return -EEXIST;
>>>> +	}
>>>
>>> find_memory_block_by_id() is not that close to the main idea in this patch.
>>> Would it be better to split this part?
>> 
>> I played with that but didn't like the temporary results (e.g. having to
>> export find_memory_block_by_id()). I'll stick to this for now.
>> 
>>>
>>>> 	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
>>>> 	if (!mem)
>>>> 		return -ENOMEM;
>>>> @@ -699,44 +716,53 @@ static int add_memory_block(int base_section_nr)
>>>> 	return 0;
>>>> }
>>>>
>>>> +static void unregister_memory(struct memory_block *memory)
>>>> +{
>>>> +	if (WARN_ON_ONCE(memory->dev.bus != &memory_subsys))
>>>> +		return;
>>>> +
>>>> +	/* drop the ref. we got via find_memory_block() */
>>>> +	put_device(&memory->dev);
>>>> +	device_unregister(&memory->dev);
>>>> +}
>>>> +
>>>> /*
>>>> - * need an interface for the VM to add new memory regions,
>>>> - * but without onlining it.
>>>> + * Create memory block devices for the given memory area. Start and size
>>>> + * have to be aligned to memory block granularity. Memory block devices
>>>> + * will be initialized as offline.
>>>>  */
>>>> -int hotplug_memory_register(int nid, struct mem_section *section)
>>>> +int create_memory_block_devices(unsigned long start, unsigned long size)
>>>> {
>>>> -	int block_id = base_memory_block_id(__section_nr(section));
>>>> -	int ret = 0;
>>>> +	const int start_block_id = pfn_to_block_id(PFN_DOWN(start));
>>>> +	int end_block_id = pfn_to_block_id(PFN_DOWN(start + size));
>>>> 	struct memory_block *mem;
>>>> +	unsigned long block_id;
>>>> +	int ret = 0;
>>>>
>>>> -	mutex_lock(&mem_sysfs_mutex);
>>>> +	if (WARN_ON_ONCE(!IS_ALIGNED(start, memory_block_size_bytes()) ||
>>>> +			 !IS_ALIGNED(size, memory_block_size_bytes())))
>>>> +		return -EINVAL;
>>>>
>>>> -	mem = find_memory_block(section);
>>>> -	if (mem) {
>>>> -		mem->section_count++;
>>>> -		put_device(&mem->dev);
>>>> -	} else {
>>>> +	mutex_lock(&mem_sysfs_mutex);
>>>> +	for (block_id = start_block_id; block_id != end_block_id; block_id++) {
>>>> 		ret = init_memory_block(&mem, block_id, MEM_OFFLINE);
>>>> 		if (ret)
>>>> -			goto out;
>>>> -		mem->section_count++;
>>>> +			break;
>>>> +		mem->section_count = sections_per_block;
>>>> +	}
>>>> +	if (ret) {
>>>> +		end_block_id = block_id;
>>>> +		for (block_id = start_block_id; block_id != end_block_id;
>>>> +		     block_id++) {
>>>> +			mem = find_memory_block_by_id(block_id, NULL);
>>>> +			mem->section_count = 0;
>>>> +			unregister_memory(mem);
>>>> +		}
>>>> 	}
>>>
>>> Would it be better to do this in reverse order?
>>>
>>> And unregister_memory() would free mem, so it is still necessary to set
>>> section_count to 0?
>> 
>> 1. I kept the existing behavior (setting it to 0) for now. I am planning
>> to eventually remove the section count completely (it could be
>> beneficial to detect removing of partially populated memory blocks).
>
>Correction: We already use it to block offlining of partially populated
>memory blocks \o/

Would you mind letting me know where we leverage this?

>
>> 
>> 2. Reverse order: We would have to start with "block_id - 1", I don't
>> like that better.
>> 
>> Thanks for having a look!
>> 
>
>
>-- 
>
>Thanks,
>
>David / dhildenb

-- 
Wei Yang
Help you, Help me

