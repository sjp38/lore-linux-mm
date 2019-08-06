Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B410C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:25:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20A5B2086D
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:25:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="J7hvxN29"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20A5B2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B79CB6B027A; Tue,  6 Aug 2019 12:25:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2AAD6B027C; Tue,  6 Aug 2019 12:25:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F2F06B027D; Tue,  6 Aug 2019 12:25:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7168E6B027A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:25:25 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id u200so35280081oia.23
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:25:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to;
        bh=ZeU3SBOMgPUc0QHo5bkyc6KqfOvXEn3bMwSky0ACaog=;
        b=ADv1q7lE0e6uUsgLEyL1KndG8LiIL+CdWBqKI1TSI1iCKPnxPn3otD+hid2lE83rLC
         vWTqUyiBXNNCuSnO/rXqQEQRJijhSX3sOgyOO1xNbT909Y4KTYe34zLx3451f8DzfuQV
         idvxBlzF83ap44MoJN/JyVzwmWbm6KVREVrLWKi72S99DfAD9L8TlcqhcacUXp1XX+cz
         m7y1QaWK+FQduLz6MVjYQzsKjf/I15awS7Hm4UH3OxyVuEvxAtJSPrignnc89csp/tVD
         yqyBr3RvI4TgF6TX5ViQR2+GiRV8VUN0Y7AwATsBtXJTq5JYGHEa4d5dgaE2oxAIUMVp
         OxGg==
X-Gm-Message-State: APjAAAV5CFNMRRXsknIWLCvBtLZS+quIm+7kAOezQiUSi7vWZe+/UwtY
	J86zxySHHJ1hDnSCJnLVcxdIMmBkFAXeFDJ02XnlXTTJOjvffis7tSPaAUWGSFNk+mVyNva8w1Y
	lK6aZUslbQn/GMDyFfi9K9B4EUh9zGawz48gpT11vI8ZHtrlMdfwDWktVxmwXowXdxg==
X-Received: by 2002:a02:90c8:: with SMTP id c8mr5116364jag.22.1565108725164;
        Tue, 06 Aug 2019 09:25:25 -0700 (PDT)
