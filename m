Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32BABC282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 07:22:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E62AE21855
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 07:22:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E62AE21855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E5D36B026B; Fri, 19 Apr 2019 03:22:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 896526B026C; Fri, 19 Apr 2019 03:22:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 785CF6B026D; Fri, 19 Apr 2019 03:22:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 266436B026B
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 03:22:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id j44so1786029eda.11
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 00:22:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=pLbKEWX3KLQG4g9IcO72nGPPB8USEyEFpeVB06WUSPY=;
        b=OuUKBaxuZ2GkLAs/9KRE+FEFjfnUEApq1R1+X874+lwTPVxmnu96EqoHIMb3foappr
         rRWgcf/cjPIHFUfa8uXSpDTg8rkj3v8G7nzFFP27W56ldqpPBbZ3WtUikuniF6hDvib6
         hpng3sarqfB2QuXwM6e0XXdbmsfDii16SrPD68Bzf9AjQ6DAlTsUzMFysI+J8mu4ldvD
         aWKWaXFng/k/mThV6zL4/UzDxY11/JP2D0lnwTN10EBNJB/OPg1y1lYAXxRLrCeZeCLK
         pipACf0IYAh1Xuaars7GLbjeLKk7CDKdF+3mkWLWsJo24OCNlPtSEQyZafIn5i9+MRdf
         Yivg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.230 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWQMzsIwvdblqUe8PKLlYiQmbk1fqmqnByoAvnKO5HXjfCduD7V
	DYQ/CCnndjdWknkWlhZSqWVZ5MSyZUhEPDIBrRDKqOppXvESkcrLr8T0BDAq4EMkfp/xGVLA8rD
	txhGVFFNDT1dez9MzdB6OsAKv3N1TRZR0z7e49WyBx8NvRh3W9HCrgMKOw6erIEw=
X-Received: by 2002:a17:906:fd4:: with SMTP id c20mr1196503ejk.159.1555658533717;
        Fri, 19 Apr 2019 00:22:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhzunCUBRcPY/SlxgGkbsnLwfxr35pFPomhDRt9AR3QqSNtov0ndizDc1y65eJO9ulzC30
X-Received: by 2002:a17:906:fd4:: with SMTP id c20mr1196472ejk.159.1555658532803;
        Fri, 19 Apr 2019 00:22:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555658532; cv=none;
        d=google.com; s=arc-20160816;
        b=N1w594ZyermZ2xHk95kIi1YgjZV+VOQYg5ouPFGeHUeDlRQ6Au2Tyf0qzW8By10hMS
         01QBnJtBqX1pEs8R4f49Ud/7fkozjObzenTuZD9gjjhSpcIYDfnsijr/1aFl/jXMU8kN
         UZtOoQEt8PlBN8+A3HBwT7t61rBcIFYbACBNKXhwxRT4apgIPMT6ciNiwoB3lyvvgTD8
         FsKSTXGmGsKQ8yIMkbNyr+ubqaDi3zU9gnHwNWcD9Jsvp9bzZXgl31WF9ChcVvDRdGp/
         kgkxgoZig2xrc4xcqcPN27ShBv4WYS44nOJAq3QB3O8WS558TWB3wQZz0qf5uBc/fjoh
         viPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=pLbKEWX3KLQG4g9IcO72nGPPB8USEyEFpeVB06WUSPY=;
        b=OvsykTO+wyvcfSL2WQMyegm2Np+VdJILTQodrWBIG5YJsgyXwd4waUBA+29fAWKeuE
         d2vLdiLDb8yrvD5U7BUwGjZWU8z6apzg94fl25lhapHzdHbEGToMk0E/k7NydOZmZ+m2
         EhVVUTuMgV54rn/5T6PlTPdlRSLC/OuAzx3fW3GNQo4ObcfFIX1LgPBArTCZ0Re8Ao4+
         TxI4A5UTAYs1QTyqajNf5ugVvCMSlaWJYNAxQ7ToII4hqq75Priq/P9OIRaQZ7cLL5sA
         12OytM9+AiigDTz2LenAFxcEVweq3bsbujBrLyuV+fntwKjzFZc1SOPFpemSQOAzQ6US
         Xa5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.230 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay10.mail.gandi.net (relay10.mail.gandi.net. [217.70.178.230])
        by mx.google.com with ESMTPS id n22si2055281edq.405.2019.04.19.00.22.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 19 Apr 2019 00:22:12 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.230 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.230;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.230 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay10.mail.gandi.net (Postfix) with ESMTPSA id F1A80240006;
	Fri, 19 Apr 2019 07:21:51 +0000 (UTC)
