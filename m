Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E41F9C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:54:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 931A42171F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:54:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="X++PCUXa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 931A42171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 297178E0004; Thu, 28 Feb 2019 04:54:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 245D38E0001; Thu, 28 Feb 2019 04:54:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 15DC08E0004; Thu, 28 Feb 2019 04:54:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id E1EB48E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:54:30 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id 9so7450950ita.8
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 01:54:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=rXb7KsxkVUdyqpMToL9gEweDulM6b6YqmLTSoKTjxKs=;
        b=hEgcp/0ASMoua5Okl5lUVYvNS7p8WtfUgjvecGuNTkBg0qxLn0MSkhlxMrbjiedprR
         Pb9LrGSeOsWPvZPufG/jb6KltIVHdnEJkyV381/HakhGHzua8Lq9QaAZaCKlS51XXuNT
         d00bbycZbY3jHc3jOkcIpo5JFLqwpoy/X3z62sup1fgJXkEt34kjAci2g4WyFnKC2BCo
         KpkOh0uwXVA80NKg+jZTE4bFwpHya3MFU6nQIf8U4LEeH7jKtalFTBbmwYe5WmlfwM2S
         44q2o9ddclzC6ZPrmNLIFD2qPljd2qFUfHUzY4Ih0ZCUobLOiMtYKIpeBS57HuZKDVix
         zYeg==
X-Gm-Message-State: APjAAAXIZBKtxoMe6jJ7/41U/LG3Wh+ujNF4c1AzWWXTYadGXvFnl7Vz
	Or35t7LnNxgJiYMDqyiULMfXzklxiU0s2r7QAOrQ5VOGdg32LHpolL23lcQZ1W0WClMV2f4KZfV
	esByHjU/YqvPnb1mm0dnc0X4d13mPZ2kO6O69T+Uyu65WNiclcjhHjMA6cssQuPbbqChz9AWgfw
	tSOC8tYdFwLPdpKNX9HdZlQtaS/a3gtMj/6Hy3TcoB76vLUT/dEYWmkbZH3DM1si3sWB3qjPp3n
	zIwgLotXcdU1kZUF+2VY6fjSv3f4rF/BabSSYr6D84K+RG5ojwjEX/vud07jAo5Pz/gEFG34TRO
	Zc/bCmoR1+hdm4XpwWTJSi7Sneqezt23NCBZEAsrzMsO90utzGwOJfKEtqgBH/o5f9CqfM7LM0b
	e
X-Received: by 2002:a24:4161:: with SMTP id x94mr2222161ita.69.1551347670661;
        Thu, 28 Feb 2019 01:54:30 -0800 (PST)
X-Received: by 2002:a24:4161:: with SMTP id x94mr2222133ita.69.1551347669169;
        Thu, 28 Feb 2019 01:54:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551347669; cv=none;
        d=google.com; s=arc-20160816;
        b=ue+Lq6MCsdyP6OixLTAlB3oe0Xy8hFvzsFd9MxgLoo+l0te9xzsBo5ONEhbwYZDptp
         3gECbuuSep1RPc7Kk1aQrGCxH00OWO9nm1LDvZGqGvg1D/GnLKt7WuVUJEqrh+XVy9jz
         i+q48cFCxLdj2sh6DUtA1tYfH7gF4xu4udjszT/1k7GYT9crGaj69xzegJxFnS5ACp3U
         jpkR/if21Sa7tZoCDOGrbta/ZzQXc375EgnPlJjGh3TFTcqEhm7Fy+P+XYmkPX41/mUi
         bFBQfldyc50M2z5CeHHHpXV0HHf1iXd8DHjjMWBNUrJudawT6j5Q8bsuCGcG0VWVTGrz
         MJ1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=rXb7KsxkVUdyqpMToL9gEweDulM6b6YqmLTSoKTjxKs=;
        b=qQc0RECznD7igPy3e+hww8YDm3yWOjiDFRG2LwbyC5q50gPudvF03IJhFU+uh9YiuZ
         rpwInSSYVnVwOV8kx6t9Owd2SE0oOGSryixW9su2PiYfcGh543qlfE/cWk5P+7PcRuFl
         FllieCa7m7jrBiegRjMGmBlBDMt8Bx276FRnN07FbCBCqjBR/sxXjJZoPq0hMvLg2hQn
         bTyaNsXZmqQzOXS58zxyeemn+4t7/a4mSBoKWD+YcHR/IrAwTArvQpmRRcmhPGBl6mCR
         dBYnzNFxOGH4kmULr4dzXmP239Hp7LEv4N//l0XopYJyz/9CLyvciVXE3/DBSrb+Akfw
         0P/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=X++PCUXa;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l2sor8445444iop.108.2019.02.28.01.54.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 01:54:29 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=X++PCUXa;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=rXb7KsxkVUdyqpMToL9gEweDulM6b6YqmLTSoKTjxKs=;
        b=X++PCUXaJwXTgXvM/pM1bCF+D3zL0eQrlEDzTn/y4nNYHQWsyhJ4BzqDWWTgF/vDXE
         yLmHvNRvOjABe/twyuoGAcS4yLo3ZQuavfR/KhkNcrJz338N4ZWk2RbTePHSOLSFcFg0
         /mOQqXZTBcBC0PkJ8ghony/7lRTzZ2HmsnxPb49Vc/BrHzFTnFPa7A19C+5B8XZQ6LMl
         0zDa4mY+VkjHpLdgqmaN8HJacQS99wMtUy6m4qn9GZtQuet1uZa7NOIrPC7Gc0B2dyxP
         8X3Zo3o3PPL/E1NaPAxGuXnbn0QPqSjo4Lx0MvJU+3G6FkB55dfHKzwvrKitxAT7KtiC
         6vbg==
