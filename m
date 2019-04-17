Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7E3CC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 12:07:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 631B9206BA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 12:07:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 631B9206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EFAC6B0003; Wed, 17 Apr 2019 08:07:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0788A6B0006; Wed, 17 Apr 2019 08:07:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E82C26B0007; Wed, 17 Apr 2019 08:07:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 94B196B0003
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 08:07:39 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f42so7411766edd.0
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 05:07:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=9EEEjioMNhgtR3XDpWQkgiV6FEqwUwcY9ZGajU+PBmk=;
        b=CQkQ7J6tjLVLHQN0XeapH1rfvTWe6QnhmEmSH5Dt0tdSrEoh2mvJxrofTrmR6W6Cc/
         FycHFifXCQUw98KS3ZIw9QKobSpgvLg1yFJkAnLVh8zdictON+tW/0Y2pcAaC7vFpqUI
         8r+BMGfjA6/WrxMrCIB4u1FXa/anFlTcnumVk/W641J/HMonMCVaVsMlv8sLPlfSfb/3
         Sx6M7XDOZLtAjUGhvbtNMqLdu1amSQ4hkhE+nDGh2dnRcBEqqpRU9P+zPmlMaoqm1ett
         FuX+Hf2fgiGR7mc4VH6hyLRut4s53gcz9XowEnTrjYqNSejzjl6+POAH1RwaRZcaG2UV
         fI4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAWW9G0gBE8dAze/Z+cfGF03EBrc0mDz2wOKbLAn69pt1FWcwTPy
	zi9NbeX0+e2yJS+FDOL5uZkFwoi6Mb4prX8CFecm1B5dWVlEL4FXPqlLt5Ov5qTXRQyf/9NEuyB
	K+nn5hydZ+fQcq7Cv2XzDRUQYh8BS910vrTh0txp5ApfFM0U8R7KoFxl3KCrRPr285g==
X-Received: by 2002:a17:906:eb96:: with SMTP id mh22mr24035415ejb.186.1555502859135;
        Wed, 17 Apr 2019 05:07:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTYDli3fZYxrkM7D9RQJkBQ0cLqLNevULN7VKrqWCWaOfNBaUJXEshW3eZ8pavFMh2WpZZ
X-Received: by 2002:a17:906:eb96:: with SMTP id mh22mr24035380ejb.186.1555502858307;
        Wed, 17 Apr 2019 05:07:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555502858; cv=none;
        d=google.com; s=arc-20160816;
        b=m5c3AYRUWPjaupbzu53FjMoXGtKXgEtv7Bfu5eH5ur8+afZMjIZaW+H6SdCtE3muEV
         vI5Srdu4tSS0stOEogLGqIUOeRBhClbQb0X2jPITPoIY7QG84AFc9PDvyPCJ6joG5pRf
         pSpgDkUUJACdrhxXJohl88yRunZLFV+RGMlwKr2cLD6pYLpCa5LsEpbhGOuxA3CtVfEa
         lHqoi1uoWSAIX2z8wHmqPdwvRAjvGBPLISKfslpkks8+smvwBKEJJUJmr9U0I0KmJuVi
         zsP3a6pfXtzSlRh7vD1FaLjIn6YS270LtEDGE/gM/wI/Ljd4VCt9OitYWAez96u6qkFk
         tJmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=9EEEjioMNhgtR3XDpWQkgiV6FEqwUwcY9ZGajU+PBmk=;
        b=Tbenk9x4kkB8M/i7Vmw53ZMLb4Wyj+Wv8NxLyMnfC3Ixr/dkrBnR0vyAUDd4ikIQrn
         K1FVHuKBabsivIaHrq2W6p7Oc2KZgfj3L57Aetetc/SpJxRqx0RuI2N9bqMMVO5j5nvE
         dt0MXXShPXoX31M05hEy03pUS82UOFXM/AESMMq4NJFk6GQBt3M0+0c0Zzgl4BR0v8x/
         UtzmFI0vHbsby/LUyQToecLXp7FIokwvde3EhXFl8MmfVcXbf5ZbfZpqfTRPMFATXZcq
         uAvwOLJbjA5igNmBpnRjkJhL2/yrv43otvJZ9nTSvDRW37efsTP8d5qSTQRANTYGWL9G
         C9Iw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e31si684753ede.102.2019.04.17.05.07.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 05:07:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7AF31AFFC;
	Wed, 17 Apr 2019 12:07:37 +0000 (UTC)
