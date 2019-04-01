Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87C9AC43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 14:11:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D7F620840
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 14:11:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D7F620840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAF936B0008; Mon,  1 Apr 2019 10:11:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C36E96B000A; Mon,  1 Apr 2019 10:11:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB5346B000C; Mon,  1 Apr 2019 10:11:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8320C6B0008
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 10:11:58 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id s70so8650754qka.1
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 07:11:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=ZC6uUWQXI4PEfdsrsQvHbrZCV+D8No1632cdDEK/kKc=;
        b=RJm3VcWW3/N5lBFEHxVc0mQtL6eNj/d2o/Jm3ln+c52wdWagpsb8Lh6VhSNA5I6GdG
         3kEsXVHprAJRgm7M6IopnByni9nEFvI7zzkm2eUaOzuYMyQeBvAtHOtUE+tYkPNWG83M
         DO0YWV2bHSJERWCItwoIPHSM++cl5cLD3NbUHtv55yYQrlzK/o/Cclmpl8dqxK/+FpdI
         jToPNbJ1kY9Cw6CFldHE4lkurO5bSR6bKze+MY+b7vU6FsIwdHcrrMkUfA4/R0kMz5l+
         1wXF7D6UDkqdqEOXGg5VE8SiAj8UwOal2cFNLxRjmMKwFUWnCo3cnhEH4X+H8xnPaq3E
         cnRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVfA461aKyEVrWvHrrGGVKaoc4ZSArLXCW8Fya92Y1D2h5lW1t+
	1Vh041Z0axDY91h8QakipCQZsvZWRI7qDyFFV57N9P2n8Pg7UbaiXkN+YTMQxQok8WwLsFDzf1d
	8yFy6TbEwQmaKt32sF0IZodlJaGdg+uTJ1vNdhRwiAw+VRk0u3hLFyp4wWPmSnkdDEQ==
X-Received: by 2002:ac8:14c:: with SMTP id f12mr54333842qtg.138.1554127918266;
        Mon, 01 Apr 2019 07:11:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTfcU8900Oy4TevVepQmTYjFBN157smlWxyk8jJU7+7RW68q7/S/47ieMILIAhlvsqwkzO
X-Received: by 2002:ac8:14c:: with SMTP id f12mr54333747qtg.138.1554127917197;
        Mon, 01 Apr 2019 07:11:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554127917; cv=none;
        d=google.com; s=arc-20160816;
        b=o1guB47ugcMpTWWhWNNZJfoPvlPK2VQs/AtjoWYeHwSFduaZiWw3AUlppfNqG83JqE
         BPwCe4BarQcrBp7D6HKgEAK/Wc/xlV0LtcnYpM5j0FO0gqY6YVXtZAsm5eLCELsvuF0n
         r92XArPEbvk0gq1UzQLA/7QRcqCyr39nvtCydhiHWQ+ssCVcNC5ApEyHRI1ih+OiD5d/
         cls+/zXh4qI5lIa+kbLFb4J5a20nsD5IG1o2Qlby2msehriJ68Q6X0T2n+Sk4OrTqJTl
         NwXhc9MGo4XBuzvI8M8ibekph35jn0kusD34MWfMnv4xDUk8Z8Nlyqge4g1/G7XwCL+b
         aklw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp
         :references:cc:to:from:subject;
        bh=ZC6uUWQXI4PEfdsrsQvHbrZCV+D8No1632cdDEK/kKc=;
        b=sFTizBPGXf1U/4EBZkng642qANUVWnMwD8PFoEuNyxq2qc692i8UJlnhw5mUG8vsQm
         QgRH/2SL+YSsFteiBgDK1BApT7HjzDr0AwL3pBsoNn02udjhn17u6XkgodktzqWe+kZ5
         fvm60dM+OGzlOZtCgB/1L3FRTUshSjxEONKGXmb8nOmXUYcKsOMtQuoO4uh4p6MxjR5v
         GszFYS5T6ej9w+nm7c/m17lSg2f781xXFjXREbaMcjXIBHZo98IIdgNdOuLWW6nUtX71
         k3/vROd48dhU1vQcNmCwUDangXlbtYmSUjD6bgOdY2A4pmWzfCbq0/2al5mBuUeRgwel
         TOhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j50si2113971qtk.3.2019.04.01.07.11.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 07:11:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5FB7230832F4;
	Mon,  1 Apr 2019 14:11:56 +0000 (UTC)
Received: from [10.36.118.81] (unknown [10.36.118.81])
	by smtp.corp.redhat.com (Postfix) with ESMTP id DC96A5D70E;
	Mon,  1 Apr 2019 14:11:42 +0000 (UTC)
Subject: Re: On guest free page hinting and OOM
From: David Hildenbrand <david@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, pbonzini@redhat.com,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 yang.zhang.wz@gmail.com, riel@surriel.com, dodgen@google.com,
 konrad.wilk@oracle.com, dhildenb@redhat.com, aarcange@redhat.com,
 alexander.duyck@gmail.com
References: <20190329084058-mutt-send-email-mst@kernel.org>
 <f6332928-d6a4-7a75-245d-2c534cf6e710@redhat.com>
 <20190329104311-mutt-send-email-mst@kernel.org>
 <7a3baa90-5963-e6e2-c862-9cd9cc1b5f60@redhat.com>
 <f0ee075d-3e99-efd5-8c82-98d53b9f204f@redhat.com>
 <20190329125034-mutt-send-email-mst@kernel.org>
 <fb23fd70-4f1b-26a8-5ecc-4c14014ef29d@redhat.com>
 <20190401073007-mutt-send-email-mst@kernel.org>
 <29e11829-c9ac-a21b-b2f1-ed833e4ca449@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <dc14a711-a306-d00b-c4ce-c308598ee386@redhat.com>
