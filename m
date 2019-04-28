Return-Path: <SRS0=7ROk=S6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 696BCC43219
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 14:28:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0A762067C
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 14:28:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0A762067C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E68E6B0005; Sun, 28 Apr 2019 10:28:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 897306B0006; Sun, 28 Apr 2019 10:28:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 785666B0007; Sun, 28 Apr 2019 10:28:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 27DAA6B0005
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 10:28:01 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o8so3708770edh.12
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 07:28:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=U4gvHYtR3cZMhjl2n48U193qZV7aNj8fYuONBGQ/OiY=;
        b=EpStsPiLQ2xAuIH6Sv0uUtSndtA+lewaOIkAPubw+DurEE41MeEjlLaJoBQVasZpMA
         5Sw6sDUuFBuowyUpMD53ft5lB0oQy0yNXItFk83cQWVejwa412uZrSJTK7KAapQvmuzk
         Sgzn1Q46TCIp1Pvoo0uV8yFGLgv4QlywXt05CKA2m9OcGq/l9dxc1apypiRKhtABPAeQ
         JbW/if3guxhl4ipuZEy2FmO7QhH6ggigIq+hOJ+9rxJP/snvoKOYc2FQgsOb/FwpOmHU
         eI6VbV3HNCEd3uVpKAM5RNK54ir0MXagBlu5ge6qLjKxd7TDicJC0wOTREgHO6RDVezq
         AEtA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWaPMNk/rhPO9db6nRysj+Z4zEOtNaYVYy43NTsNkPqQ1wrTAIx
	F41e8RV6mT61hc3cYmCvgiBTYLIk+Yik65Nh+JHeV+Bhld+DDXXUIdizX+pvjP/uLJV67JEQC1L
	APu6fflQtEyPseI6OuaYPo2ubKU9hVoYfAW6sPTev76FhlvnkIhaYcurcboUtxPs=
X-Received: by 2002:a17:906:111a:: with SMTP id h26mr14307837eja.281.1556461680516;
        Sun, 28 Apr 2019 07:28:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx75maoWjdXMC1A7np/8BKwlLDkMDGNDcdndpeKS5GbcCZSB8ckEZuvgfqPD+/evvS/23nA
X-Received: by 2002:a17:906:111a:: with SMTP id h26mr14307803eja.281.1556461679317;
        Sun, 28 Apr 2019 07:27:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556461679; cv=none;
        d=google.com; s=arc-20160816;
        b=BUMZCwNKt5HyS69mstztUET7fTKaGTRITk5VQWFEzilaB0XvRvwNqXyLBjrZ2O7Nb0
         158XA8WPTWXau4KwSkK5P24oFjY6T5FFsahynVDroFEYkrogDsTOkNzl3XG0cOMbPnm7
         gBzJrovoNb6mDT8SB/Vv639EzoUUyph85W6/LqExRLvSTiJEiVGz8ktAbEiG9EFBKZ3o
         gon3Gfk9SmfMhkLYLhn+oDvDrSH1GfUxNyu9zbfrkIpNR1YdQlWx0uXWcQNcqrCWr2jj
         P7/8qyjcXAM/YB0JSL8Zt+0fWvCxER7PovHrdUSDBuaQl54tT8Amvt2Ty2FBWR37hP7r
         Yieg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=U4gvHYtR3cZMhjl2n48U193qZV7aNj8fYuONBGQ/OiY=;
        b=O/BxBPcr+PPXfPlwhgX3iIF+PLG9LaiQl7u/4xDEA82x2QnmcbBxm6O079LfMqZxHX
         NNKOpP3YUyQflpdAgGggkE1HYBF7Nj8mxGPcfyhlFtIRo94YIXz2ZE51V+y/6Rr2Ng8+
         b6zIGLQXM2PPKVDTHESo3PtHLQMlT7JmpUuPGVG1j2ZXqfs+4kbWMWgRnpTa6wsTQH4B
         1iepHd6ps3V29mZ9fx4pcc8T1tw3gFDhx61xzNsMcHqS0fQ1OYpkwZ2BbTnJYbWvXO3/
         oT4UEz9hNxqucnTvayURJB6z1jnUdIH1IDLWeJP5QX4nijatLC8vK7+UGy90iM1sFBAY
         8+Ug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id b16si694216ejb.80.2019.04.28.07.27.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 28 Apr 2019 07:27:59 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.12] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 381E61C0005;
	Sun, 28 Apr 2019 14:27:53 +0000 (UTC)
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
From: Alex Ghiti <alex@ghiti.fr>
Message-ID: <cf4073ed-098f-779e-32e1-f3273622b115@ghiti.fr>
Date: Sun, 28 Apr 2019 10:27:52 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+NkQ+nwRShuKeHMwuy6++3x0QMS9djE=wUzUUtAkVf3g@mail.gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: sv-FI
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
>
>> Actually, I had to add those ifdefs for mmap_rnd_compat_bits, not
>> is_compat_task.
> Oh! In that case, use CONFIG_HAVE_ARCH_MMAP_RND_BITS. :) Actually,
> what would be maybe cleaner would be to add mmap_rnd_bits_min/max
> consts set to 0 for the non-CONFIG_HAVE_ARCH_MMAP_RND_BITS case at the
> top of mm/mmap.c.
>
> I really like this clean-up! I think we can move x86 to it too without
> too much pain. :)
>
Hi,

Just a short note to indicate that while working on v4, I realized this 
series had a some issues:

- I broke the case ARCH_HAS_ELF_RANDOMIZE selected but not
   ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT (which can happen on arm 
without MMU for example)
- I use mmap_rnd_bits unconditionnally whereas it might not be defined 
(it works for all arches I moved though)

The only clean solution I found for the first problem is to propose a 
common implementation for arch_randomize_brk
and arch_mmap_rnd, which is another series on its own and another good 
cleanup since every architecture uses
the same functions (except ppc, but that can be workarounded easily).
Just like moving x86 deserves its own series since it adds up 8/9 commits.
I am on vacations for 2 weeks, so I won't have time to submit another 
patchset before, sorry about that.

Thanks,

Alex