Subject: Re: [PATCH] mm: fix false-positive OVERCOMMIT_GUESS failures
To: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Kernel Team <Kernel-team@fb.com>
References: <20190412191418.26333-1-hannes@cmpxchg.org>
 <20190412200629.GA24377@tower.DHCP.thefacebook.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 mQINBFZdmxYBEADsw/SiUSjB0dM+vSh95UkgcHjzEVBlby/Fg+g42O7LAEkCYXi/vvq31JTB
 KxRWDHX0R2tgpFDXHnzZcQywawu8eSq0LxzxFNYMvtB7sV1pxYwej2qx9B75qW2plBs+7+YB
 87tMFA+u+L4Z5xAzIimfLD5EKC56kJ1CsXlM8S/LHcmdD9Ctkn3trYDNnat0eoAcfPIP2OZ+
 9oe9IF/R28zmh0ifLXyJQQz5ofdj4bPf8ecEW0rhcqHfTD8k4yK0xxt3xW+6Exqp9n9bydiy
 tcSAw/TahjW6yrA+6JhSBv1v2tIm+itQc073zjSX8OFL51qQVzRFr7H2UQG33lw2QrvHRXqD
 Ot7ViKam7v0Ho9wEWiQOOZlHItOOXFphWb2yq3nzrKe45oWoSgkxKb97MVsQ+q2SYjJRBBH4
 8qKhphADYxkIP6yut/eaj9ImvRUZZRi0DTc8xfnvHGTjKbJzC2xpFcY0DQbZzuwsIZ8OPJCc
 LM4S7mT25NE5kUTG/TKQCk922vRdGVMoLA7dIQrgXnRXtyT61sg8PG4wcfOnuWf8577aXP1x
 6mzw3/jh3F+oSBHb/GcLC7mvWreJifUL2gEdssGfXhGWBo6zLS3qhgtwjay0Jl+kza1lo+Cv
 BB2T79D4WGdDuVa4eOrQ02TxqGN7G0Biz5ZLRSFzQSQwLn8fbwARAQABtCBWbGFzdGltaWwg
 QmFia2EgPHZiYWJrYUBzdXNlLmN6PokCVAQTAQoAPgIbAwULCQgHAwUVCgkICwUWAgMBAAIe
 AQIXgBYhBKlA1DSZLC6OmRA9UCJPp+fMgqZkBQJcbbyGBQkH8VTqAAoJECJPp+fMgqZkpGoP
 /1jhVihakxw1d67kFhPgjWrbzaeAYOJu7Oi79D8BL8Vr5dmNPygbpGpJaCHACWp+10KXj9yz
 fWABs01KMHnZsAIUytVsQv35DMMDzgwVmnoEIRBhisMYOQlH2bBn/dqBjtnhs7zTL4xtqEcF
 1hoUFEByMOey7gm79utTk09hQE/Zo2x0Ikk98sSIKBETDCl4mkRVRlxPFl4O/w8dSaE4eczH
 LrKezaFiZOv6S1MUKVKzHInonrCqCNbXAHIeZa3JcXCYj1wWAjOt9R3NqcWsBGjFbkgoKMGD
 usiGabetmQjXNlVzyOYdAdrbpVRNVnaL91sB2j8LRD74snKsV0Wzwt90YHxDQ5z3M75YoIdl
 byTKu3BUuqZxkQ/emEuxZ7aRJ1Zw7cKo/IVqjWaQ1SSBDbZ8FAUPpHJxLdGxPRN8Pfw8blKY
 8mvLJKoF6i9T6+EmlyzxqzOFhcc4X5ig5uQoOjTIq6zhLO+nqVZvUDd2Kz9LMOCYb516cwS/
 Enpi0TcZ5ZobtLqEaL4rupjcJG418HFQ1qxC95u5FfNki+YTmu6ZLXy+1/9BDsPuZBOKYpUm
 3HWSnCS8J5Ny4SSwfYPH/JrtberWTcCP/8BHmoSpS/3oL3RxrZRRVnPHFzQC6L1oKvIuyXYF
 rkybPXYbmNHN+jTD3X8nRqo+4Qhmu6SHi3VquQENBFsZNQwBCACuowprHNSHhPBKxaBX7qOv
 KAGCmAVhK0eleElKy0sCkFghTenu1sA9AV4okL84qZ9gzaEoVkgbIbDgRbKY2MGvgKxXm+kY
 n8tmCejKoeyVcn9Xs0K5aUZiDz4Ll9VPTiXdf8YcjDgeP6/l4kHb4uSW4Aa9ds0xgt0gP1Xb
 AMwBlK19YvTDZV5u3YVoGkZhspfQqLLtBKSt3FuxTCU7hxCInQd3FHGJT/IIrvm07oDO2Y8J
 DXWHGJ9cK49bBGmK9B4ajsbe5GxtSKFccu8BciNluF+BqbrIiM0upJq5Xqj4y+Xjrpwqm4/M
 ScBsV0Po7qdeqv0pEFIXKj7IgO/d4W2bABEBAAGJA3IEGAEKACYWIQSpQNQ0mSwujpkQPVAi
 T6fnzIKmZAUCWxk1DAIbAgUJA8JnAAFACRAiT6fnzIKmZMB0IAQZAQoAHRYhBKZ2GgCcqNxn
 k0Sx9r6Fd25170XjBQJbGTUMAAoJEL6Fd25170XjDBUH/2jQ7a8g+FC2qBYxU/aCAVAVY0NE
 YuABL4LJ5+iWwmqUh0V9+lU88Cv4/G8fWwU+hBykSXhZXNQ5QJxyR7KWGy7LiPi7Cvovu+1c
 9Z9HIDNd4u7bxGKMpn19U12ATUBHAlvphzluVvXsJ23ES/F1c59d7IrgOnxqIcXxr9dcaJ2K
 k9VP3TfrjP3g98OKtSsyH0xMu0MCeyewf1piXyukFRRMKIErfThhmNnLiDbaVy6biCLx408L
 Mo4cCvEvqGKgRwyckVyo3JuhqreFeIKBOE1iHvf3x4LU8cIHdjhDP9Wf6ws1XNqIvve7oV+w
 B56YWoalm1rq00yUbs2RoGcXmtX1JQ//aR/paSuLGLIb3ecPB88rvEXPsizrhYUzbe1TTkKc
 4a4XwW4wdc6pRPVFMdd5idQOKdeBk7NdCZXNzoieFntyPpAq+DveK01xcBoXQ2UktIFIsXey
 uSNdLd5m5lf7/3f0BtaY//f9grm363NUb9KBsTSnv6Vx7Co0DWaxgC3MFSUhxzBzkJNty+2d
 10jvtwOWzUN+74uXGRYSq5WefQWqqQNnx+IDb4h81NmpIY/X0PqZrapNockj3WHvpbeVFAJ0
 9MRzYP3x8e5OuEuJfkNnAbwRGkDy98nXW6fKeemREjr8DWfXLKFWroJzkbAVmeIL0pjXATxr
 +tj5JC0uvMrrXefUhXTo0SNoTsuO/OsAKOcVsV/RHHTwCDR2e3W8mOlA3QbYXsscgjghbuLh
 J3oTRrOQa8tUXWqcd5A0+QPo5aaMHIK0UAthZsry5EmCY3BrbXUJlt+23E93hXQvfcsmfi0N
 rNh81eknLLWRYvMOsrbIqEHdZBT4FHHiGjnck6EYx/8F5BAZSodRVEAgXyC8IQJ+UVa02QM5
 D2VL8zRXZ6+wARKjgSrW+duohn535rG/ypd0ctLoXS6dDrFokwTQ2xrJiLbHp9G+noNTHSan
 ExaRzyLbvmblh3AAznb68cWmM3WVkceWACUalsoTLKF1sGrrIBj5updkKkzbKOq5gcC5AQ0E
 Wxk1NQEIAJ9B+lKxYlnKL5IehF1XJfknqsjuiRzj5vnvVrtFcPlSFL12VVFVUC2tT0A1Iuo9
 NAoZXEeuoPf1dLDyHErrWnDyn3SmDgb83eK5YS/K363RLEMOQKWcawPJGGVTIRZgUSgGusKL
 NuZqE5TCqQls0x/OPljufs4gk7E1GQEgE6M90Xbp0w/r0HB49BqjUzwByut7H2wAdiNAbJWZ
 F5GNUS2/2IbgOhOychHdqYpWTqyLgRpf+atqkmpIJwFRVhQUfwztuybgJLGJ6vmh/LyNMRr8
 J++SqkpOFMwJA81kpjuGR7moSrUIGTbDGFfjxmskQV/W/c25Xc6KaCwXah3OJ40AEQEAAYkC
 PAQYAQoAJhYhBKlA1DSZLC6OmRA9UCJPp+fMgqZkBQJbGTU1AhsMBQkDwmcAAAoJECJPp+fM
 gqZkPN4P/Ra4NbETHRj5/fM1fjtngt4dKeX/6McUPDIRuc58B6FuCQxtk7sX3ELs+1+w3eSV
 rHI5cOFRSdgw/iKwwBix8D4Qq0cnympZ622KJL2wpTPRLlNaFLoe5PkoORAjVxLGplvQIlhg
 miljQ3R63ty3+MZfkSVsYITlVkYlHaSwP2t8g7yTVa+q8ZAx0NT9uGWc/1Sg8j/uoPGrctml
 hFNGBTYyPq6mGW9jqaQ8en3ZmmJyw3CHwxZ5FZQ5qc55xgshKiy8jEtxh+dgB9d8zE/S/UGI
 E99N/q+kEKSgSMQMJ/CYPHQJVTi4YHh1yq/qTkHRX+ortrF5VEeDJDv+SljNStIxUdroPD29
 2ijoaMFTAU+uBtE14UP5F+LWdmRdEGS1Ah1NwooL27uAFllTDQxDhg/+LJ/TqB8ZuidOIy1B
 xVKRSg3I2m+DUTVqBy7Lixo73hnW69kSjtqCeamY/NSu6LNP+b0wAOKhwz9hBEwEHLp05+mj
 5ZFJyfGsOiNUcMoO/17FO4EBxSDP3FDLllpuzlFD7SXkfJaMWYmXIlO0jLzdfwfcnDzBbPwO
 hBM8hvtsyq8lq8vJOxv6XD6xcTtj5Az8t2JjdUX6SF9hxJpwhBU0wrCoGDkWp4Bbv6jnF7zP
 Nzftr4l8RuJoywDIiJpdaNpSlXKpj/K6KrnyAI/joYc7
