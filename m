Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38383C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 11:53:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE5D22083D
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 11:53:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE5D22083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76BD18E0003; Thu, 28 Feb 2019 06:53:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71ACB8E0001; Thu, 28 Feb 2019 06:53:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 62FB28E0003; Thu, 28 Feb 2019 06:53:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 319F08E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 06:53:44 -0500 (EST)
Received: by mail-vk1-f197.google.com with SMTP id z135so10401069vkd.12
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:53:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=TcJwoA8exl8075X2LFgyOfIWV3Nji8fTLObRm1fTh8E=;
        b=G6iyexfd7YQ7kRmrEcPEzF56NZwzvoGS6W9vnnzW8yd+6lBmMrAIuBClaVBRqKn2VR
         juEp+sX+UsEL/h5i7AlsKLPp2WQet6EGwiA7vuBigZEHers28q5+3/Jis3Hfb6xfv7KL
         sUKtOx45PBmDVvCxJhG6Akxbs1yJbW7ZCnDxZdXjOZof9llE67oMj+p4bDsrdxA5p1in
         NtmO0LDhy/jg+eFB1t4Y06to15O7UPU8Emu8udB2PD0N1NwWNM60u7X5LkI3pHKNUnId
         +gj0SwCRRFwqaQLPxuvn5iZHbCtXFl+jtTBVx9MxyQ7EOSsyryKyKx5BI4jTOFB5ugSc
         4hDQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
X-Gm-Message-State: AHQUAuYA2foP91D2WkMVbcgPDX96Vi1jW5bV9SDgMf52u7TqlDpFtJOE
	3FdLoo7iWQ2orCpTF2LHiOVGEITk2SCpG0RKDuzg6Bhcq6hz5z4uaZNMuzhHOClDNDZnV226ppk
	c3sPUoCJ3Zhw3RXh+/7j3Jy/8SxxUC/rSqMY/Gy3wN33aex6ucenCg6WZi3g44IxFc+5Fui8Ea1
	WugqpALJmKgHWkmkOPctj8MijZwIC1NelhEOEJ9NJUVBi1cdGI+WClRIhsHcpcZtAvs28nkbwUb
	m+Al3txSI55sXfqE6nx1EndVmzP4XBvOmI6sblYYwqlalLVJrTNNy46idJzHQTU3JvaKraKNBpq
	za8GfxrAil3JWXMSIQs914OqT6Zx2eHBLjsxUMwPTxTfiLTT7h2N4X9drtUztZVjqCT8dUzjOw=
	=
X-Received: by 2002:a67:e897:: with SMTP id x23mr4514952vsn.4.1551354823893;
        Thu, 28 Feb 2019 03:53:43 -0800 (PST)
X-Received: by 2002:a67:e897:: with SMTP id x23mr4514917vsn.4.1551354823109;
        Thu, 28 Feb 2019 03:53:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551354823; cv=none;
        d=google.com; s=arc-20160816;
        b=MGIrhBL7AZRkDg7pl7EUwbWHHH6tnQxPlByMlgBtnc0VcuilWXm2cLZt/mb6ob9DVG
         Yu+IM0zlQ2Vcmv+hLK60Te9ZUm1+oC1/xD8Qxn29xfoU/sZwUzzteUz0UKAa8GQHWIkP
         j6wNY23qTfs45fUUAW3CCXkJnnBpcvlFcVWXPSGA/4DNfFMo7d5k1YTwYBGP+JOTO6VX
         HUNJBsnvhFQxOriIWJHeT1mMWPgaeAL0JLmLFOTcP7ap8+DGzXqtC6luu6R3fLhZKbAn
         y59DO4iFOEWPRgjKu6B9Dl0Z+uA6wgzyXbb/3TOrKjTh0KrKF5v8AMoEDUtBQauNGoiP
         0zAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=TcJwoA8exl8075X2LFgyOfIWV3Nji8fTLObRm1fTh8E=;
        b=yuOWkkhCb7jf+FjK0UjrR/NN13mxirlsI6dNBmiySAonMa93YBVo9aZpJZxMMchWhX
         FPNKWNLoHWOU7l3tJAvhSWruLeLUzt//eNcfW41qpYhydYISo8f2d+h8s64xjAs7CemY
         ltBAUSumIzHZllz9Wlvb1DoqZK6yU0Tzk/HeBlSq4wQ8VBdie8LNyudeLp+wRvtPnDbq
         iOxmHca//Qdj/xKAhtoB45jqzo5uwF8MsE+INez4ApOF11gV0LUqFot7LPj7agF8bSli
         MAj4UgpL8QoooW0UzG3DC+E8cZKu+jGcMgRzjDYDLvvnXB0fmscaoAZY57wCs+BqD33E
         4Ngw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x66sor11413218vsx.41.2019.02.28.03.53.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 03:53:42 -0800 (PST)
