Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18603C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:23:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE9D22086D
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:23:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GnKuUVq/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE9D22086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 587C26B000C; Tue,  6 Aug 2019 12:23:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EB2D6B027A; Tue,  6 Aug 2019 12:23:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B18F6B027B; Tue,  6 Aug 2019 12:23:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0437D6B000C
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:23:38 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id i132so35326705oif.2
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:23:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to;
        bh=FXcx40QviUjh/go1r7qaSy8ThqYBOojFvr3X85upeJM=;
        b=fGdDFzBm9t49nhzMgaxeKONGgjZdiRv7sf4mcL0c3am+AHYW5obqPHhz9tCf8VdkKq
         YTq/raMpvNT5qTNOlG0nqWKPd8/L+JavYCgx22IMJyiM4qz1eJU9yW8ava6Om5UR6Erf
         xDDPpEdWLwSN8DEP0Vkcg5uFAEyUg0PqVOPZQucXuKcXl6rqqTbEzmYcGdsdmpIFE0ZW
         TNAOzxq3zOHw2ISxE+3Q9ev/ivVeAoU8RzCrZEoeJ91hsVDzumetgrP7eDlX/2Kagq9x
         r0zT+nEkVielAMaHUyiRiKBeoyD4HvQsdH1nBAHYcuMsARr9VRao9jlgcmC0N7fc3H1h
         ARlg==
X-Gm-Message-State: APjAAAU8+maKSOI3w7Kwgs7Icazaw31R70CM2+Ntg89fKG0/rkctXpMg
	vekq1CGUh7bJZr/jlyeV5UkBaoUyosrEJFJHOG58+Fmj+8JghhGsu0jrnarO5ievDJeH8ogpvle
	0Lavmq11MVvSUlMs17jZDIAOYmCXFpPNXgvlPRRN5m0IjM2XhB8p0AJb7f7g3f0Sj6A==
X-Received: by 2002:a02:ce52:: with SMTP id y18mr5019780jar.78.1565108617714;
        Tue, 06 Aug 2019 09:23:37 -0700 (PDT)
