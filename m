Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C2E6C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:41:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4348A2077C
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:41:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4348A2077C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D06516B0269; Tue, 16 Apr 2019 07:41:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8E5A6B026A; Tue, 16 Apr 2019 07:41:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B089C6B026B; Tue, 16 Apr 2019 07:41:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5BD926B0269
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:41:09 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o8so10034626edh.12
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 04:41:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=zeBlbP/gZym6awy2ZZe8rnBBQDeZUtuoMJDbwJCbMTI=;
        b=cDYMD3ExlOIjc/T4A/oUUyZzYpZHXaec5ejTNVhFhhSuzVq/gcYpYje4VFzpsT5h/N
         /rX4IVm4VH0IuyUoy5rmZChm7lnlep/patm3/uIn6PEGUTkYVLsQ81FFBuAB232/WB0h
         qfve1fj3U3uKOCIUj/5RTBhyysLmEnLT+W0U7W1aGDwJKM+UCEVurxJz7q5hXfse+4pH
         FLazeWrWtRjA6aYPUfQiqcfab0kQAlbyGe761xkDcxzAv/9gM/+EcEb/26zvfOqMOeE7
         hC/Kq6sCXN5hUiLyfiOHCdcJs634egWSvsfxqYHbg0B79+4GlHvsCtLHQiyarNZH/lu8
         Dkzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAW4uSH0mtKdhCUj4GMtGnMWeZTZ8qRSklDh4Il+wMs3Par9N1Bh
	UMofrVQYv0NY+fCRlKqQhXFafVb1NysljVjl9rPYpnjYFHb6jLZydeZ910yHsSGgU3/rKHbOR6Y
	h24tTXsl8i+L+P05rPd3mNz0XmAPOfGMvVPt7RTJcoFUpezKae5lxebWoM0QfGwORCQ==
X-Received: by 2002:a50:a704:: with SMTP id h4mr49171897edc.7.1555414868904;
        Tue, 16 Apr 2019 04:41:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8KfLu9bHU4SYeTKr6OewUHo+1heenu9HEjQGgPV0tCFF8scLruGXkKC5uOvH1fc7vHDTz
X-Received: by 2002:a50:a704:: with SMTP id h4mr49171841edc.7.1555414867958;
        Tue, 16 Apr 2019 04:41:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555414867; cv=none;
        d=google.com; s=arc-20160816;
        b=WOAhXZYuPUabM3klq6VFh+bFk7gofkpCsylW6zY8L+qd+H/ZprT5xvcAvTrN4Fid9/
         2mP2X8hypkysqCPpPT/CV0QM9AandiAX6uHyDO3fnF5aHVc6lk26CGeP3sfAXHymbKy7
         ILONwcrJExNdv7JRVc26h3vwGG/0c0RrCORNnFvUHClCCT7dQW0I/3mQ89ryIKSyI3nY
         U+bOScdMvVNYELmKxMWy9JpCWVYGpWW0UaG6JCRpNZh87l6Htl+D0PhvgR2ynM/Ev3KH
         z+xFXADvh6kLRz1DopbXUXCDpwqLNhCTSPXNoem9Llxhz74T/phJhwkgZ+KXWjFc/DMm
         xTRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=zeBlbP/gZym6awy2ZZe8rnBBQDeZUtuoMJDbwJCbMTI=;
        b=LIUhpAaeMn53wg8ycSk4OwqTfM61vxUlnWJq2HFxU5oXB5CgHoRmUWsy1ig02NRhFF
         gayqvLV7JdFyAnjd7seVIOvUIlkWICbxh+qJfsfnNQZ1xDo32uskX52SA5vaLOhYhBoO
         LxeyBRGhgP2bzRMf12AJ1LqMVw0dM2VDOzyusdWdv5OzW2lFC+OeHqUx5sWXDeMxma4Z
         oTNb1PiEZzHl4Um6brP6DNvnrokQLRWxjRaNPpmDjXGdWkyyatHM93WDWse4RdOpZflq
         wiAhk/D/pXK9PTwgYAP/SXLAoASv4t0MlV8EaBHZI8/sPg8GJNWTJ/kYOQfY5/Zxzkbl
         rrXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k29si1330378edb.395.2019.04.16.04.41.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 04:41:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 712CEAF8F;
	Tue, 16 Apr 2019 11:41:07 +0000 (UTC)
Subject: Re: [patch V4 01/32] mm/slab: Fix broken stack trace storage
To: Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, LKML
 <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>,
 Sean Christopherson <sean.j.christopherson@intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg
 <penberg@kernel.org>, Linux-MM <linux-mm@kvack.org>,
 David Rientjes <rientjes@google.com>
References: <20190414155936.679808307@linutronix.de>
 <20190414160143.591255977@linutronix.de>
 <CALCETrUhVc_u3HL-x7wMnk9ukEbwQPvc9N5Na-Q55se0VwcCpw@mail.gmail.com>
 <alpine.DEB.2.21.1904141832400.4917@nanos.tec.linutronix.de>
 <alpine.DEB.2.21.1904151101100.1729@nanos.tec.linutronix.de>
 <20190415132339.wiqyzygqklliyml7@treble>
 <alpine.DEB.2.21.1904151804460.1895@nanos.tec.linutronix.de>
 <20190415161657.2zwboghblj5ducux@treble>
 <CALCETrXLa9ec8Lcz2WPML8qQiStpTtDSAGkW=Rv9bMSiunNNMw@mail.gmail.com>
 <alpine.DEB.2.21.1904152320540.1806@nanos.tec.linutronix.de>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <612f9b99-a75b-6aeb-cf92-7dc5421cd950@suse.cz>
Date: Tue, 16 Apr 2019 13:37:48 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1904152320540.1806@nanos.tec.linutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/15/19 11:22 PM, Thomas Gleixner wrote:
> On Mon, 15 Apr 2019, Andy Lutomirski wrote:
>> On Mon, Apr 15, 2019 at 9:17 AM Josh Poimboeuf <jpoimboe@redhat.com> wrote:
>>> On Mon, Apr 15, 2019 at 06:07:44PM +0200, Thomas Gleixner wrote:
>>>>> Looks like stack_trace.nr_entries isn't initialized?  (though this code
>>>>> gets eventually replaced by a later patch)
>>>>
>>>> struct initializer initialized the non mentioned fields to 0, if I'm not
>>>> totally mistaken.
>>>
>>> Hm, it seems you are correct.  And I thought I knew C.
>>>
>>>>> Who actually reads this stack trace?  I couldn't find a consumer.
>>>>
>>>> It's stored directly in the memory pointed to by @addr and that's the freed
>>>> cache memory. If that is used later (UAF) then the stack trace can be
>>>> printed to see where it was freed.
>>>
>>> Right... but who reads it?
>>
>> That seems like a reasonable question.  After some grepping and some
>> git searching, it looks like there might not be any users.  I found
> 
> Anymore. There was something 10y+ ago.

In theory it can be useful in a crash dump. But I don't see any related
debugging
check that would trigger a panic, in order to get one.

>> SLAB_STORE_USER, but that seems to be independent.
>>
>> So maybe the whole mess should just be deleted.  If anyone ever
>> notices, they can re-add it better.
> 
> No objections from my side, but the mm people might have opinions.

Anyone who wants to debug wrong slab usage probably uses SLUB anyway, so
I don't think it's a problem to remove broken SLAB debugging. Perhaps
even SLAB itself will be removed soon if there's performance data
supporting it [1].

[1]
https://lore.kernel.org/linux-mm/20190412112816.GD18914@techsingularity.net/T/#u

> Thanks,
> 
> 	tglx
> 