Date: Mon, 1 Apr 2019 16:11:42 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <29e11829-c9ac-a21b-b2f1-ed833e4ca449@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Mon, 01 Apr 2019 14:11:56 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01.04.19 16:09, David Hildenbrand wrote:
>>> Thinking about your approach, there is one elementary thing to notice:
>>>
>>> Giving the guest pages from the buffer while hinting requests are being
>>> processed means that the guest can and will temporarily make use of more
>>> memory than desired. Essentially up to the point where MADV_FREE is
>>> finally called for the hinted pages.
>>
>> Right - but that seems like exactly the reverse of the issue with the current
>> approach which is guest can temporarily use less memory than desired.
>>
>>> Even then the guest will logicall
>>> make use of more memory than desired until core MM takes pages away.
>>
>> That sounds more like a host issue though. If it wants to
>> it can use e.g. MAD_DONTNEED.
> 
> Indeed. But MADV_DONTNEED is somewhat undesired for performance reasons.
> You want to do the work when swapping not when hinting.
> 
> But what I wanted to say here: Looking at the pure size of your guest
> will at least not help you to identify if more memory than desired will
> be used.
> 
>>
>>> So:
>>> 1) Unmodified guests will make use of more memory than desired.
>>
>> One interesting possibility for this is to add the buffer memory
>> by hotplug after the feature has been negotiated.
>> I agree this sounds complex.
> 
> Yes it is, and it goes into the direction of virtio-mem that essentially
> does that. But bad news: memory hotplug is complicated stuff, both on
> the hypervisor and guest side. And things like NUMA make it more involved.
> 
> But even then, malicious guest can simply fake feature negotiation and
> make use of all hotplugged memory. Won't work, at least not for
> malicious guests.
> 
>>
>> But I have an idea: how about we include the hint size in the
>> num_pages counter? Then unmodified guests put
>> it in the balloon and don't use it. Modified ones
>> will know to use it just for hinting.
> 
> These are the nightmares I was talking about. I would like to decouple
> this feature as far as possible from balloon inflation/deflation.
> Ballooning is 4k based and might have other undesirable side effect.
> Just because somebody wants to use page hinting does not mean he wants
> to use ballooning. Effectively, many people will want to avoid
> ballooning completely by using page hinting for their use case.
> 
>>
>>
>>> 2) Malicious guests will make use of more memory than desired.
>>
>> Well this limitation is fundamental to balloon right?
> 
> Yep, it is the fundamental issue of ballooning. If memory is available
> right from the boot, the system is free to do with it whatever it wants.
> (one of the main things virtio-mem will do differently/better)
> 
>> If host wants to add tracking of balloon memory, it
>> can enforce the limits. So far no one bothered,
>> but maybe with this feature we should start to do that.
> 
> I think I already had endless rants about why this is not possible.
> Ballooning as it is currently implemented by virtio-balloon is broken by
> design. Period. You can and never will be able to distinguish unmodified
> guests from malicious guests. Please don't design new approaches based
> on broken design.
> 
>>
>>> 3) Sane, modified guests will make use of more memory than desired.
>>>
>>> Instead, we could make our life much easier by doing the following:
>>>
>>> 1) Introduce a parameter to cap the amount of memory concurrently hinted
>>> similar like you suggested, just don't consider it a buffer value.
>>> "-device virtio-balloon,hinting_size=1G". This gives us control over the
>>> hinting proceess.
>>>
>>> hinting_size=0 (default) disables hinting
>>>
>>> The admin can tweak the number along with memory requirements of the
>>> guest. We can make suggestions (e.g. calculate depending on #cores,#size
>>> of memory, or simply "1GB")
>>
>> So if it's all up to the guest and for the benefit of the guest, and
>> with no cost/benefit to the host, then why are we supplying this value
>> from the host?
> 
> See 3), the admin has to be aware of hinting behavior.
> 
>>
>>> 2) In the guest, track the size of hints in progress, cap at the
>>> hinting_size.
>>>
>>> 3) Document hinting behavior
>>>
>>> "When hinting is enabled, memory up to hinting_size might temporarily be
>>> removed from your guest in order to be hinted to the hypervisor. This is
>>> only for a very short time, but might affect applications. Consider the
>>> hinting_size when sizing your guest. If your application was tested with
>>> XGB and a hinting size of 1G is used, please configure X+1GB for the
>>> guest. Otherwise, performance degradation might be possible."
>>
>> OK, so let's start with this. Now let us assume that guest follows
>> the advice.  We thus know that 1GB is not needed for guest applications.
>> So why do we want to allow applications to still use this extra memory?
> 
> If the application does not need the 1GB, the 1GB will be hinted to the
> hypervisor and are effectively only a buffer for the OOM scenario.
> (ignoring page cache discussions for now).
> 
> "So why do we want to allow applications to still use this extra memory"
> is the EXACT same issue you have with your buffer approach. Any guest
> can make use of the buffer and you won't be able to detect it. Very same
> problem. Only in your approach, the guest might agree to play nicely by
> not making use of the 1G you provided. Just as if the application does
> not need/use the additional 1GB.
> 
> The interesting thing is most probably: Will the hinting size usually be
> reasonable small? At least I guess a guest with 4TB of RAM will not
> suddenly get a hinting size of hundreds of GB. Most probably also only
> something in the range of 1GB. But this is an interesting question to
> look into.
> 
> Also, if the admin does not care about performance implications when
> already close to hinting, no need to add the additional 1Gb to the ram size.

"close to OOM" is what I meant.


-- 

Thanks,

David / dhildenb