Received-SPF: pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
X-Google-Smtp-Source: AHgI3Ib2womPVlCd4lKB7w6IM2Uss8KBwWcgCMw7fXFICaM0ZB86xo+GzFqQ3C2ElIq0yYhPoCdDFn3T7uQTJKWhoB0=
X-Received: by 2002:a67:ead0:: with SMTP id s16mr4434066vso.63.1551354822670;
 Thu, 28 Feb 2019 03:53:42 -0800 (PST)
MIME-Version: 1.0
References: <20190227170608.27963-1-steven.price@arm.com> <20190227170608.27963-10-steven.price@arm.com>
 <CAMuHMdXCjuurBiFzQBeLPUFu=mmSowvb=37XyWmF_=xVhkQm4g@mail.gmail.com> <20190228113653.GB3766@rapoport-lnx>
In-Reply-To: <20190228113653.GB3766@rapoport-lnx>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 28 Feb 2019 12:53:30 +0100
Message-ID: <CAMuHMdU5gn6ftAHNwHNPDoUy_JvcZLcXbkk1hvUmYxtfJRfTTQ@mail.gmail.com>
Subject: Re: [PATCH v3 09/34] m68k: mm: Add p?d_large() definitions
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Steven Price <steven.price@arm.com>, Linux MM <linux-mm@kvack.org>, 
	Andy Lutomirski <luto@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
	Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, 
	James Morse <james.morse@arm.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, 
	Will Deacon <will.deacon@arm.com>, "the arch/x86 maintainers" <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mark Rutland <Mark.Rutland@arm.com>, 
	"Liang, Kan" <kan.liang@linux.intel.com>, linux-m68k <linux-m68k@lists.linux-m68k.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Mike,

On Thu, Feb 28, 2019 at 12:37 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> On Wed, Feb 27, 2019 at 08:27:40PM +0100, Geert Uytterhoeven wrote:
> > On Wed, Feb 27, 2019 at 6:07 PM Steven Price <steven.price@arm.com> wrote:
> > > walk_page_range() is going to be allowed to walk page tables other than
> > > those of user space. For this it needs to know when it has reached a
> > > 'leaf' entry in the page tables. This information is provided by the
> > > p?d_large() functions/macros.
> > >
> > > For m68k, we don't support large pages, so add stubs returning 0
> > >
> > > CC: Geert Uytterhoeven <geert@linux-m68k.org>
> > > CC: linux-m68k@lists.linux-m68k.org
> > > Signed-off-by: Steven Price <steven.price@arm.com>
> >
> > Thanks for your patch!
> >
> > >  arch/m68k/include/asm/mcf_pgtable.h      | 2 ++
> > >  arch/m68k/include/asm/motorola_pgtable.h | 2 ++
> > >  arch/m68k/include/asm/pgtable_no.h       | 1 +
> > >  arch/m68k/include/asm/sun3_pgtable.h     | 2 ++
> > >  4 files changed, 7 insertions(+)
> >
> > If the definitions are the same, why not add them to
> > arch/m68k/include/asm/pgtable.h instead?
>
> Maybe I'm missing something, but why the stubs have to be defined in
> arch/*/include/asm/pgtable.h rather than in include/asm-generic/pgtable.h?

That would even make more sense, given most architectures don't
support huge pages.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

