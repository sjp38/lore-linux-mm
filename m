Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 693C9C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:31:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CFB02173C
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:31:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CFB02173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 851DF6B0005; Wed, 17 Apr 2019 09:31:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FF9C6B0006; Wed, 17 Apr 2019 09:31:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EFA76B0007; Wed, 17 Apr 2019 09:31:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 21D0B6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 09:31:18 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y7so12630949eds.7
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 06:31:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=80Fc5vCm7MXJCIj4hA1wwDbBitsMVHqGA795yPTmxJA=;
        b=iXPfOiFlHl7v6o1VeLm1Y/R/xVTEVHiOaY31tNJGX5COFGo84bhYFcetE/8bMslOL1
         rAbkADr7cKlW5oR1xDK7g1I1grKX1AbR/FJ5AeaNwDX8SqUDzHp5R+3pyUR3wk27fAQQ
         fWnbZwQ3wudTWo0uH1ufr+0NRad3VMnVIAzO8FBlNzrR+w6/j7gPO5hIMH7PPfHJfsRm
         Twq5P7K4bKf6nGwsgLmq+i5NuREU4E+9pruG1Dq0fPzaOK/fN+7SRnH8k6KqPCeAKhbR
         g/+DgTFOZbYKkFBQbQuWq4d6ksomQX4owCSRG9hsgAWkAa8K4ICjhdBUvCp0flb6uMy8
         35mw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXbcrHETmN67+bzdwQ5cbKkpyI6y955dsOaZhpvshXCNPzaEvSO
	eEiEkJkRNZH8MwWKLoLdR+PRl96FBqn2ASHQfkO2DtAFPOARJm8GFMieqewwe7sR231hcyb8WdX
	48JlNw+FfGLfZABGgFvSfpgFgMOCwZqvIWmBMEgCpBZ34ELQmq5tHa2e5Bt0XyBKdyA==
X-Received: by 2002:a50:a4c3:: with SMTP id x3mr56646719edb.190.1555507877590;
        Wed, 17 Apr 2019 06:31:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzriwWdLkT/G6yP/kexkdqrCpEkYqT1DEPOTpu+zaBNu/h23T6jhpODZM7gOG9oyju9NiC2
X-Received: by 2002:a50:a4c3:: with SMTP id x3mr56646662edb.190.1555507876643;
        Wed, 17 Apr 2019 06:31:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555507876; cv=none;
        d=google.com; s=arc-20160816;
        b=ugwx3ukNTN4GWwoRsTT0i8YypqoYv1bBozIpKjUnlZAuL1lXxVvFqAr/2noTqgYr0A
         4aMYeMO82ICH4vtZi+kRhWnZFnh0GNVaZY/rXiqZao5cS1gmK2+3Nnr/uxkAwKlDef14
         4GRrPkiXtNPFfrcclzt18I0pVg12Moj1PFqa7+gFeZJPRX1G02EDtV+DFyMNNlBScA+X
         beEkJQ48LuEyXDwRUu6sIn907t3Q/bmnv3joYuYFQjYZDSxnc87wUuWE5aZwRLbQCrKr
         ErrThRMIKFpITbHH/a6nskBENBzqit0rwGCyWkL9o1SF5oiw19AAXYcMv3HQd/aAkqYO
         katA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=80Fc5vCm7MXJCIj4hA1wwDbBitsMVHqGA795yPTmxJA=;
        b=ltOzCedGIlqwrh1n7ShB6hkKY809LYKydu35/a2H2dJupeUe6sSiZOsOJcIA+hB3V6
         QJzITmFtHHTC0bYS0rkH270wQ26kwD+tLlXpkBTFHszmKAvO7ApqystoCVMJQF+rUkvh
         bI06q4wordRx66V/lZ1Z42PrLxe0faUR/cQK0YpVOTvlajrSXEXBQJAK64lGgSeAD1AH
         kh5b4EXX2xUxt/ElSpzHSXrM+H52IA9oQAgOscyFkYmUPn8kAmwGqlZMm+rlGcKSl36A
         1E2J7lgsbIlnxH/c4W7LgQIpZ3eZab7qd3oS2nnUN0hnXTb7puXNHcqUUqbaqV1Gd1Wj
         A13A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h9si3723347edw.334.2019.04.17.06.31.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 06:31:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 31435B136;
	Wed, 17 Apr 2019 13:31:16 +0000 (UTC)
Subject: Re: [PATCH 2/3] mm: separate memory allocation and actual work in
 alloc_vmap_area()
To: Roman Gushchin <guro@fb.com>
Cc: Roman Gushchin <guroan@gmail.com>, "linux-mm@kvack.org"
 <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Matthew Wilcox <willy@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>,
 Kernel Team <Kernel-team@fb.com>
References: <20190225203037.1317-1-guro@fb.com>
 <20190225203037.1317-3-guro@fb.com>
 <db6b9745-7e64-6eb9-6b2b-da9d157a779b@suse.cz>
 <20190301164834.GA3154@tower.DHCP.thefacebook.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <ed835e2c-9357-c7ea-f458-0cd9b8f6e966@suse.cz>
Date: Wed, 17 Apr 2019 15:27:56 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190301164834.GA3154@tower.DHCP.thefacebook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/1/19 5:48 PM, Roman Gushchin wrote:
> On Fri, Mar 01, 2019 at 03:43:19PM +0100, Vlastimil Babka wrote:
>> On 2/25/19 9:30 PM, Roman Gushchin wrote:
>>> alloc_vmap_area() is allocating memory for the vmap_area, and
>>> performing the actual lookup of the vm area and vmap_area
>>> initialization.
>>>
>>> This prevents us from using a pre-allocated memory for the map_area
>>> structure, which can be used in some cases to minimize the number
>>> of required memory allocations.
>>
>> Hmm, but that doesn't happen here or in the later patch, right? The only
>> caller of init_vmap_area() is alloc_vmap_area(). What am I missing?
> 
> So initially the patch was a part of a bigger patchset, which
> tried to minimize the number of separate allocations during vmalloc(),
> e.g. by inlining vm_struct->pages into vm_struct for small areas.
> 
> I temporarily dropped the rest of the patchset for some rework,
> but decided to leave this patch, because it looks like a nice refactoring
> in any case, and also it has been already reviewed and acked by Matthew
> and Johannes.

OK then,

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> Thank you for looking into it!
> 

