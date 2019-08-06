Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9ABA0C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 17:34:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39B6A2075B
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 17:34:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ufkf+wKe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39B6A2075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA57F6B0007; Tue,  6 Aug 2019 13:34:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2E9B6B0008; Tue,  6 Aug 2019 13:34:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD04D6B000A; Tue,  6 Aug 2019 13:34:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7F12E6B0007
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 13:34:31 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id w5so50024533otg.0
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 10:34:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to;
        bh=fT7csg5lAZv8BudUFmwzu8/aZHQNMKh1N+jjXv4hPDg=;
        b=qFgTo+4YDYNBpiHxIJc9qlvaqUqBJ79N6+L/OUaJ70+SwQNZtrRVYn99kEFv/ttmCl
         9y8G799uz/EEDIyN91MNDiuYtMTkjI+cLn2VjhC2DxCKwXviDnHXgjO3kNPvJcMdQmeq
         Vdn8o4SwzYTYsK9yoTMZdphzRpFXPlIkeEXlAlaLLaCNG36sQG8u2A330iBncLonXd/8
         7+wnTEdk6StWyLVLO3d+0vtDTzZKwkPyvUMsnezexvYZLj1rH0HiNT+J4stGcrbn7IVC
         VF5QAbcHyiCDEZLB1sw5NX38cjrWa8O/yMo5vN9He4jUnXIQ2YAoBLFe3Ek/RY4+swqf
         Uc6A==
X-Gm-Message-State: APjAAAVFRq5adH9g07qF5PDAEDKQ4nONFfyIyaXjKsENh67XDXGnTeYl
	Jbaa4iaFsKpLYSpzC512AwHThbC1gwVCXhI2A7Wm4NN1GN+dA6A2ibIPelbf3sfnNT6JZmxxGr+
	vARB31Opk1IsZIhFPYzNMXVIZVrj/NKMXiCQ4gYCyCK2TK6WhL95OGbSQ3c94gDlBOg==
X-Received: by 2002:a5d:885a:: with SMTP id t26mr4477121ios.218.1565112871235;
        Tue, 06 Aug 2019 10:34:31 -0700 (PDT)
