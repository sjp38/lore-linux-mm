Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADC64C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 23:18:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E894217FA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 23:18:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="bmUIU6sK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E894217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB5226B0005; Wed, 17 Apr 2019 19:18:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3D676B0006; Wed, 17 Apr 2019 19:18:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B04426B0007; Wed, 17 Apr 2019 19:18:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 46FEF6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 19:18:35 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id p13so35255lfc.4
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 16:18:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=MovRSmCBZtC0FfepdTAmKtvCaTqkApcKe7AZyWeWly0=;
        b=ERlZJVCsk1nUULWrXyLCeWDF0GgvKxiLR5FQ2GhraUiio1tcGBE1v8OFjsIrZPLk8H
         4tQWCHofmnpGZP9fhsrCzvImYIDgdcKpIxkp7fUGByekuByO5HViQc5FOeeELjMCjOMc
         H66rmDp8JAZO7o1FCkBX54AL8RG4Az6A/DPWWXUMasbJxUZMmsEI9t7n2rBEGb0qd6+P
         rStzJT2OmK7GgxyY37c7+1b2UXM7U/BsCeQ1mwQCoMd0n/ctdXwQALFE+jH092KZcEQt
         zLpCOvxd3fAhtPUlyBodbbMyo/48HuQWoU0U6GPPkmJOW9GBRgX8QyVabqaf5r9AuSqO
         YYbw==
X-Gm-Message-State: APjAAAUlrhKg/m26MYyGK3DgdNc/J0SOu5ZclZIrYpSyXS8jA702RST0
	8SA4gB2PPCG1EjENfRaYxwHH8rjPA5/rfuMRBLNHJ3pFHdgiNCx/kuOn7ZKNWDDlUt9VKEwge3u
	Cs8xDKlcPc6heXGcB/RLSJkOCQdMaHv2iPUGXkNzux7Qs235gaSqlNYyrTFSE92USkQ==
X-Received: by 2002:ac2:5085:: with SMTP id f5mr20854251lfm.71.1555543114668;
        Wed, 17 Apr 2019 16:18:34 -0700 (PDT)
X-Received: by 2002:ac2:5085:: with SMTP id f5mr20854228lfm.71.1555543113715;
        Wed, 17 Apr 2019 16:18:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555543113; cv=none;
        d=google.com; s=arc-20160816;
        b=KsswUrE/BJ2+pNmNo7gU4xFm/S8jsXe5MA3bkuHxBC6aNkpzl5N5KIZbgI41JVGxKJ
         5qGxpv9WoUOPp2wXuR6pNgIMlxXZrLpg7e8x9Q1SFntOSab7ZpPI4MXH9BwSrLS4Ye5J
         pexaAb8/QLEX9NOL84Xy9xrmJ5s7RSeU+pn5F4buP7nF/rgwtYhatMgNaMQiwcAU/ldM
         3clVYYEBxSYM7HdNGlLh87YGbhkDg6E8r0+GfsUEMA4d9BFJdwlrQVgXTHZx3WlxWUqe
         HpYdqbYctHSk92+ZhXuGBUqkwlAuEUTixcxepQWcWZMiRVQrPNz3+Shi5cIwJI6SVJM4
         G5og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=MovRSmCBZtC0FfepdTAmKtvCaTqkApcKe7AZyWeWly0=;
        b=M5iYUmRigRX//RFhdCtLQ2c5x1NrNl0S1sxC7SzJ3NeYXR9OX2Fd7gbwOd5GY+kPm/
         0A9Av694YXZfq+qwI51ReJkGRCEJgAdkFTX71rrC/pgPXSHwNek0iQ2WptQuDqn/QD+k
         8HDujHLf+1uQsYZfqBQmrDKUsqUvvQJI0Dn55TEJ6pYZcaW6iOBKaRxG2t6AlW8uK+N/
         FAHdp4jL6/4sihPs88dCDeSCU/E0sz/GcvwdR5rqjY0GM6N0YBzOEFntZKgTIA9lqEQL
         wDCe1ysFZFS7BAUV7cYaUFaAFTjonXXV3UPwrNqglkKKyIPo0dwxcMmPQNkJ4COZ/gsC
         udwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=bmUIU6sK;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f5sor98736ljj.23.2019.04.17.16.18.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 16:18:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=bmUIU6sK;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=MovRSmCBZtC0FfepdTAmKtvCaTqkApcKe7AZyWeWly0=;
        b=bmUIU6sKJUij7h28dg7hpNxvADEffY+cXC5BTMaGAk08LOHFA0WpumdZ0cWjETTV/R
         97UwcY+cF21cLiI4RF62jKRUqtn6sHJoEST9IWQkMOQ+A4wkC4yz7z+EMZr5Hj7wFKyD
         EPCgEzmy1qG0ABYsC+JpwdC9Evx0XjNLurMXg=
