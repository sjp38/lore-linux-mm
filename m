Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97194C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 10:30:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D70221019
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 10:30:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D70221019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D68398E0003; Thu, 14 Mar 2019 06:30:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D15308E0001; Thu, 14 Mar 2019 06:30:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEDFB8E0003; Thu, 14 Mar 2019 06:30:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 63EB38E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 06:30:06 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p4so2208055edd.0
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 03:30:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=GX5du4KPAlD8W+/E9CLMUop4J/VDhbjPK/SjZGcBi8k=;
        b=ZOqnnH3E4ZJ493/gX87sNUl8Kz/2hOD1OtYeVz+EfiRTfsAxOMzyL433g4f5+Ej2Qo
         d2CRfyqnRZXTu8RCTCs6Y46MePHkGhbEJZPe57IwI0H7dy4xBaGDbuX9ENz5uqz+LDtD
         7G0HJGFkLkyUMugqJPoFD1v9NXdQz5BPdJmqtTtfmQ7mdsu2H5TTzpWhRCV82eqjKuA4
         jk3z7nXoF7lfLI0xDObm/+z8qBzoROfKR/q1iinbj8cLBo4aiS0wSVoV450l3Fvv+IX4
         lmKBEIPBsU3mVsHy028XOKzT6+Kenteu03LRo0kPlNc9/Ykux2I48lmdPLVHCuAY0y70
         GPiA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAX9L1udgc8HBxKrET0VHpE4B4Vqz3k/cm4xthKKt0bbAm29BjcV
	XctXWcT4gVheVrHRnrAL0yIalzWQAvou6ARlWEanl2oFHvqoQr5reTG6iTL/++Z3TAIyjE8/NVX
	8xHinIG1GkGsv77SmWi/iEZR0AqftNuyGs5Ki2cmCHaehj5r7T8uv5IqUiYiaP5D5XA==
X-Received: by 2002:a17:906:f11:: with SMTP id z17mr16029909eji.116.1552559405942;
        Thu, 14 Mar 2019 03:30:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyxjcc+8NtgDwMzV5aZt/idxSNWH4247TiF9jqWivfNPlQghrf+tjclMCM+87zttuVzyZ/A
X-Received: by 2002:a17:906:f11:: with SMTP id z17mr16029846eji.116.1552559404955;
        Thu, 14 Mar 2019 03:30:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552559404; cv=none;
        d=google.com; s=arc-20160816;
        b=z26vxsAndL34vaIgUuaLxa6MaZ8ZTjHy8ku807L6ykItXWkJ8ueXaQHm/h/FtAPEtG
         ri10BncP9tSoXQwSDb7I62QGKCyS3LHLQ6LgizY20OYtyoIDWr9NBdpgn3lo7UvWwosF
         SFiJnSzI01HLjeTdVo93+F/Bn6wqi3fIWL5zl+sZbDdKES3aDAsyX8VmmrSw9shbr4t8
         ukXv8KZ8cSyyiL+PLkKbvsKA/lgg8OPvfqtuxijEMFzeSk1BwVHa/MVq0bDp6O8PQVi9
         mf0BL/llh6176D4er9aMNznnnVz8L0MuFAYyPqfLLCnt7FiSMeq6jSWH4XH9nS8SgPLd
         5L4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=GX5du4KPAlD8W+/E9CLMUop4J/VDhbjPK/SjZGcBi8k=;
        b=KlG7zX4RWol9TX77lXt8AA+oR6vmWK0SQSC8MICcRAzX9+K4YMm1qCk9OzNx8AMgYt
         oWGYjTxFQpZ2XDlgKJ8AnZ5+h9WYD7wYLMkRQKxETNV9LnPA+7CxP45usaGhYMWwmBhi
         FVfU/2uU4FltIAT2I0MMQTj9PGKTRY46xURusE1UpNVCRkxVnelSAIq6laEIx4erbMpG
         ng6iihDgOs3uCzqkNcKyx2/vSxC1ju3p/4TRbgvqEhi0I++2AXcR8b4yVP+Y821F/9qh
         nhpD2ze5eRRq4Yewu3xuZoJ3Dbn9/Y3pKoVjcyn/hg6D1+P9Cf+Zpttv14LmyBwNWP94
         OzoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v14si300681edr.2.2019.03.14.03.30.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 03:30:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5C95EAF15;
	Thu, 14 Mar 2019 10:30:04 +0000 (UTC)
Subject: Re: [PATCH v2] mm, page_alloc: disallow __GFP_COMP in
 alloc_pages_exact()
To: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov"
 <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>,
 Takashi Iwai <tiwai@suse.de>
References: <20190314093944.19406-1-vbabka@suse.cz>
 <20190314094249.19606-1-vbabka@suse.cz>
 <20190314101526.GH7473@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1dc997a3-7573-7bd5-9ce6-3bfbf77d1194@suse.cz>