X-Received: by 2002:a5d:885a:: with SMTP id t26mr4476908ios.218.1565112868440;
        Tue, 06 Aug 2019 10:34:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565112868; cv=none;
        d=google.com; s=arc-20160816;
        b=padRZN4QAvMaN1C7dItmqaIDVwthv1EgH27VrFOtFSFORXZZ0ufFlbmaN4NZzkbTIc
         mHw+0Sr7VK0f9nlUJrKj1sU1cgLtx/EK1Fo4GJrmoBLLsHt8OY5BC1A/5vHAJYFkf3c+
         WdFqBAFfub7Bj7HO7osZ17AYcYAr8pl0jVobbCECoqvm2uawTfVSFW7JK99sseWvlO5F
         lI7PToFsq2l7PtbkMnsWmrTItntqrvRLwXSGlzosOqwjRo4qBFvH4IRMqL6WNomx3q9h
         L/qgT8XQQI7Lc4c6RNfO8lXO3nPe6456u5UwO9O3OSQyaCc4wxOUjt+VBGPsVVy165SD
         NTeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:in-reply-to:references:mime-version
         :dkim-signature;
        bh=fT7csg5lAZv8BudUFmwzu8/aZHQNMKh1N+jjXv4hPDg=;
        b=iSXdUxnqpQbqg0I8F0K7FFkvEsfRs3DyRbXDhe1BG2Bgy1BqzzeZxjDE3KlqPifcml
         aEBUBTy8c7G9zWLf3Hpj+vf56aYru1KL/uDBmQ6BRCfjwC3e8wS4doj5FNL9irVSzzps
         qikFaiUhqG1eCoZ1J2RgqZ+9tYnGdCmwI+FCZGaXbjD2Ijq8A6BJzmW0fM7+ONWO6Dkm
         A/83dAaiyvAPa7Tb0KZExLG0nVks43CGwM76LbcB/FlRqr5wAaR6T6qZAHbal4qdnUiO
         eUv3mEQzg9z1y6HEq6p8T7jdKFeYlnJoH7gbZeEgkpalGEHrOFmUxDPELcwQeEkkFU84
         YuXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ufkf+wKe;
       spf=pass (google.com: domain of a.reversat@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=a.reversat@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x6sor60708339ioa.24.2019.08.06.10.34.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 10:34:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of a.reversat@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ufkf+wKe;
       spf=pass (google.com: domain of a.reversat@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=a.reversat@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to;
        bh=fT7csg5lAZv8BudUFmwzu8/aZHQNMKh1N+jjXv4hPDg=;
        b=ufkf+wKeVdUlGc8obq0nb6I86qcgmuQaEl2fCeXW6LRSU2pL7J8HRsC2+WO2Vd0LEc
         iwEyv53MYKb9jhlaURxhwbJI9RvEGoHeiXj3Ibm5QLr89vcjdNBg9/C6ad7V4iythcts
         R87DN3O4L3/fH26xMEBTXEFMBSUEeQAsX3t7vhi0MRkUB3ANg5Pm4P6GQLal+wMjd0K6
         FUY/y/NkNM+kFiHMfKV7gRAhdUuqjFZPcBuWA9GZJVJl06zi3y41wYwpH2odbZzwYLY/
         TGHqJB9ur8ejxzK85NA65PH7/ixRTQK+HB/MYAvoldT6iEcagjas3gRQZ9qTYfbLo1X3
         CIbg==
X-Google-Smtp-Source: APXvYqx/uXRkUgUhMjHPJog7qXD21ovTrICe/JGAf5Vz8BbxsIVj1ZzjRpWOZeSB9L2DHskQA8ue8uM8WwLeY8IPMyI=
X-Received: by 2002:a5d:8249:: with SMTP id n9mr4746822ioo.14.1565112867888;
 Tue, 06 Aug 2019 10:34:27 -0700 (PDT)
MIME-Version: 1.0
References: <CAA=2nCbZWGvUPVeYZJB7fU7Fkmnu0MEYMDr_RYkTEY79CeLOjw@mail.gmail.com>
 <CAA=2nCa1D=1vKL_w36Mru7QegktONLOsrwjjoej9qJwrTj7MmA@mail.gmail.com> <CAA=2nCZbZDxF4bDQ22Lu0fbUyzmCAoWJKtU1XLrfdtmkJ84J9w@mail.gmail.com>
In-Reply-To: <CAA=2nCZbZDxF4bDQ22Lu0fbUyzmCAoWJKtU1XLrfdtmkJ84J9w@mail.gmail.com>
From: Antoine Reversat <a.reversat@gmail.com>
Date: Tue, 6 Aug 2019 13:34:16 -0400
Message-ID: <CAA=2nCZNA5iGQk3QRCzAbSMrCst0oWqi_OCLEO6A7Ux8A3+dbg@mail.gmail.com>
Subject: Re: [BUG] Kernel panic on >= 4.12 because of NX
To: linux-mm@kvack.org
Content-Type: multipart/alternative; boundary="0000000000008622f5058f763c47"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000077, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000008622f5058f763c47
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

As it turns out adding the efi=3Dold_map kernel parameter (and removing
noexec=3Doff) also fixes the issue.

Le mar. 6 ao=C3=BBt 2019 =C3=A0 12:25, Antoine Reversat <a.reversat@gmail.c=
om> a
=C3=A9crit :

> Could this be caused by the fact that this machine uses a 32bit efi bios
> on a 64bit platform ?
>
> Le mar. 6 ao=C3=BBt 2019 =C3=A0 12:23, Antoine Reversat <a.reversat@gmail=
.com> a
> =C3=A9crit :
>
>> On a booted 5.2.5, at the point where I see the panic I get :
>>
>> [    0.183953] efi: Error mapping PA 0x0 -> VA 0x0!
>> [    0.183956] efi: Error mapping PA 0x90000 -> VA 0x90000!
>> [    0.183959] efi: Error mapping PA 0x100000 -> VA 0x100000!
>> [    0.183961] efi: Error mapping PA 0x2165000 -> VA 0x2165000!
>> [    0.183963] efi: Error mapping PA 0x2200000 -> VA 0x2200000!
>> [    0.183966] efi: Error mapping PA 0x4265000 -> VA 0x4265000!
>> [    0.183968] efi: Error mapping PA 0x30ae7000 -> VA 0x30ae7000!
>> [    0.183971] efi: Error mapping PA 0x3456b000 -> VA 0x3456b000!
>> [    0.183973] efi: Error mapping PA 0x5d590000 -> VA 0x5d590000!
>> [    0.183975] efi: Error mapping PA 0x7c84e000 -> VA 0x7c84e000!
>> [    0.183978] efi: Error mapping PA 0x7c864000 -> VA 0x7c864000!
>> [    0.183980] efi: Error mapping PA 0x7c86f000 -> VA 0x7c86f000!
>> [    0.183982] efi: Error mapping PA 0x7c891000 -> VA 0x7c891000!
>> [    0.183985] efi: Error mapping PA 0x7c8cb000 -> VA 0x7c8cb000!
>> [    0.183987] efi: Error mapping PA 0x7c8d0000 -> VA 0x7c8d0000!
>> [    0.183989] efi: Error mapping PA 0x7d0d6000 -> VA 0x7d0d6000!
>> [    0.183992] efi: Error mapping PA 0x7d0d9000 -> VA 0x7d0d9000!
>> [    0.183994] efi: Error mapping PA 0x7d0de000 -> VA 0x7d0de000!
>> [    0.183996] efi: Error mapping PA 0x7d0df000 -> VA 0x7d0df000!
>> [    0.183999] efi: Error mapping PA 0x7d11c000 -> VA 0x7d11c000!
>> [    0.184001] efi: Error mapping PA 0x7d11d000 -> VA 0x7d11d000!
>> [    0.184003] efi: Error mapping PA 0x7e776000 -> VA 0x7e776000!
>> [    0.184006] efi: Error mapping PA 0x7e78b000 -> VA 0x7e78b000!
>> [    0.184008] efi: Error mapping PA 0x7e7cb000 -> VA 0x7e7cb000!
>> [    0.184010] efi: Error mapping PA 0x7e7cc000 -> VA 0x7e7cc000!
>> [    0.184013] efi: Error mapping PA 0x7e7d6000 -> VA 0x7e7d6000!
>> [    0.184015] efi: Error mapping PA 0x7e7d9000 -> VA 0x7e7d9000!
>> [    0.184017] efi: Error mapping PA 0x7e7dd000 -> VA 0x7e7dd000!
>> [    0.184020] efi: Error mapping PA 0x7e7e0000 -> VA 0x7e7e0000!
>> [    0.184022] efi: Error mapping PA 0x7e7e2000 -> VA 0x7e7e2000!
>> [    0.184025] efi: Error mapping PA 0x7e7e3000 -> VA 0x7e7e3000!
>> [    0.184027] efi: Error mapping PA 0x7e7e6000 -> VA 0x7e7e6000!
>> [    0.184029] efi: Error mapping PA 0x7e7e9000 -> VA 0x7e7e9000!
>> [    0.184032] efi: Error mapping PA 0x7e7eb000 -> VA 0x7e7eb000!
>> [    0.184034] efi: Error mapping PA 0x7e7ec000 -> VA 0x7e7ec000!
>> [    0.184036] efi: Error mapping PA 0x7e801000 -> VA 0x7e801000!
>> [    0.184039] efi: Error mapping PA 0x7e812000 -> VA 0x7e812000!
>> [    0.184041] efi: Error mapping PA 0x7e823000 -> VA 0x7e823000!
>> [    0.184043] efi: Error mapping PA 0x7e82b000 -> VA 0x7e82b000!
>> [    0.184046] efi: Error mapping PA 0x7e82e000 -> VA 0x7e82e000!
>> [    0.184048] efi: Error mapping PA 0x7e831000 -> VA 0x7e831000!
>> [    0.184050] efi: Error mapping PA 0x7e94d000 -> VA 0x7e94d000!
>> [    0.184053] efi: Error mapping PA 0x7e96f000 -> VA 0x7e96f000!
>> [    0.184055] efi: Error mapping PA 0x7e997000 -> VA 0x7e997000!
>> [    0.184057] efi: Error mapping PA 0x7e9a4000 -> VA 0x7e9a4000!
>> [    0.184060] efi: Error mapping PA 0x7e9b2000 -> VA 0x7e9b2000!
>> [    0.184062] efi: Error mapping PA 0x7ec26000 -> VA 0x7ec26000!
>> [    0.184065] efi: Error mapping PA 0x7ec27000 -> VA 0x7ec27000!
>> [    0.184067] efi: Error mapping PA 0x7f5f7000 -> VA 0x7f5f7000!
>> [    0.184069] efi: Error mapping PA 0x7f6f7000 -> VA 0x7f6f7000!
>> [    0.184072] efi: Error mapping PA 0x7f7e1000 -> VA 0x7f7e1000!
>> [    0.184074] efi: Error mapping PA 0x7f7f7000 -> VA 0x7f7f7000!
>> [    0.184076] efi: Error mapping PA 0x7f8ca000 -> VA 0x7f8ca000!
>> [    0.184079] efi: Error mapping PA 0x7f8f7000 -> VA 0x7f8f7000!
>> [    0.184081] efi: Error mapping PA 0x7fb7b000 -> VA 0x7fb7b000!
>> [    0.184083] efi: Error mapping PA 0x7fb89000 -> VA 0x7fb89000!
>> [    0.184086] efi: Error mapping PA 0x7fbbb000 -> VA 0x7fbbb000!
>> [    0.184088] efi: Error mapping PA 0x7fbbc000 -> VA 0x7fbbc000!
>> [    0.184091] efi: Error mapping PA 0x100000000 -> VA 0x100000000!
>> [    0.184093] efi: Error mapping PA 0xfff90000 -> VA 0xfff90000!
>> [    0.184097] efi: Error ident-mapping new memmap (0x17b5a4000)!
>>
>> Le mar. 6 ao=C3=BBt 2019 =C3=A0 11:39, Antoine Reversat <a.reversat@gmai=
l.com> a
>> =C3=A9crit :
>>
>>> Sorry for the maybe not so helpful title.
>>>
>>> Here is the problem :
>>> I'm running Linux on a Mac pro 1,1 (the first x86 mac pro). It's a dual
>>> xeon 5150 with ECC ram. I have 2 ram kits in it : 2x512M and 2x2G (this=
 one
>>> :
>>> http://www.ec.kingston.com/ecom/hyperx_us/partsinfo.asp?root=3D&ktcpart=
no=3DKTA-MP667AK2/4G
>>> )
>>>
>>> If I only have the 2x512M kit everything works fine for all kernel
>>> versions but if I have both kits or just the 2x2G kit any kernel above =
4.10
>>> panics very early on (picture of said panic https://imgur.com/a/PipU5Oc=
).
>>> The picture was taken on 4.15 (using earlyprintk=3Defi,keep) on other
>>> versions even using earlyprintk I don't get any output.
>>>
>>> I have been trying several kernels and everything up to 4.11 works no
>>> problem. Then on 4.11 I got a panic which mentionned NX and pages being=
 in
>>> W+X which prompted me to try noexec=3Doff on newer versions and that fi=
xes
>>> the panic. This works up to 5.2.5.
>>>
>>> /proc/cpuinfo reports that the CPU support the NX flag.
>>>
>>> I would need help in order to troubleshoot this further.
>>>
>>

--0000000000008622f5058f763c47
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">As it turns out adding the efi=3Dold_map kernel parameter =
(and removing noexec=3Doff) also fixes the issue.<br></div><br><div class=
=3D"gmail_quote"><div dir=3D"ltr" class=3D"gmail_attr">Le=C2=A0mar. 6 ao=C3=
=BBt 2019 =C3=A0=C2=A012:25, Antoine Reversat &lt;<a href=3D"mailto:a.rever=
sat@gmail.com">a.reversat@gmail.com</a>&gt; a =C3=A9crit=C2=A0:<br></div><b=
lockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-le=
ft:1px solid rgb(204,204,204);padding-left:1ex"><div dir=3D"ltr">Could this=
 be caused by the fact that this machine uses a 32bit efi bios on a 64bit p=
latform ?<br></div><br><div class=3D"gmail_quote"><div dir=3D"ltr" class=3D=
"gmail_attr">Le=C2=A0mar. 6 ao=C3=BBt 2019 =C3=A0=C2=A012:23, Antoine Rever=
sat &lt;<a href=3D"mailto:a.reversat@gmail.com" target=3D"_blank">a.reversa=
t@gmail.com</a>&gt; a =C3=A9crit=C2=A0:<br></div><blockquote class=3D"gmail=
_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204=
,204);padding-left:1ex"><div dir=3D"ltr"><div>On a booted 5.2.5, at the poi=
nt where I see the panic I get : <br></div><div><br></div><div>[ =C2=A0 =C2=
=A00.183953] efi: Error mapping PA 0x0 -&gt; VA 0x0!<br>[ =C2=A0 =C2=A00.18=
3956] efi: Error mapping PA 0x90000 -&gt; VA 0x90000!<br>[ =C2=A0 =C2=A00.1=
83959] efi: Error mapping PA 0x100000 -&gt; VA 0x100000!<br>[ =C2=A0 =C2=A0=
0.183961] efi: Error mapping PA 0x2165000 -&gt; VA 0x2165000!<br>[ =C2=A0 =
=C2=A00.183963] efi: Error mapping PA 0x2200000 -&gt; VA 0x2200000!<br>[ =
=C2=A0 =C2=A00.183966] efi: Error mapping PA 0x4265000 -&gt; VA 0x4265000!<=
br>[ =C2=A0 =C2=A00.183968] efi: Error mapping PA 0x30ae7000 -&gt; VA 0x30a=
e7000!<br>[ =C2=A0 =C2=A00.183971] efi: Error mapping PA 0x3456b000 -&gt; V=
A 0x3456b000!<br>[ =C2=A0 =C2=A00.183973] efi: Error mapping PA 0x5d590000 =
-&gt; VA 0x5d590000!<br>[ =C2=A0 =C2=A00.183975] efi: Error mapping PA 0x7c=
84e000 -&gt; VA 0x7c84e000!<br>[ =C2=A0 =C2=A00.183978] efi: Error mapping =
PA 0x7c864000 -&gt; VA 0x7c864000!<br>[ =C2=A0 =C2=A00.183980] efi: Error m=
apping PA 0x7c86f000 -&gt; VA 0x7c86f000!<br>[ =C2=A0 =C2=A00.183982] efi: =
Error mapping PA 0x7c891000 -&gt; VA 0x7c891000!<br>[ =C2=A0 =C2=A00.183985=
] efi: Error mapping PA 0x7c8cb000 -&gt; VA 0x7c8cb000!<br>[ =C2=A0 =C2=A00=
.183987] efi: Error mapping PA 0x7c8d0000 -&gt; VA 0x7c8d0000!<br>[ =C2=A0 =
=C2=A00.183989] efi: Error mapping PA 0x7d0d6000 -&gt; VA 0x7d0d6000!<br>[ =
=C2=A0 =C2=A00.183992] efi: Error mapping PA 0x7d0d9000 -&gt; VA 0x7d0d9000=
!<br>[ =C2=A0 =C2=A00.183994] efi: Error mapping PA 0x7d0de000 -&gt; VA 0x7=
d0de000!<br>[ =C2=A0 =C2=A00.183996] efi: Error mapping PA 0x7d0df000 -&gt;=
 VA 0x7d0df000!<br>[ =C2=A0 =C2=A00.183999] efi: Error mapping PA 0x7d11c00=
0 -&gt; VA 0x7d11c000!<br>[ =C2=A0 =C2=A00.184001] efi: Error mapping PA 0x=
7d11d000 -&gt; VA 0x7d11d000!<br>[ =C2=A0 =C2=A00.184003] efi: Error mappin=
g PA 0x7e776000 -&gt; VA 0x7e776000!<br>[ =C2=A0 =C2=A00.184006] efi: Error=
 mapping PA 0x7e78b000 -&gt; VA 0x7e78b000!<br>[ =C2=A0 =C2=A00.184008] efi=
: Error mapping PA 0x7e7cb000 -&gt; VA 0x7e7cb000!<br>[ =C2=A0 =C2=A00.1840=
10] efi: Error mapping PA 0x7e7cc000 -&gt; VA 0x7e7cc000!<br>[ =C2=A0 =C2=
=A00.184013] efi: Error mapping PA 0x7e7d6000 -&gt; VA 0x7e7d6000!<br>[ =C2=
=A0 =C2=A00.184015] efi: Error mapping PA 0x7e7d9000 -&gt; VA 0x7e7d9000!<b=
r>[ =C2=A0 =C2=A00.184017] efi: Error mapping PA 0x7e7dd000 -&gt; VA 0x7e7d=
d000!<br>[ =C2=A0 =C2=A00.184020] efi: Error mapping PA 0x7e7e0000 -&gt; VA=
 0x7e7e0000!<br>[ =C2=A0 =C2=A00.184022] efi: Error mapping PA 0x7e7e2000 -=
&gt; VA 0x7e7e2000!<br>[ =C2=A0 =C2=A00.184025] efi: Error mapping PA 0x7e7=
e3000 -&gt; VA 0x7e7e3000!<br>[ =C2=A0 =C2=A00.184027] efi: Error mapping P=
A 0x7e7e6000 -&gt; VA 0x7e7e6000!<br>[ =C2=A0 =C2=A00.184029] efi: Error ma=
pping PA 0x7e7e9000 -&gt; VA 0x7e7e9000!<br>[ =C2=A0 =C2=A00.184032] efi: E=
rror mapping PA 0x7e7eb000 -&gt; VA 0x7e7eb000!<br>[ =C2=A0 =C2=A00.184034]=
 efi: Error mapping PA 0x7e7ec000 -&gt; VA 0x7e7ec000!<br>[ =C2=A0 =C2=A00.=
184036] efi: Error mapping PA 0x7e801000 -&gt; VA 0x7e801000!<br>[ =C2=A0 =
=C2=A00.184039] efi: Error mapping PA 0x7e812000 -&gt; VA 0x7e812000!<br>[ =
=C2=A0 =C2=A00.184041] efi: Error mapping PA 0x7e823000 -&gt; VA 0x7e823000=
!<br>[ =C2=A0 =C2=A00.184043] efi: Error mapping PA 0x7e82b000 -&gt; VA 0x7=
e82b000!<br>[ =C2=A0 =C2=A00.184046] efi: Error mapping PA 0x7e82e000 -&gt;=
 VA 0x7e82e000!<br>[ =C2=A0 =C2=A00.184048] efi: Error mapping PA 0x7e83100=
0 -&gt; VA 0x7e831000!<br>[ =C2=A0 =C2=A00.184050] efi: Error mapping PA 0x=
7e94d000 -&gt; VA 0x7e94d000!<br>[ =C2=A0 =C2=A00.184053] efi: Error mappin=
g PA 0x7e96f000 -&gt; VA 0x7e96f000!<br>[ =C2=A0 =C2=A00.184055] efi: Error=
 mapping PA 0x7e997000 -&gt; VA 0x7e997000!<br>[ =C2=A0 =C2=A00.184057] efi=
: Error mapping PA 0x7e9a4000 -&gt; VA 0x7e9a4000!<br>[ =C2=A0 =C2=A00.1840=
60] efi: Error mapping PA 0x7e9b2000 -&gt; VA 0x7e9b2000!<br>[ =C2=A0 =C2=
=A00.184062] efi: Error mapping PA 0x7ec26000 -&gt; VA 0x7ec26000!<br>[ =C2=
=A0 =C2=A00.184065] efi: Error mapping PA 0x7ec27000 -&gt; VA 0x7ec27000!<b=
r>[ =C2=A0 =C2=A00.184067] efi: Error mapping PA 0x7f5f7000 -&gt; VA 0x7f5f=
7000!<br>[ =C2=A0 =C2=A00.184069] efi: Error mapping PA 0x7f6f7000 -&gt; VA=
 0x7f6f7000!<br>[ =C2=A0 =C2=A00.184072] efi: Error mapping PA 0x7f7e1000 -=
&gt; VA 0x7f7e1000!<br>[ =C2=A0 =C2=A00.184074] efi: Error mapping PA 0x7f7=
f7000 -&gt; VA 0x7f7f7000!<br>[ =C2=A0 =C2=A00.184076] efi: Error mapping P=
A 0x7f8ca000 -&gt; VA 0x7f8ca000!<br>[ =C2=A0 =C2=A00.184079] efi: Error ma=
pping PA 0x7f8f7000 -&gt; VA 0x7f8f7000!<br>[ =C2=A0 =C2=A00.184081] efi: E=
rror mapping PA 0x7fb7b000 -&gt; VA 0x7fb7b000!<br>[ =C2=A0 =C2=A00.184083]=
 efi: Error mapping PA 0x7fb89000 -&gt; VA 0x7fb89000!<br>[ =C2=A0 =C2=A00.=
184086] efi: Error mapping PA 0x7fbbb000 -&gt; VA 0x7fbbb000!<br>[ =C2=A0 =
=C2=A00.184088] efi: Error mapping PA 0x7fbbc000 -&gt; VA 0x7fbbc000!<br>[ =
=C2=A0 =C2=A00.184091] efi: Error mapping PA 0x100000000 -&gt; VA 0x1000000=
00!<br>[ =C2=A0 =C2=A00.184093] efi: Error mapping PA 0xfff90000 -&gt; VA 0=
xfff90000!<br>[ =C2=A0 =C2=A00.184097] efi: Error ident-mapping new memmap =
(0x17b5a4000)!</div></div><br><div class=3D"gmail_quote"><div dir=3D"ltr" c=
lass=3D"gmail_attr">Le=C2=A0mar. 6 ao=C3=BBt 2019 =C3=A0=C2=A011:39, Antoin=
e Reversat &lt;<a href=3D"mailto:a.reversat@gmail.com" target=3D"_blank">a.=
reversat@gmail.com</a>&gt; a =C3=A9crit=C2=A0:<br></div><blockquote class=
=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rg=
b(204,204,204);padding-left:1ex"><div dir=3D"ltr"><div>Sorry for the maybe =
not so helpful title.</div><div><br></div><div>Here is the problem :</div><=
div>I&#39;m running Linux on a Mac pro 1,1 (the first x86 mac pro). It&#39;=
s a dual xeon 5150 with ECC ram. I have 2 ram kits in it : 2x512M and 2x2G =
(this one : <a href=3D"http://www.ec.kingston.com/ecom/hyperx_us/partsinfo.=
asp?root=3D&amp;ktcpartno=3DKTA-MP667AK2/4G" target=3D"_blank">http://www.e=
c.kingston.com/ecom/hyperx_us/partsinfo.asp?root=3D&amp;ktcpartno=3DKTA-MP6=
67AK2/4G</a>)</div><div><br></div><div>If I only have the 2x512M kit everyt=
hing works fine for all kernel versions but if I have both kits or just the=
 2x2G kit any kernel above 4.10 panics very early on (picture of said panic=
 <a href=3D"https://imgur.com/a/PipU5Oc" target=3D"_blank">https://imgur.co=
m/a/PipU5Oc</a>). The picture was taken on 4.15 (using earlyprintk=3Defi,ke=
ep) on other versions even using earlyprintk I don&#39;t get any output.<br=
></div><div><br></div><div>I have been trying several kernels and everythin=
g up to 4.11 works no problem. Then on 4.11 I got a panic which mentionned =
NX and pages being in W+X which prompted me to try noexec=3Doff on newer ve=
rsions and that fixes the panic. This works up to 5.2.5.<br></div><div><br>=
</div><div>/proc/cpuinfo reports that the CPU support the NX flag. <br></di=
v><div><br></div><div>I would need help in order to troubleshoot this furth=
er.<br></div></div>
</blockquote></div>
</blockquote></div>
</blockquote></div>

--0000000000008622f5058f763c47--