X-Google-Smtp-Source: APXvYqxmaNJZtCBPBXL7Hy9EghpgusRMw77WP2JE7FsfpttrLEKTeHM5IOQ1cSJ3T+ljyv2j9UnAriNdzBQMyOEvCSo=
X-Received: by 2002:a5d:834a:: with SMTP id q10mr4364650ior.271.1551347668481;
 Thu, 28 Feb 2019 01:54:28 -0800 (PST)
MIME-Version: 1.0
References: <c6d80735-0cfe-b4ab-0349-673fc65b2e15@c-s.fr> <5f0203bd-77ea-d94c-11b7-1befba439cd4@virtuozzo.com>
 <15a40476-2852-cf5a-0982-d899dd79d9c1@c-s.fr> <7778f728-3ca2-7ad6-503f-72ca098863cb@virtuozzo.com>
 <CACT4Y+adjRarmcWTrQxotATzaHoFQ4TXbyiRXEpWozLPzjQBrQ@mail.gmail.com> <11314e32-6044-9207-a238-738e394ea2eb@virtuozzo.com>
In-Reply-To: <11314e32-6044-9207-a238-738e394ea2eb@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 28 Feb 2019 10:54:17 +0100
Message-ID: <CACT4Y+ZgtHiUWAug+2JXHs0=LWqxE+jT6rRAoRp=SgZZ4ZeVeA@mail.gmail.com>
Subject: Re: BUG: KASAN: stack-out-of-bounds
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Christophe Leroy <christophe.leroy@c-s.fr>, Alexander Potapenko <glider@google.com>, 
	Daniel Axtens <dja@axtens.net>, Linux-MM <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org, 
	kasan-dev <kasan-dev@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 10:46 AM Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
