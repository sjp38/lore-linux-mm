Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6F9AC28CC5
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 20:00:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DE18208E3
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 20:00:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=googlemail.com header.i=@googlemail.com header.b="iCm+4VqZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DE18208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=googlemail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D52236B0008; Sat,  8 Jun 2019 16:00:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D029E6B000A; Sat,  8 Jun 2019 16:00:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD5B66B000C; Sat,  8 Jun 2019 16:00:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 94A656B0008
	for <linux-mm@kvack.org>; Sat,  8 Jun 2019 16:00:44 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id z52so2714482otb.13
        for <linux-mm@kvack.org>; Sat, 08 Jun 2019 13:00:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=wvkpFaao1bpKQ1FWayC3EusodSIMGE6w694SSNfMEPA=;
        b=OFNoZmuSceqeu5uNGF+8UeE+eaySljfg2KbgROMNbSm6Yjq1+c9OXKm2HGy/eYm3bc
         C48GX3yRucRhlSE3SKQK/JRQXFPtvZA351hTExr6e6mse8/PS3ZJMxAmgC6i6+tToM0b
         gPK2W1rZiPAcaVVVQL98JbrDBn1orpPmdDh0BKU1PSvMjPcIKenS3DLatbfme7nOcpXo
         XohshCM46DI2N6yYwzOYKnYRLdL5EYBjMG0NxLAOGpedFKNdhY63RhVXVCrUfEhz9yOm
         c6Vy+Mv44NWSGdPf8oa9/R7Rqx9XGOCu2783wCD2QsUj0VJBcnP73flsDtqOJyUejTD0
         8acw==
X-Gm-Message-State: APjAAAWmqRJOjoJSGP16KviSnSRVS5LeRq0VdFaYRkAMuRTK0ljCSEfX
	hGNuVICuvaTdOLhAb9hIYlv7dZcFWuE1lIlPKiomsJdJRGqmdFwa8My307oJlS+kS0cRc0ZaZL6
	+nA5KTBzeCGiktpdMLMuH1wbRRwDWz615258PkrFAgHsQ4NgYlhdq0jdvzvu8qPP4Xg==
X-Received: by 2002:a9d:3ba4:: with SMTP id k33mr23609227otc.68.1560024044117;
        Sat, 08 Jun 2019 13:00:44 -0700 (PDT)