X-Received: by 2002:a02:90c8:: with SMTP id c8mr5115520jag.22.1565108714452;
        Tue, 06 Aug 2019 09:25:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565108714; cv=none;
        d=google.com; s=arc-20160816;
        b=Hd5h9yBvmySVuZA4SJSvvy/UvN8nL2Fk3k9BRld6wg8NoYSWdc6+52YZMAS9XTwN5+
         AyMk2+ZWx5gR+pffoJ1DySrhqpj5ov8VcLJ7M7zCKY9n8OtDH7t79ZjRWFv588qHJFGh
         bXfUOvi5VL3hclUdBHkGoBVETGOrntSyu2CibsSMp0LR+uHWDKP7rhWnsL5aG6UzGaPL
         E0M/bnsBjxn9LRNTmb4fPtzt9wjBMmLDl69qJmXAlR1Pmo+BEE1KHWYFnaqZ/cBmgjzQ
         EaPOqLs9c9RMVkV+ArGo7j7/dnYE4y/8cB+wJ2wl4/ak4Z6Ud7zp3aC52TT8Oe7O0jEC
         Vm4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:in-reply-to:references:mime-version
         :dkim-signature;
        bh=ZeU3SBOMgPUc0QHo5bkyc6KqfOvXEn3bMwSky0ACaog=;
        b=tl+zfTMvH48tPQVo63Y9FqD94G7di3s5/28qMXv29mmXT5bh2hxlArPG0nEWe2cqM7
         eH0HfGU4uEiY/f4xhUA0TdahdO4eFw8tDBLSBgzDDu1M7fjKUHSG9UETTu4GuYGxAQHr
         pspaIyK4F1DCHG5zKD4DmipUfEJkpQkU+/0fOJDbaiXquik5epRlChRlSZwMO2W6ou+t
         eEo02fDuRw1GHpK7/moM/aCWx/QLgpx6BdbDyUZnpdNVvf+vKp3EUPg4pDY8Jrs5zVL2
         nBqu+b2hauFX3QUoTYmRaIoNKdfwIck5DytrVR8aHVh5U1prC8t4EX2lchhvxPJotJWM
         wtKA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=J7hvxN29;
       spf=pass (google.com: domain of a.reversat@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=a.reversat@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v5sor202395153jan.4.2019.08.06.09.25.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 09:25:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of a.reversat@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=J7hvxN29;
       spf=pass (google.com: domain of a.reversat@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=a.reversat@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to;
        bh=ZeU3SBOMgPUc0QHo5bkyc6KqfOvXEn3bMwSky0ACaog=;
        b=J7hvxN291Nnl4txWPlqoo0aVxOdLWeiFIHcEW3xZnqTeuh2oIhrYKkX8NbzlZMCP7E
         eUqef0z3EmKFdbexrrAZhiW6EwpzXh7ctDJLM4hhFFiddfJ0+wje9J5L7U8VFnHeojhV
         NvzRJyfad2MhqZJ/t2KKHLbMqZ25GlPEAf7iWPNEOumnbgoXiRgqZjThBPA6Be36MBs6
         QrHT7ND94ijL6HHWGjMbsEiZfncnEWtC3rYv4yp18oCtCBzX25BmYdNGptSvdPa1smFV
         TJ6KS0VAv+HsZW2j9txwgVMWk3RReQRPmyqgIub3nKsDUov2EoEpWWCtae4kGqTJONjI
         qNvw==
X-Google-Smtp-Source: APXvYqyrPUOn/bNUIOvdDKX7WrMpBVocYumr5qPj2oGO68VgWam9oXpYzaJF0XOmhMPJm0wHFxIK+fPRiYw83Rtav50=
X-Received: by 2002:a02:528a:: with SMTP id d132mr4906225jab.68.1565108713952;
 Tue, 06 Aug 2019 09:25:13 -0700 (PDT)
MIME-Version: 1.0
References: <CAA=2nCbZWGvUPVeYZJB7fU7Fkmnu0MEYMDr_RYkTEY79CeLOjw@mail.gmail.com>
 <CAA=2nCa1D=1vKL_w36Mru7QegktONLOsrwjjoej9qJwrTj7MmA@mail.gmail.com>
In-Reply-To: <CAA=2nCa1D=1vKL_w36Mru7QegktONLOsrwjjoej9qJwrTj7MmA@mail.gmail.com>
From: Antoine Reversat <a.reversat@gmail.com>
Date: Tue, 6 Aug 2019 12:25:02 -0400
Message-ID: <CAA=2nCZbZDxF4bDQ22Lu0fbUyzmCAoWJKtU1XLrfdtmkJ84J9w@mail.gmail.com>
Subject: Re: [BUG] Kernel panic on >= 4.12 because of NX
To: linux-mm@kvack.org
Content-Type: multipart/alternative; boundary="000000000000ee1825058f75447f"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000ee1825058f75447f
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Could this be caused by the fact that this machine uses a 32bit efi bios on
a 64bit platform ?

Le mar. 6 ao=C3=BBt 2019 =C3=A0 12:23, Antoine Reversat <a.reversat@gmail.c=
om> a
=C3=A9crit :

> On a booted 5.2.5, at the point where I see the panic I get :
>
> [    0.183953] efi: Error mapping PA 0x0 -> VA 0x0!
> [    0.183956] efi: Error mapping PA 0x90000 -> VA 0x90000!
> [    0.183959] efi: Error mapping PA 0x100000 -> VA 0x100000!
> [    0.183961] efi: Error mapping PA 0x2165000 -> VA 0x2165000!
> [    0.183963] efi: Error mapping PA 0x2200000 -> VA 0x2200000!
> [    0.183966] efi: Error mapping PA 0x4265000 -> VA 0x4265000!
> [    0.183968] efi: Error mapping PA 0x30ae7000 -> VA 0x30ae7000!
> [    0.183971] efi: Error mapping PA 0x3456b000 -> VA 0x3456b000!
> [    0.183973] efi: Error mapping PA 0x5d590000 -> VA 0x5d590000!
> [    0.183975] efi: Error mapping PA 0x7c84e000 -> VA 0x7c84e000!
> [    0.183978] efi: Error mapping PA 0x7c864000 -> VA 0x7c864000!
> [    0.183980] efi: Error mapping PA 0x7c86f000 -> VA 0x7c86f000!
> [    0.183982] efi: Error mapping PA 0x7c891000 -> VA 0x7c891000!
> [    0.183985] efi: Error mapping PA 0x7c8cb000 -> VA 0x7c8cb000!
> [    0.183987] efi: Error mapping PA 0x7c8d0000 -> VA 0x7c8d0000!
> [    0.183989] efi: Error mapping PA 0x7d0d6000 -> VA 0x7d0d6000!
> [    0.183992] efi: Error mapping PA 0x7d0d9000 -> VA 0x7d0d9000!
> [    0.183994] efi: Error mapping PA 0x7d0de000 -> VA 0x7d0de000!
> [    0.183996] efi: Error mapping PA 0x7d0df000 -> VA 0x7d0df000!
> [    0.183999] efi: Error mapping PA 0x7d11c000 -> VA 0x7d11c000!
> [    0.184001] efi: Error mapping PA 0x7d11d000 -> VA 0x7d11d000!
> [    0.184003] efi: Error mapping PA 0x7e776000 -> VA 0x7e776000!
> [    0.184006] efi: Error mapping PA 0x7e78b000 -> VA 0x7e78b000!
> [    0.184008] efi: Error mapping PA 0x7e7cb000 -> VA 0x7e7cb000!
> [    0.184010] efi: Error mapping PA 0x7e7cc000 -> VA 0x7e7cc000!
> [    0.184013] efi: Error mapping PA 0x7e7d6000 -> VA 0x7e7d6000!
> [    0.184015] efi: Error mapping PA 0x7e7d9000 -> VA 0x7e7d9000!
> [    0.184017] efi: Error mapping PA 0x7e7dd000 -> VA 0x7e7dd000!
> [    0.184020] efi: Error mapping PA 0x7e7e0000 -> VA 0x7e7e0000!
> [    0.184022] efi: Error mapping PA 0x7e7e2000 -> VA 0x7e7e2000!
> [    0.184025] efi: Error mapping PA 0x7e7e3000 -> VA 0x7e7e3000!
> [    0.184027] efi: Error mapping PA 0x7e7e6000 -> VA 0x7e7e6000!
> [    0.184029] efi: Error mapping PA 0x7e7e9000 -> VA 0x7e7e9000!
> [    0.184032] efi: Error mapping PA 0x7e7eb000 -> VA 0x7e7eb000!
> [    0.184034] efi: Error mapping PA 0x7e7ec000 -> VA 0x7e7ec000!
> [    0.184036] efi: Error mapping PA 0x7e801000 -> VA 0x7e801000!
> [    0.184039] efi: Error mapping PA 0x7e812000 -> VA 0x7e812000!
> [    0.184041] efi: Error mapping PA 0x7e823000 -> VA 0x7e823000!
> [    0.184043] efi: Error mapping PA 0x7e82b000 -> VA 0x7e82b000!
> [    0.184046] efi: Error mapping PA 0x7e82e000 -> VA 0x7e82e000!
> [    0.184048] efi: Error mapping PA 0x7e831000 -> VA 0x7e831000!
> [    0.184050] efi: Error mapping PA 0x7e94d000 -> VA 0x7e94d000!
> [    0.184053] efi: Error mapping PA 0x7e96f000 -> VA 0x7e96f000!
> [    0.184055] efi: Error mapping PA 0x7e997000 -> VA 0x7e997000!
> [    0.184057] efi: Error mapping PA 0x7e9a4000 -> VA 0x7e9a4000!
> [    0.184060] efi: Error mapping PA 0x7e9b2000 -> VA 0x7e9b2000!
> [    0.184062] efi: Error mapping PA 0x7ec26000 -> VA 0x7ec26000!
> [    0.184065] efi: Error mapping PA 0x7ec27000 -> VA 0x7ec27000!
> [    0.184067] efi: Error mapping PA 0x7f5f7000 -> VA 0x7f5f7000!
> [    0.184069] efi: Error mapping PA 0x7f6f7000 -> VA 0x7f6f7000!
> [    0.184072] efi: Error mapping PA 0x7f7e1000 -> VA 0x7f7e1000!
> [    0.184074] efi: Error mapping PA 0x7f7f7000 -> VA 0x7f7f7000!
> [    0.184076] efi: Error mapping PA 0x7f8ca000 -> VA 0x7f8ca000!
> [    0.184079] efi: Error mapping PA 0x7f8f7000 -> VA 0x7f8f7000!
> [    0.184081] efi: Error mapping PA 0x7fb7b000 -> VA 0x7fb7b000!
> [    0.184083] efi: Error mapping PA 0x7fb89000 -> VA 0x7fb89000!
> [    0.184086] efi: Error mapping PA 0x7fbbb000 -> VA 0x7fbbb000!
> [    0.184088] efi: Error mapping PA 0x7fbbc000 -> VA 0x7fbbc000!
> [    0.184091] efi: Error mapping PA 0x100000000 -> VA 0x100000000!
> [    0.184093] efi: Error mapping PA 0xfff90000 -> VA 0xfff90000!
> [    0.184097] efi: Error ident-mapping new memmap (0x17b5a4000)!
>
> Le mar. 6 ao=C3=BBt 2019 =C3=A0 11:39, Antoine Reversat <a.reversat@gmail=
.com> a
> =C3=A9crit :
>
>> Sorry for the maybe not so helpful title.
>>
>> Here is the problem :
>> I'm running Linux on a Mac pro 1,1 (the first x86 mac pro). It's a dual
>> xeon 5150 with ECC ram. I have 2 ram kits in it : 2x512M and 2x2G (this =
one
>> :
>> http://www.ec.kingston.com/ecom/hyperx_us/partsinfo.asp?root=3D&ktcpartn=
o=3DKTA-MP667AK2/4G
>> )
>>
>> If I only have the 2x512M kit everything works fine for all kernel
>> versions but if I have both kits or just the 2x2G kit any kernel above 4=
.10
>> panics very early on (picture of said panic https://imgur.com/a/PipU5Oc)=
.
>> The picture was taken on 4.15 (using earlyprintk=3Defi,keep) on other
>> versions even using earlyprintk I don't get any output.
>>
>> I have been trying several kernels and everything up to 4.11 works no
>> problem. Then on 4.11 I got a panic which mentionned NX and pages being =
in
>> W+X which prompted me to try noexec=3Doff on newer versions and that fix=
es
>> the panic. This works up to 5.2.5.
>>
>> /proc/cpuinfo reports that the CPU support the NX flag.
>>
>> I would need help in order to troubleshoot this further.
>>
>

--000000000000ee1825058f75447f
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Could this be caused by the fact that this machine uses a =
32bit efi bios on a 64bit platform ?<br></div><br><div class=3D"gmail_quote=
"><div dir=3D"ltr" class=3D"gmail_attr">Le=C2=A0mar. 6 ao=C3=BBt 2019 =C3=
=A0=C2=A012:23, Antoine Reversat &lt;<a href=3D"mailto:a.reversat@gmail.com=
">a.reversat@gmail.com</a>&gt; a =C3=A9crit=C2=A0:<br></div><blockquote cla=
ss=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid =
rgb(204,204,204);padding-left:1ex"><div dir=3D"ltr"><div>On a booted 5.2.5,=
 at the point where I see the panic I get : <br></div><div><br></div><div>[=
 =C2=A0 =C2=A00.183953] efi: Error mapping PA 0x0 -&gt; VA 0x0!<br>[ =C2=A0=
 =C2=A00.183956] efi: Error mapping PA 0x90000 -&gt; VA 0x90000!<br>[ =C2=
=A0 =C2=A00.183959] efi: Error mapping PA 0x100000 -&gt; VA 0x100000!<br>[ =
=C2=A0 =C2=A00.183961] efi: Error mapping PA 0x2165000 -&gt; VA 0x2165000!<=
br>[ =C2=A0 =C2=A00.183963] efi: Error mapping PA 0x2200000 -&gt; VA 0x2200=
000!<br>[ =C2=A0 =C2=A00.183966] efi: Error mapping PA 0x4265000 -&gt; VA 0=
x4265000!<br>[ =C2=A0 =C2=A00.183968] efi: Error mapping PA 0x30ae7000 -&gt=
; VA 0x30ae7000!<br>[ =C2=A0 =C2=A00.183971] efi: Error mapping PA 0x3456b0=
00 -&gt; VA 0x3456b000!<br>[ =C2=A0 =C2=A00.183973] efi: Error mapping PA 0=
x5d590000 -&gt; VA 0x5d590000!<br>[ =C2=A0 =C2=A00.183975] efi: Error mappi=
ng PA 0x7c84e000 -&gt; VA 0x7c84e000!<br>[ =C2=A0 =C2=A00.183978] efi: Erro=
r mapping PA 0x7c864000 -&gt; VA 0x7c864000!<br>[ =C2=A0 =C2=A00.183980] ef=
i: Error mapping PA 0x7c86f000 -&gt; VA 0x7c86f000!<br>[ =C2=A0 =C2=A00.183=
982] efi: Error mapping PA 0x7c891000 -&gt; VA 0x7c891000!<br>[ =C2=A0 =C2=
=A00.183985] efi: Error mapping PA 0x7c8cb000 -&gt; VA 0x7c8cb000!<br>[ =C2=
=A0 =C2=A00.183987] efi: Error mapping PA 0x7c8d0000 -&gt; VA 0x7c8d0000!<b=
r>[ =C2=A0 =C2=A00.183989] efi: Error mapping PA 0x7d0d6000 -&gt; VA 0x7d0d=
6000!<br>[ =C2=A0 =C2=A00.183992] efi: Error mapping PA 0x7d0d9000 -&gt; VA=
 0x7d0d9000!<br>[ =C2=A0 =C2=A00.183994] efi: Error mapping PA 0x7d0de000 -=
&gt; VA 0x7d0de000!<br>[ =C2=A0 =C2=A00.183996] efi: Error mapping PA 0x7d0=
df000 -&gt; VA 0x7d0df000!<br>[ =C2=A0 =C2=A00.183999] efi: Error mapping P=
A 0x7d11c000 -&gt; VA 0x7d11c000!<br>[ =C2=A0 =C2=A00.184001] efi: Error ma=
pping PA 0x7d11d000 -&gt; VA 0x7d11d000!<br>[ =C2=A0 =C2=A00.184003] efi: E=
rror mapping PA 0x7e776000 -&gt; VA 0x7e776000!<br>[ =C2=A0 =C2=A00.184006]=
 efi: Error mapping PA 0x7e78b000 -&gt; VA 0x7e78b000!<br>[ =C2=A0 =C2=A00.=
184008] efi: Error mapping PA 0x7e7cb000 -&gt; VA 0x7e7cb000!<br>[ =C2=A0 =
=C2=A00.184010] efi: Error mapping PA 0x7e7cc000 -&gt; VA 0x7e7cc000!<br>[ =
=C2=A0 =C2=A00.184013] efi: Error mapping PA 0x7e7d6000 -&gt; VA 0x7e7d6000=
!<br>[ =C2=A0 =C2=A00.184015] efi: Error mapping PA 0x7e7d9000 -&gt; VA 0x7=
e7d9000!<br>[ =C2=A0 =C2=A00.184017] efi: Error mapping PA 0x7e7dd000 -&gt;=
 VA 0x7e7dd000!<br>[ =C2=A0 =C2=A00.184020] efi: Error mapping PA 0x7e7e000=
0 -&gt; VA 0x7e7e0000!<br>[ =C2=A0 =C2=A00.184022] efi: Error mapping PA 0x=
7e7e2000 -&gt; VA 0x7e7e2000!<br>[ =C2=A0 =C2=A00.184025] efi: Error mappin=
g PA 0x7e7e3000 -&gt; VA 0x7e7e3000!<br>[ =C2=A0 =C2=A00.184027] efi: Error=
 mapping PA 0x7e7e6000 -&gt; VA 0x7e7e6000!<br>[ =C2=A0 =C2=A00.184029] efi=
: Error mapping PA 0x7e7e9000 -&gt; VA 0x7e7e9000!<br>[ =C2=A0 =C2=A00.1840=
32] efi: Error mapping PA 0x7e7eb000 -&gt; VA 0x7e7eb000!<br>[ =C2=A0 =C2=
=A00.184034] efi: Error mapping PA 0x7e7ec000 -&gt; VA 0x7e7ec000!<br>[ =C2=
=A0 =C2=A00.184036] efi: Error mapping PA 0x7e801000 -&gt; VA 0x7e801000!<b=
r>[ =C2=A0 =C2=A00.184039] efi: Error mapping PA 0x7e812000 -&gt; VA 0x7e81=
2000!<br>[ =C2=A0 =C2=A00.184041] efi: Error mapping PA 0x7e823000 -&gt; VA=
 0x7e823000!<br>[ =C2=A0 =C2=A00.184043] efi: Error mapping PA 0x7e82b000 -=
&gt; VA 0x7e82b000!<br>[ =C2=A0 =C2=A00.184046] efi: Error mapping PA 0x7e8=
2e000 -&gt; VA 0x7e82e000!<br>[ =C2=A0 =C2=A00.184048] efi: Error mapping P=
A 0x7e831000 -&gt; VA 0x7e831000!<br>[ =C2=A0 =C2=A00.184050] efi: Error ma=
pping PA 0x7e94d000 -&gt; VA 0x7e94d000!<br>[ =C2=A0 =C2=A00.184053] efi: E=
rror mapping PA 0x7e96f000 -&gt; VA 0x7e96f000!<br>[ =C2=A0 =C2=A00.184055]=
 efi: Error mapping PA 0x7e997000 -&gt; VA 0x7e997000!<br>[ =C2=A0 =C2=A00.=
184057] efi: Error mapping PA 0x7e9a4000 -&gt; VA 0x7e9a4000!<br>[ =C2=A0 =
=C2=A00.184060] efi: Error mapping PA 0x7e9b2000 -&gt; VA 0x7e9b2000!<br>[ =
=C2=A0 =C2=A00.184062] efi: Error mapping PA 0x7ec26000 -&gt; VA 0x7ec26000=
!<br>[ =C2=A0 =C2=A00.184065] efi: Error mapping PA 0x7ec27000 -&gt; VA 0x7=
ec27000!<br>[ =C2=A0 =C2=A00.184067] efi: Error mapping PA 0x7f5f7000 -&gt;=
 VA 0x7f5f7000!<br>[ =C2=A0 =C2=A00.184069] efi: Error mapping PA 0x7f6f700=
0 -&gt; VA 0x7f6f7000!<br>[ =C2=A0 =C2=A00.184072] efi: Error mapping PA 0x=
7f7e1000 -&gt; VA 0x7f7e1000!<br>[ =C2=A0 =C2=A00.184074] efi: Error mappin=
g PA 0x7f7f7000 -&gt; VA 0x7f7f7000!<br>[ =C2=A0 =C2=A00.184076] efi: Error=
 mapping PA 0x7f8ca000 -&gt; VA 0x7f8ca000!<br>[ =C2=A0 =C2=A00.184079] efi=
: Error mapping PA 0x7f8f7000 -&gt; VA 0x7f8f7000!<br>[ =C2=A0 =C2=A00.1840=
81] efi: Error mapping PA 0x7fb7b000 -&gt; VA 0x7fb7b000!<br>[ =C2=A0 =C2=
=A00.184083] efi: Error mapping PA 0x7fb89000 -&gt; VA 0x7fb89000!<br>[ =C2=
=A0 =C2=A00.184086] efi: Error mapping PA 0x7fbbb000 -&gt; VA 0x7fbbb000!<b=
r>[ =C2=A0 =C2=A00.184088] efi: Error mapping PA 0x7fbbc000 -&gt; VA 0x7fbb=
c000!<br>[ =C2=A0 =C2=A00.184091] efi: Error mapping PA 0x100000000 -&gt; V=
A 0x100000000!<br>[ =C2=A0 =C2=A00.184093] efi: Error mapping PA 0xfff90000=
 -&gt; VA 0xfff90000!<br>[ =C2=A0 =C2=A00.184097] efi: Error ident-mapping =
new memmap (0x17b5a4000)!</div></div><br><div class=3D"gmail_quote"><div di=
r=3D"ltr" class=3D"gmail_attr">Le=C2=A0mar. 6 ao=C3=BBt 2019 =C3=A0=C2=A011=
:39, Antoine Reversat &lt;<a href=3D"mailto:a.reversat@gmail.com" target=3D=
"_blank">a.reversat@gmail.com</a>&gt; a =C3=A9crit=C2=A0:<br></div><blockqu=
ote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px=
 solid rgb(204,204,204);padding-left:1ex"><div dir=3D"ltr"><div>Sorry for t=
he maybe not so helpful title.</div><div><br></div><div>Here is the problem=
 :</div><div>I&#39;m running Linux on a Mac pro 1,1 (the first x86 mac pro)=
. It&#39;s a dual xeon 5150 with ECC ram. I have 2 ram kits in it : 2x512M =
and 2x2G (this one : <a href=3D"http://www.ec.kingston.com/ecom/hyperx_us/p=
artsinfo.asp?root=3D&amp;ktcpartno=3DKTA-MP667AK2/4G" target=3D"_blank">htt=
p://www.ec.kingston.com/ecom/hyperx_us/partsinfo.asp?root=3D&amp;ktcpartno=
=3DKTA-MP667AK2/4G</a>)</div><div><br></div><div>If I only have the 2x512M =
kit everything works fine for all kernel versions but if I have both kits o=
r just the 2x2G kit any kernel above 4.10 panics very early on (picture of =
said panic <a href=3D"https://imgur.com/a/PipU5Oc" target=3D"_blank">https:=
//imgur.com/a/PipU5Oc</a>). The picture was taken on 4.15 (using earlyprint=
k=3Defi,keep) on other versions even using earlyprintk I don&#39;t get any =
output.<br></div><div><br></div><div>I have been trying several kernels and=
 everything up to 4.11 works no problem. Then on 4.11 I got a panic which m=
entionned NX and pages being in W+X which prompted me to try noexec=3Doff o=
n newer versions and that fixes the panic. This works up to 5.2.5.<br></div=
><div><br></div><div>/proc/cpuinfo reports that the CPU support the NX flag=
. <br></div><div><br></div><div>I would need help in order to troubleshoot =
this further.<br></div></div>
</blockquote></div>
</blockquote></div>

--000000000000ee1825058f75447f--