X-Received: by 2002:a02:ce52:: with SMTP id y18mr5019592jar.78.1565108615289;
        Tue, 06 Aug 2019 09:23:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565108615; cv=none;
        d=google.com; s=arc-20160816;
        b=cfxhH7O4XNLZE0WQEYJcK4WIgvLdHn29hW/jvLnM3bc6bmIoj1IrbUsmyK89u8Ws1h
         +X91smhLTc5V4oIkw6QHHesN4NWsjz8qVEJbZcQy3VsUrawFvuhwAEtirh6DgxE8wubf
         FsRBE0Q2/9gjBBShRb9/6kURRnVicP6Y3j/4IQqFmbvf94zMIC+hamSMhAikas0qQb5d
         tbdGRsg+bsZWanNnM5Ig06pBeKjfNXloxRK7Tq9sIfZUD42qA6dTpQL5ulHiLQLYsn0r
         NDi4Yv+NkTq88rdelL0H64RYszvHv1HqlVBoJsq+rBZ9JiYkb2Djlohtc05bxUkKY8Qr
         GynQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:in-reply-to:references:mime-version
         :dkim-signature;
        bh=FXcx40QviUjh/go1r7qaSy8ThqYBOojFvr3X85upeJM=;
        b=zwoZrI1lgA0m5P87CwaI/C48idOw6jmbrR75Stlw0MeC1IuopiyqI0bXGG2UsjQ0a/
         NRtlCTV6j/WfHigYRb+YSG37y/xFBWada+1LdwgWSR5hir8Xmy2tLe5QUPuGg74WQkkn
         C3DuCs3YZjYnwoaGgsLip3UkedSEU5uGy5o63XEcvxL1u4g4MzYIxzElnL4v7u8FfSu6
         6A9Ygam53ozkHcC1shS3k5qh13gqQ5j7ERYiKpiGvDk6dgHUL6tsXP5bLdJfeXo7LAug
         Qaq9nmwFJuvuq94Mhxpx2EZqqe7QeHBooXy8N13umAZ5MergU2HatUMkaz1IxCwL2FX6
         7ibA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="GnKuUVq/";
       spf=pass (google.com: domain of a.reversat@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=a.reversat@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t127sor201316318jaa.12.2019.08.06.09.23.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 09:23:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of a.reversat@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="GnKuUVq/";
       spf=pass (google.com: domain of a.reversat@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=a.reversat@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to;
        bh=FXcx40QviUjh/go1r7qaSy8ThqYBOojFvr3X85upeJM=;
        b=GnKuUVq/WvfVcA4NBk1oZU4Cslv6BuNxR+Jr9SItDiWCGrPUq6Xa3TqbKZf2I8ypPs
         PGZjOKixWHn5vzw0x2s6eM33M16EqlQ0pK4qRj8G91Q/QUZERgKVk4C2aKSn/XbKNM6R
         Ox3hRjJUCmLj0/OjQEN1EDX0dsCA8wNGh1PZyZzcghp3WDnW/gD11YIZtl+8cH130uE3
         psu44hIFXId2lSDAGxYrpmy/L9D3faAeY6q9QW2u/F8vKLJdPsFeTpvFeNlLrFoklkjA
         0VpIlvNhGYDka0V/UYLgYc4uW7h43RXFsT1DngEKskBQysuBX6YEvAVUa18KU8E/siw3
         Iq9g==
X-Google-Smtp-Source: APXvYqyh3XfXaX+saiqQbN+SvHNe+NhISviQUHJzUMO7yO6EL9ZHLrr+GRkSSKPYOFlGoXNQH7wRaVl1Ncqo6jvGs0Q=
X-Received: by 2002:a02:6016:: with SMTP id i22mr5148691jac.56.1565108614630;
 Tue, 06 Aug 2019 09:23:34 -0700 (PDT)
MIME-Version: 1.0
References: <CAA=2nCbZWGvUPVeYZJB7fU7Fkmnu0MEYMDr_RYkTEY79CeLOjw@mail.gmail.com>
In-Reply-To: <CAA=2nCbZWGvUPVeYZJB7fU7Fkmnu0MEYMDr_RYkTEY79CeLOjw@mail.gmail.com>
From: Antoine Reversat <a.reversat@gmail.com>
Date: Tue, 6 Aug 2019 12:23:23 -0400
Message-ID: <CAA=2nCa1D=1vKL_w36Mru7QegktONLOsrwjjoej9qJwrTj7MmA@mail.gmail.com>
Subject: Re: [BUG] Kernel panic on >= 4.12 because of NX
To: linux-mm@kvack.org
Content-Type: multipart/alternative; boundary="00000000000002915b058f753f6d"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--00000000000002915b058f753f6d
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On a booted 5.2.5, at the point where I see the panic I get :

[    0.183953] efi: Error mapping PA 0x0 -> VA 0x0!
[    0.183956] efi: Error mapping PA 0x90000 -> VA 0x90000!
[    0.183959] efi: Error mapping PA 0x100000 -> VA 0x100000!
[    0.183961] efi: Error mapping PA 0x2165000 -> VA 0x2165000!
[    0.183963] efi: Error mapping PA 0x2200000 -> VA 0x2200000!
[    0.183966] efi: Error mapping PA 0x4265000 -> VA 0x4265000!
[    0.183968] efi: Error mapping PA 0x30ae7000 -> VA 0x30ae7000!
[    0.183971] efi: Error mapping PA 0x3456b000 -> VA 0x3456b000!
[    0.183973] efi: Error mapping PA 0x5d590000 -> VA 0x5d590000!
[    0.183975] efi: Error mapping PA 0x7c84e000 -> VA 0x7c84e000!
[    0.183978] efi: Error mapping PA 0x7c864000 -> VA 0x7c864000!
[    0.183980] efi: Error mapping PA 0x7c86f000 -> VA 0x7c86f000!
[    0.183982] efi: Error mapping PA 0x7c891000 -> VA 0x7c891000!
[    0.183985] efi: Error mapping PA 0x7c8cb000 -> VA 0x7c8cb000!
[    0.183987] efi: Error mapping PA 0x7c8d0000 -> VA 0x7c8d0000!
[    0.183989] efi: Error mapping PA 0x7d0d6000 -> VA 0x7d0d6000!
[    0.183992] efi: Error mapping PA 0x7d0d9000 -> VA 0x7d0d9000!
[    0.183994] efi: Error mapping PA 0x7d0de000 -> VA 0x7d0de000!
[    0.183996] efi: Error mapping PA 0x7d0df000 -> VA 0x7d0df000!
[    0.183999] efi: Error mapping PA 0x7d11c000 -> VA 0x7d11c000!
[    0.184001] efi: Error mapping PA 0x7d11d000 -> VA 0x7d11d000!
[    0.184003] efi: Error mapping PA 0x7e776000 -> VA 0x7e776000!
[    0.184006] efi: Error mapping PA 0x7e78b000 -> VA 0x7e78b000!
[    0.184008] efi: Error mapping PA 0x7e7cb000 -> VA 0x7e7cb000!
[    0.184010] efi: Error mapping PA 0x7e7cc000 -> VA 0x7e7cc000!
[    0.184013] efi: Error mapping PA 0x7e7d6000 -> VA 0x7e7d6000!
[    0.184015] efi: Error mapping PA 0x7e7d9000 -> VA 0x7e7d9000!
[    0.184017] efi: Error mapping PA 0x7e7dd000 -> VA 0x7e7dd000!
[    0.184020] efi: Error mapping PA 0x7e7e0000 -> VA 0x7e7e0000!
[    0.184022] efi: Error mapping PA 0x7e7e2000 -> VA 0x7e7e2000!
[    0.184025] efi: Error mapping PA 0x7e7e3000 -> VA 0x7e7e3000!
[    0.184027] efi: Error mapping PA 0x7e7e6000 -> VA 0x7e7e6000!
[    0.184029] efi: Error mapping PA 0x7e7e9000 -> VA 0x7e7e9000!
[    0.184032] efi: Error mapping PA 0x7e7eb000 -> VA 0x7e7eb000!
[    0.184034] efi: Error mapping PA 0x7e7ec000 -> VA 0x7e7ec000!
[    0.184036] efi: Error mapping PA 0x7e801000 -> VA 0x7e801000!
[    0.184039] efi: Error mapping PA 0x7e812000 -> VA 0x7e812000!
[    0.184041] efi: Error mapping PA 0x7e823000 -> VA 0x7e823000!
[    0.184043] efi: Error mapping PA 0x7e82b000 -> VA 0x7e82b000!
[    0.184046] efi: Error mapping PA 0x7e82e000 -> VA 0x7e82e000!
[    0.184048] efi: Error mapping PA 0x7e831000 -> VA 0x7e831000!
[    0.184050] efi: Error mapping PA 0x7e94d000 -> VA 0x7e94d000!
[    0.184053] efi: Error mapping PA 0x7e96f000 -> VA 0x7e96f000!
[    0.184055] efi: Error mapping PA 0x7e997000 -> VA 0x7e997000!
[    0.184057] efi: Error mapping PA 0x7e9a4000 -> VA 0x7e9a4000!
[    0.184060] efi: Error mapping PA 0x7e9b2000 -> VA 0x7e9b2000!
[    0.184062] efi: Error mapping PA 0x7ec26000 -> VA 0x7ec26000!
[    0.184065] efi: Error mapping PA 0x7ec27000 -> VA 0x7ec27000!
[    0.184067] efi: Error mapping PA 0x7f5f7000 -> VA 0x7f5f7000!
[    0.184069] efi: Error mapping PA 0x7f6f7000 -> VA 0x7f6f7000!
[    0.184072] efi: Error mapping PA 0x7f7e1000 -> VA 0x7f7e1000!
[    0.184074] efi: Error mapping PA 0x7f7f7000 -> VA 0x7f7f7000!
[    0.184076] efi: Error mapping PA 0x7f8ca000 -> VA 0x7f8ca000!
[    0.184079] efi: Error mapping PA 0x7f8f7000 -> VA 0x7f8f7000!
[    0.184081] efi: Error mapping PA 0x7fb7b000 -> VA 0x7fb7b000!
[    0.184083] efi: Error mapping PA 0x7fb89000 -> VA 0x7fb89000!
[    0.184086] efi: Error mapping PA 0x7fbbb000 -> VA 0x7fbbb000!
[    0.184088] efi: Error mapping PA 0x7fbbc000 -> VA 0x7fbbc000!
[    0.184091] efi: Error mapping PA 0x100000000 -> VA 0x100000000!
[    0.184093] efi: Error mapping PA 0xfff90000 -> VA 0xfff90000!
[    0.184097] efi: Error ident-mapping new memmap (0x17b5a4000)!

Le mar. 6 ao=C3=BBt 2019 =C3=A0 11:39, Antoine Reversat <a.reversat@gmail.c=
om> a
=C3=A9crit :

> Sorry for the maybe not so helpful title.
>
> Here is the problem :
> I'm running Linux on a Mac pro 1,1 (the first x86 mac pro). It's a dual
> xeon 5150 with ECC ram. I have 2 ram kits in it : 2x512M and 2x2G (this o=
ne
> :
> http://www.ec.kingston.com/ecom/hyperx_us/partsinfo.asp?root=3D&ktcpartno=
=3DKTA-MP667AK2/4G
> )
>
> If I only have the 2x512M kit everything works fine for all kernel
> versions but if I have both kits or just the 2x2G kit any kernel above 4.=
10
> panics very early on (picture of said panic https://imgur.com/a/PipU5Oc).
> The picture was taken on 4.15 (using earlyprintk=3Defi,keep) on other
> versions even using earlyprintk I don't get any output.
>
> I have been trying several kernels and everything up to 4.11 works no
> problem. Then on 4.11 I got a panic which mentionned NX and pages being i=
n
> W+X which prompted me to try noexec=3Doff on newer versions and that fixe=
s
> the panic. This works up to 5.2.5.
>
> /proc/cpuinfo reports that the CPU support the NX flag.
>
> I would need help in order to troubleshoot this further.
>

--00000000000002915b058f753f6d
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>On a booted 5.2.5, at the point where I see the panic=
 I get : <br></div><div><br></div><div>[ =C2=A0 =C2=A00.183953] efi: Error =
mapping PA 0x0 -&gt; VA 0x0!<br>[ =C2=A0 =C2=A00.183956] efi: Error mapping=
 PA 0x90000 -&gt; VA 0x90000!<br>[ =C2=A0 =C2=A00.183959] efi: Error mappin=
g PA 0x100000 -&gt; VA 0x100000!<br>[ =C2=A0 =C2=A00.183961] efi: Error map=
ping PA 0x2165000 -&gt; VA 0x2165000!<br>[ =C2=A0 =C2=A00.183963] efi: Erro=
r mapping PA 0x2200000 -&gt; VA 0x2200000!<br>[ =C2=A0 =C2=A00.183966] efi:=
 Error mapping PA 0x4265000 -&gt; VA 0x4265000!<br>[ =C2=A0 =C2=A00.183968]=
 efi: Error mapping PA 0x30ae7000 -&gt; VA 0x30ae7000!<br>[ =C2=A0 =C2=A00.=
183971] efi: Error mapping PA 0x3456b000 -&gt; VA 0x3456b000!<br>[ =C2=A0 =
=C2=A00.183973] efi: Error mapping PA 0x5d590000 -&gt; VA 0x5d590000!<br>[ =
=C2=A0 =C2=A00.183975] efi: Error mapping PA 0x7c84e000 -&gt; VA 0x7c84e000=
!<br>[ =C2=A0 =C2=A00.183978] efi: Error mapping PA 0x7c864000 -&gt; VA 0x7=
c864000!<br>[ =C2=A0 =C2=A00.183980] efi: Error mapping PA 0x7c86f000 -&gt;=
 VA 0x7c86f000!<br>[ =C2=A0 =C2=A00.183982] efi: Error mapping PA 0x7c89100=
0 -&gt; VA 0x7c891000!<br>[ =C2=A0 =C2=A00.183985] efi: Error mapping PA 0x=
7c8cb000 -&gt; VA 0x7c8cb000!<br>[ =C2=A0 =C2=A00.183987] efi: Error mappin=
g PA 0x7c8d0000 -&gt; VA 0x7c8d0000!<br>[ =C2=A0 =C2=A00.183989] efi: Error=
 mapping PA 0x7d0d6000 -&gt; VA 0x7d0d6000!<br>[ =C2=A0 =C2=A00.183992] efi=
: Error mapping PA 0x7d0d9000 -&gt; VA 0x7d0d9000!<br>[ =C2=A0 =C2=A00.1839=
94] efi: Error mapping PA 0x7d0de000 -&gt; VA 0x7d0de000!<br>[ =C2=A0 =C2=
=A00.183996] efi: Error mapping PA 0x7d0df000 -&gt; VA 0x7d0df000!<br>[ =C2=
=A0 =C2=A00.183999] efi: Error mapping PA 0x7d11c000 -&gt; VA 0x7d11c000!<b=
r>[ =C2=A0 =C2=A00.184001] efi: Error mapping PA 0x7d11d000 -&gt; VA 0x7d11=
d000!<br>[ =C2=A0 =C2=A00.184003] efi: Error mapping PA 0x7e776000 -&gt; VA=
 0x7e776000!<br>[ =C2=A0 =C2=A00.184006] efi: Error mapping PA 0x7e78b000 -=
&gt; VA 0x7e78b000!<br>[ =C2=A0 =C2=A00.184008] efi: Error mapping PA 0x7e7=
cb000 -&gt; VA 0x7e7cb000!<br>[ =C2=A0 =C2=A00.184010] efi: Error mapping P=
A 0x7e7cc000 -&gt; VA 0x7e7cc000!<br>[ =C2=A0 =C2=A00.184013] efi: Error ma=
pping PA 0x7e7d6000 -&gt; VA 0x7e7d6000!<br>[ =C2=A0 =C2=A00.184015] efi: E=
rror mapping PA 0x7e7d9000 -&gt; VA 0x7e7d9000!<br>[ =C2=A0 =C2=A00.184017]=
 efi: Error mapping PA 0x7e7dd000 -&gt; VA 0x7e7dd000!<br>[ =C2=A0 =C2=A00.=
184020] efi: Error mapping PA 0x7e7e0000 -&gt; VA 0x7e7e0000!<br>[ =C2=A0 =
=C2=A00.184022] efi: Error mapping PA 0x7e7e2000 -&gt; VA 0x7e7e2000!<br>[ =
=C2=A0 =C2=A00.184025] efi: Error mapping PA 0x7e7e3000 -&gt; VA 0x7e7e3000=
!<br>[ =C2=A0 =C2=A00.184027] efi: Error mapping PA 0x7e7e6000 -&gt; VA 0x7=
e7e6000!<br>[ =C2=A0 =C2=A00.184029] efi: Error mapping PA 0x7e7e9000 -&gt;=
 VA 0x7e7e9000!<br>[ =C2=A0 =C2=A00.184032] efi: Error mapping PA 0x7e7eb00=
0 -&gt; VA 0x7e7eb000!<br>[ =C2=A0 =C2=A00.184034] efi: Error mapping PA 0x=
7e7ec000 -&gt; VA 0x7e7ec000!<br>[ =C2=A0 =C2=A00.184036] efi: Error mappin=
g PA 0x7e801000 -&gt; VA 0x7e801000!<br>[ =C2=A0 =C2=A00.184039] efi: Error=
 mapping PA 0x7e812000 -&gt; VA 0x7e812000!<br>[ =C2=A0 =C2=A00.184041] efi=
: Error mapping PA 0x7e823000 -&gt; VA 0x7e823000!<br>[ =C2=A0 =C2=A00.1840=
43] efi: Error mapping PA 0x7e82b000 -&gt; VA 0x7e82b000!<br>[ =C2=A0 =C2=
=A00.184046] efi: Error mapping PA 0x7e82e000 -&gt; VA 0x7e82e000!<br>[ =C2=
=A0 =C2=A00.184048] efi: Error mapping PA 0x7e831000 -&gt; VA 0x7e831000!<b=
r>[ =C2=A0 =C2=A00.184050] efi: Error mapping PA 0x7e94d000 -&gt; VA 0x7e94=
d000!<br>[ =C2=A0 =C2=A00.184053] efi: Error mapping PA 0x7e96f000 -&gt; VA=
 0x7e96f000!<br>[ =C2=A0 =C2=A00.184055] efi: Error mapping PA 0x7e997000 -=
&gt; VA 0x7e997000!<br>[ =C2=A0 =C2=A00.184057] efi: Error mapping PA 0x7e9=
a4000 -&gt; VA 0x7e9a4000!<br>[ =C2=A0 =C2=A00.184060] efi: Error mapping P=
A 0x7e9b2000 -&gt; VA 0x7e9b2000!<br>[ =C2=A0 =C2=A00.184062] efi: Error ma=
pping PA 0x7ec26000 -&gt; VA 0x7ec26000!<br>[ =C2=A0 =C2=A00.184065] efi: E=
rror mapping PA 0x7ec27000 -&gt; VA 0x7ec27000!<br>[ =C2=A0 =C2=A00.184067]=
 efi: Error mapping PA 0x7f5f7000 -&gt; VA 0x7f5f7000!<br>[ =C2=A0 =C2=A00.=
184069] efi: Error mapping PA 0x7f6f7000 -&gt; VA 0x7f6f7000!<br>[ =C2=A0 =
=C2=A00.184072] efi: Error mapping PA 0x7f7e1000 -&gt; VA 0x7f7e1000!<br>[ =
=C2=A0 =C2=A00.184074] efi: Error mapping PA 0x7f7f7000 -&gt; VA 0x7f7f7000=
!<br>[ =C2=A0 =C2=A00.184076] efi: Error mapping PA 0x7f8ca000 -&gt; VA 0x7=
f8ca000!<br>[ =C2=A0 =C2=A00.184079] efi: Error mapping PA 0x7f8f7000 -&gt;=
 VA 0x7f8f7000!<br>[ =C2=A0 =C2=A00.184081] efi: Error mapping PA 0x7fb7b00=
0 -&gt; VA 0x7fb7b000!<br>[ =C2=A0 =C2=A00.184083] efi: Error mapping PA 0x=
7fb89000 -&gt; VA 0x7fb89000!<br>[ =C2=A0 =C2=A00.184086] efi: Error mappin=
g PA 0x7fbbb000 -&gt; VA 0x7fbbb000!<br>[ =C2=A0 =C2=A00.184088] efi: Error=
 mapping PA 0x7fbbc000 -&gt; VA 0x7fbbc000!<br>[ =C2=A0 =C2=A00.184091] efi=
: Error mapping PA 0x100000000 -&gt; VA 0x100000000!<br>[ =C2=A0 =C2=A00.18=
4093] efi: Error mapping PA 0xfff90000 -&gt; VA 0xfff90000!<br>[ =C2=A0 =C2=
=A00.184097] efi: Error ident-mapping new memmap (0x17b5a4000)!</div></div>=
<br><div class=3D"gmail_quote"><div dir=3D"ltr" class=3D"gmail_attr">Le=C2=
=A0mar. 6 ao=C3=BBt 2019 =C3=A0=C2=A011:39, Antoine Reversat &lt;<a href=3D=
"mailto:a.reversat@gmail.com">a.reversat@gmail.com</a>&gt; a =C3=A9crit=C2=
=A0:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px=
 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex"><div dir=3D=
"ltr"><div>Sorry for the maybe not so helpful title.</div><div><br></div><d=
iv>Here is the problem :</div><div>I&#39;m running Linux on a Mac pro 1,1 (=
the first x86 mac pro). It&#39;s a dual xeon 5150 with ECC ram. I have 2 ra=
m kits in it : 2x512M and 2x2G (this one : <a href=3D"http://www.ec.kingsto=
n.com/ecom/hyperx_us/partsinfo.asp?root=3D&amp;ktcpartno=3DKTA-MP667AK2/4G"=
 target=3D"_blank">http://www.ec.kingston.com/ecom/hyperx_us/partsinfo.asp?=
root=3D&amp;ktcpartno=3DKTA-MP667AK2/4G</a>)</div><div><br></div><div>If I =
only have the 2x512M kit everything works fine for all kernel versions but =
if I have both kits or just the 2x2G kit any kernel above 4.10 panics very =
early on (picture of said panic <a href=3D"https://imgur.com/a/PipU5Oc" tar=
get=3D"_blank">https://imgur.com/a/PipU5Oc</a>). The picture was taken on 4=
.15 (using earlyprintk=3Defi,keep) on other versions even using earlyprintk=
 I don&#39;t get any output.<br></div><div><br></div><div>I have been tryin=
g several kernels and everything up to 4.11 works no problem. Then on 4.11 =
I got a panic which mentionned NX and pages being in W+X which prompted me =
to try noexec=3Doff on newer versions and that fixes the panic. This works =
up to 5.2.5.<br></div><div><br></div><div>/proc/cpuinfo reports that the CP=
U support the NX flag. <br></div><div><br></div><div>I would need help in o=
rder to troubleshoot this further.<br></div></div>
</blockquote></div>

--00000000000002915b058f753f6d--