X-Received: by 2002:a9d:3ba4:: with SMTP id k33mr23609176otc.68.1560024043247;
        Sat, 08 Jun 2019 13:00:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560024043; cv=none;
        d=google.com; s=arc-20160816;
        b=olDU9dI3VevFM48xO+hyuY8tt0fSa2hKrHB9JlU0BSRIm66K2qIW2BGDfc/xZd9AaD
         UqItOV1rR9S2uX87G0NjxZfyr3KSl81Fmx4Vph0lfrtCx/r6XdZdTJI5hf8ZN4fuEHiT
         NcaPFlQY6t5KHbYFIeUAZ5jQGM537jZHbLEQ4cNqwD00/wk3xNuDHVPhhHe0HEpfRMCX
         kSmbz030H1h9FL+lUTY07oci+zQE8q3FgQF7zde0mbNZCF1skPx61NBuqhUtxExuS48D
         sq+kkcLUvlSXjBwtOPbSYaTnJwkhFzYxMrq8sweR37t8oSLdHlU7en3OCMcq6Fpt7v5K
         Zqcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=wvkpFaao1bpKQ1FWayC3EusodSIMGE6w694SSNfMEPA=;
        b=SQr4cZjTcnVxQQMvGoLHTESysT4X9c6ySYgn80In1fKIZ0tpsNkliTTHcuOtOs2AIa
         Zbp1VGa8T4ebmjg+XOfgRhBAlreKZPsFsIxh5RH/lJSyVuzmIrUKqaSOnyxOTe5iYk/q
         NYfNCD1k1RHcwGCutT6jgjD2Yw7NT27q0Wf4SbX5m8bbpGcOyKtyBa3GAlNBTTs1zHvZ
         aSkqvKXV/i2QDw2rXxBxFcmX6sMuK2Pz/8ZFTBiEi3FelipQ3709hwu79GMgsYGesSR2
         V8Z926aX/1jY0vOlrV6YHeuEd1ZNTlfqh0YuEXtSTwmiTDOV6NuHZoTSM0d6ItgfuGtY
         X75w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@googlemail.com header.s=20161025 header.b=iCm+4VqZ;
       spf=pass (google.com: domain of martin.blumenstingl@googlemail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=martin.blumenstingl@googlemail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=googlemail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z22sor2709719ote.183.2019.06.08.13.00.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 08 Jun 2019 13:00:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of martin.blumenstingl@googlemail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@googlemail.com header.s=20161025 header.b=iCm+4VqZ;
       spf=pass (google.com: domain of martin.blumenstingl@googlemail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=martin.blumenstingl@googlemail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=googlemail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=googlemail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wvkpFaao1bpKQ1FWayC3EusodSIMGE6w694SSNfMEPA=;
        b=iCm+4VqZSt6kP2oAqKNK9ttO+n1BscayXijHYPF97LlKXKRTy/SQJZN8g6ptnB37GY
         2qpvcyeM4ipaUGv65IBoJk02Qm02N2zjp1eUXMCq+AN4trMiVdYmCSqfFUNnpqCeLs73
         Hp2SAEt7Mvr8wKtGNmb72g6Av+lQZbvcgd3MLPNKA40YmEdhRMR+1oBXTPPWTEwvlJzj
         tt/CdN305EsiUJ9JuqpVD3D7V7QibejrzDVzpZwMPG3HBT3xKfgfibme2CBG/1ZgwDvL
         bvRP90LTWNSXGucxuU1L5uvWJLtOO0uXdC4As8XsFXZ4rsoY6xw7ij12LQADBI9QEXzN
         hF4Q==
X-Google-Smtp-Source: APXvYqzE1S4at/LKVQiJdPOZ7qR8leNmGzSuvzyjOZztdFT72UxQXxBOmWKetA1I5Vc/iv6tZY4wzFoHoG2nI91n1qA=
X-Received: by 2002:a9d:6d8d:: with SMTP id x13mr23458026otp.6.1560024042878;
 Sat, 08 Jun 2019 13:00:42 -0700 (PDT)
MIME-Version: 1.0
References: <CAFBinCBOX8HyY-UocsVQvsnTr4XWXyE9oU+f2xhO1=JU0i_9ow@mail.gmail.com>
 <20190321214401.GC19508@bombadil.infradead.org> <CAFBinCA6oK5UhDAt9kva5qRisxr2gxMF26AMK8vC4b1DN5RXrw@mail.gmail.com>
 <5cad2529-8776-687e-58d0-4fb9e2ec59b1@amlogic.com> <CAFBinCA=0XSSVmzfTgb4eSiVFr=XRHqLOVFGyK0++XRty6VjnQ@mail.gmail.com>
 <32799846-b8f0-758f-32eb-a9ce435e0b79@amlogic.com> <CAFBinCDHmuNZxuDf3pe2ij6m8aX2fho7L+B9ZMaMOo28tPZ62Q@mail.gmail.com>
 <79b81748-8508-414f-c08a-c99cb4ae4b2a@amlogic.com> <CAFBinCCSkVGp_iWKf=o=7UGuDUWxyLPGdrqGy_P-HPuEJiU1zQ@mail.gmail.com>
 <8cb108ff-7a72-6db4-660d-33880fcee08a@amlogic.com> <CAFBinCD4cRGbC=cFYEGVAHOtBSvrgNbCSfDWe3To0KCE5+ceVw@mail.gmail.com>
 <45ce172c-5c76-bb69-31c8-af91e8ffdd68@amlogic.com>
In-Reply-To: <45ce172c-5c76-bb69-31c8-af91e8ffdd68@amlogic.com>
From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Date: Sat, 8 Jun 2019 22:00:31 +0200
Message-ID: <CAFBinCDWaDoRbbG+5B=27MNRTcekbooEdgAZv5kyS+Xu6M7Bzg@mail.gmail.com>
Subject: Re: 32-bit Amlogic (ARM) SoC: kernel BUG in kfree()
To: Liang Yang <liang.yang@amlogic.com>
Cc: Matthew Wilcox <willy@infradead.org>, mhocko@suse.com, linux@armlinux.org.uk, 
	linux-kernel@vger.kernel.org, rppt@linux.ibm.com, linux-mm@kvack.org, 
	linux-mtd@lists.infradead.org, linux-amlogic@lists.infradead.org, 
	akpm@linux-foundation.org, linux-arm-kernel@lists.infradead.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Liang,

On Thu, Apr 11, 2019 at 5:00 AM Liang Yang <liang.yang@amlogic.com> wrote:
>
> Hi Martin,
> On 2019/4/11 1:54, Martin Blumenstingl wrote:
> > Hi Liang,
> >
> > On Wed, Apr 10, 2019 at 1:08 PM Liang Yang <liang.yang@amlogic.com> wrote:
> >>
> >> Hi Martin,
> >>
> >> On 2019/4/5 12:30, Martin Blumenstingl wrote:
> >>> Hi Liang,
> >>>
> >>> On Fri, Mar 29, 2019 at 8:44 AM Liang Yang <liang.yang@amlogic.com> wrote:
> >>>>
> >>>> Hi Martin,
> >>>>
> >>>> On 2019/3/29 2:03, Martin Blumenstingl wrote:
> >>>>> Hi Liang,
> >>>> [......]
> >>>>>> I don't think it is caused by a different NAND type, but i have followed
> >>>>>> the some test on my GXL platform. we can see the result from the
> >>>>>> attachment. By the way, i don't find any information about this on meson
> >>>>>> NFC datasheet, so i will ask our VLSI.
> >>>>>> Martin, May you reproduce it with the new patch on meson8b platform ? I
> >>>>>> need a more clear and easier compared log like gxl.txt. Thanks.
> >>>>> your gxl.txt is great, finally I can also compare my own results with
> >>>>> something that works for you!
> >>>>> in my results (see attachment) the "DATA_IN  [256 B, force 8-bit]"
> >>>>> instructions result in a different info buffer output.
> >>>>> does this make any sense to you?
> >>>>>
> >>>> I have asked our VLSI designer for explanation or simulation result by
> >>>> an e-mail. Thanks.
> >>> do you have any update on this?
> >> Sorry. I haven't got reply from VLSI designer yet. We tried to improve
> >> priority yesterday, but i still can't estimate the time. There is no
> >> document or change list showing the difference between m8/b and gxl/axg
> >> serial chips. Now it seems that we can't use command NFC_CMD_N2M on nand
> >> initialization for m8/b chips and use *read byte from NFC fifo register*
> >> instead.
> > thank you for the status update!
> >
> > I am trying to understand your suggestion not to use NFC_CMD_N2M:
> > the documentation (public S922X datasheet from Hardkernel: [0]) states
> > that P_NAND_BUF (NFC_REG_BUF in the meson_nand driver) can hold up to
> > four bytes of data. is this the "read byte from NFC FIFO register" you
> > mentioned?
> >
> You are right.take the early meson NFC driver V2 on previous mail as a
> reference.
>
> > Before I spend time changing the code to use the FIFO register I would
> > like to wait for an answer from your VLSI designer.
> > Setting the "correct" info buffer length for NFC_CMD_N2M on the 32-bit
> > SoCs seems like an easier solution compared to switching to the FIFO
> > register. Keeping NFC_CMD_N2M on the 32-bit SoCs also allows us to
> > have only one code-path for 32 and 64 bit SoCs, meaning we don't have
> > to maintain two separate code-paths for basically the same
> > functionality (assuming that NFC_CMD_N2M is not completely broken on
> > the 32-bit SoCs, we just don't know how to use it yet).
> >
> All right. I am also waiting for the answer.
do you have any update on this?


Martin

