Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34022C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 13:18:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCA9B2166E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 13:18:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="Ga0F0K7E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCA9B2166E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 552826B0005; Wed, 19 Jun 2019 09:18:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 502B38E0002; Wed, 19 Jun 2019 09:18:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CB0D8E0001; Wed, 19 Jun 2019 09:18:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id E54526B0005
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 09:18:44 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id b67so1707093wmd.0
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 06:18:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=qiE5blyrEXjR+EvN4cIOjdw+vmQhFfJ4XznqchvkiBE=;
        b=C5P1J0oJhGyyQ4NMhRSMQYxCxQUe0c1MSE/eeVh1vZNbje3eIIouQkUVumos29PsZo
         F95aDJgYpbh/hmMSG0LkKcW6XeXLhpRPS14/iT4gG5ibEoaEj5mjXxmUKefYJTbpCZRF
         yOmc5cC9CeNLNnWQo4TnoIZSIychUqbelej5mNQiGLuzrHzyfwA7PiasclYwXvrVkKbG
         uiUE8A/TJeEhdToeSXALUZvr9go4qM2BsDoxgKhcbSifiyDPldvwLVwUdDEvIu9aFNn5
         ei3+ITHdjbbkqLyfxrFXLOkAOULPGDyfFobSNaZE/F+eeCIb+bkcNdB5woKWiwNTKiz/
         JebA==
X-Gm-Message-State: APjAAAVLYkSAW8hJdm/jspy9KgncmF580zJ565bp3eVkHzONjVRdNa+V
	AbIa7MHJkCHgSueScOD3Ddcu65jyItDIUuVq3oVP8igzZjATc3Fyvni/gc142yuWeEAmYyoWCdf
	MyLdNgVe0V5E1bbKJaDwy7ps6qyRk1WHswSRWIqtbvoduVVJyheqU0qgriXNQ+WuKPg==
X-Received: by 2002:a5d:548e:: with SMTP id h14mr34989649wrv.76.1560950324510;
        Wed, 19 Jun 2019 06:18:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/WuztuRLJbaBODehH0DCcHFmzx9ZlAb54+8dufBXrArejTbz0S+RrZ8Hna9gFLQmcsrLD
X-Received: by 2002:a5d:548e:: with SMTP id h14mr34989604wrv.76.1560950323774;
        Wed, 19 Jun 2019 06:18:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560950323; cv=none;
        d=google.com; s=arc-20160816;
        b=shxOYPBeMj2vX9ke9hF79tTKfQEQvZ9zvqiJ91uwYLvx9QWKevmtrnFg+oPw3mI9BN
         Rtrd/gDNkhKNzqfHLryGXs21cWdHnB5YgiSnnKDphVDHBGu8Nb1d9i0OS9uZlBVJkvps
         8cStWFHMpFvaRmuajREw61ez15e2dwglhgo4RC1xlZHE6r69309tztuJJJiV9VXKBODA
         2XbeUhNaiRDkd5FqCHl/X20e5a4v3ptFzmoxFdeTwPBOSBx7VsAlCROngbIZbo2kUuXU
         B06UtIkDRtfeeC+ZlMWrH5SPHLlZKLMH5/OBrx7Q15kyPRfh5uF3mcdG7TC7Bx+Nsp6x
         s0Dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=qiE5blyrEXjR+EvN4cIOjdw+vmQhFfJ4XznqchvkiBE=;
        b=VNlmPNO8a/5si4i7dNduFjtqNLdGoKnWmdkxZxXfybUM9c5aeAbemGtGciAOD0msu7
         2ES7ojAnUWiJE3CW6o4/Hc7JNgsAiz7R2zNXEqxadDsYRPIJIOPaUCQp4khQ0PaTVr4d
         4OfCjBS19fiqDxohwDQOJI3o1K8FsEvZpB3k6wn7Rh1Q9XWNhWvF3BujxavxSn+UuAqI
         kf7ViWxfNcf5g814H9YzKfAf2vudcZZb8EKUkrBWmiA4VQk4Z1bRX+QF8qr8DnTSkb4w
         yj9jaXRXkkdvHMsEpb5YF+8bcIGNHtf/cMSy9Kr+7qIjyA09Ap4NL5lEKZUgRgMXGMUl
         JTXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=Ga0F0K7E;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id f15si10567895wrp.75.2019.06.19.06.18.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 06:18:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=Ga0F0K7E;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 45TQWN67qgzB09ZM;
	Wed, 19 Jun 2019 15:18:40 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=Ga0F0K7E; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id eJHKCkKy6Csx; Wed, 19 Jun 2019 15:18:40 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 45TQWN4sgfzB09ZJ;
	Wed, 19 Jun 2019 15:18:40 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1560950320; bh=qiE5blyrEXjR+EvN4cIOjdw+vmQhFfJ4XznqchvkiBE=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=Ga0F0K7E3XoSDkoIpBC50ILQufEvplU5MlC4X6vPhMU1h2lHMVlSrVE5mHAB+nqNC
	 u3xzEP6IH5n8KFFmyPV57vrixG7l5hCWIOZ2C/GfThUKzBI/uYSic2p6jPyCT5mGlK
	 iHsxCiOKvH3UEOSNrHTp85AHc9HB4RkpVmLZLu9A=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 0727F8B92B;
	Wed, 19 Jun 2019 15:18:43 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id KNj3EcPtKvgV; Wed, 19 Jun 2019 15:18:42 +0200 (CEST)