From: Alex Ghiti <alex@ghiti.fr>
Subject: Re: [PATCH v3 04/11] arm64, mm: Move generic mmap layout functions to
 mm
To: Kees Cook <keescook@chromium.org>
Cc: Albert Ou <aou@eecs.berkeley.edu>,
 Catalin Marinas <catalin.marinas@arm.com>, Palmer Dabbelt
 <palmer@sifive.com>, Will Deacon <will.deacon@arm.com>,
 Russell King <linux@armlinux.org.uk>, Ralf Baechle <ralf@linux-mips.org>,
 LKML <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>,
 Linux-MM <linux-mm@kvack.org>, Paul Burton <paul.burton@mips.com>,
 linux-riscv@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>,
 James Hogan <jhogan@kernel.org>,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>, linux-mips@vger.kernel.org,
 Christoph Hellwig <hch@lst.de>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
 Luis Chamberlain <mcgrof@kernel.org>
References: <20190417052247.17809-1-alex@ghiti.fr>
 <20190417052247.17809-5-alex@ghiti.fr>
 <CAGXu5j+NV7nfQ044kvsqqSrWpuXH5J6aZEbvg7YpxyBFjdAHyw@mail.gmail.com>
 <fd2b02b3-5872-ccf6-9f52-53f692fba02d@ghiti.fr>
 <CAGXu5j+NkQ+nwRShuKeHMwuy6++3x0QMS9djE=wUzUUtAkVf3g@mail.gmail.com>
Message-ID: <365fe520-b14a-c792-9961-c18f79edfe13@ghiti.fr>
Date: Fri, 19 Apr 2019 09:20:36 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.5.2
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+NkQ+nwRShuKeHMwuy6++3x0QMS9djE=wUzUUtAkVf3g@mail.gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/18/19 10:19 AM, Kees Cook wrote:
> On Thu, Apr 18, 2019 at 12:55 AM Alex Ghiti <alex@ghiti.fr> wrote:
>> Regarding the help text, I agree that it does not seem to be frequent to
>> place
>> comment above config like that, I'll let Christoph and you decide what's
>> best. And I'll
>> add the possibility for the arch to define its own STACK_RND_MASK.
> Yeah, I think it's very helpful to spell out the requirements for new
> architectures with these kinds of features in the help text (see
> SECCOMP_FILTER for example).
>
>>> I think CONFIG_ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT should select
>>> CONFIG_ARCH_HAS_ELF_RANDOMIZE. It would mean moving
>>
>> I don't think we should link those 2 features together: an architecture
>> may want
>> topdown mmap and don't care about randomization right ?
> Given that the mmap randomization and stack randomization are already
> coming along for the ride, it seems weird to make brk randomization an
> optional feature (especially since all the of the architectures you're
> converting include it). I'd also like these kinds of security features
> to be available by default. So, I think one patch to adjust the MIPS
> brk randomization entropy and then you can just include it in this
> move.


Ok that makes sense, and that would bring support for randomization to
riscv at the same time, so I'll look into it, thanks.


>> Actually, I had to add those ifdefs for mmap_rnd_compat_bits, not
>> is_compat_task.
> Oh! In that case, use CONFIG_HAVE_ARCH_MMAP_RND_BITS. :) Actually,
> what would be maybe cleaner would be to add mmap_rnd_bits_min/max
> consts set to 0 for the non-CONFIG_HAVE_ARCH_MMAP_RND_BITS case at the
> top of mm/mmap.c.


Ok I'll do that.


>
> I really like this clean-up! I think we can move x86 to it too without
> too much pain. :)
>

Yeah I think too, I will do that too.


Thanks again,


Alex


