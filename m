Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30A8CC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 11:46:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6DB12147C
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 11:46:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6DB12147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B4478E0007; Mon, 25 Feb 2019 06:46:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 265008E0004; Mon, 25 Feb 2019 06:46:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 137FD8E0007; Mon, 25 Feb 2019 06:46:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE0CA8E0004
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 06:46:50 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id j5so3751509edt.17
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 03:46:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=tFwUwEqGb1rXwUYXN4mNnP93vKgOIcKRDgrGO7DYd+M=;
        b=Gy0nZWoKNSbRvtDjoGCWR/N/aunh/HShvZNFnJzvQfLoURZ/z9L++bSSWf7ld3kG8g
         6vdIsKuatL+SHkHBw1TJ2uU69hGEjQfVZDySYmtexmG1odBqz5ja8YG5xck2bllgIUiP
         1xF0osCvprab6EX8Mdnmrrfs/BQA1vpsjpSJPXXkZHaxvQm17H3FhS5xZGwCzvvzCMSr
         fkLZQoXB4RM/7pmO1QgIaKBc29+3iSdNclczF8nuQF7zFDZAolyOkXu9ZjBISGN5cG3b
         Ums38A6APKsycrAS7j+07/VLfRIJQRMZKwKS60ZfTyTYCdZHp76qmGp6izxjE6MmE9vJ
         BGRA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuaZJDCXNoS5+7gTOMzqkG52/HG3bcLcoaul7kcYsbduwLTqS2rT
	Tm0vqZCfC9+KIu8UIghRwbIAGtrMkh3asIhSilwV5dcZ+TnBa7eYG4XoewTbBe9W6zQL12CTt1u
	w2qC9lwM57rro6h7/Zf16+OpC7OygCcQWXTeFKLe0HevFHghrAPVgX1Fq/q+6LIIGWg==
X-Received: by 2002:a17:906:128c:: with SMTP id k12mr12924533ejb.77.1551095210246;
        Mon, 25 Feb 2019 03:46:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZEHYDyAhgbM682u5T4qzOvlkvTaEBU8CdLWo/OL4MZdP/0q30q2v1FvZvihqCKopvqbnkL
X-Received: by 2002:a17:906:128c:: with SMTP id k12mr12924477ejb.77.1551095209142;
        Mon, 25 Feb 2019 03:46:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551095209; cv=none;
        d=google.com; s=arc-20160816;
        b=Zljiu2w1NRvEGtQCD/colgzPjmQD3RAHNuLVkv9yl3lsm1J8KrxBtQp9lDRXaX+NPU
         zSFAUpuEzCDlfZE+zMc/it6R0f7KGLJosQLPGx9rdxoIF7CTwgM2YmcgE2/t4oJEoL/o
         FYEH7o9MvMUXQEZLPJ3dgk0R5Iq7GYqtLC0awkqrE9M751Q97M9Djx7mpbe1RqpJtnTg
         y8RsTS2uLLDGwV8HPHCQDWka6zIx3VRhMuxi6xx0Bh62VcCE41StHGLs8GFsDHT8hsAU
         +3PUsRAtA+KPs8R6muN0ypRKq1Sub/xlx+tL9zqDhWLwNxUuRy5zq4D6TUE16BwUj094
         Bdww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=tFwUwEqGb1rXwUYXN4mNnP93vKgOIcKRDgrGO7DYd+M=;
        b=EDk6QoDqDPzSwGkXEW7HZFpqaGvI80nhNnO93NplaiKjuS0Uuz8PG7ZHpJut0RgXjt
         O79wFDRy399UG1GOO0y8LOj78n69JDqDoInPWmeJfvDrnavmt41NnHGY/AqtDWBkMXgu
         9oe4ZiUmtw288qE4C9+QO2Jzuhx9uUzca5Dlh715iJ7/v4rKHD5hEAA/0LA5NXjyJLO3
         +mBUBuAEL+PaGfG3r5KPaHDk0hcKEa2P4bi4eW8AOUYJE+8Vi2r81bQIZ2c0dyS72OZX
         IYYlxc6qMI/tX3HGPZgGYxeJbm8l2e4RtELyL0zdKukAbDm6k0zu5Qky+W28RSmdwGmt
         yjbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 47si298713edz.370.2019.02.25.03.46.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 03:46:49 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5AF9BAFFB;
	Mon, 25 Feb 2019 11:46:48 +0000 (UTC)
Subject: Re: [RFC PATCH] mm,mremap: Bail out earlier in mremap_to under map
 pressure
To: "Kirill A. Shutemov" <kirill@shutemov.name>,
 Oscar Salvador <osalvador@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-api@vger.kernel.org, hughd@google.com, joel@joelfernandes.org,
 jglisse@redhat.com, yang.shi@linux.alibaba.com, mgorman@techsingularity.net
References: <20190221085406.10852-1-osalvador@suse.de>
 <20190222130125.apa2ysnahgfuj2vx@kshutemo-mobl1>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <cfc53e5a-a403-a732-69d2-1f96b8416f6d@suse.cz>
Date: Mon, 25 Feb 2019 12:46:46 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190222130125.apa2ysnahgfuj2vx@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/22/19 2:01 PM, Kirill A. Shutemov wrote:
> On Thu, Feb 21, 2019 at 09:54:06AM +0100, Oscar Salvador wrote:
>> When using mremap() syscall in addition to MREMAP_FIXED flag,
>> mremap() calls mremap_to() which does the following:
>>
>> 1) unmaps the destination region where we are going to move the map
>> 2) If the new region is going to be smaller, we unmap the last part
>>    of the old region
>>
>> Then, we will eventually call move_vma() to do the actual move.
>>
>> move_vma() checks whether we are at least 4 maps below max_map_count
>> before going further, otherwise it bails out with -ENOMEM.
>> The problem is that we might have already unmapped the vma's in steps
>> 1) and 2), so it is not possible for userspace to figure out the state
>> of the vma's after it gets -ENOMEM, and it gets tricky for userspace
>> to clean up properly on error path.
>>
>> While it is true that we can return -ENOMEM for more reasons
>> (e.g: see may_expand_vm() or move_page_tables()), I think that we can
>> avoid this scenario in concret if we check early in mremap_to() if the
>> operation has high chances to succeed map-wise.
>>
>> Should not be that the case, we can bail out before we even try to unmap
>> anything, so we make sure the vma's are left untouched in case we are likely
>> to be short of maps.
>>
>> The thumb-rule now is to rely on the worst-scenario case we can have.
>> That is when both vma's (old region and new region) are going to be split
>> in 3, so we get two more maps to the ones we already hold (one per each).
>> If current map count + 2 maps still leads us to 4 maps below the threshold,
>> we are going to pass the check in move_vma().
>>
>> Of course, this is not free, as it might generate false positives when it is
>> true that we are tight map-wise, but the unmap operation can release several
>> vma's leading us to a good state.
>>
>> Because of that I am sending this as a RFC.
>> Another approach was also investigated [1], but it may be too much hassle
>> for what it brings.
> 
> I believe we don't need the check in move_vma() with this patch. Or do we?

move_vma() can be also called directly from SYSCALL_DEFINE5(mremap) for
the non-MMAP_FIXED case. So unless there's further refactoring, the
check is still needed.

>>
>> [1] https://lore.kernel.org/lkml/20190219155320.tkfkwvqk53tfdojt@d104.suse.de/
>>
>> Signed-off-by: Oscar Salvador <osalvador@suse.de>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

