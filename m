Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E70AC10F0B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:24:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D628921479
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:24:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D628921479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 736986B0005; Thu, 18 Apr 2019 01:24:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BDAC6B0007; Thu, 18 Apr 2019 01:24:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5867A6B0008; Thu, 18 Apr 2019 01:24:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 04B256B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 01:24:40 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k56so640745edb.2
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:24:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=KOswaRWRUemI8S/gquiofczxdNhkxEeSj4E8YC19lcI=;
        b=hzBpbhdeBjNUqdFf+97605hE8Xl6omnlTErSdjh6CI9Pl/Lz1hQJh9pWQjfF9uOL6J
         TmUTkSnk+5xjZLiOcVdjdSNRCkYPE1GHV8izo+AL1QrgTa+bJoup4c6Ju410ljIqtybA
         s7u25DglCV2/RWJg3mtzETf+5SBgnd/7eJb7qooDoYNsR9a3NZCoQshnkP40wKj/4Dbs
         pcm2FOESm1zKHZGr+Krl+6xpAuFSQkT8BMIXVmK0ZkXGEyn8vIpT8OVWSoV3GRS8uqm7
         zc0YlkHxzh8qEmTfaZgxdBnLloOVXv2DiYYhRUxpM3UV/KtA7+CEGefhvDgYqaCEgwVX
         4oDw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWpiVQazEYkMhe9khy6GVkCluZaC7KaRorNsMkpWL/wxv6hzMnR
	nCcDDeIw40QwJP7UV+QHnLvBx3bQe8ib59rmvkUtd9Xfqz31f5r4B4cIw2xTr6AE2d6fGmzDKWe
	eJBW8iW2LU7nj815zTjeiBbYyyIvPjTmGuWU56EC9VlQo/IBBZhKGv9zgNsP1tu8=
X-Received: by 2002:a50:e718:: with SMTP id a24mr43288542edn.63.1555565079551;
        Wed, 17 Apr 2019 22:24:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEaJwkG0MHHzIrFSGEqmrm1uqd2wTzp02guK36sZyKiJG87xOl/6EMSU48OpZYwgXipzU7
X-Received: by 2002:a50:e718:: with SMTP id a24mr43288504edn.63.1555565078769;
        Wed, 17 Apr 2019 22:24:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555565078; cv=none;
        d=google.com; s=arc-20160816;
        b=bgqOO8RNfrGjrfUi/MKLvG2cURWfl0NEXzrdKTT5JASgIQdz4fl+C7AhdZpzlJLLVh
         FP6v+pROkjMqndLgpO1Db4lwWDnnx7Pc1SBanTskGgbFcb8hGMOd2Cslyts9aL59vWV/
         Ed9cIu7ZKarKARbMjIPDtlYy8Oa1rwYr0bc20op+9CIj9cAR9qY8Rq5UdYF+nJ8UfN/E
         03XCdPc8ZMAfsRUQ+gn+2Q2mOXjuvp9+bRmal3gCYEEOcljSr5dWq7Qt8qNpeICY+yEA
         RkFZ0bUAoC+7kqZUd6Y62k6on+6J+QV99VSIwv5pvalaLoETQY95I/FXlnmE7917T98B
         hlQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=KOswaRWRUemI8S/gquiofczxdNhkxEeSj4E8YC19lcI=;
        b=QqeffsXWnaW9/mK/nvKWJyQATfyscKCDj9w2weJ18FdNLMgloO2mpqVvs5ehztRec1
         voXaUiD1ZGksx6wtAaBuI5AzhAzUv+83znjRHTP1bO/wQ15eBBqcVBg4+T98CnNz6l3r
         1OciHthrcvrPOvoS81OqxSOfjZLhY1ddWor1D178XDU0766gBakG7cLUjf4f+TwkB+gQ
         QHdo2HmRPUn2Hhh0HhQJXaYh8UiHwmRE2WQzIPeu3Wr7ljr/dnDJjhEr9mXiHE7x50So
         Uozl3Y5FkiMA74e08AI/gW9Lw2BbRCe+hH3SzXqNTP1HQmZXMBG9gliF8gj3jjS9L7qp
         yzgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay1-d.mail.gandi.net (relay1-d.mail.gandi.net. [217.70.183.193])
        by mx.google.com with ESMTPS id p15si616899ejl.11.2019.04.17.22.24.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 22:24:38 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.11] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay1-d.mail.gandi.net (Postfix) with ESMTPSA id 42730240002;
	Thu, 18 Apr 2019 05:24:33 +0000 (UTC)
Subject: Re: [PATCH v3 03/11] arm64: Consider stack randomization for mmap
 base only when necessary
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
 <hch@lst.de>, Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>,
 Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
 Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Luis Chamberlain <mcgrof@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
 linux-mips@vger.kernel.org, linux-riscv@lists.infradead.org,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>
References: <20190417052247.17809-1-alex@ghiti.fr>
 <20190417052247.17809-4-alex@ghiti.fr>
 <CAGXu5jKo26zXw=jfKSzr_pnfx5Zux+fVbY7V9bJwEMApDcFi8w@mail.gmail.com>
From: Alex Ghiti <alex@ghiti.fr>
Message-ID: <b2d80348-a3d4-ffcc-d174-0a7a244dae0b@ghiti.fr>
Date: Thu, 18 Apr 2019 01:24:32 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAGXu5jKo26zXw=jfKSzr_pnfx5Zux+fVbY7V9bJwEMApDcFi8w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: sv-FI
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/18/19 12:37 AM, Kees Cook wrote:
> On Wed, Apr 17, 2019 at 12:26 AM Alexandre Ghiti <alex@ghiti.fr> wrote:
>> Do not offset mmap base address because of stack randomization if
>> current task does not want randomization.
> Maybe mention that this makes this logic match the existing x86 behavior too?


Ok I will add this in case of a v4.


>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Acked-by: Kees Cook <keescook@chromium.org>

Thanks !


>
> -Kees
>
>> ---
>>   arch/arm64/mm/mmap.c | 6 +++++-
>>   1 file changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
>> index ed4f9915f2b8..ac89686c4af8 100644
>> --- a/arch/arm64/mm/mmap.c
>> +++ b/arch/arm64/mm/mmap.c
>> @@ -65,7 +65,11 @@ unsigned long arch_mmap_rnd(void)
>>   static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
>>   {
>>          unsigned long gap = rlim_stack->rlim_cur;
>> -       unsigned long pad = (STACK_RND_MASK << PAGE_SHIFT) + stack_guard_gap;
>> +       unsigned long pad = stack_guard_gap;
>> +
>> +       /* Account for stack randomization if necessary */
>> +       if (current->flags & PF_RANDOMIZE)
>> +               pad += (STACK_RND_MASK << PAGE_SHIFT);
>>
>>          /* Values close to RLIM_INFINITY can overflow. */
>>          if (gap + pad > gap)
>> --
>> 2.20.1
>>
>