Date: Thu, 14 Mar 2019 11:30:03 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.2
MIME-Version: 1.0
In-Reply-To: <20190314101526.GH7473@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/14/19 11:15 AM, Michal Hocko wrote:
> On Thu 14-03-19 10:42:49, Vlastimil Babka wrote:
>> alloc_pages_exact*() allocates a page of sufficient order and then splits it
>> to return only the number of pages requested. That makes it incompatible with
>> __GFP_COMP, because compound pages cannot be split.
>> 
>> As shown by [1] things may silently work until the requested size (possibly
>> depending on user) stops being power of two. Then for CONFIG_DEBUG_VM, BUG_ON()
>> triggers in split_page(). Without CONFIG_DEBUG_VM, consequences are unclear.
>> 
>> There are several options here, none of them great:
>> 
>> 1) Don't do the spliting when __GFP_COMP is passed, and return the whole
>> compound page. However if caller then returns it via free_pages_exact(),
>> that will be unexpected and the freeing actions there will be wrong.
>> 
>> 2) Warn and remove __GFP_COMP from the flags. But the caller wanted it, so
>> things may break later somewhere.
>> 
>> 3) Warn and return NULL. However NULL may be unexpected, especially for
>> small sizes.
>> 
>> This patch picks option 3, as it's best defined.
> 
> The question is whether callers of alloc_pages_exact do have any
> fallback because if they don't then this is forcing an always fail path
> and I strongly suspect this is not really what users want. I would
> rather go with 2) because "callers wanted it" is much less probable than
> "caller is simply confused and more gfp flags is surely better than
> fewer".

I initially went with 2 as well, as you can see from v1 :) but then I looked at
the commit [2] mentioned in [1] and I think ALSA legitimaly uses __GFP_COMP so
that the pages are then mapped to userspace. Breaking that didn't seem good.

The point is that with the warning in place, A developer will immediately know
that they did something wrong, regardless if the size is power-of-two or not.
But yeah, if it's adding of __GFP_COMP that is not deterministic, a bug can
still sit silently for a while.

But maybe we could go with 1) if free_pages_exact() is also adjusted to check
for CompoundPage and free it properly?

>> [1] https://lore.kernel.org/lkml/20181126002805.GI18977@shao2-debian/T/#u

[2]
https://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound.git/commit/?id=3a6d1980fe96dbbfe3ae58db0048867f5319cdbf

>> 
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> ---
>> Sent v1 before amending commit, sorry.
>> 
>>  mm/page_alloc.c | 15 ++++++++++++---
>>  1 file changed, 12 insertions(+), 3 deletions(-)
>> 
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 0b9f577b1a2a..dd3f89e8f88d 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -4752,7 +4752,7 @@ static void *make_alloc_exact(unsigned long addr, unsigned int order,
>>  /**
>>   * alloc_pages_exact - allocate an exact number physically-contiguous pages.
>>   * @size: the number of bytes to allocate
>> - * @gfp_mask: GFP flags for the allocation
>> + * @gfp_mask: GFP flags for the allocation, must not contain __GFP_COMP
>>   *
>>   * This function is similar to alloc_pages(), except that it allocates the
>>   * minimum number of pages to satisfy the request.  alloc_pages() can only
>> @@ -4768,6 +4768,10 @@ void *alloc_pages_exact(size_t size, gfp_t gfp_mask)
>>  	unsigned long addr;
>>  
>>  	addr = __get_free_pages(gfp_mask, order);
>> +
>> +	if (WARN_ON_ONCE(gfp_mask & __GFP_COMP))
>> +		return NULL;
>> +
>>  	return make_alloc_exact(addr, order, size);
>>  }
>>  EXPORT_SYMBOL(alloc_pages_exact);
>> @@ -4777,7 +4781,7 @@ EXPORT_SYMBOL(alloc_pages_exact);
>>   *			   pages on a node.
>>   * @nid: the preferred node ID where memory should be allocated
>>   * @size: the number of bytes to allocate
>> - * @gfp_mask: GFP flags for the allocation
>> + * @gfp_mask: GFP flags for the allocation, must not contain __GFP_COMP
>>   *
>>   * Like alloc_pages_exact(), but try to allocate on node nid first before falling
>>   * back.
>> @@ -4785,7 +4789,12 @@ EXPORT_SYMBOL(alloc_pages_exact);
>>  void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask)
>>  {
>>  	unsigned int order = get_order(size);
>> -	struct page *p = alloc_pages_node(nid, gfp_mask, order);
>> +	struct page *p;
>> +
>> +	if (WARN_ON_ONCE(gfp_mask & __GFP_COMP))
>> +		return NULL;
>> +
>> +	p = alloc_pages_node(nid, gfp_mask, order);
>>  	if (!p)
>>  		return NULL;
>>  	return make_alloc_exact((unsigned long)page_address(p), order, size);
>> -- 
>> 2.20.1
> 