Message-ID: <0d2ad7c1-4a5f-08b0-0f57-0273fedc4f70@suse.cz>
Date: Wed, 17 Apr 2019 14:04:17 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190412200629.GA24377@tower.DHCP.thefacebook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/12/19 10:06 PM, Roman Gushchin wrote:
> On Fri, Apr 12, 2019 at 03:14:18PM -0400, Johannes Weiner wrote:
>> With the default overcommit==guess we occasionally run into mmap
>> rejections despite plenty of memory that would get dropped under
>> pressure but just isn't accounted reclaimable. One example of this is
>> dying cgroups pinned by some page cache. A previous case was auxiliary
>> path name memory associated with dentries; we have since annotated
>> those allocations to avoid overcommit failures (see d79f7aa496fc ("mm:
>> treat indirectly reclaimable memory as free in overcommit logic")).
>>
>> But trying to classify all allocated memory reliably as reclaimable
>> and unreclaimable is a bit of a fool's errand. There could be a myriad
>> of dependencies that constantly change with kernel versions.

Just wondering, did you find at least one another reclaimable case like
those path names?

>> It becomes even more questionable of an effort when considering how
>> this estimate of available memory is used: it's not compared to the
>> system-wide allocated virtual memory in any way. It's not even
>> compared to the allocating process's address space. It's compared to
>> the single allocation request at hand!
>>
>> So we have an elaborate left-hand side of the equation that tries to
>> assess the exact breathing room the system has available down to a
>> page - and then compare it to an isolated allocation request with no
>> additional context. We could fail an allocation of N bytes, but for
>> two allocations of N/2 bytes we'd do this elaborate dance twice in a
>> row and then still let N bytes of virtual memory through. This doesn't
>> make a whole lot of sense.
>>
>> Let's take a step back and look at the actual goal of the
>> heuristic. From the documentation:
>>
>>    Heuristic overcommit handling. Obvious overcommits of address
>>    space are refused. Used for a typical system. It ensures a
>>    seriously wild allocation fails while allowing overcommit to
>>    reduce swap usage.  root is allowed to allocate slightly more
>>    memory in this mode. This is the default.
>>
>> If all we want to do is catch clearly bogus allocation requests
>> irrespective of the general virtual memory situation, the physical
>> memory counter-part doesn't need to be that complicated, either.
>>
>> When in GUESS mode, catch wild allocations by comparing their request
>> size to total amount of ram and swap in the system.
>>
>> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> My 2c here: any kinds of percpu counters and percpu data is accounted
> as unreclaimable and can alter the calculation significantly.
> 
> This is a special problem on hosts, which were idle for some time.
> Without any memory pressure, kernel caches do occupy most of the memory,
> so than a following attempt to start a workload fails.

So then we remove the kmalloc-reclaimable caches again as not worth the
trouble anymore (they might be useful for anti-fragmentation purposes,
but that's much harder to quantify), or what?

> With a big pleasure:
> Acked-by: Roman Gushchin <guro@fb.com>
> 
> Thanks!
> 