Received: from PO15451 (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A64938B93C;
	Wed, 19 Jun 2019 15:18:42 +0200 (CEST)
Subject: Re: [PATCH 1/4] mm: Move ioremap page table mapping function to mm/
To: Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org
References: <20190610043838.27916-1-npiggin@gmail.com>
 <86991f76-2101-8087-37db-d939d5d744fa@c-s.fr>
 <1560915576.aqf69c3nf8.astroid@bobo.none>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <7218a243-0d9c-ad90-d409-87663893799e@c-s.fr>
Date: Wed, 19 Jun 2019 15:18:29 +0200
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <1560915576.aqf69c3nf8.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 19/06/2019 à 05:43, Nicholas Piggin a écrit :
> Christophe Leroy's on June 11, 2019 3:24 pm:
>>
>>
>> Le 10/06/2019 à 06:38, Nicholas Piggin a écrit :

[snip]

>>> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
>>> index 51e131245379..812bea5866d6 100644
>>> --- a/include/linux/vmalloc.h
>>> +++ b/include/linux/vmalloc.h
>>> @@ -147,6 +147,9 @@ extern struct vm_struct *find_vm_area(const void *addr);
>>>    extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
>>>    			struct page **pages);
>>>    #ifdef CONFIG_MMU
>>> +extern int vmap_range(unsigned long addr,
>>> +		       unsigned long end, phys_addr_t phys_addr, pgprot_t prot,
>>> +		       unsigned int max_page_shift);
>>
>> Drop extern keyword here.
> 
> I don't know if I was going crazy but at one point I was getting
> duplicate symbol errors that were fixed by adding extern somewhere.

probably not on a function name ...

> Maybe sleep depravation. However...
> 
>> As checkpatch tells you, 'CHECK:AVOID_EXTERNS: extern prototypes should
>> be avoided in .h files'
> 
> I prefer to follow existing style in surrounding code at the expense
> of some checkpatch warnings. If somebody later wants to "fix" it
> that's fine.

I don't think that's fine to 'fix' later things that could be done right 
from the begining. 'Cosmetic only' fixes never happen because they are a 
nightmare for backports, and a shame for 'git blame'.

In some patches, you add cleanups to make the code look nicer, and here 
you have the opportunity to make the code nice from the begining and you 
prefer repeating the errors done in the past ? You're surprising me.

Christophe

> 
> Thanks,
> Nick
> 