X-Google-Smtp-Source: APXvYqw1yD+Z0a7HkRuYobLk9ZcVODOIZXTP8hG5BF2qQ2358wJPxiQB2ZB+AV94BaA42KespI9LnQ==
X-Received: by 2002:a2e:85d4:: with SMTP id h20mr1512166ljj.189.1555543113151;
        Wed, 17 Apr 2019 16:18:33 -0700 (PDT)
Received: from mail-lf1-f54.google.com (mail-lf1-f54.google.com. [209.85.167.54])
        by smtp.gmail.com with ESMTPSA id l13sm43739ljj.96.2019.04.17.16.18.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 16:18:32 -0700 (PDT)
Received: by mail-lf1-f54.google.com with SMTP id h18so78925lfj.11
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 16:18:31 -0700 (PDT)
X-Received: by 2002:ac2:598b:: with SMTP id w11mr21120489lfn.62.1555543110507;
 Wed, 17 Apr 2019 16:18:30 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1554248001.git.khalid.aziz@oracle.com> <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
 <20190417161042.GA43453@gmail.com> <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com>
 <20190417170918.GA68678@gmail.com> <56A175F6-E5DA-4BBD-B244-53B786F27B7F@gmail.com>
 <20190417172632.GA95485@gmail.com> <063753CC-5D83-4789-B594-019048DE22D9@gmail.com>
 <alpine.DEB.2.21.1904172317460.3174@nanos.tec.linutronix.de>
In-Reply-To: <alpine.DEB.2.21.1904172317460.3174@nanos.tec.linutronix.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 17 Apr 2019 16:18:18 -0700
X-Gmail-Original-Message-ID: <CAHk-=wgBMg9P-nYQR2pS0XwVdikPCBqLsMFqR9nk=wSmAd4_5g@mail.gmail.com>
Message-ID: <CAHk-=wgBMg9P-nYQR2pS0XwVdikPCBqLsMFqR9nk=wSmAd4_5g@mail.gmail.com>
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Nadav Amit <nadav.amit@gmail.com>, Ingo Molnar <mingo@kernel.org>, 
	Khalid Aziz <khalid.aziz@oracle.com>, juergh@gmail.com, Tycho Andersen <tycho@tycho.ws>, 
	jsteckli@amazon.de, keescook@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, 
	deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, 
	David Woodhouse <dwmw@amazon.co.uk>, Andrew Cooper <andrew.cooper3@citrix.com>, jcm@redhat.com, 
	Boris Ostrovsky <boris.ostrovsky@oracle.com>, iommu <iommu@lists.linux-foundation.org>, 
	X86 ML <x86@kernel.org>, linux-arm-kernel@lists.infradead.org, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	LSM List <linux-security-module@vger.kernel.org>, Khalid Aziz <khalid@gonehiking.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, 
	Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Hansen <dave@sr71.net>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, Arjan van de Ven <arjan@infradead.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Content-Type: multipart/alternative; boundary="00000000000088f1ef0586c21a38"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--00000000000088f1ef0586c21a38
Content-Type: text/plain; charset="UTF-8"

On Wed, Apr 17, 2019, 14:20 Thomas Gleixner <tglx@linutronix.de> wrote:

>
> It's not necessarily a W+X issue. The user space text is mapped in the
> kernel as well and even if it is mapped RX then this can happen. So any
> kernel mappings of user space text need to be mapped NX!


With SMEP, user space pages are always NX.

I really think SM[AE]P is something we can already take for granted. People
who have old CPU's workout it are simply not serious about security anyway.
There is no point in saying "we can do it badly in software".

       Linus

>

--00000000000088f1ef0586c21a38
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><br><div class=3D"gmail_quote"><div dir=3D"ltr" =
class=3D"gmail_attr">On Wed, Apr 17, 2019, 14:20 Thomas Gleixner &lt;<a hre=
f=3D"mailto:tglx@linutronix.de">tglx@linutronix.de</a>&gt; wrote:<br></div>=
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><br>
It&#39;s not necessarily a W+X issue. The user space text is mapped in the<=
br>
kernel as well and even if it is mapped RX then this can happen. So any<br>
kernel mappings of user space text need to be mapped NX!</blockquote></div>=
</div><div dir=3D"auto"><br></div><div dir=3D"auto">With SMEP, user space p=
ages are always NX.</div><div dir=3D"auto"><br></div><div dir=3D"auto">I re=
ally think SM[AE]P is something we can already take for granted. People who=
 have old CPU&#39;s workout it are simply not serious about security anyway=
. There is no point in saying &quot;we can do it badly in software&quot;.</=
div><div dir=3D"auto"><br></div><div dir=3D"auto">=C2=A0 =C2=A0 =C2=A0 =C2=
=A0Linus</div><div dir=3D"auto"><div class=3D"gmail_quote"><blockquote clas=
s=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pad=
ding-left:1ex">=C2=A0</blockquote></div></div><div dir=3D"auto"></div></div=
>

--00000000000088f1ef0586c21a38--

