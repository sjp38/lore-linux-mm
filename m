Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C58BAC282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 15:52:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C6122175B
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 15:52:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C6122175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CFE98E0002; Tue, 29 Jan 2019 10:52:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2803A8E0001; Tue, 29 Jan 2019 10:52:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1489F8E0002; Tue, 29 Jan 2019 10:52:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A956B8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:52:24 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x15so8153265edd.2
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 07:52:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=tWWxSABfpXRajMhk7SnL8Dhl7wtX5UIR/JlHdPavfy8=;
        b=Wr7y1g/wScj0tP7eUZL6OM+XoGltAwgCQUnNj/kMzr98mT82XNRNlYOZU+T7asj6OQ
         1qrMnJp9XqNIXPXMUz4rjzg+CB4JpfTE1245kRGvkyYZ2MmEXLdiidKBUJwGier3gn+n
         64y2XFUX3I4u0AoT44Cu+PS4bS8OOi01+xhbXvwyKxSSXTXidZcHT3xVDlkLf93X3whs
         SyeknK4MH0HFBHhgddyemU5viwB/uDHuoRW8VNjf0qSrm0T7T2heTp+/FdkEyTypltp5
         QLcDDQwsVD5Hlb/Ce8QolaMcFGP3XZt9XHBrAE75TJG/9J6RUwWCVCZFZwRBhvtBS8E8
         xIEA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AJcUukdJi3OvIP8RWRi/YsBA847/FUW5yycJMrrO6L6ykvkhscPHXsLw
	brhXyM3YeOqQp/fzgHfJQ7AgxcSNsGNttNHEO9jj9roAmk4FHFChDZr3MPLnHUELSd1dNCiEDkC
	qRvX5Xu3S8eW6JNoNP0ahVFXnMm5RO2J4Sit5wgW1P7JojMYMVit1V/TxNITciFaipQ==
X-Received: by 2002:a50:b4f1:: with SMTP id x46mr26515805edd.289.1548777144258;
        Tue, 29 Jan 2019 07:52:24 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4+z6g/Rs5MtyocrVdOAq/0picdicqILPxav8WdZCeK7XuzWzNEOTc3uisgeibbAWps/4sf
X-Received: by 2002:a50:b4f1:: with SMTP id x46mr26515758edd.289.1548777143353;
        Tue, 29 Jan 2019 07:52:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548777143; cv=none;
        d=google.com; s=arc-20160816;
        b=DaoEjwXXQN+xGtA4IDNR5TS4rr//tJSaU8PzCTL5Qy8HKt46hsPvt4GpI9EhapFml+
         OipMnVYIf2Rb3IPwcOHKIQTtpskT5PiGDzH+uyJ9ufklTvTKXa38N1Mjy2yxOXLI76Tu
         9gA+1novZ+63hlpZw2/TPyhnJT/9xmA1Wo7Y1xyspkeYm1qYamSWauvkjrYXU9Vkxp/0
         T86XDIBUkRRn6skTqqgIVS36OYgZbKxmJKIYznWAuMuRQEWLGwbANmlE1m8LP3nqYSA0
         hPBYsFPm/Nr3uOikkd6UDDZTFh0g/luVKWwq+qKn2mbYfnm+EQ7dvU2E5b3rjkOFJ4bw
         kegw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=tWWxSABfpXRajMhk7SnL8Dhl7wtX5UIR/JlHdPavfy8=;
        b=sZeuNQrEHP2VH7LEZAFDaJ6J0yx6LYc4AgQ5ByZr9mhhuSsa9cHOt7uRTHLI7c2VEq
         iA1Si/lNigi7Ij4EmOrMzFR1ODROLzHXPkztArSvCljFCq0chnGihjf2jeKA2V+HnV/Z
         8MY+OBDp0WEwTr4vAY8RHg8Qy/zfIXYfhIdbBSH9axq/tRe+Y38/ioQ+WhCVyHngnY6v
         Sk5c53JhaM2HwflPWfVeBRLCpizLj9zef13bJCv+NGHRVYGC54JG0r5SD2ObKlqT+tTC
         N1a8eJ/niSgZh9Qi8lbBEND1EUpQuWQ11Ex6hSCWZqtlgnIEZa3UZWYQ/WE32BSyN6Ru
         Ti1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n9-v6si2655258ejk.117.2019.01.29.07.52.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 07:52:23 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D88CDB11F;
	Tue, 29 Jan 2019 15:52:22 +0000 (UTC)
Subject: Re: [PATCH] mm: proc: smaps_rollup: Fix pss_locked calculation
To: Andrew Morton <akpm@linux-foundation.org>,
 Sandeep Patil <sspatil@android.com>
Cc: adobriyan@gmail.com, avagin@openvz.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org,
 kernel-team@android.com, dancol@google.com
References: <20190121011049.160505-1-sspatil@android.com>
 <20190128161509.5085cacf939463f1c22e0550@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b15205cd-33e3-6cac-b6a4-65266be7a9c8@suse.cz>
Date: Tue, 29 Jan 2019 16:52:21 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190128161509.5085cacf939463f1c22e0550@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/29/19 1:15 AM, Andrew Morton wrote:
> On Sun, 20 Jan 2019 17:10:49 -0800 Sandeep Patil <sspatil@android.com> wrote:
> 
>> The 'pss_locked' field of smaps_rollup was being calculated incorrectly
>> as it accumulated the current pss everytime a locked VMA was found.
>> 
>> Fix that by making sure we record the current pss value before each VMA
>> is walked. So, we can only add the delta if the VMA was found to be
>> VM_LOCKED.
>> 
>> ...
>>
>> --- a/fs/proc/task_mmu.c
>> +++ b/fs/proc/task_mmu.c
>> @@ -709,6 +709,7 @@ static void smap_gather_stats(struct vm_area_struct *vma,
>>  #endif
>>  		.mm = vma->vm_mm,
>>  	};
>> +	unsigned long pss;
>>  
>>  	smaps_walk.private = mss;
>>  
>> @@ -737,11 +738,12 @@ static void smap_gather_stats(struct vm_area_struct *vma,
>>  		}
>>  	}
>>  #endif
>> -
>> +	/* record current pss so we can calculate the delta after page walk */
>> +	pss = mss->pss;
>>  	/* mmap_sem is held in m_start */
>>  	walk_page_vma(vma, &smaps_walk);
>>  	if (vma->vm_flags & VM_LOCKED)
>> -		mss->pss_locked += mss->pss;
>> +		mss->pss_locked += mss->pss - pss;
>>  }
> 
> This seems to be a rather obscure way of accumulating
> mem_size_stats.pss_locked.  Wouldn't it make more sense to do this in
> smaps_account(), wherever we increment mem_size_stats.pss?
> 
> It would be a tiny bit less efficient but I think that the code cleanup
> justifies such a cost?

Yeah, Sandeep could you add 'bool locked' param to smaps_account() and check it
there? We probably don't need the whole vma param yet.

Thanks.