>
> On 2/28/19 12:27 PM, Dmitry Vyukov wrote:
> > On Thu, Feb 28, 2019 at 10:22 AM Andrey Ryabinin
> > <aryabinin@virtuozzo.com> wrote:
> >>
> >>
> >>
> >> On 2/27/19 4:11 PM, Christophe Leroy wrote:
> >>>
> >>>
> >>> Le 27/02/2019 =C3=A0 10:19, Andrey Ryabinin a =C3=A9crit :
> >>>>
> >>>>
> >>>> On 2/27/19 11:25 AM, Christophe Leroy wrote:
> >>>>> With version v8 of the series implementing KASAN on 32 bits powerpc=
 (https://patchwork.ozlabs.org/project/linuxppc-dev/list/?series=3D94309), =
I'm now able to activate KASAN on a mac99 is QEMU.
> >>>>>
> >>>>> Then I get the following reports at startup. Which of the two repor=
ts I get seems to depend on the option used to build the kernel, but for a =
given kernel I always get the same report.
> >>>>>
> >>>>> Is that a real bug, in which case how could I spot it ? Or is it so=
mething wrong in my implementation of KASAN ?
> >>>>>
> >>>>> I checked that after kasan_init(), the entire shadow memory is full=
 of 0 only.
> >>>>>
> >>>>> I also made a try with the strong STACK_PROTECTOR compiled in, but =
no difference and nothing detected by the stack protector.
> >>>>>
> >>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >>>>> BUG: KASAN: stack-out-of-bounds in memchr+0x24/0x74
> >>>>> Read of size 1 at addr c0ecdd40 by task swapper/0
> >>>>>
> >>>>> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1133
> >>>>> Call Trace:
> >>>>> [c0e9dca0] [c01c42a0] print_address_description+0x64/0x2bc (unrelia=
ble)
> >>>>> [c0e9dcd0] [c01c4684] kasan_report+0xfc/0x180
> >>>>> [c0e9dd10] [c089579c] memchr+0x24/0x74
> >>>>> [c0e9dd30] [c00a9e38] msg_print_text+0x124/0x574
> >>>>> [c0e9dde0] [c00ab710] console_unlock+0x114/0x4f8
> >>>>> [c0e9de40] [c00adc60] vprintk_emit+0x188/0x1c4
> >>>>> --- interrupt: c0e9df00 at 0x400f330
> >>>>>      LR =3D init_stack+0x1f00/0x2000
> >>>>> [c0e9de80] [c00ae3c4] printk+0xa8/0xcc (unreliable)
> >>>>> [c0e9df20] [c0c28e44] early_irq_init+0x38/0x108
> >>>>> [c0e9df50] [c0c16434] start_kernel+0x310/0x488
> >>>>> [c0e9dff0] [00003484] 0x3484
> >>>>>
> >>>>> The buggy address belongs to the variable:
> >>>>>   __log_buf+0xec0/0x4020
> >>>>> The buggy address belongs to the page:
> >>>>> page:c6eac9a0 count:1 mapcount:0 mapping:00000000 index:0x0
> >>>>> flags: 0x1000(reserved)
> >>>>> raw: 00001000 c6eac9a4 c6eac9a4 00000000 00000000 00000000 ffffffff=
 00000001
> >>>>> page dumped because: kasan: bad access detected
> >>>>>
> >>>>> Memory state around the buggy address:
> >>>>>   c0ecdc00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >>>>>   c0ecdc80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >>>>>> c0ecdd00: 00 00 00 00 00 00 00 00 f1 f1 f1 f1 00 00 00 00
> >>>>>                                     ^
> >>>>>   c0ecdd80: f3 f3 f3 f3 00 00 00 00 00 00 00 00 00 00 00 00
> >>>>>   c0ecde00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >>>>>
> >>>>
> >>>> This one doesn't look good. Notice that it says stack-out-of-bounds,=
 but at the same time there is
> >>>>     "The buggy address belongs to the variable:  __log_buf+0xec0/0x4=
020"
> >>>>   which is printed by following code:
> >>>>     if (kernel_or_module_addr(addr) && !init_task_stack_addr(addr)) =
{
> >>>>         pr_err("The buggy address belongs to the variable:\n");
> >>>>         pr_err(" %pS\n", addr);
> >>>>     }
> >>>>
> >>>> So the stack unrelated address got stack-related poisoning. This cou=
ld be a stack overflow, did you increase THREAD_SHIFT?
> >>>> KASAN with stack instrumentation significantly increases stack usage=
.
> >>>>
> >>>
> >>> I get the above with THREAD_SHIFT set to 13 (default value).
> >>> If increasing it to 14, I get the following instead. That means that =
in that case the problem arises a lot earlier in the boot process (but stil=
l after the final kasan shadow setup).
> >>>
> >>
> >> We usually use 15 (with 4k pages), but I think 14 should be enough for=
 the clean boot.
> >>
> >>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >>> BUG: KASAN: stack-out-of-bounds in pmac_nvram_init+0x1f8/0x5d0
> >>> Read of size 1 at addr f6f37de0 by task swapper/0
> >>>
> >>> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1143
> >>> Call Trace:
> >>> [c0e9fd60] [c01c43c0] print_address_description+0x164/0x2bc (unreliab=
le)
> >>> [c0e9fd90] [c01c46a4] kasan_report+0xfc/0x180
> >>> [c0e9fdd0] [c0c226d4] pmac_nvram_init+0x1f8/0x5d0
> >>> [c0e9fef0] [c0c1f73c] pmac_setup_arch+0x298/0x314
> >>> [c0e9ff20] [c0c1ac40] setup_arch+0x250/0x268
> >>> [c0e9ff50] [c0c151dc] start_kernel+0xb8/0x488
> >>> [c0e9fff0] [00003484] 0x3484
> >>>
> >>>
> >>> Memory state around the buggy address:
> >>>  f6f37c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >>>  f6f37d00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >>>> f6f37d80: 00 00 00 00 00 00 00 00 00 00 00 00 f1 f1 f1 f1
> >>>                                                ^
> >>>  f6f37e00: 00 00 01 f4 f2 f2 f2 f2 00 00 00 00 f2 f2 f2 f2
> >>>  f6f37e80: 00 00 00 00 f3 f3 f3 f3 00 00 00 00 00 00 00 00
> >>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >>
> >> Powerpc's show_stack() prints stack addresses, so we know that stack i=
s something near 0xc0e9f... address.
> >> f6f37de0 is definitely not stack address and it's to far for the stack=
 overflow.
> >> So it looks like shadow for stack  - kasan_mem_to_shadow(0xc0e9f...) a=
nd shadow for address in report - kasan_mem_to_shadow(0xf6f37de0)
> >> point to the same physical page.
> >
> > Shouldn't shadow start at 0xf8 for powerpc32? I did some math
> > yesterday which I think lead me to 0xf8.
>
> Dunno, maybe. How is this relevant? In case you referring to the 0xf6f* a=
ddresses in the report,
> these are not shadow, but accessed addresses.

Right. Then never mind.

