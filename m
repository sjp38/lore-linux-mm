Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DDE3C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 14:26:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19E55208E4
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 14:26:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="FBq8bKtw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19E55208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E5676B0005; Thu, 18 Apr 2019 10:26:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96B846B0006; Thu, 18 Apr 2019 10:26:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80CC16B0007; Thu, 18 Apr 2019 10:26:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 580C36B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 10:26:05 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id t17so555103vsl.8
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 07:26:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8eV2vUS51UMgePfSSxCuXJhq0Gtq0aUu2F6TTcKETz0=;
        b=S41AKENoYTRcITcEpssQUrfWHoJv6FLso8P7s6PTbBgVuz5r8Daz9UfH0nUdtfWtdc
         xkTe7piUFC3qw+gn7ISi8eo4ryhaoKExTglw5RyMmeZ7q+71NL42L/pM4aIAdP1GyNQK
         2FA3pSp9gvwO5swihNGczyAueVtAxJ2eN9TvMxgQTIk7YIt67TyYV57nGu8rUlWPxqCh
         6hVMlxutyncsC+PUOVjQQpITIm0MCUsKAplmNE9VQqbJr1lMq27LF409nUXIAIWKChDC
         XuypJmYA6YpkVPgummEsm8jxgJmwXEwJrF8MAHO4k4e9yoN39XpSPBRiVmSbPQRKc5Qn
         9auw==
X-Gm-Message-State: APjAAAWEb05D+A63d4Ws7yLp04VDsxvJxiOWoBqb5mWifujIEFpCGKGP
	pNAZFs8vN1Y8+yvg3h93gKSeB4EMyt1mULKZa4XO72sBlO0l1MpE1p2PQNKnDYxKssucls5bG0y
	iO41xrQuLvde1TAFu7bE5KHn+STP1LIkMHibH/yQeNiyqxj+8/oWa4fdenS991rorJw==
X-Received: by 2002:a67:fa4d:: with SMTP id j13mr51855213vsq.22.1555597564977;
        Thu, 18 Apr 2019 07:26:04 -0700 (PDT)
X-Received: by 2002:a67:fa4d:: with SMTP id j13mr51855168vsq.22.1555597564283;
        Thu, 18 Apr 2019 07:26:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555597564; cv=none;
        d=google.com; s=arc-20160816;
        b=qoOx7/pWxwdBlTrYBNAtkO0RXT5WPtMtTjOxTuIiRKrVmgrMkjKy6Q15a/IapmovW4
         glrySADlntVfW3H+mpY8yX1T+QQls7EIF5lsDks/jbRPZ16pSJdo+WD7SU6177ETjnP8
         BXKRqMUwzsBrm39K6M2xPdARk9gEuXuJEFT8tfQghjl4A64yqNjeDXhEkcuLRRTF6iRs
         0qGkR8SSRGVbIMgMypousn4UNEDh9c9u4yXPj0lSgp8AsU/J37/j/kJXrYK2eqn5zuOi
         Xj1L69HfaPre8ptgouyb6d7shRYDvbqHisdvS2aVcUbrfuvgyZ3R27X0v17WYwJW/gDL
         3ncw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8eV2vUS51UMgePfSSxCuXJhq0Gtq0aUu2F6TTcKETz0=;
        b=YvMRG5bTLvmK5p7yCuEKlbn9HejPOn9e0Nk9Z1jusVRSb/7pRw5X+38/IuYUo8PqLX
         sudSOtlckMLE8z4nlvKJygC5SFMJDbiJ4aJF2RgqQV4xrHulw8umDIk27ksLt9MWFHUS
         FOhs1SFQovZabl0FGCnJo4qjn3169pWuJAKe3KbL8eD1+KQxkpDPbWb8Lq9R4feAFYIa
         VI2lwI/794xZhwpSHQg7ZxcwPqtpBux5sf+PeHR/lFHZJBtTUpRyQDlD78uddSGCCbu0
         OrdGhUoo2bkWDUQE+zJTbD0ISS2JxACIcVFeZHQIJZ6pAZMNxGZYpkE8uoE5vKbPifrH
         fofA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=FBq8bKtw;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o25sor1066075vsp.47.2019.04.18.07.26.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 07:26:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=FBq8bKtw;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8eV2vUS51UMgePfSSxCuXJhq0Gtq0aUu2F6TTcKETz0=;
        b=FBq8bKtw8jKgNvkAesGOL5wEhVUfIvOVZLawNU9Os5filzXur33S5KXLGi3G59zEmJ
         MNxbw1dkanZJyl6+Bh/X7hbbi4DCuJUT+N82rjvvIQb1baWE98HINAsh1KYITkSEbQsv
         WkyhKK/r8PDat9cP9eHISsDMRa0TxCyHkKPk0=
X-Google-Smtp-Source: APXvYqymIvWLmi/Cq4+kJDANmjOdslCYhur5PiCKHEbURU7N+/ywL2l12KaXr/8W9MCG428i9tli4w==
X-Received: by 2002:a67:e451:: with SMTP id n17mr52297917vsm.35.1555597563427;
        Thu, 18 Apr 2019 07:26:03 -0700 (PDT)
Received: from mail-vk1-f179.google.com (mail-vk1-f179.google.com. [209.85.221.179])
        by smtp.gmail.com with ESMTPSA id e198sm490669vsc.3.2019.04.18.07.26.03
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 07:26:03 -0700 (PDT)
Received: by mail-vk1-f179.google.com with SMTP id h127so485951vkd.12
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 07:26:03 -0700 (PDT)
X-Received: by 2002:a1f:2e07:: with SMTP id u7mr50481033vku.44.1555597170338;
 Thu, 18 Apr 2019 07:19:30 -0700 (PDT)
MIME-Version: 1.0
References: <20190417052247.17809-1-alex@ghiti.fr> <20190417052247.17809-5-alex@ghiti.fr>
 <CAGXu5j+NV7nfQ044kvsqqSrWpuXH5J6aZEbvg7YpxyBFjdAHyw@mail.gmail.com> <fd2b02b3-5872-ccf6-9f52-53f692fba02d@ghiti.fr>
In-Reply-To: <fd2b02b3-5872-ccf6-9f52-53f692fba02d@ghiti.fr>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 18 Apr 2019 09:19:18 -0500
X-Gmail-Original-Message-ID: <CAGXu5j+NkQ+nwRShuKeHMwuy6++3x0QMS9djE=wUzUUtAkVf3g@mail.gmail.com>
Message-ID: <CAGXu5j+NkQ+nwRShuKeHMwuy6++3x0QMS9djE=wUzUUtAkVf3g@mail.gmail.com>
Subject: Re: [PATCH v3 04/11] arm64, mm: Move generic mmap layout functions to mm
To: Alex Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, 
	Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, 
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>, 
	Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Luis Chamberlain <mcgrof@kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, 
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-mips@vger.kernel.org, 
	linux-riscv@lists.infradead.org, 
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Christoph Hellwig <hch@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 12:55 AM Alex Ghiti <alex@ghiti.fr> wrote:
> Regarding the help text, I agree that it does not seem to be frequent to
> place
> comment above config like that, I'll let Christoph and you decide what's
> best. And I'll
> add the possibility for the arch to define its own STACK_RND_MASK.

Yeah, I think it's very helpful to spell out the requirements for new
architectures with these kinds of features in the help text (see
SECCOMP_FILTER for example).

> > I think CONFIG_ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT should select
> > CONFIG_ARCH_HAS_ELF_RANDOMIZE. It would mean moving
>
>
> I don't think we should link those 2 features together: an architecture
> may want
> topdown mmap and don't care about randomization right ?

Given that the mmap randomization and stack randomization are already
coming along for the ride, it seems weird to make brk randomization an
optional feature (especially since all the of the architectures you're
converting include it). I'd also like these kinds of security features
to be available by default. So, I think one patch to adjust the MIPS
brk randomization entropy and then you can just include it in this
move.

> Actually, I had to add those ifdefs for mmap_rnd_compat_bits, not
> is_compat_task.

Oh! In that case, use CONFIG_HAVE_ARCH_MMAP_RND_BITS. :) Actually,
what would be maybe cleaner would be to add mmap_rnd_bits_min/max
consts set to 0 for the non-CONFIG_HAVE_ARCH_MMAP_RND_BITS case at the
top of mm/mmap.c.

I really like this clean-up! I think we can move x86 to it too without
too much pain. :)

-- 
Kees Cook

